`include "errno.svh"
`include "mem.svh"
`include "synth.svh"

module cpu(
    input  wire     [31:0]  instr,
    input  wire     [31:0]  m_rd,

    output wire     [31:0]  m_addr,
    output wire             m_we,
    output wire     [31:0]  m_wd,
    output mem_dt_e         m_dt,
    output          [31:0]  pc,

    input  wire             rst,
    input  wire             clk
);
    wire [31:0] multicycle_instr;

    wire        reg_we;
    wire        mem_we;
    imm_src_e   imm_src;
    alu_op_e    alu_op;
    res_src_e   res_src;
    pc_src_e    pc_src;

    wire en_npc_r, en_ir;
    alu_src_e alu_src_a, alu_src_b;
    wire m_addr_src;
    wire [3:0] alu_flags;
    rf_wd_src_e rf_wd_src;
    wire en_oldpc_r;

    controller_multicycle co(
        multicycle_instr,
        alu_flags,
        reg_we,
        m_we,
        alu_src_a,
        alu_src_b,
        res_src,
        imm_src,
        rf_wd_src,
        alu_op,
        m_dt,
        en_ir,
        en_npc_r,
        en_oldpc_r,
        m_addr_src,
        clk,
        rst
    );

    datapath_multicycle dp(
        m_rd,
        reg_we,
        imm_src,
        alu_op,
        alu_src_a,
        alu_src_b,
        res_src,
        m_addr_src,
        en_ir,
        en_npc_r,
        en_oldpc_r,
        rf_wd_src,
        m_addr,
        alu_flags,
        m_wd,
        multicycle_instr,
        pc,
        clk,
        rst
    );
endmodule

module cpu_mem #(parameter M_SIZE = 768,
                 parameter INIT_VALS = 0) (
    input  wire     [31:0]  pc,
    input  wire     [31:0]  addr,
    input  wire     [31:0]  wd,
    input  wire             we,
    input  mem_dt_e         dt,

    output wire     [31:0]  instr,
    output wire     [31:0]  rd,
    output errno_e          err,

    input  wire             clk
);
    mem #(.N(M_SIZE), .INIT_VALS(INIT_VALS)) m(
        addr, pc, wd, we, dt, rd, instr, err, clk);
endmodule
