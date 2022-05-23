`timescale 10ps/1ps

`define WAIT_DELAY 180

`ifndef VCD
    `define VCD "alu_logic_tb.vcd"
`endif

module alu_logic_tb;
    reg signed [31:0] a, b;
    reg signed [1:0] op;

    wire signed [31:0] res;
    wire [3:0] flags;

    alu alu0(a, b, op, res, flags);

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, alu_logic_tb);

        // and 0 works
        op = 2;
        a = 32'hffffffff;
        b = 0;
        #`WAIT_DELAY;
        assert(res === 0);
        assert(flags === 4'b0100);

        // and all ffs works
        op = 2;
        a = 32'hffffffff;
        b = 32'hffffffff;
        #`WAIT_DELAY;
        assert(res === 32'hffffffff);
        assert(flags === 4'b1000);

        // and works (1)
        op = 2;
        a = 32'hffffffff;
        b = 32'b111000;
        #`WAIT_DELAY;
        assert(res === 32'b111000);
        assert(flags === 4'b0000);

        // and works (1)
        op = 2;
        a = 32'b111000;
        b = 32'hffffffff;
        #`WAIT_DELAY;
        assert(res === 32'b111000);
        assert(flags === 4'b0000);



        op = 3;
        a = 32'hffffffff;
        b = 0;
        #`WAIT_DELAY;
        assert(res === 32'hffffffff);
        assert(flags === 4'b1000);

        op = 3;
        a = 32'h0;
        b = 32'b111000;
        #`WAIT_DELAY;
        assert(res === 32'b111000);
        assert(flags === 4'b0000);

        #`WAIT_DELAY;
        $finish;
    end

endmodule
