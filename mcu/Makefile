-include .config

MAKEFILE_SOURCE_DIR = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
BUILD_ROOT = $(MAKEFILE_SOURCE_DIR)/build

incremental-build: $(BUILD_ROOT)/.first-time-build-timestamp
	@cd $(BUILD_ROOT) && make -s

$(BUILD_ROOT)/.first-time-build-timestamp: ./.config | dirs
	@echo
	@echo "************************************************"
	@echo
	@echo "   App. name = $(CONFIG_APP_NAME)"
	@echo
	@echo "************************************************"
	@rm -rf $(BUILD_ROOT)/* && cd $(BUILD_ROOT) && cmake .. -DARCH=$(CONFIG_ARCH) -DSOC=$(CONFIG_SOC) -DAPP_NAME=$(CONFIG_APP_NAME) $(CONFIG_EXTRA_BUILD_DEFS)
	@touch $@


#
# config targets
#
.PHONY: tm4c123g-fw_updater_defconfig
tm4c123g-fw_updater_defconfig: $(MAKEFILE_SOURCE_DIR)/config/tm4c123g-fw_updater_defconfig
	@cp $< $(MAKEFILE_SOURCE_DIR)/.config

.PHONY: tm4c123g-fw_updater_defconfig
tm4c123g-spi_reader_defconfig: $(MAKEFILE_SOURCE_DIR)/config/tm4c123g-spi_reader_defconfig
	@cp $< $(MAKEFILE_SOURCE_DIR)/.config

.PHONY: simpleriscv-led_blink_defconfig
simpleriscv-led_blink_defconfig: $(MAKEFILE_SOURCE_DIR)/config/simpleriscv-led_blink_defconfig
	@cp $< $(MAKEFILE_SOURCE_DIR)/.config

.PHONY: simpleriscv-led_blink_c_defconfig
simpleriscv-led_blink_c_defconfig: $(MAKEFILE_SOURCE_DIR)/config/simpleriscv-led_blink_c_defconfig
	@cp $< $(MAKEFILE_SOURCE_DIR)/.config

.PHONY: simpleriscv-test_app_defconfig
simpleriscv-test_app_defconfig: $(MAKEFILE_SOURCE_DIR)/config/simpleriscv-test_app_defconfig
	@cp $< $(MAKEFILE_SOURCE_DIR)/.config


#
# Aux. targets
#
.PHONY: flash
flash:
	@cd $(BUILD_ROOT) && make -s flash

.PHONY: clean
clean:
	@rm -rf $(BUILD_ROOT)
	@cd submodules/SW-TM4C/TivaWare_C_Series-2.1.4.178 && make clean
	@cd submodules/lm4tools/lm4flash && make clean
	@cd submodules/lm4tools/lmicdiusb && make clean


.PHONY: dirs
dirs:
	@mkdir -p $(BUILD_ROOT)

.PHONY: debdeps
debdeps:
	sudo apt update && sudo apt install -y $(cat /packages.txt)

.PHONY: docker
docker:
	docker build -f docker/Dockerfile -t gr_mcu .
	docker run --privileged -it -v ~/.ssh:/home/dan-docker/.ssh -v .:/home/dan-docker/mcu gr_mcu
