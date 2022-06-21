PREFIX ?= ./build
SRC = ../../src
INC = ../../include

VV := iverilog
VVP := vvp

IFLAGS := -DIVERILOG -DRISCV_FPGA_FIRST_TEST

all: $(PREFIX)/riscv_single.xv

$(PREFIX)/riscv_single.xv: riscv_single_tb.sv riscv_single.sv $(SRC)/mem.sv $(SRC)/utils.sv $(SRC)/alu.sv $(SRC)/riscv/controller.sv $(SRC)/riscv/datapath.sv $(SRC)/riscv/riscv.sv | dirs
	$(VV) -o $@ -g2012 $(IFLAGS) -I$(INC) -Wall -Wno-timescale -DVCD="\"$@.vcd\"" -DWAIT_CLKS=1 $^
	$(VVP) $@

.PHONY: dirs
dirs:
	@mkdir -p $(PREFIX)

.PHONY: clean
clean:
	@rm -rf $(PREFIX)/*