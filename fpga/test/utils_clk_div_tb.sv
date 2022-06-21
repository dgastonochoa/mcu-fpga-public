`timescale 10ps/1ps

`ifndef VCD
    `define VCD "utils_clk_div_tb.vcd"
`endif

`define CLK_P 6

module utils_clk_div_tb;
    localparam WAIT_CLKS = 8'd4, POL = 1'b1;

    reg clk = 0, rst = 0;
    wire div_clk;

    clk_div #(.POL(POL)) dut(div_clk, WAIT_CLKS, clk, rst);

    always #(`CLK_P / 2) clk = ~clk;


    integer i = 0;


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, utils_clk_div_tb);

        //
        // Stays at POL if rst = 1
        //
        #4      rst = 1;
        #100    assert(div_clk == POL);


        //
        // Waits for WAIT_CLKS pos. edges to start
        //
        rst = 0;
        for (i = 0; i < WAIT_CLKS; i = i + 1) begin
            @(posedge clk);
        end
        #1  assert(div_clk == 1'b0);
        for (i = 0; i < 10; i = i + 1) begin
            @(negedge div_clk);
        end


        //
        // Reset after start works (level low)
        //
        @(negedge div_clk);

        #`CLK_P rst = 1;
        #1      assert(div_clk === 1'b1);

        for (i = 0; i < WAIT_CLKS; i = i + 1) begin
            @(posedge clk) assert(div_clk === 1'b1);
        end


        //
        // Reset after start works (level high)
        //
        #40 rst = 0;
        @(posedge div_clk);

        #`CLK_P rst = 1;
        #1      assert(div_clk === 1'b1);

        for (i = 0; i < WAIT_CLKS; i = i + 1) begin
            @(posedge clk) assert(div_clk === 1'b1);
        end

        #20 $finish;
    end
endmodule
