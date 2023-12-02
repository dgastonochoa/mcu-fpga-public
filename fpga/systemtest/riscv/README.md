# Summary

Information about the RISC-V fpga<->mcu test (**bootloader version**)

This are system tests meant to be run physically on the FPGA, but they contain a SystemVerilog
test bench (to be run with iverilog for instance) to serve as a quick verification step before
synthetizing and running them in the FPGA, with all the complexity that involves.



# How the test works

The test consist on configuring the FPGA with a RISC-V MCU (single or multicycle, or pipelined),
that will contain a [pre-loaded program](#the-pre-loaded-program) in its memory. This pre-loaded
program can either be a [bootloader](#the-bootloader) or the [test firmware](#the-test-firmware).


## The test firmware

The test firmware is a RISC-V assembly program that tests all the supported instructions in
different contexts (edge values, provoked hazards etc.)

The firmware stores each operation result somewhere and then sends these results over SPI. The host
is expected to read these results and compare them with the expected ones to determine if the test
was successful.

The test firmware might also turn on LEDs or similar to indicate success/failure. See [test_app](#related-fw-applications)


## The bootloader

The bootloader is meant to wait for receiving the "test firmware" over SPI and then jump to it. Then
the test firmware runs as explained in [The test firmware](#the-test-firmware).



# The pre-loaded program


## Pre-loaded program location

The pre-loaded program, whether it be the test firmware or the bootloader, is located in
`${CURRENT_DIR}/include/${PROGRAM_NAME}/mem_default_vals.svh`.

:warning: Respect the file name `mem_default_vals.svh` as the HDL source files will search for it
specifically.


## Pre-loaded program format

The program's format is a a list of 32 bits numbers in hex. format (the program instructions)
enclosed in a macro that will be later used by the memory module to initialize itself with these
instructions.


## How is the pre-loaded program generated

The pre-loaded program is simply a RISC-V assembly file, or a C file, compiled with a RISC-V
compiler, using the appropriate compiler options to restrict it the set of supported instructions,
architecture etc.

The pre-loaded program is expected to be built using the build system under
`${PROJECT_SOURCE_DIR}/mcu` or `${PROJECT_SOURCE_DIR}/bootloader`. After the `elf` file is built,
it must be parsed to the appropriate [format](#pre-loaded-program-format).

To achieve this, the project provides several tools located in `${PROJECT_ROOT}/fpga/test/test-utils`.

In particular, `gen_asm_instr.sh` can be used take an `*.elf` file and generate a text file with a
list of instructions in plain text (32 bits, hex-format numbers). Then, `gen_mem_map_macro.py` can
take this file and convert it into one with the same format as `mem_default_vals.svh` in
[Pre-loaded program location](#pre-loaded-program-location).

Notice that some targets might automatically generate a plain text instructions file, so
`gen_asm_instr.sh` might not need to be manually run.

For more details about how the pre-loaded program (or any program) must be compiled and linked,
visit the `bootloader` and `mcu` directories mentioned above.


### Example of generating a pre-loaded program

Examples of how to obtain the values to be put in `mem_default_vals.svh` in
[Pre-loaded program location](#pre-loaded-program-location).

#### Firmware

```
cd ${PROJECT_ROOT_DIR}/mcu
make simpleriscv-test_app_defconfig
make
cd build
${PROJECT_ROOT_DIR}/fpga/test/test-utils/gen_mem_map_macro.py mcu.txt
```

#### Bootloader

```
cd ${PROJECT_ROOT_DIR}/bootloader
rm -rf build && mkdir build && cd build
cmake .. -DGEN_DISSAS_TXT=y -DARCH="riscv" -DSOC="simpleriscv" -DAPP_NAME="simpleboot"
make
${PROJECT_ROOT_DIR}/fpga/test/test-utils/gen_mem_map_macro.py bootloader.txt
```



# The test bench for the system test

This is a test bench to simulate (with iverilog) the execution of the actual system test in a quick
and easier-to-debug way.

This works as explained above: there is a set of values pre-loaded in memory, which the MCU will
run. Then, the MCU will send them over SPI. This means the test bench needs to instantiate an SPI
slave to read all these values, store them, and perform a series asserts to verify the match the
expected values.

Notice that the bootloader system test (that is, the bootloader is preloaded and waits to receive
the FW and jump to it) does not have a test bench; it's not supported. However, this test is
supported in [the real FPGA system test](#the-real-fpga-system-test).

## Run the test bench

To execute the simulation, do:

```
    CONFIG_RISCV_$(CPU_MODEL)=y make                                \
        build/riscv_all_instr_physical_fpga_test_top_tb.xv &&       \
        vvp ./build/riscv_all_instr_physical_fpga_test_top_tb.xv
```

`$(CPU_MODEL)` is "SINGLECYCLE", "MULTICYCLE" or "PIPELINED".

:warning: These tests are heavy and might take a few seconds to run. However, if they take too long
it might have got stuck. In that case: `ctrl+C`, type "finish" and press enter.



# The real FPGA system test

How to run the system tests in the physical FPGA.


## Related FW applications

The FW apps. related to this system tests are:

 - `test_app`, under `${PROJECT_SOURCE_DIR}/mcu/apps`. It's the test firmware app. It is meant to
    run on the MCU (in the FPGA) and test all the supported instructions in different scenarios.

 - `spi_reader`, under `${PROJECT_SOURCE_DIR}/mcu/apps`. It's a simple app. that reads from SPI and
    replicates to the UART. The host uses this to read the data sent from the FPGA over SPI.

 - `fw_updater`, under `${PROJECT_SOURCE_DIR}/mcu/apps`. Same as above but first sends the FW for
    the bootloader (in the MCU in the FPGA) to read it, place it and jump to it.

 - `simpleboot` under `${PROJECT_SOURCE_DIR}/bootloader/apps`. It's a bootloader that waits for
    receiving a FW image over SPI and then jumps to it. It's more complex than this, so see the
    READMEs in its location for more info.


## Expected results

The real FPGA system tests are meant to execute a series of operations, store their results and send
them over SPI. Then, the host is expected to compare the received results with the expected ones.

Notice that different tests might have different expected values; in particular, the plain FW test
and the bootloader test have different expected values. This is because the latter place the FW in
a different memory region (as the bootoader occupies the first addresses) and so the result of the
execution of some branch instructions might vary.

The expected results are located in `${PROJECT_SOURCE_DIR}/fpga/systemtest/riscv/expected_results`.

:warning: Make sure to choose the right expected results file to verify your test.


## Peripherals

This system tests require a MCU (tm4c123g) to be connected to the FPGA to:

 - Act as an SPI bridge between the FPGA and the host. -> In case the system test doesn't use the
   bootloader.

 - Act as a FW updater to send the test image to the bootloader running in the tested MCU (the MCU
   configured in the FPGA) and then read back all the values sent by the test image itself. -> In
   case he system test use the bootloader.

In any case the FPGA needs to be configured and the SPI-bridge-MCU flashed, and in a particular
order, which may vary depending on the type of system test (bootloader, no bootloader) being run.


## FPGA configuration through Vivado

 - Create a Vivado project and add all the required source files (those used
   to run the test bench). These files can be found in the `Makefile` in this
   directory. Do not add any test-bench related modules, such as the test bench module
   itself.

 - Add the required directories to the include path, namely:
    - `gr/fpga/include`
    - `gr/fpga/systemtests/riscv`
    - `gr/fpga/systemtests/riscv/include/$(APP_NAME)`. See warning below.

 - Add the require definitions, namely:
    - The CPU model, e.g.: `-DCONFIG_RISCV_SINGLECYCLE=y`
    - Enable the pre-loaded program feature: `-DCONFIG_ENABLE_MEM_DEFAULT_VALS=1`

 - Add the constraints files, which are located in the `cnstr` directory.


:warning: The FPGA's MCU pre-loaded program is determined by which
`gr/fpga/systemtests/riscv/include/$(APP_NAME)` directory is included. For no bootloader tests, use
`all_instr_test`; for bootloader tests use: `bootloader`.


## Connect the FPGA to TI tm4c123g

![fpga-mcu-pin-conn](./doc/img/FPGA-MCU-PIN-CON-2.png)


## SPI port configuration in the tm4c123g app

Configure the SPI reader as:
- PHA = 0
- POL = 1
- Num. bits = 8
- Min. bit rate: 10 kHz

The app. should already do this.


## Find the serial iface. in the host

See `find_spi_iface.sh`


## Run the test

Instructions to run the system tests

### Common steps
  - Connet the FPGA and tm4c123g SPI ports as explained above.
  - Connect the FPGA to the host.
  - Connect the tm4c123g to the host.


:warning: Whenever `${UART_iface}` is referred, it is possibly `ttyACM0`. The `find_spi_iface.sh`
tool in `${PROJ_SRC_DIR}/fpga/systemtest/riscv` can help to find it.

### No bootloader mode

Do this if the testbench is to not use the bootloader.

  - Create a sym. link to the expected results for this test:
   `ln -s ${PROJ_SRC_DIR}/fpga/systemtest/riscv/expected_results/all_instr_test/expected_results.py`

  - Configure the FPGA to not use the bootloader (see
    [FPGA configuration through Vivado](#fpga-configuration-through-vivado)).

  - Flash the tm4c123g with the `spi_reader` application.

  - In the host computer: `minicom -D /dev/${UART_iface} -C file.txt`

  - Reset the FPGA (this will trigger the execution of the test program)

  - Go to `file.txt` and verify it has received something (should be a list of numbers). Remove
    **everything** except from the data sent by the test program just executed.

  - Do: `verif_results.py file.txt`. If it returns nothing, the test has passed.


### Bootloader mode

Do this if the testbench is to use the bootloader.

 - Create a sym. link to the expected results for this test:
   `ln -s ${PROJ_SRC_DIR}/fpga/systemtest/riscv/expected_results/all_instr_test_bootloader/expected_results.py`

 - Flash the tm4c123g with the `fw_updater` application.

 - Configure the FPGA to use the bootloader (see
   [FPGA configuration through Vivado](#fpga-configuration-through-vivado)).

 - In the host computer: `minicom -D /dev/ttyACM0 -C file.txt`

 - Reset the tm4c123g. This should trigger the send of the
   test program and its execution. The program is first sent, then
   read back and verified, then executed.

 - Go to `file.txt` and remove **everything** except from the data sent by the test program just
   executed.

 - Do: `verif_results.py file.txt`. If it returns nothing, the test has passed.

