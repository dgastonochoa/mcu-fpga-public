`include "alu.svh"
`include "riscv/datapath.svh"
`include "riscv/controller.svh"

module controller_multicycle(
    input   wire         [31:0] instr,
    input   wire         [3:0]  alu_flags,
    output  wire                rf_we,
    output  wire                m_we,
    output  alu_src_e           alu_src_a,
    output  alu_src_e           alu_src_b,
    output  res_src_e           res_src,
    output  imm_src_e           imm_src,
    output  alu_op_e            alu_ctrl,
    output  mem_dt_e            dt,
    output  wire                en_ir,
    output  wire                en_npc_r,
    output  wire                m_addr_src,
    input   wire                clk,
    input   wire                rst
);
    wire [6:0] op;

    assign op = instr[6:0];


    //
    // Next state logic
    //
    typedef enum reg [3:0]
    {
        FETCH,
        DECODE,
        MEM_ADDR,
        MEM_READ,
        MEM_WRITE,
        RF_WRITE
    } rv_mcyc_st_e;

    rv_mcyc_st_e cs;
    rv_mcyc_st_e mem_addr_ns;

    assign mem_addr_ns = (op == OP_I_TYPE_L ? MEM_READ : MEM_WRITE);

    always @(posedge clk, posedge rst) begin
        if (rst)
            cs <= FETCH;
        else
            case (cs)
            FETCH:      cs <= DECODE;
            DECODE:     cs <= MEM_ADDR;
            MEM_ADDR:   cs <= mem_addr_ns;
            MEM_WRITE:  cs <= FETCH;
            MEM_READ:   cs <= RF_WRITE;
            RF_WRITE:   cs <= FETCH;
            endcase
    end


    //
    // Outputs logic
    //
    always_comb begin
        case(cs)
        FETCH:     imm_src = IMM_SRC_NONE;
        DECODE:    imm_src = IMM_SRC_NONE;
        MEM_ADDR:  imm_src = (op == OP_I_TYPE_L ? IMM_SRC_ITYPE : IMM_SRC_STYPE);
        MEM_WRITE: imm_src = (op == OP_I_TYPE_L ? IMM_SRC_ITYPE : IMM_SRC_STYPE);
        MEM_READ:  imm_src = (op == OP_I_TYPE_L ? IMM_SRC_ITYPE : IMM_SRC_STYPE);
        RF_WRITE:  imm_src = (op == OP_I_TYPE_L ? IMM_SRC_ITYPE : IMM_SRC_STYPE);
        endcase
    end

    logic [20:0] ctrls;

    assign {                rf_we,  m_we,   alu_src_a,      alu_src_b,          res_src,            dt,          en_ir,  en_npc_r,   m_addr_src} = ctrls;

    always_comb begin
        case(cs)
        FETCH:     ctrls = {1'b0,   1'b0,   ALU_SRC_PC,     ALU_SRC_4,          RES_SRC_ALU_OUT,    MEM_DT_WORD, 1'b1,   1'b0,       1'b0};
        DECODE:    ctrls = {1'b0,   1'b0,   ALU_SRC_PC,     ALU_SRC_4,          RES_SRC_ALU_OUT,    MEM_DT_WORD, 1'b0,   1'b1,       1'b0};
        MEM_ADDR:  ctrls = {1'b0,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_EXT_IMM,    RES_SRC_ALU_OUT,    MEM_DT_WORD, 1'b0,   1'b0,       1'b0};
        MEM_WRITE: ctrls = {1'b0,   1'b1,   ALU_SRC_REG_1,  ALU_SRC_EXT_IMM,    RES_SRC_ALU_OUT,    MEM_DT_WORD, 1'b0,   1'b0,       1'b1};
        MEM_READ:  ctrls = {1'b0,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_EXT_IMM,    RES_SRC_ALU_OUT,    MEM_DT_WORD, 1'b0,   1'b0,       1'b1};
        RF_WRITE:  ctrls = {1'b1,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_EXT_IMM,    RES_SRC_MEM,        MEM_DT_WORD, 1'b0,   1'b0,       1'b1};
        endcase
    end

    assign alu_ctrl = ALU_OP_ADD;
endmodule
