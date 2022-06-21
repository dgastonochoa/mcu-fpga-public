`timescale 10ps/1ps

`ifndef VCD
    `define VCD "spi_tests_tb.vcd"
`endif

module spi_tests_tb;
    reg clk = 0;

    always #2 clk = ~clk;


    reg en = 0, rst = 0;
    wire en_sync;

    cell_sync_n #(.N(1)) csn(clk, rst, en, en_sync);


    reg [3:0] sw = 0;
    wire [15:0] leds;

    spi_tests #(.SCK_PWIDTH(4)) dut(en_sync, sw, leds, clk, rst);


    //
    // Debug signals
    //
    wire miso, mosi, ss, sck;
    wire dut_en_sync;

    assign miso = dut.miso;
    assign mosi = dut.mosi;
    assign ss = dut.ss;
    assign sck = dut.sck;
    assign dut_en_sync = dut.en_sync;


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, spi_tests_tb);
        #64 rst = 1;
        #8  rst = 0;

        //
        // sw[2:1] = 00 -> master sends 0xaa, slave 0x55
        //
        #64 en = 1;
        #8  en = 0;
        #512 assert(leds[7:0] === 8'haa);    // sw[0] = 0 -> show master
        #8   sw[0] = 1'b1;
        #1   assert(leds[7:0] === 8'h55);    // sw[0] = 1 -> show slave

        //
        // sw[2:1] = 11 -> master sends 0x55, slave 0xaa
        //
        sw = 3'b110;
        #64 en = 1;
        #8  en = 0;
        #512 assert(leds[7:0] === 8'h55);    // sw[0] = 0 -> show master
        #8   sw[0] = 1'b1;
        #1   assert(leds[7:0] === 8'haa);    // sw[0] = 1 -> show slave

        #64 $finish;
    end
endmodule
