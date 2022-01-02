`timescale 1us/100ns

module double_clk_gen_tb;

    wire clk0;
    wire clk1;

    reg rst = 0;
    reg en = 0;
    reg clk = 0;

    double_clk_gen #(.CLK_DIV(10)) dcg(clk0, clk1, rst, en, clk);

    pullup(clk0);
    pullup(clk1);

    always #2.5 clk <= ~clk;

    initial begin
        $dumpfile("double_clk_gen_tb.vcd");
        $dumpvars(1, double_clk_gen_tb);
        #10 rst <= 1;
        #10 rst <= 0;

        #7.5 en <= 1;
        #500 en <= 0;

        #50 $finish;
    end

    wire [15:0] _cnt;
    assign _cnt = dcg.cnt;
endmodule
