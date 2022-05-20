`define ALU_OP_ADD  2'b00
`define ALU_OP_SUB  2'b01
`define ALU_OP_AND  2'b10
`define ALU_OP_OR   2'b11

/**
 * ALU module
 *
 * @param a Operand a
 * @param b Operand b
 * @param op Operation to perform. See ALU_OP* macros
 * @param res Operation result
 * @param flags Bit flags updated after the operation finishes.
 *      bit 0: overflow
 *      bit 1: carry out
 *      bit 2: result is zero
 *      bit 3: result is negative
 */
module alu (
    input logic [31 : 0] a,
    input logic [31 : 0] b,
    input logic [1:0] op,
    output logic [31 : 0] res,
    output wire [3:0] flags
);
    wire [31:0] s;
    wire co;

    logic [31:0] b_op;
    logic cin;
    wire [31:0] nb;

    assign nb = ~b;

    always_comb begin
        case (op)
        2'b00: begin
            b_op = b;
            cin = 1'b0;
            res = s;
        end

        2'b01: begin
            b_op = nb;
            cin = 1'b1;
            res = s;
        end

        2'b10: res = a & b;
        2'b11: res = a | b;
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
        2'b00: ov = ov0 | ov1;
        2'b01: ov = ov2 | ov3;
        default: ov = 0;
        endcase
    end

    //
    // flags
    //
    // overflow
    assign flags[0] = ov;
    // cout
    assign flags[1] = co & ~op[1];
    // zero
    assign flags[2] = ~(|res);
    // neg
    assign flags[3] = res[31];
endmodule

module alu_slt (
    input logic [31 : 0] a,
    input logic [31 : 0] b,
    input logic [2:0] op,
    output logic [31 : 0] res,
    output wire [3:0] flags
);
    wire [31:0] res_aux;
    wire sign;
    wire ov;

    alu alu0(a, b, op[1:0], res_aux, flags);

    assign sign = res_aux[31];
    assign ov = flags[0];

    always_comb begin
        if (op == 3'b101) begin
            res = {{31{1'b0}}, sign ^ ov};
        end else begin
            res = res_aux;
        end
    end

endmodule
