`timescale 1us/100ns

module spi_slave_rx_tb;

  reg mosi = 0, ss = 1, sck = 0;
  reg [7:0] final_data = 0;

  wire [7:0] data, _dbg_buf;
  wire [1:0] _dbg_cs;
  wire [3:0] _dbg_idx;
  wire busy;
  wire rdy;

  spi_slave_rx ssr(data, busy, rdy, _dbg_cs, _dbg_buf, _dbg_idx, mosi, ss, sck);

  initial begin
    $dumpfile("spi_slave_rx_tb.vcd");
    $dumpvars(1, spi_slave_rx_tb);
    // wait for 10 + 2.5, 2.5 because the SPI sender must
    // send bits on the negedge.
    #12.5;

    mosi <= 0;
    ss <= 0;
    repeat (8) begin
      #5 mosi <= ~mosi;
    end
    ss <= 1;
    mosi <= 0;
    @(negedge busy);
    // again, wait for 2.5 after busy to send always
    // on the negedge.
    #2.5;

    mosi <= 1;
    ss <= 0;
    repeat (8) begin
      #5 mosi <= ~mosi;
    end
    ss <= 1;
    mosi <= 0;
    @(negedge busy);
    #2.5;

    #50;
    $finish;
  end

  always @(posedge rdy) begin
    final_data <= data;
  end

  initial begin
    #5 sck <= 1;
    forever begin
      #2.5 sck <= ~sck;
    end
  end

endmodule
