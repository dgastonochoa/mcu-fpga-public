/**
 * RISC-V top module. Connects the RISC-V CPU with external
 * memories.
 */
module riscv_single_top(
    // TODO control signals. To be handled by the control unit
    input   wire        reg_we,
    input   wire        mem_we,
    input   wire        imm_src,
    input   wire [1:0]  alu_op,
    input   wire        alu_src,
    input   wire        res_src,
    ////////

    // Signals exposed for debugging purposes
    output  wire [31:0] instr,
    output  wire [31:0] alu_out,
    output  wire [31:0] mem_rd_data,
    output  wire [31:0] mem_wd_data,

    output  wire [31:0] pc,
    ///////

    input   wire        rst,
    input   wire        clk
);
    datapath dp(
        instr,
        mem_rd_data,
        reg_we,
        imm_src,
        alu_op,
        alu_src,
        res_src,
        pc,
        alu_out,
        mem_wd_data,
        rst,
        clk
    );

    mem data_mem(alu_out, mem_wd_data, mem_we, mem_rd_data, clk);

    mem instr_mem(pc, 32'b00, 1'b0, instr, clk);
endmodule
