# Vivado Launch Script
#### Change design settings here #######
set design nf10_axis_converter
set top nf10_axis_converter
set device xc7vx690t-2-ffg1761
set proj_dir ./synth
set repo_dir ./ip_repo
set ip_version v1_0_0
set ip_output $::env(IP_FOLDER)/generic/${design}_${ip_version}.zip
set lib_name NetFPGA
#####################################
# set IP paths
#####################################
set fallthrough_small_fifo_ip $::env(IP_FOLDER)/generic/fallthrough_small_fifo_v1_0_0.zip
#####################################
# Project Settings
#####################################
create_project -name ${design} -force -dir "./${proj_dir}" -part ${device} -ip
set_property source_mgmt_mode None [current_project] 
set_property top ${top} [current_fileset]
  file mkdir ${repo_dir}
 set_property ip_repo_paths ${repo_dir} [current_fileset]
puts "Creating Fallthrough Small FIFO IP"
# Project Constraints
#####################################
# Project Structure & IP Build
#####################################

update_ip_catalog
update_ip_catalog -add_ip ${fallthrough_small_fifo_ip} -repo_path ${repo_dir}
create_ip -name fallthrough_small_fifo -vendor NetFPGA -library NetFPGA -module_name  input_fifo
set_property generate_synth_checkpoint false [get_files  input_fifo.xci]
generate_target all [get_ips  input_fifo]
create_ip -name fallthrough_small_fifo -vendor NetFPGA -library NetFPGA -module_name  info_fifo
set_property generate_synth_checkpoint false [get_files  info_fifo.xci]
generate_target all [get_ips  info_fifo]

read_verilog "./source/nf10_axis_converter.v"
update_compile_order -fileset sources_1
#update_compile_order -fileset sim_1
ipx::package_project
set_property library ${lib_name} [ipx::current_core]
set_property vendor_display_name {NetFPGA} [ipx::current_core]
set_property company_url {www.netfpga.org} [ipx::current_core]
set_property vendor {NetFPGA} [ipx::current_core]
set_property supported_families {{virtex7} {Production}} [ipx::current_core]
set_property taxonomy {{/NetFPGA/Generic}} [ipx::current_core]
ipx::infer_user_parameters [ipx::current_core]
ipx::save_core [ipx::current_core]
ipx::check_integrity [ipx::current_core]
ipx::archive_core ${ip_output} [ipx::current_core]
close_project











