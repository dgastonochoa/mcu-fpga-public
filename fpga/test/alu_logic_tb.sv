`timescale 10ps/1ps
`include "alu.svh"
`define WAIT_DELAY 180

`ifndef VCD
    `define VCD "alu_logic_tb.vcd"
`endif

module alu_logic_tb;
    reg signed [31:0] a, b;
    reg [3:0] op;

    wire signed [31:0] res;
    wire [3:0] flags;

    alu alu0(a, b, op, res, flags);

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, alu_logic_tb);

        //
        // and
        //
        // x_and_0_works
        op = 2;
        a = 32'hffffffff;
        b = 0;
        #`WAIT_DELAY;
        assert(res === 0);
        assert(flags === 4'b0100);

        // and_cannot_enable_ov_flag_1
        op = 2;
        a = 32'hffffffff;
        b = 32'hffffffff;
        #`WAIT_DELAY;
        assert(res === 32'hffffffff);
        assert(flags === 4'b1000);

        // and_cannot_enable_ov_flag_2
        op = 2;
        a = 32'hffffffff;
        b = 32'h7fffffff;
        #`WAIT_DELAY;
        assert(res === 32'h7fffffff);
        assert(flags === 4'b0000);

        // and_works_1
        op = 2;
        a = 32'hffffffff;
        b = 32'b111000;
        #`WAIT_DELAY;
        assert(res === 32'b111000);
        assert(flags === 4'b0000);

        // and_works_2
        op = 2;
        a = 32'b111000;
        b = 32'hffffffff;
        #`WAIT_DELAY;
        assert(res === 32'b111000);
        assert(flags === 4'b0000);


        //
        // or
        //
        // or_works_1
        op = 3;
        a = 32'hffffffff;
        b = 0;
        #`WAIT_DELAY;
        assert(res === 32'hffffffff);
        assert(flags === 4'b1000);

        // or_works_2
        op = 3;
        a = 32'h0;
        b = 32'b111000;
        #`WAIT_DELAY;
        assert(res === 32'b111000);
        assert(flags === 4'b0000);

        // or_cannot_en_ov_flag_1
        op = 3;
        a = 32'hffffffff;
        b = 32'hffffffff;
        #`WAIT_DELAY;
        assert(res === 32'hffffffff);
        assert(flags === 4'b1000);

        // or_cannot_en_ov_flag_2
        op = 3;
        a = 32'hffffffff;
        b = 32'h7fffffff;
        #`WAIT_DELAY;
        assert(res === 32'hffffffff);
        assert(flags === 4'b1000);


        //
        // xor
        //
        // xor_cannot_en_ov_flag_1
        op = 4;
        a = 32'hffffffff;
        b = 32'hffffffff;
        #`WAIT_DELAY;
        assert(res === 32'h00);
        assert(flags === 4'b0100);

        // xor_cannot_en_ov_flag_2
        op = 4;
        a = 32'hffffffff;
        b = 32'h7fffffff;
        #`WAIT_DELAY;
        assert(res === 32'h80000000);
        assert(flags === 4'b1000);

        // xor_works_1
        op = 4;
        a = 32'b010101;
        b = 32'b101010;
        #`WAIT_DELAY;
        assert(res === 32'b111111);
        assert(flags === 4'b0000);

        // xor_works_2
        op = 4;
        a = 32'b111111;
        b = 32'b101010;
        #`WAIT_DELAY;
        assert(res === 32'b010101);
        assert(flags === 4'b0000);


        //
        // sll
        //
        // sll_cannot_en_ov_flag_1
        op = 5;
        a = 32'hffffffff;
        b = 32'hffffffff;
        #`WAIT_DELAY;
        assert(res === 32'h00);
        assert(flags === 4'b0100);

        // sll_cannot_en_ov_flag_2
        op = 5;
        a = 32'hffffffff;
        b = 32'h7fffffff;
        #`WAIT_DELAY;
        assert(res === 32'h00000000);
        assert(flags === 4'b0100);

        // sll_works_1
        op = 5;
        a = 32'b00001111;
        b = 32'd4;
        #`WAIT_DELAY;
        assert(res === 32'b11110000);
        assert(flags === 4'b0000);

        // sll_works_2
        op = 5;
        a = 32'b00001111;
        b = 32'd31;
        #`WAIT_DELAY;
        assert(res === 32'h80000000);
        assert(flags === 4'b1000);

        // sll_can_enable_zero
        op = 5;
        a = 32'b00001111;
        b = 32'd32;
        #`WAIT_DELAY;
        assert(res === 32'b00);
        assert(flags === 4'b0100);


        //
        // srl
        //
        // srl_works_1
        op = 6;
        a = 32'b00001111;
        b = 32'd3;
        #`WAIT_DELAY;
        assert(res === 32'd1);
        assert(flags === 4'b0000);

        // srl_can_enable_zero
        op = 6;
        a = 32'd1;
        b = 32'd1;
        #`WAIT_DELAY;
        assert(res === 32'd0);
        assert(flags === 4'b0100);

        #`WAIT_DELAY;
        $finish;
    end

endmodule
