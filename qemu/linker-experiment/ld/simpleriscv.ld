OUTPUT_ARCH("riscv")
OUTPUT_FORMAT("elf32-littleriscv")

MEMORY
{
    BOOTLOADER      (rx): ORIGIN = 0,       LENGTH = 2048
    FW_IMG_FLASH    (rx): ORIGIN = 2048,    LENGTH = 2048
    FW_IMG_RAM      (rx): ORIGIN = 4096,    LENGTH = 256
}

_stack_size = 256;

ENTRY(main)

SECTIONS
{
    .text.init :
    {
        _text.init = .;
        *(.text.init)
        _etext.init = .;
    } > FW_IMG

    .text :
    {
        _text = .;
        *(.text)
        _etext = .;
    } > FW_IMG

    .data :
    {
        _sdata = .;
        *(.data)
        _edata = .;
    } > FW_IMG

    . = ORIGIN(FW_IMG) + LENGTH(FW_IMG) - _stack_size;
    _stack_bottom = .;
    . = ORIGIN(FW_IMG) + LENGTH(FW_IMG);
    _stack_top = .;

    _end = .;
}
