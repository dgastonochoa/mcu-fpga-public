`define SEND_DATA_LENGTH 12
`define RECV_DATA_LENGTH 8

module spi_master_fpga(clk, vauxp6, vauxp14, vauxp7, vauxp15, LED, btnC, rst);
  input wire clk;
  output wire vauxp6;
  input wire vauxp14;
  output wire vauxp7;
  output wire vauxp15;
  output wire [15:0] LED;
  input wire btnC;
  input wire rst;

  reg [7:0] master_read_val = 0;

  //
  // SPI var. decl.
  //
  wire miso, mosi, ss, sck;

  // master
  reg [`SEND_DATA_LENGTH - 1 : 0] master_send_data = 12'hb55;
  wire [`RECV_DATA_LENGTH - 1 : 0] master_recv_data;
  reg [`RECV_DATA_LENGTH - 1 : 0] master_recv_buff = 0;
  wire master_recv_data_rdy;
  wire busy;

  // SPI devices
  spi_master #(.DEBC_CLKS(100000)) sm(
    mosi, miso, ss, sck, clk, btnC, master_send_data, master_recv_data, busy, master_recv_data_rdy, rst
  );

  assign LED[8] = master_read_val[0];
  assign LED[9] = master_read_val[1];
  assign LED[10] = master_read_val[2];
  assign LED[11] = master_read_val[3];
  assign LED[12] = master_read_val[4];
  assign LED[13] = master_read_val[5];
  assign LED[14] = master_read_val[6];
  assign LED[15] = master_read_val[7];

  assign vauxp6 = mosi;
  assign vauxp14 = miso;
  assign vauxp7 = ss;
  assign vauxp15 = sck;

  //
  // Capture SPI rx buffers
  //
  always @ (posedge master_recv_data_rdy) begin
    master_read_val <= master_recv_data[7:0];
  end

endmodule