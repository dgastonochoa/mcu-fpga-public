`timescale 10ps/1ps
`include "alu.svh"
`include "riscv/datapath.svh"




`ifndef VCD
    `define VCD "beq_tb.vcd"
`endif

module beq_tb;
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
        $dumpvars(1, beq_tb);

        dut.rv.dp.rf._reg[0] = 32'd00;
        dut.rv.dp.rf._reg[4] = 32'd00;

        dut.rv.instr_mem._mem._mem[0] = 32'h00400a63;       // beq x0, x4, 20
        dut.rv.instr_mem._mem._mem[5] = 32'h00400263;       // beq x0, x4, 4
        dut.rv.instr_mem._mem._mem[6] = 32'hfe4004e3;       // beq x0, x4, -6

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);
        #11 assert(pc === 32'd20);
        #20 assert(pc === 32'd24);
        #20 assert(pc === 32'd00);

        #5;
        $finish;
    end

endmodule
