`timescale 10ps/1ps

`include "alu.svh"
`include "mem.svh"
`include "riscv/datapath.svh"

`include "riscv_test_utils.svh"

`ifndef VCD
    `define VCD "controller_multicycle_tb.vcd"
`endif

module controller_multicycle_tb;
    reg [31:0] instr;
    reg [3:0] alu_flags;

    wire rf_we, m_we, en_ir, en_npc_r, en_oldpc_r, m_addr_src;
    alu_src_e alu_src_a;
    alu_src_e alu_src_b;
    res_src_e res_src;
    imm_src_e imm_src;
    rf_wd_src_e rf_wd_src;
    alu_op_e alu_ctrl;
    mem_dt_e dt;

    reg clk = 0, rst;

    // TODO review order of rst, clk in all modules
    // TODO review name of controllers single and multicycle
    controller_multicycle ctrl(
        instr,
        alu_flags,
        rf_we,
        m_we,
        alu_src_a,
        alu_src_b,
        res_src,
        imm_src,
        rf_wd_src,
        alu_ctrl,
        dt,
        en_ir,
        en_npc_r,
        en_oldpc_r,
        m_addr_src,
        clk,
        rst
    );

    always #10 clk = ~clk;

    wire [3:0] __cs;

    assign __cs = ctrl.cs;

    initial begin
        $dumpfile(`VCD);
        $dumpvars(1, controller_multicycle_tb);

        //
        // lw
        //
        instr = 32'hffc4a303;
        alu_flags = 4'b0;
        #2  rst = 1;
        #2  rst = 0;
            assert(rf_we === 1'b0);
            assert(m_we === 1'b0);
            assert(alu_src_a === ALU_SRC_PC);
            assert(alu_src_b === ALU_SRC_4);
            assert(res_src === RES_SRC_ALU_OUT);
            assert(imm_src === IMM_SRC_NONE);
            assert(rf_wd_src === RF_WD_SRC_NONE);
            assert(alu_ctrl === ALU_OP_ADD);
            assert(dt === MEM_DT_WORD);
            assert(en_ir === 1'b1);
            assert(en_npc_r === 1'b0);
            assert(en_oldpc_r === 1'b1);
            assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_ITYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b1);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_MEM);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // lb
        //
        alu_flags = 4'b0;
        instr = 32'h01410083;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_ITYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_BYTE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_BYTE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b1);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_MEM);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // lh
        //
        alu_flags = 4'b0;
        instr = 32'hffc49303;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_ITYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_HALF);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_HALF);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b1);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_MEM);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // lbu
        //
        alu_flags = 4'b0;
        instr = 32'hffc4c303;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_ITYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_UBYTE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_UBYTE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b1);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_MEM);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // lhu
        //
        alu_flags = 4'b0;
        instr = 32'hffc4d303;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_ITYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_UHALF);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_UHALF);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b1);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_MEM);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // sw
        //
        alu_flags = 4'b0;
        instr = 32'h0064a423;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_STYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b1);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b1);

        //
        // sb
        //
        alu_flags = 4'b0;
        instr = 32'hfe648e23;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_STYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_BYTE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b1);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_BYTE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b1);

        //
        // sh
        //
        alu_flags = 4'b0;
        instr = 32'hfe649e23;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_STYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_HALF);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b1);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_HALF);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b1);

        //
        // or
        //
        alu_flags = 4'b0;
        instr = 32'h0062e233;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_OR);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // sra
        //
        alu_flags = 4'b0;
        instr = 32'h4062d233;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SRA);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // slt
        //
        alu_flags = 4'b0;
        instr = 32'h0062a233;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SLT);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // sltu
        //
        alu_flags = 4'b0;
        instr = 32'h0062b233;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SLTU);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // add
        //
        alu_flags = 4'b0;
        instr = 32'h003180b3;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // sub
        //
        alu_flags = 4'b0;
        instr = 32'h403180b3;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SUB);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // and
        //
        alu_flags = 4'b0;
        instr = 32'h0031f0b3;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_AND);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // xor
        //
        alu_flags = 4'b0;
        instr = 32'h0031c0b3;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_XOR);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // sll
        //
        alu_flags = 4'b0;
        instr = 32'h003190b3;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SLL);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // srl
        //
        alu_flags = 4'b0;
        instr = 32'h0031d0b3;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SRL);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // beq
        //
        alu_flags = 4'b0;
        instr = 32'hfe420ae3;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_BTYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SUB);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        alu_flags = 4'b0100;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_BTYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SUB);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // bne
        //
        alu_flags = 4'b0;
        instr = 32'h00311863;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_BTYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SUB);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        alu_flags = 4'b0100;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_BTYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SUB);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // blt
        //
        alu_flags = 4'b1000;
        instr = 32'h00314863;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_BTYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SUB);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        alu_flags = 4'b0000;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_BTYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SUB);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // bge
        //
        alu_flags = 4'b1000;
        instr = 32'h00315863;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_BTYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SUB);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        alu_flags = 4'b0000;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_BTYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SUB);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // bltu
        //
        alu_flags = 4'b0000;
        instr = 32'h00316863;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_BTYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SUB);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        alu_flags = 4'b0010;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_BTYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SUB);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // bgeu
        //
        alu_flags = 4'b0000;
        instr = 32'h00317863;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_BTYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SUB);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        alu_flags = 4'b0010;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_BTYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_REG_2);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SUB);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // addi
        //
        alu_flags = 4'b0;
        instr = 32'h00a00213;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_ITYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // andi
        //
        alu_flags = 4'b0;
        instr = 32'h0ff27013;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_ITYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_AND);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // srli
        //
        alu_flags = 4'b0;
        instr = 32'h00425013;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_ITYPE2);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SRL);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // ori
        //
        alu_flags = 4'b0;
        instr = 32'h0fe26013;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_ITYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_OR);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // slli
        //
        alu_flags = 4'b0;
        instr = 32'h00421013;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_ITYPE2);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SLL);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // slti
        //
        alu_flags = 4'b0;
        instr = 32'h0022a213;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_ITYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SLT);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // sltiu
        //
        alu_flags = 4'b0;
        instr = 32'h0022b213;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_ITYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SLTU);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // srai
        //
        alu_flags = 4'b0;
        instr = 32'h4022d213;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_ITYPE2);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_SRA);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // xori
        //
        alu_flags = 4'b0;
        instr = 32'h0152c013;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_ITYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_XOR);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // jal
        //
        alu_flags = 4'b0;
        instr = 32'h0000016f; // TODO fix jal test in single-cycle
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_JTYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_PC);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // jalr
        //
        alu_flags = 4'b0;
        instr = 32'h019080e7;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_REG_1);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_ITYPE);
                                assert(rf_wd_src === RF_WD_SRC_PC);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // auipc
        //
        alu_flags = 4'b0;
        instr = 32'h00014097;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_UTYPE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_RES);
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        //
        // lui
        //
        alu_flags = 4'b0;
        instr = 32'h000ff3b7;
        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC);
                                assert(alu_src_b === ALU_SRC_4);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_WORD);
                                assert(en_ir === 1'b1);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b1);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b0);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_PC_OLD);
                                assert(alu_src_b === ALU_SRC_EXT_IMM);
                                assert(res_src === RES_SRC_ALU_OUT);
                                assert(imm_src === IMM_SRC_NONE);
                                assert(rf_wd_src === RF_WD_SRC_NONE);
                                assert(alu_ctrl === ALU_OP_ADD);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b1);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        `WAIT_INSTR_C(clk, 1)   assert(rf_we === 1'b1);
                                assert(m_we === 1'b0);
                                assert(alu_src_a === ALU_SRC_NONE);
                                assert(alu_src_b === ALU_SRC_NONE);
                                assert(res_src === RES_SRC_NONE);
                                assert(imm_src === IMM_SRC_UTYPE);
                                assert(rf_wd_src === RF_WD_SRC_IMM); // TODO: this could go through result mux
                                assert(alu_ctrl === ALU_OP_NONE);
                                assert(dt === MEM_DT_NONE);
                                assert(en_ir === 1'b0);
                                assert(en_npc_r === 1'b0);
                                assert(en_oldpc_r === 1'b0);
                                assert(m_addr_src === 1'b0);

        $finish;
    end


endmodule
