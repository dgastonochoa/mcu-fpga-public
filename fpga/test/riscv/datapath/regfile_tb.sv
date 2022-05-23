`timescale 10ps/1ps

`ifndef VCD
    `define VCD "regfile_tb.vcd"
`endif

module regfile_tb;
    reg [4:0] ad1, ad2, ad3;
    reg [31:0] wd3;
    reg we;

    wire [31:0] rd1, rd2;

    reg clk = 0;

    always #10 clk = ~clk;

    regfile rf(ad1, ad2, ad3, wd3, we, rd1, rd2, clk);

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, regfile_tb);

        //
        // Write registers 1 to 4
        //
        ad3 = 32'h01;
        wd3 = 32'h01;
        we = 1;
        #40;

        ad3 = 32'h02;
        wd3 = 32'h02;
        we = 1;
        #40;

        ad3 = 32'h03;
        wd3 = 32'h03;
        we = 1;
        #40;

        ad3 = 32'h04;
        wd3 = 32'h04;
        we = 1;
        #40;

        //
        // Verify the value of the registers 1 to 4
        //
        we = 0;
        ad1 = 1;
        ad2 = 2;
        #1;
        assert(rd1 === 1);
        assert(rd2 === 2);

        we = 0;
        ad1 = 3;
        ad2 = 4;
        #1;
        assert(rd1 === 3);
        assert(rd2 === 4);


        //
        // Verify that zero register cannot be written
        //
        ad3 = 32'h00;
        wd3 = 32'h04;
        we = 1;
        #40;

        //
        // Verify reading the zero register produces 0
        //
        we = 0;
        ad1 = 0;
        ad2 = 0;
        #1;
        assert(rd1 === 0);
        assert(rd2 === 0);

        $finish;
    end

endmodule
