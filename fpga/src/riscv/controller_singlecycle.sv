`include "mem.svh"

`include "riscv/datapath.svh"
`include "riscv/controller.svh"

/**
 * Outputs the CPU control signals based on the received instruction
 * and flags.
 *
 * @param instr Instruction
 * @param alu_zero ALU zero flag
 * @param reg_we Register file write enable
 * @param mem_we Memory write enable
 * @param alu_src_a ALU's first operand source (register, immediate...)
 * @param alu_src_b ALU's second operand source (register, immediate...)
 *
 * @param res_src Source of the result to be written in the register file.
 *                (alu's output, memory etc.).
 *
 * @param pc_src Source of the next program counter (+4, +offset...)
 * @param imm_src Indicates the type of instr. with regards to how
 *                its immediate is stored
 *
 * @param alu_ctrl Operation to be performed by the ALU
 * @param dt Memory data type to be read/write
 *
 */
module controller(
    input   wire [31:0] instr,
    input   wire [3:0]  alu_flags,

    output  wire        reg_we,
    output  wire        mem_we,

    output  alu_src_e   alu_src_a,
    output  alu_src_e   alu_src_b,
    output  res_src_e   result_src,
    output  pc_src_e    pc_src,
    output  imm_src_e   imm_src,

    output  alu_op_e    alu_ctrl,
    output  mem_dt_e    dt
);
    wire [6:0] op;
    wire [2:0] func3;
    wire [6:0] func7;

    alu_dec ad(op, func3, func7, alu_ctrl);

    assign op = instr[6:0];
    assign func3 = instr[14:12];
    assign func7 = instr[31:25];


    // iverilog doesn't support index accesses within an `always_comb` block.
    wire alu_ov, alu_cout, alu_zero, alu_neg;
    logic [3:0] pc_src_b_type;

    // TODO replace this and the pc_src columns below by branch_pc_src_dec in
    // controller_common
    always_comb begin
        case (func3)
        3'b000: pc_src_b_type = alu_zero ? PC_SRC_PLUS_OFF : PC_SRC_PLUS_4;             // beq
        3'b001: pc_src_b_type = alu_zero ? PC_SRC_PLUS_4 : PC_SRC_PLUS_OFF;             // bne
        3'b100: pc_src_b_type = (alu_neg ^ alu_ov) ? PC_SRC_PLUS_OFF : PC_SRC_PLUS_4;   // blt
        3'b101: pc_src_b_type = (alu_neg ^ alu_ov) ? PC_SRC_PLUS_4 : PC_SRC_PLUS_OFF;   // bge
        3'b110: pc_src_b_type = alu_cout ? PC_SRC_PLUS_4 : PC_SRC_PLUS_OFF;             // bltu
        3'b111: pc_src_b_type = alu_cout ? PC_SRC_PLUS_OFF : PC_SRC_PLUS_4;             // bgeu
        default: pc_src_b_type = PC_SRC_NONE;
        endcase
    end

    assign {alu_neg, alu_zero, alu_cout, alu_ov} = alu_flags[3:0];


    imm_src_e imm_src_i_type;
    logic [21:0] ctrls;

    assign {reg_we, mem_we, alu_src_a, alu_src_b, result_src, pc_src, imm_src} = ctrls;
    assign imm_src_i_type = (func3[0] & ~func3[1]) ? IMM_SRC_ITYPE2 : IMM_SRC_ITYPE;


    always_comb begin
        case (func3)
        3'b000:  dt = MEM_DT_BYTE;
        3'b001:  dt = MEM_DT_HALF;
        3'b010:  dt = MEM_DT_WORD;
        3'b100:  dt = MEM_DT_UBYTE;
        3'b101:  dt = MEM_DT_UHALF;
        default: dt = MEM_DT_NONE;
        endcase
    end

    always_comb begin
        case (op)
        //                       reg_we  mem_we  alu_src_a      alu_src_b        result_src         pc_src               imm_src
        OP_I_TYPE_L:    ctrls = {1'b1,  1'b0,    ALU_SRC_REG_1, ALU_SRC_EXT_IMM, RES_SRC_MEM,       PC_SRC_PLUS_4,       IMM_SRC_ITYPE};
        OP_I_TYPE:      ctrls = {1'b1,  1'b0,    ALU_SRC_REG_1, ALU_SRC_EXT_IMM, RES_SRC_ALU_OUT,   PC_SRC_PLUS_4,       imm_src_i_type};
        OP_S_TYPE:      ctrls = {1'b0,  1'b1,    ALU_SRC_REG_1, ALU_SRC_EXT_IMM, RES_SRC_NONE,      PC_SRC_PLUS_4,       IMM_SRC_STYPE};
        OP_R_TYPE:      ctrls = {1'b1,  1'b0,    ALU_SRC_REG_1, ALU_SRC_REG_2,   RES_SRC_ALU_OUT,   PC_SRC_PLUS_4,       IMM_SRC_NONE};
        OP_B_TYPE:      ctrls = {1'b0,  1'b0,    ALU_SRC_REG_1, ALU_SRC_REG_2,   RES_SRC_NONE,      pc_src_b_type,       IMM_SRC_BTYPE};
        OP_J_TYPE:      ctrls = {1'b1,  1'b0,    ALU_SRC_NONE,  ALU_SRC_NONE,    RES_SRC_PC_PLUS_4, PC_SRC_PLUS_OFF,     IMM_SRC_JTYPE};
        OP_JALR:        ctrls = {1'b1,  1'b0,    ALU_SRC_NONE,  ALU_SRC_NONE,    RES_SRC_PC_PLUS_4, PC_SRC_REG_PLUS_OFF, IMM_SRC_ITYPE};
        OP_AUIPC:       ctrls = {1'b1,  1'b0,    ALU_SRC_PC,    ALU_SRC_EXT_IMM, RES_SRC_ALU_OUT,   PC_SRC_PLUS_4,       IMM_SRC_UTYPE};
        OP_LUI:         ctrls = {1'b1,  1'b0,    ALU_SRC_NONE,  ALU_SRC_NONE,    RES_SRC_EXT_IMM,   PC_SRC_PLUS_4,       IMM_SRC_UTYPE};
        default:        ctrls = 22'h3fffff;
        endcase
    end
endmodule
