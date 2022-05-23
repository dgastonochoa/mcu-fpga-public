BUILDIR=./build
SRC=../src
SRCRV=$(SRC)/riscv
TSRCRV=./riscv
INC=../include

RANDOM := $(shell bash -c 'echo $$RANDOM')

tests := $(BUILDIR)/alu_logic_tb.xv 	\
		 $(BUILDIR)/alu_add_tb.xv 		\
		 $(BUILDIR)/alu_subs_tb.xv 		\
		 $(BUILDIR)/mem_tb.xv 			\
		 $(BUILDIR)/regfile_tb.xv 		\
		 $(BUILDIR)/lw_tb.xv			\
		 $(BUILDIR)/sw_tb.xv			\
		 $(BUILDIR)/datapath_tb.xv

all: $(tests)
	$(foreach test,$^,vvp $(test);)

$(BUILDIR)/alu_logic_tb.xv: alu_logic_tb.sv $(SRC)/alu.sv
$(BUILDIR)/alu_add_tb.xv: alu_add_tb.sv $(SRC)/alu.sv
$(BUILDIR)/alu_subs_tb.xv: alu_subs_tb.sv $(SRC)/alu.sv

$(BUILDIR)/mem_tb.xv: mem_tb.sv $(SRC)/mem.sv
$(BUILDIR)/regfile_tb.xv: $(TSRCRV)/datapath/regfile_tb.sv $(SRC)/alu.sv $(SRC)/mem.sv $(SRC)/utils.sv $(SRCRV)/datapath.sv
$(BUILDIR)/lw_tb.xv: $(TSRCRV)/datapath/lw_tb.sv $(SRC)/alu.sv $(SRC)/mem.sv $(SRC)/utils.sv $(SRCRV)/datapath.sv $(SRCRV)/riscv_single_top.sv
$(BUILDIR)/sw_tb.xv: $(TSRCRV)/datapath/sw_tb.sv $(SRC)/alu.sv $(SRC)/mem.sv $(SRC)/utils.sv $(SRCRV)/datapath.sv $(SRCRV)/riscv_single_top.sv
$(BUILDIR)/datapath_tb.xv: $(TSRCRV)/datapath/datapath_tb.sv $(SRC)/alu.sv $(SRC)/mem.sv $(SRC)/utils.sv $(SRCRV)/datapath.sv $(SRCRV)/riscv_single_top.sv

$(BUILDIR)/%_tb.xv:
	@if [ ! -d "$(BUILDIR)" ]; then mkdir $(BUILDIR); fi
	@echo "Building $@"
	@iverilog -o $@ -g2012 -DSEED=$(RANDOM) -I$(INC) -DVCD="\"$@.vcd\"" $^

$(BUILDIR)/2scomp: ./utils/2scomp.c
	gcc -o $@ -std=c11 $<

.PHONY: clean
clean:
	@rm -rf $(BUILDIR)/*

.PHONY: dirs
dirs:
	@mkdir -p $(BUILDIR)
