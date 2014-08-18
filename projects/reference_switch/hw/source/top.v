//-----------------------------------------------------------------------------
//
// Here comes the NetFPGA new and nice header
//--
//------------------------------------------------------------------------------

`timescale 1ps / 1ps

 module top # (
  parameter          PL_SIM_FAST_LINK_TRAINING           = "FALSE",      // Simulation Speedup
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

//PCI Express
  input  [7:0]pcie_7x_mgt_rxn,
  input  [7:0]pcie_7x_mgt_rxp,
  output [7:0]pcie_7x_mgt_txn,
  output [7:0]pcie_7x_mgt_txp,
//10G Interface

  input [0:0] rxp,
  input [0:0] rxn,
  output [0:0] txp,
  output [0:0] txn,
  
// PCIe Clock
  input       sys_clkp,
  input       sys_clkn,
  
  //200MHz Clock
  input       clk_ref_p,
  input       clk_ref_n,
  
  
  
      //-SI5324 I2C programming interface
  inout                          i2c_clk,
  inout                          i2c_data,
  output                         i2c_mux_rst_n,
  output                         si5324_rst_n,
  // 156.25 MHz clock in
  input                          xphy_refclk_p,
  input                          xphy_refclk_n,
      

  input       sys_reset
);


  
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

  wire                                       sys_clk;
  wire                                       clk_200_i;
 wire                                       clk_200;
  wire                                       sys_rst_n_c;

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
  
  wire [31:0]   M03_AXI_araddr;
  wire [2:0]    M03_AXI_arprot;
  wire [0:0]    M03_AXI_arready;
  wire [0:0]    M03_AXI_arvalid;
  wire [31:0]   M03_AXI_awaddr;
  wire [2:0]    M03_AXI_awprot;
  wire [0:0]    M03_AXI_awready;
  wire [0:0]    M03_AXI_awvalid;
  wire [0:0]    M03_AXI_bready;
  wire [1:0]    M03_AXI_bresp;
  wire [0:0]    M03_AXI_bvalid;
  wire [31:0]   M03_AXI_rdata;
  wire [0:0]    M03_AXI_rready;
  wire [1:0]    M03_AXI_rresp;
  wire [0:0]    M03_AXI_rvalid;
  wire [31:0]   M03_AXI_wdata;
  wire [0:0]    M03_AXI_wready;
  wire [3:0]    M03_AXI_wstrb;
  wire [0:0]    M03_AXI_wvalid;
  
  wire [31:0]   M04_AXI_araddr;
  wire [2:0]    M04_AXI_arprot;
  wire [0:0]    M04_AXI_arready;
  wire [0:0]    M04_AXI_arvalid;
  wire [31:0]   M04_AXI_awaddr;
  wire [2:0]    M04_AXI_awprot;
  wire [0:0]    M04_AXI_awready;
  wire [0:0]    M04_AXI_awvalid;
  wire [0:0]    M04_AXI_bready;
  wire [1:0]    M04_AXI_bresp;
  wire [0:0]    M04_AXI_bvalid;
  wire [31:0]   M04_AXI_rdata;
  wire [0:0]    M04_AXI_rready;
  wire [1:0]    M04_AXI_rresp;
  wire [0:0]    M04_AXI_rvalid;
  wire [31:0]   M04_AXI_wdata;
  wire [0:0]    M04_AXI_wready;
  wire [3:0]    M04_AXI_wstrb;
  wire [0:0]    M04_AXI_wvalid;
    
  
  wire axi_aresetn;
  wire axi_clk;
  // --------------------------------------------------------------------
  //I2C Synthesizer Interface
  // 50mhz clk
  // --------------------------------------------------------------------
  wire          clk50;
  reg [1:0]     clk_divide = 2'b00;
  
  always @(posedge clk_200)
  clk_divide  <= clk_divide + 1'b1;

  //---------------------------------------------------------------------
  // Misc 
  //---------------------------------------------------------------------
  
  IBUF   sys_reset_n_ibuf (  .O(sys_rst_n_c),   .I(~sys_reset));

    IBUFDS_GTE2 #(
     .CLKCM_CFG("TRUE"),   // Refer to Transceiver User Guide
     .CLKRCV_TRST("TRUE"), // Refer to Transceiver User Guide
     .CLKSWING_CFG(2'b11)  // Refer to Transceiver User Guide
  )
  IBUFDS_GTE2_inst (
     .O(sys_clk),         // 1-bit output: Refer to Transceiver User Guide
     .ODIV2(),            // 1-bit output: Refer to Transceiver User Guide
     .CEB(1'b0),          // 1-bit input: Refer to Transceiver User Guide
     .I(sys_clkp),        // 1-bit input: Refer to Transceiver User Guide
     .IB(sys_clkn)        // 1-bit input: Refer to Transceiver User Guide
  );  
  
 
   // 200mhz ref clk
  IBUFGDS #(
    .DIFF_TERM    ("TRUE"),
    .IBUF_LOW_PWR ("FALSE")
  ) diff_clk_200 (
    .I    (clk_ref_p  ),
    .IB   (clk_ref_n  ),
    .O    (clk_200_i )  
  );
  
  BUFG u_bufg_clk_ref
  (
    .O (clk_200),
    .I (clk_200_i)
  );
  
 //-SI 5324 programming
/*  clock_control cc_inst (
     .i2c_clk        (i2c_clk        ),
     .i2c_data       (i2c_data       ),
     .i2c_mux_rst_n  (i2c_mux_rst_n  ),
     .si5324_rst_n   (si5324_rst_n   ),
     .rst            (reset    ),  
     .clk50          (clk50          )
   );    
*/
 
wire reset;
assign reset = !sys_rst_n_c;


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
    .axis_aclk                        (clk_200),
    .axis_resetn                      (sys_rst_n_c),
    .axi_aclk                        (axi_clk),
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

           .M03_AXI_araddr  (M03_AXI_araddr ),
           .M03_AXI_arprot  (M03_AXI_arprot ),
           .M03_AXI_arready (M03_AXI_arready),
           .M03_AXI_arvalid (M03_AXI_arvalid),
           .M03_AXI_awaddr  (M03_AXI_awaddr ),
           .M03_AXI_awprot  (M03_AXI_awprot ),
           .M03_AXI_awready (M03_AXI_awready),
           .M03_AXI_awvalid (M03_AXI_awvalid),
           .M03_AXI_bready  (M03_AXI_bready ),
           .M03_AXI_bresp   (M03_AXI_bresp  ),
           .M03_AXI_bvalid  (M03_AXI_bvalid ),
           .M03_AXI_rdata   (M03_AXI_rdata  ),
           .M03_AXI_rready  (M03_AXI_rready ),
           .M03_AXI_rresp   (M03_AXI_rresp  ),
           .M03_AXI_rvalid  (M03_AXI_rvalid ),
           .M03_AXI_wdata   (M03_AXI_wdata  ),
           .M03_AXI_wready  (M03_AXI_wready ),
           .M03_AXI_wstrb   (M03_AXI_wstrb  ),
           .M03_AXI_wvalid  (M03_AXI_wvalid ), 

           .M04_AXI_araddr  (M04_AXI_araddr ),
           .M04_AXI_arprot  (M04_AXI_arprot ),
           .M04_AXI_arready (M04_AXI_arready),
           .M04_AXI_arvalid (M04_AXI_arvalid),
           .M04_AXI_awaddr  (M04_AXI_awaddr ),
           .M04_AXI_awprot  (M04_AXI_awprot ),
           .M04_AXI_awready (M04_AXI_awready),
           .M04_AXI_awvalid (M04_AXI_awvalid),
           .M04_AXI_bready  (M04_AXI_bready ),
           .M04_AXI_bresp   (M04_AXI_bresp  ),
           .M04_AXI_bvalid  (M04_AXI_bvalid ),
           .M04_AXI_rdata   (M04_AXI_rdata  ),
           .M04_AXI_rready  (M04_AXI_rready ),
           .M04_AXI_rresp   (M04_AXI_rresp  ),
           .M04_AXI_rvalid  (M04_AXI_rvalid ),
           .M04_AXI_wdata   (M04_AXI_wdata  ),
           .M04_AXI_wready  (M04_AXI_wready ),
           .M04_AXI_wstrb   (M04_AXI_wstrb  ),
           .M04_AXI_wvalid  (M04_AXI_wvalid ),

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

  
          .axi_aresetn (axi_aresetn),
          .axi_clk (axi_clk),
       
        .pcie_7x_mgt_rxn(pcie_7x_mgt_rxn),
        .pcie_7x_mgt_rxp(pcie_7x_mgt_rxp),
        .pcie_7x_mgt_txn(pcie_7x_mgt_txn),
        .pcie_7x_mgt_txp(pcie_7x_mgt_txp),
        .sys_clk(sys_clk),
        .sys_reset(~sys_reset));
        
        
// 10G Interfaces
//Port 0

  nf_10g_interface #(
    .C_BASEADDR('H00003000),
    .C_HIGHADDR('H00003FFF),
    .IF_NUMBER('H0000)
  ) inst (
    .axi_aclk(clk_200),
    .axi_resetn(sys_rst_n_c),
    .refclk_p(xphy_refclk_p),
    .refclk_n(xphy_refclk_n),
    .m_axis_tdata(axis_i_0_tdata),
    .m_axis_tstrb(axis_i_tstrb),
    .m_axis_tuser(axis_i_tuser),
    .m_axis_tvalid(axis_i_tvalid),
    .m_axis_tready(axis_i_tready),
    .m_axis_tlast(axis_i_tlast),
    .s_axis_tdata(axis_o_tdata),
    .s_axis_tstrb(axis_o_tstrb),
    .s_axis_tuser(axis_o_tuser),
    .s_axis_tvalid(axis_o_tvalid),
    .s_axis_tready(axis_o_tready),
    .s_axis_tlast(axis_o_tlast),
    .S_AXI_ACLK(axi_clk),
    .S_AXI_ARESETN(axi_resetn),
    .S_AXI_AWADDR(M03_AXI_AWADDR),
    .S_AXI_AWVALID(M03_AXI_AWVALID),
    .S_AXI_WDATA(M03_AXI_WDATA),
    .S_AXI_WSTRB(M03_AXI_WSTRB),
    .S_AXI_WVALID(M03_AXI_WVALID),
    .S_AXI_BREADY(M03_AXI_BREADY),
    .S_AXI_ARADDR(M03_AXI_ARADDR),
    .S_AXI_ARVALID(M03_AXI_ARVALID),
    .S_AXI_RREADY(M03_AXI_RREADY),
    .S_AXI_ARREADY(M03_AXI_ARREADY),
    .S_AXI_RDATA(M03_AXI_RDATA),
    .S_AXI_RRESP(M03_AXI_RRESP),
    .S_AXI_RVALID(M03_AXI_RVALID),
    .S_AXI_WREADY(M03_AXI_WREADY),
    .S_AXI_BRESP(M03_AXI_BRESP),
    .S_AXI_BVALID(M03_AXI_BVALID),
    .S_AXI_AWREADY(M03_AXI_AWREADY),
    .XGE_S_AXI_ACLK(M04_AXI_ACLK),
    .XGE_S_AXI_ARESETN(M04_AXI_ARESETN),
    .XGE_S_AXI_AWADDR(M04_AXI_AWADDR),
    .XGE_S_AXI_AWVALID(M04_AXI_AWVALID),
    .XGE_S_AXI_WDATA(M04_AXI_WDATA),
    .XGE_S_AXI_WSTRB(M04_AXI_WSTRB),
    .XGE_S_AXI_WVALID(M04_AXI_WVALID),
    .XGE_S_AXI_BREADY(M04_AXI_BREADY),
    .XGE_S_AXI_ARADDR(M04_AXI_ARADDR),
    .XGE_S_AXI_ARVALID(M04_AXI_ARVALID),
    .XGE_S_AXI_RREADY(M04_AXI_RREADY),
    .XGE_S_AXI_ARREADY(M04_AXI_ARREADY),
    .XGE_S_AXI_RDATA(M04_AXI_RDATA),
    .XGE_S_AXI_RRESP(M04_AXI_RRESP),
    .XGE_S_AXI_RVALID(M04_AXI_RVALID),
    .XGE_S_AXI_WREADY(M04_AXI_WREADY),
    .XGE_S_AXI_BRESP(M04_AXI_BRESP),
    .XGE_S_AXI_BVALID(M04_AXI_BVALID),
    .XGE_S_AXI_AWREADY(M04_AXI_AWREADY),
    .txp(txp),
    .txn(txn),
    .rxp(rxp),
    .rxn(rxn)
  );        



endmodule

