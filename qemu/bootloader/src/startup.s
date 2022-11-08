.align 4

.section .text

.section .isr_vector

.globl _start
_start:
    la      sp, _stack_top
    j       bootloader_main

bootloader_main:
    call    bld_reset
bld_loop:
    call    bld_next_state
    call    bld_exec_state
    jal     x0, bld_loop
