#!/bin/bash

rm -rf ./build/* && pushd ./build && cmake .. -DARCH=riscv -DSOC=simpleriscv      -DAPP_NAME=test_app                                  && make && popd
rm -rf ./build/* && pushd ./build && cmake .. -DARCH=riscv -DSOC=sifive_e      -DAPP_NAME=test_app                                  && make && popd
rm -rf ./build/* && pushd ./build && cmake .. -DARCH=riscv -DSOC=simpleriscv      -DAPP_NAME=led_blink                                 && make && popd
rm -rf ./build/* && pushd ./build && cmake .. -DARCH=arm   -DSOC=cortex-m4     -DAPP_NAME=fw_updater       -DTIVA_SDK=y             && make && popd
rm -rf ./build/* && pushd ./build && cmake .. -DARCH=arm   -DSOC=cortex-m4     -DAPP_NAME=spi_reader       -DTIVA_SDK=y             && make && popd
rm -rf ./build/* && pushd ./build && cmake .. -DARCH=arm   -DSOC=cortex-m4     -DAPP_NAME=i2c_legacy       -DTIVA_SDK=y             && make && popd