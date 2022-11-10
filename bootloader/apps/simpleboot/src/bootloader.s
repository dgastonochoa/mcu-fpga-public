.include "bootloader.inc"

.align 4

.section .text

# TODO comments
.globl main
main:
    call    bld_reset
bld_loop:
    call    bld_next_state
    call    bld_exec_state
    jal     x0, bld_loop


# Write sub-machine next state
#
# glob: s2 Current machine state
# glob: s3 Last value read
# glob: s4 Memory pointer
# glob: s5 Write final state (for debug purposes)
# glob: s6 Read final state (for debug purposes)
# glob: a7 Jump final state (for debug purposes)
#
# ret:  a0 Error code
.globl bld_wr_next_state
bld_wr_next_state:
    push    ra

    li      a0, GPIO_BASE           # load WFRE func. arg 0
    addi    a1, x0, 1               # load WFRE func. arg 1

    addi    t0, x0, ST_W_ST         # This block checks the current state and
                                    # goes to the appropriate handler
    beq     s2, t0, wns_st
    addi    t0, x0, ST_W_RC
    beq     s2, t0, wns_rc
    addi    t0, x0, ST_W_RE
    beq     s2, t0, wns_re
    addi    t0, x0, ST_W_RN
    beq     s2, t0, wns_rn
    beq     s2, s5, wns_end

wns_st:                             # write start
    call    WFRE                    # wait for GPIO
    addi    s2, x0, ST_W_RC         # next state = write read char
    jal     wns_ok                  # return ok

wns_rc:
    addi    t0, x0, ESC_C           # write read char
    addi    s2, x0, ST_W_RN         # s2 = state normal char read
    addi    t1, x0, ESC_C           # load escape char
    bne     s3, t1, wns_ok          # if the read char != escape, return ok
    call    WFRE                    # else wait for GPIO (another read req.)
    addi    s2, x0, ST_W_RE         # next state = esc. char read
    jal     wns_ok                  # return ok

wns_re:
    addi    t0, x0, ESC_C           # write escape char read
    addi    s2, x0, ST_W_RN         # if next char is escape again, it is
                                    # considered a normal char, so assume
                                    # it is escape and set next state =
                                    # = normal char read
    addi    t1, x0, ESC_C           # load escape char
    beq     s3, t1, wns_ok          # if last read char is escape as assumed,
                                    # return ok
    add     s2, x0, s5              # if last read char is not escape, it
                                    # is a command. Consider any command as
                                    # close for now, so next state = final
                                    # state. Final state will be end or idle
                                    # depending on if test or production.
    jal     wns_ok                  # return ok

wns_rn:
    call    WFRE                    # write normal char read
    addi    s2, x0, ST_W_RC         # next state = read char again
    jal     wns_ok                  # return ok

wns_end:                            # if curr. state = end, do nothing
wns_ok:
    addi    a0, x0, 0               # ret. code = 0
    pop     ra                      # restore ra
    jr      ra                      # return


# Write sub-machine execute state
#
# glob: s2 Current machine state
# glob: s3 Last value read
# glob: s4 Memory pointer
# glob: s5 Write final state (for debug purposes)
# glob: s6 Read final state (for debug purposes)
# glob: a7 Jump final state (for debug purposes)
#
# ret:  a0 Error code
.globl bld_wr_exec_state
bld_wr_exec_state:
    push    ra                      # save ra

    addi    t0, x0, ST_W_ST         # This block checks the current state and
                                    # goes to the appropriate handler
    beq     s2, t0, wes_st
    addi    t0, x0, ST_W_RC
    beq     s2, t0, wes_rc
    addi    t0, x0, ST_W_RE
    beq     s2, t0, wes_re
    addi    t0, x0, ST_W_RN
    beq     s2, t0, wes_rn
    beq     s2, s5, wes_end

wes_st:                             # write start
    addi    s3, x0, 0               # last val. read = 0
    jal     x0, wes_ok              # return ok

