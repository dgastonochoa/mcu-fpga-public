PREFIX ?= ./build

SRC := ../src
SRCRV := $(SRC)/riscv
INC := ../include

TSRCRV := ./riscv
TESTUTILS := ./test-utils
RISCV_TEST_DIR := $(PREFIX)/riscv

CC := gcc
VV := iverilog
RV_AS := riscv64-unknown-elf-as
RV_OBJCOPY := riscv64-unknown-elf-objcopy
RANDOM := $(shell bash -c 'echo $$RANDOM')


tests := $(PREFIX)/mem_tb.xv				\
		 $(PREFIX)/alu_logic_tb.xv			\
		 $(PREFIX)/alu_add_tb.xv			\
		 $(PREFIX)/alu_subs_tb.xv

riscv_tests := $(RISCV_TEST_DIR)/lw_tb.xv			\
		 	   $(RISCV_TEST_DIR)/sw_tb.xv			\
		 	   $(RISCV_TEST_DIR)/or_tb.xv			\
		 	   $(RISCV_TEST_DIR)/and_tb.xv			\
		 	   $(RISCV_TEST_DIR)/sub_tb.xv			\
		 	   $(RISCV_TEST_DIR)/beq_tb.xv			\
		 	   $(RISCV_TEST_DIR)/addi_tb.xv			\
		 	   $(RISCV_TEST_DIR)/jal_tb.xv			\
		 	   $(RISCV_TEST_DIR)/datapath_tb.xv		\
		 	   $(RISCV_TEST_DIR)/controller_tb.xv

tests_waves := $(addsuffix .vcd,$(tests))

riscv_tests_waves := $(addsuffix .vcd,$(riscv_tests))


common_src := $(SRC)/alu.sv 	\
			  $(SRC)/mem.sv 	\
			  $(SRC)/utils.sv

riscv_src :=  $(SRCRV)/datapath.sv 			\
			  $(SRCRV)/riscv_single_top.sv 	\
			  $(SRCRV)/controller.sv


test: $(tests) $(riscv_tests)
	$(foreach test,$^,vvp $(test) -none;)

wavedumps: $(tests_waves) $(riscv_tests_waves)

gen_as: $(PREFIX)/as_instr.bin

$(tests): | dirs

$(riscv_tests): | dirs

$(wavedumps): | dirs


$(PREFIX)/%.xv: %.sv $(common_src)
	@$(VV) -o $@ -g2012 -DSEED=$(RANDOM) -I$(INC) -DVCD="\"$@.vcd\"" $^

$(RISCV_TEST_DIR)/%.xv: $(TSRCRV)/%.sv $(common_src) $(riscv_src)
	@$(VV) -o $@ -g2012 -DSEED=$(RANDOM) -I$(INC) -DVCD="\"$@.vcd\"" $^

$(PREFIX)/%.xv.vcd: $(PREFIX)/%.xv
	$(VVP) $<

$(RISCV_TEST_DIR)/%.xv.vcd: $(RISCV_TEST_DIR)/%.xv
	$(VVP) $<

$(PREFIX)/2scomp: $(TESTUTILS)/2scomp.c dirs
	$(CC) -o $@ -std=c11 $<

$(PREFIX)/as_instr.bin: $(TESTUTILS)/as_instr.s dirs
	@$(RV_AS) -o $@.elf $<
	@$(RV_OBJCOPY) -O binary $@.elf $@.bin
	@xxd -e -c 4 $@.bin


.PHONY: clean
clean:
	@rm -rf $(PREFIX)/*

.PHONY: dirs
dirs:
	@mkdir -p $(PREFIX)
	@mkdir -p $(RISCV_TEST_DIR)
