`timescale 1ns/100ps

`ifndef VCD
    `define VCD "seven_seg_display_top_tb.vcd"
`endif

module seven_seg_display_top_tb;
    reg clk = 0;

    always #5 clk = ~clk;

    reg btnC = 0;
    reg [15:0] sw = 0;

    wire [15:0] LED;
    wire [7:0] JA;
    wire [6:0] seg;
    wire [3:0] an;

    seven_seg_display_top dut(
        btnC,
        sw,
        LED,
        JA,
        an,
        seg,
        clk
    );

    wire [2:0] __cnt;
    wire [3:0] __anode_en;

    assign __cnt = dut.dut.cnt;
    assign __anode_en = dut.dut.anode_en;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, seven_seg_display_top_tb);

        // Reset
        #5  btnC = 1;
        #20 btnC = 0;

        #100 sw = 16'd03;
        #100 sw = 16'd07;
        #100 sw = 16'd09;
        #100 sw = 16'd014;
        #100 sw = 16'd015;
        #100 sw = 16'hffff;


        #100 $finish;
    end

endmodule
