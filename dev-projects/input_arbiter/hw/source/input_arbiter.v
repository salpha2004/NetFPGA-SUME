/*******************************************************************************
 *
 *  NetFPGA-10G http://www.netfpga.org
 *
 *  File:
 *        input_arbiter.v
 *
 *  Library:
 *        hw/std/pcores/nf10_input_arbiter_v1_10_a
 *
 *  Module:
 *        nf10_input_arbiter
 *
 *  Author:
 *        Adam Covington
 *
 *  Description:
 *        Round Robin arbiter (N inputs to 1 output)
 *        Inputs have a parameterizable width
 *
 *  Copyright notice:
 *        Copyright (C) 2010, 2011 The Board of Trustees of The Leland Stanford
 *                                 Junior University
 *
 *  Licence:
 *        This file is part of the NetFPGA 10G development base package.
 *
 *        This file is free code: you can redistribute it and/or modify it under
 *        the terms of the GNU Lesser General Public License version 2.1 as
 *        published by the Free Software Foundation.
 *
 *        This package is distributed in the hope that it will be useful, but
 *        WITHOUT ANY WARRANTY; without even the implied warranty of
 *        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *        Lesser General Public License for more details.
 *
 *        You should have received a copy of the GNU Lesser General Public
 *        License along with the NetFPGA source package.  If not, see
 *        http://www.gnu.org/licenses/.
 *
 */
