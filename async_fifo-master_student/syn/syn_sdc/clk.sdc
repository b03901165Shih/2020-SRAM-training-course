# operating conditions and boundary conditions #

set cycle1 10.00
set cycle2 3.00


create_clock -name rclk -period $cycle1 [get_ports  rclk]
create_clock -name wclk -period $cycle2 [get_ports  wclk]

set_dont_touch_network      [all_clocks]
set_ideal_network           [get_ports  rclk]
set_ideal_network           [get_ports  wclk]

set_clock_uncertainty  0.1  [all_clocks]
set_clock_latency      0.1  [all_clocks]
set_fix_hold                [all_clocks]
set_input_transition   0.1  [all_inputs]
set_clock_transition   0.1  [all_clocks]

set_load         0.1     	[all_outputs]
set_drive        1     		[all_inputs]


set_input_delay  0.0   -clock wclk [remove_from_collection [all_inputs] [get_ports {wclk rclk rrst_n rinc}]] -clock_fall
set_input_delay  0.0   -clock rclk [remove_from_collection [all_inputs] [get_ports {wclk rclk wrst_n winc wdata}]] -clock_fall
set_output_delay 0.0   -clock wclk [get_ports {wfull awfull}] -clock_fall
set_output_delay 0.0   -clock rclk [get_ports {rempty arempty rdata}] -clock_fall

set_operating_conditions -min_library sc9_cln40g_base_rvt_ff_typical_min_0p99v_m40c -min ff_typical_min_0p99v_m40c \
                         -max_library sc9_cln40g_base_rvt_ss_typical_max_0p81v_125c -max ss_typical_max_0p81v_125c  
set_wire_load_model -name Small -library sc9_cln40g_base_rvt_ss_typical_max_0p81v_125c
set_max_fanout 20 [all_inputs]

set_false_path -from wclk  -to rclk
set_false_path -from rclk  -to wclk                         
