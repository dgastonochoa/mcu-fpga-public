`timescale 10ps/1ps

`include "errno.svh"
`include "alu.svh"
`include "mem.svh"
`include "riscv/datapath.svh"

`ifndef VCD
    `define VCD "mem_byte_ops_tb.vcd"
`endif

module mem_byte_ops_tb;
    reg [31:0] addr, wd;
    mem_dt_e dt;
    errno_e err;
    reg we, clk = 0;

    wire [31:0] rd;

    mem m(addr, wd, we, dt, rd, err, clk);

    always #10 clk = ~clk;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, mem_byte_ops_tb);


        // check write byte works 1
        m._mem._mem[12] = 32'h12345678;
        dt = MEM_DT_BYTE;
        addr = 48;
        wd = 32'hab;
        we = 1;
        #40 assert(m._mem._mem[12] === 32'h123456ab);


        // check write byte works 2
        m._mem._mem[12] = 32'h12345678;
        dt = MEM_DT_BYTE;
        addr = 49;
        wd = 32'hab;
        we = 1;
        #40 assert(m._mem._mem[12] === 32'h1234ab78);


        // check write byte works 3
        m._mem._mem[12] = 32'h12345678;
        dt = MEM_DT_BYTE;
        addr = 50;
        wd = 32'hab;
        we = 1;
        #40 assert(m._mem._mem[12] === 32'h12ab5678);


        // check write byte works 4
        m._mem._mem[12] = 32'h12345678;
        dt = MEM_DT_BYTE;
        addr = 51;
        wd = 32'hab;
        we = 1;
        #40 assert(m._mem._mem[12] === 32'hab345678);


        // check write read byte works 1
        m._mem._mem[12] = 32'h12345678;
        dt = MEM_DT_BYTE;
        addr = 48;
        we = 0;
        #40 assert(rd === 32'h78);


        // check write read byte works 2
        m._mem._mem[12] = 32'h12345678;
        dt = MEM_DT_BYTE;
        addr = 49;
        we = 0;
        #40 assert(rd === 32'h56);


        // check write read byte works 3
        m._mem._mem[12] = 32'h12345678;
        dt = MEM_DT_BYTE;
        addr = 50;
        we = 0;
        #40 assert(rd === 32'h34);


        // check write read byte works 4
        m._mem._mem[12] = 32'h12345678;
        dt = MEM_DT_BYTE;
        addr = 51;
        we = 0;
        #40 assert(rd === 32'h12);

        $finish;
    end

endmodule
