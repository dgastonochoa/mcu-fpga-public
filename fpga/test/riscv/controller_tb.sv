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
    wire [3:0] alu_ctrl;

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

        //
        // add
        //
        alu_flags = 4'b0;
        instr = 32'h003180b3;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_reg);
            assert(res_src === res_src_alu_out);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === 2'bx);
            assert(alu_ctrl === alu_op_add);

        //
        // sub
        //
        alu_flags = 4'b0;
        instr = 32'h403180b3;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_reg);
            assert(res_src === res_src_alu_out);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === 2'bx);
            assert(alu_ctrl === alu_op_sub);

        //
        // and
        //
        alu_flags = 4'b0;
        instr = 32'h0031f0b3;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_reg);
            assert(res_src === res_src_alu_out);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === 2'bx);
            assert(alu_ctrl === alu_op_and);

        //
        // xor
        //
        alu_flags = 4'b0;
        instr = 32'h0031c0b3;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_reg);
            assert(res_src === res_src_alu_out);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === 2'bx);
            assert(alu_ctrl === alu_op_xor);

        //
        // sll
        //
        alu_flags = 4'b0;
        instr = 32'h003190b3;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_reg);
            assert(res_src === res_src_alu_out);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === 2'bx);
            assert(alu_ctrl === alu_op_sll);

        //
        // srl
        //
        alu_flags = 4'b0;
        instr = 32'h0031d0b3;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_reg);
            assert(res_src === res_src_alu_out);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === 2'bx);
            assert(alu_ctrl === alu_op_srl);

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
        // bne
        //
        alu_flags = 4'b0;
        instr = 32'h00311863;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_reg);
            assert(res_src === 2'bx);
            assert(pc_src === pc_src_plus_off);
            assert(imm_src === imm_src_btype);
            assert(alu_ctrl === alu_op_sub);

        alu_flags = 4'b0100;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_reg);
            assert(res_src === 2'bx);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === imm_src_btype);
            assert(alu_ctrl === alu_op_sub);

        //
        // blt
        //
        alu_flags = 4'b1000;
        instr = 32'h00314863;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_reg);
            assert(res_src === 2'bx);
            assert(pc_src === pc_src_plus_off);
            assert(imm_src === imm_src_btype);
            assert(alu_ctrl === alu_op_sub);

        alu_flags = 4'b0000;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_reg);
            assert(res_src === 2'bx);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === imm_src_btype);
            assert(alu_ctrl === alu_op_sub);

        //
        // bge
        //
        alu_flags = 4'b1000;
        instr = 32'h00315863;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_reg);
            assert(res_src === 2'bx);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === imm_src_btype);
            assert(alu_ctrl === alu_op_sub);

        alu_flags = 4'b0000;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_reg);
            assert(res_src === 2'bx);
            assert(pc_src === pc_src_plus_off);
            assert(imm_src === imm_src_btype);
            assert(alu_ctrl === alu_op_sub);

        //
        // bltu
        //
        alu_flags = 4'b0000;
        instr = 32'h00316863;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_reg);
            assert(res_src === 2'bx);
            assert(pc_src === pc_src_plus_off);
            assert(imm_src === imm_src_btype);
            assert(alu_ctrl === alu_op_sub);

        alu_flags = 4'b0010;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_reg);
            assert(res_src === 2'bx);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === imm_src_btype);
            assert(alu_ctrl === alu_op_sub);

        //
        // bgeu
        //
        alu_flags = 4'b0000;
        instr = 32'h00317863;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src === alu_src_reg);
            assert(res_src === 2'bx);
            assert(pc_src === pc_src_plus_4);
            assert(imm_src === imm_src_btype);
            assert(alu_ctrl === alu_op_sub);

        alu_flags = 4'b0010;
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

        $finish;
    end


endmodule
