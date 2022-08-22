`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "sw_spi_loop_tb.vcd"
`endif

module sw_spi_loop_tb;
    reg clk = 0, rst;

    always #10 clk = ~clk;


    reg [7:0] s_wd = 8'haa;
    wire s_busy, s_rdy, mosi, miso, ss, sck;
    wire [7:0] s_rd;

    spi_slave spis(mosi, ss, s_wd, miso, s_rd, s_rdy, s_busy, rst, sck, clk);


    wire reg_we, mem_we;
    res_src_e res_src;
    pc_src_e pc_src;
    alu_src_e alu_src;
    imm_src_e imm_src;
    alu_op_e alu_ctrl;
    wire [31:0] pc, m_addr, wdata;
    wire [31:0] instr, mem_rd_data, m_wd;

    riscv dut(
        reg_we,
        mem_we,
        imm_src,
        alu_ctrl,
        alu_src,
        res_src, pc_src,
        instr,
        m_addr,
        mem_rd_data,
        m_wd,
        pc,

        mosi,
        miso,
        ss,
        sck,

        rst,
        clk
    );


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, sw_spi_loop_tb);

        dut.data_mem._mem._mem[0] = 32'hdeadc0de;
        dut.data_mem._mem._mem[1] = 32'hdeadbeef;
        dut.data_mem._mem._mem[2] = 32'hc001c0de;
        dut.data_mem._mem._mem[3] = 32'hc001beef;

        dut.dp.rf._reg[3] = 32'h80000000;


        // Reset and test
        #2  rst = 1;
        #2  rst = 0;

        #5;
        $finish;
    end
endmodule
