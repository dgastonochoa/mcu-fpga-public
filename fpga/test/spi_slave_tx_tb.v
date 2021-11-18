`timescale 1us/100ns

module spi_slave_tx_tb;

  wire miso, busy;
  reg ss, sck;
  reg [7:0] data;
  reg [7:0] read_data;
  reg [3:0] idx;

  wire [1:0] _dbg_cs;
  wire [3:0] _dbg_idx;
  wire [7:0] _dbg_data;

  spi_slave_tx sst(miso, busy, _dbg_cs, _dbg_idx, _dbg_data, data, ss, sck);

  initial begin
    $dumpfile("spi_slave_tx_tb.vcd");
    $dumpvars(1, spi_slave_tx_tb);
    ss <= 1;

    // 2.5 waits are to assure that the bits are read on
    // the rising edge, as an actual spi receiver would do.

    read_data <= 0;
    idx <= 0;
    data <= 8'b01010101;
    #2.5 ss <= 0;
    repeat (8) begin
      #5 read_data[idx] <= miso;
      idx <= idx + 1;
    end
    ss <= 1;

    @(negedge busy);
    read_data <= 0;
    idx <= 0;
    data <= 8'b10101010;
    #2.5 ss <= 0;
    repeat (8) begin
      #5 read_data[idx] <= miso;
      idx <= idx + 1;
    end
    ss <= 1;

    @(negedge busy);
    read_data <= 0;
    idx <= 0;
    data <= 8'h37;
    #2.5 ss <= 0;
    repeat (8) begin
      #5 read_data[idx] <= miso;
      idx <= idx + 1;
    end
    ss <= 1;

    #20;
    $finish;
  end

  initial begin
    sck <= 0;
    forever begin
      #2.5 sck <= ~sck;
    end
  end

endmodule
