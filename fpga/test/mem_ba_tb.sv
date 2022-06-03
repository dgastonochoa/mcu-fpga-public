`timescale 10ps/1ps

`include "mem.svh"

`ifndef VCD
    `define VCD "mem_ba_tb.vcd"
`endif

module mem_ba_tb;
    reg [31:0] addr, wd;
    mem_dt_e rdt;
    reg we, clk = 0;

    wire [31:0] rd;

    mem m(addr, wd, we, rd, clk);

    always #10 clk = ~clk;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, mem_ba_tb);

        // write something at addr 0
        rdt = MEM_R_WORD;
        addr = 0;
        wd = 32'habcdef12;
        we = 1;
        #40;

        // check addr 0 contains the expected val.
        rdt = MEM_R_WORD;
        addr = 0;
        wd = 0;
        we = 0;
        #40;
        assert(rd == 32'habcdef12);

        // write something at addr 50
        rdt = MEM_R_WORD;
        addr = 48;
        wd = 32'hdeadc0de;
        we = 1;
        #40;

        // check addr 0 remains unchanged
        rdt = MEM_R_WORD;
        addr = 0;
        wd = 0;
        we = 0;
        #40;
        assert(rd == 32'habcdef12);

        // check addr 50 contains the expected val.
        rdt = MEM_R_WORD;
        addr = 48;
        wd = 0;
        we = 0;
        #40;
        assert(rd == 32'hdeadc0de);

        $finish;
    end

endmodule
