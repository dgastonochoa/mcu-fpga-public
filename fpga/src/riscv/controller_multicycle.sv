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
        ALU_W_RF,
        BRANCH,
        ERROR
    } rv_mcyc_st_e;

    rv_mcyc_st_e cs;
    rv_mcyc_st_e decode_ns;
    rv_mcyc_st_e mem_addr_ns;

    always_comb begin
        case (op)
        OP_R_TYPE:      decode_ns = EXEC_R;
        OP_I_TYPE_L:    decode_ns = MEM_ADDR;
        OP_S_TYPE:      decode_ns = MEM_ADDR;
        OP_B_TYPE:      decode_ns = BRANCH;
        default:        decode_ns = ERROR;
        endcase
    end

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
            BRANCH:     cs <= FETCH;
            default:    cs <= ERROR;
            endcase
    end


    //
    // Outputs logic
    //
    always_comb begin
        case(cs)
        FETCH:     imm_src = IMM_SRC_NONE;
        DECODE:    imm_src = IMM_SRC_BTYPE;
        MEM_ADDR:  imm_src = (op == OP_I_TYPE_L ? IMM_SRC_ITYPE : IMM_SRC_STYPE);
        MEM_WRITE: imm_src = (op == OP_I_TYPE_L ? IMM_SRC_ITYPE : IMM_SRC_STYPE);
        MEM_READ:  imm_src = (op == OP_I_TYPE_L ? IMM_SRC_ITYPE : IMM_SRC_STYPE);
        MEM_W_RF:  imm_src = (op == OP_I_TYPE_L ? IMM_SRC_ITYPE : IMM_SRC_STYPE);
        default:   imm_src = IMM_SRC_NONE;
        endcase
    end

    logic branch_en_npc_r;
    wire alu_neg, alu_zero, alu_cout, alu_ov;

    assign {alu_neg, alu_zero, alu_cout, alu_ov} = alu_flags[3:0];

    always_comb begin
        case (funct3)
        3'b000:  branch_en_npc_r = alu_zero == 1'b1;                    // beq
        3'b001:  branch_en_npc_r = alu_zero == 1'b0;                    // bne
        3'b100:  branch_en_npc_r = (alu_neg ^ alu_ov) ? 1'b1 : 1'b0;    // blt
        3'b101:  branch_en_npc_r = (alu_neg ^ alu_ov) ? 1'b0 : 1'b1;    // bge
        3'b110:  branch_en_npc_r = alu_cout ? 1'b0 : 1'b1;              // bltu
        3'b111:  branch_en_npc_r = alu_cout ? 1'b1 : 1'b0;              // bgeu
        default: branch_en_npc_r = 1'b0;
        endcase
    end

    logic [20:0] ctrls;

    assign {                rf_we,  m_we,   alu_src_a,      alu_src_b,          res_src,            dt,          en_ir,  en_npc_r,          m_addr_src} = ctrls;

    always_comb begin
        case(cs)
        FETCH:     ctrls = {1'b0,   1'b0,   ALU_SRC_PC,     ALU_SRC_4,          RES_SRC_ALU_OUT,    MEM_DT_WORD, 1'b1,   1'b0,              1'b0};
        DECODE:    ctrls = {1'b0,   1'b0,   ALU_SRC_PC,     ALU_SRC_EXT_IMM,    RES_SRC_ALU_OUT,    MEM_DT_WORD, 1'b0,   1'b1,              1'b0};
        MEM_ADDR:  ctrls = {1'b0,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_EXT_IMM,    RES_SRC_ALU_OUT,    MEM_DT_WORD, 1'b0,   1'b0,              1'b0};
        MEM_READ:  ctrls = {1'b0,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_EXT_IMM,    RES_SRC_ALU_OUT,    MEM_DT_WORD, 1'b0,   1'b0,              1'b1};
        MEM_WRITE: ctrls = {1'b0,   1'b1,   ALU_SRC_REG_1,  ALU_SRC_EXT_IMM,    RES_SRC_ALU_OUT,    MEM_DT_WORD, 1'b0,   1'b0,              1'b1};
        EXEC_R:    ctrls = {1'b1,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_REG_2,      RES_SRC_ALU_OUT,    MEM_DT_WORD, 1'b0,   1'b0,              1'b0};
        ALU_W_RF:  ctrls = {1'b1,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_REG_2,      RES_SRC_ALU_OUT,    MEM_DT_WORD, 1'b0,   1'b0,              1'b0};
        MEM_W_RF:  ctrls = {1'b1,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_EXT_IMM,    RES_SRC_MEM,        MEM_DT_WORD, 1'b0,   1'b0,              1'b1};
        BRANCH:    ctrls = {1'b0,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_REG_2,      RES_SRC_ALU_OUT,    MEM_DT_WORD, 1'b0,   branch_en_npc_r,   1'b0};
        default:   ctrls = {1'b0,   1'b0,   ALU_SRC_NONE,   ALU_SRC_NONE,       RES_SRC_NONE,       MEM_DT_WORD, 1'b0,   1'b0,              1'b0};
        endcase
    end

    alu_op_e alu_dec_out;

    alu_dec ad(op, funct3, funct7, alu_dec_out);

    always_comb begin
        case(cs)
        FETCH:     alu_ctrl = ALU_OP_ADD;
        DECODE:    alu_ctrl = ALU_OP_ADD;
        MEM_ADDR:  alu_ctrl = ALU_OP_ADD;
        MEM_WRITE: alu_ctrl = ALU_OP_ADD;
        MEM_READ:  alu_ctrl = ALU_OP_ADD;
        MEM_W_RF:  alu_ctrl = ALU_OP_ADD;
        EXEC_R:    alu_ctrl = alu_dec_out;
        MEM_W_RF:  alu_ctrl = alu_dec_out;
        BRANCH:    alu_ctrl = alu_dec_out;
        default:   alu_ctrl = ALU_OP_NONE;
        endcase
    end
endmodule
