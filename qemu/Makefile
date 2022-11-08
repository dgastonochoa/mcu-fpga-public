BOARD ?= sifive_e

$(info - Board = $(BOARD))

ifeq ($(BOARD),sifive_e)
LD_SCRIPT := ./sifive_e/sifive_e.ld
EXTRA_FLAGS := -T$(LD_SCRIPT) -Wa,--defsym,BOARD_SIFIVE_E=1
else ifeq ($(BOARD),my_riscv)
LD_SCRIPT := my_riscv_image.ld
EXTRA_FLAGS := -T$(LD_SCRIPT) -Wa,--defsym,BOARD_MY_RISCV=1
endif

CC=riscv64-unknown-elf-gcc
OBJC=riscv64-unknown-elf-objcopy

CC_FLAGS=-march=rv32g -mabi=ilp32 -static -mcmodel=medany \
	-fvisibility=hidden -nostdlib -nostartfiles \
	-Isifive_e -g

BUILDIR=build

$(BUILDIR)/riscv_all_instr_test.elf: riscv_all_instr_test.s $(BUILDIR)/.$(LD_SCRIPT).ld_timestamp.s | dirs
	$(CC) -o $@ $(CC_FLAGS) $(EXTRA_FLAGS) $<

$(BUILDIR)/led_blink.elf: led_blink.s $(BUILDIR)/.$(LD_SCRIPT).ld_timestamp.s | dirs
	$(CC) -o $@ $(CC_FLAGS) $(EXTRA_FLAGS) $<

$(BUILDIR)/%.bin: $(BUILDIR)/%.elf
	$(OBJC) -O binary $< $@

$(BUILDIR)/%.txt: $(BUILDIR)/%.bin
	xxd -e -c 4 $< | cut -d ' ' -f 2 > $@

$(BUILDIR)/.$(LD_SCRIPT).ld_timestamp.s: $(LD_SCRIPT) | dirs
	@touch $(BUILDIR)/.$(LD_SCRIPT).ld_timestamp.s


.PHONY:
clean:
	rm -rf $(BUILDIR)

.PHONY:
dirs:
	@if [ ! -d "./build" ]; then mkdir build; fi
