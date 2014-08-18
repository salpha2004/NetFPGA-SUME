#create_bd_design "xge_port"

create_bd_cell -type ip -vlnv xilinx.com:ip:axi_10g_ethernet:1.2 axi_10g_ethernet_0
set_property -dict [list CONFIG.Statistics_Gathering {false}] [get_bd_cells axi_10g_ethernet_0]
set_property -dict [list CONFIG.TIMER_CLK_PERIOD {4000}] [get_bd_cells axi_10g_ethernet_0]


create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 s_axi
set_property -dict [list CONFIG.PROTOCOL [get_property CONFIG.PROTOCOL [get_bd_intf_pins axi_10g_ethernet_0/ten_gig_eth_mac/s_axi]] CONFIG.SUPPORTS_NARROW_BURST [get_property CONFIG.SUPPORTS_NARROW_BURST [get_bd_intf_pins axi_10g_ethernet_0/ten_gig_eth_mac/s_axi]] CONFIG.MAX_BURST_LENGTH [get_property CONFIG.MAX_BURST_LENGTH [get_bd_intf_pins axi_10g_ethernet_0/ten_gig_eth_mac/s_axi]]] [get_bd_intf_ports s_axi]
connect_bd_intf_net [get_bd_intf_pins axi_10g_ethernet_0/s_axi] [get_bd_intf_ports s_axi]

create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_tx
set_property -dict [list CONFIG.TDATA_NUM_BYTES [get_property CONFIG.TDATA_NUM_BYTES [get_bd_intf_pins axi_10g_ethernet_0/ten_gig_eth_mac/s_axis_tx]] CONFIG.TUSER_WIDTH [get_property CONFIG.TUSER_WIDTH [get_bd_intf_pins axi_10g_ethernet_0/ten_gig_eth_mac/s_axis_tx]] CONFIG.HAS_TKEEP [get_property CONFIG.HAS_TKEEP [get_bd_intf_pins axi_10g_ethernet_0/ten_gig_eth_mac/s_axis_tx]] CONFIG.HAS_TLAST [get_property CONFIG.HAS_TLAST [get_bd_intf_pins axi_10g_ethernet_0/ten_gig_eth_mac/s_axis_tx]]] [get_bd_intf_ports s_axis_tx]
connect_bd_intf_net [get_bd_intf_pins axi_10g_ethernet_0/s_axis_tx] [get_bd_intf_ports s_axis_tx]

create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_pause
set_property -dict [list CONFIG.TDATA_NUM_BYTES [get_property CONFIG.TDATA_NUM_BYTES [get_bd_intf_pins axi_10g_ethernet_0/ten_gig_eth_mac/s_axis_pause]] CONFIG.HAS_TREADY [get_property CONFIG.HAS_TREADY [get_bd_intf_pins axi_10g_ethernet_0/ten_gig_eth_mac/s_axis_pause]]] [get_bd_intf_ports s_axis_pause]
connect_bd_intf_net [get_bd_intf_pins axi_10g_ethernet_0/s_axis_pause] [get_bd_intf_ports s_axis_pause]

create_bd_port -dir I -type rst reset
set_property CONFIG.POLARITY [get_property CONFIG.POLARITY [get_bd_pins axi_10g_ethernet_0/ten_gig_eth_pcs_pma/reset]] [get_bd_ports reset]
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/reset] [get_bd_ports reset]

create_bd_port -dir I -type clk s_axi_aclk
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/s_axi_aclk] [get_bd_ports s_axi_aclk]

create_bd_port -dir I -type rst s_axi_aresetn
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/s_axi_aresetn] [get_bd_ports s_axi_aresetn]

create_bd_port -dir I -type rst tx_axis_aresetn
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/tx_axis_aresetn] [get_bd_ports tx_axis_aresetn]

create_bd_port -dir I -type rst rx_axis_aresetn
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/rx_axis_aresetn] [get_bd_ports rx_axis_aresetn]

create_bd_port -dir I -from 7 -to 0 tx_ifg_delay
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/tx_ifg_delay] [get_bd_ports tx_ifg_delay]

create_bd_port -dir I rxp
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/rxp] [get_bd_ports rxp]

create_bd_port -dir I rxn
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/rxn] [get_bd_ports rxn]

create_bd_port -dir I signal_detect
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/signal_detect] [get_bd_ports signal_detect]

