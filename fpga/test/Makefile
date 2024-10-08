-include ./.config

PREFIX ?= ./build

SRC := ../src
SRCRV := $(SRC)/riscv
INC := -I../include -I./riscv -I.

TSRCRV := ./riscv
TESTUTILS := ./test-utils
RISCV_TEST_DIR := $(PREFIX)/riscv

CC := gcc
VV := iverilog
VVP := vvp

ifeq ($(CONFIG_RISCV_SINGLECYCLE),y)
IFLAGS := -DIVERILOG -DCONFIG_RISCV_SINGLECYCLE
else ifeq ($(CONFIG_RISCV_MULTICYCLE),y)
IFLAGS := -DIVERILOG -DCONFIG_RISCV_MULTICYCLE
else ifeq ($(CONFIG_RISCV_PIPELINE),y)
IFLAGS := -DIVERILOG -DCONFIG_RISCV_PIPELINE
else
IFLAGS := -DIVERILOG
endif

#
# Generate a random number. Can be useful for test benches
# sometimes.
#
RANDOM := $(shell bash -c 'echo $$RANDOM')


tests := $(PREFIX)/mem_word_ops_tb.xv				\
		 $(PREFIX)/mem_byte_ops_tb.xv				\
		 $(PREFIX)/mem_halfw_ops_tb.xv				\
		 $(PREFIX)/mem_error_tb.xv					\
		 $(PREFIX)/alu_logic_tb.xv					\
		 $(PREFIX)/alu_add_tb.xv					\
		 $(PREFIX)/alu_subs_tb.xv					\
		 $(PREFIX)/alu_cmp_tb.xv					\
		 $(PREFIX)/utils_clk_div_tb.xv				\
		 $(PREFIX)/utils_piso_reg_tb.xv				\
		 $(PREFIX)/utils_sipo_reg_tb.xv				\
		 $(PREFIX)/spi_master_ctrl_tb.xv			\
		 $(PREFIX)/spi_tb.xv						\
		 $(PREFIX)/spi_several_slaves_tb.xv

riscv_tests := $(RISCV_TEST_DIR)/lw_tb.xv						\
			   $(RISCV_TEST_DIR)/lb_tb.xv						\
			   $(RISCV_TEST_DIR)/lh_tb.xv						\
			   $(RISCV_TEST_DIR)/lbu_tb.xv						\
			   $(RISCV_TEST_DIR)/lhu_tb.xv						\
		 	   $(RISCV_TEST_DIR)/sw_lw_spi_tb.xv				\
		 	   $(RISCV_TEST_DIR)/sw_lw_spi_loop_tb.xv			\
		 	   $(RISCV_TEST_DIR)/sw_tb.xv						\
		 	   $(RISCV_TEST_DIR)/sb_tb.xv						\
		 	   $(RISCV_TEST_DIR)/sh_tb.xv						\
		 	   $(RISCV_TEST_DIR)/or_tb.xv						\
		 	   $(RISCV_TEST_DIR)/and_tb.xv						\
		 	   $(RISCV_TEST_DIR)/sub_tb.xv						\
		 	   $(RISCV_TEST_DIR)/xor_tb.xv						\
		 	   $(RISCV_TEST_DIR)/sll_tb.xv						\
		 	   $(RISCV_TEST_DIR)/srl_tb.xv						\
		 	   $(RISCV_TEST_DIR)/sra_tb.xv						\
		 	   $(RISCV_TEST_DIR)/slt_tb.xv						\
		 	   $(RISCV_TEST_DIR)/sltu_tb.xv						\
		 	   $(RISCV_TEST_DIR)/addi_tb.xv						\
		 	   $(RISCV_TEST_DIR)/slli_tb.xv						\
		 	   $(RISCV_TEST_DIR)/slti_tb.xv						\
		 	   $(RISCV_TEST_DIR)/sltiu_tb.xv					\
		 	   $(RISCV_TEST_DIR)/xori_tb.xv						\
		 	   $(RISCV_TEST_DIR)/srli_tb.xv						\
		 	   $(RISCV_TEST_DIR)/srai_tb.xv						\
		 	   $(RISCV_TEST_DIR)/ori_tb.xv						\
		 	   $(RISCV_TEST_DIR)/andi_tb.xv						\
		 	   $(RISCV_TEST_DIR)/lui_tb.xv						\
		 	   $(RISCV_TEST_DIR)/auipc_tb.xv					\
		 	   $(RISCV_TEST_DIR)/mem_map_gpio_tb.xv				\
		 	   $(RISCV_TEST_DIR)/mem_map_spi_tb.xv				\
		 	   $(RISCV_TEST_DIR)/mem_map_led_tb.xv				\
		 	   $(RISCV_TEST_DIR)/mem_map_io_dec_tb.xv			\
			   $(RISCV_TEST_DIR)/all_instr_program_test_tb.xv