`include "arbiter_cpu_regs_defines.v"

module input_arbiter
#(
    // Master AXI Stream Data Width
    parameter C_M_AXIS_DATA_WIDTH=256,
    parameter C_S_AXIS_DATA_WIDTH=256,
    parameter C_M_AXIS_TUSER_WIDTH=128,
    parameter C_S_AXIS_TUSER_WIDTH=128,
    parameter NUM_QUEUES=5,
    
    // AXI Registers Data Width
    parameter C_S_AXI_DATA_WIDTH    = 32,          
    parameter C_S_AXI_ADDR_WIDTH    = 32,          
    parameter C_USE_WSTRB           = 0,	   
    parameter C_DPHASE_TIMEOUT      = 0,               
    parameter C_NUM_ADDRESS_RANGES = 1,
    parameter  C_TOTAL_NUM_CE       = 1,
    parameter  C_S_AXI_MIN_SIZE    = 32'h0000_FFFF,
    //parameter [0:32*2*C_NUM_ADDRESS_RANGES-1]   C_ARD_ADDR_RANGE_ARRAY  = 
    //                                             {2*C_NUM_ADDRESS_RANGES
    //                                              {32'h00000000}
//                                                 },
    parameter [0:8*C_NUM_ADDRESS_RANGES-1] C_ARD_NUM_CE_ARRAY  = 
                                                {
                                                 C_NUM_ADDRESS_RANGES{8'd1}
                                                 },
    parameter     C_FAMILY            = "virtex7", 
    parameter C_BASEADDR            = 32'h00000000,
    parameter C_HIGHADDR            = 32'h0000FFFF

)
(
    // Part 1: System side signals
    // Global Ports
    input axi_aclk,
    input axi_resetn,

    // Master Stream Ports (interface to data path)
    output [C_M_AXIS_DATA_WIDTH - 1:0] m_axis_tdata,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_tstrb,
    output [C_M_AXIS_TUSER_WIDTH-1:0] m_axis_tuser,
    output m_axis_tvalid,
    input  m_axis_tready,
    output m_axis_tlast,

    // Slave Stream Ports (interface to RX queues)
    input [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_tdata_0,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_tstrb_0,
    input [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_tuser_0,
    input  s_axis_tvalid_0,
    output s_axis_tready_0,
    input  s_axis_tlast_0,

    input [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_tdata_1,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_tstrb_1,
    input [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_tuser_1,
    input  s_axis_tvalid_1,
    output s_axis_tready_1,
    input  s_axis_tlast_1,

    input [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_tdata_2,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_tstrb_2,
    input [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_tuser_2,
    input  s_axis_tvalid_2,
    output s_axis_tready_2,
    input  s_axis_tlast_2,

    input [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_tdata_3,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_tstrb_3,
    input [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_tuser_3,
    input  s_axis_tvalid_3,
    output s_axis_tready_3,
    input  s_axis_tlast_3,

    input [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_tdata_4,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_tstrb_4,
    input [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_tuser_4,
    input  s_axis_tvalid_4,
    output s_axis_tready_4,
    input  s_axis_tlast_4,
    
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
    

   // stats
    output reg pkt_fwd

);

   function integer log2;
      input integer number;
      begin
         log2=0;
         while(2**log2<number) begin
            log2=log2+1;
         end
      end
   endfunction // log2

   // ------------ Internal Params --------

   localparam  NUM_QUEUES_WIDTH = log2(NUM_QUEUES);
   

   parameter NUM_STATES = 1;
   parameter IDLE = 0;
   parameter WR_PKT = 1;

   localparam MAX_PKT_SIZE = 2000; // In bytes
   localparam IN_FIFO_DEPTH_BIT = log2(MAX_PKT_SIZE/(C_M_AXIS_DATA_WIDTH / 8));

   // ------------- Regs/ wires -----------

   wire [NUM_QUEUES-1:0]               nearly_full;
   wire [NUM_QUEUES-1:0]               empty;
   wire [C_M_AXIS_DATA_WIDTH-1:0]        in_tdata      [NUM_QUEUES-1:0];
   wire [((C_M_AXIS_DATA_WIDTH/8))-1:0]  in_tstrb      [NUM_QUEUES-1:0];
   wire [C_M_AXIS_TUSER_WIDTH-1:0]             in_tuser      [NUM_QUEUES-1:0];
   wire [NUM_QUEUES-1:0] 	       in_tvalid;
   wire [NUM_QUEUES-1:0]               in_tlast;
   wire [C_M_AXIS_TUSER_WIDTH-1:0]             fifo_out_tuser[NUM_QUEUES-1:0];
   wire [C_M_AXIS_DATA_WIDTH-1:0]        fifo_out_tdata[NUM_QUEUES-1:0];
   wire [((C_M_AXIS_DATA_WIDTH/8))-1:0]  fifo_out_tstrb[NUM_QUEUES-1:0];
   wire [NUM_QUEUES-1:0] 	       fifo_out_tlast;
   wire                                fifo_tvalid;
   wire                                fifo_tlast;
   reg [NUM_QUEUES-1:0]                rd_en;

   wire [NUM_QUEUES_WIDTH-1:0]         cur_queue_plus1;
   reg [NUM_QUEUES_WIDTH-1:0]          cur_queue;
   reg [NUM_QUEUES_WIDTH-1:0]          cur_queue_next;

   reg [NUM_STATES-1:0]                state;
   reg [NUM_STATES-1:0]                state_next;

   reg				       pkt_fwd_next;
   
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


   // ------------ Modules -------------

   generate
   genvar i;
   for(i=0; i<NUM_QUEUES; i=i+1) begin: in_arb_queues
      fallthrough_small_fifo
        #( .WIDTH(C_M_AXIS_DATA_WIDTH+C_M_AXIS_TUSER_WIDTH+C_M_AXIS_DATA_WIDTH/8+1),
           .MAX_DEPTH_BITS(IN_FIFO_DEPTH_BIT))
      in_arb_fifo
        (// Outputs
         .dout                           ({fifo_out_tlast[i], fifo_out_tuser[i], fifo_out_tstrb[i], fifo_out_tdata[i]}),
         .full                           (),
         .nearly_full                    (nearly_full[i]),
	 .prog_full                      (),
         .empty                          (empty[i]),
         // Inputs
         .din                            ({in_tlast[i], in_tuser[i], in_tstrb[i], in_tdata[i]}),
         .wr_en                          (in_tvalid[i] & ~nearly_full[i]),
         .rd_en                          (rd_en[i]),
         .reset                          (~axi_resetn),
         .clk                            (axi_aclk));
   end
   endgenerate

   // ------------- Logic ------------

   assign in_tdata[0]        = s_axis_tdata_0;
   assign in_tstrb[0]        = s_axis_tstrb_0;
   assign in_tuser[0]        = s_axis_tuser_0;
   assign in_tvalid[0]       = s_axis_tvalid_0;
   assign in_tlast[0]        = s_axis_tlast_0;
   assign s_axis_tready_0    = !nearly_full[0];

   assign in_tdata[1]        = s_axis_tdata_1;
   assign in_tstrb[1]        = s_axis_tstrb_1;
   assign in_tuser[1]        = s_axis_tuser_1;
   assign in_tvalid[1]       = s_axis_tvalid_1;
   assign in_tlast[1]        = s_axis_tlast_1;
   assign s_axis_tready_1    = !nearly_full[1];

   assign in_tdata[2]        = s_axis_tdata_2;
   assign in_tstrb[2]        = s_axis_tstrb_2;
   assign in_tuser[2]        = s_axis_tuser_2;
   assign in_tvalid[2]       = s_axis_tvalid_2;
   assign in_tlast[2]        = s_axis_tlast_2;
   assign s_axis_tready_2    = !nearly_full[2];

   assign in_tdata[3]        = s_axis_tdata_3;
   assign in_tstrb[3]        = s_axis_tstrb_3;
   assign in_tuser[3]        = s_axis_tuser_3;
   assign in_tvalid[3]       = s_axis_tvalid_3;
   assign in_tlast[3]        = s_axis_tlast_3;
   assign s_axis_tready_3    = !nearly_full[3];

   assign in_tdata[4]        = s_axis_tdata_4;
   assign in_tstrb[4]        = s_axis_tstrb_4;
   assign in_tuser[4]        = s_axis_tuser_4;
   assign in_tvalid[4]       = s_axis_tvalid_4;
   assign in_tlast[4]        = s_axis_tlast_4;
   assign s_axis_tready_4    = !nearly_full[4];

   assign cur_queue_plus1    = (cur_queue == NUM_QUEUES-1) ? 0 : cur_queue + 1;

   //assign fifo_out_tuser_sel = fifo_out_tuser[cur_queue];
   //assign fifo_out_tdata_sel = fifo_out_tdata[cur_queue];
   //assign fifo_out_tlast_sel = fifo_out_tlast[cur_queue];
   //assign fifo_out_tstrb_sel = fifo_out_tstrb[cur_queue];

   assign m_axis_tuser = fifo_out_tuser[cur_queue];
   assign m_axis_tdata = fifo_out_tdata[cur_queue];
   assign m_axis_tlast = fifo_out_tlast[cur_queue];
   assign m_axis_tstrb = fifo_out_tstrb[cur_queue];
   assign m_axis_tvalid = ~empty[cur_queue];


   always @(*) begin
      state_next      = state;
      cur_queue_next  = cur_queue;
      rd_en           = 0;
      pkt_fwd_next    = 0;

      case(state)

        /* cycle between input queues until one is not empty */
        IDLE: begin
           if(!empty[cur_queue]) begin
              if(m_axis_tready) begin
                 state_next = WR_PKT;
                 rd_en[cur_queue] = 1;
		 pkt_fwd_next = 1;
              end
           end
           else begin
              cur_queue_next = cur_queue_plus1;
           end
        end

        /* wait until eop */
        WR_PKT: begin
           /* if this is the last word then write it and get out */
           if(m_axis_tready & m_axis_tlast) begin
              state_next = IDLE;
	      rd_en[cur_queue] = 1;
              cur_queue_next = cur_queue_plus1;
           end
           /* otherwise read and write as usual */
           else if (m_axis_tready & !empty[cur_queue]) begin
              rd_en[cur_queue] = 1;
           end
        end // case: WR_PKT

      endcase // case(state)
   end // always @ (*)

   always @(posedge axi_aclk) begin
      if(~axi_resetn) begin
         state <= IDLE;
         cur_queue <= 0;
         pkt_fwd <= 0;
      end
      else begin
         state <= state_next;
         cur_queue <= cur_queue_next;
         pkt_fwd <= pkt_fwd_next;
      end
   end


//Registers section
 arbiter_cpu_regs 
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
 ) arbiter_cpu_regs_inst
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
		id_reg <= #1    `REG_ID_DEFAULT;
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
		counterin_reg[`REG_COUNTERIN_WIDTH -2: 0] <= #1  counterin_reg_clear ? 'h0  : counterin_reg[`REG_COUNTERIN_WIDTH-2:0] + (s_axis_tlast_0 && s_axis_tvalid_0) + (s_axis_tlast_1 && s_axis_tvalid_1) + (s_axis_tlast_2 && s_axis_tvalid_2) + (s_axis_tlast_3 && s_axis_tvalid_3) + (s_axis_tlast_4 && s_axis_tvalid_4)  ;
        counterin_reg[`REG_COUNTERIN_WIDTH-1] <= #1 counterin_reg_clear ? 1'h0 : counterin_reg_clear ? 'h0  : counterin_reg[`REG_COUNTERIN_WIDTH-2:0] + (s_axis_tlast_0 && s_axis_tvalid_0) +       
                                                    (s_axis_tlast_1 && s_axis_tvalid_1) + (s_axis_tlast_2 && s_axis_tvalid_2) + (s_axis_tlast_3 && s_axis_tvalid_3) + (s_axis_tlast_4 &&  s_axis_tvalid_4) 
                                                     > {(`REG_COUNTERIN_WIDTH-1){1'b1}} ? 1'b1 : counterin_reg[`REG_COUNTERIN_WIDTH-1];
                                                               
		counterout_reg [`REG_COUNTEROUT_WIDTH-2:0]<= #1  counterout_reg_clear ? 'h0  : counterout_reg [`REG_COUNTEROUT_WIDTH-2:0] + m_axis_tvalid && m_axis_tvalid ;
                counterout_reg [`REG_COUNTEROUT_WIDTH-1]<= #1  counterout_reg_clear ? 'h0  : counterout_reg [`REG_COUNTEROUT_WIDTH-2:0] + m_axis_tvalid && m_axis_tvalid > {(`REG_COUNTEROUT_WIDTH-1){1'b1}} ?
                                                                1'b1 : counterout_reg [`REG_COUNTEROUT_WIDTH-1];
		ip2cpu_debug_reg <= #1    `REG_DEBUG_DEFAULT+cpu2ip_debug_reg;
        end



endmodule
