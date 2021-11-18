module spi_tx
  #(parameter  DATA_LENGTH = 8)(
  output reg tx,
  input wire ss,
  input wire sck,

  input wire [DATA_LENGTH - 1 : 0] data,
  input wire prst,
  input wire clk
);
  localparam [1:0] IDLE = 2'b00, SEND = 2'b01;

  reg [1:0] cs = IDLE;
  reg [DATA_LENGTH - 1 : 0] data_buf = 0;
  reg [3:0] idx = DATA_LENGTH - 1;

  initial begin
    tx <= 0;
  end

  always @(posedge clk or posedge prst) begin
    if (prst) begin
        cs <= IDLE;
        data_buf <= 0;
        idx <= DATA_LENGTH - 1;
        data_buf <= 0;
        tx <= 0;
    end else if (!sck) begin
      case (cs)

      IDLE: begin
        if (!ss) begin
          data_buf <= data;
          tx <= data[idx];
          idx <= idx - 1;
          cs <= SEND;
        end
      end

      SEND: begin
        tx <= data_buf[idx];
        if (idx == 0) begin
          idx <= DATA_LENGTH - 1;
          cs <= IDLE;
        end else begin
          idx <= idx - 1;
        end
      end
      endcase
    end
  end

endmodule