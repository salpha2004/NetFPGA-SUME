
################################################################
# This is a generated script based on design: pcie2axilite_sub
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2014.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   puts "ERROR: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source pcie2axilite_sub_script.tcl

# If you do not already have a project created,
# you can create a project using the following command:
#    create_project project_1 myproj -part xc7vx690tffg1761-2
#    set_property BOARD_PART xilinx.com:vc709:part0:1.0 [current_project]


# CHANGE DESIGN NAME HERE
set design_name pcie2axilite_sub

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}


# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} ne "" && ${cur_design} eq ${design_name} } {

   # Checks if design is empty or not   
   if { $list_cells ne "" } {
      set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
      set nRet 1
   } else {
      puts "INFO: Constructing design in IPI design <$design_name>..."
   }
} elseif { ${cur_design} ne "" && ${cur_design} ne ${design_name} } {

   if { $list_cells eq "" } {
      puts "INFO: You have an empty design <${cur_design}>. Will go ahead and create design..."
   } else {
      set errMsg "ERROR: Design <${cur_design}> is not empty! Please do not source this script on non-empty designs."
      set nRet 1
   }
} else {

   if { [get_files -quiet ${design_name}.bd] eq "" } {
      puts "INFO: Currently there is no design <$design_name> in project, so creating one..."

      create_bd_design $design_name

      puts "INFO: Making design <$design_name> as current_bd_design."
      current_bd_design $design_name

   } else {
      set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
      set nRet 3
   }

}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set pcie_7x_mgt [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_7x_mgt ]

  # Create ports
  set sys_clk [ create_bd_port -dir I -type clk sys_clk ]
  set sys_reset [ create_bd_port -dir I -type rst sys_reset ]
  set_property -dict [ list CONFIG.POLARITY {ACTIVE_HIGH}  ] $sys_reset

 



 set m07_axi [create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M07_AXI]
 set m06_axi [create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M06_AXI]
 set m05_axi [create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M05_AXI]
 set m04_axi [create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M04_AXI]
 set m03_axi [create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M03_AXI]
 set m02_axi [create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M02_AXI]
 set m01_axi [create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M01_AXI]
 set m00_axi [create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI]

 set_property CONFIG.PROTOCOL AXI4LITE [get_bd_intf_ports M00_AXI]
 set_property CONFIG.PROTOCOL AXI4LITE [get_bd_intf_ports M01_AXI]
 set_property CONFIG.PROTOCOL AXI4LITE [get_bd_intf_ports M02_AXI]
 set_property CONFIG.PROTOCOL AXI4LITE [get_bd_intf_ports M03_AXI]
 set_property CONFIG.PROTOCOL AXI4LITE [get_bd_intf_ports M04_AXI]
 set_property CONFIG.PROTOCOL AXI4LITE [get_bd_intf_ports M05_AXI]
 set_property CONFIG.PROTOCOL AXI4LITE [get_bd_intf_ports M06_AXI]
 set_property CONFIG.PROTOCOL AXI4LITE [get_bd_intf_ports M07_AXI]
  
  set axi_resetn [create_bd_port -dir O -type rst axi_aresetn]
  set axi_aclk [create_bd_port -dir O -type clk axi_clk]

  # Create instance: axi_bram_ctrl_0, and set properties
  #set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:3.0 axi_bram_ctrl_0 ]
  #set_property -dict [ list CONFIG.SINGLE_PORT_BRAM {1}  ] $axi_bram_ctrl_0

  # Create instance: axi_bram_ctrl_1, and set properties
  #set axi_bram_ctrl_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:3.0 axi_bram_ctrl_1 ]
  #set_property -dict [ list CONFIG.SINGLE_PORT_BRAM {1}  ] $axi_bram_ctrl_1

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
 
