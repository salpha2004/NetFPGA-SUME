# Vivado Launch Script
#### Change design settings here #######
set design output_port_lookup
set top nf10_nic_output_port_lookup
set device xc7vx690t-2-ffg1761
set proj_dir ./synth
set ip_version v1_0_0
set ip_output $::env(IP_FOLDER)/${design}/vc709/${design}_${ip_version}.zip
set lib_name NetFPGA
#####################################
# set IP paths
#####################################
# Project Settings
#####################################
create_project -name ${design} -force -dir "./${proj_dir}" -part ${device} -ip
set_property top ${top} [current_fileset]
puts "Creating Input Arbiter IP"
# Project Constraints
#####################################
# Project Structure & IP Build
#####################################
read_verilog "./source/fallthrough_small_fifo_v2.v"
read_verilog "./source/small_fifo_v3.v"
read_verilog "./source/nf10_nic_output_port_lookup.v"
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
ipx::package_project
set_property library ${lib_name} [ipx::current_core]
set_property vendor_display_name {NetFPGA} [ipx::current_core]
set_property company_url {www.netfpga.org} [ipx::current_core]
set_property vendor {NetFPGA} [ipx::current_core]
set_property supported_families {{virtex7} {Production}} [ipx::current_core]
set_property taxonomy {{/NetFPGA/Data_Path}} [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::archive_core ${ip_output} [ipx::current_core]
close_project











