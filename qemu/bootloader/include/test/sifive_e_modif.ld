OUTPUT_ARCH( "riscv" )
OUTPUT_FORMAT("elf32-littleriscv")
ENTRY( _start )
SECTIONS
{
  /* text: test code section */
  . = 0x20400000;

    .text.isr_vector :
    {
        _text.isr_vector = .;
        *(.text.isr_vector) /* Note: verify that _start is at address 0 after build */
        _etext.isr_vector = .;
    }

  .text :
  {
    _text = .;
    *(.text)
    *(.rodata)
    _etext = .;
  }

  /* gnu_build_id: readonly build identifier */
  .gnu_build_id : { *(.note.gnu.build-id) }
  /* rodata: readonly data segment */

  /* data: Initialized data segment */
  . = 0x80000000;
  .data :
  {
    _data = .;
    *(.data)
    _edata = .;
  }
  .sdata : { *(.sdata) }
  .debug : { *(.debug) }
  . += 0x1000;
  stack_top = .;

  /* End of uninitalized data segement */
  _end = .;

  . = ALIGN(4);
  .fwimg :
  {
    _fwimg = .;
    *(.fwimg)
    _efwimg = .;
  }
}
