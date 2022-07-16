PREFIX ?= ./build
SRC = ../../src
INC = ../../include

VV := iverilog
VVP := vvp

#
# Simulation only
#
IFLAGS := -DIVERILOG

all: $(PREFIX)/seven_seg_display_top_tb.xv

$(PREFIX)/seven_seg_display_top_tb.xv: seven_seg_display_top_tb.sv seven_seg_display_top.sv $(SRC)/seven_seg_display.sv $(SRC)/utils.sv $(SRC)/legacy/utils/debounce_filter.v | dirs
	$(VV) -o $@ -g2012 $(IFLAGS) -I$(INC) -Wall -Wno-timescale -DVCD="\"$@.vcd\"" $^
	$(VVP) $@

.PHONY: dirs
dirs:
	@mkdir -p $(PREFIX)

.PHONY: clean
clean:
	@rm -rf $(PREFIX)/*
