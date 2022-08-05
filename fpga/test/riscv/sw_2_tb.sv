`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "sw_2_tb.vcd"
`endif

module sw_2_tb;
    reg clk = 0, rst;

    always #10 clk = ~clk;


    wire reg_we, mem_we;
    res_src_e res_src;
    pc_src_e pc_src;
    alu_src_e alu_src;
    imm_src_e imm_src;
    alu_op_e alu_ctrl;
    wire [31:0] pc, alu_out, wdata;
    wire [31:0] instr, mem_rd_data, mem_wd_data;

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

    wire [31:0] write_data, m_addr;

    wire [31:0] a1, a2, rd1_d, rd2_d, rd1_e, rd2_e;

    wire [31:0] alu_op_a_e, alu_op_b_e, alu_out_e, alu_out_m;
    wire [31:0] i_d, i_e, i_m;

    wire [32:0] x2, x5;

    assign write_data = dut.rv.dp.write_data;
    assign m_addr = dut.rv.dp.m_addr;

    assign alu_op_a_e = dut.rv.dp.alu_op_a_e;
    assign alu_op_b_e = dut.rv.dp.alu_op_b_e;
    assign alu_out_e = dut.rv.dp.alu_out_e;
    assign alu_out_m = dut.rv.dp.alu_out_m;

    assign rd1_d = dut.rv.dp.rd1_d;
    assign rd2_d = dut.rv.dp.rd2_d;
    assign a1 = dut.rv.dp.rf.addr1;
    assign a2 = dut.rv.dp.rf.addr2;
    assign rd1_e = dut.rv.dp.rd1_e;
    assign rd2_e = dut.rv.dp.rd2_e;

    assign i_d = dut.rv.dp.i_d;
    assign i_e = dut.rv.dp.i_e;
    assign i_m = dut.rv.dp.i_m;

    assign x2 = dut.rv.dp.rf._reg[2];
    assign x5 = dut.rv.dp.rf._reg[5];


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, sw_2_tb);

        dut.rv.dp.rf._reg[2] = 32'h00;
        dut.rv.dp.rf._reg[5] = 32'h00;
        dut.rv.dp.rf._reg[6] = 32'h00;

        `MEM_DATA[8] = 32'hdeadc0de;
        `MEM_DATA[9] = 32'hdeadbeef;


        `MEM_INSTR[`INSTR_START_IDX + 0] = 32'h02000113; //         addi    x2, x0, 32
        `MEM_INSTR[`INSTR_START_IDX + 1] = 32'h02500293; //         addi    x5, x0, 37
        `MEM_INSTR[`INSTR_START_IDX + 2] = 32'h00328313; //         addi    x6, x5, 3
        `MEM_INSTR[`INSTR_START_IDX + 3] = 32'h00512023; //         sw      x5, (0*4)(x2)
        `MEM_INSTR[`INSTR_START_IDX + 4] = 32'h00612223; //         sw      x6, (1*4)(x2)
        `MEM_INSTR[`INSTR_START_IDX + 5] = 32'h0000006f; // .L0:    jal     x0, .L0

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;

        `WAIT_INSTR_C(clk, 20) assert(dut.rv.dp.rf._reg[2] === 32'd32);
                               assert(dut.rv.dp.rf._reg[5] === 32'd37);
                               assert(dut.rv.dp.rf._reg[6] === 32'd40);
                               assert(`MEM_DATA[8] === 32'd37);
                               assert(`MEM_DATA[9] === 32'd40);

        #5;
        $finish;
    end
endmodule
