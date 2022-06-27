`timescale 1us/100ns

`define SEND_DATA_LENGTH 12
`define RECV_DATA_LENGTH 8

module spi_slave_fpga(clk, JA, LED, vauxn6);

  input wire clk; 
  input wire [7:0] JA;
  output wire [15:0] LED;
  output wire vauxn6;

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
  wire rst;

  // SPI devices
  spi_slave sl(
    miso, mosi, ss, sck, slave_send_data, slave_recv_data, slave_recv_data_rdy, clk, rst
  );

  assign LED[0] = slave_read_val[0];
  assign LED[1] = slave_read_val[1];
  assign LED[2] = slave_read_val[2];
  assign LED[3] = slave_read_val[3];
  assign LED[4] = slave_read_val[4];
  assign LED[5] = slave_read_val[5];
  assign LED[6] = slave_read_val[6];
  assign LED[7] = slave_read_val[7];

  assign mosi = JA[0];
  assign miso = vauxn6; 
  assign ss = JA[2];
  assign sck = JA[3];
  assign rst = JA[4];

  //
  // Capture SPI rx buffers
  //
  always @ (posedge slave_recv_data_rdy) begin
    slave_read_val <= slave_recv_data[7:0];
  end

endmodule
