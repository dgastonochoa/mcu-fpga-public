`ifndef MEM_SVH
`define MEM_SVH

typedef enum bit [1:0]
{
    MEM_DT_BYTE = 2'b00,
    MEM_DT_HALF = 2'b01,
    MEM_DT_WORD = 2'b10
} mem_dt_e;

`endif // MEM_SVH
