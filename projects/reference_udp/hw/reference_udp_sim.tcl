# Vivado Launch Script
#### Change design settings here #######
set design reference_udp 
set top top
set sim_top top_tb
#set sim_top board
set device xc7vx690t-2-ffg1761
set proj_dir ./synth
set repo_dir ./ip_repo
set impl_constraints $::env(CONSTRAINTS)/vc709_generic.xdc
set bit_settings $::env(CONSTRAINTS)/vc709_generic_bit.xdc 
set project_constraints ./constraints/top.xdc
#####################################
# set IP paths
#####################################
set arbiter_ip $::env(IP_FOLDER)/input_arbiter/input_arbiter_v1_0_0.zip
# set arbiter_ip $::env(IP_FOLDER)/input_arbiter/component.xml
set output_port_lookup_ip $::env(IP_FOLDER)/output_port_lookup/output_port_lookup_v1_0_0.zip
set output_queues_ip $::env(IP_FOLDER)/output_queues/output_queues_v1_0_0.zip
set pcie_2_axilite_ip $::env(XILINX_IP_FOLDER)/pcie2axilite_bridge/component.xml
# set axi_lite_ipif_ip $::env(XILINX_PATH)/data/ip/xilinx/axi_lite_ipif_v2_0/component.xml
#####################################
# Project Settings
#####################################
create_project -name ${design} -force -dir "./${proj_dir}" -part ${device}
set_property source_mgmt_mode DisplayOnly [current_project]
set_property top ${top} [current_fileset]
puts "Creating User Datapath reference project"
#####################################
# Project Constraints
#####################################
create_fileset -constrset -quiet constraints
file mkdir ${repo_dir}
set_property ip_repo_paths ${repo_dir} [current_fileset]
add_files -fileset constraints -norecurse ${impl_constraints}
add_files -fileset constraints -norecurse ${bit_settings}
add_files -fileset constraints -norecurse ${project_constraints}
set_property is_enabled false [get_files ${impl_constraints}]
set_property is_enabled true [get_files ${project_constraints}]
set_property is_enabled true [get_files ${bit_settings}]
set_property constrset constraints [get_runs synth_1]
set_property constrset constraints [get_runs impl_1]
 
#####################################
# Project 
#####################################
update_ip_catalog
update_ip_catalog -add_ip ${arbiter_ip} -repo_path ${repo_dir}
update_ip_catalog -add_ip ${output_port_lookup_ip} -repo_path ${repo_dir}
update_ip_catalog -add_ip ${output_queues_ip} -repo_path ${repo_dir}
create_ip -name output_port_lookup -vendor NetFPGA -library NetFPGA -module_name nf10_output_port_lookup
set_property generate_synth_checkpoint false [get_files nf10_output_port_lookup.xci]
generate_target all [get_ips output_port_lookup]
create_ip -name input_arbiter -vendor NetFPGA -library NetFPGA -module_name nf10_input_arbiter
set_property generate_synth_checkpoint false [get_files nf10_input_arbiter.xci]
generate_target all [get_ips input_arbiter]
create_ip -name output_queues -vendor NetFPGA -library NetFPGA -module_name nf10_bram_output_queues
set_property generate_synth_checkpoint false [get_files nf10_bram_output_queues.xci]
generate_target all [get_ips output_queues]

#create the IPI Block Diagram
create_bd_design "pcie2axilite_sub"
update_ip_catalog -add_ip ${pcie_2_axilite_ip} -repo_path ${repo_dir}
source ./source/sim/pcie2axilite_sub_256_tb.tcl
validate_bd_design
save_bd_design

read_verilog "./source/nf10_datapath.v"
read_verilog "./source/sim/cq_axis_stimulus.v"
read_verilog "./source/sim/top_tb.v"
#read_verilog "./source/top_tb.v"
##Setting Synthesis options
#create_run -flow {Vivado Synthesis 2013} synth
##Setting Implementation options
#create_run impl -parent_run synth -flow {Vivado Implementation 2013} 
#set_property steps.phys_opt_design.is_enabled true [get_runs impl]
## The following implementation options will increase runtime, but get the best timing results
#set_property strategy Performance_Explore [get_runs impl]
## Solves synthesis crash in 2013.2
#set_param synth.filterSetMaxDelayWithDataPathOnly true
#launch_runs synth
#launch_runs impl_1 -to_step write_bitstream

####################
# Set up Simulations
set_property top ${sim_top} [get_filesets sim_1]
set_property include_dirs {${proj_dir} ./} [get_filesets sim_1]
 set_property verilog_define { {SIMULATION=1} } [get_filesets sim_1]
# Vivado Simulator settings
set_property -name xsim.more_options -value {-testplusarg TESTNAME=basic_test} -objects [get_filesets sim_1]
set_property runtime {} [get_filesets sim_1]
 # set_property XSIM.TCLBATCH ../../../../misc/xsim_wave.tcl [get_filesets sim_1]
# Default to MTI
set_property target_simulator xsim [current_project]
# MTI settings
set_property runtime {} [get_filesets sim_1]
#set_property -name xsim.vlog_more_options -value +acc -objects [get_filesets sim_1]
#set_property -name xsim.vsim_more_options -value {+notimingchecks +TESTNAME=basic_test -GSIM_COLLISION_CHECK=NONE } -objects [get_filesets sim_1]
set_property compxlib.compiled_library_dir {} [current_project]
#set_property xsim.custom_udo "./misc/wave.do" [get_filesets sim_1]
# Generate the IPs
#generate_target {synthesis simulation} [get_ips]
#  generate_target example [get_files *mig_axi_mm_dual.xci]
### set_property include_dirs { ../tb ../tb/dsport ../tb/include ../source/gen_chk project_1/xt_connectivity_trd.srcs/sources_1/ip/mig_axi_mm_dual/mig_axi_mm_dual/example_design/sim} [get_filesets sim_1]
create_run -flow {Vivado Synthesis 2014} sim_1
launch_runs sim_1
launch_xsim -simset sim_1 -mode behavioral
run 10us


