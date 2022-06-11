module spi_rx
  #(parameter  DATA_LENGTH = 8)(
  input wire rx,
  input wire ss,
  input wire sck,

  output reg [DATA_LENGTH - 1 : 0] data,
  output reg data_rdy,
  input wire prst,
  input wire clk
);
  localparam IDLE = 0, RECV = 1, DUMMY_BITS = 2;

  reg [DATA_LENGTH - 1 : 0] buff = 0;
  reg [3:0] idx = DATA_LENGTH - 1;
  reg [3:0] dummy_bits_cnt = 0;
  reg [1:0] cs = IDLE;

  initial begin
    data <= 0;
    data_rdy <= 0;
  end

  always @ (posedge clk or posedge prst) begin
    if (prst) begin
      buff <= 0;
      idx <= DATA_LENGTH - 1;
      dummy_bits_cnt <= 0;
      cs <= IDLE;
      data <= 0;
      data_rdy <= 0;
    end else if (sck) begin
      case (cs)

      IDLE: begin
        if (!ss) begin
          cs <= RECV;
          data_rdy <= 0;
          data <= 0;

          buff[idx] <= rx;
          idx <= idx - 1;

          dummy_bits_cnt <= 0;
        end
      end

      RECV: begin
        buff[idx] <= rx;
        if (idx == 0) begin
          idx <= DATA_LENGTH - 1;
          cs <= DUMMY_BITS;
        end else begin
          idx <= idx - 1;
        end
      end

      DUMMY_BITS: begin
        if (dummy_bits_cnt == 0) begin
          data <= buff;
          buff <= 0;
        end else begin
          if (!data_rdy)
            data_rdy <= 1;
        end

        dummy_bits_cnt <= dummy_bits_cnt + 1;
        if (dummy_bits_cnt == 3) begin
          cs <= IDLE;
        end
      end

      endcase
    end
  end
endmodule
