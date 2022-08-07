`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "sltu_tb.vcd"
`endif

module sltu_tb;
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
        $dumpvars(1, sltu_tb);

        dut.rv.dp.rf._reg[4] = 32'b00;
        dut.rv.dp.rf._reg[5] = 32'h08;
        dut.rv.dp.rf._reg[6] = 32'd2;
        dut.rv.dp.rf._reg[7] = 32'hfffffff8;
        dut.rv.dp.rf._reg[8] = 32'd2;
        dut.rv.dp.rf._reg[9] = 32'd2;
        dut.rv.dp.rf._reg[10] = 32'd4;

        `SET_MEM_I(0, 32'h0062b233); // sltu   x4, x5, x6
        `SET_MEM_I(1, 32'h0083b233); // sltu   x4, x7, x8
        `SET_MEM_I(2, 32'h00a4b233); // sltu   x4, x9, x10

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        `WAIT_INIT_CYCLES(clk);
        `WAIT_CLKS(clk, `R_I_CYC) assert(dut.rv.dp.rf._reg[4] === 32'd0);
        `WAIT_CLKS(clk, `R_I_CYC) assert(dut.rv.dp.rf._reg[4] === 32'd0);
        `WAIT_CLKS(clk, `R_I_CYC) assert(dut.rv.dp.rf._reg[4] === 32'd1);

        #5;
        $finish;
    end

endmodule