wes_rc:                             # write read char.
    li      a0, SSI_BASE            # a0 = serial iface. base
    call    RB                      # read byte from SSI
    add     a0, x0, a2              # a0 = ret. code
    add     s3, x0, a1              # last_val_read = byte read above
    jal     x0, wes_ok              # return ok

wes_re:                             # write escape char read
    li      a0, SSI_BASE            # load SSI base
    call    RB                      # read next char
    add     a0, x0, a2              # a0 = ret code
    add     s3, x0, a1              # last_val_read = byte read above
    jal     x0, wes_ok              # return ok

wes_rn:                             # write normal char read
    sb      s3, 0(s4)               # write val. in memory
    addi    s4, s4, 1               # mem. addr += 1
    jal     x0, wes_ok              # return ok

wes_end:
wes_ok:
    addi    a0, x0, 0               # a0 = success
    pop     ra                      # restore ra
    jr      ra                      # return


# Read sub-machine next state
#
# glob: s2 Current machine state
# glob: s3 Last value read
# glob: s4 Memory pointer
# glob: s5 Write final state (for debug purposes)
# glob: s6 Read final state (for debug purposes)
# glob: a7 Jump final state (for debug purposes)
#
# ret:  a0 Error code
.globl bld_rd_next_state
bld_rd_next_state:
    push    ra

    li      a0, GPIO_BASE           # load WFRE func. arg 0
    addi    a1, x0, 1               # load WFRE func. arg 1

    addi    t0, x0, ST_R_ST         # This block checks the current state and
                                    # goes to the appropriate handler
    beq     s2, t0, rns_st
    addi    t0, x0, ST_R_WRC
    beq     s2, t0, rns_wrc
    addi    t0, x0, ST_END
    beq     s2, t0, rns_end

rns_st:
    call    WFRE                    # wait for gpio
    addi    s2, x0, ST_R_WRC        # curr. state = ST_R_WRC
    jal     x0, rns_ok              # return ok

rns_wrc:
    add     s2, x0, s6              # curr_state = read final state
    addi    t0, x0, CMD_C           # load CMD_C char
    beq     s3, t0, rns_ok          # if last val. read == CMD_C, finish
    call    WFRE                    # else wait for gpio
    addi    s2, x0, ST_R_WRC        # curr. state = ST_R_WRC
    jal     x0, rns_ok

rns_end:                            # if curr. state == end, do nothing
rns_ok:
    addi    a0, x0, 0               # err code = 0
    pop     ra                      # restora ra
    jr      ra                      # return


# Read sub-machine execute state
#
# glob: s2 Current machine state
# glob: s3 Last value read
# glob: s4 Memory pointer
# glob: s5 Write final state (for debug purposes)
# glob: s6 Read final state (for debug purposes)
# glob: a7 Jump final state (for debug purposes)
#
# ret:  a0 Error code
.globl bld_rd_exec_state
bld_rd_exec_state:
    push    ra

    li      a0, GPIO_BASE           # load WFRE func. arg 0
    addi    a1, x0, 1               # load WFRE func. arg 1

    addi    t0, x0, ST_R_ST         # check curr. state
    beq     s2, t0, res_st          # check curr. state
    addi    t0, x0, ST_R_WRC        # check curr. state
    beq     s2, t0, res_wrc         # check curr. state
    addi    t0, x0, ST_END          # check curr. state
    beq     s2, t0, res_end         # check curr. state

res_st:
    addi    s3, x0, 0               # reset last val. read
    jal     x0, res_ok              # return ok

res_wrc:
    li      a0, SSI_BASE            # load SSI base
    add     a1, x0, s4              # a1 = mem. pointer
    call    ex_st_r_wrc             # execute ST_R_WRC sate
    add     s3, x0, a2              # s3 = last value read
    add     s4, x0, a1              # s4 = new mem. ptr.
    jal     x0, res_ok              # return ok

res_end:
res_ok:
    addi    a0, x0, 0               # set error code = 0
    pop     ra                      # restore ra
    jr      ra                      # return


