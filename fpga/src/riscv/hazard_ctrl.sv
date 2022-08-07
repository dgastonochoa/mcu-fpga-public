`include "riscv/datapath.svh"
`include "riscv/hazard_ctrl.svh"

/**
 * Decodes the type of forwarding required given the inputs.
 *
 */
module forward_dec(
    input  wire [4:0]      rf_src_e,
    input  wire [4:0]      rf_dst_m,
    input  wire [4:0]      rf_dst_w,
    input  wire            rf_we_m,
    input  wire            rf_we_w,
    output fw_type_e  fw_t
);
    wire nz, fw_alu_out_m, fw_alu_out_w;

    assign nz           = (rf_src_e != 5'd0);
    assign fw_alu_out_m = rf_we_m & (rf_src_e == rf_dst_m);
    assign fw_alu_out_w = rf_we_w & (rf_src_e == rf_dst_w);

    wire [2:0] flags;

    assign flags = {nz, fw_alu_out_m, fw_alu_out_w};

    always_comb begin
        case (flags)
        3'b110:  fw_t = FORW_ALU_OUT_M;
        3'b101:  fw_t = FORW_ALU_OUT_W;
        3'b111:  fw_t = FORW_ALU_OUT_M;
        default: fw_t = FORW_NO;
        endcase
    end
endmodule

/**
 * Hazard controller.
 *
 * @param a1_d Register file address 1, decode stage
 * @param a2_d Register file address 2, decode stage
 * @param a1_e Register file address 1, execute stage
 * @param a2_e Register file address 2, execute stage
 * @param a3_e Register file address 3, execute stage
 * @param a3_m Register file address 3, memory stage
 * @param a3_w Register file address 3, writeback stage
 * @param rf_we_m Register file write enable, memory stage.
 * @param rf_we_w Register file write enable, writeback stage.
 * @param result_src_e Result source, execute state.
 * @param ps_e PC source, execute state.
 * @param fw_type_a Decoded forward type for the register read value 1.
 * @param fw_type_2 Decoded forward type for the register read value 2.
 * @param stall Stall signal (indicates the pipeline must be stalled).
 * @param flush Flush signal (used in conjunction with 'stall'; indicates
 *              whether or not certain pipeline registers need to be cleared).
 *
 */
module hazard_ctrl(
    input  wire [4:0]       a1_d,
    input  wire [4:0]       a2_d,
    input  wire [4:0]       a1_e,
    input  wire [4:0]       a2_e,
    input  wire [4:0]       a3_e,
    input  wire [4:0]       a3_m,
    input  wire [4:0]       a3_w,
    input  wire             rf_we_m,
    input  wire             rf_we_w,
    input  res_src_e        result_src_e,
    input  pc_src_e         ps_e,
    output fw_type_e        fw_type_a,
    output fw_type_e        fw_type_b,
    output logic            stall,
    output wire             flush
);
    forward_dec fda(a1_e, a3_m, a3_w, rf_we_m, rf_we_w, fw_type_a);
    forward_dec fdb(a2_e, a3_m, a3_w, rf_we_m, rf_we_w, fw_type_b);

    assign stall =
        (result_src_e == RES_SRC_MEM) && ((a3_e == a1_d) || (a3_e == a2_d));

    assign flush = ps_e != PC_SRC_PLUS_4;
endmodule
