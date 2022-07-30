`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "lw_hazards_tb.vcd"
`endif

module lw_hazards_tb;
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


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, lw_hazards_tb);

        //
        // Basic stall works
        //
        #2  rst = 1;
            dut.rv.dp.rf._reg[1] = 32'h00;
            dut.rv.dp.rf._reg[2] = 32'd3;
            dut.rv.dp.rf._reg[3] = 32'h00;
            dut.rv.dp.rf._reg[4] = 32'h00;
            dut.rv.dp.rf._reg[5] = 32'd7;
            dut.rv.dp.rf._reg[6] = 32'h00;
            dut.rv.dp.rf._reg[7] = 32'd1;

            `MEM_DATA[`DATA_START_IDX + 0] = 32'hdeadc0de;

            `MEM_INSTR[`INSTR_START_IDX + 0] = 32'h00002083; // lw  x1, 0(x0)
            `MEM_INSTR[`INSTR_START_IDX + 1] = 32'h0020f1b3; // and x3, x1, x2
            `MEM_INSTR[`INSTR_START_IDX + 2] = 32'h0012e233; // or  x4, x5, x1
            `MEM_INSTR[`INSTR_START_IDX + 3] = 32'h40708333; // sub x6, x1, x7
        #2  rst = 0;

        `WAIT_INIT_CYCLES(clk);
        `WAIT_INSTR(clk) assert(dut.rv.dp.rf._reg[1] === 32'hdeadc0de);
        `WAIT_INSTR(clk); // stall
        `WAIT_INSTR(clk) assert(dut.rv.dp.rf._reg[3] === 32'h2);
        `WAIT_INSTR(clk) assert(dut.rv.dp.rf._reg[4] === 32'hdeadc0df);
        `WAIT_INSTR(clk) assert(dut.rv.dp.rf._reg[6] === 32'hdeadc0dd);


        //
        // Stall and then forward works
        //
        #2  rst = 1;
            dut.rv.dp.rf._reg[1] = 32'h00;
            dut.rv.dp.rf._reg[2] = 32'd3;
            dut.rv.dp.rf._reg[3] = 32'h5;
            dut.rv.dp.rf._reg[4] = 32'h00;

            `MEM_DATA[`DATA_START_IDX + 0] = 32'hdeadc0de;

            `MEM_INSTR[`INSTR_START_IDX + 0] = 32'h00002083; // lw  x1, 0(x0)
            `MEM_INSTR[`INSTR_START_IDX + 1] = 32'h003100b3; // add x1, x2, x3
            `MEM_INSTR[`INSTR_START_IDX + 2] = 32'h00208233; // add x4, x1, x2
        #2  rst = 0;

        `WAIT_INIT_CYCLES(clk);
        `WAIT_INSTR(clk) assert(dut.rv.dp.rf._reg[1] === 32'hdeadc0de);
        `WAIT_INSTR(clk); // stall
        `WAIT_INSTR(clk) assert(dut.rv.dp.rf._reg[1] === 32'd8);
        `WAIT_INSTR(clk) assert(dut.rv.dp.rf._reg[4] === 32'd11);

        #20;
        $finish;
    end
endmodule
