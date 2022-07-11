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
    wire [6:0] op, funct7;
    wire [2:0] funct3;

    assign op = instr[6:0];
    assign funct7 = instr[31:25];
    assign funct3 = instr[14:12];


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
        MEM_W_RF,
        EXEC_R,
        ALU_W_RF
    } rv_mcyc_st_e;

    rv_mcyc_st_e cs;
    rv_mcyc_st_e decode_ns;
    rv_mcyc_st_e mem_addr_ns;

    assign decode_ns = (op == OP_R_TYPE ? EXEC_R : MEM_ADDR);
    assign mem_addr_ns = (op == OP_I_TYPE_L ? MEM_READ : MEM_WRITE);

    always @(posedge clk, posedge rst) begin
        if (rst)
            cs <= FETCH;
        else
            case (cs)
            FETCH:      cs <= DECODE;
            DECODE:     cs <= decode_ns;
            MEM_ADDR:   cs <= mem_addr_ns;
            MEM_WRITE:  cs <= FETCH;
            MEM_READ:   cs <= MEM_W_RF;
            MEM_W_RF:   cs <= FETCH;
            EXEC_R:     cs <= ALU_W_RF;
            ALU_W_RF:   cs <= FETCH;
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
        MEM_W_RF:  imm_src = (op == OP_I_TYPE_L ? IMM_SRC_ITYPE : IMM_SRC_STYPE);
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
        MEM_W_RF:  ctrls = {1'b1,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_EXT_IMM,    RES_SRC_MEM,        MEM_DT_WORD, 1'b0,   1'b0,       1'b1};
        EXEC_R:    ctrls = {1'b1,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_REG_2,      RES_SRC_ALU_OUT,    MEM_DT_WORD, 1'b0,   1'b0,       1'b0};
        MEM_W_RF:  ctrls = {1'b0,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_REG_2,      RES_SRC_ALU_OUT,    MEM_DT_WORD, 1'b0,   1'b0,       1'b0};
        endcase
    end

    alu_op_e exec_r_alu_ctrl;

    alu_dec ad(op, funct3, funct7, exec_r_alu_ctrl);

    always_comb begin
        case(cs)
        FETCH:     alu_ctrl = ALU_OP_ADD;
        DECODE:    alu_ctrl = ALU_OP_ADD;
        MEM_ADDR:  alu_ctrl = ALU_OP_ADD;
        MEM_WRITE: alu_ctrl = ALU_OP_ADD;
        MEM_READ:  alu_ctrl = ALU_OP_ADD;
        MEM_W_RF:  alu_ctrl = ALU_OP_ADD;
        EXEC_R:    alu_ctrl = exec_r_alu_ctrl;
        MEM_W_RF:  alu_ctrl = exec_r_alu_ctrl;
        endcase
    end
endmodule
