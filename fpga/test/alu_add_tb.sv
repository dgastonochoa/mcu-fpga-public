`timescale 10ps/1ps
`include "alu.svh"
`include "riscv/datapath.svh"

`define WAIT_DELAY 180

`ifndef VCD
    `define VCD "alu_tb.vcd"
`endif

module alu_tb;
    reg signed [31:0] a, b;
    reg [3:0] op;

    wire signed [31:0] res;
    wire [3:0] flags;

    alu alu0(a, b, op, res, flags);

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, alu_tb);

        //
        // Addition
        //
        // can add two 0
        op = 0;
        a = 0;
        b = 0;
        #`WAIT_DELAY;
        assert(res === 0);
        assert(flags === 4'b0100);

        // can add small possitive nums.
        op = 0;
        a = 2;
        b = 3;
        #`WAIT_DELAY;
        assert(res === 5);
        assert(flags === 4'b0000);

        // can add negative numbers
        op = 0;
        a = 32'hffffffe0; // -32
        b = 32'hfffffff9; // -7
        #`WAIT_DELAY;
        assert(res === -39);
        assert(flags === 4'b1010);

        // can add possitive and negative numbers
        op = 0;
        a = 32'h08;
        b = 32'hfffffff9;   // -7
        #`WAIT_DELAY;
        assert(res === 1);
        assert(flags === 4'b0010);

        // can add negative + possitive numbers
        op = 0;
        a = 32'hffffffe0; // -32
        b = 33;
        #`WAIT_DELAY;
        assert(res === 1);
        assert(flags === 4'b0010);

        // Overflow is detected
        op = 0;
        a = 32'h7fffffff - 10;
        b = 11;
        #`WAIT_DELAY;
        assert(flags === 4'b1001);

        // Zero and cout is detected
        op = 0;
        a = 11;
        b = -11;
        #`WAIT_DELAY;
        assert(flags === 4'b0110);

        // cout is detected
        op = 0;
        a = 32'hffffffff;
        b = 5;
        #`WAIT_DELAY;
        assert(flags === 4'b0010);

        // cout is detected
        op = 0;
        a = 20;
        b = -25;
        #`WAIT_DELAY;
        assert(flags === 4'b1000);

        $finish;
    end

endmodule