ifeq ($(CONFIG_RISCV_SINGLECYCLE),y)
riscv_tests += $(RISCV_TEST_DIR)/controller_singlecycle_tb.xv					\
		 	   $(RISCV_TEST_DIR)/datapath_tb.xv									\
		 	   $(RISCV_TEST_DIR)/jal_tb.xv										\
		 	   $(RISCV_TEST_DIR)/jalr_tb.xv										\
			   $(RISCV_TEST_DIR)/beq_tb.xv										\
		 	   $(RISCV_TEST_DIR)/bne_tb.xv										\
		 	   $(RISCV_TEST_DIR)/blt_tb.xv										\
		 	   $(RISCV_TEST_DIR)/bge_tb.xv										\
		 	   $(RISCV_TEST_DIR)/bltu_tb.xv										\
		 	   $(RISCV_TEST_DIR)/bgeu_tb.xv

else ifeq ($(CONFIG_RISCV_MULTICYCLE),y)
riscv_tests += $(RISCV_TEST_DIR)/controller_multicycle_tb.xv	\
		 	   $(RISCV_TEST_DIR)/datapath_tb.xv					\
			   $(RISCV_TEST_DIR)/jal_tb.xv						\
		 	   $(RISCV_TEST_DIR)/jalr_tb.xv						\
			   $(RISCV_TEST_DIR)/beq_tb.xv						\
		 	   $(RISCV_TEST_DIR)/bne_tb.xv						\
		 	   $(RISCV_TEST_DIR)/blt_tb.xv						\
		 	   $(RISCV_TEST_DIR)/bge_tb.xv						\
		 	   $(RISCV_TEST_DIR)/bltu_tb.xv						\
		 	   $(RISCV_TEST_DIR)/bgeu_tb.xv

else ifeq ($(CONFIG_RISCV_PIPELINE),y)
# Pipelined RISC-V branch behaviour is very different from the others
# with regards to the values that pc takes, therefore it is simpler
# to have separated tests for it.
riscv_tests += $(RISCV_TEST_DIR)/pipeline_jal_tb.xv				\
			   $(RISCV_TEST_DIR)/pipeline_jalr_tb.xv			\
			   $(RISCV_TEST_DIR)/pipeline_beq_tb.xv				\
		 	   $(RISCV_TEST_DIR)/pipeline_bne_tb.xv				\
		 	   $(RISCV_TEST_DIR)/pipeline_blt_tb.xv				\
		 	   $(RISCV_TEST_DIR)/pipeline_bge_tb.xv				\
		 	   $(RISCV_TEST_DIR)/pipeline_bltu_tb.xv			\
		 	   $(RISCV_TEST_DIR)/pipeline_bgeu_tb.xv			\
			   $(RISCV_TEST_DIR)/raw_hazards_tb.xv			 	\
		 	   $(RISCV_TEST_DIR)/lw_hazards_tb.xv			 	\
			   $(RISCV_TEST_DIR)/sw_hazards_tb.xv				\
		 	   $(RISCV_TEST_DIR)/sw_lw_hazard_tb.xv				\
			   $(RISCV_TEST_DIR)/ctrl_hazards_tb.xv
endif

tests_waves := $(addsuffix .vcd,$(tests))

riscv_tests_waves := $(addsuffix .vcd,$(riscv_tests))


common_src := $(SRC)/alu.sv 		\
			  $(SRC)/mem.sv 		\
			  $(SRC)/utils.sv		\
			  $(SRC)/test_utils.sv	\
			  $(SRC)/spi.sv

riscv_src := $(SRCRV)/io.sv $(SRC)/mcu.sv

ifeq ($(CONFIG_RISCV_SINGLECYCLE),y)
riscv_src +=  $(SRCRV)/datapath_singlecycle.sv 		\
			  $(SRCRV)/datapath_utils.sv	 		\
			  $(SRCRV)/riscv_singlecycle.sv 		\
			  $(SRCRV)/controller_singlecycle.sv	\
			  $(SRCRV)/controller_common.sv

