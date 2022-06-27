# Test program for the FPGA RISC-V CPU. This requires commenting/
# uncommenting sections depending on it's going to be executed in
# qemu or the current version of the FPGA RISC-V proc.


#
# SIFIVE_E initialization (Comment out when generating the
# program for the FPGA test)
#
.align 4
# .equ UART_BASE,         0x10013000

.section .text
.globl _start

_start:
        la      sp, stack_top           # setup stack pointer


        # #
        # # STACK POINTER INITIALIZATION FOR TESTS (Uncomment when
        # # generating the program for the FPGA test)
        # #
        # addi    x2, x0, 0             # setup stack pointer

        #
        # addi, sw, jal
        #
        addi    x5, x0, 37
        addi    x6, x5, 3
        sw      x5, (0*4)(x2)   # sp[0] = 37
        sw      x6, (1*4)(x2)   # sp[1] = 40
        jal     x3, tj
tj:     sw      x3, (2*4)(x2)   # sp[2] = 24

        #
        # lui, or, srli
        #
        lui     x5, 0xabcde
        lui     x6, 0x00f12
        srli    x6, x6, 12
        or      x5, x5, x6
        sw      x5, (3*4)(x2)   # sp[3] = 0xabcdeef12

        #
        # sh, sb, lw, lhu, lbu
        #
        addi    x5, x0, 0
        lbu     x5, 12(x2)      # x5 = sp[3] & 0xff
        sw      x5, (4*4)(x2)   # sp[4] = x5
        addi    x5, x0, 0
        lbu     x5, 13(x2)      # x5 = sp[3] & 0xff00
        sw      x5, (5*4)(x2)   # sp[5] = x5
        addi    x5, x0, 0
        lbu     x5, 14(x2)      # x5 = sp[3] & 0xff0000
        sw      x5, (6*4)(x2)   # sp[6] = x5
        addi    x5, x0, 0
        lbu     x5, 15(x2)      # x5 = sp[3] & 0xff000000
        sw      x5, (7*4)(x2)   # sp[7] = x5
        addi    x5, x0, 0
        lhu     x5, 12(x2)      # x5 = sp[3] & 0xffff
        sw      x5, (8*4)(x2)   # sp[8] = x5
        addi    x5, x0, 0
        lhu     x5, 14(x2)      # x5 = sp[3] & 0xffff0000
        sw      x5, (9*4)(x2)   # sp[9] = x5
        addi    x5, x0, 0
        lw      x5, 12(x2)      # x5 = sp[3]
        sw      x5, (10*4)(x2)  # sp[10] = x5
        sh      x5, (11*4)(x2)  # sp[11] = x5 & 0xffff
        sb      x5, (12*4)(x2)  # sp[12] = x5 & 0xff

        #
        # lh, lb
        #
        addi    x5, x0, 0
        lb      x5, 12(x2)      # x5 = sp[3] & 0xff
        sw      x5, (13*4)(x2)  # sp[13] = x5
        addi    x5, x0, 0
        lb      x5, 13(x2)      # x5 = 0xffffff | ((sp[3] & 0xff00) >> 8)
        sw      x5, (14*4)(x2)  # sp[14] = x5
        addi    x5, x0, 0
        lb      x5, 14(x2)      # x5 = 0xffffff | ((sp[3] & 0xff0000) >> 16)
        sw      x5, (15*4)(x2)  # sp[15] = x5
        addi    x5, x0, 0
        lb      x5, 15(x2)      # x5 = 0xffffff | ((sp[3] & 0xff000000) >> 24)
        sw      x5, (16*4)(x2)  # sp[16] = x5
        addi    x5, x0, 0
        lh      x5, 12(x2)      # x5 = 0xffff | (sp[3] & 0xffff)
        sw      x5, (17*4)(x2)  # sp[17] = x5

        addi    x5, x0, 0
        lui     x5, 0x7ffff     # x5 = 0x7ffff000
        sw      x5, (18*4)(x2)  # sp[18] = x5
        addi    x5, x0, 0
        lh      x5, (18*4 + 2)(x2)  # x5 = sp[20] & 0xffff0000
        # TODO missing storage here

        #
        # slli
        #
        lw      x5, 12(x2)      # x5 = 0xabcdef12
        slli    x6, x5, 8       # x6 = 0xcdef1200
        sw      x6, (19*4)(sp)  # sp[19] = x6
        slli    x6, x5, 9       # x6 = 0x9bde2400
        sw      x6, (20*4)(sp)  # sp[20] = x6
        slli    x6, x5, 0       # x6 = 0xabcdef12
        sw      x6, (21*4)(sp)  # sp[21] = x6
        slli    x6, x5, 31      # x6 = 0x0
        sw      x6, (22*4)(sp)  # sp[22] = x6

        #
        # slti
        #
        addi    x6, x0, 7
        slti    x7, x6, 6
        sw      x7, (23*4)(sp)  # < 6; sp[23] = 0
        slti    x7, x6, 8
        sw      x7, (24*4)(sp)  # < 8; sp[24] = 1
        slti    x7, x6, -3
        sw      x7, (25*4)(sp)  # < -3; sp[25] = 0
        slti    x7, x6, 0
        sw      x7, (26*4)(sp)  # < 0; sp[26] = 0
        slti    x7, x6, 7
        sw      x7, (27*4)(sp)  # < 7; sp[27] = 0

        addi    x6, x0, 0
        slti    x7, x6, 6
        sw      x7, (28*4)(sp)  # < 6; sp[28] = 1
        slti    x7, x6, -3
        sw      x7, (29*4)(sp)  # < -3; sp[29] = 0
        slti    x7, x6, 0
        sw      x7, (30*4)(sp)  # < 0; sp[30] = 0

        addi    x6, x0, -7
        slti    x7, x6, -8
        sw      x7, (31*4)(sp)  # < -8; sp[31] = 0
        slti    x7, x6, -7
        sw      x7, (32*4)(sp)  # < -7; sp[32] = 0
        slti    x7, x6, -6
        sw      x7, (33*4)(sp)  # < -6; sp[33] = 1
        slti    x7, x6, 0
        sw      x7, (34*4)(sp)  # < 0; sp[34] = 1
        slti    x7, x6, 8
        sw      x7, (35*4)(sp)  # < 8; sp[35] = 1

        #
        # sltiu
        #
        addi    x6, x0, 7
        sltiu   x7, x6, 6
        sw      x7, (36*4)(sp)  # < 6; sp[36] = 0
        sltiu   x7, x6, 8
        sw      x7, (37*4)(sp)  # < 8; sp[37] = 1
        sltiu   x7, x6, -3
        sw      x7, (38*4)(sp)  # < -3; sp[38] = 1
        sltiu   x7, x6, 0
        sw      x7, (39*4)(sp)  # < 0; sp[39] = 0
        sltiu   x7, x6, 7
        sw      x7, (40*4)(sp)  # < 7; sp[40] = 0

        addi    x6, x0, 0
        sltiu   x7, x6, 6
        sw      x7, (41*4)(sp)  # < 6; sp[41] = 1
        sltiu   x7, x6, -3
        sw      x7, (42*4)(sp)  # < -3; sp[42] = 1
        sltiu   x7, x6, 0
        sw      x7, (43*4)(sp)  # < 0; sp[43] = 0

        addi    x6, x0, -7
        sltiu   x7, x6, -8
        sw      x7, (44*4)(sp)  # < -8; sp[44] = 0
        sltiu   x7, x6, -7
        sw      x7, (45*4)(sp)  # < -7; sp[45] = 0
        sltiu   x7, x6, -6
        sw      x7, (46*4)(sp)  # < -6; sp[46] = 1
        sltiu   x7, x6, 0
        sw      x7, (47*4)(sp)  # < 0; sp[47] = 0
        sltiu   x7, x6, 8
        sw      x7, (48*4)(sp)  # < 8; sp[48] = 0

        #
        # xori
        #
        addi    x6, x0, 0xaa
        xori    x7, x6, 0x55
        sw      x7, (49*4)(sp)  # sp[49] = 0xff
        xori    x7, x7, 0xff
        sw      x7, (50*4)(sp)  # sp[50] = 0x00

        #
        # srli
        #
        lui     x6, 0xfffff     # x7 =     0xfffff000
        srli    x7, x6, 4
        sw      x7, (51*4)(sp)  # sp[51] = 0x0fffff00
        srli    x7, x6, 8
        sw      x7, (52*4)(sp)  # sp[52] = 0x00fffff0

        #
        # srai
        #
        lui     x6, 0xfffff     # x6     = 0xfffff000
        srai    x7, x6, 4
        sw      x7, (53*4)(sp)  # sp[53] = 0xffffff00
        srai    x7, x6, 8
        sw      x7, (54*4)(sp)  # sp[54] = 0xfffffff0

        #
        # ori
        #
        addi    x6, x0, 0
        ori     x7, x6, 0xf0
        sw      x7, (55*4)(sp)  # sp[55] = 0xf0
        ori     x7, x6, 0xff
        sw      x7, (56*4)(sp)  # sp[56] = 0xff
        ori     x7, x7, 0x0
        sw      x7, (57*4)(sp)  # sp[57] = 0xff

        #
        # andi
        #
        addi    x6, x0, 0x7ff
        andi    x7, x6, 0xff
        sw      x7, (58*4)(sp)  # sp[58] = 0xff
        andi    x7, x6, 0x0f
        sw      x7, (59*4)(sp)  # sp[59] = 0x0f
        andi    x7, x6, 0x0
        sw      x7, (60*4)(sp)  # sp[60] = 0x00

        #
        # auipc, sub
        #
        auipc   x6, 0x01        # x6 = PC_1 + 0x00001000
        auipc   x7, 0x01        # x7 = (PC_1 + 4) + 0x00001000
        sub     x7, x7, x6      # x7 = 4
        sw      x7, (61*4)(sp)  # sp[61] = 0x04

        #
        # sll
        #
        lw      x5, 12(x2)      # x5 = 0xabcdef12
        addi    x8, x0, 8
        sll     x6, x5, x8      # x6 = 0xcdef1200
        sw      x6, (62*4)(sp)  # sp[62] = x6
        addi    x8, x0, 9
        sll     x6, x5, x8      # x6 = 0x9bde2400
        sw      x6, (63*4)(sp)  # sp[63] = x6
        addi    x8, x0, 0
        sll     x6, x5, x8      # x6 = 0xabcdef12
        sw      x6, (64*4)(sp)  # sp[64] = x6
        addi    x8, x0, 31
        sll     x6, x5, x8      # x6 = 0x0
        sw      x6, (65*4)(sp)  # sp[65] = x6

        #
        # slt
        #
        addi    x6, x0, 7
        addi    x8, x0, 6
        slt     x7, x6, x8
        sw      x7, (65*4)(sp)  # < 6; sp[65] = 0
        addi    x8, x0, 8
        slt     x7, x6, x8
        sw      x7, (66*4)(sp)  # < 8; sp[66] = 1
        addi    x8, x0, -3
        slt     x7, x6, x8
        sw      x7, (67*4)(sp)  # < -3; sp[67] = 0
        addi    x8, x0, 0
        slt     x7, x6, x8
        sw      x7, (68*4)(sp)  # < 0; sp[68] = 0
        addi    x8, x0, 7
        slt     x7, x6, x8
        sw      x7, (69*4)(sp)  # < 7; sp[69] = 0

        addi    x6, x0, 0
        addi    x8, x0, 6
        slt     x7, x6, x8
        sw      x7, (70*4)(sp)  # < 6; sp[70] = 1
        addi    x8, x0, -3
        slt     x7, x6, x8
        sw      x7, (71*4)(sp)  # < -3; sp[71] = 0
        addi    x8, x0, 0
        slt     x7, x6, x8
        sw      x7, (72*4)(sp)  # < 0; sp[72] = 0

        addi    x6, x0, -7
        addi    x8, x0, -8
        slt     x7, x6, x8
        sw      x7, (73*4)(sp)  # < -8; sp[73] = 0
        addi    x8, x0, -7
        slt     x7, x6, x8
        sw      x7, (74*4)(sp)  # < -7; sp[74] = 0
        addi    x8, x0, -6
        slt     x7, x6, x8
        sw      x7, (75*4)(sp)  # < -6; sp[75] = 1
        addi    x8, x0, 0
        slt     x7, x6, x8
        sw      x7, (76*4)(sp)  # < 0; sp[76] = 1
        addi    x8, x0, 8
        slt     x7, x6, x8
        sw      x7, (77*4)(sp)  # < 8; sp[77] = 1

        #
        # sltu
        #
        addi    x6, x0, 7
        addi    x8, x0, 6
        sltu    x7, x6, x8
        sw      x7, (78*4)(sp)  # < 6; sp[78] = 0
        addi    x8, x0, 8
        sltu    x7, x6, x8
        sw      x7, (79*4)(sp)  # < 8; sp[79] = 1
        addi    x8, x0, -3
        sltu    x7, x6, x8
        sw      x7, (80*4)(sp)  # < -3; sp[80] = 1
        addi    x8, x0, 0
        sltu    x7, x6, x8
        sw      x7, (81*4)(sp)  # < 0; sp[81] = 0
        addi    x8, x0, 7
        sltu    x7, x6, x8
        sw      x7, (82*4)(sp)  # < 7; sp[82] = 0

        addi    x6, x0, 0
        addi    x8, x0, 6
        sltu    x7, x6, x8
        sw      x7, (83*4)(sp)  # < 6; sp[83] = 1
        addi    x8, x0, -3
        sltu    x7, x6, x8
        sw      x7, (84*4)(sp)  # < -3; sp[84] = 1
        addi    x8, x0, 0
        sltu    x7, x6, x8
        sw      x7, (85*4)(sp)  # < 0; sp[85] = 0

        addi    x6, x0, -7
        addi    x8, x0, -8
        sltu    x7, x6, x8
        sw      x7, (86*4)(sp)  # < -8; sp[86] = 0
        addi    x8, x0, -7
        sltu    x7, x6, x8
        sw      x7, (87*4)(sp)  # < -7; sp[87] = 0
        addi    x8, x0, -6
        sltu    x7, x6, x8
        sw      x7, (88*4)(sp)  # < -6; sp[88] = 1
        addi    x8, x0, 0
        sltu    x7, x6, x8
        sw      x7, (89*4)(sp)  # < 0; sp[89] = 0
        addi    x8, x0, 8
        sltu    x7, x6, x8
        sw      x7, (90*4)(sp)  # < 8; sp[90] = 0

        #
        # xor
        #
        addi    x6, x0, 0xaa
        addi    x8, x0, 0x55
        xor     x7, x6, x8
        sw      x7, (91*4)(sp)  # sp[91] = 0xff
        addi    x8, x0, 0xff
        xor     x7, x7, x8
        sw      x7, (92*4)(sp)  # sp[92] = 0x00

        #
        # srl
        #
        lui     x6, 0xfffff     # x7 =     0xfffff000
        addi    x8, x0, 4
        srl     x7, x6, x8
        sw      x7, (93*4)(sp)  # sp[93] = 0x0fffff00
        addi    x8, x0, 8
        srl     x7, x6, x8
        sw      x7, (94*4)(sp)  # sp[94] = 0x00fffff0

        #
        # sra
        #
        lui     x6, 0xfffff     # x6     = 0xfffff000
        addi    x8, x0, 4
        sra     x7, x6, x8
        sw      x7, (95*4)(sp)  # sp[95] = 0xffffff00
        addi    x8, x0, 8
        sra     x7, x6, x8
        sw      x7, (96*4)(sp)  # sp[96] = 0xfffffff0

        #
        # or
        #
        addi    x6, x0, 0
        addi    x8, x0, 0xf0
        or      x7, x6, x8
        sw      x7, (97*4)(sp)  # sp[97] = 0xf0
        addi    x8, x0, 0xff
        or      x7, x6, x8
        sw      x7, (98*4)(sp)  # sp[98] = 0xff
        addi    x8, x0, 0x00
        or      x7, x7, x8
        sw      x7, (99*4)(sp)  # sp[99] = 0xff

        #
        # and
        #
        addi    x6, x0, 0x7ff
        addi    x8, x0, 0xff
        and     x7, x6, x8
        sw      x7, (100*4)(sp) # sp[100] = 0xff
        addi    x8, x0, 0x0f
        and     x7, x6, x8
        sw      x7, (101*4)(sp) # sp[101] = 0x0f
        addi    x8, x0, 0x00
        and     x7, x6, x8
        sw      x7, (102*4)(sp) # sp[102] = 0x00

        #
        # addi
        #
        addi    x6, x0, 20
        addi    x7, x6, 0
        sw      x7, (103*4)(sp) # sp[103] = 20
        addi    x7, x6, 5
        sw      x7, (104*4)(sp) # sp[104] = 25
        addi    x7, x6, -20
        sw      x7, (105*4)(sp) # sp[105] = 0
        addi    x7, x6, -25
        sw      x7, (106*4)(sp) # sp[106] = -5

        #
        # add
        #
        addi    x6, x0, 20
        addi    x8, x0, 0
        add     x7, x6, x8
        sw      x7, (107*4)(sp) # sp[107] = 20
        addi    x8, x0, 5
        add     x7, x6, x8
        sw      x7, (108*4)(sp) # sp[108] = 25
        addi    x8, x0, -20
        add     x7, x6, x8
        sw      x7, (109*4)(sp) # sp[109] = 0
        addi    x8, x0, -25
        add     x7, x6, x8
        sw      x7, (110*4)(sp) # sp[110] = -5

        #
        # sub
        #
        addi    x6, x0, 20
        addi    x8, x0, 0
        sub     x7, x6, x8
        sw      x7, (111*4)(sp) # sp[111] = 20
        addi    x8, x0, 0
        sub     x7, x8, x6
        sw      x7, (112*4)(sp) # sp[112] = -20
        addi    x8, x0, 25
        sub     x7, x6, x8
        sw      x7, (113*4)(sp) # sp[113] = -5
        addi    x8, x0, -25
        sub     x7, x6, x8
        sw      x7, (114*4)(sp) # sp[114] = 45

        #
        # beq
        #
        addi    x6, x0, 1
        addi    x8, x0, 0
        beq     x6, x6, .L1
        sw      x8, (115*4)(sp) # sp[115] = 0
