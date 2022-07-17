`include "alu.svh"
`include "mem.svh"
`include "riscv/datapath.svh"
`include "riscv/controller.svh"

/**
 * Multi-cycle controller possible states.
 *
 */
typedef enum reg [3:0]
{
    RV_MC_ST_FETCH,
    RV_MC_ST_DECODE,
    RV_MC_ST_MEM_ADDR,
    RV_MC_ST_MEM_READ,
    RV_MC_ST_MEM_WRITE,
    RV_MC_ST_MEM_W_RF,       // 5
    RV_MC_ST_EXEC_R,
    RV_MC_ST_ALU_W_RF,
    RV_MC_ST_BRANCH,
    RV_MC_ST_EXEC_I,
    RV_MC_ST_ALU_W_PCN,      // 10
    RV_MC_ST_EXEC_I_JALR,
    RV_MC_ST_EXEC_J,
    RV_MC_ST_EXEC_LUI,
    RV_MC_ST_EXEC_AUIPC,
    RV_MC_ST_ERROR
} rv_mcyc_st_e;

/**
 * Immediate extender source decoder.
 *
 */
module imm_src_dec(
    input   wire        [31:0]  instr,
    input   rv_mcyc_st_e        cs,
    output  imm_src_e           imm_src
);
    wire [6:0] op, funct7;
    wire [2:0] funct3;

    assign op = instr[6:0];
    assign funct7 = instr[31:25];
    assign funct3 = instr[14:12];


    imm_src_e i_instr_imm_src;
    imm_src_e dec_imm_src;

    assign i_instr_imm_src = (funct3[0] & ~funct3[1]) ? IMM_SRC_ITYPE2 : IMM_SRC_ITYPE;

    always_comb begin
        case (op)
        OP_B_TYPE: dec_imm_src = IMM_SRC_BTYPE;
        OP_J_TYPE: dec_imm_src = IMM_SRC_JTYPE;
        OP_AUIPC:  dec_imm_src = IMM_SRC_UTYPE;
        default:   dec_imm_src = IMM_SRC_NONE;
        endcase
    end

    always_comb begin
        case(cs)
        RV_MC_ST_DECODE:      imm_src = dec_imm_src;
        RV_MC_ST_MEM_ADDR:    imm_src = (op == OP_I_TYPE_L ? IMM_SRC_ITYPE : IMM_SRC_STYPE);
        RV_MC_ST_EXEC_I:      imm_src = i_instr_imm_src;
        RV_MC_ST_EXEC_I_JALR: imm_src = IMM_SRC_ITYPE;
        RV_MC_ST_EXEC_LUI:    imm_src = IMM_SRC_UTYPE;
        default:              imm_src = IMM_SRC_NONE;
        endcase
    end
endmodule

/**
 * Multi-cycle CPU ALU operation decoder.
 *
 */
module alu_dec_multicycle(
    input   wire    [31:0]  instr,
    input   rv_mcyc_st_e    cs,
    output  alu_op_e        alu_op
);
    wire [6:0] op, funct7;
    wire [2:0] funct3;

    assign op = instr[6:0];
    assign funct7 = instr[31:25];
    assign funct3 = instr[14:12];


    alu_op_e alu_dec_out;

    alu_dec ad(op, funct3, funct7, alu_dec_out);

    always_comb begin
        case(cs)
        RV_MC_ST_FETCH:       alu_op = ALU_OP_ADD;
        RV_MC_ST_DECODE:      alu_op = ALU_OP_ADD;
        RV_MC_ST_MEM_ADDR:    alu_op = ALU_OP_ADD;
        RV_MC_ST_EXEC_R:      alu_op = alu_dec_out;
        RV_MC_ST_EXEC_I:      alu_op = alu_dec_out;
        RV_MC_ST_EXEC_I_JALR: alu_op = ALU_OP_ADD;
        RV_MC_ST_BRANCH:      alu_op = alu_dec_out;
        default:              alu_op = ALU_OP_NONE;
        endcase
    end
endmodule

/**
 * Memory data type decoder.
 *
 */
module mem_dt_dec(
    input   wire    [31:0]  instr,
    input   rv_mcyc_st_e    cs,
    output  mem_dt_e        dt
);
    wire [6:0] op, funct7;
    wire [2:0] funct3;

    assign op = instr[6:0];
    assign funct7 = instr[31:25];
    assign funct3 = instr[14:12];


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

    always_comb begin
        case (cs)
        RV_MC_ST_FETCH:     dt = MEM_DT_WORD;
        RV_MC_ST_MEM_ADDR:  dt = mem_w_dt;
        RV_MC_ST_MEM_READ:  dt = mem_w_dt;
        RV_MC_ST_MEM_WRITE: dt = mem_w_dt;
        default:            dt = MEM_DT_NONE;
        endcase
    end
