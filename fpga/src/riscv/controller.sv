`include "alu.svh"
`include "riscv/datapath.svh"

typedef enum logic [6:0]
{
    OP_I_TYPE_L = 7'b0000011,
    OP_I_TYPE = 7'b0010011,
    OP_S_TYPE = 7'b0100011,
    OP_R_TYPE = 7'b0110011,
    OP_B_TYPE = 7'b1100011,
    OP_J_TYPE = 7'b1101111,
    OP_JALR = 7'b1100111,
    OP_AUIPC = 7'b0010111
} op_e;


/**
 * Decodes the ALU control (op. to perform) based on the inputs
 *
 */
module alu_dec(
    input   wire    [6:0] op,
    input   wire    [2:0] func3,
    input   wire    [6:0] func7,
    output  logic   [3:0] alu_ctrl
);
    logic [3:0] ri_type_alu_ctr;

    always_comb begin
        case (func3)
        3'b000: begin
            case (op)
            OP_R_TYPE:  ri_type_alu_ctr = func7 == 7'b0 ? ALU_OP_ADD : ALU_OP_SUB;
            OP_I_TYPE:  ri_type_alu_ctr = ALU_OP_ADD;
            default:    ri_type_alu_ctr = 4'bx;
            endcase
        end

        3'b110: ri_type_alu_ctr = ALU_OP_OR;
        3'b111: ri_type_alu_ctr = ALU_OP_AND;
        3'b100: ri_type_alu_ctr = ALU_OP_XOR;
        3'b001: ri_type_alu_ctr = ALU_OP_SLL;
        3'b101: ri_type_alu_ctr = func7 == 7'b0 ? ALU_OP_SRL : ALU_OP_SRA;
        3'b010: ri_type_alu_ctr = ALU_OP_SLT;
        3'b011: ri_type_alu_ctr = ALU_OP_SLTU;
        default: ri_type_alu_ctr = 3'bx;
        endcase
    end

    always_comb begin
        case (op)
        OP_R_TYPE:      alu_ctrl = ri_type_alu_ctr;
        OP_I_TYPE:      alu_ctrl = ri_type_alu_ctr;
        OP_I_TYPE_L:    alu_ctrl = ALU_OP_ADD;
        OP_S_TYPE:      alu_ctrl = ALU_OP_ADD;
        OP_B_TYPE:      alu_ctrl = ALU_OP_SUB;
        OP_AUIPC:       alu_ctrl = ALU_OP_ADD;
        default:        alu_ctrl = 3'bx;
        endcase
    end
endmodule

/**
 * Outputs the CPU control signals based on the received instruction
 * and flags.
 *
 * @param instr Instruction
 * @param alu_zero ALU zero flag
 * @param reg_we Register file write enable
 * @param mem_we Memory write enable
 * @param alu_src ALU's second operand source (register, immediate...)
 * @param result_src Source of the result to be written in the register file.
 * @param pc_src Source of the next program counter (+4, +offset...)
 * @param imm_src Indicates the type of instr. with regards to how
 *                its immediate is stored
 *
 * @param alu_ctrl Operation to be performed by the ALU
 */
module controller(
    input   wire [31:0] instr,
    input   wire [3:0]  alu_flags,

    output  wire        reg_we,
    output  wire        mem_we,

    output  alu_src_e   alu_src,
    output  res_src_e   result_src,
    output  pc_src_e    pc_src,
    output  imm_src_e   imm_src,

    output  alu_op_e    alu_ctrl
);
    wire [6:0] op;
    wire [2:0] func3;
    wire [6:0] func7;

    alu_dec ad(op, func3, func7, alu_ctrl);

    assign op = instr[6:0];
    assign func3 = instr[14:12];
    assign func7 = instr[31:25];


    // icarus verilog doesn't support index accesses within an `always_comb` block.
    wire alu_ov, alu_cout, alu_zero, alu_neg;
    logic [1:0] pc_src_b_type;

    always_comb begin
        case (func3)
        3'b000: pc_src_b_type = alu_zero ? PC_SRC_PLUS_OFF : PC_SRC_PLUS_4;             // beq
        3'b001: pc_src_b_type = alu_zero ? PC_SRC_PLUS_4 : PC_SRC_PLUS_OFF;             // bne

        // TODO This two xor's can be optimized by using alu_ctrl = alu_op_slt
        3'b100: pc_src_b_type = (alu_neg ^ alu_ov) ? PC_SRC_PLUS_OFF : PC_SRC_PLUS_4;   // blt
        3'b101: pc_src_b_type = (alu_neg ^ alu_ov) ? PC_SRC_PLUS_4 : PC_SRC_PLUS_OFF;   // bge

        3'b110: pc_src_b_type = alu_cout ? PC_SRC_PLUS_4: PC_SRC_PLUS_OFF;              // bltu
        3'b111: pc_src_b_type = alu_cout ? PC_SRC_PLUS_OFF : PC_SRC_PLUS_4;             // bgeu
        default: pc_src_b_type = 3'bx;
        endcase
    end

    assign {alu_neg, alu_zero, alu_cout, alu_ov} = alu_flags[3:0];


    imm_src_e imm_src_i_type;
    logic [10:0] ctrls;

    always_comb begin
        case (op)
        //                       reg_we  mem_we  alu_src                result_src          pc_src                imm_src
        OP_I_TYPE_L:    ctrls = {1'b1,  1'b0,    ALU_SRC_EXT_IMM,       RES_SRC_READ_DATA, PC_SRC_PLUS_4,         IMM_SRC_ITYPE};
        OP_I_TYPE:      ctrls = {1'b1,  1'b0,    ALU_SRC_EXT_IMM,       RES_SRC_ALU_OUT,   PC_SRC_PLUS_4,         imm_src_i_type};
        OP_S_TYPE:      ctrls = {1'b0,  1'b1,    ALU_SRC_EXT_IMM,       RES_SRC_READ_DATA, PC_SRC_PLUS_4,         IMM_SRC_STYPE};
        OP_R_TYPE:      ctrls = {1'b1,  1'b0,    ALU_SRC_REG,           RES_SRC_ALU_OUT,   PC_SRC_PLUS_4,         3'bx         };
        OP_B_TYPE:      ctrls = {1'b0,  1'b0,    ALU_SRC_REG,           RES_SRC_X,         pc_src_b_type,         IMM_SRC_BTYPE};
        OP_J_TYPE:      ctrls = {1'b1,  1'b0,    2'bx,                  RES_SRC_PC_PLUS_4, PC_SRC_PLUS_OFF,       IMM_SRC_JTYPE};
        OP_JALR:        ctrls = {1'b1,  1'b0,    2'bx,                  RES_SRC_PC_PLUS_4, PC_SRC_REG_PLUS_OFF,   IMM_SRC_ITYPE};
        OP_AUIPC:       ctrls = {1'b1,  1'b0,    ALU_SRC_PC_EXT_IMM,    RES_SRC_ALU_OUT,   PC_SRC_PLUS_4,         IMM_SRC_UTYPE};
        default:        ctrls = 11'bx;
        endcase
    end

    assign {reg_we, mem_we, alu_src, result_src, pc_src, imm_src} = ctrls;
    assign imm_src_i_type = (func3[0] & ~func3[1]) ? IMM_SRC_ITYPE2 : IMM_SRC_ITYPE;

endmodule