# Execute state: ST_R_WRC. It will send, over SSI,
# the byte located at *a1 and read the byte received
# as a result of this op.
#
# in:    a0 SSI base addr.
# out:   a2 Value read from SSI
# inout: a1 Memory pointer
#
# ret: a0 error code
ex_st_r_wrc:
    push    ra                  # save ra
    push    s2
    push    s3
    add     s2, x0, a0          # s2 = SSI base addr.
    add     s3, x0, a1          # s3 = mem. ptr.
    lb      a1, 0(a1)           # read val. from mem.
    call    SB                  # send byte just read
    add     a0, x0, s2          # arg0 = SSI addr.
    call    RSB                 # read byte sent as a result of
                                # the previous send op.
    add     a2, x0, a1          # a2 = value read
    add     a1, s3, 1           # incr. mem. pointer
    pop     s3
    pop     s2
    pop     ra                  # restore ra
    jr      ra                  # return


# General-machine next state
#
# glob: s2 Current machine state
# glob: s3 Last value read
# glob: s4 Memory pointer
# glob: s5 Write final state (for debug purposes)
# glob: s6 Read final state (for debug purposes)
# glob: a7 Jump final state (for debug purposes)
#
# ret:  a0 Error code
.globl bld_next_state
bld_next_state:
    push    ra

    addi    t0, x0, ST_END              # if curr. state == ST_END
    beq     s2, t0, ns_st_end           # goto ns_st_end handler

    addi    t0, x0, ST_J                # if curr. state == ST_J
    beq     s2, t0, ns_j                # go to ns_j handler

    addi    t0, x0, ST_IDLE
    beq     s2, t0, ns_idle             # if curr. sate = ns_idle,
                                        # goto ns_idle handler

    addi    t0, x0, ST_CMD              # if curr. state == ST_CMD &&
    addi    t1, x0, CMD_J               # last val. read == CMD_J goto
    bne     s2, t0, ns_not_st_j_st      # jump handler
    beq     s3, t1, ns_st_j_st

ns_not_st_j_st:
    addi    t0, x0, ST_CMD
    addi    t1, x0, CMD_W
    bne     s2, t0, ns_not_st_w_st
    beq     s3, t1, ns_st_w_st          # if curr. state == ST_CMD &&
                                        # last val. read == CMD_W goto
                                        # ns_st_w_st
ns_not_st_w_st:
    addi    t0, x0, ST_CMD              # same as above but for command
                                        # CMD_R and ns_st_r_st handler
    addi    t1, x0, CMD_R
    bne     s2, t0, ns_not_st_r_st
    beq     s3, t1, ns_st_r_st

ns_not_st_r_st:
    addi    t0, x0, ST_CMD              # same as above but for command
                                        # CMD_C and ns_st_r_st handler
    addi    t1, x0, CMD_C
    bne     s2, t0, ns_not_cmd_c
    beq     s3, t1, ns_cmd_c

ns_not_cmd_c:
    add     a0, x0, s2
    addi    a1, x0, ST_W_ST
    addi    a2, x0, ST_W_RN
    call    within                      # check if
                                        # `ST_W_ST <= curr.-state <= ST_W_RN`,
                                        # that is, the the curr. state
                                        # belongs to the write sub-machine
                                        # domain.
    bne     a0, x0, ns_wns              # if the above is true, goto ns_wns
                                        # handler

    add     a0, x0, s2
    addi    a1, x0, ST_R_ST
    addi    a2, x0, ST_R_WRC
    call    within                      # check if
                                        # `ST_R_ST <= curr.-state <= ST_R_RN`,
                                        # that is, the the curr. state
                                        # belongs to the read sub-machine
                                        # domain.
    bne     a0, x0, ns_rns              # if the above is true, goto ns_rns
                                        # handler

    addi    s2, x0, ST_IDLE             # If none of the above checks succeed,
                                        # the recv. char. is unknow. Go back
                                        # to ST_IDLE.
    jal     x0, ns_ok                   # return ok

