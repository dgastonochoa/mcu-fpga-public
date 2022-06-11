.align 2
.include "cfg.inc"
.equ UART_REG_TXFIFO,   0

.section .text
.globl _start

_start:
        csrr    t0, mhartid             # read hardware thread id (`hart` stands for `hardware thread`)
        bnez    t0, halt                # run only on the first hardware thread (hartid == 0), halt all the other threads

        la      sp, stack_top           # setup stack pointer


        la      a0, msg                 # load address of `msg` to a0 argument register

ex639:
        add     a0, zero, zero
        lui     a0, 0xabcde
        addi    a0, a0, 0x789
        addi    a0, a0, 0x789
        jal     chendns

        la      a0, array10
        jal     chendns_ar


ex641:
        # a0 = 0x40fc0000
        # a1 = 0x3e400000
        lui     a0, 0x40fc0
        lui     a1, 0x3e400
        jal     add_pos_floats          # result should be 0x41010000

        li      a0, 0xC0D20004
        li      a1, 0x40DC0004
        jal     add_pos_floats          # result should be 0x3EA00000

        li      a0, 0x40d20004
        li      a1, 0xc0dc0004
        jal     add_pos_floats          # result should be 0xbea00000

        li      a0, 0xc0fc0000
        li      a1, 0xbe400000
        jal     add_pos_floats          # result should be 0xc1010000

        li      a0, 0xC0D20004
        li      a1, 0x40d20004
        jal     add_pos_floats          # result should be 0 -- TODO doesn't work

ex643:
        la      a0, array11
        li      a1, 10*4
        jal     bubble_sort


exi62:
        la      a0, array12
        li      a1, 5
        la      a2, array15
        jal     find_largest_sum

        la      a0, array13
        li      a1, 5
        la      a2, array15
        jal     find_largest_sum

        la      a0, array14
        li      a1, 5
        la      a2, array15
        jal     find_largest_sum


exi63:
        la      a0, array12
        li      a1, 5
        jal     rev_arr

        la      a0, array16
        li      a1, 6
        jal     rev_arr

        la      a0, array20
        li      a1, 6
        jal     rev_arr_b

        la      a0, array21
        li      a1, 5
        jal     rev_arr_b

        la      a0, sentence
        jal     rev_words

exi65:
        li      a0, 0xabcdef12
        jal     rev_reg

exi67:
        la      a0, palyn1
        li      a1, 8
        jal     palyn

        la      a0, palyn2
        li      a1, 8
        jal     palyn

        la      a0, palyn3
        li      a1, 5
        jal     palyn

        la      a0, palyn4
        li      a1, 5
        jal     palyn



        jal     puts                    # jump to `puts` subroutine, return address is stored in ra regster

halt:   wfi                    # enter the infinite loop

puts:                                 # `puts` subroutine writes null-terminated string to UART (serial communication port)
                                      # input: a0 register specifies the starting address of a null-terminated string
                                      # clobbers: t0, t1, t2 temporary registers

        li      t0, UART_BASE           # t0 = UART_BASE
1:      lbu     t1, (a0)                # t1 = load unsigned byte from memory address specified by a0 register
        beqz    t1, 3f                  # break the loop, if loaded byte was null

                                      # wait until UART is ready
2:      lw      t2, UART_REG_TXFIFO(t0) # t2 = uart[UART_REG_TXFIFO]
        bltz    t2, 2b                  # t2 becomes positive once UART is ready for transmission
        sw      t1, UART_REG_TXFIFO(t0) # send byte, uart[UART_REG_TXFIFO] = t1

        addi    a0, a0, 1               # increment a0 address by 1 byte
        j       1b

3:      wfi

# void set_array(int num) {
#   int i;
#   int array[10];
#   for (i = 0; i < 10; i = i + 1)
#       array[i] = compare(num, i);
# }
#
# int compare(int a, int b) {
##   if (sub(a, b) >= 0)
#       return 1;
##   else
#       return 0;
# }
#
# int sub(int a, int b) {
#   return a - b;
# }
set_array:
        add     t0, zero, sp
        addi    sp, sp, -(4*10)         # allocate space for 10 words
        add     t1, zero, sp            # array

        add     t2, zero, zero          # i
        addi    t3, zero, 10            # i_max
        add     t5, zero, t1            # array idx
sar_loop:
        addi    t4, zero, 0
        blt     a0, t2, _ali
        addi    t4, zero, 1
_ali:
        sw      t4, (t5)
        addi    t5, t5, 4
        addi    t2, t2, 1
        blt     t2, t3, sar_loop

        add     sp, zero, t0
        add     a0, zero, t1
        jr      ra


