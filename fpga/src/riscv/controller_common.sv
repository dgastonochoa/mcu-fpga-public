`include "alu.svh"

`include "riscv/controller.svh"

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
