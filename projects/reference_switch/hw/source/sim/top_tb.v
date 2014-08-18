//-----------------------------------------------------------------------------
//
// Here comes the NetFPGA new and nice header
//--
//------------------------------------------------------------------------------

`timescale 1ns / 100ps

 module top_tb # (
  parameter          PL_SIM_FAST_LINK_TRAINING           = "TRUE",      // Simulation Speedup
  parameter          C_DATA_WIDTH                        = 256,         // RX/TX interface data width
  parameter          KEEP_WIDTH                          = C_DATA_WIDTH / 32,
  parameter  integer USER_CLK2_FREQ                 = 4,
  parameter          REF_CLK_FREQ                   = 0,           // 0 - 100 MHz, 1 - 125 MHz,  2 - 250 MHz
  parameter          AXISTEN_IF_RQ_ALIGNMENT_MODE   = "FALSE",
  parameter          AXISTEN_IF_CC_ALIGNMENT_MODE   = "FALSE",
  parameter          AXISTEN_IF_CQ_ALIGNMENT_MODE   = "FALSE",
  parameter          AXISTEN_IF_RC_ALIGNMENT_MODE   = "FALSE",
  parameter          AXISTEN_IF_ENABLE_CLIENT_TAG   = 0,
  parameter          AXISTEN_IF_RQ_PARITY_CHECK     = 0,
  parameter          AXISTEN_IF_CC_PARITY_CHECK     = 0,
  parameter          AXISTEN_IF_MC_RX_STRADDLE      = 0,
  parameter          AXISTEN_IF_ENABLE_RX_MSG_INTFC = 0,
  parameter   [17:0] AXISTEN_IF_ENABLE_MSG_ROUTE    = 18'h2FFFF
) (

);

 parameter PERIOD = 4;
 
   localparam  TCQ                                 = 1;
   localparam  BAR0AXI                             = 32'h40000000;
   localparam  BAR1AXI                             = 32'h10000000;
   localparam  BAR2AXI                             = 32'h20000000;
   localparam  BAR3AXI                             = 32'h30000000;
   localparam  BAR4AXI                             = 32'h40000000;
   localparam  BAR5AXI                             = 32'h50000000;
   localparam  BAR0SIZE                            = 64'hFFFF_FFFF_FFFF_FF80;
   localparam  BAR1SIZE                            = 64'hFFFF_FFFF_FFFF_FF80;
   localparam  BAR2SIZE                            = 64'hFFFF_FFFF_FFFF_FF80;
   localparam  BAR3SIZE                            = 64'hFFFF_FFFF_FFFF_FF80;
   localparam  BAR4SIZE                            = 64'hFFFF_FFFF_FFFF_FF80;
   localparam  BAR5SIZE                            = 64'hFFFF_FFFF_FFFF_FF80;
   localparam  throttle_percent                    = 50;
  //----------------------------------------------------------------------------------------------------------------//
  //    Generated Signals                                                                                      //
  //----------------------------------------------------------------------------------------------------------------//
 // input  [7:0]pcie_7x_mgt_rxn;
 // input  [7:0]pcie_7x_mgt_rxp;
 // output [7:0]pcie_7x_mgt_txn;
 // output [7:0]pcie_7x_mgt_txp;
  
 // wire       sys_clkp;
 // wire       sys_clkn;
 // wire       clk_ref_p;
 // wire       clk_ref_n;

  reg       sys_reset; 
//----------------------------------------------------------------------------------------------------------------//
  //    PCI-Express Interface                                                                                       //
  //----------------------------------------------------------------------------------------------------------------//

//  wire [7:0]pcie_7x_mgt_rxn;
//  wire [7:0]pcie_7x_mgt_rxp;
//  wire [7:0]pcie_7x_mgt_txn;
//  wire [7:0]pcie_7x_mgt_txp;
 // wire sys_clkp;
 // wire sys_clkn;
 // wire sys_clk;
//  wire sys_reset;


  //----------------------------------------------------------------------------------------------------------------//
  //    System(SYS) Interface                                                                                       //
  //----------------------------------------------------------------------------------------------------------------//

  reg                                       sys_clk;
 // wire                                       clk_200_i;
 // wire                                       clk_200;
  //wire                                       sys_rst_n_c;

    //-----------------------------------------------------------------------------------------------------------------------
  
  //----------------------------------------------------------------------------------------------------------------//
  // axis interface                                                                                                 //
  //----------------------------------------------------------------------------------------------------------------//

  wire[C_DATA_WIDTH-1:0]      axis_i_0_tdata;
  wire            axis_i_0_tvalid;
  wire            axis_i_0_tlast;
  wire            axis_i_0_tuser;
  wire[C_DATA_WIDTH/8-1:0]       axis_i_0_tstrb;
  wire            axis_i_0_tready;

  wire[C_DATA_WIDTH-1:0]      axis_o_0_tdata;
  wire            axis_o_0_tvalid;
  wire            axis_o_0_tlast;
  //wire          axis_o_0_tuser;
  wire[C_DATA_WIDTH/8-1:0]       axis_o_0_tstrb;
  wire            axis_o_0_tready;

  wire[C_DATA_WIDTH-1:0]      axis_i_1_tdata;
  wire            axis_i_1_tvalid;
  wire            axis_i_1_tlast;
  wire            axis_i_1_tuser;
  wire[C_DATA_WIDTH-1:0]       axis_i_1_tstrb;
  wire            axis_i_1_tready;

  wire[C_DATA_WIDTH-1:0]      axis_o_1_tdata;
  wire            axis_o_1_tvalid;
  wire            axis_o_1_tlast;
  //wire            axis_o_1_tuser;
  wire[C_DATA_WIDTH/8-1:0]       axis_o_1_tstrb;
  wire            axis_o_1_tready;

  wire[C_DATA_WIDTH-1:0]      axis_i_2_tdata;
  wire            axis_i_2_tvalid;
  wire            axis_i_2_tlast;
  wire            axis_i_2_tuser;
  wire[C_DATA_WIDTH/8-1:0]       axis_i_2_tstrb;
  wire            axis_i_2_tready;

  wire[C_DATA_WIDTH-1:0]      axis_o_2_tdata;
  wire            axis_o_2_tvalid;
  wire            axis_o_2_tlast;
  //wire          axis_o_2_tuser;
  wire[C_DATA_WIDTH/8-1:0]       axis_o_2_tstrb;
  wire            axis_o_2_tready;

  wire[C_DATA_WIDTH-1:0]      axis_i_3_tdata;
  wire            axis_i_3_tvalid;
  wire            axis_i_3_tlast;
  wire            axis_i_3_tuser;
  wire[C_DATA_WIDTH/8-1:0]       axis_i_3_tstrb;
  wire            axis_i_3_tready;

  wire[C_DATA_WIDTH-1:0]      axis_o_3_tdata;
  wire            axis_o_3_tvalid;
  wire            axis_o_3_tlast;
  //wire          axis_o_3_tuser;
  wire[C_DATA_WIDTH/8-1:0]       axis_o_3_tstrb;
  wire            axis_o_3_tready;
  
 //----------------------------------------------------------------------------------------------------------------//
 // AXI Lite interface                                                                                                 //
 //----------------------------------------------------------------------------------------------------------------//
  wire [31:0]   M00_AXI_araddr;
  wire [2:0]    M00_AXI_arprot;
  wire [0:0]    M00_AXI_arready;
  wire [0:0]    M00_AXI_arvalid;
  wire [31:0]   M00_AXI_awaddr;
  wire [2:0]    M00_AXI_awprot;
  wire [0:0]    M00_AXI_awready;
  wire [0:0]    M00_AXI_awvalid;
  wire [0:0]    M00_AXI_bready;
  wire [1:0]    M00_AXI_bresp;
  wire [0:0]    M00_AXI_bvalid;
  wire [31:0]   M00_AXI_rdata;
  wire [0:0]    M00_AXI_rready;
  wire [1:0]    M00_AXI_rresp;
  wire [0:0]    M00_AXI_rvalid;
  wire [31:0]   M00_AXI_wdata;
  wire [0:0]    M00_AXI_wready;
  wire [3:0]    M00_AXI_wstrb;
  wire [0:0]    M00_AXI_wvalid;
  
  wire [31:0]   M01_AXI_araddr;
  wire [2:0]    M01_AXI_arprot;
  wire [0:0]    M01_AXI_arready;
  wire [0:0]    M01_AXI_arvalid;
  wire [31:0]   M01_AXI_awaddr;
  wire [2:0]    M01_AXI_awprot;
  wire [0:0]    M01_AXI_awready;
  wire [0:0]    M01_AXI_awvalid;
  wire [0:0]    M01_AXI_bready;
  wire [1:0]    M01_AXI_bresp;
  wire [0:0]    M01_AXI_bvalid;
  wire [31:0]   M01_AXI_rdata;
  wire [0:0]    M01_AXI_rready;
  wire [1:0]    M01_AXI_rresp;
  wire [0:0]    M01_AXI_rvalid;
  wire [31:0]   M01_AXI_wdata;
  wire [0:0]    M01_AXI_wready;
  wire [3:0]    M01_AXI_wstrb;
  wire [0:0]    M01_AXI_wvalid;

  wire [31:0]   M02_AXI_araddr;
  wire [2:0]    M02_AXI_arprot;
  wire [0:0]    M02_AXI_arready;
  wire [0:0]    M02_AXI_arvalid;
  wire [31:0]   M02_AXI_awaddr;
  wire [2:0]    M02_AXI_awprot;
  wire [0:0]    M02_AXI_awready;
  wire [0:0]    M02_AXI_awvalid;
  wire [0:0]    M02_AXI_bready;
  wire [1:0]    M02_AXI_bresp;
  wire [0:0]    M02_AXI_bvalid;
  wire [31:0]   M02_AXI_rdata;
  wire [0:0]    M02_AXI_rready;
  wire [1:0]    M02_AXI_rresp;
  wire [0:0]    M02_AXI_rvalid;
  wire [31:0]   M02_AXI_wdata;
  wire [0:0]    M02_AXI_wready;
  wire [3:0]    M02_AXI_wstrb;
  wire [0:0]    M02_AXI_wvalid;
  
  wire                 [C_DATA_WIDTH-1:0]    m_axis_cq_tdata;
  wire                            [84:0]     m_axis_cq_tuser;
  wire                                       m_axis_cq_tlast;
  wire                   [KEEP_WIDTH-1:0]    m_axis_cq_tkeep;
  wire                                       m_axis_cq_tvalid;
  wire                             [21:0]    m_axis_cq_tready;

  wire                 [C_DATA_WIDTH-1:0]    s_axis_cc_tdata;
  wire                             [32:0]    s_axis_cc_tuser;
  wire                                       s_axis_cc_tlast;
  wire                   [KEEP_WIDTH-1:0]    s_axis_cc_tkeep;
  wire                                       s_axis_cc_tvalid;
  reg                               [3:0]    s_axis_cc_tready;
  
    
  
  wire axi_aresetn;
  wire axi_clk;

  reg [C_DATA_WIDTH-1:0] completion_data [1:0];
 
  // --------------------------------------------------------------------
  //I2C Synthesizer Interface
  // 50mhz clk
  // --------------------------------------------------------------------
  //wire          clk50;
 // reg [1:0]     clk_divide = 2'b00;

  //---------------------------------------------------------------------
  // Misc 
  //---------------------------------------------------------------------
  
 // IBUF   sys_reset_n_ibuf (  .O(sys_rst_n_c),   .I(~sys_reset));

//    IBUFDS_GTE2 #(
//     .CLKCM_CFG("TRUE"),   // Refer to Transceiver User Guide
//     .CLKRCV_TRST("TRUE"), // Refer to Transceiver User Guide
//     .CLKSWING_CFG(2'b11)  // Refer to Transceiver User Guide
//  )
//  IBUFDS_GTE2_inst (
//     .O(sys_clk),         // 1-bit output: Refer to Transceiver User Guide
//     .ODIV2(),            // 1-bit output: Refer to Transceiver User Guide
//     .CEB(1'b0),          // 1-bit input: Refer to Transceiver User Guide
//     .I(sys_clkp),        // 1-bit input: Refer to Transceiver User Guide
//     .IB(sys_clkn)        // 1-bit input: Refer to Transceiver User Guide
//  );  
//  
// 
//   // 200mhz ref clk
//  IBUFGDS #(
//    .DIFF_TERM    ("TRUE"),
//    .IBUF_LOW_PWR ("FALSE")
//  ) diff_clk_200 (
//    .I    (clk_ref_p  ),
//    .IB   (clk_ref_n  ),
//    .O    (clk_200_i )  
//  );
//  
//  BUFG u_bufg_clk_ref
//  (
//    .O (clk_200),
//    .I (clk_200_i)
//  );
  

 
//wire reset;
//assign reset = sys_reset;


//-----------------------------------------------------------------------------------------------//
// Network modules                                                                               //
//-----------------------------------------------------------------------------------------------//

nf10_datapath 
#(
    // Master AXI Stream Data Width
    .C_M_AXIS_DATA_WIDTH (C_DATA_WIDTH),
    .C_S_AXIS_DATA_WIDTH (C_DATA_WIDTH),
    .C_M_AXIS_TUSER_WIDTH (128),
    .C_S_AXIS_TUSER_WIDTH (128),
    .NUM_QUEUES (5)
)
nf10_datapath_0 
(
   // .axi_aclk                        (clk_200),
    .axi_aclk                        (axi_clk),
  //  .axi_resetn                      (sys_rst_n_c),
    .axi_resetn                      (axi_aresetn),
    
    // Slave Stream Ports (interface from Rx queues)
    .s_axis_tdata_0                  (axis_i_0_tdata),  
    .s_axis_tstrb_0                  (axis_i_0_tstrb),  
    .s_axis_tuser_0                  (axis_i_0_tuser),  
    .s_axis_tvalid_0                 (axis_i_0_tvalid), 
    .s_axis_tready_0                 (axis_i_0_tready), 
    .s_axis_tlast_0                  (axis_i_0_tlast),  
    .s_axis_tdata_1                  (axis_i_1_tdata),  
    .s_axis_tstrb_1                  (axis_i_1_tstrb),  
    .s_axis_tuser_1                  (axis_i_1_tuser),  
    .s_axis_tvalid_1                 (axis_i_1_tvalid), 
    .s_axis_tready_1                 (axis_i_1_tready), 
    .s_axis_tlast_1                  (axis_i_1_tlast),  
    .s_axis_tdata_2                  (axis_i_2_tdata),  
    .s_axis_tstrb_2                  (axis_i_2_tstrb),  
    .s_axis_tuser_2                  (axis_i_2_tuser),  
    .s_axis_tvalid_2                 (axis_i_2_tvalid), 
    .s_axis_tready_2                 (axis_i_2_tready), 
    .s_axis_tlast_2                  (axis_i_2_tlast),  
    .s_axis_tdata_3                  (),  
    .s_axis_tstrb_3                  (),  
    .s_axis_tuser_3                  (),  
    .s_axis_tvalid_3                 (), 
    .s_axis_tready_3                 (), 
    .s_axis_tlast_3                  (),  
    .s_axis_tdata_4                  (axis_i_3_tdata), 
    .s_axis_tstrb_4                  (axis_i_3_tstrb), 
    .s_axis_tuser_4                  (axis_i_3_tuser), 
    .s_axis_tvalid_4                 (axis_i_3_tvalid), 
    .s_axis_tready_4                 (axis_i_3_tready), 
    .s_axis_tlast_4                  (axis_i_3_tlast),  


    // Master Stream Ports (interface to TX queues)
    .m_axis_tdata_0                  (axis_o_0_tdata),
    .m_axis_tstrb_0                  (axis_o_0_tstrb),
    .m_axis_tuser_0                  (axis_o_0_tuser),
    .m_axis_tvalid_0                 (axis_o_0_tvalid),
    .m_axis_tready_0                 (axis_o_0_tready),
    .m_axis_tlast_0                  (axis_o_0_tlast),
    .m_axis_tdata_1                  (axis_o_1_tdata), 
    .m_axis_tstrb_1                  (axis_o_1_tstrb), 
    .m_axis_tuser_1                  (axis_o_1_tuser), 
    .m_axis_tvalid_1                 (axis_o_1_tvalid),
    .m_axis_tready_1                 (axis_o_1_tready),
    .m_axis_tlast_1                  (axis_o_1_tlast), 
    .m_axis_tdata_2                  (axis_o_2_tdata), 
    .m_axis_tstrb_2                  (axis_o_2_tstrb), 
    .m_axis_tuser_2                  (axis_o_2_tuser), 
    .m_axis_tvalid_2                 (axis_o_2_tvalid),
    .m_axis_tready_2                 (axis_o_2_tready),
    .m_axis_tlast_2                  (axis_o_2_tlast), 
    .m_axis_tdata_3                  (), 
    .m_axis_tstrb_3                  (), 
    .m_axis_tuser_3                  (), 
    .m_axis_tvalid_3                 (),
    .m_axis_tready_3                 (),
    .m_axis_tlast_3                  (), 
    .m_axis_tdata_4                  (axis_o_3_tdata),
    .m_axis_tstrb_4                  (axis_o_3_tstrb),
    .m_axis_tuser_4                  (axis_o_3_tuser),
    .m_axis_tvalid_4                 (axis_o_3_tvalid),
    .m_axis_tready_4                 (axis_o_3_tready),
    .m_axis_tlast_4                  (axis_o_3_tlast),
   
   //AXI-Lite interface  
 
    .S0_AXI_AWADDR                    (M00_AXI_awaddr), 
    .S0_AXI_AWVALID                   (M00_AXI_awvalid),
    .S0_AXI_WDATA                     (M00_AXI_wdata),  
    .S0_AXI_WSTRB                     (M00_AXI_wstrb),  
    .S0_AXI_WVALID                    (M00_AXI_wvalid), 
    .S0_AXI_BREADY                    (M00_AXI_bready), 
    .S0_AXI_ARADDR                    (M00_AXI_araddr), 
    .S0_AXI_ARVALID                   (M00_AXI_arvalid),
    .S0_AXI_RREADY                    (M00_AXI_rready), 
    .S0_AXI_ARREADY                   (M00_AXI_arready),
    .S0_AXI_RDATA                     (M00_AXI_rdata),  
    .S0_AXI_RRESP                     (M00_AXI_rresp),  
    .S0_AXI_RVALID                    (M00_AXI_rvalid), 
    .S0_AXI_WREADY                    (M00_AXI_wready), 
    .S0_AXI_BRESP                     (M00_AXI_bresp),  
    .S0_AXI_BVALID                    (M00_AXI_bvalid), 
    .S0_AXI_AWREADY                   (M00_AXI_awready),
     
     .S1_AXI_AWADDR                    (M01_AXI_awaddr), 
     .S1_AXI_AWVALID                   (M01_AXI_awvalid),
     .S1_AXI_WDATA                     (M01_AXI_wdata),  
     .S1_AXI_WSTRB                     (M01_AXI_wstrb),  
     .S1_AXI_WVALID                    (M01_AXI_wvalid), 
     .S1_AXI_BREADY                    (M01_AXI_bready), 
     .S1_AXI_ARADDR                    (M01_AXI_araddr), 
     .S1_AXI_ARVALID                   (M01_AXI_arvalid),
     .S1_AXI_RREADY                    (M01_AXI_rready), 
     .S1_AXI_ARREADY                   (M01_AXI_arready),
     .S1_AXI_RDATA                     (M01_AXI_rdata),  
     .S1_AXI_RRESP                     (M01_AXI_rresp),  
     .S1_AXI_RVALID                    (M01_AXI_rvalid), 
     .S1_AXI_WREADY                    (M01_AXI_wready), 
     .S1_AXI_BRESP                     (M01_AXI_bresp),  
     .S1_AXI_BVALID                    (M01_AXI_bvalid), 
     .S1_AXI_AWREADY                   (M01_AXI_awready),

     .S2_AXI_AWADDR                    (M02_AXI_awaddr), 
     .S2_AXI_AWVALID                   (M02_AXI_awvalid),
     .S2_AXI_WDATA                     (M02_AXI_wdata),  
     .S2_AXI_WSTRB                     (M02_AXI_wstrb),  
     .S2_AXI_WVALID                    (M02_AXI_wvalid), 
     .S2_AXI_BREADY                    (M02_AXI_bready), 
     .S2_AXI_ARADDR                    (M02_AXI_araddr), 
     .S2_AXI_ARVALID                   (M02_AXI_arvalid),
     .S2_AXI_RREADY                    (M02_AXI_rready), 
     .S2_AXI_ARREADY                   (M02_AXI_arready),
     .S2_AXI_RDATA                     (M02_AXI_rdata),  
     .S2_AXI_RRESP                     (M02_AXI_rresp),  
     .S2_AXI_RVALID                    (M02_AXI_rvalid), 
     .S2_AXI_WREADY                    (M02_AXI_wready), 
     .S2_AXI_BRESP                     (M02_AXI_bresp),  
     .S2_AXI_BVALID                    (M02_AXI_bvalid), 
     .S2_AXI_AWREADY                   (M02_AXI_awready)
    
    );

  
   // PCI Express and PCIe to AXI_Lite bridge


pcie2axilite_sub pcie2axilite_sub_i
       (
           .M00_AXI_araddr  (M00_AXI_araddr  ),
           .M00_AXI_arprot  (M00_AXI_arprot  ),
           .M00_AXI_arready (M00_AXI_arready ),
           .M00_AXI_arvalid (M00_AXI_arvalid ),
           .M00_AXI_awaddr  (M00_AXI_awaddr  ),
           .M00_AXI_awprot  (M00_AXI_awprot  ),
           .M00_AXI_awready (M00_AXI_awready ),
           .M00_AXI_awvalid (M00_AXI_awvalid ),
           .M00_AXI_bready  (M00_AXI_bready  ),
           .M00_AXI_bresp   (M00_AXI_bresp   ),
           .M00_AXI_bvalid  (M00_AXI_bvalid  ),
           .M00_AXI_rdata   (M00_AXI_rdata   ),
           .M00_AXI_rready  (M00_AXI_rready  ),
           .M00_AXI_rresp   (M00_AXI_rresp   ),
           .M00_AXI_rvalid  (M00_AXI_rvalid  ),
           .M00_AXI_wdata   (M00_AXI_wdata   ),
           .M00_AXI_wready  (M00_AXI_wready  ),
           .M00_AXI_wstrb   (M00_AXI_wstrb   ),
           .M00_AXI_wvalid  (M00_AXI_wvalid  ),
           
           .M01_AXI_araddr  (M01_AXI_araddr  ),
           .M01_AXI_arprot  (M01_AXI_arprot  ),
           .M01_AXI_arready (M01_AXI_arready ),
           .M01_AXI_arvalid (M01_AXI_arvalid ),
           .M01_AXI_awaddr  (M01_AXI_awaddr  ),
           .M01_AXI_awprot  (M01_AXI_awprot  ),
           .M01_AXI_awready (M01_AXI_awready ),
           .M01_AXI_awvalid (M01_AXI_awvalid ),
           .M01_AXI_bready  (M01_AXI_bready  ),
           .M01_AXI_bresp   (M01_AXI_bresp   ),
           .M01_AXI_bvalid  (M01_AXI_bvalid  ),
           .M01_AXI_rdata   (M01_AXI_rdata   ),
           .M01_AXI_rready  (M01_AXI_rready  ),
           .M01_AXI_rresp   (M01_AXI_rresp   ),
           .M01_AXI_rvalid  (M01_AXI_rvalid  ),
           .M01_AXI_wdata   (M01_AXI_wdata   ),
           .M01_AXI_wready  (M01_AXI_wready  ),
           .M01_AXI_wstrb   (M01_AXI_wstrb   ),
           .M01_AXI_wvalid  (M01_AXI_wvalid  ),           

           
           .M02_AXI_araddr  (M02_AXI_araddr  ),
           .M02_AXI_arprot  (M02_AXI_arprot  ),
           .M02_AXI_arready (M02_AXI_arready ),
           .M02_AXI_arvalid (M02_AXI_arvalid ),
           .M02_AXI_awaddr  (M02_AXI_awaddr  ),
           .M02_AXI_awprot  (M02_AXI_awprot  ),
           .M02_AXI_awready (M02_AXI_awready ),
           .M02_AXI_awvalid (M02_AXI_awvalid ),
           .M02_AXI_bready  (M02_AXI_bready  ),
           .M02_AXI_bresp   (M02_AXI_bresp   ),
           .M02_AXI_bvalid  (M02_AXI_bvalid  ),
           .M02_AXI_rdata   (M02_AXI_rdata   ),
           .M02_AXI_rready  (M02_AXI_rready  ),
           .M02_AXI_rresp   (M02_AXI_rresp   ),
           .M02_AXI_rvalid  (M02_AXI_rvalid  ),
           .M02_AXI_wdata   (M02_AXI_wdata   ),
           .M02_AXI_wready  (M02_AXI_wready  ),
           .M02_AXI_wstrb   (M02_AXI_wstrb   ),
           .M02_AXI_wvalid  (M02_AXI_wvalid  ),   

           .M03_AXI_araddr  (),
           .M03_AXI_arprot  (),
           .M03_AXI_arready (),
           .M03_AXI_arvalid (),
           .M03_AXI_awaddr  (),
           .M03_AXI_awprot  (),
           .M03_AXI_awready (),
           .M03_AXI_awvalid (),
           .M03_AXI_bready  (),
           .M03_AXI_bresp   (),
           .M03_AXI_bvalid  (),
           .M03_AXI_rdata   (),
           .M03_AXI_rready  (),
           .M03_AXI_rresp   (),
           .M03_AXI_rvalid  (),
           .M03_AXI_wdata   (),
           .M03_AXI_wready  (),
           .M03_AXI_wstrb   (),
           .M03_AXI_wvalid  (),  

           .M04_AXI_araddr  (),
           .M04_AXI_arprot  (),
           .M04_AXI_arready (),
           .M04_AXI_arvalid (),
           .M04_AXI_awaddr  (),
           .M04_AXI_awprot  (),
           .M04_AXI_awready (),
           .M04_AXI_awvalid (),
           .M04_AXI_bready  (),
           .M04_AXI_bresp   (),
           .M04_AXI_bvalid  (),
           .M04_AXI_rdata   (),
           .M04_AXI_rready  (),
           .M04_AXI_rresp   (),
           .M04_AXI_rvalid  (),
           .M04_AXI_wdata   (),
           .M04_AXI_wready  (),
           .M04_AXI_wstrb   (),
           .M04_AXI_wvalid  (),

           .M05_AXI_araddr  (),
           .M05_AXI_arprot  (),
           .M05_AXI_arready (),
           .M05_AXI_arvalid (),
           .M05_AXI_awaddr  (),
           .M05_AXI_awprot  (),
           .M05_AXI_awready (),
           .M05_AXI_awvalid (),
           .M05_AXI_bready  (),
           .M05_AXI_bresp   (),
           .M05_AXI_bvalid  (),
           .M05_AXI_rdata   (),
           .M05_AXI_rready  (),
           .M05_AXI_rresp   (),
           .M05_AXI_rvalid  (),
           .M05_AXI_wdata   (),
           .M05_AXI_wready  (),
           .M05_AXI_wstrb   (),
           .M05_AXI_wvalid  (),  

           .M06_AXI_araddr  (),
           .M06_AXI_arprot  (),
           .M06_AXI_arready (),
           .M06_AXI_arvalid (),
           .M06_AXI_awaddr  (),
           .M06_AXI_awprot  (),
           .M06_AXI_awready (),
           .M06_AXI_awvalid (),
           .M06_AXI_bready  (),
           .M06_AXI_bresp   (),
           .M06_AXI_bvalid  (),
           .M06_AXI_rdata   (),
           .M06_AXI_rready  (),
           .M06_AXI_rresp   (),
           .M06_AXI_rvalid  (),
           .M06_AXI_wdata   (),
           .M06_AXI_wready  (),
           .M06_AXI_wstrb   (),
           .M06_AXI_wvalid  (),  

           .M07_AXI_araddr  (),
           .M07_AXI_arprot  (),
           .M07_AXI_arready (),
           .M07_AXI_arvalid (),
           .M07_AXI_awaddr  (),
           .M07_AXI_awprot  (),
           .M07_AXI_awready (),
           .M07_AXI_awvalid (),
           .M07_AXI_bready  (),
           .M07_AXI_bresp   (),
           .M07_AXI_bvalid  (),
           .M07_AXI_rdata   (),
           .M07_AXI_rready  (),
           .M07_AXI_rresp   (),
           .M07_AXI_rvalid  (),
           .M07_AXI_wdata   (),
           .M07_AXI_wready  (),
           .M07_AXI_wstrb   (),
           .M07_AXI_wvalid  (),  


           .s_axis_cq_tdata         (m_axis_cq_tdata  ),         
           .s_axis_cq_tkeep         (m_axis_cq_tkeep  ),
           .s_axis_cq_tlast         (m_axis_cq_tlast  ),
           .s_axis_cq_tready        (m_axis_cq_tready ),
           .s_axis_cq_tuser         (m_axis_cq_tuser  ),
           .s_axis_cq_tvalid        (m_axis_cq_tvalid ),
           .m_axis_cc_tdata   (s_axis_cc_tdata  ),
           .m_axis_cc_tkeep   (s_axis_cc_tkeep  ),
           .m_axis_cc_tlast   (s_axis_cc_tlast  ),
           .m_axis_cc_tready  (s_axis_cc_tready ),
           .m_axis_cc_tuser   (s_axis_cc_tuser  ),
           .m_axis_cc_tvalid  (s_axis_cc_tvalid ),
            
  
          .axi_aresetn (axi_aresetn),
           .axi_clk (axi_clk),
       
  //      .pcie_7x_mgt_rxn(pcie_7x_mgt_rxn),
  //      .pcie_7x_mgt_rxp(pcie_7x_mgt_rxp),
  //      .pcie_7x_mgt_txn(pcie_7x_mgt_txn),
  //      .pcie_7x_mgt_txp(pcie_7x_mgt_txp),
        .sys_clk(sys_clk),
        .sys_reset(sys_reset));

//Generated PCIe stimulus 
  cq_axis_stimulus #(
    .C_DATA_WIDTH(C_DATA_WIDTH),
    .PERIOD(PERIOD),
    .TCQ(TCQ)
  ) cq_axis_stimulus_i (
  .user_clk(sys_clk),
  .reset_n(!sys_reset),
  .m_axis_cq_tdata(m_axis_cq_tdata),
  .m_axis_cq_tuser(m_axis_cq_tuser),
  .m_axis_cq_tlast(m_axis_cq_tlast),
  .m_axis_cq_tkeep(m_axis_cq_tkeep),
  .m_axis_cq_tvalid(m_axis_cq_tvalid),
  .m_axis_cq_tready(m_axis_cq_tready)
    );
    
 
  
   
    
//Reset handling
 // Important! polarity here is opposite the one in the actual design
   initial begin 
    sys_reset = 1'b0;
    #(PERIOD * 200);
    sys_reset = 1'b1;
    $display("Reset Deasserted");
   end

//Clock generation
   initial begin
      sys_clk = 1'b0;
      #(PERIOD/2);
      forever
         #(PERIOD/2) sys_clk = ~sys_clk;
   end 


   initial begin
      forever
            #(PERIOD/2) s_axis_cc_tready = {4{( throttle_percent > ($random %100))}};            
   end
 
    
    initial begin
      forever begin
        @(posedge sys_clk) begin
          if (s_axis_cc_tvalid & s_axis_cc_tready[0] & s_axis_cc_tlast) begin
            if ( C_DATA_WIDTH == 64 ) begin
              #1 $display ("%g Lower Address = %h, Tag = %h, Data = %h", $time, completion_data[0][7:0], completion_data[1][7:0], completion_data[1][63:32] );
            end else if (  C_DATA_WIDTH == 128  ) begin
              #1 $display ("%g Lower Address = %h, Tag = %h, Data = %h", $time, completion_data[1][7:0], completion_data[1][7+64:0+64], completion_data[1][63+64:32+64] );
            end else if (  C_DATA_WIDTH == 256  ) begin
              #1 $display ("%g Lower Address = %h, Tag = %h, Data = %h", $time, completion_data[1][7:0], completion_data[1][7+64:0+64], completion_data[1][63+64:32+64] );
            end
          end        
        end      
      end
    end



    initial begin
     forever begin
       @(posedge sys_clk)
      if (s_axis_cc_tvalid & s_axis_cc_tready[0]) begin
       completion_data[0]  <= completion_data[1];
       completion_data[1]  <= s_axis_cc_tdata;
      end
end
end
 

endmodule
