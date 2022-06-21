`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`ifndef VCD
    `define VCD "slti_tb.vcd"
`endif

module slti_tb;
    wire reg_we, mem_we;
    res_src_e res_src;
	pc_src_e pc_src;
	alu_src_e alu_src;
    imm_src_e imm_src;
    alu_op_e alu_ctrl;

    wire [31:0] pc, alu_out, wdata;
    wire [31:0] instr, mem_rd_data, mem_wd_data;

    reg clk = 0, rst;

    riscv dut(
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


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, slti_tb);

        dut.dp.rf._reg[4] = 32'b00;

        dut.dp.rf._reg[5] = 32'h08;
        dut.dp.rf._reg[6] = 32'd2;

        dut.dp.rf._reg[7] = 32'hfffffff8;
        dut.dp.rf._reg[8] = 32'd2;

        dut.dp.rf._reg[9] = 32'd2;
        dut.dp.rf._reg[10] = 32'd4;

        dut.instr_mem._mem._mem[0] = 32'h0022a213;   // slti    x4, x5, x6
        dut.instr_mem._mem._mem[1] = 32'h0023a213;   // slti    x4, x7, x8
        dut.instr_mem._mem._mem[2] = 32'h0044a213;   // slti    x4, x9, x10

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        #20 assert(dut.dp.rf._reg[4] === 32'd0);
        #20 assert(dut.dp.rf._reg[4] === 32'd1);
        #20 assert(dut.dp.rf._reg[4] === 32'd1);

        #5;
        $finish;
    end

endmodule
