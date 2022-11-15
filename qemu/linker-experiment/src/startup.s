.align 4
.section .text.init

.globl _start
_start:
        la      t0, _etext          # Load starting address of .srodata at FLASH (LMA)
        la      t1, _srodata        # Load starting address of .srodata at RAM (VMA)
        la      t2, _esrodata       # Load ending address of .srodata at RAM (VMA)

loop:                               # Copy memory from FLASH to RAM
        lw      t3, 0(t0)           # t3 = *_etext
        sw      t3, 0(t1)           # *_srodata = *_etext
        addi    t0, t0, 4           # Increase pointer: _etext++;
        addi    t1, t1, 4           # Increase pointer: _srodata++;
        bne     t1, t2, loop        # If _srodata != _esrodata, there is still data
                                    # to copy

        la      t0, _tss            # Load starting address of the bss section
        la      t1, _etss           # Load ending address of the bss section
bss_loop:                           # Init. bss section at RAM to 0
        sw      x0, 0(t0)           # *_tss = 0
        addi    t0, t0, 4           # _tss++
        bne     t0, t1, bss_loop    # if _tss != _etss, there is still data to
                                    # initialize to 0, loop again

        la      sp, _stack_top
        jal     x0, main
