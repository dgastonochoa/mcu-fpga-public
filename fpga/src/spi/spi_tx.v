module spi_tx
  #(parameter  DATA_LENGTH = 8)(
  output reg tx,
  input wire ss,
  input wire sck,

  input wire [DATA_LENGTH - 1 : 0] data
);
  localparam [1:0] IDLE = 2'b00, SEND = 2'b01;

  reg [1:0] cs = 0;
  reg [4:0] timer = 0;
  reg [DATA_LENGTH - 1 : 0] data_buf = 0;
  reg [3:0] idx = 0;

  initial begin
    tx <= 0;
  end

  always @(negedge sck) begin
    case (cs)

    IDLE: begin
      if (!ss) begin
        data_buf <= data;
        tx <= data[idx];
        idx <= idx + 1;
        cs <= SEND;
      end
    end

    SEND: begin
      idx <= idx + 1;
      if (idx >= DATA_LENGTH - 1) begin
        idx <= 0;
        cs <= IDLE;
      end else begin
        tx <= data_buf[idx];
      end
    end

    endcase
  end

endmodule