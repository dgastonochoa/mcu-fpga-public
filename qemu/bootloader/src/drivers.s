.include "bootloader.inc"

.align 4

.section .text

# Read peripheral data reg.
#
# in:   a0 = periph. base addr.
# out:  a1 = value read
.globl rd_periph
rd_periph:
    lw      a1, 0(a0)
    jr      ra


# Write peripheral ctrl reg.
#
# in:   a0 = base addr.
# out:  a1 = cfg. reg. val.
.globl rd_per_ctrl
rd_per_ctrl:
    lw      a1, 4(a0)
    jr      ra


# Write peripheral data reg.
#
# in:  a0 = base addr.
# in:  a1 = value to write
.globl wr_periph
wr_periph:
    sw      a1, 0(a0)
    jr      ra


# Write peripheral ctrl reg.
#
# in:   a0 = base addr.
# in:   a1 = cfg. reg. val.
.globl wr_per_ctrl
wr_per_ctrl:
    sw      a1, 4(a0)
    jr      ra
