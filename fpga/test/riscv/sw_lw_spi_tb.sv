`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "sw_spi_tb.vcd"
`endif

module sw_spi_tb;
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

    wire [15:0] leds;

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

    `__GET_REG_X0(dut.c.dp.rf);


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, sw_spi_tb);

        dut.c.dp.rf._reg[3] = 32'hdeadc0de;
        dut.c.dp.rf._reg[9] = 32'h80000000;

        dut.cm.instr_mem._mem._mem[0]  = 32'h0034a023; //         sw      x3, 0(x9)    # write data to be send
        dut.cm.instr_mem._mem._mem[1]  = 32'h00400213; //         addi    x4, x0, 0x04 # set send flag
        dut.cm.instr_mem._mem._mem[2]  = 32'h0044a223; //         sw      x4, 4(x9)    # trigger send
        dut.cm.instr_mem._mem._mem[3]  = 32'h0044a183; // .L1:    lw      x3, 4(x9)    # read status
        dut.cm.instr_mem._mem._mem[4]  = 32'h0021f193; //         andi    x3, x3, 0x2  # get busy flag
        dut.cm.instr_mem._mem._mem[5]  = 32'hfe019ce3; //         bne     x3, x0, .L1  # if busy != 0 keep polling
        dut.cm.instr_mem._mem._mem[6]  = 32'h0044a183; // .L2:    lw      x3, 4(x9)    # read status
        dut.cm.instr_mem._mem._mem[7]  = 32'h0011f193; //         andi    x3, x3, 0x1  # rdy flag
        dut.cm.instr_mem._mem._mem[8]  = 32'hfe018ce3; //         beq     x3, x0, .L2  # if rdy == 0 keep polling
        dut.cm.instr_mem._mem._mem[9]  = 32'h0004a203; //         lw      x4, 0(x9)    # read received data
        dut.cm.instr_mem._mem._mem[10] = 32'h000000ef; // .L3:    jal     .L3          # loop for ever


        // Reset and test
        #2  rst = 1;
        #2  rst = 0;

        `WAIT_CLKS(clk, 100) assert(s_rdy === 1'b1);
                             assert(s_rd === 8'hde);
                             assert(dut.c.dp.rf._reg[4] === 8'haa);

        #5;
        $finish;
    end
endmodule
