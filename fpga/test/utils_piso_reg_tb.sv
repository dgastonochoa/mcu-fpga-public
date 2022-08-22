`timescale 10ps/1ps

`ifndef VCD
    `define VCD "utils_piso_reg_tb.vcd"
`endif

`define CLK_P 6

module utils_piso_reg_tb;

    localparam WAIT_CLKS = 8'd4, POL = 1'b1;

    reg clk = 0, rst_clk = 1;
    wire sck;

    clk_div #(.POL(POL), .PWIDTH(WAIT_CLKS)) cd0(sck, clk, rst_clk);

    always #(`CLK_P / 2) clk = ~clk;


    reg [7:0] in_data = 0;
    reg rst = 0;

    wire out_data, busy;

    piso_reg dut(in_data, out_data, busy, rst, sck);


    reg [7:0] rd = 0;
    reg [23:0] rd_big = 0;

    integer i = 0;


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, utils_piso_reg_tb);

        #4  rst = 1;
        #4  rst = 0;
            in_data = 8'haa;

        //
        // 8 bit parallel to serial works
        //
        #80 rst_clk = 0;
        for (i = 7; i >= 0; i = i - 1) begin
            @(posedge sck) rd[i] = out_data;
        end
        #1  assert(rd === 8'haa);
            assert(busy === 1'b0);
            rst_clk = 1;


        //
        // Check busy still 0 after a long time without
        // enabling
        //
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk) assert(busy === 1'b0);
        end


        //
        // Check send same sequence several times nonstop
        // works
        //
        in_data = 8'h55;
        rst_clk = 0;
        for (i= 23; i >= 0; i = i - 1) begin
            @(posedge sck) rd_big[i] = out_data;
        end
        #1  assert(rd_big === 24'h555555);
            assert(busy === 1'b0);
            rst_clk = 1;

        #32 $finish;
    end
endmodule
