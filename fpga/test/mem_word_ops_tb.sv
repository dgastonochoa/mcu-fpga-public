`timescale 10ps/1ps

`include "errno.svh"
`include "alu.svh"
`include "mem.svh"
`include "riscv/datapath.svh"

`ifndef VCD
    `define VCD "mem_word_ops_tb.vcd"
`endif

module mem_word_ops_tb;
    reg [31:0] addr, wd, addr2_word;
    mem_dt_e dt;
    errno_e err;
    reg we, clk = 0;

    wire [31:0] rd, rd2_word;

    mem m(addr, addr2_word, wd, we, dt, rd, rd2_word, err, clk);

    always #10 clk = ~clk;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, mem_word_ops_tb);

        // Check write word works 1
        dt = MEM_DT_WORD;
        addr = 0;
        wd = 32'habcdef12;
        we = 1;
        #40 assert(m._mem._mem[0] === 32'habcdef12);


        // Check write word works 2
        dt = MEM_DT_WORD;
        addr = 12;
        wd = 32'h12abcd34;
        we = 1;
        #40 assert(m._mem._mem[3] === 32'h12abcd34);


        // Check read word works 1
        dt = MEM_DT_WORD;
        addr = 0;
        we = 0;
        #40 assert(rd === 32'habcdef12);


        // Check read word works 2
        dt = MEM_DT_WORD;
        addr = 12;
        we = 0;
        #40 assert(rd === 32'h12abcd34);

        $finish;
    end

endmodule
