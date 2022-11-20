This file contains works to be done in the future.

 - The pipelined CPU time closure reports setup constraint violations
   due to the memory having a second port to read the instruction. This
   happens because the memory reads are async. Maybe a memory generated
   wiyh the Vivado IP generator fixes this.

 - Make the FPGA's mcu to have a slave spi, not master. This will
   remove the need for an extra pin to indiciate that data wants to
   be sent from the host/tm4c123g.

 - Make simpleriscv GPIOs to be configurable at least as input/output.

 - The simpleriscv mcu should not have a LED periph. These all should
   be GPIOs, which on Basys3 **board** happen to be connected to LEDs.

 - `verif_results.py` etc. should not be in the fpga dir.

 - Make all FPGA RISC-V tests cycle-independent (that is, the test bench
   does not depend on the amounf of cycles being executed for a particular
   result to be correct)