create_bd_port -dir I tx_fault
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/tx_fault] [get_bd_ports tx_fault]

create_bd_port -dir I refclk_p
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/refclk_p] [get_bd_ports refclk_p]

create_bd_port -dir I refclk_n
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/refclk_n] [get_bd_ports refclk_n]

create_bd_port -dir I -type clk systemtimer_clk
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/systemtimer_clk] [get_bd_ports systemtimer_clk]

create_bd_port -dir I -from 47 -to 0 systemtimer_s_field
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/systemtimer_s_field] [get_bd_ports systemtimer_s_field]

create_bd_port -dir I -from 31 -to 0 systemtimer_ns_field
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/systemtimer_ns_field] [get_bd_ports systemtimer_ns_field]

create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_rx
connect_bd_intf_net [get_bd_intf_pins axi_10g_ethernet_0/m_axis_rx] [get_bd_intf_ports m_axis_rx]

create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_tx_ts
connect_bd_intf_net [get_bd_intf_pins axi_10g_ethernet_0/m_axis_tx_ts] [get_bd_intf_ports m_axis_tx_ts]

create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_rx_ts
connect_bd_intf_net [get_bd_intf_pins axi_10g_ethernet_0/m_axis_rx_ts] [get_bd_intf_ports m_axis_rx_ts]

create_bd_port -dir O -type clk clk156_out
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/clk156_out] [get_bd_ports clk156_out]

create_bd_port -dir O -type intr xgmacint
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/xgmacint] [get_bd_ports xgmacint]

create_bd_port -dir O -from 25 -to 0 tx_statistics_vector
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/tx_statistics_vector] [get_bd_ports tx_statistics_vector]

create_bd_port -dir O tx_statistics_valid
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/tx_statistics_valid] [get_bd_ports tx_statistics_valid]

create_bd_port -dir O -from 29 -to 0 rx_statistics_vector
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/rx_statistics_vector] [get_bd_ports rx_statistics_vector]

create_bd_port -dir O rx_statistics_valid
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/rx_statistics_valid] [get_bd_ports rx_statistics_valid]

create_bd_port -dir O txp
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/txp] [get_bd_ports txp]

create_bd_port -dir O txn
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/txn] [get_bd_ports txn]

create_bd_port -dir O tx_disable
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/tx_disable] [get_bd_ports tx_disable]

create_bd_port -dir O -from 7 -to 0 pcspma_status
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/pcspma_status] [get_bd_ports pcspma_status]

create_bd_port -dir O resetdone
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/resetdone] [get_bd_ports resetdone]

create_bd_port -dir O reset_counter_done_out
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/reset_counter_done_out] [get_bd_ports reset_counter_done_out]

create_bd_port -dir O qplllock_out
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/qplllock_out] [get_bd_ports qplllock_out]

create_bd_port -dir O qplloutclk_out
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/qplloutclk_out] [get_bd_ports qplloutclk_out]

create_bd_port -dir O qplloutrefclk_out
connect_bd_net [get_bd_pins /axi_10g_ethernet_0/qplloutrefclk_out] [get_bd_ports qplloutrefclk_out]

set_property CONFIG.FREQ_HZ 156250000 [get_bd_intf_ports s_axis_tx]
set_property CONFIG.FREQ_HZ 156250000 [get_bd_intf_ports m_axis_rx]
set_property CONFIG.FREQ_HZ 156250000 [get_bd_intf_ports m_axis_tx_ts]
set_property CONFIG.FREQ_HZ 156250000 [get_bd_intf_ports m_axis_rx_ts]
set_property CONFIG.FREQ_HZ 156250000 [get_bd_intf_ports s_axis_pause]
set_property CONFIG.ASSOCIATED_BUSIF s_axis_tx:s_axis_pause:m_axis_rx:m_axis_tx_ts:m_axis_rx_ts [get_bd_ports clk156_out]
set_property CONFIG.ASSOCIATED_BUSIF s_axi [get_bd_ports s_axi_aclk]

assign_bd_address [get_bd_addr_segs {axi_10g_ethernet_0/ten_gig_eth_mac/s_axi/Reg }]
set_property offset 0x60000 [get_bd_addr_segs {s_axi/SEG_ten_gig_eth_mac_Reg}]
 
validate_bd_design
generate_target all [get_files xge_port.bd]
