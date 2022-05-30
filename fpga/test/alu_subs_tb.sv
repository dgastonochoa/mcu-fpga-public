`timescale 10ps/1ps

`define WAIT_DELAY 180

`ifndef VCD
    `define VCD "alu_sub_tb.vcd"
`endif

module alu_sub_tb;
    reg signed [31:0] a, b;
    reg [3:0] op;

    wire signed [31:0] res;
    wire [3:0] flags;

    alu alu0(a, b, op, res, flags);

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, alu_sub_tb);

        // can subs. two 0
        op = 1;
        a = 0;
        b = 0;
        #`WAIT_DELAY;
        assert(res === 0);
        assert(flags === 4'b0110);

        // can subs. small possitive nums.
        op = 1;
        a = 2;
        b = 3;
        #`WAIT_DELAY;
        assert(res === -1);
        assert(flags === 4'b1000);

        // can subs. negative numbers
        op = 1;
        a = 32'hffffffe0; // -32
        b = 7;
        #`WAIT_DELAY;
        assert(res === -39);
        assert(flags === 4'b1010);

        // can subs. possitive and negative numbers
        op = 1;
        a = 32'h08;
        b = 32'hfffffff9;   // -7
        #`WAIT_DELAY;
        assert(res === 15);
        assert(flags === 4'b0000);

        // can subs. negative + possitive numbers
        op = 1;
        a = 32'hffffffe0; // -32
        b = 33;
        #`WAIT_DELAY;
        assert(res === -65);
        assert(flags === 4'b1010);

        // Overflow is detected
        op = 1;
        a = 32'h80000000 + 10;
        b = 11;
        #`WAIT_DELAY;
        assert(flags === 4'b0011);

        // Zero and cout is detected
        op = 1;
        a = 11;
        b = 11;
        #`WAIT_DELAY;
        assert(flags === 4'b0110);

        // cout is detected
        op = 1;
        a = 32'hffffffff;
        b = 5;
        #`WAIT_DELAY;
        assert(flags === 4'b1010);

        // cout and overflow are detected
        op = 1;
        a = 32'h80000000;
        b = 32'h00000002;
        #`WAIT_DELAY;
        assert(flags === 4'b0011);

        $finish;
    end

endmodule
