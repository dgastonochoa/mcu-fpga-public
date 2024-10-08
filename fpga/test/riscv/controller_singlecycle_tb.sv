`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "riscv/datapath.svh"

`ifndef VCD
    `define VCD "controller_singlecycle_tb.vcd"
`endif

module controller_singlecycle_tb;
    reg [31:0] instr;
    reg [3:0] alu_flags;

    wire reg_we, mem_we;
    res_src_e res_src;
    pc_src_e pc_src;
    alu_src_e alu_src_a, alu_src_b;
    imm_src_e imm_src;
    alu_op_e alu_ctrl;
    mem_dt_e dt;

    controller ctrl(
        instr,
        alu_flags,
        reg_we,
        mem_we,
        alu_src_a,
        alu_src_b,
        res_src,
        pc_src,
        imm_src,
        alu_ctrl,
        dt
    );

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, controller_singlecycle_tb);

        //
        // lw
        //
        instr = 32'hffc4a303;
        alu_flags = 4'b0;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_MEM);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_ITYPE);
            assert(alu_ctrl === ALU_OP_ADD);
            assert(dt === MEM_DT_WORD);

        //
        // sw
        //
        alu_flags = 4'b0;
        instr = 32'h0064a423;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b1);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === 4'hf);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_STYPE);
            assert(alu_ctrl === ALU_OP_ADD);
            assert(dt === MEM_DT_WORD);

        //
        // or
        //
        alu_flags = 4'b0;
        instr = 32'h0062e233;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === 4'hf);
            assert(alu_ctrl === ALU_OP_OR);

        //
        // add
        //
        alu_flags = 4'b0;
        instr = 32'h003180b3;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === 4'hf);
            assert(alu_ctrl === ALU_OP_ADD);

        //
        // sub
        //
        alu_flags = 4'b0;
        instr = 32'h403180b3;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === 4'hf);
            assert(alu_ctrl === ALU_OP_SUB);

        //
        // and
        //
        alu_flags = 4'b0;
        instr = 32'h0031f0b3;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === 4'hf);
            assert(alu_ctrl === ALU_OP_AND);

        //
        // xor
        //
        alu_flags = 4'b0;
        instr = 32'h0031c0b3;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === 4'hf);
            assert(alu_ctrl === ALU_OP_XOR);

        //
        // sll
        //
        alu_flags = 4'b0;
        instr = 32'h003190b3;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === 4'hf);
            assert(alu_ctrl === ALU_OP_SLL);

        //
        // srl
        //
        alu_flags = 4'b0;
        instr = 32'h0031d0b3;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === 4'hf);
            assert(alu_ctrl === ALU_OP_SRL);

        //
        // beq
        //
        alu_flags = 4'b0;
        instr = 32'hfe420ae3;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_NONE);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_BTYPE);
            assert(alu_ctrl === ALU_OP_SUB);

        alu_flags = 4'b0100;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_NONE);
            assert(pc_src === PC_SRC_PLUS_OFF);
            assert(imm_src === IMM_SRC_BTYPE);
            assert(alu_ctrl === ALU_OP_SUB);

        //
        // bne
        //
        alu_flags = 4'b0;
        instr = 32'h00311863;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_NONE);
            assert(pc_src === PC_SRC_PLUS_OFF);
            assert(imm_src === IMM_SRC_BTYPE);
            assert(alu_ctrl === ALU_OP_SUB);

        alu_flags = 4'b0100;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_NONE);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_BTYPE);
            assert(alu_ctrl === ALU_OP_SUB);

        //
        // blt
        //
        alu_flags = 4'b1000;
        instr = 32'h00314863;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_NONE);
            assert(pc_src === PC_SRC_PLUS_OFF);
            assert(imm_src === IMM_SRC_BTYPE);
            assert(alu_ctrl === ALU_OP_SUB);

        alu_flags = 4'b0000;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_NONE);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_BTYPE);
            assert(alu_ctrl === ALU_OP_SUB);

        //
        // bge
        //
        alu_flags = 4'b1000;
        instr = 32'h00315863;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_NONE);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_BTYPE);
            assert(alu_ctrl === ALU_OP_SUB);

        alu_flags = 4'b0000;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_NONE);
            assert(pc_src === PC_SRC_PLUS_OFF);
            assert(imm_src === IMM_SRC_BTYPE);
            assert(alu_ctrl === ALU_OP_SUB);

        //
        // bltu
        //
        alu_flags = 4'b0000;
        instr = 32'h00316863;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_NONE);
            assert(pc_src === PC_SRC_PLUS_OFF);
            assert(imm_src === IMM_SRC_BTYPE);
            assert(alu_ctrl === ALU_OP_SUB);

        alu_flags = 4'b0010;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_NONE);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_BTYPE);
            assert(alu_ctrl === ALU_OP_SUB);

        //
        // bgeu
        //
        alu_flags = 4'b0000;
        instr = 32'h00317863;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_NONE);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_BTYPE);
            assert(alu_ctrl === ALU_OP_SUB);

        alu_flags = 4'b0010;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_NONE);
            assert(pc_src === PC_SRC_PLUS_OFF);
            assert(imm_src === IMM_SRC_BTYPE);
            assert(alu_ctrl === ALU_OP_SUB);

        //
        // addi
        //
        alu_flags = 4'b0;
        instr = 32'h00a00213;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_ITYPE);
            assert(alu_ctrl === ALU_OP_ADD);

        //
        // jal
        //
        alu_flags = 4'b0;
        instr = 32'h00a00213;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_ITYPE);
            assert(alu_ctrl === ALU_OP_ADD);

        //
        // sra
        //
        alu_flags = 4'b0;
        instr = 32'h4062d233;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === 4'hf);
            assert(alu_ctrl === ALU_OP_SRA);

        //
        // slt
        //
        alu_flags = 4'b0;
        instr = 32'h0062a233;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === 4'hf);
            assert(alu_ctrl === ALU_OP_SLT);

        //
        // sltu
        //
        alu_flags = 4'b0;
        instr = 32'h0062b233;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === 4'hf);
            assert(alu_ctrl === ALU_OP_SLTU);

        //
        // jalr
        //
        alu_flags = 4'b0;
        instr = 32'h019080e7;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === 4'hf);
            assert(res_src === RES_SRC_PC_PLUS_4);
            assert(pc_src === PC_SRC_REG_PLUS_OFF);
            assert(imm_src === IMM_SRC_ITYPE);
            assert(alu_ctrl === ALU_OP_NONE);

        //
        // auipc
        //
        alu_flags = 4'b0;
        instr = 32'h00014097;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_PC);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_UTYPE);
            assert(alu_ctrl === ALU_OP_ADD);

        //
        // andi
        //
        alu_flags = 4'b0;
        instr = 32'h0ff27013;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_ITYPE);
            assert(alu_ctrl === ALU_OP_AND);

        //
        // srli
        //
        alu_flags = 4'b0;
        instr = 32'h00425013;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_ITYPE2);
            assert(alu_ctrl === ALU_OP_SRL);

        //
        // ori
        //
        alu_flags = 4'b0;
        instr = 32'h0fe26013;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_ITYPE);
            assert(alu_ctrl === ALU_OP_OR);

        //
        // slli
        //
        alu_flags = 4'b0;
        instr = 32'h00421013;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_ITYPE2);
            assert(alu_ctrl === ALU_OP_SLL);

        //
        // slti
        //
        alu_flags = 4'b0;
        instr = 32'h0022a213;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_ITYPE);
            assert(alu_ctrl === ALU_OP_SLT);

        //
        // sltiu
        //
        alu_flags = 4'b0;
        instr = 32'h0022b213;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_ITYPE);
            assert(alu_ctrl === ALU_OP_SLTU);

        //
        // srai
        //
        alu_flags = 4'b0;
        instr = 32'h4022d213;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_ITYPE2);
            assert(alu_ctrl === ALU_OP_SRA);

        //
        // xori
        //
        alu_flags = 4'b0;
        instr = 32'h0152c013;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_ITYPE);
            assert(alu_ctrl === ALU_OP_XOR);

        //
        // lb
        //
        alu_flags = 4'b0;
        instr = 32'h01410083;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_MEM);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_ITYPE);
            assert(alu_ctrl === ALU_OP_ADD);
            assert(dt === MEM_DT_BYTE);

        //
        // lh
        //
        alu_flags = 4'b0;
        instr = 32'hffc49303;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_MEM);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_ITYPE);
            assert(alu_ctrl === ALU_OP_ADD);
            assert(dt === MEM_DT_HALF);

        //
        // lbu
        //
        alu_flags = 4'b0;
        instr = 32'hffc4c303;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_MEM);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_ITYPE);
            assert(alu_ctrl === ALU_OP_ADD);
            assert(dt === MEM_DT_UBYTE);

        //
        // lhu
        //
        alu_flags = 4'b0;
        instr = 32'hffc4d303;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === RES_SRC_MEM);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_ITYPE);
            assert(alu_ctrl === ALU_OP_ADD);
            assert(dt === MEM_DT_UHALF);

        //
        // sb
        //
        alu_flags = 4'b0;
        instr = 32'hfe648e23;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b1);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === 4'hf);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_STYPE);
            assert(alu_ctrl === ALU_OP_ADD);
            assert(dt === MEM_DT_BYTE);

        //
        // sh
        //
        alu_flags = 4'b0;
        instr = 32'hfe649e23;
        #5  assert(reg_we === 1'b0);
            assert(mem_we === 1'b1);
            assert(alu_src_a === ALU_SRC_REG_1);
            assert(res_src === 4'hf);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_STYPE);
            assert(alu_ctrl === ALU_OP_ADD);
            assert(dt === MEM_DT_HALF);

        //
        // lui
        //
        alu_flags = 4'b0;
        instr = 32'h000ff3b7;
        #5  assert(reg_we === 1'b1);
            assert(mem_we === 1'b0);
            assert(alu_src_a === 4'hf);
            assert(res_src === RES_SRC_EXT_IMM);
            assert(pc_src === PC_SRC_PLUS_4);
            assert(imm_src === IMM_SRC_UTYPE);
            assert(alu_ctrl === ALU_OP_NONE);

        $finish;
    end


endmodule
