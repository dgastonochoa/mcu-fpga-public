BUILDIR=./build
SRC=../src

RANDOM := $(shell bash -c 'echo $$RANDOM')

test_alu := $(BUILDIR)/alu_logic_tb.xv \
			 $(BUILDIR)/alu_add_tb.xv \
			 $(BUILDIR)/alu_subs_tb.xv \
			 $(BUILDIR)/alu_slt_tb.xv

test/all: test/alu

test/alu: $(test_alu)
	$(foreach test,$^,vvp $(test);)

$(BUILDIR)/alu_logic_tb.xv: alu_logic_tb.v $(SRC)/alu.v
$(BUILDIR)/alu_add_tb.xv: alu_add_tb.v $(SRC)/alu.v
$(BUILDIR)/alu_subs_tb.xv: alu_subs_tb.v $(SRC)/alu.v

$(BUILDIR)/%_tb.xv:
	@echo "Building $@"
	@iverilog -o $@ -g2012 -DSEED=$(RANDOM) -DVCD="\"$@.vcd\"" $^

$(BUILDIR)/2scomp: ./utils/2scomp.c
	gcc -o $@ -std=c11 $<

.PHONY: clean
clean:
	@rm -rf $(BUILDIR)/*

.PHONY: dirs
dirs:
	@mkdir -p $(BUILDIR)
