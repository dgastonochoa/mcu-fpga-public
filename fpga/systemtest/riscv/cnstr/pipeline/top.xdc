# System clock (100 MHz)
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports CLK100MHZ]

# It has been tested with Vivado that a factor of 3 or less causes timing violations after running implementation.
create_generated_clock -name cd/div_clk_r -source [get_ports CLK100MHZ] -divide_by 4 [get_pins cd/div_clk_r_reg/Q]

create_generated_clock -name m/spim/cd/div_clk_r -source [get_pins cd/div_clk_r_reg/Q] -divide_by 1560 [get_pins m/spim/cd/div_clk_r_reg/Q]

set_clock_groups -name SPI_m_sck -logically_exclusive -group [get_clocks {cd/div_clk_r sys_clk_pin}] -group [get_clocks m/spim/cd/div_clk_r]

# No input delay constraints required since the only input is a button placed on the very FPGA board.

# No output delay constrains required since the only outpus that go out of the board are those that correspond
# to the SPI interface. The SPI provides its own clock signal for the slave to sample the data, and since this
# SCK signal will naturally have approx. the same delay as the data, the delays get compensated.