ns_idle:
    li      a0, GPIO_BASE
    addi    a1, x0, 1
    call    WFRE                    # wait for gpio
    addi    s2, x0, ST_CMD          # curr. state = ST_CMD
    jal     x0, ns_ok               # return ok

ns_j:
    add     s2, x0, a7              # curr. state = jump final state
    jal     x0, ns_ok               # return ok

ns_st_j_st:
    addi    s2, x0, ST_J
    jal     x0, ns_ok

ns_st_w_st:
    addi    s2, x0, ST_W_ST         # curr. state = ST_W_ST
    jal     x0, ns_ok               # return ok

ns_st_r_st:
    addi    s2, x0, ST_R_ST         # curr. state = ST_R_ST
    jal     x0, ns_ok               # return ok

ns_cmd_c:
    addi    s2, x0, ST_IDLE         # curr. state = ST_IDLE
    jal     x0, ns_ok               # return ok

ns_wns:
    call    bld_wr_next_state       # let the write sub-machine
                                    # decide the new state
    jal     x0, ns_ok               # return ok

ns_rns:
    call    bld_rd_next_state       # let the read sub-machine
                                    # decide the new state
    jal     x0, ns_ok               # return ok

ns_st_end:
ns_ok:
    addi    a0, x0, 0               # err code = 0
    pop     ra                      # restore ra
    jr      ra                      # return


# Determine if b accomplishes a <= b <= c
#
# in:   a0 b
# in:   a1 a
# in:   a2 c
#
# ret:  a0 1 if the condition above is
#          accomplised, 0 otherwise
within:
    addi    t0, x0, 0               # set ret. val to 0 by default
    beq     a0, a2, within_yes      # These 3 instr. check that
                                    # (b >= a and b <= c)
    blt     a0, a1, within_no       #
    bge     a0, a2, within_no       #
within_yes:
    addi    t0, x0, 1               # if the cond. is accomplished,
                                    # set ret. val to 1
within_no:
    add     a0, x0, t0              # load ret. val
    jr      ra                      # return


# General-machine execute state
#
# glob: s2 Current machine state
# glob: s3 Last value read
# glob: s4 Memory pointer
# glob: s5 Write final state (for debug purposes)
# glob: s6 Read final state (for debug purposes)
# glob: a7 Jump final state (for debug purposes)
#
# ret:  a0 Error code
.globl bld_exec_state
bld_exec_state:
    push    ra

    addi    t0, x0, ST_IDLE     # check if the current state is ST_IDLE
    beq     s2, t0, es_idle     # or ST_CMD or ST_END and jump to the
                                # required handler
    addi    t0, x0, ST_CMD
    beq     s2, t0, es_cmd
    addi    t0, x0, ST_J
    beq     s2, t0, es_j
    addi    t0, x0, ST_END
    beq     s2, t0, es_end

    add     a0, x0, s2
    addi    a1, x0, ST_W_ST
    addi    a2, x0, ST_W_RN
    call    within              # check if
                                # `ST_W_ST <= curr.-state <= ST_W_RN`,
                                # that is, the the curr. state
                                # belongs to the write sub-machine
                                # domain.
    bne     a0, x0, es_wes      # if the above is true, goto es_wes
                                # handler

    add     a0, x0, s2
    addi    a1, x0, ST_R_ST
    addi    a2, x0, ST_R_WRC
    call    within              # check if
                                # `ST_R_ST <= curr.-state <= ST_R_RN`,
                                # that is, the the curr. state
                                # belongs to the read sub-machine
                                # domain.
    bne     a0, x0, es_res      # if the above is true, goto es_res
                                # handler

es_idle:
    addi    s3, x0, 0           # last val. read = 0
    la      s4, _fwimg          # memory ptr. = fw img. start addr.
    jal     x0, es_ok

