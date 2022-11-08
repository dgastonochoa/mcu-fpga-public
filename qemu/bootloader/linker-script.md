# > AREA_1 AT > AREA_2

Let a linker script be like:

    MEMORY
    {
        BOOTLOADER  (rx): ORIGIN = 0,       LENGTH = 2048
        FW_IMG      (rx): ORIGIN = 2048,    LENGTH = 2048
        SHARED      (rw): ORIGIN = 4096,    LENGTH = 40
    }

    ...

    SECTIONS
    {
        ...
        .data :
        {
            *(.data)
        } > SHARED AT > BOOTLOADER
        ...
    }

Then, `> SHARED AT > BOOTLOADER` can be explained as

    > `VMA` AT > `LMA`

Being VMA = Virtual Memory Address and LMA = Load Memory Address

In summary, in the generated **binary** file (not elf), all values in `data`
will be at adresses (file offsets) in the BOOTLOADER area, but all symbols
will be in the SHARED area.

This can be used to avoid generating huge binary files because some variables
have an init. value != 0, therefore they must exist in the binary image, however
they will be accessed at high addresses at runtime (e.g. if a platform defines a RAM
region at 0x80000000). To avoid generating a binary file with a ton of zeros so
that these variables are allocated at the right place, its LMAs are kept at low
addresses (FLASH for instance), its symbols at high (RAM for instance) and the
startup script will copy all values from LMA to VMA.

In other words, let `some_var` be:

    const uint32_t some_var = <some_value>;

That variable has a value != 0, therefore this value must exist at the binary file
when flashing it. However, let's suppose this variable needs to be allocated at RAM,
and let's suppose that RAM starts at 0x20000000. In order to allocate the right value
at the right address, even if the FW image contains only a few instructions, the
resulting image would need to be huge, at least 0x2000000 + 4. In order to avoid this,
assign this value a low LMA which will be close to the end of `.text`, say, 0x100.
However, the symbol `some_var` will still have address 0x2000000. In order for the app.
to read the right value, a startup script will copy `<some_value>` from 0x100 (its LMA)
to 0x20000000 (its VMA). From there on, the app will access `some_var` at address
0x20000000 without problems, and the binary image file's size will still be no much
bigger than 0x100 bytes.

## Example

Consider the following linker file:

    OUTPUT_ARCH("riscv")
    OUTPUT_FORMAT("elf32-littleriscv")

    MEMORY
    {
        BOOTLOADER  (rx): ORIGIN = 0,       LENGTH = 2048
        FW_IMG      (rx): ORIGIN = 2048,    LENGTH = 2048
        SHARED      (rw): ORIGIN = 4096,    LENGTH = 40
    }

    _stack_size = 64;

    ENTRY(_start)

    SECTIONS
    {
        .text :
        {
            _text = .;
            *(.isr_vector) /* Note: verify that _start is at address 0 after build */
            *(.text)
            _etext = .;
        } > BOOTLOADER

        .data :
        {
            _sdata = .;
            *(.data)
            _edata = .;
        } > SHARED AT > BOOTLOADER

        . = ORIGIN(BOOTLOADER) + LENGTH(BOOTLOADER) - _stack_size;
        _stack_bottom = .;
        . = ORIGIN(BOOTLOADER) + LENGTH(BOOTLOADER);
        _stack_top = .;

        _end = .;

        _fwimg = ORIGIN(FW_IMG);
    }

And this variable declared in some file:

    .align 4

    .section .data
    bld_v:
        .word   0xdeadc0de

Now, after generating the binary file:

    $ nm ./build/bootloader.elf | grep -E "bld_v"
    00001000 d bld_v

`nm` reveals that the `bld_v` symbol (var. name) is at 0x1000. However:

    $ xxd -e build/bootloader.bin | grep -E "dead"
    00000430: 00008067 deadc0de                    g.......
    $ ls -lrt ./build/bootloader.bin
    -rwxr-xr-x 1 danielgo all 1080 Nov  3 15:23 ./build/bootloader.bi

`xxd` reveals that the actual value, 0xdeadcode, is located at ~0x430.
Furthermore, `ls` reveals that the binary file size is only 1080 bytes,
far less than 0x1000 = 4096.

Indeed, VMA and LMA do not match:

    Idx Name          Size      VMA       LMA       File off  Algn
    0 .text         00000434  00000000  00000000  00001000  2**4
                    CONTENTS, ALLOC, LOAD, READONLY, CODE
    1 .data         00000004  00001000  00000434  00002000  2**0
                    CONTENTS, ALLOC, LOAD, DATA

So the value is kept at low addresses but the reference to it is at high
addresses, which are the ones to be used at runtime. Of course, as explained
above, this will require that someone (possibly the startup script) copies
this value from its LMA to its VMA.

The actual data, located at LMA, will need to be accessed by means other than
using the `bld_v` or `_sdata` symbols, since they are poiting to VMA already.
Therefore, the source pointer will be `_etext`, because `.data` starts immediatly
after `.text` finishes. So the loop would look like:

    const uint32_t* src_ptr = &_etext;
    for (uint32_t dst_ptr = &_sdata;
         dst_ptr < &_edata;
         dst_ptr++) {

        *dst_ptr = *src_ptr;
        src_ptr++;
    }

Another option would be defining a symbol just before `.data` to keep its
LMA, if that's less consufinsg:

    __sdata = .;
    .data :
    {
        _sdata = .;
        *(.data)
        _edata = .;
    } > SHARED AT > BOOTLOA

Then

    $ nm ./build/bootloader.elf | grep -E "data"
    00001004 D _edata
    00000434 T __sdata
    00001000 D _sdata

And so `__sdata` can replace `_etext` in the example above.

Finally, let's suppose that the `> SHARED AT > BOOTLOADER` is replaced by
`> BOOTLOADER`. The `nm` and `xxd` functions reveal the following:

    $ nm ./build/bootloader.elf | grep -E "bld_v"
    00000434 d bld_v
    $ xxd -e build/bootloader.bin | grep -E "dead"
    00000430: 00008067 deadc0de                    g.......

Now both the symbol and the actual value are located at ~0x434. Consequently,
VMA and LMA now match:

    Idx Name          Size      VMA       LMA       File off  Algn
      0 .text         00000434  00000000  00000000  00001000  2**4
                      CONTENTS, ALLOC, LOAD, READONLY, CODE
      1 .data         00000004  00000434  00000434  00001434  2**0
                      CONTENTS, ALLOC, LOAD, DATA

