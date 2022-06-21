`timescale 10ps/1ps
`include "alu.svh"
`include "riscv/datapath.svh"




`ifndef VCD
    `define VCD "jalr_tb.vcd"
`endif

module jalr_tb;
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

    wire [31:0] a;

    assign a = dut.dp.rf._reg[1];

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, jalr_tb);

        //
        // init. x0 as 0
        //
        dut.dp.rf._reg[1] = 32'd0;
        dut.dp.rf._reg[3] = 32'd8;
        dut.dp.rf._reg[4] = 32'd4;

        dut.instr_mem._mem._mem[0] = 32'h004180e7;   // jalr    ra, x3, 4
        dut.instr_mem._mem._mem[3] = 32'hffc200e7;   // jalr    ra, x4, -4

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);
            assert(dut.dp.rf._reg[1] === 32'd00);
        #11 assert(pc === 32'd12);
            assert(dut.dp.rf._reg[1] === 32'd04);
        #20 assert(pc === 32'd00);
            assert(dut.dp.rf._reg[1] === 32'd16);

        $finish;
    end
endmodule
