PREFIX ?= ./build
SRC = ../../src

#
# Required include directories (will be required at synthesis time
# as well)
#
INC = -I../../include -I.

VV := iverilog
VVP := vvp

#
# Definitions required both in simulation and synthesis. Required to
# (potentially among other things) pre-load the test program at
# synthesis time.
#
DEFS := -DCONFIG_ENABLE_MEM_DEFAULT_VALS

#
# Simulation-only definitions
#
SIM_DEFS := -DIVERILOG

#
# All required modules.
#
src_files := $(SRC)/spi.sv 							\
			 $(SRC)/mem.sv 							\
			 $(SRC)/utils.sv 						\
			 $(SRC)/alu.sv 							\
			 $(SRC)/riscv/riscv.sv 					\
			 $(SRC)/riscv/controller.sv 			\
			 $(SRC)/riscv/datapath.sv 				\
			 $(SRC)/legacy/utils/debounce_filter.v


all: tests wavedumps

#
# Execute tests without generating wavedumps
#
tests: $(PREFIX)/mem_send_ctrl_tb.xv $(PREFIX)/mem_send_ctrl_with_spi_tb.xv $(PREFIX)/riscv_single_all_instr_top_tb.xv

$(PREFIX)/mem_send_ctrl_tb.xv: mem_send_ctrl_tb.sv riscv_single_all_instr_top.sv $(src_files) | dirs

$(PREFIX)/mem_send_ctrl_with_spi_tb.xv: mem_send_ctrl_with_spi_tb.sv riscv_single_all_instr_top.sv $(src_files) | dirs

$(PREFIX)/riscv_single_all_instr_top_tb.xv: riscv_single_all_instr_top_tb.sv riscv_single_all_instr_top.sv $(src_files) | dirs


#
# Wavedumps only
#
wavedumps: $(PREFIX)/mem_send_ctrl_tb.vcd $(PREFIX)/mem_send_ctrl_with_spi_tb.vcd $(PREFIX)/riscv_single_all_instr_top_tb.vcd

$(PREFIX)/mem_send_ctrl_tb.vcd: $(PREFIX)/mem_send_ctrl_tb.xv

$(PREFIX)/mem_send_ctrl_with_spi_tb.vcd: $(PREFIX)/mem_send_ctrl_with_spi_tb.xv

$(PREFIX)/riscv_single_all_instr_top_tb.vcd: $(PREFIX)/riscv_single_all_instr_top_tb.xv


.PHONY: dirs
dirs:
	@mkdir -p $(PREFIX)

.PHONY: clean
clean:
	@rm -rf $(PREFIX)/*


$(PREFIX)/%.xv: %.sv
	$(VV) -o $@ -g2012 $(DEFS) $(SIM_DEFS) $(INC) -Wall -Wno-timescale -DVCD="\"$@.vcd\"" $^

$(PREFIX)/%.vcd: $(PREFIX)/%.xv
	$(VVP) $<
