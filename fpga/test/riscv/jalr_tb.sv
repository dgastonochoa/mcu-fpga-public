`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "jalr_tb.vcd"
`endif

module jalr_tb;
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
        $dumpvars(1, jalr_tb);

        //
        // init. x0 as 0
        //
        `CPU_SET_R(dut, 1, 32'd0);
        `CPU_SET_R(dut, 3, 32'd8);
        `CPU_SET_R(dut, 4, 32'd4);

        `CPU_MEM_SET_W(cm, 0, 32'h004180e7);   // jalr ra, x3, 4
        `CPU_MEM_SET_W(cm, 3, 32'hffc200e7);   // jalr ra, x4, -4

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);
            assert(`CPU_GET_R(dut, 1) === 32'd00);

        `WAIT_CLKS(clk, `R_I_CYC)   assert(pc === 32'd12);
                                    assert(`CPU_GET_R(dut, 1) === 32'd04);

        `WAIT_CLKS(clk, `R_I_CYC)   assert(pc === 32'd00);
                                    assert(`CPU_GET_R(dut, 1) === 32'd16);

        $finish;
    end
endmodule
