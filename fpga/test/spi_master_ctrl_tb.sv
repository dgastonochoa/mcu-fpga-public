`timescale 10ps/1ps

`include "test_utils.svh"

`ifndef VCD
    `define VCD "spi_master_ctrl_tb.vcd"
`endif

`define CLK_P 6

module spi_master_ctrl_tb;
    localparam WAIT_CLKS = 8'd4, POL = 1'b1;

    reg clk = 0, rst = 1'b0;

    wire sck, en_sck;

    clk_div #(.POL(POL), .PWIDTH(WAIT_CLKS)) cd0(sck, clk, rst | ~en_sck);

    always #(`CLK_P / 2) clk = ~clk;


    reg en = 1'b0;

    wire ss;

    spi_master_ctrl dut(en, sck, ss, en_sck, rst, clk);


    integer i = 0;


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, spi_master_ctrl_tb);

        //
        // Reset works
        //
        #4  rst = 1;
        #4  rst = 0;
            assert(ss === 1'b1);
            assert(en_sck === 1'b0);


        //
        // Send 1 byte works
        //
        `WAIT_CLKS(clk, 2) en = 1;
        `WAIT_CLKS(clk, 1) en = 0;
                           assert(ss === 1'b0);
                           assert(en_sck === 1'b0);
        `WAIT_CLKS(clk, 1) assert(en_sck === 1'b1);
                           assert(sck === 1'b1);

        i = 0;
        repeat(16) begin
            `WAIT_CLKS(clk, WAIT_CLKS) assert(sck === i);
                                       assert(en_sck === 1'b1);
                                       assert(ss === 1'b0);
                                       i = (i == 0 ? 1 : 0);
        end

        // (*) -1 because one of the WAIT_CLKS cycles has been already waited in
        // the last iteration of the above loop
        `WAIT_CLKS(clk, WAIT_CLKS - 1) assert(ss === 1'b1);
                                       assert(en_sck === 1'b0);

        repeat(8) begin
            `WAIT_CLKS(clk, 1) assert(ss === 1'b1);
                               assert(en_sck === 1'b0);
        end


        //
        // Send 2 consecutive bytes works
        //

        // First byte
        `WAIT_CLKS(clk, 2) en = 1;
        `WAIT_CLKS(clk, 1) assert(ss === 1'b0);
                           assert(en_sck === 1'b0);
        `WAIT_CLKS(clk, 1) assert(en_sck === 1'b1);
                           assert(sck === 1'b1);

        i = 0;
        repeat(16) begin
            `WAIT_CLKS(clk, WAIT_CLKS) assert(sck === i);
                                       assert(en_sck === 1'b1);
                                       assert(ss === 1'b0);
                                       i = (i == 0 ? 1 : 0);
        end

        // See (*) for an explanation of the -1
        `WAIT_CLKS(clk, WAIT_CLKS - 1) assert(ss === 1'b1);
                                       assert(en_sck === 1'b0);

        // Second byte
        `WAIT_CLKS(clk, 1) assert(ss === 1'b0);
                           assert(en_sck === 1'b0);

        `WAIT_CLKS(clk, 1) assert(en_sck === 1'b1);
                           assert(sck === 1'b1);

        i = 0;
        repeat(16) begin
            `WAIT_CLKS(clk, WAIT_CLKS) assert(sck === i);
                                       assert(en_sck === 1'b1);
                                       assert(ss === 1'b0);
                                       i = (i == 0 ? 1 : 0);
        end

        // See (*) for an explanation of the -1
        `WAIT_CLKS(clk, WAIT_CLKS - 1) assert(ss === 1'b1);
                                       assert(en_sck === 1'b0);



        #32 $finish;
    end
endmodule
