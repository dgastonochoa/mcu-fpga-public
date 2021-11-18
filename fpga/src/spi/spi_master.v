
module spi_master
  #(parameter SEND_DATA_LEN = 12, parameter RECV_DATA_LEN = 8)(
  output wire mosi,
  input wire miso,
  output reg ss,
  output reg sck,

  input wire clk,

  input wire en,
  input wire [SEND_DATA_LEN - 1 : 0] send_data,
  output wire [RECV_DATA_LEN - 1 : 0] recv_data,
  output reg busy,
  output wire recv_data_rdy
);

  localparam WAIT_CLKS = 5;

  reg [5:0] sck_cnt = 5'b11111;
  reg [4:0] timer = 0;
  wire en_pulse;

  spi_tx #(.DATA_LENGTH(SEND_DATA_LEN)) tx(mosi, ss, sck, send_data);

  spi_rx #(.DATA_LENGTH(RECV_DATA_LEN)) rx(miso, ss, sck,
                                           recv_data, recv_data_rdy);

  pos_edge_det ped(en, clk, en_pulse);

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
        sck <= 0;
      end
    end

    if (sck_cnt < SEND_DATA_LEN) begin
      if (timer == 1) begin
        sck <= ~sck;
        timer <= 0;
        if (!sck)
          sck_cnt <= sck_cnt + 1;
      end else begin
        timer <= timer + 1;
      end
    end

    if (sck_cnt == SEND_DATA_LEN) begin
      if (!ss)
        ss <= 1;
      if (busy)
        busy <= 0;
    end
  end
endmodule
