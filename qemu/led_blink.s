.align 4

.section .text

.globl _start

.ifdef ASD
.error "QWE"
.endif

_start:
        lui     a1, 0x80000
        addi    a1, a1, 0x40

        lui     s3, 0x7f2
        addi    t0, x0, 1
        slli    t0, t0, 11
        add     s3, s3, t0
        addi    s3, s3, 0x15

        addi    s4, x0, 0
blink:
        add     a0, x0, s3
        jal     ra, busy_wait
        sw      s4, 0(a1)
        beq     s4, x0, led_1
        addi    s4, x0, 0
        jal     x0, blink
led_1:  addi    s4, x0, 1
        jal     x0, blink


# a0 = wait for 3*a0 cycles
busy_wait:
    addi    a0, a0, -1
    bne     a0, x0, busy_wait
    jalr    x0, ra, 0

