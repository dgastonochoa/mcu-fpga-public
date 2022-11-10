.align 4

.section .text

.section .isr_vector

.globl _start
_start:
    la      sp, _stack_top
    j       main
