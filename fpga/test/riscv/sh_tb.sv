`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`ifndef VCD
    `define VCD "sh_tb.vcd"
`endif

module sh_tb;
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

    //
    // Debug signals
    //
    wire [31:0] x6, x9;
    assign x6 = dut.dp.rf._reg[6];
    assign x9 = dut.dp.rf._reg[9];

    wire [31:0] addr1, addr3;
    assign addr1 = dut.dp.rf.addr1;
    assign addr3 = dut.dp.rf.addr3;

    wire [31:0] mem5, mem10, mem11;
    assign mem5 = dut.data_mem._mem._mem[5];
    assign mem10 = dut.data_mem._mem._mem[10];
    assign mem11 = dut.data_mem._mem._mem[11];


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, sh_tb);

        dut.dp.rf._reg[9] = 32'd32;
        dut.dp.rf._reg[6] = 32'hdeadc0de;
        dut.dp.rf._reg[7] = 32'hdeadbeef;
        dut.dp.rf._reg[8] = 32'hc001c0de;

        dut.data_mem._mem._mem[5] = 32'h00;
        dut.data_mem._mem._mem[10] = 32'h00;
        dut.data_mem._mem._mem[11] = 32'h00;

        dut.instr_mem._mem._mem[0] = 32'hfe649a23;           // sh x6, -12(x9)
        dut.instr_mem._mem._mem[1] = 32'h00749423;           // sh x7, 8(x9)
        dut.instr_mem._mem._mem[2] = 32'h00849623;           // sh x8, 12(x9)
        dut.instr_mem._mem._mem[3] = 32'h00049623;           // sh x0, 12(x9)

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;

        #11 assert(dut.data_mem._mem._mem[5] === 32'h0000c0de);
        #20 assert(dut.data_mem._mem._mem[10] === 32'h0000beef);
        #20 assert(dut.data_mem._mem._mem[11] === 32'h0000c0de);
        #20 assert(dut.data_mem._mem._mem[11] === 32'h00000000);

        #5;
        $finish;
    end

endmodule
