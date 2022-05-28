`include "alu.vh"

/**
 * ALU module
 *
 * @param a Operand a
 * @param b Operand b
 * @param op Operation to perform. See riscv_params TODO change this
 * @param res Operation result
 * @param flags Bit flags updated after the operation finishes.
 *      bit 0: overflow
 *      bit 1: carry out
 *      bit 2: result is zero
 *      bit 3: result is negative
 */
module alu (
    input   logic   [31:0]  a,
    input   logic   [31:0]  b,
    input   logic   [2:0]   op,
    output  logic   [31:0]  res,
    output  wire    [3:0]   flags
);
    wire [31:0] s;
    wire co;

    logic [31:0] b_op;
    logic cin;
    wire [31:0] nb;

    assign nb = ~b;

    always_comb begin
        case (op)
        alu_op_add: begin
            b_op = b;
            cin = 1'b0;
            res = s;
        end

        alu_op_sub: begin
            b_op = nb;
            cin = 1'b1;
            res = s;
        end

        alu_op_and: res = a & b;
        alu_op_or: res = a | b;
        alu_op_xor: res = a ^ b;
        default: res = 3'bx;
        endcase
    end

    assign {co, s} = a + b_op + cin;

    //
    // overflows
    //
    logic ov;
    wire ov0, ov1, ov2, ov3;

    // +a + +b
    assign ov0 = ~a[31] & ~b[31] & s[31];

    // -a + -b
    assign ov1 = a[31] & b[31] & ~s[31];

    // -a - +b
    assign ov2 = a[31] & ~b[31] & ~s[31];

    // +a - -b
    assign ov3 = ~a[31] & b[31] & s[31];

    always_comb begin
        case (op)
        alu_op_add: ov = ov0 | ov1;
        alu_op_sub: ov = ov2 | ov3;
        default: ov = 0;
        endcase
    end

    //
    // flags
    //
    // overflow
    assign flags[0] = ov;
    // cout
    assign flags[1] = co & ~op[1] & ~op[2];
    // zero
    assign flags[2] = ~(|res);
    // neg
    assign flags[3] = res[31];
endmodule
