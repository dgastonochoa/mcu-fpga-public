`timescale 1ns/100ps

`define TEST_MASTER_READ

module i2c_app_tb;

    reg CLK100MHZ = 0;
    reg btnC = 0;
    reg btnU = 0;
    reg [15:0] sw = 0;

    wire [7:0] JA;
    wire [15:0] LED;

    i2c_app ia(CLK100MHZ, JA, LED, btnC, btnU, sw);

    always #5 CLK100MHZ <= ~CLK100MHZ;

    initial begin
        $dumpfile("i2c_app_tb.vcd");
        $dumpvars(1, i2c_app_tb);

                btnU <= 1;
        #1000   btnU <= 0;

`ifdef TEST_MASTER_READ
        sw[0] <= 1; // read op.
        sw[3] <= 1; // display master read in leds
`endif

        #1000   btnC <= 1;
        #1000   btnC <= 0;
        #500000;

        // is_slave_1
        sw[1] <= 1;
        #1000   btnC <= 1;
        #1000   btnC <= 0;
        #500000;

        // is_slave_1
        sw[1] <= 0;
        #1000   btnC <= 1;
        #1000   btnC <= 0;
        #500000;

        sw[2] <= 1;
        #2000;

        sw[2] <= 0;
        #2000;

        $finish;
    end

endmodule