endmodule

/**
 * Decoder for the 'enable next pc register' flag.
 *
 */
module en_next_pc_r_dec(
    input   wire         [31:0]  instr,
    input   rv_mcyc_st_e         cs,
    input   wire         [3:0]   alu_flags,
    output  logic                en_npc_r
);
    wire [6:0] op, funct7;
    wire [2:0] funct3;

    assign op = instr[6:0];
    assign funct7 = instr[31:25];
    assign funct3 = instr[14:12];


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

    always_comb begin
        case (cs)
        RV_MC_ST_BRANCH:    en_npc_r = branch_en_npc_r;
        RV_MC_ST_EXEC_J:    en_npc_r = 1'b1;
        RV_MC_ST_ALU_W_PCN: en_npc_r = 1'b1;
        RV_MC_ST_DECODE:    en_npc_r = 1'b1;
        default:            en_npc_r = 1'b0;
        endcase
    end
endmodule

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
    rv_mcyc_st_e cs;
    rv_mcyc_st_e decode_ns;
    rv_mcyc_st_e mem_addr_ns;
    rv_mcyc_st_e exec_i_ns;

    always_comb begin
        case (op)
        OP_R_TYPE:      decode_ns = RV_MC_ST_EXEC_R;
        OP_I_TYPE:      decode_ns = RV_MC_ST_EXEC_I;
        OP_JALR:        decode_ns = RV_MC_ST_EXEC_I_JALR;
        OP_I_TYPE_L:    decode_ns = RV_MC_ST_MEM_ADDR;
        OP_S_TYPE:      decode_ns = RV_MC_ST_MEM_ADDR;
        OP_B_TYPE:      decode_ns = RV_MC_ST_BRANCH;
        OP_J_TYPE:      decode_ns = RV_MC_ST_EXEC_J;
        OP_LUI:         decode_ns = RV_MC_ST_EXEC_LUI;
        OP_AUIPC:       decode_ns = RV_MC_ST_EXEC_AUIPC;
        default:        decode_ns = RV_MC_ST_ERROR;
        endcase
    end

    assign mem_addr_ns = (op == OP_I_TYPE_L ? RV_MC_ST_MEM_READ : RV_MC_ST_MEM_WRITE);

    always @(posedge clk, posedge rst) begin
        if (rst)
            cs <= RV_MC_ST_FETCH;
        else
            case (cs)
            RV_MC_ST_FETCH:       cs <= RV_MC_ST_DECODE;
            RV_MC_ST_DECODE:      cs <= decode_ns;
            RV_MC_ST_MEM_ADDR:    cs <= mem_addr_ns;
            RV_MC_ST_MEM_WRITE:   cs <= RV_MC_ST_FETCH;
            RV_MC_ST_MEM_READ:    cs <= RV_MC_ST_MEM_W_RF;
            RV_MC_ST_MEM_W_RF:    cs <= RV_MC_ST_FETCH;
            RV_MC_ST_EXEC_R:      cs <= RV_MC_ST_ALU_W_RF;
            RV_MC_ST_EXEC_I:      cs <= RV_MC_ST_ALU_W_RF;
            RV_MC_ST_EXEC_I_JALR: cs <= RV_MC_ST_ALU_W_PCN;
            RV_MC_ST_ALU_W_RF:    cs <= RV_MC_ST_FETCH;
            RV_MC_ST_ALU_W_PCN:   cs <= RV_MC_ST_FETCH;
            RV_MC_ST_BRANCH:      cs <= RV_MC_ST_FETCH;
            RV_MC_ST_EXEC_J:      cs <= RV_MC_ST_FETCH;
            RV_MC_ST_EXEC_LUI:    cs <= RV_MC_ST_FETCH;
            RV_MC_ST_EXEC_AUIPC:  cs <= RV_MC_ST_FETCH;
            default:              cs <= RV_MC_ST_ERROR;
            endcase
    end


    //
    // Outputs logic
    //
    imm_src_dec isc(instr, cs, imm_src);

    en_next_pc_r_dec enprd(instr, cs, alu_flags, en_npc_r);

    mem_dt_dec mdc(instr, cs, dt);

    alu_dec_multicycle adm(instr, cs, alu_ctrl);

    logic [20:0] ctrls;

    assign {                           rf_we,  m_we,   alu_src_a,      alu_src_b,          res_src,            en_ir,  en_oldpc_r, m_addr_src,   rf_wd_src} = ctrls;

    always_comb begin
        case(cs)
        RV_MC_ST_FETCH:       ctrls = {1'b0,   1'b0,   ALU_SRC_PC,     ALU_SRC_4,          RES_SRC_ALU_OUT,    1'b1,   1'b1,       1'b0,         RF_WD_SRC_NONE};
        RV_MC_ST_DECODE:      ctrls = {1'b0,   1'b0,   ALU_SRC_PC_OLD, ALU_SRC_EXT_IMM,    RES_SRC_ALU_OUT,    1'b0,   1'b0,       1'b0,         RF_WD_SRC_NONE};
        RV_MC_ST_MEM_ADDR:    ctrls = {1'b0,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_EXT_IMM,    RES_SRC_ALU_OUT,    1'b0,   1'b0,       1'b0,         RF_WD_SRC_NONE};
        RV_MC_ST_MEM_READ:    ctrls = {1'b0,   1'b0,   ALU_SRC_NONE,   ALU_SRC_NONE,       RES_SRC_ALU_OUT,    1'b0,   1'b0,       1'b1,         RF_WD_SRC_NONE};
        RV_MC_ST_MEM_WRITE:   ctrls = {1'b0,   1'b1,   ALU_SRC_NONE,   ALU_SRC_NONE,       RES_SRC_ALU_OUT,    1'b0,   1'b0,       1'b1,         RF_WD_SRC_NONE};
        RV_MC_ST_EXEC_R:      ctrls = {1'b0,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_REG_2,      RES_SRC_ALU_OUT,    1'b0,   1'b0,       1'b0,         RF_WD_SRC_NONE};
        RV_MC_ST_EXEC_I:      ctrls = {1'b0,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_EXT_IMM,    RES_SRC_ALU_OUT,    1'b0,   1'b0,       1'b0,         RF_WD_SRC_NONE};
        RV_MC_ST_EXEC_I_JALR: ctrls = {1'b1,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_EXT_IMM,    RES_SRC_ALU_OUT,    1'b0,   1'b0,       1'b0,         RF_WD_SRC_PC};
        RV_MC_ST_ALU_W_RF:    ctrls = {1'b1,   1'b0,   ALU_SRC_NONE,   ALU_SRC_NONE,       RES_SRC_ALU_OUT,    1'b0,   1'b0,       1'b0,         RF_WD_SRC_RES};
        RV_MC_ST_ALU_W_PCN:   ctrls = {1'b0,   1'b0,   ALU_SRC_NONE,   ALU_SRC_NONE,       RES_SRC_ALU_OUT,    1'b0,   1'b0,       1'b0,         RF_WD_SRC_NONE};
        RV_MC_ST_MEM_W_RF:    ctrls = {1'b1,   1'b0,   ALU_SRC_NONE,   ALU_SRC_NONE,       RES_SRC_MEM,        1'b0,   1'b0,       1'b0,         RF_WD_SRC_RES};
        RV_MC_ST_BRANCH:      ctrls = {1'b0,   1'b0,   ALU_SRC_REG_1,  ALU_SRC_REG_2,      RES_SRC_ALU_OUT,    1'b0,   1'b0,       1'b0,         RF_WD_SRC_NONE};
        RV_MC_ST_EXEC_J:      ctrls = {1'b1,   1'b0,   ALU_SRC_NONE,   ALU_SRC_NONE,       RES_SRC_ALU_OUT,    1'b0,   1'b0,       1'b0,         RF_WD_SRC_PC};
        RV_MC_ST_EXEC_LUI:    ctrls = {1'b1,   1'b0,   ALU_SRC_NONE,   ALU_SRC_NONE,       RES_SRC_NONE,       1'b0,   1'b0,       1'b0,         RF_WD_SRC_IMM};
        RV_MC_ST_EXEC_AUIPC:  ctrls = {1'b1,   1'b0,   ALU_SRC_NONE,   ALU_SRC_NONE,       RES_SRC_ALU_OUT,    1'b0,   1'b0,       1'b0,         RF_WD_SRC_RES};
        default:              ctrls = {1'b0,   1'b0,   ALU_SRC_NONE,   ALU_SRC_NONE,       RES_SRC_NONE,       1'b0,   1'b0,       1'b0,         RF_WD_SRC_RES};
        endcase
    end
endmodule
