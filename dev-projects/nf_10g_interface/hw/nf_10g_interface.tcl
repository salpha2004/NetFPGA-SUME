# Vivado Launch Script
#### Change design settings here #######
set design nf_10g_interface 
set top nf_10g_interface
set device xc7vx690t-2-ffg1761
set proj_dir ./synth
set repo_dir ./ip_repo
set ip_version v1_0_0
set ip_output $::env(IP_FOLDER)/${design}/${design}_${ip_version}.zip
set lib_name NetFPGA
#####################################
# set IP paths
#####################################
 set axi_lite_ipif_ip_path $::env(XILINX_IP_FOLDER)/axi_lite_ipif/source/
set fallthrough_small_fifo_ip $::env(IP_FOLDER)/generic/fallthrough_small_fifo_v1_0_0.zip
set nf10_axis_converter_ip $::env(IP_FOLDER)/generic/nf10_axis_converter_v1_0_0.zip
#####################################
# Project Settings
#####################################
create_project -name ${design} -force -dir "./${proj_dir}" -part ${device} -ip
set_property source_mgmt_mode None [current_project] 
set_property top ${top} [current_fileset]
file mkdir ${repo_dir}
 set_property ip_repo_paths ${repo_dir} [current_fileset]
puts "Creating 10G Interface IP"
# Project Constraints
#####################################
# Proj
 #Project Structure & IP Build
#####################################

##read_verilog "${axi_lite_ipif_ip_path}/axi_lite_ipif.v"
##read_verilog "${axi_lite_ipif_ip_path}/counter_f.v"
##read_verilog "${axi_lite_ipif_ip_path}/pselect_f.v"
##read_verilog "${axi_lite_ipif_ip_path}/slave_attachment.v"
#read_verilog "./source/fallthrough_small_fifo_v2.v"
#read_verilog "./source/small_fifo_v3.v"
update_ip_catalog
update_ip_catalog -add_ip ${nf10_axis_converter_ip} -repo_path ${repo_dir}
create_ip -name nf10_axis_converter -vendor NetFPGA -library NetFPGA -module_name converter_master
set_property generate_synth_checkpoint false [get_files converter_master.xci]
generate_target all [get_ips converter_master]
create_ip -name nf10_axis_converter -vendor NetFPGA -library NetFPGA -module_name converter_slave
set_property generate_synth_checkpoint false [get_files converter_slave.xci]
generate_target all [get_ips converter_slave]

create_bd_design "xge_sub"
open_bd_design "xge_sub"
source ./source/xge_sub.tcl
#validate_bd_design
save_bd_design
#generate_target all [get_files  xge_sub.bd ]

read_verilog "./source/rx_queue.v"
read_verilog "./source/FIFO36_72.v"
read_verilog "./source/small_async_fifo.v"
read_verilog "./source/tx_queue.v"
read_verilog "./source/nf10_axis_converter.v"
read_verilog "./source/cpu_sync.v"

read_verilog "./source/nf_10g_if_cpu_regs_defines.v"
read_verilog "./source/nf_10g_if_cpu_regs.v"
read_verilog "./source/nf_10g_interface.v"
update_compile_order -fileset sources_1
#update_compile_order -fileset sim_1
ipx::package_project
set_property library ${lib_name} [ipx::current_core]
set_property vendor_display_name {NetFPGA} [ipx::current_core]
set_property company_url {www.netfpga.org} [ipx::current_core]
#set_property name {nf10_input_arbiter} [ipx::current_core]
set_property vendor {NetFPGA} [ipx::current_core]
set_property supported_families {{virtex7} {Production}} [ipx::current_core]
set_property taxonomy {{/NetFPGA/Data_Path}} [ipx::current_core]
set_property value {0x01} [ipx::get_user_parameter C_ARD_NUM_CE_ARRAY [ipx::current_core]]
#set_property value_bit_string_length {64} [ipx::get_user_parameter C_ARD_ADDR_RANGE_ARRAY [ipx::current_core]]
#set_property value {0x0000FFFF00000000} [ipx::get_user_parameter C_ARD_ADDR_RANGE_ARRAY [ipx::current_core]]
ipx::infer_user_parameters [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::archive_core ${ip_output} [ipx::current_core]
#close_project











