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

        dut.instr_mem._mem[0] = 32'hffc4a303;           // lw x6, -4(x9)

        reg_we = 1'b1;
        imm_src = 1'b0;
        mem_we = 1'b0;
        #5  rst = 1;
        #1  assert(pc === 0);
            assert(alu_out === 4);

        #1  rst = 0;
        #4  assert(pc === 4);
            assert(dut.dp.rf._reg[6] === 32'hdeadc0de);

        #5;
        $finish;
    end
endmodule