.L1:    sw      x6, (115*4)(sp) # sp[115] = 1
        beq     x8, x6, .FAIL
        sw      x6, (116*4)(sp) # sp[116] = 1

        #
        # bne
        #
        addi    x6, x0, 1
        addi    x8, x0, 0
        bne     x6, x8, .L2
        sw      x8, (117*4)(sp) # sp[117] = 0
.L2:    sw      x6, (117*4)(sp) # sp[117] = 1
        bne     x6, x6, .FAIL
        sw      x6, (118*4)(sp) # sp[116] = 1

        #
        # blt
        #
        addi    x6, x0, 6
        addi    x7, x0, 7
        addi    x8, x0, 8
        blt     x6, x6, .FAIL
        blt     x6, x7, .L3
        jal     x3, .FAIL
.L3:    blt     x8, x7, .FAIL
        sw      x6, (119*4)(sp) # sp[119] = 6
        addi    x9, x0, -9
        addi    x10, x0, -10
        addi    x11, x0, -11
        blt     x9, x9, .FAIL
        blt     x10, x9, .L4
        jal     x3, .FAIL
.L4:    blt     x10, x11, .FAIL
        blt     x10, x6, .L5
        jal     x3, .FAIL
.L5:
        sw      x6, (120*4)(sp) # sp[120] = 6


        #
        # bge
        #
        addi    x6, x0, 6
        addi    x7, x0, 7
        addi    x8, x0, 8
        bge     x6, x6, .L6
        jal     x3, .FAIL
