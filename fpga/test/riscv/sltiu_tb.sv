`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "sltiu_tb.vcd"
`endif

module sltiu_tb;
    reg clk = 0, rst;

    always #10 clk = ~clk;


    wire reg_we, mem_we;
    res_src_e res_src;
    pc_src_e pc_src;
    alu_src_e alu_src;
    imm_src_e imm_src;
    alu_op_e alu_ctrl;

    wire [31:0] pc, alu_out, wdata;
    wire [31:0] instr, mem_rd_data, mem_wd_data;

    riscv_legacy dut(
        reg_we,
        mem_we,
        imm_src,
        alu_ctrl,
        alu_src,
        res_src, pc_src,
        instr,
        alu_out,
        mem_rd_data,
        mem_wd_data,
        pc,
        rst,
        clk
    );

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, sltiu_tb);

        dut.rv.c.dp.rf._reg[4] = 32'b00;
        dut.rv.c.dp.rf._reg[5] = 32'h08;
        dut.rv.c.dp.rf._reg[6] = 32'd2;
        dut.rv.c.dp.rf._reg[7] = 32'hfffffff8;
        dut.rv.c.dp.rf._reg[8] = 32'd2;
        dut.rv.c.dp.rf._reg[9] = 32'd2;
        dut.rv.c.dp.rf._reg[10] = 32'd4;

        `SET_MEM_I(0, 32'h0022b213);   // sltiu    x4, x5, 2
        `SET_MEM_I(1, 32'h0023b213);   // sltiu    x4, x7, 2
        `SET_MEM_I(2, 32'h0044b213);   // sltiu    x4, x9, 4

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        `WAIT_INIT_CYCLES(clk);
        `WAIT_CLKS(clk, `I_I_CYC) assert(dut.rv.c.dp.rf._reg[4] === 32'd0);
        `WAIT_CLKS(clk, `I_I_CYC) assert(dut.rv.c.dp.rf._reg[4] === 32'd0);
        `WAIT_CLKS(clk, `I_I_CYC) assert(dut.rv.c.dp.rf._reg[4] === 32'd1);

        #5;
        $finish;
    end

endmodule
