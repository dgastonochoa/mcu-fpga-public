# Introduction

 * VMA: Virtual memory address. This is the address/es by which the linker will replace
   references to a particular variable. That is, if `int x = 25` is at `VMA = 0x100`,
   `printf("%p\n", &x)` will print 100.

 * LMA: Load memory address. This is the address at which the value of a initialized
   variable will be. In the above example, if `LMA` of `x` is `0x10`, then
   `printf("%d\n", *((uint8_t*)0x10))` will print 25.

 * ELF and BIN images: ELF images contain address information. A flash tool or similar
   that receives this kind of files as an input will probably make use of this information
   to put stuff at particular addresses. This is the case of `qemu` for this particular
   example: it will run an `elf` file and it will place code at address `0x20400000`.
   On the other hand, binary files are just raw code an data, they don't contain address
   information. Therefore, they will just be plain-copied to memory, at a particular
   address.

 * LMA and loaders: If there is no loader, then there is no one to put values etc.
   from the FW elf image at particular addresses. In this case, LMA seems to not be
   very relevant. However, there will be SoCs whose addressable memory starts at a particular
   address, e.g. 0x80000000. That means that, even when flashing a raw binary image,
   the SoC will place this raw image starting at address 0x80000000. I imagine the update
   tool (e.g. dfu-util) will just send the raw image to the SoC (with some firmware already
   on it) over USB, SPI or whatever, and the SoC will start storing this data at 0x80000000
   or the like. This is exactly what `simpleriscv` does, but starting at address 0. But it
   could start at address `n` and just decode this address to something else, exactly what
   the `simpleriscv` memory-mapped periphs. do.
   In this case, it is important that LMA is correct, because when the code itself accesses
   data (e.g. to copy it to its destination VMA or anything), it will need to use the right
   address. That is, if the SoC says the first addressable memory is 0x1000, the FW cannot
   access memory 0x0 etc. therefore all its code/data must be at address 0x1000 or greater.

 * Offset: literally the offset at which an element is place in the generated binary image.
   This doesn't need to match LMA. The fact that LMA is, for instance, 0x2000000 won't make
   objcopy to generate huge file to satisfy this. It will generate a file starting to put
   data at offset 0 (at the beginning of the file), it won't fill it with zeros to reach
   the LMA. This is because a raw binary file is expected to be flashed/updated, in other
   words, to be written in memory, at address LMA. E.g. Let `x` bet at LMA = 0x2001000. In
   the binary file, it will be at offset 0x1000. When the file is updated, it will be written
   starting at address 0x2000000, therefore `x` will be at 0x2000000 + 0x1000 = 0x2001000, so
   the code will access it correctly.

 * `> A AT > B`: In other words, VMA = A, LMA = B.

 * `NOLOAD`: Instruct the linker mark a section as `NOLOAD`. This means that objcopy will
   discard it when generating the binary file from the elf one. However, this will only happen
   if discarding that section doesn't 'break' the image file layout. That is, if there are 3
   sections in this order 'A B C', to preserve the right offsets of code/data in the generated
   raw binary file, A and B cannot be discarded. At a very least they will need to be filled with
   zeros, to keep C at the right offset. See [Offset](Definitions::Offset). Some sections are marked
   as `NOLOAD` automatically by the linker, such as `.bss`. Whether or not a section is `NOLOAD`
   can be known by showing the elf file headers, e.g. with `objdump`.

 * `KEEP`: Create a section eventhough it doesn't have any contents.

 * `PROVIDE`: It's like `__attribute__((weak))` but for linker symbols (sections?)

 * Linker-script-defined symbols: beware that symbols defined inside sections will have its
   address located at the `VMA` defined for that particular section. For example, because of this,
   when copying the `.srodata` section to its `VMA`, `_srodata` and `_esrodata` must not be used
   as source pointers, but as destination ones. Another symbol must be defined to retrieve the
   LMA of `.srodata`, or like in this example, `_etext` can be used (because it's defined inside
   a section whose `VMA` is at `FLASH`, just before `.srodata` starts). Be careful with this,
   there could be paddings that would make `_etext` to not work for this (there shouldn't because
   `.text` is code, therefore it necessarily needs to be 4-byte aligned). In any case, another symbol
   can be created **just before the `.srodata` declaration and outside it**, so it picks the right
   address.