chendns:
        add     t1, zero, zero  # aux
        add     t2, zero, zero  # res

        # first byte
        slli    t2, a0, 24

        # second byte
        srli    t1, a0, 8
        andi    t1, t1, 0xff
        slli    t1, t1, 16
        or      t2, t1, t2

        # third byte
        srli    t1, a0, 16
        andi    t1, t1, 0xff
        slli    t1, t1, 8
        or      t2, t1, t2

        # fourth byte
        srli    t1, a0, 24
        or      t2, t1, t2

        add     a0, zero, t2
        jr      ra


chendns_ar:
        addi    sp, sp, -(4*4)
        sw      ra, 0(sp)
        sw      a0, 4(sp)
        sw      s0, 8(sp)
        sw      s1, 12(sp)

        add     s0, zero, a0

        addi    s1, zero, 0     # i
        addi    s2, zero, 10    # i_max
chendns_loop:
        lw      a0, (s0)
        jal     chendns
        sw      a0, (s0)

        addi    s0, s0, 4
        addi    s1, s1, 1
        blt     s1, s2, chendns_loop

        lw      s1, 12(sp)
        lw      s0, 8(sp)
        lw      a0, 4(sp)
        lw      ra, 0(sp)
        addi    sp, sp, (4*4)
        jr      ra


# a0 float 0
# a1 float 1
add_pos_floats:
extract:
        lui     t4, 0x7ff + 1
        addi    t4, t4, -1          # mantissa mask (0x7fffff)
        and     t0, a0, t4          # t0 = a0 mantissa
        and     t1, a1, t4          # t1 = t1 mantissa
        lui     t4, 0x800           # t4 = 0x00800000 (impl. leading 1)
        or      t0, t0, t4          # add implicit 1 to a0 mantissa
        or      t1, t1, t4          # add implicit 1 to a1 mantissa
        lui     t4, 0x7f800         # exponent mask
        and     t2, a0, t4          # t2 = a0 exponent
        srli    t2, t2, 23          # shift a0 exp. right
        and     t3, a1, t4          # t3 = a1 exponent
        srli    t3, t3, 23          # shift a1 exp. right
compare:
        beq     t2, t3, check_sign  # check if exponents match
        bgeu    t2, t3, shift1      # check which exponent is larger
shift0:
        sub     t4, t3, t2          # calc. diff. of exps.
        srl     t0, t0, t4          # shift a0 mant. by above difference
        add     t2, t2, t4          # adjust a0 exponent
        j       check_sign
shift1:
        sub     t4, t2, t3          # calc. diff. of exps.
        srl     t1, t1, t4          # shift a0 mant. by above difference
        add     t3, t3, t4          # adjust a1 exponent (for regularity)
check_sign:
        srl     t4, a0, 31          # t4 = a0 sign
        srl     t5, a1, 31          # t5 = a1 sign
        beq     t4, t5, add_mant    # check if signs are equal
        sub     t5, t0, t1          # t5 = a0 mant - a1 mant
        beq     t4, zero, a1neg     # check if a0 mant is positive
        sub     t5, t1, t0          # t5 = a1 mant - a0 mant
a1neg:
        beq     t5, zero, norm      # check if the sub. of mants. is 0
        lui     t4, 0x800           # t5 = 0x00800000 (prep. 1 bit mask)
        bge     t5, zero, norm2     # check if sub. of mants. is > 0 (== 0 discarded alr.)
        sub     t5, zero, t5        # two's comp negative sub. of mantissas
        addi    s0, zero, 1         # signal that the final sign must be 1 (negative)
                                    # TODO do not use s0 before pushing it
norm2:
        and     t6, t5, t4          # get bit 24
        bne     t6, zero, done      # check if bit 24 is not zero
        sll     t5, t5, 1           # adjust sub. of mants. by left-shifting 1
        addi    t2, t2, -1          # adjust exp. to be coherent with the above
        j       norm2               # repeat
add_mant:
        add     t5, t0, t1
norm:
        lui     t4, 0x1000          # t4 = 0x01000000 (overflow bit mask)
        and     t4, t5, t4          # t4 = bit 24
        beq     t4, zero, done      # no overflow, no need to right shift
        srli    t5, t5, 1           # shift mantissa right by one
        addi    t2, t2, 1           # adjust the exponent after shift
done:
        lui     t4, 0x7ff + 1
        addi    t4, t4, -1          # mantissa mask (0x7fffff)
        and     t5, t5, t4          # t5 = masked result mantissa
        slli    t2, t2, 23          # align the exponent in proper place
        lui     t4, 0x7f800         # t4 = exponent mask
        and     t2, t2, t4          # t2 = result exponent
        or      a0, t5, t2          # result stored in a0
        beq     s0, zero, return    # check if the sign must be set as negative
        lui     t6, 0x80000         # 31 bit mask
        or      a0, a0, t6          # set 31 bit as 1 (negative)
return:
        jr      ra                  # return


