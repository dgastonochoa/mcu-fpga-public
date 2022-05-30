/**
 * RISC-V top module. Connects the RISC-V CPU with external
 * memories.
 */
module riscv_single_top(
    // Signals exposed for debugging purposes
    output  wire        reg_we,
    output  wire        mem_we,
    output  wire [1:0]  imm_src,
    output  wire [3:0]  alu_op,
    output  wire        alu_src,
    output  wire [1:0]  res_src,
    output  wire        pc_src,
    output  wire [31:0] instr,
    output  wire [31:0] alu_out,
    output  wire [31:0] mem_rd_data,
    output  wire [31:0] mem_wd_data,
    output  wire [31:0] pc,
    ///////

    input   wire        rst,
    input   wire        clk
);
    wire [3:0] alu_flags;

    datapath dp(
        instr,
        mem_rd_data,
        reg_we,
        imm_src,
        alu_op,
        alu_src,
        res_src, pc_src,
        pc,
        alu_out,
        alu_flags,
        mem_wd_data,
        rst,
        clk
    );

    controller co(
        instr,
        alu_flags,
        reg_we,
        mem_we,
        alu_src,
        res_src,
        pc_src,
        imm_src,
        alu_op
    );

    mem data_mem(alu_out, mem_wd_data, mem_we, mem_rd_data, clk);

    mem instr_mem(pc, 32'b00, 1'b0, instr, clk);
endmodule
