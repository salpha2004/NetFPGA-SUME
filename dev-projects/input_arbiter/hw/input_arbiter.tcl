# Vivado Launch Script
#### Change design settings here #######
set design input_arbiter 
set top input_arbiter
set device xc7vx690t-2-ffg1761
set proj_dir ./synth
set repo_dir ./ip_repo
set ip_version v1_0_0
set ip_output $::env(IP_FOLDER)/${design}/${design}_${ip_version}.zip
set lib_name NetFPGA
#####################################
# set IP paths
#####################################
# set axi_lite_ipif_ip $::env(XILINX_IP_FOLDER)/axi_lite_ipif/axi_lite_ipif_v2_0_0.zip
 set axi_lite_ipif_ip_path $::env(XILINX_IP_FOLDER)/axi_lite_ipif/source/
set fallthrough_small_fifo_ip $::env(IP_FOLDER)/generic/fallthrough_small_fifo_v1_0_0.zip
#####################################
# Project Settings
#####################################
create_project -name ${design} -force -dir "./${proj_dir}" -part ${device} -ip
set_property source_mgmt_mode None [current_project] 
set_property top ${top} [current_fileset]
file mkdir ${repo_dir}
 set_property ip_repo_paths ${repo_dir} [current_fileset]
puts "Creating Input Arbiter IP"
# Project Constraints
#####################################
# Project Structure & IP Build
#####################################

#update_ip_catalog
#update_ip_catalog -add_ip ${axi_lite_ipif_ip} -repo_path ${repo_dir}
#create_ip -name axi_lite_ipif -vendor xilinx.com -library AXILite -module_name axi_lite_ipif_0
#create_ip_run [get_ips axi_lite_ipif_0]
#launch_run axi_lite_ipif_0_synth_1  
read_verilog "${axi_lite_ipif_ip_path}/address_decoder.v"
read_verilog "${axi_lite_ipif_ip_path}/axi_lite_ipif.v"
read_verilog "${axi_lite_ipif_ip_path}/counter_f.v"
read_verilog "${axi_lite_ipif_ip_path}/pselect_f.v"
read_verilog "${axi_lite_ipif_ip_path}/slave_attachment.v"
#read_verilog "./source/fallthrough_small_fifo_v2.v"
#read_verilog "./source/small_fifo_v3.v"
update_ip_catalog
update_ip_catalog -add_ip ${fallthrough_small_fifo_ip} -repo_path ${repo_dir}
create_ip -name fallthrough_small_fifo -vendor NetFPGA -library NetFPGA -module_name in_arb_fifo
set_property generate_synth_checkpoint false [get_files in_arb_fifo.xci]
generate_target all [get_ips in_arb_fifo]
read_verilog "./source/cpu_sync.v"
read_verilog "./source/small_async_fifo.v"
read_verilog "./source/arbiter_cpu_regs_defines.v"
read_verilog "./source/arbiter_cpu_regs.v"
read_verilog "./source/input_arbiter.v"
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
close_project











