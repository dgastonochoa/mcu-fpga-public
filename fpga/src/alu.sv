`include "synth.svh"
`include "alu.svh"

/**
 * ALU module
 *
 * @param a Operand a
 * @param b Operand b
 * @param op Operation to perform.
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
    input   alu_op_e        op,
    output  logic   [31:0]  res,
    output  wire    [3:0]   flags
);
    wire [31:0] s;
    wire co;

    logic [31:0] b_op;
    logic cin;
    wire [31:0] nb;
    wire signed [31:0] signed_a;

    assign nb = ~b;
    assign signed_a = `CAST(signed, a);

    always_comb begin
        case (op)
        ALU_OP_ADD: begin
            b_op = b;
            cin = 1'b0;
            res = s;
        end

        ALU_OP_SUB: begin
            b_op = nb;
            cin = 1'b1;
            res = s;
        end

        ALU_OP_SLT: begin
            b_op = nb;
            cin = 1'b1;
            res = {{31{1'b0}}, (sign ^ ov)};
        end

        ALU_OP_SLTU: begin
            b_op = nb;
            cin = 1'b1;
            res = {{31{1'b0}}, ~co};
        end

        ALU_OP_AND: begin
            b_op = 32'h0;
            cin = 1'b0;
            res = a & b;
        end

        ALU_OP_OR: begin
            b_op = 32'h0;
            cin = 1'b0;
            res = a | b;
        end

        ALU_OP_XOR: begin
            b_op = 32'h0;
            cin = 1'b0;
            res = a ^ b;
        end

        ALU_OP_SLL: begin
            b_op = 32'h0;
            cin = 1'b0;
            res = a << b;
        end

        ALU_OP_SRL: begin
            b_op = 32'h0;
            cin = 1'b0;
            res = a >> b;
        end

        ALU_OP_SRA: begin
            b_op = 32'h0;
            cin = 1'b0;
            res = signed_a >>> b;
        end

        default: {b_op, cin, res} = {32'h0, 1'b0, 32'hffffffff};
        endcase
    end

    assign {co, s} = a + b_op + cin;

    wire sign;
    assign sign = s[31];

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
        ALU_OP_ADD: ov = ov0 | ov1;
        ALU_OP_SUB: ov = ov2 | ov3;
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
