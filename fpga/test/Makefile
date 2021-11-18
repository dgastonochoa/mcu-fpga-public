BUILDIR=./build
SRCD=../src
SRCP=$(SRCD)/spi
SRCU=$(SRCD)/utils

all: spi ped 

spi: spi_tb.v $(SRCP)/spi_master.v $(SRCP)/spi_slave.v $(SRCP)/spi_tx.v $(SRCP)/spi_rx.v $(SRCD)/utils/pos_edge_det.v $(SRCD)/utils/neg_edge_det.v $(SRCD)/utils/cell_sync.v $(SRCU)/debounce_filter.v dirs
	iverilog -o $(BUILDIR)/spi_tb.xv -g2012 spi_tb.v $(SRCP)/spi_master.v $(SRCP)/spi_slave.v $(SRCP)/spi_tx.v $(SRCP)/spi_rx.v $(SRCD)/utils/pos_edge_det.v $(SRCD)/utils/neg_edge_det.v $(SRCD)/utils/cell_sync.v $(SRCU)/debounce_filter.v
	@cd $(BUILDIR) && vvp ./spi_tb.xv

ped: pos_edge_det_tb.v neg_edge_det_tb.v $(SRCU)/pos_edge_det.v $(SRCU)/neg_edge_det.v dirs
	iverilog -o $(BUILDIR)/pos_edge_det_tb.xv -g2012 pos_edge_det_tb.v $(SRCU)/pos_edge_det.v
	iverilog -o $(BUILDIR)/neg_edge_det_tb.xv -g2012 neg_edge_det_tb.v $(SRCU)/neg_edge_det.v
	@cd $(BUILDIR) && vvp ./pos_edge_det_tb.xv && vvp ./neg_edge_det_tb.xv

debf: debounce_filter_tb.v $(SRCU)/debounce_filter.v
	iverilog -o $(BUILDIR)/pos_edge_det_tb.xv -g2012 $^
	@cd $(BUILDIR) && vvp ./pos_edge_det_tb.xv

.PHONY: dirs
dirs:
	mkdir -p $(BUILDIR)
