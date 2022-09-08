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

ifeq ($(CONFIG_RISCV_SINGLECYCLE),y)
DEFS += -DIVERILOG -DCONFIG_RISCV_SINGLECYCLE
INC += -I./include/singlecycle
else ifeq ($(CONFIG_RISCV_MULTICYCLE),y)
DEFS += -DIVERILOG -DCONFIG_RISCV_MULTICYCLE
INC += -I./include/multicycle
else ifeq ($(CONFIG_RISCV_PIPELINE),y)
DEFS += -DIVERILOG -DCONFIG_RISCV_PIPELINE
INC += -I./include/pipeline
endif

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
			 $(SRC)/test_utils.sv					\
			 $(SRC)/legacy/utils/debounce_filter.v	\
			 $(SRC)/riscv/datapath_utils.sv			\
			 $(SRC)/riscv/io.sv						\
			 $(SRC)/riscv/controller_common.sv

ifeq ($(CONFIG_RISCV_SINGLECYCLE),y)
src_files += $(SRC)/riscv/riscv_singlecycle.sv		\
			 $(SRC)/riscv/controller_singlecycle.sv	\
			 $(SRC)/riscv/datapath_singlecycle.sv

else ifeq ($(CONFIG_RISCV_MULTICYCLE),y)
src_files += $(SRC)/riscv/riscv_multicycle.sv		\
			 $(SRC)/riscv/controller_multicycle.sv	\
			 $(SRC)/riscv/datapath_multicycle.sv
else ifeq ($(CONFIG_RISCV_PIPELINE),y)
src_files += $(SRC)/riscv/datapath_pipeline.sv		\
			 $(SRC)/riscv/controller_common.sv		\
			 $(SRC)/riscv/controller_singlecycle.sv	\
			 $(SRC)/riscv/mem_pipeline.sv			\
			 $(SRC)/riscv/hazard_ctrl.sv			\
			 $(SRC)/riscv/riscv_pipeline.sv
endif


all: tests wavedumps

#
# Execute tests without generating wavedumps
#
tests: $(PREFIX)/riscv_all_instr_physical_fpga_test_top_tb.xv

$(PREFIX)/riscv_all_instr_physical_fpga_test_top_tb.xv: riscv_all_instr_physical_fpga_test_top_tb.sv riscv_all_instr_physical_fpga_test_top.sv $(src_files) | dirs


#
# Wavedumps only
#
wavedumps: $(PREFIX)/riscv_all_instr_physical_fpga_test_top_tb.vcd

$(PREFIX)/riscv_all_instr_physical_fpga_test_top_tb.vcd: $(PREFIX)/riscv_all_instr_physical_fpga_test_top_tb.xv


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
