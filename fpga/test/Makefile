BUILDIR=./build
SRCD=../src
SRCP=$(SRCD)/spi
SRCU=$(SRCD)/utils
SRCI=$(SRCD)/i2c
APP=../app

spi: spi_tb.v $(SRCP)/spi_master.v $(SRCP)/spi_slave.v $(SRCP)/spi_tx.v $(SRCP)/spi_rx.v $(SRCD)/utils/pos_edge_det.v $(SRCD)/utils/neg_edge_det.v $(SRCD)/utils/cell_sync.v $(SRCU)/debounce_filter.v dirs
	iverilog -o $(BUILDIR)/spi_tb.xv -g2012 spi_tb.v $(SRCP)/spi_master.v $(SRCP)/spi_slave.v $(SRCP)/spi_tx.v $(SRCP)/spi_rx.v $(SRCD)/utils/pos_edge_det.v $(SRCD)/utils/neg_edge_det.v $(SRCD)/utils/cell_sync.v $(SRCU)/debounce_filter.v
	@cd $(BUILDIR) && vvp ./spi_tb.xv

ped: pos_edge_det_tb.v neg_edge_det_tb.v $(SRCU)/pos_edge_det.v $(SRCU)/neg_edge_det.v dirs
	iverilog -o $(BUILDIR)/pos_edge_det_tb.xv -g2012 pos_edge_det_tb.v $(SRCU)/pos_edge_det.v
	iverilog -o $(BUILDIR)/neg_edge_det_tb.xv -g2012 neg_edge_det_tb.v $(SRCU)/neg_edge_det.v
	@cd $(BUILDIR) && vvp ./pos_edge_det_tb.xv && vvp ./neg_edge_det_tb.xv

debf: debounce_filter_tb.v $(SRCU)/debounce_filter.v dirs
	iverilog -o $(BUILDIR)/debounce_filter_tb.xv -g2012 debounce_filter_tb.v $(SRCU)/debounce_filter.v
	@cd $(BUILDIR) && vvp ./debounce_filter_tb.xv

shift_reg: shift_reg_tb.v $(SRCU)/shift_reg.v dirs
	iverilog -o $(BUILDIR)/shift_reg_tb.xv -g2012 shift_reg_tb.v $(SRCU)/shift_reg.v
	@cd $(BUILDIR) && vvp ./shift_reg_tb.xv

clk_gen: clk_gen_tb.v $(SRCU)/clk_gen.v $(SRCU)/pos_edge_det.v $(SRCU)/cell_sync.v dirs
	iverilog -o $(BUILDIR)/clk_gen_tb.xv -g2012 clk_gen_tb.v $(SRCU)/clk_gen.v $(SRCU)/pos_edge_det.v $(SRCU)/cell_sync.v
	@cd $(BUILDIR) && vvp ./clk_gen_tb.xv

i2c: i2c-read i2c-write

i2c-read: i2c_master_read_tb.v $(SRCI)/i2c_master.v $(SRCI)/i2c_slave.v $(SRCU)/double_clk_gen.v $(SRCU)/pos_edge_det.v $(SRCU)/neg_edge_det.v $(SRCU)/cell_sync.v
	@mkdir -p $(BUILDIR)
	iverilog -o $(BUILDIR)/$<.xv -g2012 $^
	@cd $(BUILDIR) && vvp ./$<.xv

i2c-write: i2c_master_write_tb.v $(SRCI)/i2c_master.v $(SRCI)/i2c_slave.v $(SRCU)/double_clk_gen.v $(SRCU)/pos_edge_det.v $(SRCU)/neg_edge_det.v $(SRCU)/cell_sync.v
	@mkdir -p $(BUILDIR)
	iverilog -o $(BUILDIR)/$<.xv -g2012 $^
	@cd $(BUILDIR) && vvp ./$<.xv

i2c-app: i2c_app_tb.v $(APP)/i2c/i2c_app.v $(SRCU)/debounce_filter.v $(SRCI)/i2c_master.v $(SRCI)/i2c_slave.v $(SRCU)/double_clk_gen.v $(SRCU)/pos_edge_det.v $(SRCU)/neg_edge_det.v $(SRCU)/cell_sync.v
	@mkdir -p $(BUILDIR)
	iverilog -o $(BUILDIR)/$<.xv -DTEST_BENCH -g2012 $^
	@cd $(BUILDIR) && vvp ./$<.xv

double_clk_gen: double_clk_gen_tb.v $(SRCU)/double_clk_gen.v
	@mkdir -p $(BUILDIR)
	iverilog -o $(BUILDIR)/$<.xv -g2012 $^
	@cd $(BUILDIR) && vvp ./$<.xv

.PHONY: clean
clean:
	@rm -rf $(BUILDIR)

.PHONY: dirs
dirs:
	mkdir -p $(BUILDIR)
