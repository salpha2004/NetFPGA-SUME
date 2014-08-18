/*******************************************************************************
 *
 *  NetFPGA-SUME http://www.netfpga.org
 *
 *  File:
 *        nf_10g_interface.v
 *
 * 
*/

`include "nf_10g_if_cpu_regs_defines.v"

module nf_10g_interface
#(
     // Master AXI Stream Data Width
    parameter C_M_AXIS_DATA_WIDTH=256,
    parameter C_S_AXIS_DATA_WIDTH=256,
    parameter C_M_AXIS_TUSER_WIDTH=128,
    parameter C_S_AXIS_TUSER_WIDTH=128,
    parameter C_DEFAULT_VALUE_ENABLE = 0,
    parameter C_DEFAULT_SRC_PORT = 0,
    parameter C_DEFAULT_DST_PORT = 0,

    // AXI Data Width
    parameter C_S_AXI_ACLK_FREQ_HZ  = 250,
    parameter C_S_AXI_DATA_WIDTH    = 32,         
    parameter C_S_AXI_ADDR_WIDTH    = 32,         
    parameter C_USE_WSTRB           = 0,             
    parameter C_DPHASE_TIMEOUT      = 0,          
    parameter C_NUM_ADDRESS_RANGES = 1,           
    parameter  C_TOTAL_NUM_CE       = 1,          
    parameter  C_S_AXI_MIN_SIZE    = 32'h0000_FFFF,
    //parameter [0:32*2*C_NUM_ADDRESS_RANGES-1]   
    //                                            
    //                                            
    parameter [0:8*C_NUM_ADDRESS_RANGES-1] C_ARD_NUM_CE_ARRAY  = 
                                                 {
                                                  C_NUM_ADDRESS_RANGES{8'd1}
                                                  },
    parameter     C_FAMILY            = "virtex7",
    parameter C_BASEADDR            = 32'h00000000,
    parameter C_HIGHADDR            = 32'h0000FFFF,
    
    //Interface number
    parameter IF_NUMBER = 16'h0000
)

(
    // Part 1: System side signals
    // Global Ports
    input axi_aclk,
    input axi_resetn,

 //   input dclk,   //DRP Clock 50MHz
    input refclk_p, //GTX Clock 156.25MHz
    input refclk_n,

    // Master Stream Ports
    output [C_M_AXIS_DATA_WIDTH - 1:0] m_axis_tdata,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_tstrb,
    output [C_M_AXIS_TUSER_WIDTH-1:0] m_axis_tuser, // Dummy AXI TUSER
    output m_axis_tvalid,
    input  m_axis_tready,
    output m_axis_tlast,

    // Slave Stream Ports
    input [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_tstrb,
    input [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_tuser,
    input  s_axis_tvalid,
    output s_axis_tready,
    input  s_axis_tlast,

    // Signals for AXI_IP and IF_REG (Added by neels for testing)
    // Slave AXI Ports
    input                                     S_AXI_ACLK,
    input                                     S_AXI_ARESETN,
    input      [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_AWADDR,
    input                                     S_AXI_AWVALID,
    input      [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_WDATA,
    input      [C_S_AXI_DATA_WIDTH/8-1 : 0]   S_AXI_WSTRB,
    input                                     S_AXI_WVALID,
    input                                     S_AXI_BREADY,
    input      [C_S_AXI_ADDR_WIDTH-1 : 0]     S_AXI_ARADDR,
    input                                     S_AXI_ARVALID,
    input                                     S_AXI_RREADY,
    output                                    S_AXI_ARREADY,
    output     [C_S_AXI_DATA_WIDTH-1 : 0]     S_AXI_RDATA,
    output     [1 : 0]                        S_AXI_RRESP,
    output                                    S_AXI_RVALID,
    output                                    S_AXI_WREADY,
    output     [1 :0]                         S_AXI_BRESP,
    output                                    S_AXI_BVALID,
    output                                    S_AXI_AWREADY,
    
    
    input                                     XGE_S_AXI_ACLK,
    input                                     XGE_S_AXI_ARESETN,
    input      [C_S_AXI_ADDR_WIDTH-1 : 0]     XGE_S_AXI_AWADDR,
    input                                     XGE_S_AXI_AWVALID,
    input      [C_S_AXI_DATA_WIDTH-1 : 0]     XGE_S_AXI_WDATA,
    input      [C_S_AXI_DATA_WIDTH/8-1 : 0]   XGE_S_AXI_WSTRB,
    input                                     XGE_S_AXI_WVALID,
    input                                     XGE_S_AXI_BREADY,
    input      [C_S_AXI_ADDR_WIDTH-1 : 0]     XGE_S_AXI_ARADDR,
    input                                     XGE_S_AXI_ARVALID,
    input                                     XGE_S_AXI_RREADY,
    output                                    XGE_S_AXI_ARREADY,
    output     [C_S_AXI_DATA_WIDTH-1 : 0]     XGE_S_AXI_RDATA,
    output     [1 : 0]                        XGE_S_AXI_RRESP,
    output                                    XGE_S_AXI_RVALID,
    output                                    XGE_S_AXI_WREADY,
    output     [1 :0]                         XGE_S_AXI_BRESP,
    output                                    XGE_S_AXI_BVALID,
    output                                    XGE_S_AXI_AWREADY,



    // Part 2: PHY side signals
    // XAUI PHY Interface
    output        txp,
    output        txn,


    input         rxp,
    input         rxn
 );

  localparam C_M_AXIS_DATA_WIDTH_INTERNAL=64;
  localparam C_S_AXIS_DATA_WIDTH_INTERNAL=64;

  localparam NUM_RW_REGS       = 1;
  localparam NUM_RO_REGS       = 17;

    wire                                            Bus2IP_Clk;
    wire                                            Bus2IP_Resetn;
    wire     [C_S_AXI_ADDR_WIDTH-1 : 0]             Bus2IP_Addr;
    wire     [0:0]                                  Bus2IP_CS;
    wire                                            Bus2IP_RNW;
    wire     [C_S_AXI_DATA_WIDTH-1 : 0]             Bus2IP_Data;
    wire     [C_S_AXI_DATA_WIDTH/8-1 : 0]           Bus2IP_BE;
    wire     [C_S_AXI_DATA_WIDTH-1 : 0]             IP2Bus_Data;
    wire                                            IP2Bus_RdAck;
    wire                                            IP2Bus_WrAck;
    wire                                            IP2Bus_Error;

  //wire clk156, txoutclk;
  wire clk156_out;
//  wire [63:0] xgmii_rxd, xgmii_txd;
//  wire [ 7:0] xgmii_rxc, xgmii_txc;

  wire [63 : 0] tx_data;
  wire [7 : 0]  tx_data_valid;
  wire          tx_start;
  wire          tx_ack;

  wire [63 : 0] rx_data;
  wire [7 : 0]  rx_data_valid;

  wire          rx_good_frame;
  wire          rx_bad_frame;

    // Master Stream Ports
    wire [C_M_AXIS_DATA_WIDTH_INTERNAL - 1:0] m_axis_tdata_internal;
    wire [((C_M_AXIS_DATA_WIDTH_INTERNAL / 8)) - 1:0] m_axis_tstrb_internal;
    wire [C_M_AXIS_TUSER_WIDTH-1:0] m_axis_tuser_internal; // Dummy AXI TUSER
    wire m_axis_tvalid_internal;
    wire  m_axis_tready_internal;
    wire m_axis_tlast_internal;

    // Slave Stream Ports
    wire [C_S_AXIS_DATA_WIDTH_INTERNAL - 1:0] s_axis_tdata_internal;
    wire [((C_S_AXIS_DATA_WIDTH_INTERNAL / 8)) - 1:0] s_axis_tstrb_internal;
    wire [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_tuser_internal;
    wire  s_axis_tvalid_internal;
    wire  s_axis_tready_internal;


    wire  s_axis_tlast_internal;

//    wire  drop_pkt;
    wire info_fifo_rd_en;
    wire info_fifo_wr_en;
    wire fifo_wr_en;
reg [31:0] tx_enqueued_pkts, tx_enqueued_bytes;

//CPU Registers 

 reg      [`REG_ID_BITS]    id_reg;
  reg      [`REG_VERSION_BITS]    version_reg;
  reg      [`REG_FLIP_BITS]    ip2cpu_flip_reg;
  wire     [`REG_FLIP_BITS]    cpu2ip_flip_reg;
  reg      [`REG_COUNTERIN_BITS]    counterin_reg;
  wire                             counterin_reg_clear;
  reg      [`REG_COUNTEROUT_BITS]    counterout_reg;
  wire                             counterout_reg_clear;
  reg      [`REG_DEBUG_BITS]    ip2cpu_debug_reg;
  wire     [`REG_DEBUG_BITS]    cpu2ip_debug_reg;


  reg      [C_S_AXI_DATA_WIDTH-1 : 0]             tx_dequeued_pkts;	
  reg      [C_S_AXI_DATA_WIDTH-1 : 0]             drop_pkt_counter;	
  wire                                            rst_cntrs;

// rx_queues  
  
  reg      [C_S_AXI_DATA_WIDTH-1 : 0]             good_frames_counter;
  reg      [C_S_AXI_DATA_WIDTH-1 : 0]             bad_frames_counter;
  reg [31:0] bytes_from_mac_ff;
  reg [31:0] num_rx, rx_enqueued_bytes_ff;
  wire [31:0] bytes_from_mac;
  reg [31:0] rx_enqueued_pkts; 
  wire [31:0] rx_enqueued_bytes;
  reg [31:0] rx_dequeued_pkts, rx_dequeued_bytes;
  reg [31:0] rx_bytes_in_queue, rx_pkts_in_queue;
  reg [31:0] rx_pkts_dropped, rx_bytes_dropped;

// tx_queues  
  wire  tx_dequeued_pkt;
  wire  tx_pkts_enqueued_signal;
  wire  [15:0] tx_bytes_enqueued;
  reg [31:0] tx_dequeued_bytes_ff,tx_dequeued_bytes_ff_d, tx_dequeued_bytes_ff_dd;
  wire [31:0] tx_dequeued_bytes;
  reg [31:0] tx_bytes_in_queue, tx_pkts_in_queue;
  reg [31:0] tx_pkts_dropped, tx_bytes_dropped;

  wire be;


  wire reset = ~axi_resetn;
  assign m_axis_tuser_internal = {(C_M_AXIS_TUSER_WIDTH){1'b0}};


  // =============================================================================
  // Module Instantiation
  // =============================================================================

  // Put system clocks on global routing
  BUFG clk156_bufg (
    .I(clk156_out),
    .O(clk156));

 ////////////////////////////////////
 // Instantiate 10G AXI port  
 ///////////////////////////////////
 
 
 xge_sub xge_sub_i
        (.clk156_out(clk156_out),
         .m_axis_rx_tdata(m_axis_tdata_internal),
         .m_axis_rx_tkeep(m_axis_tkeep_internal),
         .m_axis_rx_tlast(m_axis_tlast_internal),
         .m_axis_rx_ts_tdata(),//for future use
         .m_axis_rx_ts_tvalid(),//for future use
         .m_axis_rx_tuser(m_axis_tuser_internal),
         .m_axis_rx_tvalid(m_axis_tvalid_internal),
         .m_axis_tx_ts_tdata(),//for future use
         .m_axis_tx_ts_tvalid(),//for future use
         .pcspma_status(), //for future use
         .qplllock_out(),//for future use
         .qplloutclk_out(),//for future use
         .qplloutrefclk_out(),//for future use
         .refclk_n(refclk_n),
         .refclk_p(refclk_p),
         .reset(reset),
         .reset_counter_done_out(),//for future use
         .resetdone(),//for future use
         .rx_axis_aresetn(axi_resetn),
         .rx_statistics_valid(),//for future use
         .rx_statistics_vector(),//for future use
         .rxn(rxn),
         .rxp(rxp),
         .s_axi_aclk(XGE_S_AXI_ACLK),
         .s_axi_araddr(XGE_S_AXI_ARADDR),
         .s_axi_aresetn(XGE_S_AXI_ARESETN),
         .s_axi_arready(XGE_S_AXI_ARREADY),
         .s_axi_arvalid(XGE_S_AXI_ARVALID),
         .s_axi_awaddr(XGE_S_AXI_AWADDR),
         .s_axi_awready(XGE_S_AXI_AWREADY),
         .s_axi_awvalid(XGE_S_AXI_AWVALID),
         .s_axi_bready(s_axi_XGE_S_AXI_BREADY),
         .s_axi_bresp(XGE_S_AXI_BRESP),
         .s_axi_bvalid(XGE_S_AXI_BVALID),
         .s_axi_rdata(XGE_S_AXI_RDATA),
         .s_axi_rready(XGE_S_AXI_RREADY),
         .s_axi_rresp(XGE_S_AXI_RRESP),
         .s_axi_rvalid(XGE_S_AXI_RVALID),
         .s_axi_wdata(XGE_S_AXI_WDATA),
         .s_axi_wready(XGE_S_AXI_WREADY),
         .s_axi_wvalid(XGE_S_AXI_WVALID),
         .s_axis_pause_tdata(),//for future use
         .s_axis_pause_tvalid(),//for future use
         .s_axis_tx_tdata(s_axis_tdata_internal),
         .s_axis_tx_tkeep(s_axis_tkeep_internal),
         .s_axis_tx_tlast(s_axis_tlast_internal),
         .s_axis_tx_tready(s_axis_tready_internal),
         .s_axis_tx_tuser(s_axis_tuser_internal),
         .s_axis_tx_tvalid(s_axis_tvalid_internal),
         .signal_detect(1'b1),//for future use
         .systemtimer_clk(),//for future use
         .systemtimer_ns_field(),//for future use
         .systemtimer_s_field(),//for future use
         .tx_axis_aresetn(axis_resetn),
         .tx_disable(),//for future use
         .tx_fault(1'b0),//for future use
         .tx_ifg_delay(8'h8),//for future use
         .tx_statistics_valid(),//for future use
         .tx_statistics_vector(),//for future use
         .txn(txn),
         .txp(txp),
         .xgmacint()//for future use
         );
 
 
    ////////////////////////////////
    // Instantiate the AXI Converter
    ////////////////////////////////
    rx_queue #(
       .AXI_DATA_WIDTH(C_M_AXIS_DATA_WIDTH_INTERNAL)
    )rx_queue (
       // AXI side
       .tdata(m_axis_tdata_internal),
       .tstrb(m_axis_tstrb_internal),
       .tvalid(m_axis_tvalid_internal),
       .tlast(m_axis_tlast_internal),
       .tready(m_axis_tready_internal),
       .clk(axi_aclk),
       .reset(~axi_resetn),
       .fifo_wr_en(fifo_wr_en),
       // MAC side
       .rx_data(rx_data),
       .rx_data_valid(rx_data_valid),
       .rx_good_frame(rx_good_frame),
       .rx_bad_frame(rx_bad_frame),
       .clk156(clk156)
    );

    tx_queue #(
       .AXI_DATA_WIDTH(C_S_AXIS_DATA_WIDTH_INTERNAL),
       .C_S_AXIS_TUSER_WIDTH(C_S_AXIS_TUSER_WIDTH)
    )
    tx_queue (
       // AXI side
       .tuser(s_axis_tuser_internal),
       .tdata(s_axis_tdata_internal),
       .tstrb(s_axis_tstrb_internal),
       .tvalid(s_axis_tvalid_internal),
       .tlast(s_axis_tlast_internal),
       .tready(s_axis_tready_internal),
       .tx_dequeued_pkt(tx_dequeued_pkt),
       .tx_pkts_enqueued_signal(tx_pkts_enqueued_signal),
       .tx_bytes_enqueued(tx_bytes_enqueued),
       .be(be),
       .clk(axi_aclk),
       .reset(~axi_resetn),
       // MAC side
       .tx_data(tx_data),
       .tx_data_valid(tx_data_valid),
       .tx_start(tx_start),
       .tx_ack(tx_ack),
       .clk156(clk156)
    );

    nf10_axis_converter
    #(.C_M_AXIS_DATA_WIDTH(C_M_AXIS_DATA_WIDTH),
      .C_S_AXIS_DATA_WIDTH(C_M_AXIS_DATA_WIDTH_INTERNAL),
      .C_DEFAULT_VALUE_ENABLE(C_DEFAULT_VALUE_ENABLE),
      .C_DEFAULT_SRC_PORT(C_DEFAULT_SRC_PORT),
      .C_DEFAULT_DST_PORT(C_DEFAULT_DST_PORT)
     ) converter_master
    (
    // Global Ports
    .axi_aclk(axi_aclk),
    .axi_resetn(axi_resetn),

    // Master Stream Ports
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tstrb(m_axis_tstrb),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tlast(m_axis_tlast),
	.m_axis_tuser(m_axis_tuser),

    // Slave Stream Ports
    .s_axis_tdata(m_axis_tdata_internal),
    .s_axis_tstrb(m_axis_tstrb_internal),
    .s_axis_tvalid(m_axis_tvalid_internal),
    .s_axis_tready(m_axis_tready_internal),
    .s_axis_tlast(m_axis_tlast_internal),
	.s_axis_tuser(m_axis_tuser_internal)
   );

    nf10_axis_converter
    #(.C_M_AXIS_DATA_WIDTH(C_S_AXIS_DATA_WIDTH_INTERNAL),
      .C_S_AXIS_DATA_WIDTH(C_S_AXIS_DATA_WIDTH)
     ) converter_slave
    (
    // Global Ports
    .axi_aclk(axi_aclk),
    .axi_resetn(axi_resetn),

    // Master Stream Ports
    .m_axis_tdata(s_axis_tdata_internal),
    .m_axis_tstrb(s_axis_tstrb_internal),
    .m_axis_tvalid(s_axis_tvalid_internal),
    .m_axis_tready(s_axis_tready_internal),
    .m_axis_tlast(s_axis_tlast_internal),
	 .m_axis_tuser(s_axis_tuser_internal),

    // Slave Stream Ports
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tstrb(s_axis_tstrb),
    .s_axis_tvalid(s_axis_tvalid),
    .s_axis_tready(s_axis_tready),
    .s_axis_tlast(s_axis_tlast),
	.s_axis_tuser(s_axis_tuser)
   );

 // -- AXILITE IPIF
/*
  axi_lite_ipif_1bar #
  (
    .C_S_AXI_DATA_WIDTH (C_S_AXI_DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH (C_S_AXI_ADDR_WIDTH),
    .C_USE_WSTRB        (C_USE_WSTRB),
    .C_DPHASE_TIMEOUT   (C_DPHASE_TIMEOUT),
    .C_BAR0_BASEADDR    (C_BASEADDR),
    .C_BAR0_HIGHADDR    (C_HIGHADDR)
  ) axi_lite_ipif_inst
  (
    .S_AXI_ACLK          ( S_AXI_ACLK     ),
    .S_AXI_ARESETN       ( axi_resetn     ),
    .S_AXI_AWADDR        ( S_AXI_AWADDR   ),
    .S_AXI_AWVALID       ( S_AXI_AWVALID  ),
    .S_AXI_WDATA         ( S_AXI_WDATA    ),
    .S_AXI_WSTRB         ( S_AXI_WSTRB    ),
    .S_AXI_WVALID        ( S_AXI_WVALID   ),
    .S_AXI_BREADY        ( S_AXI_BREADY   ),
    .S_AXI_ARADDR        ( S_AXI_ARADDR   ),
    .S_AXI_ARVALID       ( S_AXI_ARVALID  ),
    .S_AXI_RREADY        ( S_AXI_RREADY   ),
    .S_AXI_ARREADY       ( S_AXI_ARREADY  ),
    .S_AXI_RDATA         ( S_AXI_RDATA    ),
    .S_AXI_RRESP         ( S_AXI_RRESP    ),
    .S_AXI_RVALID        ( S_AXI_RVALID   ),
    .S_AXI_WREADY        ( S_AXI_WREADY   ),
    .S_AXI_BRESP         ( S_AXI_BRESP    ),
    .S_AXI_BVALID        ( S_AXI_BVALID   ),
    .S_AXI_AWREADY       ( S_AXI_AWREADY  ),
	
	// Controls to the IP/IPIF modules
    .Bus2IP_Clk          ( Bus2IP_Clk     ),
    .Bus2IP_Resetn       ( Bus2IP_Resetn  ),
    .Bus2IP_Addr         ( Bus2IP_Addr    ),
    .Bus2IP_RNW          ( Bus2IP_RNW     ),
    .Bus2IP_BE           ( Bus2IP_BE      ),
    .Bus2IP_CS           ( Bus2IP_CS      ),
    .Bus2IP_Data         ( Bus2IP_Data    ),
    .IP2Bus_Data         ( IP2Bus_Data    ),
    .IP2Bus_WrAck        ( IP2Bus_WrAck   ),
    .IP2Bus_RdAck        ( IP2Bus_RdAck   ),
    .IP2Bus_Error        ( IP2Bus_Error   )
  );
*/
 

//Registers section
nf_10g_if_cpu_regs 
 #(
   .C_S_AXI_DATA_WIDTH (C_S_AXI_DATA_WIDTH),
   .C_S_AXI_ADDR_WIDTH (C_S_AXI_ADDR_WIDTH),
   .C_USE_WSTRB        (C_USE_WSTRB),
   .C_DPHASE_TIMEOUT   (C_DPHASE_TIMEOUT),
   .C_NUM_ADDRESS_RANGES (C_NUM_ADDRESS_RANGES),
   .C_TOTAL_NUM_CE    ( C_TOTAL_NUM_CE),
   .C_S_AXI_MIN_SIZE  (C_S_AXI_MIN_SIZE),
   .C_BASE_ADDRESS    (C_BASEADDR),
   .C_HIGH_ADDRESS    (C_HIGHADDR),
   .C_FAMILY (C_FAMILY)
 ) nf_10g_if_cpu_regs_inst
 (   
   // General ports
    .clk                    (axi_aclk),
    .resetn                 (axi_resetn),
   // AXI Lite ports
    .S_AXI_ACLK             (S_AXI_ACLK),
    .S_AXI_ARESETN          (S_AXI_ARESETN),
    .S_AXI_AWADDR           (S_AXI_AWADDR),
    .S_AXI_AWVALID          (S_AXI_AWVALID),
    .S_AXI_WDATA            (S_AXI_WDATA),
    .S_AXI_WSTRB            (S_AXI_WSTRB),
    .S_AXI_WVALID           (S_AXI_WVALID),
    .S_AXI_BREADY           (S_AXI_BREADY),
    .S_AXI_ARADDR           (S_AXI_ARADDR),
    .S_AXI_ARVALID          (S_AXI_ARVALID),
    .S_AXI_RREADY           (S_AXI_RREADY),
    .S_AXI_ARREADY          (S_AXI_ARREADY),
    .S_AXI_RDATA            (S_AXI_RDATA),
    .S_AXI_RRESP            (S_AXI_RRESP),
    .S_AXI_RVALID           (S_AXI_RVALID),
    .S_AXI_WREADY           (S_AXI_WREADY),
    .S_AXI_BRESP            (S_AXI_BRESP),
    .S_AXI_BVALID           (S_AXI_BVALID),
    .S_AXI_AWREADY          (S_AXI_AWREADY),

   
   // Register ports
   .id_reg          (id_reg),
   .version_reg          (version_reg),
   .ip2cpu_flip_reg          (ip2cpu_flip_reg),
   .cpu2ip_flip_reg          (cpu2ip_flip_reg),
   .counterin_reg          (counterin_reg),
   .counterin_reg_clear    (counterin_reg_clear),
   .counterout_reg          (counterout_reg),
   .counterout_reg_clear    (counterout_reg_clear),
   .ip2cpu_debug_reg          (ip2cpu_debug_reg),
   .cpu2ip_debug_reg          (cpu2ip_debug_reg),
   // Global Registers - user can select if to use
   .cpu_resetn_soft(),//software reset, after cpu module
   .resetn_soft    (),//software reset to cpu module (from central reset management)
   .resetn_sync    (resetn_sync)//synchronized reset, use for better timing
);
////registers logic, current logic is just a placeholder for initial compil, required to be changed by the user
always @(posedge axi_aclk)
	if (~resetn_sync) begin
		id_reg <= #1  `REG_ID_DEFAULT;
	    id_reg[31:16] <= #1    IF_NUMBER;
		version_reg <= #1    `REG_VERSION_DEFAULT;
		ip2cpu_flip_reg <= #1    `REG_FLIP_DEFAULT;
		counterin_reg <= #1    `REG_COUNTERIN_DEFAULT;
		counterout_reg <= #1    `REG_COUNTEROUT_DEFAULT;
		ip2cpu_debug_reg <= #1    `REG_DEBUG_DEFAULT;
	end
	else begin
		id_reg <= #1    `REG_ID_DEFAULT;
		version_reg <= #1    `REG_VERSION_DEFAULT;
		ip2cpu_flip_reg <= #1    ~cpu2ip_flip_reg;
		counterin_reg[`REG_COUNTERIN_WIDTH -2: 0] <= #1  counterin_reg_clear ? 'h0  : counterin_reg[`REG_COUNTERIN_WIDTH-2:0] + (s_axis_tlast && s_axis_tvalid)   ;
        counterin_reg[`REG_COUNTERIN_WIDTH-1] <= #1 counterin_reg_clear ? 1'h0 : counterin_reg_clear ? 'h0  : counterin_reg[`REG_COUNTERIN_WIDTH-2:0] + (s_axis_tlast && s_axis_tvalid)  
                                                     > {(`REG_COUNTERIN_WIDTH-1){1'b1}} ? 1'b1 : counterin_reg[`REG_COUNTERIN_WIDTH-1];
                                                               
		counterout_reg [`REG_COUNTEROUT_WIDTH-2:0]<= #1  counterout_reg_clear ? 'h0  : counterout_reg [`REG_COUNTEROUT_WIDTH-2:0] + m_axis_tvalid && m_axis_tvalid ;
                counterout_reg [`REG_COUNTEROUT_WIDTH-1]<= #1  counterout_reg_clear ? 'h0  : counterout_reg [`REG_COUNTEROUT_WIDTH-2:0] + m_axis_tvalid && m_axis_tvalid > {(`REG_COUNTEROUT_WIDTH-1){1'b1}} ?
                                                                1'b1 : counterout_reg [`REG_COUNTEROUT_WIDTH-1];
		ip2cpu_debug_reg <= #1    `REG_DEBUG_DEFAULT+cpu2ip_debug_reg;
        end



	
endmodule
