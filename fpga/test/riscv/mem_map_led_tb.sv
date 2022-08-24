`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "mem_map_led_tb.vcd"
`endif

module mem_map_led_tb;
    reg clk = 0, rst;

    always #10 clk = ~clk;


    wire mosi, miso, ss, sck;

    wire [15:0] leds;

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

        leds,

        rst,
        clk
    );

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, mem_map_led_tb);

        dut.dp.rf._reg[11] = 32'h80000040;          // set a1 as the led periph. base

        dut.instr_mem._mem._mem[0]  = 32'h0aa00613; //         addi    a2, x0, 0xaa    # 1: load value to write in leds
        dut.instr_mem._mem._mem[1]  = 32'h00c5a023; //         sw      a2, 0(a1)       # 2: write leds
        dut.instr_mem._mem._mem[2]  = 32'h0005a683; //         lw      a3, 0(a1)       # 3: read leds back
        dut.instr_mem._mem._mem[3]  = 32'h05500613; //         addi    a2, x0, 0x55    # repeat 1
        dut.instr_mem._mem._mem[4]  = 32'h00c5a023; //         sw      a2, 0(a1)       # repeat 2
        dut.instr_mem._mem._mem[5]  = 32'h0005a683; //         lw      a3, 0(a1)       # repeat 3
        dut.instr_mem._mem._mem[6]  = 32'hfff00613; //         addi    a2, x0, -1      # load all 0xff's
        dut.instr_mem._mem._mem[7]  = 32'h00c5a023; //         sw      a2, 0(a1)       # repeat 2
        dut.instr_mem._mem._mem[8]  = 32'h0005a683; //         lw      a3, 0(a1)       # repeat 3
        dut.instr_mem._mem._mem[9]  = 32'h00000613; //         addi    a2, x0, 0       # repeat 1
        dut.instr_mem._mem._mem[10] = 32'h00c5a023; //         sw      a2, 0(a1)       # repeat 2
        dut.instr_mem._mem._mem[11] = 32'h0005a683; //         lw      a3, 0(a1)       # repeat 3
        dut.instr_mem._mem._mem[12] = 32'h000000ef; // .END:   jal     ra, .END        # loop for ever


        // Reset and test
        #2  rst = 1;
        #2  rst = 0;

        // TODO cycles...
        `WAIT_INIT_CYCLES(clk);

        `WAIT_CLKS(clk, 1) assert(leds === 16'h00aa);
        `WAIT_CLKS(clk, 3) assert(leds === 16'h0055);
        `WAIT_CLKS(clk, 3) assert(leds === 16'hffff);
        `WAIT_CLKS(clk, 3) assert(leds === 16'h0000);

        #5;
        $finish;
    end
endmodule
