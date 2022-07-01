`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "lb_tb.vcd"
`endif

`ifdef CONFIG_RISCV_SINGLECYCLE
    `define N_CLKS 1
`elsif CONFIG_RISCV_MULTICYCLE
    `define N_CLKS 5
`endif

module lb_tb;
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
        $dumpvars(1, lb_tb);

        // Set register init. vals
        dut.rv.dp.rf._reg[0] = 32'd0;
        dut.rv.dp.rf._reg[6] = 32'd0;
        dut.rv.dp.rf._reg[9] = (`DATA_START_IDX * 4) + 8;

        // Set mem. init. vals
        `MEM_DATA[`DATA_START_IDX + 1] = 32'hdeadc0de;
        `MEM_DATA[`DATA_START_IDX + 2] = 32'hdeadbeef;
        `MEM_DATA[`DATA_START_IDX + 3] = 32'hc001c0de;

        // Load words with different addresses
        // Last instr. is to try to load word into x0
        `MEM_INSTR[`INSTR_START_IDX + 0] = 32'hffc48303;    // lb x6, -4(x9)
        `MEM_INSTR[`INSTR_START_IDX + 1] = 32'h00048303;    // lb x6, 0(x9)
        `MEM_INSTR[`INSTR_START_IDX + 2] = 32'h00448303;    // lb x6, 4(x9)
        `MEM_INSTR[`INSTR_START_IDX + 3] = 32'h00448003;    // lb x0, 4(x9)

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
        `WAIT_INSTR_C(clk, `N_CLKS) assert(dut.rv.dp.rf._reg[6] === 32'hffffffde);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(dut.rv.dp.rf._reg[6] === 32'hffffffef);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(dut.rv.dp.rf._reg[6] === 32'hffffffde);
        `WAIT_INSTR_C(clk, `N_CLKS) assert(dut.rv.dp.rf._reg[0] === 32'h00000000);

        #20;
        $finish;
    end
endmodule
