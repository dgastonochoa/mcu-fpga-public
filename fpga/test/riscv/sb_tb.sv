`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv/mem_map.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "sw_tb.vcd"
`endif

module sw_tb;
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
        $dumpvars(1, sw_tb);

        `CPU_SET_R(dut, 2, (`SEC_DATA_W * 4) + 32);
        `CPU_SET_R(dut, 6, 32'hdeadc0de);
        `CPU_SET_R(dut, 7, 32'hdeadbeef);
        `CPU_SET_R(dut, 8, 32'hc001c0de);

        `CPU_MEM_SET_D(cm, `SEC_DATA_W + 5, 32'h00);
        `CPU_MEM_SET_D(cm, `SEC_DATA_W + 10, 32'h00);
        `CPU_MEM_SET_D(cm, `SEC_DATA_W + 11, 32'h00);

        `CPU_MEM_SET_I(cm, 0, 32'hfe610a23);    // sb x6, -12(sp)
        `CPU_MEM_SET_I(cm, 1, 32'h00710423);    // sb x7, 8(sp)
        `CPU_MEM_SET_I(cm, 2, 32'h00810623);    // sb x8, 12(sp)
        `CPU_MEM_SET_I(cm, 3, 32'h00010623);    // sb x0, 12(sp)

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;

`ifdef CONFIG_RISCV_PIPELINE
        `WAIT_CLKS(clk, 3);
`endif
        `WAIT_CLKS(clk, `S_I_CYC) assert(`CPU_MEM_GET_D(cm, `SEC_DATA_W + 5) === 32'h000000de);
        `WAIT_CLKS(clk, `S_I_CYC) assert(`CPU_MEM_GET_D(cm, `SEC_DATA_W + 10) === 32'h000000ef);
        `WAIT_CLKS(clk, `S_I_CYC) assert(`CPU_MEM_GET_D(cm, `SEC_DATA_W + 11) === 32'h000000de);
        `WAIT_CLKS(clk, `S_I_CYC) assert(`CPU_MEM_GET_D(cm, `SEC_DATA_W + 11) === 32'h00000000);

        #5;
        $finish;
    end

endmodule
