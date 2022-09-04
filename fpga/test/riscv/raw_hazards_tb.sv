`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "raw_hazards_tb.vcd"
`endif

module raw_hazards_tb;
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
        $dumpvars(1, raw_hazards_tb);


        //
        // Forwarding works for the next 3 instructions
        //
        dut.rv.c.dp.rf._reg[1] = 32'hff;
        dut.rv.c.dp.rf._reg[2] = 32'd0;
        dut.rv.c.dp.rf._reg[3] = 32'd1;
        dut.rv.c.dp.rf._reg[4] = 32'd1;
        dut.rv.c.dp.rf._reg[5] = 32'd2;
        dut.rv.c.dp.rf._reg[6] = 32'd13;
        dut.rv.c.dp.rf._reg[7] = 32'd0;
        dut.rv.c.dp.rf._reg[8] = 32'd0;
        dut.rv.c.dp.rf._reg[9] = 32'd0;

        `SET_MEM_I(0, 32'h00520433); // add x8, x4, x5  # x8 = 3
        `SET_MEM_I(1, 32'h40340133); // sub x2, x8, x3  # x2 = 2
        `SET_MEM_I(2, 32'h008364b3); // or  x9, x6, x8  # x9 = hff
        `SET_MEM_I(3, 32'h001473b3); // and x7, x8, x1  # x7 = hff

        #2  rst = 1;
        #2  rst = 0;
        `WAIT_INIT_CYCLES(clk);
        `WAIT_CLKS(clk, 1) assert(dut.rv.c.dp.rf._reg[8] === 32'd3);
        `WAIT_CLKS(clk, 1) assert(dut.rv.c.dp.rf._reg[2] === 32'd2);
        `WAIT_CLKS(clk, 1) assert(dut.rv.c.dp.rf._reg[9] === 32'hf);
        `WAIT_CLKS(clk, 1) assert(dut.rv.c.dp.rf._reg[7] === 32'd3);


        //
        // Forwarding works if:
        // instr[M].dst_reg == instr[W].dst_reg == instr[E].src_reg2
        //
        #2  rst = 1;
            dut.rv.c.dp.rf._reg[1] = 32'hff;
            dut.rv.c.dp.rf._reg[2] = 32'd2;
            dut.rv.c.dp.rf._reg[3] = 32'd3;
            dut.rv.c.dp.rf._reg[4] = 32'd4;
            dut.rv.c.dp.rf._reg[5] = 32'hff;

            `SET_MEM_I(0, 32'h003100b3); // add x1, x2, x3
            `SET_MEM_I(1, 32'h004180b3); // add x1, x3, x4
            `SET_MEM_I(2, 32'h002082b3); // add x5, x2, x1
        #2  rst = 0;

            `WAIT_INIT_CYCLES(clk);
            `WAIT_CLKS(clk, 1) assert(dut.rv.c.dp.rf._reg[1] === 32'd5);
            `WAIT_CLKS(clk, 1) assert(dut.rv.c.dp.rf._reg[1] === 32'd7);
            `WAIT_CLKS(clk, 1) assert(dut.rv.c.dp.rf._reg[5] === 32'd9);


        //
        // Forwarding works if:
        // instr[M].dst_reg == instr[W].dst_reg == instr[E].src_reg1
        //
        #2  rst = 1;
            dut.rv.c.dp.rf._reg[1] = 32'hff;
            dut.rv.c.dp.rf._reg[2] = 32'd2;
            dut.rv.c.dp.rf._reg[3] = 32'd3;
            dut.rv.c.dp.rf._reg[4] = 32'd4;
            dut.rv.c.dp.rf._reg[5] = 32'hff;

            `SET_MEM_I(0, 32'h003100b3); // add x1, x2, x3
            `SET_MEM_I(1, 32'h004180b3); // add x1, x3, x4
            `SET_MEM_I(2, 32'h001102b3); // add x5, x1, x2
        #2  rst = 0;

            `WAIT_INIT_CYCLES(clk);
            `WAIT_CLKS(clk, 1) assert(dut.rv.c.dp.rf._reg[1] === 32'd5);
            `WAIT_CLKS(clk, 1) assert(dut.rv.c.dp.rf._reg[1] === 32'd7);
            `WAIT_CLKS(clk, 1) assert(dut.rv.c.dp.rf._reg[5] === 32'd9);

        #20;
        $finish;
    end
endmodule
