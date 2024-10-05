# Summary

This directory contains all the FW apps. that are not bootloaders.

# Install dependencies

Do `make debdeps`

# Install RISC-V toolchain

Some of the apps. in this repository need are targeted for RISC-V architecutre. In particular,
they are meant to be run in simpleriscv (see fpga directory). It's important to install a riscv
toolchain with the right architecture and ABI; for simpleriscv, this is rv32gc, ilp32 respectively.

:warning: Make sure you have run `make debdeps` BEFORE bulding the RISC-V toolchain.

Follow these steps:

 - Clone git@github.com:riscv-collab/riscv-gnu-toolchain.git
 - cd $RISCV-GNU-TOOLCHAIN_HOME
 - ./configure --prefix=$BUILD_DIR --with-arch=rv32gc --with-abi=ilp32
 - make -j $(nproc)
 - Add $BUILD_DIR to $PATH or create symbolic links in /usr/local/bin or equivalent

:warning: If something fails, try to build without `-j`.

Note 1: the installation sometimes fails for (apparently) no reason. It's able to produce some
binaries in the destination directory but not the gcc compiler for instance. In that case, re-run
`make -j $(nproc)`.

Note 2: the installation can get stuck while downloading dependencies. A tested workarround is
to manually run the script that downloads such dependencies.
See https://github.com/riscv-collab/riscv-gnu-toolchain/issues/1560

Note 3: if newlib headers are not copied (e.g. `stdint.h` cannot be found), try re-building without
`-j`. This has worked in the past.

# How to build FW

`make ${APP_NAME}`
`make`

## Example

`make simpleriscv-test_app_defconfig`
`make`

# How to flash the FW

Only supported on tm4c123g

`make flash`
