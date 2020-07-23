# Import Design
read_file -format verilog  ../sram_wrapper.v
current_design sram_wrapper
link

set_attribute [get_libs {sc9_cln40g_base_hvt_ss_typical_max_0p81v_125c sc9_cln40g_base_hvt_ff_typical_min_0p99v_m40c}] -type string default_threshold_voltage_group hvt
set_attribute [get_libs {sc9_cln40g_base_lvt_ss_typical_max_0p81v_125c sc9_cln40g_base_lvt_ff_typical_min_0p99v_m40c}]  -type string default_threshold_voltage_group lvt
set_boundary_optimization "*"

set high_fanout_net_threshold 0
set_fix_multiple_port_nets -feedthroughs
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]
set verilogout_no_tri TRUE
set compile_top_all_paths "true"

set_host_options -max_cores 16
source -verbose -echo ./syn_sdc/clk.sdc
uniquify

compile

# --Ultra---
#compile_ultra -retime
#compile_ultra -inc
#optimize_netlist -area
#compile_ultra -inc -only_design_rule
#compile -inc -only_hold_time


#===================================================================================================#

remove_unconnected_ports -blast_buses [get_cells -hierarchical *]
set bus_inference_style {%s[%d]}
set bus_naming_style {%s[%d]}
set hdlout_internal_busses true
change_names -hierarchy -rule verilog
define_name_rules name_rule -allowed {a-z A-Z 0-9 _} -max_length 255 -type cell
define_name_rules name_rule -allowed {a-z A-Z 0-9 _[]} -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
define_name_rules name_rule -case_insensitive
change_names -hierarchy -rules name_rule


write -format ddc     -hierarchy -output ../sram_wrapper_syn.ddc
write -format verilog -hierarchy -output ../sram_wrapper_syn.v
write_sdf -version 2.1 ../sram_wrapper_syn.sdf

report_area
report_constraints