`timescale 10ps/1ps
`include "alu.svh"
`include "riscv/datapath.svh"




`ifndef VCD
    `define VCD "bne_tb.vcd"
`endif

module bne_tb;
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
    wire [31:0] x6, x9;
    assign x6 = dut.rv.dp.rf._reg[6];
    assign x9 = dut.rv.dp.rf._reg[9];

    wire [31:0] addr1, addr3;
    assign addr1 = dut.rv.dp.rf.addr1;
    assign addr3 = dut.rv.dp.rf.addr3;

    wire [31:0] mem5, mem10, mem11;
    assign mem5 = dut.rv.data_mem._mem._mem[5];
    assign mem10 = dut.rv.data_mem._mem._mem[10];
    assign mem11 = dut.rv.data_mem._mem._mem[11];


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, bne_tb);

        dut.rv.dp.rf._reg[0] = 32'd00;
        dut.rv.dp.rf._reg[4] = 32'd04;
        dut.rv.dp.rf._reg[5] = 32'd00;

        dut.rv.instr_mem._mem._mem[0] = 32'h00401863;       // bne x0, x4, 16
        dut.rv.instr_mem._mem._mem[4] = 32'h00421463;       // bne x4, x4, 24
        dut.rv.instr_mem._mem._mem[5] = 32'hfe5216e3;       // bne x4, x5, 0

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);
        #11 assert(pc === 32'd16);
        #20 assert(pc === 32'd20);
        #20 assert(pc === 32'd00);

        #5;
        $finish;
    end

endmodule
