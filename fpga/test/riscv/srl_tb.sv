`timescale 10ps/1ps

`include "alu.vh"
`include "riscv/datapath.vh"

`ifndef VCD
    `define VCD "srl_tb.vcd"
`endif

module srl_tb;
    wire reg_we, mem_we, alu_src, pc_src;
    wire [1:0] imm_src, res_src;
    wire [2:0] alu_ctrl;

    wire [31:0] pc, alu_out, wdata;
    wire [31:0] instr, mem_rd_data, mem_wd_data;

    reg clk = 0, rst;

    riscv_single_top dut(
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
    wire [31:0] alu_a, alu_b;
    assign alu_a = dut.dp.srca;
    assign alu_b = dut.dp.srcb;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, srl_tb);

        dut.dp.rf._reg[0] = 32'd00;
        dut.dp.rf._reg[4] = 32'b00;
        dut.dp.rf._reg[5] = 32'hf0;
        dut.dp.rf._reg[6] = 32'd4;

        dut.instr_mem._mem[0] = 32'h00525033;   // srl     x0, x4, x5
        dut.instr_mem._mem[1] = 32'h0062d233;   // srl     x4, x5, x6
        dut.instr_mem._mem[2] = 32'h00625233;   // srl     x4, x4, x6

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        #11 assert(dut.dp.rf._reg[0] === 32'h00);
        #20 assert(dut.dp.rf._reg[4] === 32'h0f);
        #20 assert(dut.dp.rf._reg[4] === 32'b0);

        #5;
        $finish;
    end

endmodule
