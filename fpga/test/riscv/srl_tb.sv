`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "srl_tb.vcd"
`endif

module srl_tb;
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

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, srl_tb);

        dut.rv.dp.rf._reg[0] = 32'd00;
        dut.rv.dp.rf._reg[4] = 32'b00;
        dut.rv.dp.rf._reg[5] = 32'hf0;
        dut.rv.dp.rf._reg[6] = 32'd4;

        `MEM_INSTR[`INSTR_START_ADDR + 0] = 32'h00525033;   // srl x0, x4, x5
        `MEM_INSTR[`INSTR_START_ADDR + 1] = 32'h0062d233;   // srl x4, x5, x6
        `MEM_INSTR[`INSTR_START_ADDR + 2] = 32'h00625233;   // srl x4, x4, x6

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        `WAIT_INSTR(clk) assert(dut.rv.dp.rf._reg[0] === 32'h00);
        `WAIT_INSTR(clk) assert(dut.rv.dp.rf._reg[4] === 32'h0f);
        `WAIT_INSTR(clk) assert(dut.rv.dp.rf._reg[4] === 32'b0);

        #5;
        $finish;
    end

endmodule