.L6:    bge     x7, x6, .L7
        jal     x3, .FAIL
.L7:    bge     x6, x7, .FAIL
        sw      x6, (121*4)(sp) # sp[121] = 6
        addi    x9, x0, -9
        addi    x10, x0, -10
        addi    x11, x0, -11
        bge     x9, x9, .L8
        jal     x3, .FAIL
.L8:    bge     x9, x10, .L9
        jal     x3, .FAIL
.L9:    bge     x11, x10, .FAIL
        bge     x6, x9, .L10
        jal     x3, .FAIL
.L10:   sw      x6, (122*4)(sp) # sp[122] = 6

        #
        # bltu
        #
        addi    x6, x0, 6
        addi    x7, x0, 7
        addi    x8, x0, 8
        bltu    x6, x6, .FAIL
        bltu    x6, x7, .L11
        jal     x3, .FAIL
.L11:   bltu    x8, x7, .FAIL
        sw      x6, (123*4)(sp) # sp[123] = 6
        addi    x9, x0, -9
        addi    x10, x0, -10
        addi    x11, x0, -11
        bltu    x9, x9, .FAIL
        bltu    x10, x9, .L12
        jal     x3, .FAIL
.L12:   bltu    x10, x11, .FAIL
        bltu    x10, x6, .FAIL
        sw      x6, (124*4)(sp) # sp[124] = 6

        #
        # bgeu
        #
        addi    x6, x0, 6
        addi    x7, x0, 7
        addi    x8, x0, 8
        bgeu    x6, x6, .L13
        jal     x3, .FAIL
.L13:   bgeu    x7, x6, .L14
        jal     x3, .FAIL
.L14:   bgeu    x6, x7, .FAIL
        sw      x6, (125*4)(sp) # sp[125] = 6
        addi    x9, x0, -9
        addi    x10, x0, -10
        addi    x11, x0, -11
        bgeu    x9, x9, .L15
        jal     x3, .FAIL
.L15:   bgeu    x9, x10, .L16
        jal     x3, .FAIL
.L16:   bgeu    x11, x10, .FAIL
        bgeu    x6, x9, .FAIL
        sw      x6, (126*4)(sp) # sp[126] = 6

#
# Finish program (uncomment when generating the FPGA
# program)
#
# .OK:    jal     x3, .OK
# .FAIL:  jal     x3, .FAIL

#
# Finish program (comment out when generating the FPGA
# program)
#
.FAIL:  nop
halt:   wfi                     # enter the infinite loop
