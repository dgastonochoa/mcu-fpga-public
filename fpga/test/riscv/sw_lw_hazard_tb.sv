`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "sw_lw_hazard_tb.vcd"
`endif

module sw_lw_hazard_tb;
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

    // wire [31:0] a1, a2, rd1_d, rd2_d, rd1_e, rd2_e;

    // wire [31:0] alu_op_a_e, alu_op_b_e, alu_out_e, alu_out_m;
    wire [31:0] i_d, i_e, i_m;

    wire [32:0] x2, x3, x5, mem0;

    wire m_we_m, stall, flush;

    assign write_data = dut.rv.dp.write_data;
    assign m_addr = dut.rv.dp.m_addr;

    // assign alu_op_a_e = dut.rv.dp.alu_op_a_e;
    // assign alu_op_b_e = dut.rv.dp.alu_op_b_e;
    // assign alu_out_e = dut.rv.dp.alu_out_e;
    // assign alu_out_m = dut.rv.dp.alu_out_m;

    // assign rd1_d = dut.rv.dp.rd1_d;
    // assign rd2_d = dut.rv.dp.rd2_d;
    // assign a1 = dut.rv.dp.rf.addr1;
    // assign a2 = dut.rv.dp.rf.addr2;
    // assign rd1_e = dut.rv.dp.rd1_e;
    // assign rd2_e = dut.rv.dp.rd2_e;

    assign i_d = dut.rv.dp.i_d;
    // assign i_e = dut.rv.dp.i_e;
    assign i_m = dut.rv.dp.i_m;

    assign x2 = dut.rv.dp.rf._reg[2];
    assign x3 = dut.rv.dp.rf._reg[3];
    // assign x5 = dut.rv.dp.rf._reg[5];

    assign mem0 = dut.rv.data_mem._mem._mem[0];

    assign m_we_m = dut.rv.m_we_m;
    assign stall = dut.rv.dp.stall;
    assign flush = dut.rv.dp.flush;


    wire [31:0] a3_e, a1_d, a2_d;
    wire [3:0] result_src_e;

    assign a3_e = dut.rv.dp.hc.a3_e;
    assign a1_d = dut.rv.dp.hc.a1_d;
    assign a2_d = dut.rv.dp.hc.a2_d;
    assign result_src_e = dut.rv.dp.hc.result_src_e;



    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, sw_lw_hazard_tb);

        dut.rv.dp.rf._reg[2] = 32'h00;
        dut.rv.dp.rf._reg[5] = 32'h00;
        dut.rv.dp.rf._reg[6] = 32'h00;

        `MEM_DATA[0] = 32'hdeadc0de;
        `MEM_DATA[1] = 32'hdeadbeef;


        `MEM_INSTR[`INSTR_START_IDX + 0] = 32'h02000113; //         addi    x2, x0, 32
        `MEM_INSTR[`INSTR_START_IDX + 1] = 32'h00202023; //         sw      x2, (0)(x0)
        `MEM_INSTR[`INSTR_START_IDX + 2] = 32'h00002183; //         lw      x3, (0)(x0)
        `MEM_INSTR[`INSTR_START_IDX + 3] = 32'h00302223; //         sw      x3, (4)(x0)
        `MEM_INSTR[`INSTR_START_IDX + 4] = 32'h0000006f; // .L0:    jal     x0, .L0


        // Reset and test
        #2  rst = 1;
        #2  rst = 0;

        `WAIT_INSTR_C(clk, 20) assert(dut.rv.dp.rf._reg[2] === 32'd32);
                               assert(dut.rv.dp.rf._reg[3] === 32'd32);
                               assert(`MEM_DATA[0] === 32'd32);
                               assert(`MEM_DATA[1] === 32'd32);

        #5;
        $finish;
    end
endmodule
