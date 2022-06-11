
module spi_master
  #(parameter SEND_DATA_LEN = 12, parameter RECV_DATA_LEN = 8, parameter DEBC_CLKS = 1)(
  output wire mosi,
  input wire miso,
  output reg ss,
  output reg sck,

  input wire clk,

  input wire en,
  input wire [SEND_DATA_LEN - 1 : 0] send_data,
  output wire [RECV_DATA_LEN - 1 : 0] recv_data,
  output reg busy,
  output wire recv_data_rdy,
  input wire rst
);
  localparam WAIT_CLKS = 24;

  reg [5:0] sck_cnt = 5'b11111;
  reg [4:0] timer = 0;
  wire en_pulse;

  wire sync_sck;
  wire sync_rst;
  wire sync_en;
  wire debc_en;
  wire psck;
  wire nsck;
  wire prst;

  debounce_filter #(.WAIT_CLK(DEBC_CLKS)) df(en, clk, debc_en);

  cell_sync cs1(clk, 1'b0, sck, sync_sck);
  cell_sync cs2(clk, 1'b0, rst, sync_rst);
  cell_sync cs3(clk, 1'b0, debc_en, sync_en);

  pos_edge_det ped_psck(sync_sck, clk, psck);
  neg_edge_det ned_psck(sync_sck, clk, nsck);
  pos_edge_det ped_rst(sync_rst, clk, prst);
  pos_edge_det ped(sync_en, clk, en_pulse);

  spi_tx #(.DATA_LENGTH(SEND_DATA_LEN)) tx(mosi, ss, nsck, send_data, prst, clk);

  spi_rx #(.DATA_LENGTH(RECV_DATA_LEN)) rx(miso, ss, psck,
                                           recv_data, recv_data_rdy, prst, clk);


  initial begin
    ss <= 1;
    busy <= 0;
    sck <= 1;
  end

  always @ (posedge clk) begin
    if (en_pulse && !busy) begin
      if (ss) begin
        sck_cnt <= 0;
        ss <= 0;
        busy <= 1;
      end
    end

    if (sck_cnt < SEND_DATA_LEN) begin
      if (timer == WAIT_CLKS) begin
        sck <= ~sck;
        timer <= 0;
        if (!sck)
          sck_cnt <= sck_cnt + 1;
      end else begin
        timer <= timer + 1;
      end
    end

    if (sck_cnt == SEND_DATA_LEN) begin
      if (timer == WAIT_CLKS) begin
        if (!ss)
          ss <= 1;
        if (busy)
          busy <= 0;
      end else begin
        timer <= timer + 1;
      end
    end
  end
endmodule