# Synopsys

This application intents to serve as an example of several linker script features.

The application changes the value of an array of LEDs depending on several variables,
stored at different places in memory.

 * There are several sequences of values which will be applied to each LED, 1 value per sec.
 * The sequence to be applied at the moment will change as a function of a state variable.

The application will use `.tss` instead of `.bss` to ilustrate the effects of `NOLOAD` (since
`.bss` is always `NOLOAD`)


# Data

## LED sequences

They have initial values, therefore this initial values will need to be in the binary file to
be 'flashed'. These values are to be located in `.srodata` just below `.text`, which will correspond
'flash' addresses (see above)

However, at runtime, its wanted to access them from RAM. Thus, 2 things need to be done:
 * The actual values must be moved from flash to RAM.
 * The addresses that the source code will use to fetch these values must refer to RAM
   addresses.

This could be solved by allocating these values directly at RAM addresses, but this would
generate a huge binary file, padded with zeroes from the end of `.text` to RAM, in order to
directly allocate their initial values in RAM.


To avoid this, the following is done:

The first point (values) is performed by a startup script, which will copy data from flash
to RAM.

The second point (addresses) is performed by the linker, by using `> RAM AT > FLASH`.

### Notes

Notice that `.srodata` is the name that the `riscv-unknown-elf` toolchain gives to `.rodata`


### Questions here

Verify the elf file size with and without `> RAM AT > FLASH`.

    The file size will be the same in this case. The VMA will be placed at RAM, and the
    actual values will be placed at flash. However, doing `> RAM AT > RAM` will indeed
    create huge files (both elf and bin)

Will making (or not) `.tss` `NOLOAD` modify the file size:

    Yes, by 4 bytes.


## State machine

This state is just expected to be initialized as zero. Therefore, instead of occupying more
space in flash, and making the elf file bigger, uninitialized values can just be initialized
to 0 by the startup script.

However, these values are wanted to have RAM addresses at runtime. Somehow, the linker must
know that :
 * The addresses of these values must be placed at RAM
 * Their initial values are just zero, therefore they don't need space in the elf file (and flash)
   to keep their initial values, they can just be initialized by the startup script.

The first point can be done by placing the `.bss` section (where unitialized values are placed)
at RAM addresses. Notice that all non-initialized data will usually be put in `.bss` by the linker,
there is no need for declaring this manually.

The second point can be done by indicating to the linker that `.bss` is `NOLOAD`. However, it might
happen that the toolchain sets `.bss` as `NOLOAD` by default. Therefore, in order to show the `NOLOAD`
behavior, a different section (different name) must be used (so `NOLOAD` can be added/deleted to see
the different behaviors)

### Questions here

If `.bss` is not declared as `NOLOAD`, will the linker be smart enough to see it is uninitialized
data, and therefore it won't create a huge binary file to have the `.bss` section at RAM?

    Notice that `> RAM` is setting the **VMA** of the section in question, therefore there is no way
    the linker will create a 'huge' binary file. However, if `> RAM AT > RAM` is used, that will
    indeed create a huge binary files

What happens with initialized sections declared as `NOLOAD`?

    If any section is declared as `NOLOAD`, it will not be added to the final binary image
    **by objcopy**


If the startup script doesn't initialize the `.tss` section, what values will it have?

    It should be unknow, although qemu seems to initialize the memory to 0 directly. In order
    to test this, make the startup script to set this area to all 0xff's, to simulate that it is
    actually doing something useful.
