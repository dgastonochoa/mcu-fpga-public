`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "errno.svh"

`include "riscv/datapath.svh"
`include "riscv/mem_map.svh"

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


    wire  [31:0] res [255];

    word_storage ws(s_rd, res, rst, s_rdy);


    wire [15:0] leds;

    mcu dut(mosi, miso, ss, sck, leds, rst, clk);

    integer i = 0;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, sw_spi_loop_tb);

        `CPU_SET_R(`MCU_GET_C(dut), 2, (`SEC_DATA_W * 4));
        `CPU_SET_R(`MCU_GET_C(dut), 11, 32'h80000000);
        `CPU_SET_R(`MCU_GET_C(dut), 12, (`SEC_DATA_W + 10) * 4);
        `CPU_SET_R(`MCU_GET_C(dut), 13, (`SEC_DATA_W + 13) * 4);

        `CPU_MEM_SET_D(`MCU_GET_M(dut), `SEC_DATA_W + 10, 32'hdeadc0de);
        `CPU_MEM_SET_D(`MCU_GET_M(dut), `SEC_DATA_W + 11, 32'hdeadbeef);
        `CPU_MEM_SET_D(`MCU_GET_M(dut), `SEC_DATA_W + 12, 32'hc001c0de);
        `CPU_MEM_SET_D(`MCU_GET_M(dut), `SEC_DATA_W + 13, 32'hc001beef);

        // TODO nop instructions at the beginning for legacy reasons,
        // delete them
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 0, 32'h00000013);  //         addi    x0, x0, 0   # nop
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 1, 32'h00000013);  //         addi    x0, x0, 0   # nop
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 2, 32'h00000013);  //         addi    x0, x0, 0   # nop
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 3, 32'h00002503);  //         lw      a0, 0(x0)   # load mem[0] (debug)
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 4, 32'h050000ef);  //         jal     .SM
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 5, 32'h000000ef);  // .END:   jal     .END

                                                           // # a0 = [7:0] = byte
                                                           // # a1 = SPI base addr.
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 6, 32'h00a5a023);  // .SB:    sw      a0, 0(a1)    # write data to be send
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 7, 32'h00400293);  //         addi    t0, x0, 0x04 # set send flag
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 8, 32'h0055a223);  //         sw      t0, 4(a1)    # trigger send
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 9, 32'h0045a283);  // .L1:    lw      t0, 4(a1)    # read status
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 10, 32'h0022f293); //         andi    t0, t0, 0x2  # get busy flag
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 11, 32'hfe029ce3); //         bne     t0, x0, .L1  # if busy != 0 keep polling
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 12, 32'h00008067); //         jr      ra           # return

                                                           // # a0 = word
                                                           // # a1 = SPI base addr.
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 13, 32'h00300413); // .SW:    addi    s0, x0, 3   # load iterator
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 14, 32'h00100313); //         addi    t1, x0, 1   # used tu sub. 1
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 15, 32'h00112023); //         sw      ra, 0(sp)   # push ra
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 16, 32'h00410113); //         addi    sp, sp, 4   # sp = sp + 4
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 17, 32'hfd5ff0ef); // .L2:    jal     .SB         # send byte
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 18, 32'h00855513); //         srli    a0, a0, 8   # right shift to next byte
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 19, 32'h40640433); //         sub     s0, s0, t1  # sub. 1 to iterator
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 20, 32'hfe045ae3); //         bge     s0, x0, .L2 # if it. > 0, repeat
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 21, 32'hffc10113); //         addi    sp, sp, -4  # restore sp
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 22, 32'h00012083); //         lw      ra, 0(sp)   # restore ra
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 23, 32'h00008067); //         jr      ra          # return

                                                           // # a1 = SPI base addr.
                                                           // # a2 = start addr.
                                                           // # a3 = end addr.
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 24, 32'h00112023); // .SM:    sw      ra, 0(sp)   # push ra
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 25, 32'h00410113); //         addi    sp, sp, 4   # sp = sp + 4
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 26, 32'h00062503); // .L3:    lw      a0, 0(a2)   # load word
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 27, 32'hfc9ff0ef); //         jal     .SW         # send word
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 28, 32'h00460613); //         addi    a2, a2, 4   # base addr. += 4
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 29, 32'hfec6dae3); //         bge     a3, a2, .L3 # if end addr. >= base addr. keep sending
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 30, 32'hffc10113); //         addi    sp, sp, -4  # restore sp
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 31, 32'h00012083); //         lw      ra, 0(sp)   # restore ra
        `CPU_MEM_SET_I(`MCU_GET_M(dut), 32, 32'h00008067); //         jr      ra          # return


        // Reset and test
        #2  rst = 1;
        #2  rst = 0;

        // Wait 'enough' for the mcu to send all the words
        `WAIT_CLKS(clk, 2000);

        assert(res[0] === 32'hdeadc0de);
        assert(res[1] === 32'hdeadbeef);
        assert(res[2] === 32'hc001c0de);
        assert(res[3] === 32'hc001beef);

        #5;
        $finish;
    end
endmodule
