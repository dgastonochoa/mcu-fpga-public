`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "sw_tb.vcd"
`endif

module sw_tb;
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

    // wire [31:0] write_data;

    // assign write_data = dut.rv.dp.write_data;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, sw_tb);

        dut.rv.dp.rf._reg[9] = (`DATA_START_IDX * 4) + 32;
        dut.rv.dp.rf._reg[6] = 32'hdeadc0de;
        dut.rv.dp.rf._reg[7] = 32'hdeadbeef;
        dut.rv.dp.rf._reg[8] = 32'hc001c0de;

        `MEM_DATA[`DATA_START_IDX + 5] = 32'h00;
        `MEM_DATA[`DATA_START_IDX + 10] = 32'h00;
        `MEM_DATA[`DATA_START_IDX + 11] = 32'h00;

        `MEM_INSTR[`INSTR_START_IDX + 0] = 32'hfe64aa23;   // sw x6, -12(x9)
        `MEM_INSTR[`INSTR_START_IDX + 1] = 32'h0074a423;   // sw x7, 8(x9)
        `MEM_INSTR[`INSTR_START_IDX + 2] = 32'h0084a6a3;   // sw x8, 12(x9)
        `MEM_INSTR[`INSTR_START_IDX + 3] = 32'h0004a6a3;   // sw x0, 12(x9)

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;

`ifdef CONFIG_RISCV_PIPELINE
        `WAIT_INSTR_C(clk, 3);
`endif

        `WAIT_INSTR_C(clk, `S_I_CYC) assert(`MEM_DATA[`DATA_START_IDX + 5] === 32'hdeadc0de);
        `WAIT_INSTR_C(clk, `S_I_CYC) assert(`MEM_DATA[`DATA_START_IDX + 10] === 32'hdeadbeef);
        `WAIT_INSTR_C(clk, `S_I_CYC) assert(`MEM_DATA[`DATA_START_IDX + 11] === 32'hc001c0de);
        `WAIT_INSTR_C(clk, `S_I_CYC) assert(`MEM_DATA[`DATA_START_IDX + 11] === 32'h00);

        #5;
        $finish;
    end
endmodule
