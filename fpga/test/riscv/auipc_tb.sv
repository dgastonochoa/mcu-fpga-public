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


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, auipc_tb);

        dut.dp.rf._reg[0] = 32'd00;
        dut.dp.rf._reg[1] = 32'd12;

        dut.instr_mem._mem[0] = 32'h0ffff097;

        // Reset and test
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 32'd00);
        #11 assert(pc === (32'hffff << 12) + 12 + 4);

        #5;
        $finish;
    end

endmodule
