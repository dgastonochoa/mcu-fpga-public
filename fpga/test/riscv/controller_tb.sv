`timescale 10ps/1ps

`include "alu.vh"
`include "riscv/datapath.vh"

`ifndef VCD
    `define VCD "controller_tb.vcd"
`endif

module controller_tb;
    reg [31:0] instr;
    reg [3:0] alu_flags;

    wire reg_we, mem_we, alu_src, pc_src;
    wire [1:0] imm_src, res_src;
    wire [2:0] alu_ctrl;

    controller ctrl(
        instr,
        alu_flags,
        reg_we,
        mem_we,
        alu_src,
        res_src,
        pc_src,
        imm_src,
        alu_ctrl
    );

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, controller_tb);

        //
        // lw
        //
        instr = 32'hffc4a303;
        alu_flags = 4'b0;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_ext_imm);
            assert(res_src === res_src_read_data);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === imm_src_itype);
            assert(alu_ctrl === alu_op_add);

        alu_flags = 4'b0100;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_ext_imm);
            assert(res_src === res_src_read_data);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === imm_src_itype);
            assert(alu_ctrl === alu_op_add);

        //
        // sw
        //
        alu_flags = 4'b0;
        instr = 32'h0064a423;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b1);
            assert(alu_src === alu_src_ext_imm);
            assert(res_src === res_src_read_data);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === imm_src_stype);
            assert(alu_ctrl === alu_op_add);

        alu_flags = 4'b0100;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b1);
            assert(alu_src === alu_src_ext_imm);
            assert(res_src === res_src_read_data);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === imm_src_stype);
            assert(alu_ctrl === alu_op_add);

        //
        // or
        //
        alu_flags = 4'b0;
        instr = 32'h0062e233;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_reg);
            assert(res_src === res_src_alu_out);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === 2'bx);
            assert(alu_ctrl === alu_op_or);

        alu_flags = 4'b0100;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_reg);
            assert(res_src === res_src_alu_out);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === 2'bx);
            assert(alu_ctrl === alu_op_or);

        //
        // beq
        //
        alu_flags = 4'b0;
        instr = 32'hfe420ae3;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_reg);
            assert(res_src === 2'bx);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === imm_src_btype);
            assert(alu_ctrl === alu_op_sub);

        alu_flags = 4'b0100;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_reg);
            assert(res_src === 2'bx);
            assert(pc_src === pc_src_plus_off);
            assert(imm_src === imm_src_btype);
            assert(alu_ctrl === alu_op_sub);

        //
        // addi
        //
        alu_flags = 4'b0;
        instr = 32'h00a00213;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_ext_imm);
            assert(res_src === res_src_alu_out);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === imm_src_itype);
            assert(alu_ctrl === alu_op_add);

        alu_flags = 4'b0100;
        instr = 32'h00a00213;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_ext_imm);
            assert(res_src === res_src_alu_out);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === imm_src_itype);
            assert(alu_ctrl === alu_op_add);

        //
        // jal
        //
        alu_flags = 4'b0;
        instr = 32'h00a00213;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_ext_imm);
            assert(res_src === res_src_alu_out);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === imm_src_itype);
            assert(alu_ctrl === alu_op_add);

        alu_flags = 4'b0100;
        instr = 32'h00a00213;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_ext_imm);
            assert(res_src === res_src_alu_out);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === imm_src_itype);
            assert(alu_ctrl === alu_op_add);

        $finish;
    end


endmodule
