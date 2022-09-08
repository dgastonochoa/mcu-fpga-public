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
    wire        reg_we;
    imm_src_e   imm_src;
    alu_op_e    alu_op;
    alu_src_e   alu_src;
    res_src_e   res_src;
    pc_src_e    pc_src;

    alu_src_e alu_src_a, alu_src_b;
    wire [3:0] alu_flags;

    datapath dp(
        instr,
        m_rd,
        reg_we,
        imm_src,
        alu_op,
        alu_src_a,
        alu_src_b,
        res_src,
        pc_src,
        pc,
        m_addr,
        alu_flags,
        m_wd,
        rst,
        clk
    );

    controller co(
        instr,
        alu_flags,
        reg_we,
        m_we,
        alu_src_a,
        alu_src_b,
        res_src,
        pc_src,
        imm_src,
        alu_op,
        m_dt
    );
endmodule

module cpu_mem #(parameter D_SIZE = 256,
                 parameter I_SIZE = 512,
                 parameter INIT_VALS = 0) (
    input  wire     [31:0]  pc,
    input  wire     [31:0]  d_addr,
    input  wire     [31:0]  d_wd,
    input  wire             d_we,
    input  mem_dt_e         d_dt,

    output wire     [31:0]  instr,
    output wire     [31:0]  d_rd,
    output errno_e          err,

    input  wire             clk
);
    mem #(.N(D_SIZE)) dm(
        d_addr, d_wd, d_we, d_dt, d_rd, err, clk);


    mem_dt_e dt_instr;
    errno_e err_instr;

    assign dt_instr = MEM_DT_WORD;

    mem #(.N(I_SIZE), .INIT_VALS(INIT_VALS)) im(
        pc, 32'b00, 1'b0, dt_instr, instr, err_instr, clk);
endmodule
