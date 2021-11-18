
module spi_slave
  #(parameter SEND_DATA_LEN = 12, parameter RECV_DATA_LEN = 8)(
  output wire miso,
  input wire mosi,
  input wire ss,
  input wire sck,

  input wire [SEND_DATA_LEN - 1 : 0] send_data,
  output wire [RECV_DATA_LEN - 1 : 0] recv_data,
  output wire recv_data_rdy,
  input wire clk,
  input wire rst
);
  wire psck;
  wire prst;

  pos_edge_det ped(sck, clk, psck);
  pos_edge_det ped_rst(rst, clk, prst);

  // spi_tx #(.DATA_LENGTH(SEND_DATA_LEN)) tx(miso, ss, sck, send_data);

  spi_rx #(.DATA_LENGTH(RECV_DATA_LEN)) rx(mosi, ss, psck,
                                           recv_data, recv_data_rdy, prst);

endmodule
