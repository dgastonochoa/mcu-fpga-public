`timescale 10ps/1ps

`ifndef VCD
    `define VCD "spi_master_ctrl_tb.vcd"
`endif

`define CLK_P 6

module spi_master_ctrl_tb;
    localparam WAIT_CLKS = 8'd4, POL = 1'b1;

    reg clk = 0, rst = 1'b0;

    wire sck, en_sck;

    clk_div #(.POL(POL), .WAIT_CLKS(PWIDTH)) cd0(sck, clk, rst | ~en_sck);

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
        // Enable (initialization) sequence works
        //
        @(posedge clk);
        en = 1;
        #4  en = 0;
        @(negedge ss);
        #1  assert(en_sck === 1'b0);
        @(posedge en_sck);
        #1  assert(ss === 1'b0);


        //
        // Disable sequence works
        //
        for (i = 0; i < 8; i = i + 1) begin
            @(posedge sck);
        end
        @(sck, posedge ss, negedge en_sck);
        #1  assert(ss === 1'b1);
            assert(en_sck === 1'b0);


        for (i = 0; i < 24; i = i + 1) begin
            @(posedge clk);
            assert(ss === 1'b1);
            assert(en_sck === 1'b0);
        end


        //
        // Send 8*x bits works
        //
        #4  en = 1;
        @(negedge ss);
        #1  assert(en_sck === 1'b0);
        @(posedge en_sck);
        #1  assert(ss === 1'b0);

        for (i = 0; i < 24; i = i + 1) begin
            @(posedge sck);
        end
        @(posedge clk);
        en = 0;
        #(3*`CLK_P) assert(en_sck === 1'b0);
                    assert(ss === 1'b1);

        for (i = 0; i < 24; i = i + 1) begin
            @(posedge clk);
            assert(en_sck === 1'b0);
            assert(ss === 1'b1);
        end

        #32 $finish;
    end
endmodule
