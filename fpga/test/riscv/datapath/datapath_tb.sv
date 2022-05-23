`timescale 10ps/1ps

`ifndef VCD
    `define VCD "datapath_tb.vcd"
`endif

module datapath_tb;
    reg reg_we, imm_src, mem_we;

    wire [31:0] pc, alu_out, wdata;
    wire [31:0] instr, mem_rd_data, mem_wd_data;

    reg clk = 0, rst;

    riscv_single_top dut(reg_we, mem_we, imm_src, instr, alu_out, mem_rd_data, mem_wd_data, pc, rst, clk);

    always #10 clk = ~clk;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, datapath_tb);

        dut.dp.rf._reg[9] = 32'd8;
        dut.dp.rf._reg[6] = 32'd0;

        dut.data_mem._mem[1] = 32'hdeadc0de;
        dut.data_mem._mem[4] = 32'h00;

        dut.instr_mem._mem[0] = 32'hffc4a303;           // lw x6, -4(x9)
        dut.instr_mem._mem[1] = 32'h0064a423;           // sw x6, 8(x9)

        reg_we = 1'b1;
        imm_src = 1'b0;
        mem_we = 1'b0;
        #5  rst = 1;
        #1  assert(pc === 0);
            assert(alu_out === 4);

        #1  rst = 0;
        #4  assert(pc === 4);
            assert(dut.dp.rf._reg[6] === 32'hdeadc0de);

        reg_we = 1'b0;
        imm_src = 1'b1;
        mem_we = 1'b1;
        #20 assert(pc === 8);
            assert(dut.data_mem._mem[4] === 32'hdeadc0de);

        #5;
        $finish;
    end

    wire [31:0] x0, x6, x9;
    assign x0 = dut.dp.rf._reg[0];
    assign x6 = dut.dp.rf._reg[6];
    assign x9 = dut.dp.rf._reg[9];

    wire [31:0] addr1, addr3;
    assign addr1 = dut.dp.rf.addr1;
    assign addr3 = dut.dp.rf.addr3;

    wire [31:0] mem21, mem33;
    assign mem21 = dut.data_mem._mem[1];
    assign mem33 = dut.data_mem._mem[3];
endmodule