#configure 8 Master interfaces
  set_property -dict [list CONFIG.NUM_MI {8}] [get_bd_cells axi_interconnect_0] 

  # Create instance: blk_mem_gen_0, and set properties
  #set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.1 blk_mem_gen_0 ]

  # Create instance: blk_mem_gen_1, and set properties
  #set blk_mem_gen_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.1 blk_mem_gen_1 ]

  # Create instance: pcie3_7x_0, and set properties
  set pcie3_7x_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:pcie3_7x:3.0 pcie3_7x_0 ]
  set_property -dict [ list CONFIG.AXISTEN_IF_RC_STRADDLE {true} CONFIG.PF0_DEVICE_ID {0007} CONFIG.PL_LINK_CAP_MAX_LINK_SPEED {8.0_GT/s} CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X8} CONFIG.axisten_freq {250} CONFIG.axisten_if_width {256_bit} CONFIG.cfg_ctl_if {false} CONFIG.cfg_ext_if {false} CONFIG.cfg_fc_if {false} CONFIG.cfg_mgmt_if {false} CONFIG.cfg_status_if {false} CONFIG.cfg_tx_msg_if {false} CONFIG.gen_x0y0 {false} CONFIG.mode_selection {Advanced} CONFIG.per_func_status_if {false} CONFIG.pf0_bar0_size {8} CONFIG.pf0_bar1_enabled {true} CONFIG.pf0_bar1_size {4} CONFIG.pf0_bar1_type {Memory} CONFIG.rcv_msg_if {false} CONFIG.shared_logic_in_core {true} CONFIG.tx_fc_if {false} CONFIG.xlnx_ref_board {VC709}  ] $pcie3_7x_0


  # Create instance: pcie_2_axilite_0, and set properties
 # set pcie_2_axilite_0 [ create_bd_cell -type ip -vlnv xilinx.com:AXI:pcie_2_axilite:1.0 pcie_2_axilite_0 ]
  set pcie_2_axilite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:pcie_2_axilite:1.0 pcie_2_axilite_0 ]
  set_property -dict [ list CONFIG.AXIS_TDATA_WIDTH {256} CONFIG.BAR0SIZE {0xFFFFFFFFFFC00000} CONFIG.BAR1SIZE {0xFFFFFFFFFFF00000} CONFIG.BAR2AXI0_TRANSLATION {0x0000000000000000} CONFIG.BAR2AXI1_TRANSLATION {0x0000000001000000}  ] $pcie_2_axilite_0

 # Create interface connections
   

  #connect_bd_intf_net -intf_net axi_bram_ctrl_0_bram_porta [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]
  #connect_bd_intf_net -intf_net axi_bram_ctrl_1_bram_porta [get_bd_intf_pins axi_bram_ctrl_1/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_1/BRAM_PORTA]
  #connect_bd_intf_net -intf_net axi_interconnect_0_m00_axi [get_bd_intf_pins axi_bram_ctrl_0/S_AXI] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  #connect_bd_intf_net -intf_net axi_interconnect_0_m01_axi [get_bd_intf_pins axi_bram_ctrl_1/S_AXI] [get_bd_intf_pins axi_interconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net pcie3_7x_0_m_axis_cq [get_bd_intf_pins pcie3_7x_0/m_axis_cq] [get_bd_intf_pins pcie_2_axilite_0/s_axis_cq]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_intf_nets pcie3_7x_0_m_axis_cq]
  connect_bd_intf_net -intf_net pcie3_7x_0_pcie_7x_mgt [get_bd_intf_ports pcie_7x_mgt] [get_bd_intf_pins pcie3_7x_0/pcie_7x_mgt]
  connect_bd_intf_net -intf_net pcie_2_axilite_0_m_axis_cc [get_bd_intf_pins pcie3_7x_0/s_axis_cc] [get_bd_intf_pins pcie_2_axilite_0/m_axis_cc]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_intf_nets pcie_2_axilite_0_m_axis_cc]
  connect_bd_intf_net -intf_net s00_axi_1 [get_bd_intf_pins axi_interconnect_0/S00_AXI] [get_bd_intf_pins pcie_2_axilite_0/m_axi]
  set_property -dict [ list HDL_ATTRIBUTE.MARK_DEBUG {true}  ] [get_bd_intf_nets s00_axi_1]

  # Create port connections
   connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M00_AXI] [get_bd_intf_ports M00_AXI]
   connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_ports M01_AXI]
   connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M02_AXI] [get_bd_intf_ports M02_AXI]
   connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M03_AXI] [get_bd_intf_ports M03_AXI]
   connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M04_AXI] [get_bd_intf_ports M04_AXI]
   connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M05_AXI] [get_bd_intf_ports M05_AXI]
   connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M06_AXI] [get_bd_intf_ports M06_AXI]
   connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/M07_AXI] [get_bd_intf_ports M07_AXI]





 # connect_bd_net -net pcie3_7x_0_user_clk [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_bram_ctrl_1/s_axi_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins pcie3_7x_0/user_clk] [get_bd_pins pcie_2_axilite_0/axi_clk]
 connect_bd_net -net pcie3_7x_0_user_clk [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/M02_ACLK] [get_bd_pins axi_interconnect_0/M03_ACLK] [get_bd_pins axi_interconnect_0/M04_ACLK] [get_bd_pins axi_interconnect_0/M05_ACLK] [get_bd_pins axi_interconnect_0/M06_ACLK] [get_bd_pins axi_interconnect_0/M07_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins pcie3_7x_0/user_clk] [get_bd_pins pcie_2_axilite_0/axi_clk] 

connect_bd_net [get_bd_pins /pcie3_7x_0/user_lnk_up] [get_bd_ports /axi_aresetn]
connect_bd_net [get_bd_pins /pcie3_7x_0/user_clk] [get_bd_ports /axi_clk]


