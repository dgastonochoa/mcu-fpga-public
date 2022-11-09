This is the expected results for the all_instr test program. Depending on if this program was synthetized along with
the FPGA code, or if it was updated and run by means of the bootloader, its PC will change (in the first case the program
is at address 0x00, in the second it is at the FW_IMG region, below the bootloader). This introduces a small change in the
expected results as one of the tests test the `jal` instruction and, in particular, the value it stores in a register, which
is PC + 4.

For now, use one result or the other by using symbolic links.
