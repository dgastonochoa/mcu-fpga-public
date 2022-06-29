/**
 * 2 to 4 decoder.
 *
 */
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
    input  wire [N-1:0] d,
    input  wire         en,
    output reg  [N-1:0] q,
    input  wire         rst,
    input  wire         clk
);
    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            q <= 32'b0;
        else if (en == 1'b1)
            q <= d;
    end
endmodule

/**
 * Clock divider.
 *
 * @param div_clk Divided clock signal
 * @param clk Clock
 * @param rst Reset
 *
 * @tparam POL Polarity (@param{clk} value when in reset state)
 * @tparam PWIDTH @param{div_clk} pulse width in @param{clk} pulses.
 *
 */
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

/**
 * Synchronizer.
 *
 * @param clk Clock against which the input signal/s will be sync.
 * @param rst Reset
 * @param in_p Input async. signal/s
 * @param out_p Output sync. signal/s
 *
 * @tparam N Number of signals to sync.
 */
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
 * @param rdy 1 if @param{out_data} contains data to read, 0 otherwise. This
 *            parameter and @param{out_data} change at the same time, so it's
 *            necessary to wait 'some time' after @param{rdy} is driven high
 *            to be able to read @param{out_data} safely.
 *
 * @param rst Reset
 * @param clk Clock signal
 *
 * @todo Determine how much time is required to wait after @param{rdy} is driven
 *       high to read @param{out_data} safely.
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

/**
 * Parallel-in serial-out register. Polarity 0 (it shifts data on the negative
 * edge of @param{clk}). It keeps shifting data as long as the clock keeps
 * changing.
 *
 * @param in_data Parallel data to shift
 * @param out_data Shifted serial data
 * @param busy 1 if busy sending data, 0 otherwise.
 * @param rst Reset
 * @param clk Clock
 *
 */
module piso_reg(
    input   wire [7:0]  in_data,
    output  reg         out_data,
    output  reg         busy,
    input   wire        rst,
    input   wire        clk
);
    //
    // Buff and counter logic
    //
    reg [3:0] i;

    always @(negedge clk, posedge rst) begin
        if (rst) begin
            i <= 0;
            buff <= 0;
        end else begin
            if (i == 8'd0)
                buff <= in_data;

            i <= (i == 8'd0) ? 8'd7 : i - 1;
        end
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

    always_comb begin
        case (cs)
        IDLE:   {busy, out_data} = 2'b0;
        START:  {busy, out_data} = {1'b1, msb};
        SEND:   {busy, out_data} = {1'b1, cb};
        FINISH: {busy, out_data} = {1'b0, cb};
        endcase
    end
endmodule

/**
 * Clock dege counter. Counts 8 positive edges.
 *
 * @param s 1 every 8*x clock pos. edge is reached, 0 otherwise.
 * @param clk Clock
 * @param rst Reset
 *
 * @todo Rename this to something clearer.
 */
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
