`timescale 10ps/1ps

`include "errno.svh"
`include "alu.svh"
`include "mem.svh"
`include "riscv/datapath.svh"

`ifndef VCD
    `define VCD "mem_error_tb.vcd"
`endif

module mem_error_tb;
    reg [31:0] addr, wd, addr2_word;
    mem_dt_e dt;
    errno_e err;
    reg we, clk = 0;

    wire [31:0] rd, rd2_word;

    mem m(addr, addr2_word, wd, we, dt, rd, rd2_word, err, clk);

    always #10 clk = ~clk;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, mem_error_tb);

        // Check unaligned word access is detected
        dt = MEM_DT_WORD;
        addr = 1;
        #10 assert(err === EUNACCESS);

        dt = MEM_DT_WORD;
        addr = 2;
        #20 assert(err === EUNACCESS);

        dt = MEM_DT_WORD;
        addr = 3;
        #20 assert(err === EUNACCESS);


        // Check that word aligned access does not produce error
        dt = MEM_DT_WORD;
        addr = 4;
        #20 assert(err === ENONE);


        // Check unaligned half-word access is detected
        dt = MEM_DT_HALF;
        addr = 1;
        #20 assert(err === EUNACCESS);

        dt = MEM_DT_HALF;
        addr = 25;
        #20 assert(err === EUNACCESS);


        // Check that half-word aligned access does not produce error
        dt = MEM_DT_HALF;
        addr = 2;
        #20 assert(err === ENONE);


        // Check that byte access never produces unaligned access error
        dt = MEM_DT_BYTE;
        addr = 0;
        #20 assert(err === ENONE);
        addr = 1;
        #20 assert(err === ENONE);
        addr = 2;
        #20 assert(err === ENONE);
        addr = 3;
        #20 assert(err === ENONE);
        addr = 4;
        #20 assert(err === ENONE);
        addr = 5;
        #20 assert(err === ENONE);

        $finish;
    end

endmodule
