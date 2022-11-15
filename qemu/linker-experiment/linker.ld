OUTPUT_ARCH("riscv")
OUTPUT_FORMAT("elf32-littleriscv")

MEMORY
{
    FLASH       (rx):   ORIGIN = 0x20400000,      LENGTH = 508M
    RAM         (wrx):  ORIGIN = 0x80000000,      LENGTH = 16K
}

_stack_size = 256;

ENTRY(_start)

SECTIONS
{
    .text.init :
    {
        _text.init = .;
        *(.text.init)
        _etext.init = .;
    } > FLASH

    .text :
    {
        _text = .;
        *(.text)
        _etext = .;
    } > FLASH

    .srodata : ALIGN(4)
    {
        _srodata = .;
        *(.srodata)
        _esrodata = .;
    } > RAM AT > FLASH

    .tss (NOLOAD) : ALIGN(4)
    {
        _tss = .;
        *(.tss)
        _etss = .;
    } > RAM

    . = ORIGIN(RAM) + LENGTH(RAM) - _stack_size;
    _stack_bottom = .;
    . = ORIGIN(RAM) + LENGTH(RAM);
    _stack_top = .;

    _end = .;
}