es_cmd:
    li      a0, SSI_BASE
    call    RB                  # read byte
    add     s3, x0, a1          # last val. read = a1 (read byte)
    jal     x0, es_ok           # return ok

es_j:
    jalr    ra, s4, 0           # jump to image area
    jal     x0, es_ok           # return ok

es_wes:
    call    bld_wr_exec_state   # let the write sub-machine deal
                                # with this
    jal     x0, es_ok           # return ok

es_res:
    call    bld_rd_exec_state   # let the read sub-machine deal
                                # with this
    jal     x0, es_ok           # return ok

es_end:
es_ok:
    addi    a0, x0, 0           # err code = 0
    pop     ra                  # restore ra
    jr      ra                  # return


.globl bld_reset
bld_reset:
    addi    s2, x0, ST_IDLE     # curr. state = ST_IDLE
    addi    s3, x0, 0           # last read val. = 0
    la      s4, _fwimg          # mem. ptr. -> _fwimg area
    addi    s5, x0, ST_IDLE     # write final st. = ST_IDLE
    addi    s6, x0, ST_IDLE     # read final st. = ST_IDLE
    addi    a7, x0, ST_IDLE     # jump final st. = ST_IDLE
    jr      ra


# Wait for GPIO rising edge
# a0 = GPIO base addr.
WFRE:
    push    ra
    push    s2
    add     s2, x0, a0      # s2 = base addr.
    addi    a1, zero, 0     # set level as 'low'
    call    WFG             # wait for GPIO
    add     a0, x0, s2      # a0 = base addr. again
    addi    a1, zero, 1     # set level as 'high'
    jal     ra, WFG         # wait for GPIO
    pop     s2
    pop     ra
    jr      ra              # return


# Wait for GPIO
# a0 = GPIO base addr.
# a1 = level
WFG:
    push    ra
    push    s2
    push    s3
    add     s2, x0, a0          # s2 = base addr
    add     s3, x0, a1          # s3 = level
wfg_loop:
    add     a0, x0, s2          # set arg0
    add     a1, x0, s3          # set arg1
    call    rd_periph           # read gpios
    andi    a1, a1, 1           # mask to read only GPIO 0
    bne     a1, s3, wfg_loop    # if gpio != level, keep polling
    pop     s3                  # restore all and return
    pop     s2
    pop     ra
    jr      ra



# Send byte
# a0 = SPI base addr.
# a1 = [7:0] = byte
SB:
    push    ra
    push    s2
    add     s2, x0, a0      # s2 = base addr.
    call    wr_periph       # write data to be sent
    add     a0, x0, s2      # arg0 = base addr.
    addi    a1, x0, 0x04    # arg1 = send flag
    call    wr_per_ctrl     # trigger send
L111:
    add     a0, x0, s2      # arg0 = base addr.
    call    rd_per_ctrl     # read status
    andi    a1, a1, 0x2     # get busy flag
    bne     a1, x0, L111    # if busy != 0 keep polling
    pop     s2
    pop     ra
    jr      ra              # return


# Read byte
# a0 = SPI base addr
# a1 = value read
# a0 = error code
RB:
    push    ra
    push    s2
    add     s2, x0, a0      # s2 = base addr.
    addi    a1, x0, 0       # arg1 = dummy byte
    call    SB              # send
    add     a0, x0, s2      # arg0 = base addr
    call    rd_per_ctrl     # read SPI status
    andi    a1, a1, 1       # mask SPI rdy bit
    beq     a1, x0, RB_ERR  # if rdy != 1, error
    add     a0, x0, s2      # arg0 = base addr
    call    rd_periph       # else read from SPI
    addi    a0, zero, 0     # set error as 0
    jal     x0, RB_EXIT     # finished
RB_ERR:
    addi    a0, zero, 1     # set error as 1
RB_EXIT:
    pop     s2
    pop     ra
    jr      ra              # return


# Read SSI recv. buffer
# a0 = SSI base addr
# a1 = value read
RSB:
    push    ra
    call    rd_periph
    pop     ra
    jr      ra
