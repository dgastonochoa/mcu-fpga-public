module mem_pipeline(
    input  wire     flush,
    input  wire     stall,
    input  mem_dt_e dt,
    input  wire     m_we,
    output mem_dt_e dt_m,
    output wire     m_we_m,
    input           clk,
    input           rst
);
    // TODO this requires flush
    mem_dt_e dt_d, dt_e;
    wire m_we_d, m_we_e;

    clear_dff #(.N(5)) dff_decode(
        {dt,   m_we},
        ~stall,
        {dt_d, m_we_d},
        flush,
        clk,
        rst
    );

    clear_dff #(.N(5)) dff_execute(
        {dt_d, m_we_d},
        ~stall,
        {dt_e, m_we_e},
        stall | flush,
        clk,
        rst
    );

    dff #(.N(5)) dff_mem(
        {dt_e, m_we_e},
        1'b1,
        {dt_m, m_we_m},
        clk,
        rst
    );
endmodule