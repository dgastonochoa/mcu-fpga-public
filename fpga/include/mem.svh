`ifndef MEM_SVH
`define MEM_SVH

typedef enum bit [2:0]
{
    MEM_DT_BYTE     = 3'b000,
    MEM_DT_HALF     = 3'b001,
    MEM_DT_WORD     = 3'b010,
    MEM_DT_UBYTE    = 3'b100,
    MEM_DT_UHALF    = 3'b101
} mem_dt_e;

`endif // MEM_SVH
