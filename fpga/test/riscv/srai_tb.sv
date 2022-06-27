`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`ifndef VCD
    `define VCD "srai_tb.vcd"
`endif

module srai_tb;
    wire reg_we, mem_we;
    res_src_e res_src;
	pc_src_e pc_src;
	alu_src_e alu_src;
    imm_src_e imm_src;
    alu_op_e alu_ctrl;

    wire [31:0] pc, alu_out, wdata;
    wire [31:0] instr, mem_rd_data, mem_wd_data;

    reg clk = 0, rst;

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

    always #10 clk = ~clk;

    //
    // Debug signals
    //
    wire [31:0] pc_plus_4;
    wire [31:0] pc_plus_off;
    wire [31:0] pc_reg_plus_off;
    wire [31:0] pc_next;
    wire [31:0] reg_rd1;
    wire [31:0] reg_rd2;
    wire [31:0] reg_wr_data;
    wire [31:0] alu_srca;
    wire [31:0] alu_srcb;
    wire [31:0] ext_imm;
    wire [31:0] res;
    wire [31:0] i_src, s_src, b_src, j_src, u_src;

    assign pc_plus_4 = dut.rv.dp.pc_plus_4;
    assign pc_plus_off = dut.rv.dp.pc_plus_off;
    assign pc_reg_plus_off = dut.rv.dp.pc_reg_plus_off;
    assign pc_next = dut.rv.dp.pc_next;
    assign reg_rd1 = dut.rv.dp.reg_rd1;
    assign reg_rd2 = dut.rv.dp.reg_rd2;
    assign reg_wr_data = dut.rv.dp.reg_wr_data;
    assign alu_srca = dut.rv.dp.alu_srca;
    assign alu_srcb =  dut.rv.dp.alu_srcb;
    assign ext_imm = dut.rv.dp.ext_imm;
    assign res = dut.rv.dp.rf._reg[1];

    assign i_src = dut.rv.dp.ext.i_src;
    assign s_src = dut.rv.dp.ext.s_src;
    assign b_src = dut.rv.dp.ext.b_src;
    assign j_src = dut.rv.dp.ext.j_src;
    assign u_src = dut.rv.dp.ext.u_src;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, srai_tb);

        dut.rv.dp.rf._reg[4] = 32'b00;
        dut.rv.dp.rf._reg[5] = 32'h08;
        dut.rv.dp.rf._reg[7] = 32'hfffffff8;

        dut.rv.instr_mem._mem._mem[0] = 32'h4022d213;   // srai     x4, x5, 2
        dut.rv.instr_mem._mem._mem[1] = 32'h4023d213;   // srai     x4, x7, 2

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        #20 assert(dut.rv.dp.rf._reg[4] === 32'h02);
        #20 assert(dut.rv.dp.rf._reg[4] === 32'hfffffffe);

        #5;
        $finish;
    end

endmodule
