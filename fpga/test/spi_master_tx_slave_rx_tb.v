`timescale 1us/100ns

module spi_master_tx_slave_rx_tb;

  wire mosi, sck, ss, m_busy, s_busy, s_rdy;
  wire [7:0] data_out;

  wire [15:0] _dbg_m_timer;
  wire [7:0] _dbg_s_buff;
  wire [3:0] _dbg_s_idx;
  wire [1:0] _dbg_m_cs, _dbg_s_cs;
  wire _dbg_sck;

  reg [7:0] data_in;
  reg master_send;
  reg clk;

  spi_master_tx spi_m_tx(mosi, sck, ss, m_busy, _dbg_m_cs, _dbg_sck, _dbg_m_timer, data_in, master_send, clk);
  spi_slave_rx  spi_s_rx(data_out, s_busy, s_rdy, _dbg_s_cs, _dbg_s_buff, _dbg_s_idx, mosi, ss, sck);

  initial begin
    $dumpfile("spi_master_tx_slave_rx_tb.vcd");
    $dumpvars(1, spi_master_tx_slave_rx_tb);

    data_in <= 0;
    master_send <= 0;
    #10;

    data_in <= 8'b01010101;
    master_send <= 1;
    @(negedge s_busy);
    master_send <= 0;
    #10;

    data_in <= 8'hAA;
    master_send <= 1;
    @(negedge s_busy);
    master_send <= 0;
    #10;

    data_in <= 8'hFF;
    master_send <= 1;
    @(negedge s_busy);
    master_send <= 0;
    #10;

    data_in <= 8'h01;
    master_send <= 1;
    @(negedge s_busy);
    master_send <= 0;

    #400;
    $finish;
  end

  initial begin
    clk <= 0;
    #5 clk <= 1;
    forever begin
      #2.5 clk <= ~clk;
    end
  end
endmodule
