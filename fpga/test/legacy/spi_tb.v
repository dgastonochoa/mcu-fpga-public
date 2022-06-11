`timescale 1us/100ns

`define SEND_DATA_LENGTH 12
`define RECV_DATA_LENGTH 8

`define VAL1 12'hD5F
`define VAL2 12'h55F
`define VAL3 12'hAAF
`define VAL4 12'h00F

module spi_tb;

  reg clk = 0;
  wire rst;

  wire miso, mosi, ss, sck;

  reg en = 0;
  reg [`SEND_DATA_LENGTH - 1 : 0] master_send_data = `VAL1;
  wire [`RECV_DATA_LENGTH - 1 : 0] master_recv_data;
  wire busy;
  wire master_recv_data_rdy;

  spi_master sm(
    mosi, miso, ss, sck,
    clk, en, master_send_data, master_recv_data, busy, master_recv_data_rdy, rst
  );


  reg [`SEND_DATA_LENGTH - 1 : 0] slave_send_data = `VAL1;
  wire [`RECV_DATA_LENGTH - 1 : 0] slave_recv_data;
  wire slave_recv_data_rdy;

  spi_slave sl(
    miso, mosi, ss, sck, slave_send_data, slave_recv_data, slave_recv_data_rdy, clk, rst
  );


  // Master device
  initial begin
    $dumpfile("spi_tb.vcd");
    $dumpvars(1, spi_tb);
    #20 en <= 1;
    @(negedge busy);

    master_send_data <= `VAL2;
    slave_send_data <= `VAL2;
    en <= 0;
    #20 en <= 1;
    @(negedge busy);

    master_send_data <= `VAL3;
    slave_send_data <= `VAL3;
    en <= 0;
    #20 en <= 1;
    #20 en <= 0;
    #20 en <= 1;
    #20 en <= 0;
    @(negedge busy);

    master_send_data <= `VAL4;
    slave_send_data <= `VAL4;
    en <= 0;
    #20 en <= 1;
    #20 en <= 0;
    #20 en <= 1;
    #20 en <= 0;
    @(negedge busy);

    #200;
    $finish;
  end


  reg [`RECV_DATA_LENGTH - 1 : 0] mas_recv_rdy_data = 0;
  always @ (posedge master_recv_data_rdy) begin
    mas_recv_rdy_data <= master_recv_data;
  end


  // Slave device
  reg [`RECV_DATA_LENGTH - 1 : 0] sla_recv_rdy_data = 0;
  always @ (posedge slave_recv_data_rdy) begin
    sla_recv_rdy_data <= slave_recv_data;
  end


  // master debug vars
  // wire [1:0] _mas_rx_cs;
  // wire [1:0] _mas_tx_cs;
  wire [`RECV_DATA_LENGTH - 1 : 0] _mas_rx_buff;
  wire [`SEND_DATA_LENGTH - 1 : 0] _mas_tx_data_buf = 0;
  // wire [3:0] _mas_rx_idx;
  // wire _mas_en_pulse;
  wire [5:0] _mas_sck_cnt;
  // wire [3:0] _mas_tx_idx;
  // assign _mas_rx_cs = sm.rx.cs;
  assign _mas_rx_buff = sm.rx.buff;
  // assign _mas_rx_idx = sm.rx.idx;
  // assign _mas_en_pulse = sm.en_pulse;
  // assign _mas_tx_cs = sm.tx.cs;
  assign _mas_tx_data_buf = sm.tx.data_buf;
  // assign _mas_tx_idx = sm.tx.idx;
  assign _mas_sck_cnt = sm.sck_cnt;

  // slave debug vars
  // wire [`RECV_DATA_LENGTH - 1 : 0] _sla_rx_buff;
  // wire _sla_data_rdy;
  // wire [1:0] _sla_rx_cs;
  // wire [3:0] _sla_rx_idx;
  // assign _sla_rx_buff = sl.rx.buff;
  // assign _sla_rx_cs = sl.rx.cs;
  // assign _sla_rx_idx = sl.rx.idx;

  initial begin
    #5 clk <= 1;
    forever begin
      #2.5 clk <= ~clk;
    end
  end

endmodule
