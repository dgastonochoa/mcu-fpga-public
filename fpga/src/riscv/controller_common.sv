`include "alu.svh"
`include "synth.svh"

`include "riscv/controller.svh"
`include "riscv/datapath.svh"

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
            default:    ri_type_alu_ctr = ALU_OP_NONE;
            endcase
        end

        3'b110: ri_type_alu_ctr = ALU_OP_OR;
        3'b111: ri_type_alu_ctr = ALU_OP_AND;
        3'b100: ri_type_alu_ctr = ALU_OP_XOR;
        3'b001: ri_type_alu_ctr = ALU_OP_SLL;
        3'b101: ri_type_alu_ctr = func7 == 7'b0 ? ALU_OP_SRL : ALU_OP_SRA;
        3'b010: ri_type_alu_ctr = ALU_OP_SLT;
        3'b011: ri_type_alu_ctr = ALU_OP_SLTU;
        default: ri_type_alu_ctr = ALU_OP_NONE;
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
        OP_LUI:         alu_ctrl = ALU_OP_NONE;
        default:        alu_ctrl = ALU_OP_NONE;
        endcase
    end
endmodule

/**
 * Infers the required PC source from the instruction represented by @param{op} and
 * @param{func3}, and from @param{alu_flags}.
 *
 */
module branch_pc_src_dec(
    input  wire     [6:0] op,
    input  wire     [2:0] func3,
    input  wire     [3:0] alu_flags,
    output pc_src_e       pc_src
);
    // iverilog doesn't support index accesses within an `always_comb` block.
    wire alu_ov, alu_cout, alu_zero, alu_neg;
    logic [3:0] pc_src_b_type;

    assign {alu_neg, alu_zero, alu_cout, alu_ov} = alu_flags[3:0];

    always_comb begin
        case (func3)
        3'b000:  pc_src_b_type = alu_zero ? PC_SRC_PLUS_OFF : PC_SRC_PLUS_4;             // beq
        3'b001:  pc_src_b_type = alu_zero ? PC_SRC_PLUS_4 : PC_SRC_PLUS_OFF;             // bne
        3'b100:  pc_src_b_type = (alu_neg ^ alu_ov) ? PC_SRC_PLUS_OFF : PC_SRC_PLUS_4;   // blt
        3'b101:  pc_src_b_type = (alu_neg ^ alu_ov) ? PC_SRC_PLUS_4 : PC_SRC_PLUS_OFF;   // bge
        3'b110:  pc_src_b_type = alu_cout ? PC_SRC_PLUS_4 : PC_SRC_PLUS_OFF;             // bltu
        3'b111:  pc_src_b_type = alu_cout ? PC_SRC_PLUS_OFF : PC_SRC_PLUS_4;             // bgeu
        default: pc_src_b_type = PC_SRC_NONE;
        endcase
    end

    always_comb begin
        case (op)
        OP_B_TYPE:   pc_src = `CAST(pc_src_e, pc_src_b_type);
        OP_J_TYPE:   pc_src = PC_SRC_PLUS_OFF;
        OP_JALR:     pc_src = PC_SRC_REG_PLUS_OFF;
        OP_AUIPC:    pc_src = PC_SRC_PLUS_4;
        OP_LUI:      pc_src = PC_SRC_PLUS_4;
        OP_I_TYPE_L: pc_src = PC_SRC_PLUS_4;
        OP_I_TYPE:   pc_src = PC_SRC_PLUS_4;
        OP_S_TYPE:   pc_src = PC_SRC_PLUS_4;
        OP_R_TYPE:   pc_src = PC_SRC_PLUS_4;
        0:           pc_src = PC_SRC_PLUS_4; // TODO why is this needed
        default:     pc_src = PC_SRC_NONE;
        endcase
    end
endmodule
