# Summary

Information about the fpga<->mcu test (**bootloader version**)


# Execute the test bench

To execute the simulation, do:

    CONFIG_RISCV_$(CPU_MODEL)=y make                                \
        build/riscv_all_instr_physical_fpga_test_top_tb.xv &&       \
        vvp ./build/riscv_all_instr_physical_fpga_test_top_tb.xv

# Configure the FPGA through Vivado

 - Create a Vivado project and add all the required source files (those used
   to run the test bench). These files can be found in the `Makefile` in this
   directory. Do not add any test-related modules, such as the test bench module
   itself.

 - Add the required directories to the include path, namely:
    - `gr/fpga/include`
    - `gr/fpga/systemtests/riscv`
    - `gr/fpga/systemtests/riscv/include/$(APP_NAME)`

 - Add the require definitions, namely:
    - The CPU model, e.g.: `-DCONFIG_RISCV_SINGLECYCLE=y`
    - Enable the pre-loaded program feature: `-DCONFIG_ENABLE_MEM_DEFAULT_VALS=1`

 - Add the constraints files, which are located in the `cnstr` directory.


# Connect the FPGA to TI tm4c123g

![fpga-mcu-pin-conn](./doc/img/FPGA-MCU-PIN-CON-2.png)


# SPI port configuration in the tm4c123g app

Configure the SPI reader as:
- PHA = 0
- POL = 1
- Num. bits = 8
- Min. bit rate: 10 kHz


# Find the serial iface. in the host

See `find_spi_iface.sh`


# Run the test

 - In the host computer: `minicom -D /dev/ttyACM0 -C file.txt`
 - Config. the FPGA if it wasn't already, or reset it if it was.

 - Flash or reset the tm4c123g. This should trigger the send of the
   test program and its execution. The program is first sent, then
   read back and verified, then executed.

 - Go to `file.txt` and remove **everything** except from the data
   sent by the test program just executed.

  - Do: `verif_results.py file.txt`. If it returns nothing, the test
    has passed.

**Note:** The expected results are located at
`expected_results/$(TEST)/expected?results.py`.
