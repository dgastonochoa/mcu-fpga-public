BUILDIR=./build
TESTUTILS=./test-utils
SRC=../src
SRCRV=$(SRC)/riscv
TSRCRV=./riscv
INC=../include

CC=gcc
VV=iverilog
RV_AS=riscv64-unknown-elf-as
RV_OBJCOPY=riscv64-unknown-elf-objcopy

RANDOM := $(shell bash -c 'echo $$RANDOM')

tests := $(BUILDIR)/datapath/lw_tb.xv			\
		 $(BUILDIR)/datapath/sw_tb.xv			\
		 $(BUILDIR)/datapath/or_tb.xv			\
		 $(BUILDIR)/datapath/and_tb.xv			\
		 $(BUILDIR)/datapath/sub_tb.xv			\
		 $(BUILDIR)/datapath/beq_tb.xv			\
		 $(BUILDIR)/datapath/datapath_tb.xv		\
		 $(BUILDIR)/controller_tb.xv			\
		 $(BUILDIR)/mem_tb.xv					\
		 $(BUILDIR)/alu_logic_tb.xv				\
		 $(BUILDIR)/alu_add_tb.xv				\
		 $(BUILDIR)/alu_subs_tb.xv

test_sources := $(SRC)/alu.sv 					\
				$(SRC)/mem.sv 					\
				$(SRC)/utils.sv 				\
				$(SRCRV)/datapath.sv 			\
				$(SRCRV)/riscv_single_top.sv 	\
				$(SRCRV)/controller.sv

all: $(tests)
	$(foreach test,$^,vvp $(test);)

gen_as: $(BUILDIR)/as_instr.bin

$(BUILDIR)/alu_logic_tb.xv: alu_logic_tb.sv $(SRC)/alu.sv
$(BUILDIR)/alu_add_tb.xv: alu_add_tb.sv $(SRC)/alu.sv
$(BUILDIR)/alu_subs_tb.xv: alu_subs_tb.sv $(SRC)/alu.sv
$(BUILDIR)/mem_tb.xv: mem_tb.sv $(SRC)/mem.sv

$(BUILDIR)/controller_tb.xv: $(TSRCRV)/controller_tb.sv $(SRCRV)/controller.sv

$(BUILDIR)/datapath/regfile_tb.xv: $(TSRCRV)/datapath/regfile_tb.sv $(test_sources)
$(BUILDIR)/datapath/lw_tb.xv: $(TSRCRV)/datapath/lw_tb.sv $(test_sources)
$(BUILDIR)/datapath/sw_tb.xv: $(TSRCRV)/datapath/sw_tb.sv $(test_sources)
$(BUILDIR)/datapath/or_tb.xv: $(TSRCRV)/datapath/or_tb.sv $(test_sources)
$(BUILDIR)/datapath/and_tb.xv: $(TSRCRV)/datapath/and_tb.sv $(test_sources)
$(BUILDIR)/datapath/sub_tb.xv: $(TSRCRV)/datapath/sub_tb.sv $(test_sources)
$(BUILDIR)/datapath/beq_tb.xv: $(TSRCRV)/datapath/beq_tb.sv $(test_sources)
$(BUILDIR)/datapath/datapath_tb.xv: $(TSRCRV)/datapath/datapath_tb.sv $(test_sources)

%_tb.xv:
	@echo "Building $@"
	@mkdir -p $(dir $@)
	@$(VV) -o $@ -g2012 -DSEED=$(RANDOM) -I$(INC) -DVCD="\"$@.vcd\"" $^

$(BUILDIR)/2scomp: $(TESTUTILS)/2scomp.c dirs
	$(CC) -o $@ -std=c11 $<

$(BUILDIR)/as_instr.bin: $(TESTUTILS)/as_instr.s dirs
	@$(RV_AS) -o $@.elf $<
	@$(RV_OBJCOPY) -O binary $@.elf $@.bin
	@xxd -e -c 4 $@.bin

.PHONY: clean
clean:
	@rm -rf $(BUILDIR)/*

.PHONY: dirs
dirs:
	@if [ ! -d "$(BUILDIR)" ]; then mkdir -p $(BUILDIR); fi
