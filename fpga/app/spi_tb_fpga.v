`timescale 1us/100ns

`define SEND_DATA_LENGTH 12
`define RECV_DATA_LENGTH 8

`define EN_WAIT_CYCLES_VAL 100

module spi_tb_fpga(CLK100MHZ, JA, vauxp6, vauxp14, vauxp7, vauxp15, vauxn6, btnC, LED);

  input wire CLK100MHZ; 
  input wire [7:0] JA;
  output wire vauxp6;
  input wire vauxp14;
  output wire vauxp7;
  output wire vauxp15;
  output wire vauxn6;
  input wire btnC;
  output wire [15:0] LED;

  reg clk;
  wire __fpga_clk;

  spi_slave_fpga sl(clk, JA, LED, vauxn6);
  spi_master_fpga sm(clk, vauxp6, vauxp14, vauxp7, vauxp15, LED, btnC, JA[4]);

  assign __fpga_clk = CLK100MHZ;

  // assign vauxp6 = mosi;
  // assign vauxp14 = ss;
  // assign vauxp7 = sck;
  // assign vauxp15 = rst;

  always @ (posedge __fpga_clk) begin
    clk <= ~clk;
  end

endmodule
