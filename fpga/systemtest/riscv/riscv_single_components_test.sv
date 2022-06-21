`include "mem.svh"
`include "errno.svh"
`include "alu.svh"

`include "riscv/datapath.svh"

`ifndef WAIT_CLKS
    `define WAIT_CLKS  32'h2faf080  // 500e5; 100e6 / 500e5 = 2
`endif

module slow_clk_gen(
    output  reg slow_clk,
    input   wire clk,
    input   wire rst
);
    reg [31:0] timer;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            slow_clk <= 0;
            timer <= 0;
        end else begin
            if (timer < `WAIT_CLKS) begin
                timer <= timer + 1;
            end else begin
                timer <= 0;
                slow_clk = ~slow_clk;
            end
        end
    end
endmodule

module alu_test(
    input  wire     [3:0]   sw,
    output wire     [31:0]  a,
    output wire     [31:0]  b,
    output alu_op_e         op,
    output wire     [3:0]   cnt,
    output wire     [31:0]  res,
    input  wire             clk,
    input  wire             rst
);
    logic [31:0] _a, _b;
    alu_op_e _op;
    wire [3:0] _flags;
    reg [3:0] _cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            _cnt = 0;
        end else begin
            if (~sw[0]) begin
                _cnt <= _cnt == 4'd3 ? 0 : _cnt + 1;
            end
        end
    end

    always_comb begin
        case (_cnt)
        4'd0: {_a, _b, _op} = {32'd5,   32'd3,  ALU_OP_ADD};
        4'd1: {_a, _b, _op} = {32'd5,   32'd3,  ALU_OP_SUB};
        4'd2: {_a, _b, _op} = {32'h0f,  32'hf0, ALU_OP_OR};
        4'd3: {_a, _b, _op} = {32'h0f,  32'hf0, ALU_OP_AND};
        4'd0: {_a, _b, _op} = {32'd1,   32'd2,  ALU_OP_XOR};
        endcase
    end

    alu a0(_a, _b, _op, res, _flags);

    assign a = _a;
    assign b = _b;
    assign op = _op;
    assign cnt = _cnt;

endmodule

module mem_test(
    input  wire  [3:0]   sw,
    output wire [31:0]   addr,
    output wire          we,
    output mem_dt_e      dt,
    output wire  [31:0]  rd,
    output errno_e       err,
    input  wire          clk,
    input  wire          rst
);
    reg [31:0] _addr;
    reg [31:0] _wd;
    reg _we;
    mem_dt_e _dt;

    // TODO memory populated in mem.sv
    mem m(_addr, _wd, _we, _dt, rd, err, clk);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            _addr <= 0;
            _wd <= 0;
            _we <= 0;
            _dt <= MEM_DT_HALF;
        end else begin
            if (~sw[0])
                _addr <= (_addr == 32'd10 ? 32'd0 : _addr + 2);
        end
    end

    assign addr = _addr;
    assign we = _we;
    assign dt = _dt;
endmodule

module controller_test(
    input  wire  [3:0]   sw,
    output wire  [12:0]  ctrls,
    output wire  [31:0]  _instr,
    input  wire          clk,
    input  wire          rst
);
    reg [3:0] _cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            _cnt = 0;
        end else begin
            if (~sw[0]) begin
                _cnt <= _cnt == 4'd2 ? 0 : _cnt + 1;
            end
        end
    end


    logic [31:0] instr;
    wire [3:0]  alu_flags;

    wire reg_we;
    wire mem_we;
    alu_src_e alu_src;
    res_src_e result_src;
    pc_src_e pc_src;
    imm_src_e imm_src;
    alu_op_e alu_ctrl;

    controller co(
        instr,
        alu_flags,
        reg_we,
        mem_we,
        alu_src,
        result_src,
        pc_src,
        imm_src,
        alu_ctrl
    );

    assign alu_flags = 4'b0;
    assign ctrls = {reg_we, mem_we, alu_src, result_src, pc_src, imm_src};


    always_comb begin
        case(_cnt)
        4'd0:    instr = 32'h00a00213; // addi
        4'd1:    instr = 32'h0031c0b3; // xor
        4'd2:    instr = 32'hffc4a303; // lw
        default: instr = 32'hffffffff;
        endcase
    end

    assign _instr = instr;

endmodule

