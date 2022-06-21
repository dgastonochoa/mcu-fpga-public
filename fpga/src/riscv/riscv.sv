`include "errno.svh"
`include "mem.svh"

/**
 * RISC-V top module. Connects the RISC-V CPU with external
 * memories.
 */
module riscv(
    // Signals exposed for debugging purposes
    output  wire        reg_we,
    output  wire        mem_we,
    output  imm_src_e   imm_src,
    output  alu_op_e    alu_op,
    output  alu_src_e   alu_src,
    output  res_src_e   res_src,
    output  pc_src_e    pc_src,
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

    mem_dt_e dt_data;
    errno_e err_data;

    assign dt_data = res_src[3:1];

    mem data_mem(alu_out, mem_wd_data, mem_we, dt_data, mem_rd_data, err_data, clk);


    mem_dt_e dt_instr;
    errno_e err_instr;

    assign dt_instr = MEM_DT_WORD;

    mem instr_mem(pc, 32'b00, 1'b0, dt_instr, instr, err_instr, clk);
endmodule
