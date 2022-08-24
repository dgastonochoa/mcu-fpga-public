`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "example_program_tb.vcd"
`endif

`ifdef CONFIG_RISCV_MULTICYCLE
    /**
     * Address from which the data will be written. It is added to the 'sp' register
     * (x2) in 'all_instr_program_test_instr_mem.txt' (first instruction). The
     * test program is expected to write all data using this register as base.
     *
     * Therefore it is expected tha the first instruction of the test program sets
     * the 'sp' register to this value, and all store instructions use 'sp' as base.
     *
     */
    `define DATA_OFFS   1728

    /**
    * The memory will be checked by accessing it in terms of words.
    *
    */
    `define DATA_IDX    (`DATA_OFFS / 4)

    `define MEM_MAP_FILE "./riscv/mem_maps/all_instr_program_test_instr_mem_shared_instr_data_mem.txt"

`else
    `define MEM_MAP_FILE "./riscv/mem_maps/all_instr_program_test_instr_mem_separ_instr_data_mem.txt"

    `define DATA_IDX    0
`endif // CONFIG_RISCV_MULTICYCLE

module example_program_tb;
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
        $dumpvars(1, example_program_tb);

        $readmemh(
            `MEM_MAP_FILE,
            `MEM_INSTR,
            0,
            457
        );

`ifdef CONFIG_RISCV_MULTICYCLE
        assert(`GET_MEM_I(0) === 32'h6c000113);
`else
        assert(`GET_MEM_I(0) === 32'h00000113);
`endif // CONFIG_RISCV_MULTICYCLE

        assert(`GET_MEM_I(1) === 32'h02500293);
        assert(`GET_MEM_I(2) === 32'h00328313);
        assert(`GET_MEM_I(455) === 32'hffc10113);
        assert(`GET_MEM_I(456) === 32'h00012083);
        assert(`GET_MEM_I(457) === 32'h00008067);

        // Reset
        #2  rst = 1;
        #2  rst = 0;
            assert(pc === 0);

        wait(pc === 32'h680);

        // Wait for some cycles to let the last instr. go to all the stages if
        // applicable.
        `WAIT_CLKS(clk, 20);

        assert(`MEM_DATA[`DATA_IDX + 0] === 37);
        assert(`MEM_DATA[`DATA_IDX + 1] === 40);
        assert(`MEM_DATA[`DATA_IDX + 2] === 24);
        assert(`MEM_DATA[`DATA_IDX + 3] === 32'habcdef12);
        assert(`MEM_DATA[`DATA_IDX + 4] === 32'h12);
        assert(`MEM_DATA[`DATA_IDX + 5] === 32'hef);
        assert(`MEM_DATA[`DATA_IDX + 6] === 32'hcd);
        assert(`MEM_DATA[`DATA_IDX + 7] === 32'hab);
        assert(`MEM_DATA[`DATA_IDX + 8] === 32'hef12);
        assert(`MEM_DATA[`DATA_IDX + 9] === 32'habcd);
        assert(`MEM_DATA[`DATA_IDX + 10] === 32'habcdef12);
        assert(`MEM_DATA[`DATA_IDX + 11] === 32'hxxxxef12);
        assert(`MEM_DATA[`DATA_IDX + 12] === 32'hxxxxxx12);
        assert(`MEM_DATA[`DATA_IDX + 13] === 32'h00000012);
        assert(`MEM_DATA[`DATA_IDX + 14] === 32'hffffffef);
        assert(`MEM_DATA[`DATA_IDX + 15] === 32'hffffffcd);
        assert(`MEM_DATA[`DATA_IDX + 16] === 32'hffffffab);
        assert(`MEM_DATA[`DATA_IDX + 17] === 32'hffffef12);
        assert(`MEM_DATA[`DATA_IDX + 18] === 32'h7ffff000);
        assert(`MEM_DATA[`DATA_IDX + 19] === 32'hcdef1200);
        assert(`MEM_DATA[`DATA_IDX + 20] === 32'h9bde2400);
        assert(`MEM_DATA[`DATA_IDX + 21] === 32'habcdef12);
        assert(`MEM_DATA[`DATA_IDX + 22] === 32'h00);
        assert(`MEM_DATA[`DATA_IDX + 23] === 0);
        assert(`MEM_DATA[`DATA_IDX + 24] === 1);
        assert(`MEM_DATA[`DATA_IDX + 25] === 0);
        assert(`MEM_DATA[`DATA_IDX + 26] === 0);
        assert(`MEM_DATA[`DATA_IDX + 27] === 0);
        assert(`MEM_DATA[`DATA_IDX + 28] === 1);
        assert(`MEM_DATA[`DATA_IDX + 29] === 0);
        assert(`MEM_DATA[`DATA_IDX + 30] === 0);
        assert(`MEM_DATA[`DATA_IDX + 31] === 0);
        assert(`MEM_DATA[`DATA_IDX + 32] === 0);
        assert(`MEM_DATA[`DATA_IDX + 33] === 1);
        assert(`MEM_DATA[`DATA_IDX + 34] === 1);
        assert(`MEM_DATA[`DATA_IDX + 35] === 1);
        assert(`MEM_DATA[`DATA_IDX + 36] === 0);
        assert(`MEM_DATA[`DATA_IDX + 37] === 1);
        assert(`MEM_DATA[`DATA_IDX + 38] === 1);
        assert(`MEM_DATA[`DATA_IDX + 39] === 0);
        assert(`MEM_DATA[`DATA_IDX + 40] === 0);
        assert(`MEM_DATA[`DATA_IDX + 41] === 1);
        assert(`MEM_DATA[`DATA_IDX + 42] === 1);
        assert(`MEM_DATA[`DATA_IDX + 43] === 0);
        assert(`MEM_DATA[`DATA_IDX + 44] === 0);
        assert(`MEM_DATA[`DATA_IDX + 45] === 0);
        assert(`MEM_DATA[`DATA_IDX + 46] === 1);
        assert(`MEM_DATA[`DATA_IDX + 47] === 0);
        assert(`MEM_DATA[`DATA_IDX + 48] === 0);
        assert(`MEM_DATA[`DATA_IDX + 49] === 32'hff);
        assert(`MEM_DATA[`DATA_IDX + 50] === 32'h00);
        assert(`MEM_DATA[`DATA_IDX + 51] === 32'h0fffff00);
        assert(`MEM_DATA[`DATA_IDX + 52] === 32'h00fffff0);
        assert(`MEM_DATA[`DATA_IDX + 53] === 32'hffffff00);
        assert(`MEM_DATA[`DATA_IDX + 54] === 32'hfffffff0);
        assert(`MEM_DATA[`DATA_IDX + 55] === 32'hf0);
        assert(`MEM_DATA[`DATA_IDX + 56] === 32'hff);
        assert(`MEM_DATA[`DATA_IDX + 57] === 32'hff);
        assert(`MEM_DATA[`DATA_IDX + 58] === 32'hff);
        assert(`MEM_DATA[`DATA_IDX + 59] === 32'h0f);
        assert(`MEM_DATA[`DATA_IDX + 60] === 32'h00);
        assert(`MEM_DATA[`DATA_IDX + 61] === 32'h04);
        assert(`MEM_DATA[`DATA_IDX + 62] === 32'hcdef1200);
        assert(`MEM_DATA[`DATA_IDX + 63] === 32'h9bde2400);
        assert(`MEM_DATA[`DATA_IDX + 64] === 32'habcdef12);
        assert(`MEM_DATA[`DATA_IDX + 65] === 0);
        assert(`MEM_DATA[`DATA_IDX + 66] === 1);
        assert(`MEM_DATA[`DATA_IDX + 67] === 0);
        assert(`MEM_DATA[`DATA_IDX + 68] === 0);
        assert(`MEM_DATA[`DATA_IDX + 69] === 0);
        assert(`MEM_DATA[`DATA_IDX + 70] === 1);
        assert(`MEM_DATA[`DATA_IDX + 71] === 0);
        assert(`MEM_DATA[`DATA_IDX + 72] === 0);
        assert(`MEM_DATA[`DATA_IDX + 73] === 0);
        assert(`MEM_DATA[`DATA_IDX + 74] === 0);
        assert(`MEM_DATA[`DATA_IDX + 75] === 1);
        assert(`MEM_DATA[`DATA_IDX + 76] === 1);
        assert(`MEM_DATA[`DATA_IDX + 77] === 1);
        assert(`MEM_DATA[`DATA_IDX + 78] === 0);
        assert(`MEM_DATA[`DATA_IDX + 79] === 1);
        assert(`MEM_DATA[`DATA_IDX + 80] === 1);
        assert(`MEM_DATA[`DATA_IDX + 81] === 0);
        assert(`MEM_DATA[`DATA_IDX + 82] === 0);
        assert(`MEM_DATA[`DATA_IDX + 83] === 1);
        assert(`MEM_DATA[`DATA_IDX + 84] === 1);
        assert(`MEM_DATA[`DATA_IDX + 85] === 0);
        assert(`MEM_DATA[`DATA_IDX + 86] === 0);
        assert(`MEM_DATA[`DATA_IDX + 87] === 0);
        assert(`MEM_DATA[`DATA_IDX + 88] === 1);
        assert(`MEM_DATA[`DATA_IDX + 89] === 0);
        assert(`MEM_DATA[`DATA_IDX + 90] === 0);
        assert(`MEM_DATA[`DATA_IDX + 91] === 32'hff);
        assert(`MEM_DATA[`DATA_IDX + 92] === 32'h00);
        assert(`MEM_DATA[`DATA_IDX + 93] === 32'h0fffff00);
        assert(`MEM_DATA[`DATA_IDX + 94] === 32'h00fffff0);
        assert(`MEM_DATA[`DATA_IDX + 95] === 32'hffffff00);
        assert(`MEM_DATA[`DATA_IDX + 96] === 32'hfffffff0);
        assert(`MEM_DATA[`DATA_IDX + 97] === 32'hf0);
        assert(`MEM_DATA[`DATA_IDX + 98] === 32'hff);
        assert(`MEM_DATA[`DATA_IDX + 99] === 32'hff);
        assert(`MEM_DATA[`DATA_IDX + 100] === 32'hff);
        assert(`MEM_DATA[`DATA_IDX + 101] === 32'h0f);
        assert(`MEM_DATA[`DATA_IDX + 102] === 32'h00);
        assert(`MEM_DATA[`DATA_IDX + 103] === 20);
        assert(`MEM_DATA[`DATA_IDX + 104] === 25);
        assert(`MEM_DATA[`DATA_IDX + 105] === 0);
        assert(`MEM_DATA[`DATA_IDX + 106] === -5);
        assert(`MEM_DATA[`DATA_IDX + 107] === 20);
        assert(`MEM_DATA[`DATA_IDX + 108] === 25);
        assert(`MEM_DATA[`DATA_IDX + 109] === 0);
        assert(`MEM_DATA[`DATA_IDX + 110] === -5);
        assert(`MEM_DATA[`DATA_IDX + 111] === 20);
        assert(`MEM_DATA[`DATA_IDX + 112] === -20);
        assert(`MEM_DATA[`DATA_IDX + 113] === -5);
        assert(`MEM_DATA[`DATA_IDX + 114] === 45);
        assert(`MEM_DATA[`DATA_IDX + 115] === 1);
        assert(`MEM_DATA[`DATA_IDX + 116] === 1);
        assert(`MEM_DATA[`DATA_IDX + 117] === 1);
        assert(`MEM_DATA[`DATA_IDX + 118] === 1);
        assert(`MEM_DATA[`DATA_IDX + 119] === 6);
        assert(`MEM_DATA[`DATA_IDX + 120] === 6);
        assert(`MEM_DATA[`DATA_IDX + 121] === 6);
        assert(`MEM_DATA[`DATA_IDX + 122] === 6);
        assert(`MEM_DATA[`DATA_IDX + 123] === 6);
        assert(`MEM_DATA[`DATA_IDX + 124] === 6);
        assert(`MEM_DATA[`DATA_IDX + 125] === 6);
        assert(`MEM_DATA[`DATA_IDX + 126] === 6);

        #40 $finish;
    end


endmodule


