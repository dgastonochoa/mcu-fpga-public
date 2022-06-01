`timescale 10ps/1ps
`include "alu.svh"
`include "riscv/datapath.svh"

`define WAIT_DELAY 180

`ifndef VCD
    `define VCD "alu_cmp_tb.vcd"
`endif

module alu_cmp_tb;
    reg signed [31:0] a, b;
    reg signed [3:0] op;

    wire signed [31:0] res;
    wire [3:0] flags;

    alu alu0(a, b, op, res, flags);

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, alu_cmp_tb);

        // can_do_signed_comparison_a_lt_b
        op = 1;
        a = 32'hffffff03;
        b = 32'h00000002;
        #`WAIT_DELAY;
        assert(flags[3] === 1);
        assert(flags[0] === 0);

        // can_do_signed_comparison_a_ge_b
        op = 1;
        a = 32'h00000002;
        b = 32'hffffff03;
        #`WAIT_DELAY;
        assert(flags[3] === 0);
        assert(flags[0] === 0);

        // can_do_signed_comparison_a_lt_b_with_ov
        // This is the special case in which comparing two
        // signed numbers a and b, begin a less than b, won't cause
        // an ALU's neg flag, but an overflow.
        op = 1;
        a = 32'h80000000;
        b = 32'h00000002;
        #`WAIT_DELAY;
        assert(flags[3] === 0);
        assert(flags[0] === 1);

        // can_do_signed_comparison_a_ge_b_with_ov
        // This is the special case in which comparing two
        // signed numbers a and b, begin a greater than b,
        // won't just cause an ALU's neg flag, but both a
        // neg and an overflow. (because this is like: a - (-b);
        // being b very big, so a + b overflows and goes negative)
        op = 1;
        a = 32'h00000002;
        b = 32'h80000000;
        #`WAIT_DELAY;
        assert(flags[3] === 1);
        assert(flags[0] === 1);


        // can_do_unsigned_comparison_a_lt_b_1
        op = 1;
        a = 32'h00000002;
        b = 32'hffff0000;
        #`WAIT_DELAY;
        assert(flags[1] === 0);
        assert(flags[2] === 0);

        // can_do_unsigned_comparison_a_gt_b_1
        op = 1;
        a = 32'hffff0000;
        b = 32'h00000002;
        #`WAIT_DELAY;
        assert(flags[1] === 1);
        assert(flags[2] === 0);

        // can_do_unsigned_comparison_a_eq_b_1
        op = 1;
        a = 32'hffff0000;
        b = 32'hffff0000;
        #`WAIT_DELAY;
        assert(flags[1] === 1);
        assert(flags[2] === 1);

        $finish;
    end

endmodule
