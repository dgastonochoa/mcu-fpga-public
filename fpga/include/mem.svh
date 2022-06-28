`ifndef MEM_SVH
`define MEM_SVH

/**
 * Data type to be read/write.
 *
 * BYTE and HALF will fill the upper 8/16 bytes with the result's MSB on
 * read. UBYTE and UHALF will fill these bits with 0.
 *
 * On write, the BYTE/HALF/WORD will be written as it is, therefore
 * BYTE is equivalent to UBYTE and HALF to UHALF in write ops.
 */
typedef enum logic [2:0]
{
    MEM_DT_BYTE     = 3'b000,
    MEM_DT_HALF     = 3'b001,
    MEM_DT_WORD     = 3'b010,
    MEM_DT_UBYTE    = 3'b011,
    MEM_DT_UHALF    = 3'b100
} mem_dt_e;

`endif // MEM_SVH