# a0 pointer to list of words
# a1 list size in bytes
bubble_float:
        add     t0, a0, zero        # t0 = a0 pointer
        add     t1, t0, a1          # t1 = a0 + size = final addr
        addi    t1, t1, -4          # subtract 1 word to t1
float_loop:
        lw      t3, 0(t0)           # load curr. list elem.
        lw      t4, 4(t0)           # load next list elem.
        blt     t3, t4, dont_swap   # check if *a0 < *(a0 + 4)
        sw      t3, 4(t0)           # swap *t0 and *(t0 + 4)
        sw      t4, 0(t0)
dont_swap:
        add     t0, t0, 4           # increase iterator
        blt     t0, t1, float_loop  # check if the list is over
        jr      ra                  # return


# a0 pointer to list of words
# a1 list size in bytes
bubble_sort:
        add     sp, sp, -(3*4)
        sw      ra, 0(sp)
        sw      s0, 4(sp)
        sw      s1, 8(sp)
        add     s0, a0, zero        # t0 = a0 pointer
        add     s1, a0, a1          # t1 = a0 + size = final addr
bs_loop:
        jal     bubble_float
        add     s0, s0, 4
        blt     s0, s1, bs_loop
        lw      ra, 0(sp)
        lw      s0, 4(sp)
        lw      s1, 8(sp)
        add     sp, sp, (3*4)
        jr      ra



# a0 pointer to src array
# a1 size of src array
# a2 pointer to dst array
find_largest_sum:
        add     t0, zero, a0        # t0 = a0 it.
        add     t1, zero, a1        # t1 = a1
        sll     t1, t1, 2           # t1 = 4*a1 (words to bytes)
        add     t1, t1, a0          # t1 = end of a0 array
        add     t2, zero, a2        # t2 = a2 it.
        lui     t3, 0xf0000         # t3 = min. neg. num; will hold max. val. found
fls_loop:
        lw      t4, (t0)            # t4 = *a0_it
        blt     t4, t3, fls_nm      # check if t4 is less than t3
        add     t3, zero, t4        # t3 = latest max. num. found
fls_nm:
        blt     t4, zero, fls_neg   # check if t4 is neg.
        sw      t4, (t2)            # *a2_it = t4
        addi    t2, t2, 4           # a2_it = a2_it + 4
fls_neg:
        addi    t0, t0, 4           # a0 it = a0 it + 4
        blt     t0, t1, fls_loop    # loop until end is reached
        bne     t2, a2, fls_done    # check if a2 array contains any elem.
        sw      t3, (t2)            # store max. val. found in a2[0]
        addi    t2, t2, 4           # a2_it += 4;
fls_done:
        sub     a0, t2, a2          # a0 = num. bytes added to a2 array
        srl     a0, a0, 2           # a0 = num. words (elems) added to a2 array
        jr      ra


# a0 pointer to array
# a1 arr. num. elems.
rev_arr:
        add     t0, zero, a0        # t0 = a0 it.
        add     t1, zero, a1        # t1 = a1
        addi    t1, t1, -1          # t1 = t1 - 1
        sll     t1, t1, 2           # t1 = 4*a1 (words to bytes)
        add     t1, t1, a0          # t1 = end of a0 array
ra_loop:
        lw      t2, (t0)            # t2 = *t0
        lw      t3, (t1)            # t3 = *t1
        sw      t2, (t1)            # *t1 = t2
        sw      t3, (t0)            # *t0 = t3
        addi    t0, t0, 4           # t0++
        addi    t1, t1, -4          # t1--
        blt     t0, t1, ra_loop     # check if t0 < t1
        jr      ra


# a0 pointer to array
# a1 arr. num. elems.
rev_arr_b:
        add     t0, zero, a0        # t0 = a0 it.
        add     t1, a0, a1          # t1 = a0 + a1
        addi    t1, t1, -1          # t1 -> last elem. of array
rab_loop:
        lb      t2, (t0)            # t2 = *t0
        lb      t3, (t1)            # t3 = *t1
        sb      t2, (t1)            # *t1 = t2
        sb      t3, (t0)            # *t0 = t3
        addi    t0, t0, 1           # t0++
        addi    t1, t1, -1          # t1--
        blt     t0, t1, rab_loop    # check if t0 < t1
        jr      ra


# a0 pointer to array
rev_words:
        add     s0, zero, a0        # s0 = a0 it.
        add     s1, zero, 32        # s1 = ord(' ')
        add     sp, sp, -(2*4)      # allocate 2 words
        sw      a0, 0(sp)           # push a0
        sw      ra, 4(sp)           # push a0
        add     a0, zero, s0        # save s0
rw_loop:
        lb      s3, (s0)            # read byte
        beq     s3, zero, rw_last   # check if this byte is '\0'
        bne     s3, s1, rw_next     # check if byte is ' '