else ifeq ($(CONFIG_RISCV_MULTICYCLE),y)
riscv_src +=  $(SRCRV)/datapath_multicycle.sv 		\
			  $(SRCRV)/datapath_utils.sv	 		\
			  $(SRCRV)/riscv_multicycle.sv 			\
			  $(SRCRV)/controller_multicycle.sv		\
			  $(SRCRV)/controller_common.sv

else ifeq ($(CONFIG_RISCV_PIPELINE),y)
# RISC-V pipeline version can re-use a lot of the singlecycle logic
riscv_src +=  $(SRCRV)/datapath_pipeline.sv 		\
			  $(SRCRV)/datapath_utils.sv			\
			  $(SRCRV)/controller_common.sv			\
			  $(SRCRV)/controller_singlecycle.sv	\
			  $(SRCRV)/mem_pipeline.sv				\
			  $(SRCRV)/hazard_ctrl.sv				\
			  $(SRCRV)/riscv_pipeline.sv
endif


#
# Build al tests and execute them without generating wave dumps
#
test: $(tests) $(riscv_tests)
	$(foreach test,$^,$(VVP) -n $(test) -none;)

wavedumps: $(tests_waves) $(riscv_tests_waves)

all: test wavedumps

$(tests): | dirs

$(riscv_tests): | dirs

$(wavedumps): | dirs


$(PREFIX)/%.xv: %.sv $(common_src)
	$(VV) -o $@ -g2012 -DSEED=$(RANDOM) $(IFLAGS) $(INC) -Wall -Wno-timescale -DVCD="\"$@.vcd\"" $^ $(PREFIX)/.include_timestamp.sv

$(RISCV_TEST_DIR)/%.xv: $(TSRCRV)/%.sv $(common_src) $(riscv_src) $(RISCV_TEST_DIR)/.config_timestamp.sv $(PREFIX)/.include_timestamp.sv
	$(VV) -o $@ -g2012 -DSEED=$(RANDOM) $(IFLAGS) $(INC) -Wall -Wno-timescale -DVCD="\"$@.vcd\"" $^

$(PREFIX)/%.xv.vcd: $(PREFIX)/%.xv
	$(VVP) -n $<

$(RISCV_TEST_DIR)/%.xv.vcd: $(RISCV_TEST_DIR)/%.xv
	$(VVP) -n $<

$(PREFIX)/2scomp: $(TESTUTILS)/2scomp.c dirs
	$(CC) -o $@ -std=c11 $<


.PHONY: clean
clean:
	@rm -rf $(PREFIX)/*

.PHONY: dirs
dirs:
	@mkdir -p $(PREFIX)
	@mkdir -p $(RISCV_TEST_DIR)

.PHONY: config/riscv/singlecycle
config/riscv/singlecycle: | dirs
	@echo CONFIG_RISCV_SINGLECYCLE=y > .config
	@touch $(RISCV_TEST_DIR)/.config_timestamp.sv

.PHONY: config/riscv/multicycle
config/riscv/multicycle: | dirs
	@echo CONFIG_RISCV_MULTICYCLE=y > .config
	@touch $(RISCV_TEST_DIR)/.config_timestamp.sv

.PHONY: config/riscv/pipelined
config/riscv/pipelined: | dirs
	@echo CONFIG_RISCV_PIPELINE=y > .config
	@touch $(RISCV_TEST_DIR)/.config_timestamp.sv

# This target will create $(RISCV_TEST_DIR)/.config_timestamp.sv the first time
# if it doesn't exist
$(RISCV_TEST_DIR)/.config_timestamp.sv: .config | dirs
	@touch $(RISCV_TEST_DIR)/.config_timestamp.sv


# This is a work-around to re-build any target if any of the following header
# files change, because iverilog does not have a -MMD option to generate
# a dependencies file, as gcc does. Note: this list could be split into common
# and RISC-V sources.
include_deps := ../include/alu.svh 						\
				../include/errno.svh					\
				../include/mem.svh						\
				../include/riscv/datapath.svh			\
				../include/riscv/controller.svh			\
				../include/riscv/test/test_mcu.svh		\
				../include/riscv/test/test_cpu.svh		\
				../include/riscv/test/test_cpu_mem.svh	\
				./riscv/riscv_test_utils.svh

$(PREFIX)/.include_timestamp.sv: $(include_deps)
	@touch $(PREFIX)/.include_timestamp.sv
