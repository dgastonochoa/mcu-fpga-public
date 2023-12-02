# Summary

This directory contains a bootloader application meant to be run on the RISC-V MCU, on an FPGA.

The source code is located under `apps`. This directory exists to enable the possibility of having
different bootloaders in a future, but for now there is only one.

# Tests

The current bootloader app. is written in assembly, so it's difficult to unit-test on the host.
Thus, qemu is used to run tests and debug. The details about how to run these tests are in the
`test` directory.

# Build

To build the project, do:

```
mkdir build
cd build
cmake .. -DGEN_DISSAS_TXT=y -DARCH="riscv" -DSOC="simpleriscv" -DAPP_NAME="simpleboot"
make
```
