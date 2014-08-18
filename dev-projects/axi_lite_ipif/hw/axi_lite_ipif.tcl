# Vivado Launch Script
#### Change design settings here #######
set design axi_lite_ipif 
set top axi_lite_ipif 
set device xc7vx690t-2-ffg1761
set proj_dir ./synth
set ip_version v2_0_0
set ip_output $::env(XILINX_IP_FOLDER)/${design}/${design}_${ip_version}.zip
set lib_name AXILite
#####################################
# set IP paths
#####################################
# Project Settings
#####################################
create_project -name ${design} -force -dir "./${proj_dir}" -part ${device} -ip
set_property source_mgmt_mode None [current_project] 
set_property top ${top} [current_fileset]
puts "Creating AXI Lite Ipif IP"
# Project Constraints
#####################################
# Project Structure & IP Build
#####################################
read_verilog "./source/address_decoder.v"
read_verilog "./source/axi_lite_ipif.v"
read_verilog "./source/pselect_f.v"
read_verilog "./source/counter_f.v"
read_verilog "./source/slave_attachment.v"
update_compile_order -fileset sources_1
#update_compile_order -fileset sim_1
ipx::package_project
set_property library ${lib_name} [ipx::current_core]
set_property vendor_display_name {Xilinx} [ipx::current_core]
set_property company_url {www.xilinx.com} [ipx::current_core]
set_property vendor {xilinx.com} [ipx::current_core]
set_property supported_families {{virtex7} {Production}} [ipx::current_core]
set_property taxonomy {{/AXILite/}} [ipx::current_core]
#set_property value {0x1} [ipx::get_user_parameter C_ARD_NUM_CE_ARRAY [ipx::current_core]]
set_property value_bit_string_length {64} [ipx::get_user_parameter C_ARD_ADDR_RANGE_ARRAY [ipx::current_core]]
set_property value {0x0000FFFF00000000} [ipx::get_user_parameter C_ARD_ADDR_RANGE_ARRAY [ipx::current_core]]

ipx::check_integrity [ipx::current_core]
ipx::archive_core ${ip_output} [ipx::current_core]
close_project











