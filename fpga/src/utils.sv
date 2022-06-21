module dec(
    input   wire    [1:0] d,
    output  logic   [3:0] q
);
    always_comb begin
        case (d)
        2'b00: q = 4'b0001;
        2'b01: q = 4'b0010;
        2'b10: q = 4'b0100;
        2'b11: q = 4'b1000;
        endcase
    end
endmodule

/**
 * D flip-flop
 *
 */
module dff #(parameter N = 32) (
    input wire [N-1:0] d,
    output reg [N-1:0] q,
    input wire rst,
    input wire clk
);
    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            q <= 32'b0;
        else
            q <= d;
    end
endmodule

module clk_div #(parameter POL = 1'd0, parameter PWIDTH = 8'd4) (
    output  reg         div_clk,
    input   wire        clk,
    input   wire        rst
);
    reg [31:0] timer;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            div_clk <= POL;
            timer <= 0;
        end else begin
            if (timer < (PWIDTH - 1)) begin
                timer <= timer + 1;
            end else begin
                timer <= 0;
                div_clk = ~div_clk;
            end
        end
    end
endmodule

module cell_sync_n #(parameter N = 8) (
    input wire  clk,
    input wire  rst,
    input wire  [(N-1):0] in_p,
    output wire [(N-1):0] out_p
);
    reg [(N-1):0] in_meta;
    reg [(N-1):0] in_sync;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            in_meta <= 0;
            in_sync <= 0;
        end else begin
            in_meta <= in_p;
            in_sync <= in_meta;
        end
    end

    assign out_p = in_sync;

endmodule

/**
 * Serial-in parallel-out register.
 *
 * @param in_data Serial input data
 * @param out_data Parallel output data
 *
 * @param rdy 1 if @param{out_data} contains data to read,
 *            0 otherwise.
 *
 * @param rst Reset
 * @param clk Clock signal
 */
module sipo_reg(
    input   wire        in_data,
    output  wire [7:0]  out_data,
    output  wire        rdy,
    input   wire        rst,
    input   wire        clk
);
    reg [7:0] buff;
    reg [2:0] i;
    reg was_enabled;


    always @(posedge clk, posedge rst) begin
        if (rst) begin
            buff <= 0;
            i <= 7;
            was_enabled <= 0;
        end else begin
            was_enabled <= 1;
            buff[i] <= in_data;
            i <= i == 3'd0 ? 3'd7 : (i - 3'd1);
        end
    end

    assign rdy = (i == 3'd7) & was_enabled;
    assign out_data = {8{rdy}} & buff;
endmodule

module piso_reg(
    input   wire [7:0]  in_data,
    output  reg         out_data,
    output  reg         busy,
    input   wire        rst,
    input   wire        clk
);
    //
    // Counter logic
    //
    reg [3:0] i;

    always @(negedge clk, posedge rst) begin
        if (rst)
            i <= 0;
        else
            i <= (i == 0) ? 7 : i - 1;
    end


    //
    // Next state logic
    //
    typedef enum reg [1:0] {IDLE, START, SEND, FINISH} state_e;

    state_e cs;

    always @(negedge clk, posedge rst) begin
        if (rst)
            cs <= IDLE;
        else
            case (cs)
            IDLE:   cs <= START;
            START:  cs <= SEND;
            SEND:   cs <= (i == 1 ? FINISH : SEND);
            FINISH: cs <= START;
            endcase
    end


    //
    // Outputs logic
    //
    reg [7:0] buff;
    wire msb, cb;

    assign msb = in_data[7];
    assign cb = buff[i];

    // TODO always_comb must assign all variables all the time
    // or latches are generated.
    always_comb begin
        case (cs)
        IDLE:   {buff, busy, out_data} = 10'b0;
        START:  {buff, busy, out_data} = {in_data, 1'b1, msb};
        SEND:   {busy, out_data} = {1'b1, cb};
        FINISH: {out_data, busy} = {cb, 1'b0};
        endcase
    end

endmodule

module cnt16(
    output wire s,
    input  wire clk,
    input  wire rst
);
    reg [7:0] cnt;

    always @(posedge clk, posedge rst) begin
        if (rst)
            cnt <= 8'd0;
        else
            cnt <= (cnt == 8'd8 ? 8'd1 : cnt + 8'd1);
    end

    assign s = cnt == 8'd8;
endmodule
