`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`ifndef VCD
    `define VCD "lw_tb.vcd"
`endif

`define MEM_DATA            dut.rv.data_mem._mem._mem
`define MEM_INSTR           dut.rv.instr_mem._mem._mem
`define DATA_START_ADDR     0
`define INSTR_START_ADDR    0
`define WAIT_INSTR(clk)     @(posedge clk) #1

module lw_tb;
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
        $dumpvars(1, lw_tb);

        // Set register init. vals
        dut.rv.dp.rf._reg[0] = 32'd0;
        dut.rv.dp.rf._reg[6] = 32'd0;
        dut.rv.dp.rf._reg[9] = 32'd8;

        // Set mem. init. vals
        `MEM_DATA[`DATA_START_ADDR + 1] = 32'hdeadc0de;
        `MEM_DATA[`DATA_START_ADDR + 2] = 32'hdeadbeef;
        `MEM_DATA[`DATA_START_ADDR + 3] = 32'hc001c0de;

        // Load words with different addresses
        // Last instr. is to try to load word into x0
        `MEM_INSTR[`INSTR_START_ADDR + 0] = 32'hffc4a303; // lw x6, -4(x9)
        `MEM_INSTR[`INSTR_START_ADDR + 1] = 32'h0004a303; // lw x6, 0(x9)
        `MEM_INSTR[`INSTR_START_ADDR + 2] = 32'h0044a303; // lw x6, 4(x9)
        `MEM_INSTR[`INSTR_START_ADDR + 3] = 32'h0044a003; // lw x0, 4(x9)

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        `WAIT_INSTR(clk) assert(dut.rv.dp.rf._reg[6] === 32'hdeadc0de);
        `WAIT_INSTR(clk) assert(dut.rv.dp.rf._reg[6] === 32'hdeadbeef);
        `WAIT_INSTR(clk) assert(dut.rv.dp.rf._reg[6] === 32'hc001c0de);
        `WAIT_INSTR(clk) assert(dut.rv.dp.rf._reg[0] === 32'h00);

        #20;
        $finish;
    end
endmodule
