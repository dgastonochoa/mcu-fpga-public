`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`ifndef VCD
    `define VCD "lui_tb.vcd"
`endif

module lui_tb;
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
        $dumpvars(1, lui_tb);

        dut.dp.rf._reg[0] = 32'd00;
        dut.dp.rf._reg[1] = 32'd12;

        dut.instr_mem._mem._mem[0] = 32'hfffff0b7;  // lui x1, 0xfffff
        dut.instr_mem._mem._mem[1] = 32'h000010b7;  // lui x1, 1
        dut.instr_mem._mem._mem[2] = 32'h000000b7;  // lui x1, 0

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        #11 assert(dut.dp.rf._reg[1] === 32'hfffff000);
        #20 assert(dut.dp.rf._reg[1] === 32'h00001000);
        #20 assert(dut.dp.rf._reg[1] === 32'h00000000);

        #5;
        $finish;
    end

endmodule
