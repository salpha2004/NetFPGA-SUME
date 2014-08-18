# Vivado Launch Script
#### Change design settings here #######
set design pcie_2_axilite
set top pcie_2_axilite
set device xc7vx690t-2-ffg1761
set proj_dir ./synth
set ip_version v1_0_0
set ip_output $::env(XILINX_IP_FOLDER)/${design}/${design}_${ip_version}.zip
set lib_name AXI
#####################################
# set IP paths
#####################################
# Project Settings
#####################################
create_project -name ${design} -force -dir "./${proj_dir}" -part ${device} -ip
set_property top ${top} [current_fileset]
puts "Creating IPCIe2AXILite IP"
# Project Constraints
#####################################
# Project Structure & IP Build
#####################################
read_verilog "./source/axi_read_controller.v"
read_verilog "./source/axi_write_controller.v"
read_verilog "./source/maxi_controller.v"
read_verilog "./source/maxis_controller.v"
read_verilog "./source/pcie_2_axilite.v"
read_verilog "./source/s_axi_config.v"
read_verilog "./source/saxis_controller.v"
read_verilog "./source/tag_manager.v"
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
ipx::package_project
set_property library ${lib_name} [ipx::current_core]
set_property vendor_display_name {xilinx.com} [ipx::current_core]
set_property company_url {www.xilinx.org} [ipx::current_core]
set_property vendor {xilinx.com} [ipx::current_core]
set_property supported_families {{virtex7} {Production}} [ipx::current_core]
set_property taxonomy {{/xilinx/axilite_2_pcie_bridge}} [ipx::current_core]

set_property CONFIG.ASSOCIATED_BUSIF  [get_interfaces s_axis_cq] [get_pins pcie_2_axilite_0/axi_clk]

ipx::check_integrity [ipx::current_core]
ipx::archive_core ${ip_output} [ipx::current_core]
close_project











