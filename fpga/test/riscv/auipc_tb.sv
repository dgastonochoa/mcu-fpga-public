`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "auipc_tb.vcd"
`endif

module auipc_tb;
    reg clk = 0, rst;

    always #10 clk = ~clk;


    wire [31:0] instr, d_rd, d_addr, d_wd, pc;
    wire d_we;
    mem_dt_e d_dt;

    cpu dut(instr, d_rd, d_addr, d_we, d_wd, d_dt, pc, rst, clk);


    errno_e  err;

    cpu_mem cm(
        pc, d_addr, d_wd, d_we, d_dt, instr, d_rd, err, clk);

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, auipc_tb);

        `CPU_SET_R(dut, 0, 32'd00);
        `CPU_SET_R(dut, 1, 32'd12);

        `CPU_MEM_SET_I(cm, 0, 32'h00014097);   // auipc   x1, 20
        `CPU_MEM_SET_I(cm, 1, 32'h00014097);   // auipc   x1, 20

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        assert(pc === 32'd0);
        `WAIT_INIT_CYCLES(clk);
        `WAIT_CLKS(clk, `I_I_CYC) assert(`CPU_GET_R(dut, 1) === (32'd20 << 12));
        `WAIT_CLKS(clk, `I_I_CYC) assert(`CPU_GET_R(dut, 1) === (32'd20 << 12) + 4);

        #5;
        $finish;
    end

endmodule
