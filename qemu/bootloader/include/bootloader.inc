.equ    SSI_BASE,   0x80000000  # SSI periph base
.equ    LED_BASE,   0x80000040  # LEDs periph base
.equ    GPIO_BASE,  0x80000080  # GPIOs peiph base

.equ    CMD_C,      2           # command close
.equ    CMD_W,      3           # command open-to-write
.equ    CMD_R,      4           # command open-to-read
.equ    CMD_J,      5           # command jump to the fwimg area
.equ    ESC_C,      0xff        # escape byte

.equ    ST_IDLE,    0           # general idle
.equ    ST_CMD,     1           # general cmd. received
.equ    ST_W_ST,    2           # write start
.equ    ST_W_RC,    3           # write read char.
.equ    ST_W_RE,    4           # write escaped char. read
.equ    ST_W_RN,    5           # write normal char. read
.equ    ST_R_ST,    6           # read start
.equ    ST_R_WRC,   7           # read write-read char.
.equ    ST_J,       8           # jump
.equ    ST_END,     255         # general end (debug)


.macro push reg
    addi    sp, sp, -4
    sw      \reg, 0(sp)
.endm

.macro pop reg
    lw      \reg, 0(sp)
    addi    sp, sp, 4
.endm
