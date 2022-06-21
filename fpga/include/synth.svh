`ifndef SYNTH_H
`define SYNTH_H

// SystemVerilog cast operator not currently supported
// in Icarus Verilog
`ifndef IVERILOG
    `define CAST(_type, elem) _type'(elem)
`else
    `define CAST(_type, elem) elem
`endif

`endif // SYNTH_H
