`timescale 1us/100ns

`define SEND_DATA_LENGTH 12
`define RECV_DATA_LENGTH 8

`define EN_WAIT_CYCLES_VAL 100

module spi_tb_fpga(CLK100MHZ, JA, vauxp6, vauxp14, vauxp7, vauxp15, sw, LED);

  input wire CLK100MHZ; 
  input wire [7:0] JA;
  output wire vauxp6;
  output wire vauxp14;
  output wire vauxp7;
  output wire vauxp15;
  input wire [15:0] sw;
  output wire [15:0] LED;

  wire __fpga_clk;
  reg [7:0] slave_read_val = 0;

  //
  // SPI var. decl.
  //
  wire miso, mosi, ss, sck;

  // slave
  reg [`SEND_DATA_LENGTH - 1 : 0] slave_send_data = 12'hf55;
  wire [`RECV_DATA_LENGTH - 1 : 0] slave_recv_data;
  reg [`RECV_DATA_LENGTH - 1 : 0] slave_recv_buff = 0;
  wire slave_recv_data_rdy;
  reg clk = 0;
  wire rst;


  // SPI devices
  spi_slave sl(
    miso, mosi, ss, sck, slave_send_data, slave_recv_data, slave_recv_data_rdy, clk, rst
  );

  assign __fpga_clk = CLK100MHZ;

  assign LED[0] = slave_read_val[0];
  assign LED[1] = slave_read_val[1];
  assign LED[2] = slave_read_val[2];
  assign LED[3] = slave_read_val[3];
  assign LED[4] = slave_read_val[4];
  assign LED[5] = slave_read_val[5];
  assign LED[6] = slave_read_val[6];
  assign LED[7] = slave_read_val[7];

  assign JA[0] = mosi;
  // assign JA[1] = miso;
  assign JA[2] = ss;
  assign JA[3] = sck;
  assign JA[4] = rst;

  assign vauxp6 = JA[0];
  assign vauxp14 = slave_recv_data_rdy;
  assign vauxp7 = JA[2];
  assign vauxp15 = JA[3];

  //
  // Capture SPI rx buffers
  //
  always @ (posedge slave_recv_data_rdy) begin
    slave_read_val <= slave_recv_data[7:0];
  end

  always @ (posedge __fpga_clk) begin
    clk <= ~clk;
  end

endmodule
