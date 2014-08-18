`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/17/2013 11:12:24 AM
// Design Name: 
// Module Name: nf10_datapath
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module nf10_datapath #(
    //Slave AXI parameters
    parameter C_S_AXI_DATA_WIDTH    = 32,          
    parameter C_S_AXI_ADDR_WIDTH    = 32,          
    parameter C_USE_WSTRB           = 0,
    parameter C_DPHASE_TIMEOUT      = 0,
    parameter C_BASEADDR            = 32'h00000000,
    parameter C_HIGHADDR            = 32'h0000FFFF,

    // Master AXI Stream Data Width
    parameter C_M_AXIS_DATA_WIDTH=256,
    parameter C_S_AXIS_DATA_WIDTH=256,
    parameter C_M_AXIS_TUSER_WIDTH=128,
    parameter C_S_AXIS_TUSER_WIDTH=128,
    parameter NUM_QUEUES=5
)
(
    //Datapath clock
    input                                     axis_aclk,
    input                                     axis_resetn,
    //Registers clock
    input                                     axi_aclk,
    input                                     axi_resetn,

    // Slave AXI Ports
    input      [C_S_AXI_ADDR_WIDTH-1 : 0]     S0_AXI_AWADDR,
    input                                     S0_AXI_AWVALID,
    input      [C_S_AXI_DATA_WIDTH-1 : 0]     S0_AXI_WDATA,
    input      [C_S_AXI_DATA_WIDTH/8-1 : 0]   S0_AXI_WSTRB,
    input                                     S0_AXI_WVALID,
    input                                     S0_AXI_BREADY,
    input      [C_S_AXI_ADDR_WIDTH-1 : 0]     S0_AXI_ARADDR,
    input                                     S0_AXI_ARVALID,
    input                                     S0_AXI_RREADY,
    output                                    S0_AXI_ARREADY,
    output     [C_S_AXI_DATA_WIDTH-1 : 0]     S0_AXI_RDATA,
    output     [1 : 0]                        S0_AXI_RRESP,
    output                                    S0_AXI_RVALID,
    output                                    S0_AXI_WREADY,
    output     [1 :0]                         S0_AXI_BRESP,
    output                                    S0_AXI_BVALID,
    output                                    S0_AXI_AWREADY,
    
    input      [C_S_AXI_ADDR_WIDTH-1 : 0]     S1_AXI_AWADDR,
    input                                     S1_AXI_AWVALID,
    input      [C_S_AXI_DATA_WIDTH-1 : 0]     S1_AXI_WDATA,
    input      [C_S_AXI_DATA_WIDTH/8-1 : 0]   S1_AXI_WSTRB,
    input                                     S1_AXI_WVALID,
    input                                     S1_AXI_BREADY,
    input      [C_S_AXI_ADDR_WIDTH-1 : 0]     S1_AXI_ARADDR,
    input                                     S1_AXI_ARVALID,
    input                                     S1_AXI_RREADY,
    output                                    S1_AXI_ARREADY,
    output     [C_S_AXI_DATA_WIDTH-1 : 0]     S1_AXI_RDATA,
    output     [1 : 0]                        S1_AXI_RRESP,
    output                                    S1_AXI_RVALID,
    output                                    S1_AXI_WREADY,
    output     [1 :0]                         S1_AXI_BRESP,
    output                                    S1_AXI_BVALID,
    output                                    S1_AXI_AWREADY,

    input      [C_S_AXI_ADDR_WIDTH-1 : 0]     S2_AXI_AWADDR,
    input                                     S2_AXI_AWVALID,
    input      [C_S_AXI_DATA_WIDTH-1 : 0]     S2_AXI_WDATA,
    input      [C_S_AXI_DATA_WIDTH/8-1 : 0]   S2_AXI_WSTRB,
    input                                     S2_AXI_WVALID,
    input                                     S2_AXI_BREADY,
    input      [C_S_AXI_ADDR_WIDTH-1 : 0]     S2_AXI_ARADDR,
    input                                     S2_AXI_ARVALID,
    input                                     S2_AXI_RREADY,
    output                                    S2_AXI_ARREADY,
    output     [C_S_AXI_DATA_WIDTH-1 : 0]     S2_AXI_RDATA,
    output     [1 : 0]                        S2_AXI_RRESP,
    output                                    S2_AXI_RVALID,
    output                                    S2_AXI_WREADY,
    output     [1 :0]                         S2_AXI_BRESP,
    output                                    S2_AXI_BVALID,
    output                                    S2_AXI_AWREADY,

    
    // Slave Stream Ports (interface from Rx queues)
    input [C_S_AXIS_DATA_WIDTH - 1:0]         s_axis_tdata_0,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_tstrb_0,
    input [C_S_AXIS_TUSER_WIDTH-1:0]          s_axis_tuser_0,
    input                                     s_axis_tvalid_0,
    output                                    s_axis_tready_0,
    input                                     s_axis_tlast_0,
    input [C_S_AXIS_DATA_WIDTH - 1:0]         s_axis_tdata_1,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_tstrb_1,
    input [C_S_AXIS_TUSER_WIDTH-1:0]          s_axis_tuser_1,
    input                                     s_axis_tvalid_1,
    output                                    s_axis_tready_1,
    input                                     s_axis_tlast_1,
    input [C_S_AXIS_DATA_WIDTH - 1:0]         s_axis_tdata_2,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_tstrb_2,
    input [C_S_AXIS_TUSER_WIDTH-1:0]          s_axis_tuser_2,
    input                                     s_axis_tvalid_2,
    output                                    s_axis_tready_2,
    input                                     s_axis_tlast_2,
    input [C_S_AXIS_DATA_WIDTH - 1:0]         s_axis_tdata_3,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_tstrb_3,
    input [C_S_AXIS_TUSER_WIDTH-1:0]          s_axis_tuser_3,
    input                                     s_axis_tvalid_3,
    output                                    s_axis_tready_3,
    input                                     s_axis_tlast_3,
    input [C_S_AXIS_DATA_WIDTH - 1:0]         s_axis_tdata_4,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_tstrb_4,
    input [C_S_AXIS_TUSER_WIDTH-1:0]          s_axis_tuser_4,
    input                                     s_axis_tvalid_4,
    output                                    s_axis_tready_4,
    input                                     s_axis_tlast_4,


    // Master Stream Ports (interface to TX queues)
    output [C_M_AXIS_DATA_WIDTH - 1:0]         m_axis_tdata_0,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_tstrb_0,
    output [C_M_AXIS_TUSER_WIDTH-1:0]          m_axis_tuser_0,
    output                                     m_axis_tvalid_0,
    input                                      m_axis_tready_0,
    output                                     m_axis_tlast_0,
    output [C_M_AXIS_DATA_WIDTH - 1:0]         m_axis_tdata_1,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_tstrb_1,
    output [C_M_AXIS_TUSER_WIDTH-1:0]          m_axis_tuser_1,
    output                                     m_axis_tvalid_1,
    input                                      m_axis_tready_1,
    output                                     m_axis_tlast_1,
    output [C_M_AXIS_DATA_WIDTH - 1:0]         m_axis_tdata_2,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_tstrb_2,
    output [C_M_AXIS_TUSER_WIDTH-1:0]          m_axis_tuser_2,
    output                                     m_axis_tvalid_2,
    input                                      m_axis_tready_2,
    output                                     m_axis_tlast_2,
    output [C_M_AXIS_DATA_WIDTH - 1:0]         m_axis_tdata_3,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_tstrb_3,
    output [C_M_AXIS_TUSER_WIDTH-1:0]          m_axis_tuser_3,
    output                                     m_axis_tvalid_3,
    input                                      m_axis_tready_3,
    output                                     m_axis_tlast_3,
    output [C_M_AXIS_DATA_WIDTH - 1:0]         m_axis_tdata_4,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_tstrb_4,
    output [C_M_AXIS_TUSER_WIDTH-1:0]          m_axis_tuser_4,
    output                                     m_axis_tvalid_4,
    input                                      m_axis_tready_4,
    output                                     m_axis_tlast_4


    );
    
    
    //internal connectivity
    wire [C_M_AXIS_DATA_WIDTH - 1:0]         m_axis_tdata_opl;
    wire [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_tstrb_opl;
    wire [C_M_AXIS_TUSER_WIDTH-1:0]          m_axis_tuser_opl;
    wire                                     m_axis_tvalid_opl;
    wire                                     m_axis_tready_opl;
    wire                                     m_axis_tlast_opl;
    wire [C_M_AXIS_DATA_WIDTH - 1:0]         s_axis_tdata_opl;
    wire [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_tstrb_opl;
    wire [C_M_AXIS_TUSER_WIDTH-1:0]          s_axis_tuser_opl;
    wire                                     s_axis_tvalid_opl;
    wire                                     s_axis_tready_opl;
    wire                                     s_axis_tlast_opl;
    
  input_arbiter 
#(

    .C_M_AXIS_DATA_WIDTH (C_M_AXIS_DATA_WIDTH),
    .C_S_AXIS_DATA_WIDTH (C_S_AXIS_DATA_WIDTH),
    .C_M_AXIS_TUSER_WIDTH (C_M_AXIS_TUSER_WIDTH),
    .C_S_AXIS_TUSER_WIDTH (C_S_AXIS_TUSER_WIDTH),
    .NUM_QUEUES (5),
    .C_S_AXI_DATA_WIDTH (C_S_AXI_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH (C_S_AXI_ADDR_WIDTH),
    .C_USE_WSTRB        (C_USE_WSTRB),
    .C_DPHASE_TIMEOUT   (C_DPHASE_TIMEOUT),
    .C_HIGHADDR (32'h00000FFF),
    .C_BASEADDR (32'h00000000)
)	
nf10_input_arbiter (
      .axi_aclk(axis_aclk), // input axi_aclk
      .axi_resetn(axis_resetn), // input axi_resetn
      .m_axis_tdata(s_axis_tdata_opl), // output [255 : 0] m_axis_tdata
      .m_axis_tstrb(s_axis_tstrb_opl), // output [31 : 0] m_axis_tstrb
      .m_axis_tuser(s_axis_tuser_opl), // output [127 : 0] m_axis_tuser
      .m_axis_tvalid(s_axis_tvalid_opl), // output m_axis_tvalid
      .m_axis_tready(s_axis_tready_opl), // input m_axis_tready
      .m_axis_tlast(s_axis_tlast_opl), // output m_axis_tlast
      .s_axis_tdata_0(s_axis_tdata_0), // input [255 : 0] s_axis_tdata_0
      .s_axis_tstrb_0(s_axis_tstrb_0), // input [31 : 0] s_axis_tstrb_0
      .s_axis_tuser_0(s_axis_tuser_0), // input [127 : 0] s_axis_tuser_0
      .s_axis_tvalid_0(s_axis_tvalid_0), // input s_axis_tvalid_0
      .s_axis_tready_0(s_axis_tready_0), // output s_axis_tready_0
      .s_axis_tlast_0(s_axis_tlast_0), // input s_axis_tlast_0
      .s_axis_tdata_1(s_axis_tdata_1), // input [255 : 0] s_axis_tdata_1
      .s_axis_tstrb_1(s_axis_tstrb_1), // input [31 : 0] s_axis_tstrb_1
      .s_axis_tuser_1(s_axis_tuser_1), // input [127 : 0] s_axis_tuser_1
      .s_axis_tvalid_1(s_axis_tvalid_1), // input s_axis_tvalid_1
      .s_axis_tready_1(s_axis_tready_1), // output s_axis_tready_1
      .s_axis_tlast_1(s_axis_tlast_1), // input s_axis_tlast_1
      .s_axis_tdata_2(s_axis_tdata_2), // input [255 : 0] s_axis_tdata_2
      .s_axis_tstrb_2(s_axis_tstrb_2), // input [31 : 0] s_axis_tstrb_2
      .s_axis_tuser_2(s_axis_tuser_2), // input [127 : 0] s_axis_tuser_2
      .s_axis_tvalid_2(s_axis_tvalid_2), // input s_axis_tvalid_2
      .s_axis_tready_2(s_axis_tready_2), // output s_axis_tready_2
      .s_axis_tlast_2(s_axis_tlast_2), // input s_axis_tlast_2
      .s_axis_tdata_3(s_axis_tdata_3), // input [255 : 0] s_axis_tdata_3
      .s_axis_tstrb_3(s_axis_tstrb_3), // input [31 : 0] s_axis_tstrb_3
      .s_axis_tuser_3(s_axis_tuser_3), // input [127 : 0] s_axis_tuser_3
      .s_axis_tvalid_3(s_axis_tvalid_3), // input s_axis_tvalid_3
      .s_axis_tready_3(s_axis_tready_3), // output s_axis_tready_3
      .s_axis_tlast_3(s_axis_tlast_3), // input s_axis_tlast_3
      .s_axis_tdata_4(s_axis_tdata_4), // input [255 : 0] s_axis_tdata_4
      .s_axis_tstrb_4(s_axis_tstrb_4), // input [31 : 0] s_axis_tstrb_4
      .s_axis_tuser_4(s_axis_tuser_4), // input [127 : 0] s_axis_tuser_4
      .s_axis_tvalid_4(s_axis_tvalid_4), // input s_axis_tvalid_4
      .s_axis_tready_4(s_axis_tready_4), // output s_axis_tready_4
      .s_axis_tlast_4(s_axis_tlast_4), // input s_axis_tlast_4
      .S_AXI_AWADDR(S0_AXI_AWADDR), 
      .S_AXI_AWVALID(S0_AXI_AWVALID),
      .S_AXI_WDATA(S0_AXI_WDATA),  
      .S_AXI_WSTRB(S0_AXI_WSTRB),  
      .S_AXI_WVALID(S0_AXI_WVALID), 
      .S_AXI_BREADY(S0_AXI_BREADY), 
      .S_AXI_ARADDR(S0_AXI_ARADDR), 
      .S_AXI_ARVALID(S0_AXI_ARVALID),
      .S_AXI_RREADY(S0_AXI_RREADY), 
      .S_AXI_ARREADY(S0_AXI_ARREADY),
      .S_AXI_RDATA(S0_AXI_RDATA),  
      .S_AXI_RRESP(S0_AXI_RRESP),  
      .S_AXI_RVALID(S0_AXI_RVALID), 
      .S_AXI_WREADY(S0_AXI_WREADY), 
      .S_AXI_BRESP(S0_AXI_BRESP),  
      .S_AXI_BVALID(S0_AXI_BVALID), 
      .S_AXI_AWREADY(S0_AXI_AWREADY),
      .S_AXI_ACLK (axi_aclk), 
      .S_AXI_ARESETN(axi_resetn),
      .pkt_fwd() // output pkt_fwd
    );
    
    
    
       output_port_lookup  #(
    .C_S_AXI_DATA_WIDTH (C_S_AXI_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH (C_S_AXI_ADDR_WIDTH),
    .C_USE_WSTRB        (C_USE_WSTRB),
    .C_DPHASE_TIMEOUT   (C_DPHASE_TIMEOUT),
    .C_HIGHADDR (32'h00001FFF),
    .C_BASEADDR (32'h00001000),
    .C_M_AXIS_DATA_WIDTH (C_M_AXIS_DATA_WIDTH),
    .C_S_AXIS_DATA_WIDTH (C_S_AXIS_DATA_WIDTH),
    .C_M_AXIS_TUSER_WIDTH (C_M_AXIS_TUSER_WIDTH),
    .C_S_AXIS_TUSER_WIDTH (C_S_AXIS_TUSER_WIDTH)
     )
     nf10_nic_output_port_lookup_0  (
      .axi_aclk(axis_aclk), // input axi_aclk
      .axi_resetn(axis_resetn), // input axi_resetn
      .m_axis_tdata(m_axis_tdata_opl), // output [255 : 0] m_axis_tdata
      .m_axis_tstrb(m_axis_tstrb_opl), // output [31 : 0] m_axis_tstrb
      .m_axis_tuser(m_axis_tuser_opl), // output [127 : 0] m_axis_tuser
      .m_axis_tvalid(m_axis_tvalid_opl), // output m_axis_tvalid
      .m_axis_tready(m_axis_tready_opl), // input m_axis_tready
      .m_axis_tlast(m_axis_tlast_opl), // output m_axis_tlast
      .s_axis_tdata(s_axis_tdata_opl), // input [255 : 0] s_axis_tdata
      .s_axis_tstrb(s_axis_tstrb_opl), // input [31 : 0] s_axis_tstrb
      .s_axis_tuser(s_axis_tuser_opl), // input [127 : 0] s_axis_tuser
      .s_axis_tvalid(s_axis_tvalid_opl), // input s_axis_tvalid
      .s_axis_tready(s_axis_tready_opl), // output s_axis_tready
      .s_axis_tlast(s_axis_tlast_opl), // input s_axis_tlast

      .S_AXI_AWADDR(S1_AXI_AWADDR), 
      .S_AXI_AWVALID(S1_AXI_AWVALID),
      .S_AXI_WDATA(S1_AXI_WDATA),  
      .S_AXI_WSTRB(S1_AXI_WSTRB),  
      .S_AXI_WVALID(S1_AXI_WVALID), 
      .S_AXI_BREADY(S1_AXI_BREADY), 
      .S_AXI_ARADDR(S1_AXI_ARADDR), 
      .S_AXI_ARVALID(S1_AXI_ARVALID),
      .S_AXI_RREADY(S1_AXI_RREADY), 
      .S_AXI_ARREADY(S1_AXI_ARREADY),
      .S_AXI_RDATA(S1_AXI_RDATA),  
      .S_AXI_RRESP(S1_AXI_RRESP),  
      .S_AXI_RVALID(S1_AXI_RVALID), 
      .S_AXI_WREADY(S1_AXI_WREADY), 
      .S_AXI_BRESP(S1_AXI_BRESP),  
      .S_AXI_BVALID(S1_AXI_BVALID), 
      .S_AXI_AWREADY(S1_AXI_AWREADY),
      .S_AXI_ACLK (axi_aclk), 
      .S_AXI_ARESETN(axi_resetn)


    );
    
       output_queues   #(
    .C_S_AXI_DATA_WIDTH (C_S_AXI_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH (C_S_AXI_ADDR_WIDTH),
    .C_USE_WSTRB        (C_USE_WSTRB),
    .C_DPHASE_TIMEOUT   (C_DPHASE_TIMEOUT),
    .C_HIGHADDR (32'h00002FFF),
    .C_BASEADDR (32'h00002000),
    .C_M_AXIS_DATA_WIDTH (C_M_AXIS_DATA_WIDTH),
    .C_S_AXIS_DATA_WIDTH (C_S_AXIS_DATA_WIDTH),
    .C_M_AXIS_TUSER_WIDTH (C_M_AXIS_TUSER_WIDTH),
    .C_S_AXIS_TUSER_WIDTH (C_S_AXIS_TUSER_WIDTH),
    .NUM_QUEUES (5)
     )
     nf10_bram_output_queues (
      .axi_aclk(axis_aclk), // input axi_aclk
      .axi_resetn(axis_resetn), // input axi_resetn
      .s_axis_tdata(m_axis_tdata_opl), // input [255 : 0] s_axis_tdata
      .s_axis_tstrb(m_axis_tstrb_opl), // input [31 : 0] s_axis_tstrb
      .s_axis_tuser(m_axis_tuser_opl), // input [127 : 0] s_axis_tuser
      .s_axis_tvalid(m_axis_tvalid_opl), // input s_axis_tvalid
      .s_axis_tready(m_axis_tready_opl), // output s_axis_tready
      .s_axis_tlast(m_axis_tlast_opl), // input s_axis_tlast
      .m_axis_tdata_0(m_axis_tdata_0), // output [255 : 0] m_axis_tdata_0
      .m_axis_tstrb_0(m_axis_tstrb_0), // output [31 : 0] m_axis_tstrb_0
      .m_axis_tuser_0(m_axis_tuser_0), // output [127 : 0] m_axis_tuser_0
      .m_axis_tvalid_0(m_axis_tvalid_0), // output m_axis_tvalid_0
      .m_axis_tready_0(m_axis_tready_0), // input m_axis_tready_0
      .m_axis_tlast_0(m_axis_tlast_0), // output m_axis_tlast_0
      .m_axis_tdata_1(m_axis_tdata_1), // output [255 : 0] m_axis_tdata_1
      .m_axis_tstrb_1(m_axis_tstrb_1), // output [31 : 0] m_axis_tstrb_1
      .m_axis_tuser_1(m_axis_tuser_1), // output [127 : 0] m_axis_tuser_1
      .m_axis_tvalid_1(m_axis_tvalid_1), // output m_axis_tvalid_1
      .m_axis_tready_1(m_axis_tready_1), // input m_axis_tready_1
      .m_axis_tlast_1(m_axis_tlast_1), // output m_axis_tlast_1
      .m_axis_tdata_2(m_axis_tdata_2), // output [255 : 0] m_axis_tdata_2
      .m_axis_tstrb_2(m_axis_tstrb_2), // output [31 : 0] m_axis_tstrb_2
      .m_axis_tuser_2(m_axis_tuser_2), // output [127 : 0] m_axis_tuser_2
      .m_axis_tvalid_2(m_axis_tvalid_2), // output m_axis_tvalid_2
      .m_axis_tready_2(m_axis_tready_2), // input m_axis_tready_2
      .m_axis_tlast_2(m_axis_tlast_2), // output m_axis_tlast_2
      .m_axis_tdata_3(m_axis_tdata_3), // output [255 : 0] m_axis_tdata_3
      .m_axis_tstrb_3(m_axis_tstrb_3), // output [31 : 0] m_axis_tstrb_3
      .m_axis_tuser_3(m_axis_tuser_3), // output [127 : 0] m_axis_tuser_3
      .m_axis_tvalid_3(m_axis_tvalid_3), // output m_axis_tvalid_3
      .m_axis_tready_3(m_axis_tready_3), // input m_axis_tready_3
      .m_axis_tlast_3(m_axis_tlast_3), // output m_axis_tlast_3
      .m_axis_tdata_4(m_axis_tdata_4), // output [255 : 0] m_axis_tdata_4
      .m_axis_tstrb_4(m_axis_tstrb_4), // output [31 : 0] m_axis_tstrb_4
      .m_axis_tuser_4(m_axis_tuser_4), // output [127 : 0] m_axis_tuser_4
      .m_axis_tvalid_4(m_axis_tvalid_4), // output m_axis_tvalid_4
      .m_axis_tready_4(m_axis_tready_4), // input m_axis_tready_4
      .m_axis_tlast_4(m_axis_tlast_4), // output m_axis_tlast_4
      .bytes_stored(), // output [31 : 0] bytes_stored
      .pkt_stored(), // output [4 : 0] pkt_stored
      .bytes_removed_0(), // output [31 : 0] bytes_removed_0
      .bytes_removed_1(), // output [31 : 0] bytes_removed_1
      .bytes_removed_2(), // output [31 : 0] bytes_removed_2
      .bytes_removed_3(), // output [31 : 0] bytes_removed_3
      .bytes_removed_4(), // output [31 : 0] bytes_removed_4
      .pkt_removed_0(), // output pkt_removed_0
      .pkt_removed_1(), // output pkt_removed_1
      .pkt_removed_2(), // output pkt_removed_2
      .pkt_removed_3(), // output pkt_removed_3
      .pkt_removed_4(), // output pkt_removed_4
      .bytes_dropped(), // output [31 : 0] bytes_dropped
      .pkt_dropped(), // output [4 : 0] pkt_dropped

      .S_AXI_AWADDR(S2_AXI_AWADDR), 
      .S_AXI_AWVALID(S2_AXI_AWVALID),
      .S_AXI_WDATA(S2_AXI_WDATA),  
      .S_AXI_WSTRB(S2_AXI_WSTRB),  
      .S_AXI_WVALID(S2_AXI_WVALID), 
      .S_AXI_BREADY(S2_AXI_BREADY), 
      .S_AXI_ARADDR(S2_AXI_ARADDR), 
      .S_AXI_ARVALID(S2_AXI_ARVALID),
      .S_AXI_RREADY(S2_AXI_RREADY), 
      .S_AXI_ARREADY(S2_AXI_ARREADY),
      .S_AXI_RDATA(S2_AXI_RDATA),  
      .S_AXI_RRESP(S2_AXI_RRESP),  
      .S_AXI_RVALID(S2_AXI_RVALID), 
      .S_AXI_WREADY(S2_AXI_WREADY), 
      .S_AXI_BRESP(S2_AXI_BRESP),  
      .S_AXI_BVALID(S2_AXI_BVALID), 
      .S_AXI_AWREADY(S2_AXI_AWREADY),
      .S_AXI_ACLK (axi_aclk), 
      .S_AXI_ARESETN(axi_resetn)
    ); 
    
    
    
    
endmodule
