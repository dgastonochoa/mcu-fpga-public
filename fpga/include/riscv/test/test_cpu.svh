`ifndef TEST_CPU_SVH
`define TEST_CPU_SVH

`define CPU_R_SP            2

`define CPU_GET_R(cpu, idx)     cpu.dp.rf._reg[idx]
`define CPU_SET_R(cpu, idx, d)  cpu.dp.rf._reg[idx] = d


`define DECL_REG_X0(cpu)        \
    wire [31:0] x0;             \
    assign x0 = cpu.dp.rf._reg[0]

`define DECL_REG_RA(cpu)        \
    wire [31:0] ra;             \
    assign ra = cpu.dp.rf._reg[1]

`define DECL_REG_SP(cpu)        \
    wire [31:0] sp;             \
    assign sp = cpu.dp.rf._reg[2]

`define DECL_REG_GP(cpu)        \
    wire [31:0] gp;             \
    assign gp = cpu.dp.rf._reg[3]

`define DECL_REG_TP(cpu)        \
    wire [31:0] tp;             \
    assign tp = cpu.dp.rf._reg[4]

`define DECL_REG_T0(cpu)        \
    wire [31:0] t0;             \
    assign t0 = cpu.dp.rf._reg[5]

`define DECL_REG_T1(cpu)        \
    wire [31:0] t1;             \
    assign t1 = cpu.dp.rf._reg[6]

`define DECL_REG_T2(cpu)        \
    wire [31:0] t2;             \
    assign t2 = cpu.dp.rf._reg[7]

`define DECL_REG_S0(cpu)        \
    wire [31:0] s0;             \
    assign s0 = cpu.dp.rf._reg[8]

`define DECL_REG_S1(cpu)        \
    wire [31:0] s1;             \
    assign s1 = cpu.dp.rf._reg[9]

`define DECL_REG_A0(cpu)        \
    wire [31:0] a0;             \
    assign a0 = cpu.dp.rf._reg[10]

`define DECL_REG_A1(cpu)        \
    wire [31:0] a1;             \
    assign a1 = cpu.dp.rf._reg[11]

`define DECL_REG_A2(cpu)        \
    wire [31:0] a2;             \
    assign a2 = cpu.dp.rf._reg[12]

`define DECL_REG_A3(cpu)        \
    wire [31:0] a3;             \
    assign a3 = cpu.dp.rf._reg[13]

`define DECL_REG_A4(cpu)        \
    wire [31:0] a4;             \
    assign a4 = cpu.dp.rf._reg[14]

`define DECL_REG_A5(cpu)        \
    wire [31:0] a5;             \
    assign a5 = cpu.dp.rf._reg[15]

`define DECL_REG_A6(cpu)        \
    wire [31:0] a6;             \
    assign a6 = cpu.dp.rf._reg[16]

`define DECL_REG_A7(cpu)        \
    wire [31:0] a7;             \
    assign a7 = cpu.dp.rf._reg[17]

`define DECL_REG_S2(cpu)        \
    wire [31:0] s2;             \
    assign s2 = cpu.dp.rf._reg[18]

`define DECL_REG_S3(cpu)        \
    wire [31:0] s3;             \
    assign s3 = cpu.dp.rf._reg[19]

`define DECL_REG_S4(cpu)        \
    wire [31:0] s4;             \
    assign s4 = cpu.dp.rf._reg[20]

`define DECL_REG_S5(cpu)        \
    wire [31:0] s5;             \
    assign s5 = cpu.dp.rf._reg[21]

`define DECL_REG_S6(cpu)        \
    wire [31:0] s6;             \
    assign s6 = cpu.dp.rf._reg[22]

`define DECL_REG_S7(cpu)        \
    wire [31:0] s7;             \
    assign s7 = cpu.dp.rf._reg[23]

`define DECL_REG_S8(cpu)        \
    wire [31:0] s8;             \
    assign s8 = cpu.dp.rf._reg[24]

`define DECL_REG_S9(cpu)        \
    wire [31:0] s9;             \
    assign s9 = cpu.dp.rf._reg[25]

`define DECL_REG_S10(cpu)       \
    wire [31:0] s10;            \
    assign s10 = cpu.dp.rf._reg[26]

`define DECL_REG_S11(cpu)       \
    wire [31:0] s11;            \
    assign s11 = cpu.dp.rf._reg[27]

`define DECL_REG_T3(cpu)        \
    wire [31:0] t3;             \
    assign t3 = cpu.dp.rf._reg[28]

`define DECL_REG_T4(cpu)        \
    wire [31:0] t4;             \
    assign t4 = cpu.dp.rf._reg[29]

`define DECL_REG_T5(cpu)        \
    wire [31:0] t5;             \
    assign t5 = cpu.dp.rf._reg[30]

`define DECL_REG_T6(cpu)        \
    wire [31:0] t6;             \
    assign t6 = cpu.dp.rf._reg[31]

`define DECL_REG_PC(cpu)        \
    wire [31:0] pc;             \
    assign pc = cpu.pc

`define DECL_REG_ALL(cpu)   \
    `DECL_REG_X0(cpu);      \
    `DECL_REG_RA(cpu);      \
    `DECL_REG_SP(cpu);      \
    `DECL_REG_GP(cpu);      \
    `DECL_REG_TP(cpu);      \
    `DECL_REG_T0(cpu);      \
    `DECL_REG_T1(cpu);      \
    `DECL_REG_T2(cpu);      \
    `DECL_REG_S0(cpu);      \
    `DECL_REG_S1(cpu);      \
    `DECL_REG_A0(cpu);      \
    `DECL_REG_A1(cpu);      \
    `DECL_REG_A2(cpu);      \
    `DECL_REG_A3(cpu);      \
    `DECL_REG_A4(cpu);      \
    `DECL_REG_A5(cpu);      \
    `DECL_REG_A6(cpu);      \
    `DECL_REG_A7(cpu);      \
    `DECL_REG_S2(cpu);      \
    `DECL_REG_S3(cpu);      \
    `DECL_REG_S4(cpu);      \
    `DECL_REG_S5(cpu);      \
    `DECL_REG_S6(cpu);      \
    `DECL_REG_S7(cpu);      \
    `DECL_REG_S8(cpu);      \
    `DECL_REG_S9(cpu);      \
    `DECL_REG_S10(cpu);     \
    `DECL_REG_S11(cpu);     \
    `DECL_REG_T3(cpu);      \
    `DECL_REG_T4(cpu);      \
    `DECL_REG_T5(cpu);      \
    `DECL_REG_T6(cpu);      \
    `DECL_REG_PC(cpu)


`endif // TEST_CPU_SVH