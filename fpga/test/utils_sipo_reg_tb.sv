`timescale 10ps/1ps

`ifndef VCD
    `define VCD "utils_sipo_reg_tb.vcd"
`endif

`define CLK_P 6

module utils_sipo_reg_tb;
    localparam WAIT_CLKS = 8'd4, POL = 1'b1;

    reg clk = 0, rst_clk = 1;
    wire sck;

    clk_div #(.POL(POL), .WAIT_CLKS(PWIDTH)) cd0(sck, clk, rst_clk);

    always #(`CLK_P / 2) clk = ~clk;


    reg in_data = 1'b0, rst = 1'b0;

    wire [7:0] out_data;
    wire rdy;

    sipo_reg dut(in_data, out_data, rdy, rst, sck);


    integer i = 0;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, utils_sipo_reg_tb);
        #4  rst = 1;
        #4  rst = 0;
            assert(out_data === 8'b0);
            assert(rdy === 1'b0);

        //
        // read 8 bits after reset works
        //
        #20 rst_clk = 1'b0;
            in_data = 1'b0;
        for (i = 0; i < 8; i = i + 1) begin
            @(negedge sck) in_data = ~in_data;
        end
        @(posedge sck) rst_clk = 1'b1;
        #1  assert(rdy === 1'b1);
            assert(out_data === 8'haa);


        //
        // Verify data is kept if not reset and not clk
        //
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk);
            assert(rdy == 1'b1);
            assert(out_data === 8'haa);
        end


        //
        // read 8 bits works
        //
        #20 rst_clk = 1'b0;
            in_data = 1'b1;
        for (i = 0; i < 8; i = i + 1) begin
            @(negedge sck) in_data = ~in_data;
        end
        @(posedge sck) rst_clk = 1'b1;
        #1  assert(rdy === 1'b1);
            assert(out_data === 8'h55);
        #20;


        //
        // read 8*x bits works
        //
        #20 rst_clk = 1'b0;
            in_data = 1'b1;
        for (i = 0; i < 24; i = i + 1) begin
            @(negedge sck) in_data = ~in_data;
        end
        @(posedge sck) rst_clk = 1'b1;
        #1  assert(rdy === 1'b1);
            assert(out_data === 8'h55);
            rst_clk = 1'b1;
        #20;

        $finish;
    end
endmodule
