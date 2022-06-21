`timescale 10ps/1ps

`include "mem.svh"

`ifndef VCD
    `define VCD "riscv_single_components_test_tb.vcd"
`endif

module riscv_single_components_test_tb;

    wire [15:0] leds;
    reg [3:0] sw = 4'b0;
    reg clk = 0;
    reg rst = 1'bx;

    riscv_single_components_test dut(sw, leds, clk, rst);

    always #1 clk = ~clk;

    wire slow_clk;
    wire [31:0] addr;

    assign slow_clk = dut.slow_clk;
    assign addr = dut.addr;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, riscv_single_components_test_tb);

        //
        // Check leds get the expected values for mem. data
        //
        #2  rst = 1;
        #3  rst = 0;
            assert(leds === 16'haaaa);
        #3  assert(leds === 16'h5555);
        #8  assert(leds === 16'h0180);
        #8  assert(leds === 16'h8001);
        #8  assert(leds === 16'hffff);
        #8  assert(leds === 16'h0000);
        #8  assert(leds === 16'haaaa);
        #8  assert(leds === 16'h5555);


        //
        // Check leds get the expected values for address and
        // error
        //
        #2  rst = 1;
            sw[1] = 1'b1;
        #1  rst = 0;
            assert(leds[7:0] === 16'd00);
            assert(leds[15:8] === 16'b0_0_001_000);

        #3  assert(leds[7:0] === 16'd02);
            assert(leds[15:8] === 16'b0_0_001_000);

        #8  assert(leds[7:0] === 16'd04);
            assert(leds[15:8] === 16'b0_0_001_000);

        #8  assert(leds[7:0] === 16'd06);
            assert(leds[15:8] === 16'b0_0_001_000);

        #8  assert(leds[7:0] === 16'd08);
            assert(leds[15:8] === 16'b0_0_001_000);

        #8  assert(leds[7:0] === 16'd10);
            assert(leds[15:8] === 16'b0_0_001_000);

        #8  assert(leds[7:0] === 16'd00);
            assert(leds[15:8] === 16'b0_0_001_000);

        #8  assert(leds[7:0] === 16'd02);
            assert(leds[15:8] === 16'b0_0_001_000);


        //
        // Check leds get the expected values when stopping
        // the addr. incr.
        //
        #2  rst = 1;
            sw = 4'b0001;
        #3  rst = 0;
            assert(leds === 16'haaaa);
        #3  assert(leds === 16'haaaa);
        #8  assert(leds === 16'haaaa);
        #8  assert(leds === 16'haaaa);

        sw = 4'b0000;
        #8  assert(leds === 16'h5555);
        #8  assert(leds === 16'h0180);


        //
        // Check ALU output
        //
        #2  rst = 1;
            sw = 4'b0100;
        #3  rst = 0;
            assert(leds === 16'd8);
        #3  assert(leds === 16'd2);
        #8  assert(leds === 16'hff);
        #8  assert(leds === 16'h00);
        #8  assert(leds === 16'd8);
        #8  assert(leds === 16'd2);
        #8  assert(leds === 16'hff);
        #8  assert(leds === 16'h00);

        #2  rst = 1;
            sw = 4'b0110;
        #3  rst = 0;
            assert(leds === 16'h0503);
        #3  assert(leds === 16'h0503);
        #8  assert(leds === 16'h0ff0);
        #8  assert(leds === 16'h0ff0);
        #8  assert(leds === 16'h0503);
        #8  assert(leds === 16'h0503);
        #8  assert(leds === 16'h0ff0);
        #8  assert(leds === 16'h0ff0);

        #2  rst = 1;
            sw = 4'b1000;
        #3  rst = 0;
            assert(leds === 16'h0000);
        #3  assert(leds === 16'h1001);
        #8  assert(leds === 16'h3002);
        #8  assert(leds === 16'h2003);
        #8  assert(leds === 16'h0000);
        #8  assert(leds === 16'h1001);
        #8  assert(leds === 16'h3002);
        #8  assert(leds === 16'h2003);


        //
        // Check controller ouput
        //
        #2  rst = 1;
            sw = 4'b1010;
        #3  rst = 0;
            assert(leds === {{3{1'b0}}, 1'b1, 1'b0, ALU_SRC_EXT_IMM, RES_SRC_ALU_OUT, PC_SRC_PLUS_4, IMM_SRC_ITYPE});
        #3  assert(leds === {{3{1'b0}}, 1'b1, 1'b0, ALU_SRC_REG, RES_SRC_ALU_OUT, PC_SRC_PLUS_4, 3'bx});
        #8  assert(leds === {{3{1'b0}}, 1'b1, 1'b0, ALU_SRC_EXT_IMM, RES_SRC_MEM_WORD, PC_SRC_PLUS_4, IMM_SRC_ITYPE});
        #8  assert(leds === {{3{1'b0}}, 1'b1, 1'b0, ALU_SRC_EXT_IMM, RES_SRC_ALU_OUT, PC_SRC_PLUS_4, IMM_SRC_ITYPE});
        #8  assert(leds === {{3{1'b0}}, 1'b1, 1'b0, ALU_SRC_REG, RES_SRC_ALU_OUT, PC_SRC_PLUS_4, 3'bx});
        #8  assert(leds === {{3{1'b0}}, 1'b1, 1'b0, ALU_SRC_EXT_IMM, RES_SRC_MEM_WORD, PC_SRC_PLUS_4, IMM_SRC_ITYPE});


        //
        // Check datapath
        //
        #2  rst = 1;
            sw = 4'b1110;
        #3  rst = 0;
            assert(leds[7:0] === 16'd1);
            assert(leds[15:8] === 16'd0);
        #3  assert(leds[7:0] === 16'd2);
            assert(leds[15:8] === 16'd4);
        #8  assert(leds[7:0] === 16'd3);
            assert(leds[15:8] === 16'd8);
        #8  assert(leds[7:0] === 16'd3);
            assert(leds[15:8] === 16'd12);
        #8  assert(leds[7:0] === 16'd5);
            assert(leds[15:8] === 16'd16);
        #8  assert(leds[7:0] === 16'd4);
            assert(leds[15:8] === 16'd20);
        #8  assert(leds[7:0] === 16'd1);
            assert(leds[15:8] === 16'd24);
        #8  assert(leds[7:0] === 16'd2);
            assert(leds[15:8] === 16'd28);

        #100;
        $finish;
    end
endmodule
