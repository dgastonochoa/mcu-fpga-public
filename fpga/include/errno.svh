`ifndef ERRNO_SVH
`define ERRNO_SVH

typedef enum logic
{
    ENONE = 1'b0,                       // Success
    EUNACCESS = 1'b1                    // Unaligned access
} errno_e;

`endif // ERRNO_SVH