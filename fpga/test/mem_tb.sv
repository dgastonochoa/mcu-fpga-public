`timescale 10ps/1ps
`include "alu.svh"
`include "riscv/datapath.svh"

`ifndef VCD
    `define VCD "mem_tb.vcd"
`endif

module mem_tb;
    reg [31:0] addr, wd;
    reg we, clk = 0;

    wire [31:0] rd;

    mem m(addr, wd, we, rd, clk);

    always #10 clk = ~clk;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, mem_tb);

        // write something at addr 0
        addr = 0;
        wd = 32'habcdef12;
        we = 1;
        #40;

        // check addr 0 contains the expected val.
        addr = 0;
        wd = 0;
        we = 0;
        #40;
        assert(rd == 32'habcdef12);

        // write something at addr 50
        addr = 48;
        wd = 32'hdeadc0de;
        we = 1;
        #40;

        // check addr 0 remains unchanged
        addr = 0;
        wd = 0;
        we = 0;
        #40;
        assert(rd == 32'habcdef12);

        // check addr 50 contains the expected val.
        addr = 48;
        wd = 0;
        we = 0;
        #40;
        assert(rd == 32'hdeadc0de);

        $finish;
    end

endmodule
