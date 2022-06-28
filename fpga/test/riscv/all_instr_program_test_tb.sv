`timescale 10ps/1ps

`include "alu.svh"
`include "riscv/datapath.svh"

`ifndef VCD
    `define VCD "example_program_tb.vcd"
`endif

module example_program_tb;
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
        $dumpvars(1, example_program_tb);

        $readmemh(
            "./riscv/mem_maps/all_instr_program_test_instr_mem.txt",
            dut.rv.instr_mem._mem._mem,
            0,
            417
        );

        assert(dut.rv.instr_mem._mem._mem[0] === 32'h00000113);
        assert(dut.rv.instr_mem._mem._mem[1] === 32'h02500293);
        assert(dut.rv.instr_mem._mem._mem[2] === 32'h00328313);
        assert(dut.rv.instr_mem._mem._mem[415] === 32'h1e612c23);
        assert(dut.rv.instr_mem._mem._mem[416] === 32'h000001ef);
        assert(dut.rv.instr_mem._mem._mem[417] === 32'h000001ef);

        // Reset
        #5  rst = 1;
        #1  assert(pc === 0);
        #1  rst = 0;

        wait(pc === 32'h680);

        assert(dut.rv.data_mem._mem._mem[0] === 37);
        assert(dut.rv.data_mem._mem._mem[1] === 40);
        assert(dut.rv.data_mem._mem._mem[2] === 24);
        assert(dut.rv.data_mem._mem._mem[3] === 32'habcdef12);
        assert(dut.rv.data_mem._mem._mem[4] === 32'h12);
        assert(dut.rv.data_mem._mem._mem[5] === 32'hef);
        assert(dut.rv.data_mem._mem._mem[6] === 32'hcd);
        assert(dut.rv.data_mem._mem._mem[7] === 32'hab);
        assert(dut.rv.data_mem._mem._mem[8] === 32'hef12);
        assert(dut.rv.data_mem._mem._mem[9] === 32'habcd);
        assert(dut.rv.data_mem._mem._mem[10] === 32'habcdef12);
        assert(dut.rv.data_mem._mem._mem[11] === 32'hxxxxef12);
        assert(dut.rv.data_mem._mem._mem[12] === 32'hxxxxxx12);
        assert(dut.rv.data_mem._mem._mem[13] === 32'h00000012);
        assert(dut.rv.data_mem._mem._mem[14] === 32'hffffffef);
        assert(dut.rv.data_mem._mem._mem[15] === 32'hffffffcd);
        assert(dut.rv.data_mem._mem._mem[16] === 32'hffffffab);
        assert(dut.rv.data_mem._mem._mem[17] === 32'hffffef12);
        assert(dut.rv.data_mem._mem._mem[18] === 32'h7ffff000);
        assert(dut.rv.data_mem._mem._mem[19] === 32'hcdef1200);
        assert(dut.rv.data_mem._mem._mem[20] === 32'h9bde2400);
        assert(dut.rv.data_mem._mem._mem[21] === 32'habcdef12);
        assert(dut.rv.data_mem._mem._mem[22] === 32'h00);
        assert(dut.rv.data_mem._mem._mem[23] === 0);
        assert(dut.rv.data_mem._mem._mem[24] === 1);
        assert(dut.rv.data_mem._mem._mem[25] === 0);
        assert(dut.rv.data_mem._mem._mem[26] === 0);
        assert(dut.rv.data_mem._mem._mem[27] === 0);
        assert(dut.rv.data_mem._mem._mem[28] === 1);
        assert(dut.rv.data_mem._mem._mem[29] === 0);
        assert(dut.rv.data_mem._mem._mem[30] === 0);
        assert(dut.rv.data_mem._mem._mem[31] === 0);
        assert(dut.rv.data_mem._mem._mem[32] === 0);
        assert(dut.rv.data_mem._mem._mem[33] === 1);
        assert(dut.rv.data_mem._mem._mem[34] === 1);
        assert(dut.rv.data_mem._mem._mem[35] === 1);
        assert(dut.rv.data_mem._mem._mem[36] === 0);
        assert(dut.rv.data_mem._mem._mem[37] === 1);
        assert(dut.rv.data_mem._mem._mem[38] === 1);
        assert(dut.rv.data_mem._mem._mem[39] === 0);
        assert(dut.rv.data_mem._mem._mem[40] === 0);
        assert(dut.rv.data_mem._mem._mem[41] === 1);
        assert(dut.rv.data_mem._mem._mem[42] === 1);
        assert(dut.rv.data_mem._mem._mem[43] === 0);
        assert(dut.rv.data_mem._mem._mem[44] === 0);
        assert(dut.rv.data_mem._mem._mem[45] === 0);
        assert(dut.rv.data_mem._mem._mem[46] === 1);
        assert(dut.rv.data_mem._mem._mem[47] === 0);
        assert(dut.rv.data_mem._mem._mem[48] === 0);
        assert(dut.rv.data_mem._mem._mem[49] === 32'hff);
        assert(dut.rv.data_mem._mem._mem[50] === 32'h00);
        assert(dut.rv.data_mem._mem._mem[51] === 32'h0fffff00);
        assert(dut.rv.data_mem._mem._mem[52] === 32'h00fffff0);
        assert(dut.rv.data_mem._mem._mem[53] === 32'hffffff00);
        assert(dut.rv.data_mem._mem._mem[54] === 32'hfffffff0);
        assert(dut.rv.data_mem._mem._mem[55] === 32'hf0);
        assert(dut.rv.data_mem._mem._mem[56] === 32'hff);
        assert(dut.rv.data_mem._mem._mem[57] === 32'hff);
        assert(dut.rv.data_mem._mem._mem[58] === 32'hff);
        assert(dut.rv.data_mem._mem._mem[59] === 32'h0f);
        assert(dut.rv.data_mem._mem._mem[60] === 32'h00);
        assert(dut.rv.data_mem._mem._mem[61] === 32'h04);
        assert(dut.rv.data_mem._mem._mem[62] === 32'hcdef1200);
        assert(dut.rv.data_mem._mem._mem[63] === 32'h9bde2400);
        assert(dut.rv.data_mem._mem._mem[64] === 32'habcdef12);
        assert(dut.rv.data_mem._mem._mem[65] === 0);
        assert(dut.rv.data_mem._mem._mem[66] === 1);
        assert(dut.rv.data_mem._mem._mem[67] === 0);
        assert(dut.rv.data_mem._mem._mem[68] === 0);
        assert(dut.rv.data_mem._mem._mem[69] === 0);
        assert(dut.rv.data_mem._mem._mem[70] === 1);
        assert(dut.rv.data_mem._mem._mem[71] === 0);
        assert(dut.rv.data_mem._mem._mem[72] === 0);
        assert(dut.rv.data_mem._mem._mem[73] === 0);
        assert(dut.rv.data_mem._mem._mem[74] === 0);
        assert(dut.rv.data_mem._mem._mem[75] === 1);
        assert(dut.rv.data_mem._mem._mem[76] === 1);
        assert(dut.rv.data_mem._mem._mem[77] === 1);
        assert(dut.rv.data_mem._mem._mem[78] === 0);
        assert(dut.rv.data_mem._mem._mem[79] === 1);
        assert(dut.rv.data_mem._mem._mem[80] === 1);
        assert(dut.rv.data_mem._mem._mem[81] === 0);
        assert(dut.rv.data_mem._mem._mem[82] === 0);
        assert(dut.rv.data_mem._mem._mem[83] === 1);
        assert(dut.rv.data_mem._mem._mem[84] === 1);
        assert(dut.rv.data_mem._mem._mem[85] === 0);
        assert(dut.rv.data_mem._mem._mem[86] === 0);
        assert(dut.rv.data_mem._mem._mem[87] === 0);
        assert(dut.rv.data_mem._mem._mem[88] === 1);
        assert(dut.rv.data_mem._mem._mem[89] === 0);
        assert(dut.rv.data_mem._mem._mem[90] === 0);
        assert(dut.rv.data_mem._mem._mem[91] === 32'hff);
        assert(dut.rv.data_mem._mem._mem[92] === 32'h00);
        assert(dut.rv.data_mem._mem._mem[93] === 32'h0fffff00);
        assert(dut.rv.data_mem._mem._mem[94] === 32'h00fffff0);
        assert(dut.rv.data_mem._mem._mem[95] === 32'hffffff00);
        assert(dut.rv.data_mem._mem._mem[96] === 32'hfffffff0);
        assert(dut.rv.data_mem._mem._mem[97] === 32'hf0);
        assert(dut.rv.data_mem._mem._mem[98] === 32'hff);
        assert(dut.rv.data_mem._mem._mem[99] === 32'hff);
        assert(dut.rv.data_mem._mem._mem[100] === 32'hff);
        assert(dut.rv.data_mem._mem._mem[101] === 32'h0f);
        assert(dut.rv.data_mem._mem._mem[102] === 32'h00);
        assert(dut.rv.data_mem._mem._mem[103] === 20);
        assert(dut.rv.data_mem._mem._mem[104] === 25);
        assert(dut.rv.data_mem._mem._mem[105] === 0);
        assert(dut.rv.data_mem._mem._mem[106] === -5);
        assert(dut.rv.data_mem._mem._mem[107] === 20);
        assert(dut.rv.data_mem._mem._mem[108] === 25);
        assert(dut.rv.data_mem._mem._mem[109] === 0);
        assert(dut.rv.data_mem._mem._mem[110] === -5);
        assert(dut.rv.data_mem._mem._mem[111] === 20);
        assert(dut.rv.data_mem._mem._mem[112] === -20);
        assert(dut.rv.data_mem._mem._mem[113] === -5);
        assert(dut.rv.data_mem._mem._mem[114] === 45);
        assert(dut.rv.data_mem._mem._mem[115] === 1);
        assert(dut.rv.data_mem._mem._mem[116] === 1);
        assert(dut.rv.data_mem._mem._mem[117] === 1);
        assert(dut.rv.data_mem._mem._mem[118] === 1);
        assert(dut.rv.data_mem._mem._mem[119] === 6);
        assert(dut.rv.data_mem._mem._mem[120] === 6);
        assert(dut.rv.data_mem._mem._mem[121] === 6);
        assert(dut.rv.data_mem._mem._mem[122] === 6);
        assert(dut.rv.data_mem._mem._mem[123] === 6);
        assert(dut.rv.data_mem._mem._mem[124] === 6);
        assert(dut.rv.data_mem._mem._mem[125] === 6);
        assert(dut.rv.data_mem._mem._mem[126] === 6);

        #40 $finish;
    end


endmodule


