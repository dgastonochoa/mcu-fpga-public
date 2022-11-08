OUTPUT_ARCH("riscv")
OUTPUT_FORMAT("elf32-littleriscv")

MEMORY
{
    BOOTLOADER  (rx): ORIGIN = 0,       LENGTH = 2048
    FW_IMG      (rx): ORIGIN = 2048,    LENGTH = 2048
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
    } > BOOTLOADER

    . = ORIGIN(BOOTLOADER) + LENGTH(BOOTLOADER) - _stack_size;
    _stack_bottom = .;
    . = ORIGIN(BOOTLOADER) + LENGTH(BOOTLOADER);
    _stack_top = .;

    _end = .;

    _fwimg = ORIGIN(FW_IMG);

    /**
     * 'AT 1': If AT is used, the section will ignore the current '.'
     * That is, if before declaring the section the pointer is assigned
     * to something, e.g. '. = 0x100;', this will be ignored in the
     * following section if 'AT' is used.
     *
     */

    /**
     * Add LONG: If a LONG is added to a section, to mark it
     * for example, the linker will be forced to generate a bin file
     * which contains all 0x0s until _sstack is reached and then it
     * will insert the LONG value specified. If NOLOAD is used, the
     * linker will understand that that region is not to be initialised,
     * it won't add the LONG value and therefore will not be forced to add
     * a ton of 0x0s. However it would make no sense to add a constant
     * to the section and then mark it as NOLOAD.
     *
     */

    /**
     * Be very careful with alignments. If the address is not 4-byte aligned
     * if a constant such as LONG(0xdeadc0de) is declared, it will be put
     * in weird places, like in 2 separated words, e.g.:
     *
     * 00000fb0: 00000000 00000000 00000000 de000000
     * 00000fc0: 00deadc0
     *
     */

    /**
     * See linker-script.md to see an explanation of '> AREA AT > AREA'
     *
     */
}
