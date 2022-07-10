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
    output  rf_wd_src_e         rf_wd_src,
    output  alu_op_e            alu_ctrl,
    output  mem_dt_e            dt,
    output  wire                en_ir,
    output  wire                en_npc_r,
    output  wire                en_oldpc_r,
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
        MEM_W_RF,       // 5
        EXEC_R,
        ALU_W_RF,
        BRANCH,
        EXEC_I,
        ALU_W_PCN,      // 10
        EXEC_I_JALR,
        EXEC_J,
        EXEC_LUI,
        EXEC_AUIPC,
        ERROR
    } rv_mcyc_st_e;

    rv_mcyc_st_e cs;
    rv_mcyc_st_e decode_ns;
    rv_mcyc_st_e mem_addr_ns;
    rv_mcyc_st_e exec_i_ns;

    always_comb begin
        case (op)
        OP_R_TYPE:      decode_ns = EXEC_R;
        OP_I_TYPE:      decode_ns = EXEC_I;
        OP_JALR:        decode_ns = EXEC_I_JALR;
        OP_I_TYPE_L:    decode_ns = MEM_ADDR;
        OP_S_TYPE:      decode_ns = MEM_ADDR;
        OP_B_TYPE:      decode_ns = BRANCH;
        OP_J_TYPE:      decode_ns = EXEC_J;
        OP_LUI:         decode_ns = EXEC_LUI;
        OP_AUIPC:       decode_ns = EXEC_AUIPC;
        default:        decode_ns = ERROR;
        endcase
    end

    assign mem_addr_ns = (op == OP_I_TYPE_L ? MEM_READ : MEM_WRITE);

    always @(posedge clk, posedge rst) begin
        if (rst)
            cs <= FETCH;
        else
            case (cs)
            FETCH:       cs <= DECODE;
            DECODE:      cs <= decode_ns;
            MEM_ADDR:    cs <= mem_addr_ns;
            MEM_WRITE:   cs <= FETCH;
            MEM_READ:    cs <= MEM_W_RF;
            MEM_W_RF:    cs <= FETCH;
            EXEC_R:      cs <= ALU_W_RF;
            EXEC_I:      cs <= ALU_W_RF;
            EXEC_I_JALR: cs <= ALU_W_PCN;
            ALU_W_RF:    cs <= FETCH;
            ALU_W_PCN:   cs <= FETCH;
            BRANCH:      cs <= FETCH;
            EXEC_J:      cs <= FETCH;
            EXEC_LUI:    cs <= FETCH;
            EXEC_AUIPC:  cs <= FETCH;
            default:     cs <= ERROR;
            endcase
    end


    imm_src_e i_instr_imm_src;
    imm_src_e dec_imm_src;

    assign i_instr_imm_src = (funct3[0] & ~funct3[1]) ? IMM_SRC_ITYPE2 : IMM_SRC_ITYPE;

    always_comb begin
        case (op)
        OP_B_TYPE:  dec_imm_src = IMM_SRC_BTYPE;
        OP_J_TYPE:  dec_imm_src = IMM_SRC_JTYPE;
        OP_AUIPC:   dec_imm_src = IMM_SRC_UTYPE;
        default:    dec_imm_src = IMM_SRC_NONE;
        endcase
    end

    //
    // Outputs logic
    //
    always_comb begin
        case(cs)
        DECODE:         imm_src = dec_imm_src;
        MEM_ADDR:       imm_src = (op == OP_I_TYPE_L ? IMM_SRC_ITYPE : IMM_SRC_STYPE);
        EXEC_I:         imm_src = i_instr_imm_src;
        EXEC_I_JALR:    imm_src = IMM_SRC_ITYPE;
        EXEC_LUI:       imm_src = IMM_SRC_UTYPE;
        default:        imm_src = IMM_SRC_NONE;
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

    mem_dt_e mem_w_dt;

    always_comb begin
        case (funct3)
        3'b000:  mem_w_dt = MEM_DT_BYTE;
        3'b001:  mem_w_dt = MEM_DT_HALF;
        3'b010:  mem_w_dt = MEM_DT_WORD;
        3'b100:  mem_w_dt = MEM_DT_UBYTE;
        3'b101:  mem_w_dt = MEM_DT_UHALF;
        default: mem_w_dt = MEM_DT_NONE;
        endcase
    end

    logic [25:0] ctrls;

    assign {                  rf_we,  m_we,   alu_src_a,      alu_src_b,          res_src,            dt,          en_ir,  en_npc_r,          en_oldpc_r, m_addr_src,   rf_wd_src} = ctrls;

    always_comb begin
        case(cs)
        FETCH:       ctrls = {1'b0,   1'b0,   ALU_SRC_PC,     ALU_SRC_4,          RES_SRC_ALU_OUT,    MEM_DT_WORD, 1'b1,   1'b0,              1'b1,       1'b0,         RF_WD_SRC_NONE};
        DECODE:      ctrls = {1'b0,   1'b0,   ALU_SRC_PC_OLD, ALU_SRC_EXT_IMM,    RES_SRC_ALU_OUT,    MEM_DT_NONE, 1'b0,   1'b1,              1'b0,       1'b0,         RF_WD_SRC_NONE};
        MEM_ADDR:    ctrls = {1'b0,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_EXT_IMM,    RES_SRC_ALU_OUT,    mem_w_dt,    1'b0,   1'b0,              1'b0,       1'b0,         RF_WD_SRC_NONE};
        MEM_READ:    ctrls = {1'b0,   1'b0,   ALU_SRC_NONE,   ALU_SRC_NONE,       RES_SRC_ALU_OUT,    mem_w_dt,    1'b0,   1'b0,              1'b0,       1'b1,         RF_WD_SRC_NONE};
        MEM_WRITE:   ctrls = {1'b0,   1'b1,   ALU_SRC_NONE,   ALU_SRC_NONE,       RES_SRC_ALU_OUT,    mem_w_dt,    1'b0,   1'b0,              1'b0,       1'b1,         RF_WD_SRC_NONE};
        EXEC_R:      ctrls = {1'b0,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_REG_2,      RES_SRC_ALU_OUT,    MEM_DT_NONE, 1'b0,   1'b0,              1'b0,       1'b0,         RF_WD_SRC_NONE};
        EXEC_I:      ctrls = {1'b0,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_EXT_IMM,    RES_SRC_ALU_OUT,    MEM_DT_NONE, 1'b0,   1'b0,              1'b0,       1'b0,         RF_WD_SRC_NONE};
        EXEC_I_JALR: ctrls = {1'b1,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_EXT_IMM,    RES_SRC_ALU_OUT,    MEM_DT_NONE, 1'b0,   1'b0,              1'b0,       1'b0,         RF_WD_SRC_PC};
        ALU_W_RF:    ctrls = {1'b1,   1'b0,   ALU_SRC_NONE,   ALU_SRC_NONE,       RES_SRC_ALU_OUT,    MEM_DT_NONE, 1'b0,   1'b0,              1'b0,       1'b0,         RF_WD_SRC_RES};
        ALU_W_PCN:   ctrls = {1'b0,   1'b0,   ALU_SRC_NONE,   ALU_SRC_NONE,       RES_SRC_ALU_OUT,    MEM_DT_NONE, 1'b0,   1'b1,              1'b0,       1'b0,         RF_WD_SRC_NONE};
        MEM_W_RF:    ctrls = {1'b1,   1'b0,   ALU_SRC_NONE,   ALU_SRC_NONE,       RES_SRC_MEM,        MEM_DT_NONE, 1'b0,   1'b0,              1'b0,       1'b0,         RF_WD_SRC_RES};
        BRANCH:      ctrls = {1'b0,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_REG_2,      RES_SRC_ALU_OUT,    MEM_DT_NONE, 1'b0,   branch_en_npc_r,   1'b0,       1'b0,         RF_WD_SRC_NONE};
        EXEC_J:      ctrls = {1'b1,   1'b0,   ALU_SRC_NONE,   ALU_SRC_NONE,       RES_SRC_ALU_OUT,    MEM_DT_NONE, 1'b0,   1'b1,              1'b0,       1'b0,         RF_WD_SRC_PC};
        EXEC_LUI:    ctrls = {1'b1,   1'b0,   ALU_SRC_NONE,   ALU_SRC_NONE,       RES_SRC_NONE,       MEM_DT_NONE, 1'b0,   1'b0,              1'b0,       1'b0,         RF_WD_SRC_IMM};
        EXEC_AUIPC:  ctrls = {1'b1,   1'b0,   ALU_SRC_NONE,   ALU_SRC_NONE,       RES_SRC_ALU_OUT,    MEM_DT_NONE, 1'b0,   1'b0,              1'b0,       1'b0,         RF_WD_SRC_RES};
        default:     ctrls = {1'b0,   1'b0,   ALU_SRC_NONE,   ALU_SRC_NONE,       RES_SRC_NONE,       MEM_DT_NONE, 1'b0,   1'b0,              1'b0,       1'b0,         RF_WD_SRC_RES};
        endcase
    end

    alu_op_e alu_dec_out;

    alu_dec ad(op, funct3, funct7, alu_dec_out);

    always_comb begin
        case(cs)
        FETCH:       alu_ctrl = ALU_OP_ADD;
        DECODE:      alu_ctrl = ALU_OP_ADD;
        MEM_ADDR:    alu_ctrl = ALU_OP_ADD;
        EXEC_R:      alu_ctrl = alu_dec_out;
        EXEC_I:      alu_ctrl = alu_dec_out;
        EXEC_I_JALR: alu_ctrl = ALU_OP_ADD;
        BRANCH:      alu_ctrl = alu_dec_out;
        default:     alu_ctrl = ALU_OP_NONE;
        endcase
    end
endmodule
