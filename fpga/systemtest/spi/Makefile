PREFIX ?= ./build
SRC = ../../src
INC = ../../include

VV := iverilog
VVP := vvp

IFLAGS := -DIVERILOG

all: $(PREFIX)/spi_tests.xv

$(PREFIX)/spi_tests.xv: spi_tests_tb.sv spi_tests.sv $(SRC)/utils.sv $(SRC)/spi.sv | dirs
	$(VV) -o $@ -g2012 $(IFLAGS) -I$(INC) -Wall -Wno-timescale -DVCD="\"$@.vcd\"" $^
	$(VVP) $@

.PHONY: dirs
dirs:
	@mkdir -p $(PREFIX)

.PHONY: clean
clean:
	@rm -rf $(PREFIX)/*