module datapath_test(
    input  wire  [3:0]   sw,
    output wire  [31:0]  alu_out,
    output wire  [31:0]  pc,
    input  wire          clk,
    input  wire          rst
);
    reg [3:0] _cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            _cnt = 0;
        end else begin
            if (~sw[0]) begin
                _cnt <= _cnt == 4'd5 ? 0 : _cnt + 1;
            end
        end
    end


    logic [31:0] instr;

    wire reg_we;
    wire mem_we;
    alu_src_e alu_src;
    res_src_e result_src;
    pc_src_e pc_src;
    imm_src_e imm_src;
    alu_op_e alu_ctrl;

    controller co(
        instr,
        alu_flags,
        reg_we,
        mem_we,
        alu_src,
        result_src,
        pc_src,
        imm_src,
        alu_ctrl
    );


    wire [31:0] mem_rd_data, mem_wd_data;
    wire [3:0]  alu_flags;

    datapath dp(
        instr,
        mem_rd_data,
        reg_we,
        imm_src,
        alu_ctrl,
        alu_src,
        result_src,
        pc_src,
        pc,
        alu_out,
        alu_flags,
        mem_wd_data,
        rst,
        clk
    );

    always_comb begin
        case(_cnt)
        4'd0:    instr = 32'h00100093;  // addi    x1, zero, 1
        4'd1:    instr = 32'h00200113;  // addi    x2, zero, 2
        4'd2:    instr = 32'h00300193;  // addi    x3, zero, 3
        4'd3:    instr = 32'h00208233;  // add     x4, x1, x2
        4'd4:    instr = 32'h00310233;  // add     x4, x2, x3
        4'd5:    instr = 32'h00308233;  // add     x4, x1, x3
        default: instr = 32'hffffffff;
        endcase
    end


endmodule

/**
 * System test to test the riscv components separately.
 *
 * Different riscv components sends outputs to @param{leds},
 * depending on the selection switchs (different combinatios of
 * switchs will display different information in the LEDs).
 *
 * @warning This test counts on the memory data in @ref{mem_test}
 * has the following initial values:
 *
 *   _mem[0] = 32'h5555_aaaa;
 *   _mem[1] = 32'h8001_0180;
 *   _mem[2] = 32'h0000_ffff;
 *
 */
module riscv_single_components_test(
    input  wire  [3:0]   sw,
    output logic [15:0]  leds,
    input  wire          clk,
    input  wire          rst
);
    wire slow_clk;

    slow_clk_gen scg(slow_clk, clk, rst);


    wire [31:0] addr;
    wire we;
    mem_dt_e dt;
    wire [31:0] rd;
    errno_e err;

    mem_test mt(sw, addr, we, dt, rd, err, slow_clk, rst);


    wire [31:0]  a;
    wire [31:0]  b;
    alu_op_e op;
    wire [3:0] cnt;
    wire [31:0] alu_res;

    alu_test at(sw, a, b, op, cnt, alu_res, slow_clk, rst);


    wire [12:0] ctrls;
    wire [31:0] instr;

    controller_test ct(sw, ctrls, instr, slow_clk, rst);


    wire [31:0] alu_out, pc;

    datapath_test dpt(sw, alu_out, pc, slow_clk, rst);


    //
    // Logic to select type of data to be dumped to the leds
    //
    wire [7:0] addr8;
    wire [15:0] rd16;

    assign addr8 = addr[7:0];
    assign rd16 = rd[15:0];


    wire [15:0] alu_res16;
    wire [7:0] a8, b8;

    assign alu_res16 = alu_res[15:0];
    assign a8 = a[7:0];
    assign b8 = b[7:0];


    wire [15:0] instr16;

    assign instr16 = instr[15:0];


    wire [2:0] _sw;

    assign _sw = sw[3:1];


    wire [7:0] alu_out8, pc8;

    assign alu_out8 = alu_out[7:0];
    assign pc8 = pc[7:0];


    always_comb begin
        case (_sw)
        3'b000: leds = rd16;
        3'b001: leds = {err, we, dt, {3{1'b0}}, addr8};
        3'b010: leds = alu_res16;
        3'b011: leds = {a8, b8};
        3'b100: leds = {op, {8{1'b0}}, cnt};
        3'b101: leds = {{3{1'b0}}, ctrls};
        3'b110: leds = instr16;
        3'b111: leds = {pc8, alu_out8};
        endcase
    end

endmodule
