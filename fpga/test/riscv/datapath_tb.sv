`timescale 10ps/1ps

`include "alu.vh"
`include "riscv/datapath.vh"

`ifndef VCD
    `define VCD "datapath_tb.vcd"
`endif

module datapath_tb;
    wire reg_we, mem_we, alu_src, pc_src;
    wire [1:0] imm_src, alu_ctrl, res_src;

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

    //
    // Debug signals
    //
    wire [31:0] x6, x9;
    assign x6 = dut.dp.rf._reg[6];
    assign x9 = dut.dp.rf._reg[9];

    wire [31:0] addr1, addr3;
    assign addr1 = dut.dp.rf.addr1;
    assign addr3 = dut.dp.rf.addr3;


    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, datapath_tb);

        dut.dp.rf._reg[9] = 32'd8;
        dut.dp.rf._reg[4] = 32'd0;
        dut.dp.rf._reg[5] = 32'hfffffffe;
        dut.dp.rf._reg[6] = 32'd0;

        dut.data_mem._mem[1] = 32'hdeadc0de;
        dut.data_mem._mem[4] = 32'h00;

        dut.instr_mem._mem[0] = 32'hffc4a303;           // lw x6, -4(x9)
        dut.instr_mem._mem[1] = 32'h0064a423;           // sw x6, 8(x9)
        dut.instr_mem._mem[2] = 32'h0062e233;           // or x4, x5, x6
        dut.instr_mem._mem[3] = 32'hfe420ae3;           // beq x4, x4, L7

        // Reset
        #5  rst = 1;
        #1  assert(pc === 0);
            assert(alu_out === 4);
        #1  rst = 0;

        // First instr. executed
        #4  assert(pc === 4);
            assert(dut.dp.rf._reg[6] === 32'hdeadc0de);

        // Second instr. executed
        #20 assert(pc === 8);
            assert(dut.data_mem._mem[4] === 32'hdeadc0de);

        // Third instr. executed
        #20 assert(pc === 12);
            assert(dut.dp.rf._reg[4] === 32'hfffffffe);

        // Fourth instr. executed, branched to
        // starting address.
        #20  assert(pc === 0);

        // First instr. executed again.
        #20 assert(pc === 4);
            assert(dut.dp.rf._reg[6] === 32'hdeadc0de);

        // Second instr. executed again.
        #20 assert(pc === 8);
            assert(dut.data_mem._mem[4] === 32'hdeadc0de);

        // Third instr. executed again
        #20 assert(pc === 12);
            assert(dut.dp.rf._reg[4] === 32'hfffffffe);

        // Fourth instr. executed again, branched to
        // starting address.
        #20  assert(pc === 0);

        #5;
        $finish;
    end


endmodule