rw_last:
        sub     a1, s0, a0          # a1 = s0 - a0
        jal     rev_arr_b
        add     a0, s0, 1           # update base ptr. (a0)
rw_next:
        addi    s0, s0, 1
        bne     s3, zero, rw_loop
        lw      a0, 0(sp)
        lw      ra, 4(sp)
        addi    sp, sp, (2*4)
        jr      ra


# a0: num
rev_reg:
        addi    t0, zero, 1
        addi    t1, zero, 31
        addi    t3, zero, 0
rr_loop:
        and     t2, a0, t0
        sll     t2, t2, t1
        or      t3, t3, t2
        addi    t1, t1, -1
        srl     a0, a0, 1
        bge     t1, zero, rr_loop
        add     a0, zero, t3
        jr      ra


# a0 pointer to array
# a1 arr. num. elems.
palyn:
        add     t0, zero, a0        # t0 = a0 it.
        add     t1, a0, a1          # t1 = a0 + a1
        addi    t1, t1, -1          # t1 -> last elem. of array
pal_loop:
        lb      t2, (t0)            # t2 = *t0
        lb      t3, (t1)            # t3 = *t1
        bne     t2, t3, p_no
        addi    t0, t0, 1           # t0++
        addi    t1, t1, -1          # t1--
        blt     t0, t1, pal_loop    # check if t0 < t1
        addi    a0, zero, 1
        j       pal_done
p_no:
        add     a0, zero, zero
pal_done:
        jr      ra



# .macro  push_ts
#         addi    sp, sp, -(8*4)
#         sw      t0, 0(sp)
#         sw      t1, 4(sp)
#         sw      t2, 8(sp)
#         sw      t3, 12(sp)
#         sw      t4, 16(sp)
#         sw      t5, 20(sp)
#         sw      t6, 24(sp)
#         sw      t7, 28(sp)

# .macro  pop_ts
#         lw      t0, 0(sp)
#         lw      t1, 4(sp)
#         lw      t2, 8(sp)
#         lw      t3, 12(sp)
#         lw      t4, 16(sp)
#         lw      t5, 20(sp)
#         lw      t6, 24(sp)
#         lw      t7, 28(sp)
#         addi    sp, sp, (8*4)

# .macro  push_as
#         addi    sp, sp, -(8*4)
#         sw      a0, 0(sp)
#         sw      a1, 4(sp)
#         sw      a2, 8(sp)
#         sw      a3, 12(sp)
#         sw      a4, 16(sp)
#         sw      a5, 20(sp)
#         sw      a6, 24(sp)
#         sw      a7, 28(sp)

# .macro  pop_as
#         lw      a0, 0(sp)
#         lw      a1, 4(sp)
#         lw      a2, 8(sp)
#         lw      a3, 12(sp)
#         lw      a4, 16(sp)
#         lw      a5, 20(sp)
#         lw      a6, 24(sp)
#         lw      a7, 28(sp)
#         addi    sp, sp, (8*4)


.section .rodata
msg:
    .string "Hello.\n"


.section .data
array10:
    .word 0xabcdef12
    .word 0x12345678
    .word 0xc001c0de
    .word 0xdeadbeef
    .word 0xdeadc0de
    .word 0x12ab34cd
    .word 0xabcdef12
    .word 0x12345678
    .word 0xc001c0de
    .word 0xdeadbeef

array11:
    .word 20
    .word 3
    .word 1
    .word 2
    .word 25
    .word 5
    .word 4
    .word 6
    .word 5
    .word 30

array12:
    .word 20
    .word -3
    .word 0
    .word -1
    .word 2

array13:
    .word -5
    .word -4
    .word -6
    .word -5
    .word -30

array14:
    .word -5
    .word -4
    .word -6
    .word 0
    .word -30

array15:
    .word 0
    .word 0
    .word 0
    .word 0
    .word 0

array16:
    .word 20
    .word -3
    .word 0
    .word -1
    .word 2
    .word 6

array20:
    .byte 20
    .byte -3
    .byte 0
    .byte -1
    .byte 2
    .byte 6

array21:
    .byte 20
    .byte -3
    .byte 0
    .byte -1
    .byte 2

sentence:
    .string "Hello world one two three\0"

palyn1:
    .string "abcxycba"

palyn2:
    .string "abcxxcba"

palyn3:
    .string "abxba"

palyn4:
    .string "abxca"

# Note (1)
# Load 0x7fffff (23 1's) to t0.
# This needs both lui and addi, but bit 12 will be 1 in addi,
# which can't be done because imm is a signed int. therefore
# a possitive number cannot have its 12 bit as 1.
# Add imm - 3096 (in this case -1) and add 1 to the lui immediate
# to compensate for this.
