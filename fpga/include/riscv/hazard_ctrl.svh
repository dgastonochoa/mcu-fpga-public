`ifndef HAZARD_CTRL_H
`define HAZARD_CTRL_H

typedef enum logic [3:0]
{
    FORW_NO         = 4'd0,
    FORW_ALU_OUT_M  = 4'd1,
    FORW_ALU_OUT_W  = 4'd2
} fw_type_e;

`endif // HAZARD_CTRL_H