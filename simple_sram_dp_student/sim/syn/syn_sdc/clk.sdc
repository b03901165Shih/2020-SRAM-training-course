# operating conditions and boundary conditions #

set cycle 3.000


create_clock -period $cycle [get_ports  CLK]
set_dont_touch_network      [get_clocks CLK]
set_ideal_network           [get_ports  CLK]

set_clock_uncertainty  0.1  [get_clocks CLK]
set_clock_latency      0.1  [get_clocks CLK]
set_fix_hold                [get_clocks CLK]
set_input_transition   0.1  [all_inputs]
set_clock_transition   0.1  [all_clocks]

set_load         0.1     	[all_outputs]
set_drive        1     		[all_inputs]


set_max_area        0
set_max_fanout      20  sram_wrapper
set_max_transition  1   sram_wrapper

set_input_delay  0.0   -clock CLK [remove_from_collection [all_inputs] [get_ports {CLK}]] -clock_fall
set_output_delay 0.0   -clock CLK [all_outputs] -clock_fall

set_operating_conditions -min_library sc9_cln40g_base_rvt_ff_typical_min_0p99v_m40c -min ff_typical_min_0p99v_m40c \
                         -max_library sc9_cln40g_base_rvt_ss_typical_max_0p81v_125c -max ss_typical_max_0p81v_125c  
set_wire_load_model -name Small -library sc9_cln40g_base_rvt_ss_typical_max_0p81v_125c
set_max_fanout 20 [all_inputs]

# identify false path for dual port memory (Otherwise hold time violation will be reported)
set_false_path -from [get_clocks CLK]  -to [get_pins */CLKB]
set_false_path -from [get_clocks CLK]  -to [get_pins */CLKA]