PREFIX ?= ./build
VV := iverilog
VVP := vvp

all: $(PREFIX)/led_blink.xv

$(PREFIX)/led_blink.xv: led_blink_tb.sv led_blink.sv | dirs
	$(VV) -o $@ -g2012 -Wall -Wno-timescale -DVCD="\"$@.vcd\"" -DWAIT_CLKS=2 $^
	$(VVP) $@

.PHONY: dirs
dirs:
	@mkdir -p $(PREFIX)

.PHONY: clean
clean:
	@rm -rf $(PREFIX)/*
