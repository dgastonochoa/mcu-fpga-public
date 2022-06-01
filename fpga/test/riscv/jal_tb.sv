`timescale 10ps/1ps
`include "alu.svh"
`include "riscv/datapath.svh"




`ifndef VCD
    `define VCD "jal_tb.vcd"
`endif

module jal_tb;
    wire reg_we, mem_we;
    res_src_e res_src;
	pc_src_e pc_src;
	alu_src_e alu_src;
    imm_src_e imm_src;
    alu_op_e alu_ctrl;

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

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, jal_tb);

        dut.instr_mem._mem[0] = 32'h00c000ef;   // jal ra, +12
        dut.instr_mem._mem[1] = 32'h00000013;
        dut.instr_mem._mem[2] = 32'h00000013;
        dut.instr_mem._mem[3] = 32'h00000013;
        dut.instr_mem._mem[4] = 32'h00000013;
        dut.instr_mem._mem[5] = 32'h00000013;
        dut.instr_mem._mem[6] = 32'h00000013;
        dut.instr_mem._mem[7] = 32'hff9ff0ef;   // jal ra, -8

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        #11 assert(pc === 12);
        #20 assert(pc === 16);
        #20 assert(pc === 20);
        #20 assert(pc === 24);
        #20 assert(pc === 28);
        #20 assert(pc === 20);

        // Modify first instr. to jump to itself
        dut.instr_mem._mem[0] = 32'h000000ef;
        #2  rst = 1;
        #2  rst = 0;
        #11 assert(pc === 0);
        #20 assert(pc === 0);
        #20 assert(pc === 0);
        #20 assert(pc === 0);
        #20 assert(pc === 0);

        #5 $finish;
    end
endmodule
