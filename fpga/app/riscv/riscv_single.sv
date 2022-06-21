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

module riscv_single(
    input  wire  [3:0]   sw,
    output logic [15:0]  leds,
    input  wire          clk,
    input  wire          rst
);
    wire slow_clk, _slow_clk;

    slow_clk_gen scg(_slow_clk, clk, rst);

    assign slow_clk = ~sw[0] & _slow_clk;


    wire        reg_we;
    wire        mem_we;
    imm_src_e   imm_src;
    alu_op_e    alu_op;
    alu_src_e   alu_src;
    res_src_e   res_src;
    pc_src_e    pc_src;
    wire [31:0] instr;
    wire [31:0] alu_out;
    wire [31:0] mem_rd_data;
    wire [31:0] mem_wd_data;
    wire [31:0] pc;

    riscv rv(
        reg_we,
        mem_we,
        imm_src,
        alu_op,
        alu_src,
        res_src,
        pc_src,
        instr,
        alu_out,
        mem_rd_data,
        mem_wd_data,
        pc,
        rst,
        slow_clk
    );


    //
    // Logic to select type of data to be dumped to the leds
    //
    wire [2:0] _sw;

    assign _sw = sw[3:1];


    wire [7:0] alu_out8, pc8;

    assign alu_out8 = alu_out[7:0];
    assign pc8 = pc[7:0];


    always_comb begin
        case (_sw)
        3'b000:  leds = {pc8, alu_out8};
        default: leds = 16'hffff;
        endcase
    end

endmodule