#set_property CONFIG.ASSOCIATED_BUSIF {M01_AXI} [get_bd_ports /axi_clk]
#set_property CONFIG.ASSOCIATED_BUSIF {M00_AXI:M01_AXI:M02_AXI:M03_AXI:M01_AXI:M04_AXI:M05_AXI:M06_AXI:M07_AXI} [get_bd_ports /axi_clk]
set_property CONFIG.ASSOCIATED_BUSIF M00_AXI:M01_AXI:M02_AXI:M03_AXI:M01_AXI:M04_AXI:M05_AXI:M06_AXI:M07_AXI [get_bd_ports axi_clk]

set_property CONFIG.ASSOCIATED_BUSIF  [get_bd_intf_pins pcie_2_axilite_0/s_axis_cq] [get_bd_pins pcie_2_axilite_0/axi_clk]


set_property CONFIG.FREQ_HZ 250000000 [get_bd_intf_pins pcie_2_axilite_0/m_axis_cc]
#set_property CONFIG.FREQ_HZ 250000000 [get_bd_intf_pins pcie_2_axilite_0/s_axis_cq]

  
#connect_bd_net -net pcie3_7x_0_user_lnk_up [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_bram_ctrl_1/s_axi_aresetn] [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins pcie3_7x_0/user_lnk_up] [get_bd_pins pcie_2_axilite_0/axi_aresetn]
  connect_bd_net -net pcie3_7x_0_user_lnk_up [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/M02_ARESETN] [get_bd_pins axi_interconnect_0/M03_ARESETN] [get_bd_pins axi_interconnect_0/M04_ARESETN] [get_bd_pins axi_interconnect_0/M05_ARESETN] [get_bd_pins axi_interconnect_0/M06_ARESETN] [get_bd_pins axi_interconnect_0/M07_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins pcie3_7x_0/user_lnk_up] [get_bd_pins pcie_2_axilite_0/axi_aresetn]
  connect_bd_net -net sys_clk_1 [get_bd_ports sys_clk] [get_bd_pins pcie3_7x_0/sys_clk]
  connect_bd_net -net sys_reset_1 [get_bd_ports sys_reset] [get_bd_pins pcie3_7x_0/sys_reset]


  # Create address segments
 # #create_bd_addr_seg -range 0x2000 -offset 0xC0000000 [get_bd_addr_spaces pcie_2_axilite_0/m_axi] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
 # #create_bd_addr_seg -range 0x1000 -offset 0xC2000000 [get_bd_addr_spaces pcie_2_axilite_0/m_axi] [get_bd_addr_segs axi_bram_ctrl_1/S_AXI/Mem0] SEG_axi_bram_ctrl_1_Mem0
 create_bd_addr_seg -range 0x1000 -offset 0x00000000 [get_bd_addr_spaces pcie_2_axilite_0/m_axi] [get_bd_addr_segs {M00_AXI/Reg}] SEG_axi_range0
 create_bd_addr_seg -range 0x1000 -offset 0x00001000 [get_bd_addr_spaces pcie_2_axilite_0/m_axi] [get_bd_addr_segs {M01_AXI/Reg}] SEG_axi_range1
 create_bd_addr_seg -range 0x1000 -offset 0x00002000 [get_bd_addr_spaces pcie_2_axilite_0/m_axi] [get_bd_addr_segs {M02_AXI/Reg}] SEG_axi_range2
 create_bd_addr_seg -range 0x1000 -offset 0x00003000 [get_bd_addr_spaces pcie_2_axilite_0/m_axi] [get_bd_addr_segs {M03_AXI/Reg}] SEG_axi_range3
 create_bd_addr_seg -range 0x1000 -offset 0x00004000 [get_bd_addr_spaces pcie_2_axilite_0/m_axi] [get_bd_addr_segs {M04_AXI/Reg}] SEG_axi_range4
 create_bd_addr_seg -range 0x1000 -offset 0x00005000 [get_bd_addr_spaces pcie_2_axilite_0/m_axi] [get_bd_addr_segs {M05_AXI/Reg}] SEG_axi_range5
 create_bd_addr_seg -range 0x1000 -offset 0x00006000 [get_bd_addr_spaces pcie_2_axilite_0/m_axi] [get_bd_addr_segs {M06_AXI/Reg}] SEG_axi_range6
 create_bd_addr_seg -range 0x1000 -offset 0x00007000 [get_bd_addr_spaces pcie_2_axilite_0/m_axi] [get_bd_addr_segs {M07_AXI/Reg}] SEG_axi_range7


#assign_bd_address [get_bd_addr_segs {M00_AXI/Reg }] SEG_axi_range0
#set_propert SEG_axi_range0 [set_property offset 0x40A00000 [get_bd_addr_segs {pcie_2_axilite_0/m_axi/SEG_pcie2axilite_sub_Reg}]]
#set_property range 4K [get_bd_addr_segs {pcie_2_axilite_0/m_axi/SEG_pcie2axilite_sub_Reg}]  
  

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


