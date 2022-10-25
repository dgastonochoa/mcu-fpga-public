`timescale 10ps/1ps

`include "errno.svh"
`include "alu.svh"
`include "mem.svh"
`include "riscv/datapath.svh"

`ifndef VCD
    `define VCD "mem_halfw_ops_tb.vcd"
`endif

module mem_halfw_ops_tb;
    reg [31:0] addr, wd, addr2_word;
    mem_dt_e dt;
    errno_e err;
    reg we, clk = 0;

    wire [31:0] rd, rd2_word;

    mem m(addr, addr2_word, wd, we, dt, rd, rd2_word, err, clk);

    always #10 clk = ~clk;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, mem_halfw_ops_tb);

        // check write half word works 1
        m._mem._mem[12] = 32'h12345678;
        dt = MEM_DT_HALF;
        addr = 48;
        wd = 32'hdead;
        we = 1;
        #40 assert(m._mem._mem[12] === 32'h1234dead);


        // check write half word unsigned works 1
        m._mem._mem[12] = 32'h12345678;
        dt = MEM_DT_HALF;
        addr = 50;
        wd = 32'hdead;
        we = 1;
        #40 assert(m._mem._mem[12] === 32'hdead5678);


        // check read half word works 1
        m._mem._mem[12] = 32'h82848688;
        dt = MEM_DT_UHALF;
        addr = 48;
        we = 0;
        #40 assert(rd === 32'h00008688);


        // check read half word unsigned works 2
        m._mem._mem[12] = 32'h82848688;
        dt = MEM_DT_UHALF;
        addr = 50;
        we = 0;
        #40 assert(rd === 32'h00008284);


        // check read half word signed works 1
        m._mem._mem[12] = 32'h82848688;
        dt = MEM_DT_HALF;
        addr = 48;
        we = 0;
        #40 assert(rd === 32'hffff8688);


        // check read half word signed works 2
        m._mem._mem[12] = 32'h82848688;
        dt = MEM_DT_HALF;
        addr = 50;
        we = 0;
        #40 assert(rd === 32'hffff8284);

        $finish;
    end

endmodule
