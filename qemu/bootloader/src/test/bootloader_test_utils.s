.align 4

.include "bootloader.inc"

.section .text

.globl set_write_final_state
set_write_final_state:
    add     s5, x0, a0
    jr      ra


.globl set_read_final_state
set_read_final_state:
    add     s6, x0, a0
    jr      ra


.globl set_jump_final_state
set_jump_final_state:
    add     a7, x0, a0
    jr      ra


# Public function to set the machine state
# (testing purposes)
#
# in:  a0 Machine state to set
.globl set_machine_state
set_machine_state:
    add     s2, x0, a0
    jr      ra


.globl get_machine_state
get_machine_state:
    add     a0, x0, s2
    jr      ra


# Public function to set last value read
# (testing purposes)
#
# in:  a0 Last value read to set
.globl set_last_val_read
set_last_val_read:
    add     s3, x0, a0
    jr      ra


.globl set_mem_offset
set_mem_offset:
    la      s4, _fwimg
    add     s4, s4, a0
    jr      ra


.globl cpu_reset
cpu_reset:
    addi    t0, x0, 0
    addi    t1, x0, 0
    addi    t2, x0, 0
    addi    a0, x0, 0
    addi    a1, x0, 0
    addi    a2, x0, 0
    addi    a3, x0, 0
    addi    a4, x0, 0
    addi    a5, x0, 0
    addi    a6, x0, 0
    addi    a7, x0, 0
    addi    s2, x0, 0
    addi    s3, x0, 0
    la      s4, _fwimg
    addi    s5, x0, 0
    addi    s6, x0, 0
    addi    s7, x0, 0
    addi    s8, x0, 0
    addi    s9, x0, 0
    addi    s1, x0, 0
    addi    s1, x0, 0
    addi    t3, x0, 0
    addi    t4, x0, 0
    addi    t5, x0, 0
    addi    t6, x0, 0
    jr      ra
