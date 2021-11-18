
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
  wire sync_sck;
  wire sync_rst;

  wire psck;
  wire nsck;
  wire prst;

  cell_sync cs1(clk, 1'b0, sck, sync_sck);
  cell_sync cs2(clk, 1'b0, rst, sync_rst);

  pos_edge_det ped_psck(sync_sck, clk, psck);
  neg_edge_det ned_psck(sync_sck, clk, nsck);
  pos_edge_det ped_rst(sync_rst, clk, prst);

  spi_tx #(.DATA_LENGTH(SEND_DATA_LEN)) tx(miso, ss, nsck, send_data, prst, clk);

  spi_rx #(.DATA_LENGTH(RECV_DATA_LEN)) rx(mosi, ss, psck,
                                           recv_data, recv_data_rdy, prst, clk);

endmodule
