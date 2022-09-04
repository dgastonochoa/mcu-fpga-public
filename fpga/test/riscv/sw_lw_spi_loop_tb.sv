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

    `__GET_REG_SP(dut.c.dp.rf);
    `__GET_REG_RA(dut.c.dp.rf);
    `__GET_REG_A0(dut.c.dp.rf);
    `__GET_REG_A1(dut.c.dp.rf);
    `__GET_REG_A2(dut.c.dp.rf);
    `__GET_REG_A3(dut.c.dp.rf);
    `__GET_REG_S0(dut.c.dp.rf);
    `__GET_REG_T0(dut.c.dp.rf);

    wire [32:0] stack_0;

    assign stack_0 = dut.cm.data_mem._mem._mem[8];

    integer i = 0;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, sw_spi_loop_tb);

        dut.c.dp.rf._reg[11] = 32'h80000000;

        dut.cm.data_mem._mem._mem[0] = 32'hdeadc0de;
        dut.cm.data_mem._mem._mem[1] = 32'hdeadbeef;
        dut.cm.data_mem._mem._mem[2] = 32'hc001c0de;
        dut.cm.data_mem._mem._mem[3] = 32'hc001beef;


        dut.cm.instr_mem._mem._mem[0] = 32'h00000613;  //         addi    a2, x0, 0   # set start address
        dut.cm.instr_mem._mem._mem[1] = 32'h00c00693;  //         addi    a3, x0, 12  # set end address
        dut.cm.instr_mem._mem._mem[2] = 32'h02000113;  //         addi    sp, x0, 32  # init. sp
        dut.cm.instr_mem._mem._mem[3] = 32'h00002503;  //         lw      a0, 0(x0)   # load mem[0] (debug)
        dut.cm.instr_mem._mem._mem[4] = 32'h050000ef;  //         jal     .SM
        dut.cm.instr_mem._mem._mem[5] = 32'h000000ef;  // .END:   jal     .END

                                                       // # a0 = [7:0] = byte
                                                       // # a1 = SPI base addr.
        dut.cm.instr_mem._mem._mem[6] = 32'h00a5a023;  // .SB:    sw      a0, 0(a1)    # write data to be send
        dut.cm.instr_mem._mem._mem[7] = 32'h00400293;  //         addi    t0, x0, 0x04 # set send flag
        dut.cm.instr_mem._mem._mem[8] = 32'h0055a223;  //         sw      t0, 4(a1)    # trigger send
        dut.cm.instr_mem._mem._mem[9] = 32'h0045a283;  // .L1:    lw      t0, 4(a1)    # read status
        dut.cm.instr_mem._mem._mem[10] = 32'h0022f293; //         andi    t0, t0, 0x2  # get busy flag
        dut.cm.instr_mem._mem._mem[11] = 32'hfe029ce3; //         bne     t0, x0, .L1  # if busy != 0 keep polling
        dut.cm.instr_mem._mem._mem[12] = 32'h00008067; //         jr      ra           # return

                                                       // # a0 = word
                                                       // # a1 = SPI base addr.
        dut.cm.instr_mem._mem._mem[13] = 32'h00300413; // .SW:    addi    s0, x0, 3   # load iterator
        dut.cm.instr_mem._mem._mem[14] = 32'h00100313; //         addi    t1, x0, 1   # used tu sub. 1
        dut.cm.instr_mem._mem._mem[15] = 32'h00112023; //         sw      ra, 0(sp)   # push ra
        dut.cm.instr_mem._mem._mem[16] = 32'h00410113; //         addi    sp, sp, 4   # sp = sp + 4
        dut.cm.instr_mem._mem._mem[17] = 32'hfd5ff0ef; // .L2:    jal     .SB         # send byte
        dut.cm.instr_mem._mem._mem[18] = 32'h00855513; //         srli    a0, a0, 8   # right shift to next byte
        dut.cm.instr_mem._mem._mem[19] = 32'h40640433; //         sub     s0, s0, t1  # sub. 1 to iterator
        dut.cm.instr_mem._mem._mem[20] = 32'hfe045ae3; //         bge     s0, x0, .L2 # if it. > 0, repeat
        dut.cm.instr_mem._mem._mem[21] = 32'hffc10113; //         addi    sp, sp, -4  # restore sp
        dut.cm.instr_mem._mem._mem[22] = 32'h00012083; //         lw      ra, 0(sp)   # restore ra
        dut.cm.instr_mem._mem._mem[23] = 32'h00008067; //         jr      ra          # return

                                                       // # a1 = SPI base addr.
                                                       // # a2 = start addr.
                                                       // # a3 = end addr.
        dut.cm.instr_mem._mem._mem[24] = 32'h00112023; // .SM:    sw      ra, 0(sp)   # push ra
        dut.cm.instr_mem._mem._mem[25] = 32'h00410113; //         addi    sp, sp, 4   # sp = sp + 4
        dut.cm.instr_mem._mem._mem[26] = 32'h00062503; // .L3:    lw      a0, 0(a2)   # load word
        dut.cm.instr_mem._mem._mem[27] = 32'hfc9ff0ef; //         jal     .SW         # send word
        dut.cm.instr_mem._mem._mem[28] = 32'h00460613; //         addi    a2, a2, 4   # base addr. += 4
        dut.cm.instr_mem._mem._mem[29] = 32'hfec6dae3; //         bge     a3, a2, .L3 # if end addr. >= base addr. keep sending
        dut.cm.instr_mem._mem._mem[30] = 32'hffc10113; //         addi    sp, sp, -4  # restore sp
        dut.cm.instr_mem._mem._mem[31] = 32'h00012083; //         lw      ra, 0(sp)   # restore ra
        dut.cm.instr_mem._mem._mem[32] = 32'h00008067; //         jr      ra          # return


        // Reset and test
        #2  rst = 1;
        #2  rst = 0;

        // NOTE: the following wait_clks have been extracted from studying the
        // wave dump

        `WAIT_CLKS(clk, 10);

        `WAIT_CLKS(clk, 90) assert(s_rdy === 1'b1); i = 1;
                            assert(s_rd === 8'hde);

        `WAIT_CLKS(clk, 90) assert(s_rdy === 1'b1); i = 2;
                            assert(s_rd === 8'hc0);

        `WAIT_CLKS(clk, 90) assert(s_rdy === 1'b1); i = 3;
                            assert(s_rd === 8'had);

        `WAIT_CLKS(clk, 90) assert(s_rdy === 1'b1); i = 4;
                            assert(s_rd === 8'hde);

        `WAIT_CLKS(clk, 20);


        `WAIT_CLKS(clk, 90) assert(s_rdy === 1'b1); i = 1;
                            assert(s_rd === 8'hef);

        `WAIT_CLKS(clk, 90) assert(s_rdy === 1'b1); i = 2;
                            assert(s_rd === 8'hbe);

        `WAIT_CLKS(clk, 90) assert(s_rdy === 1'b1); i = 3;
                            assert(s_rd === 8'had);

        `WAIT_CLKS(clk, 90) assert(s_rdy === 1'b1); i = 4;
                            assert(s_rd === 8'hde);

        `WAIT_CLKS(clk, 20);


        `WAIT_CLKS(clk, 90) assert(s_rdy === 1'b1); i = 1;
                            assert(s_rd === 8'hde);

        `WAIT_CLKS(clk, 90) assert(s_rdy === 1'b1); i = 2;
                            assert(s_rd === 8'hc0);

        `WAIT_CLKS(clk, 90) assert(s_rdy === 1'b1); i = 3;
                            assert(s_rd === 8'h01);

        `WAIT_CLKS(clk, 90) assert(s_rdy === 1'b1); i = 4;
                            assert(s_rd === 8'hc0);

        `WAIT_CLKS(clk, 20);


        `WAIT_CLKS(clk, 90) assert(s_rdy === 1'b1); i = 1;
                            assert(s_rd === 8'hef);

        `WAIT_CLKS(clk, 90) assert(s_rdy === 1'b1); i = 2;
                            assert(s_rd === 8'hbe);

        `WAIT_CLKS(clk, 90) assert(s_rdy === 1'b1); i = 3;
                            assert(s_rd === 8'h01);

        `WAIT_CLKS(clk, 90) assert(s_rdy === 1'b1); i = 4;
                            assert(s_rd === 8'hc0);

        #5;
        $finish;
    end
endmodule
