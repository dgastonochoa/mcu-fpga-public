`timescale 10ps/1ps

`include "alu.vh"
`include "riscv/datapath.vh"

`ifndef VCD
    `define VCD "auipc_tb.vcd"
`endif

module auipc_tb;
    wire reg_we, mem_we;
    wire [1:0] res_src, pc_src, alu_src;
    wire [2:0] imm_src;
    wire [3:0] alu_ctrl;

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

    assign pc_plus_4 = dut.dp.pc_plus_4;
    assign pc_plus_off = dut.dp.pc_plus_off;
    assign pc_reg_plus_off = dut.dp.pc_reg_plus_off;
    assign pc_next = dut.dp.pc_next;
    assign reg_rd1 = dut.dp.reg_rd1;
    assign reg_rd2 = dut.dp.reg_rd2;
    assign reg_wr_data = dut.dp.reg_wr_data;
    assign alu_srca = dut.dp.alu_srca;
    assign alu_srcb =  dut.dp.alu_srcb;
    assign ext_imm = dut.dp.ext_imm;
    assign res = dut.dp.rf._reg[1];


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, auipc_tb);

        dut.dp.rf._reg[0] = 32'd00;
        dut.dp.rf._reg[1] = 32'd12;

        dut.instr_mem._mem[0] = 32'h00014097;   // auipc   x1, 20
        dut.instr_mem._mem[1] = 32'h00014097;   // auipc   x1, 20

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        #11 assert(dut.dp.rf._reg[1] === (32'd20 << 12));
        #20 assert(dut.dp.rf._reg[1] === (32'd20 << 12) + 4);

        #5;
        $finish;
    end

endmodule
