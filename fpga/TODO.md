This file contains works to be done in the future.

 - The pipelined CPU needs to run at 25 MHz as a consequence of the delay
   added by having mixed data/instr. memory. This can be fixed by making
   the memory (for the pipelined CPU) sync-read and adding an extra stage
   to the pipeline (since now the memory read will require 2 stages: one
   to calc. the address and another one to read). This wil surely allow
   to incr. the pipelined freq. to 50 MHz, maybe even 100.

 - Make the FPGA's mcu to have a slave spi, not master. This will
   remove the need for an extra pin to indiciate that data wants to
   be sent from the host/tm4c123g. --> Possibly it will need both master
   and slave to first update then execute and send results.

 - Make simpleriscv GPIOs to be configurable at least as input/output.

 - The simpleriscv mcu should not have a LED periph. These all should
   be GPIOs, which on Basys3 **board** happen to be connected to LEDs.

 - `verif_results.py` etc. should not be in the fpga dir.

 - Make all FPGA RISC-V tests cycle-independent (that is, the test bench
   does not depend on the amounf of cycles being executed for a particular
   result to be correct)
