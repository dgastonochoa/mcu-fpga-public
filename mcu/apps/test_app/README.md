Test application for RISC-V.

Contains all the instructions in `ilp32` ABI in several scenarios. They are executed
and the results stored in memory, then sent over the SSI interface.

TODO Add an explain verif_results
TODO Add hazards tests
TODO The BOARD constant should be delcared and handled in upper levels
TODO Board shouldn't be sifive_e, that's the soc
