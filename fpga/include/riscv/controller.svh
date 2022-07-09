`ifndef CONTROLLER_SVH
`define CONTROLLER_SVH

/**
 * RISC-V instruction type.
 */
typedef enum logic [6:0]
{
    OP_I_TYPE_L = 7'b0000011,
    OP_I_TYPE = 7'b0010011,
    OP_S_TYPE = 7'b0100011,
    OP_R_TYPE = 7'b0110011,
    OP_B_TYPE = 7'b1100011,
    OP_J_TYPE = 7'b1101111,
    OP_JALR = 7'b1100111,
    OP_AUIPC = 7'b0010111,
    OP_LUI = 7'b0110111     // TODO rename this to OP_U_TYPE
} op_e;

`endif // CONTROLLER_SVH
