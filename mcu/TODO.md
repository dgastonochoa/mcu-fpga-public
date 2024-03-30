This file contains works to be done in the future.

 - Modify `toolchain-riscv.cmake` to use the assembler when compiling
   `*.s` files. Modify the assembler flags to be correct as well.

 - Place assembly code in arch-specific directories.

 - Make `fw_updater` to read the program to flash from the host. Create
   python scripts that serve as an update tool, that uses the tm4c123g
   SPI to update.

 - Automatize tests: create scripts that update and verify results all in
   a row.

 - Delete `verif_results.py` and similar scripts when they are no longer
   necessary.

 - Add support for RISC-V projects to packages.txt and Dockerfile. Do the
   same for IcarusVerilog.

