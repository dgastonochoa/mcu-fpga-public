# Summary

Test application for RISC-V.

Contains all the instructions in `ilp32` ABI in several scenarios. They are executed
and the results stored in memory, then sent over the SSI interface.

When it finishes running all the instructions without error, and before sending the results, it
turns on LED 0.

When it finishes sending the results without errors, it turns off LED 0 and turns on LED 1.

# Target platforms

This app. can be built for 2 different target platforms:

 - simpleriscv: targets a `simpleriscv` CPU (configured in an FPGA)
 - sifive_e: targets a sifive_e CPU. qemu will be required to simulate it.

