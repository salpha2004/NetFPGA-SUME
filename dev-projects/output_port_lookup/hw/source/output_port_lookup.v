/*******************************************************************************
 *
 *  NetFPGA-10G http://www.netfpga.org
 *
 *  File:
 *        nf10_nic_output_port_lookup.v
 *
 *  Library:
 *        hw/std/pcores/nf10_nic_output_port_lookup_v1_00_a
 *
 *  Module:
 *        nf10_nic_output_port_lookup
 *
 *  Author:
 *        Adam Covington
 *
 *  Description:
 *        Hardwire the hardware interfaces to CPU and vice versa
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

`include "opl_cpu_regs_defines.v"

module output_port_lookup
#(
    //Master AXI Stream Data Width
    parameter C_M_AXIS_DATA_WIDTH=256,
    parameter C_S_AXIS_DATA_WIDTH=256,
    parameter C_M_AXIS_TUSER_WIDTH=128,
    parameter C_S_AXIS_TUSER_WIDTH=128,
    parameter SRC_PORT_POS=16,
    parameter DST_PORT_POS=24,

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
    //                                             },
    parameter [0:8*C_NUM_ADDRESS_RANGES-1] C_ARD_NUM_CE_ARRAY  = 
                                                {
                                                 C_NUM_ADDRESS_RANGES{8'd1}
                                                 },
    parameter     C_FAMILY            = "virtex7", 
    parameter C_BASEADDR            = 32'h00000000,
    parameter C_HIGHADDR            = 32'h0000FFFF


)
(
    // Global Ports
    input axi_aclk,
    input axi_resetn,

    // Master Stream Ports (interface to data path)
    output [C_M_AXIS_DATA_WIDTH - 1:0] m_axis_tdata,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_tstrb,
    output reg [C_M_AXIS_TUSER_WIDTH-1:0] m_axis_tuser,
    output m_axis_tvalid,
    input  m_axis_tready,
    output m_axis_tlast,

    // Slave Stream Ports (interface to RX queues)
    input [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_tstrb,
    input [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_tuser,
    input  s_axis_tvalid,
    output s_axis_tready,
    input  s_axis_tlast,

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
    output                                    S_AXI_AWREADY
);

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
   localparam MODULE_HEADER = 0;
   localparam IN_PACKET     = 1;

   //------------- Wires ------------------
   wire  [C_M_AXIS_TUSER_WIDTH-1:0] tuser_fifo;
   reg 			  state, state_next;

   // ------------ Modules ----------------

   fallthrough_small_fifo
        #( .WIDTH(C_M_AXIS_DATA_WIDTH+C_M_AXIS_TUSER_WIDTH+C_M_AXIS_DATA_WIDTH/8+1),
           .MAX_DEPTH_BITS(2))
      input_fifo
        (// Outputs
         .dout                           ({m_axis_tlast, tuser_fifo, m_axis_tstrb, m_axis_tdata}),
         .full                           (),
         .nearly_full                    (in_fifo_nearly_full),
         .prog_full                      (),
         .empty                          (in_fifo_empty),
         // Inputs
         .din                            ({s_axis_tlast, s_axis_tuser, s_axis_tstrb, s_axis_tdata}),
         .wr_en                          (s_axis_tvalid & ~in_fifo_nearly_full),
         .rd_en                          (in_fifo_rd_en),
         .reset                          (~axi_resetn),
         .clk                            (axi_aclk));

   // ------------- Logic ----------------

   assign s_axis_tready = !in_fifo_nearly_full;

   // packet is from the cpu if it is on an odd numbered port
   assign pkt_is_from_cpu = m_axis_tuser[SRC_PORT_POS+1] ||
			    m_axis_tuser[SRC_PORT_POS+3] ||
			    m_axis_tuser[SRC_PORT_POS+5] ||
			    m_axis_tuser[SRC_PORT_POS+7];

   // modify the dst port in tuser
   always @(*) begin
      m_axis_tuser = tuser_fifo;
      state_next      = state;

      case(state)
	MODULE_HEADER: begin
	   if (m_axis_tvalid) begin
	      if(~|m_axis_tuser[SRC_PORT_POS+:8]) begin
	      	m_axis_tuser[DST_PORT_POS+7:DST_PORT_POS] = 8'b1;
	      end // Default: Send to MAC 0
	      else if(pkt_is_from_cpu) begin
		 m_axis_tuser[DST_PORT_POS+7:DST_PORT_POS] = {1'b0,
			tuser_fifo[SRC_PORT_POS+7:SRC_PORT_POS+1]};
	      end
	      else begin
		 m_axis_tuser[DST_PORT_POS+7:DST_PORT_POS] = {
			tuser_fifo[SRC_PORT_POS+6:SRC_PORT_POS], 1'b0};
	      end
	      if(m_axis_tready) begin
			    state_next = IN_PACKET;
			end
	   end
	end // case: MODULE_HEADER

	IN_PACKET: begin
	   if(m_axis_tlast & m_axis_tvalid & m_axis_tready) begin
	      state_next = MODULE_HEADER;
	   end
	end
      endcase // case (state)
   end // always @ (*)

   always @(posedge axi_aclk) begin
      if(~axi_resetn) begin
	 state <= MODULE_HEADER;
      end
      else begin
	 state <= state_next;
      end
   end

   // Handle output
   assign in_fifo_rd_en = m_axis_tready && !in_fifo_empty;
   assign m_axis_tvalid = !in_fifo_empty;


//Registers section
 opl_cpu_regs 
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
 ) opl_cpu_regs_inst
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
		counterin_reg[`REG_COUNTERIN_WIDTH -2: 0] <= #1  counterin_reg_clear ? 'h0  : counterin_reg[`REG_COUNTERIN_WIDTH-2:0] + (s_axis_tlast && s_axis_tvalid) ;
                counterin_reg[`REG_COUNTERIN_WIDTH-1] <= #1 counterin_reg_clear ? 1'h0 : counterin_reg_clear ? 'h0  : counterin_reg[`REG_COUNTERIN_WIDTH-2:0] + (s_axis_tlast && s_axis_tvalid) 
                                                     > {(`REG_COUNTERIN_WIDTH-1){1'b1}} ? 1'b1 : counterin_reg[`REG_COUNTERIN_WIDTH-1];
                                                               
		counterout_reg [`REG_COUNTEROUT_WIDTH-2:0]<= #1  counterout_reg_clear ? 'h0  : counterout_reg [`REG_COUNTEROUT_WIDTH-2:0] + (m_axis_tvalid && m_axis_tvalid) ;
                counterout_reg [`REG_COUNTEROUT_WIDTH-1]<= #1  counterout_reg_clear ? 'h0  : counterout_reg [`REG_COUNTEROUT_WIDTH-2:0] + + (m_axis_tvalid && m_axis_tvalid)  > {(`REG_COUNTEROUT_WIDTH-1){1'b1}} ?
                                                                1'b1 : counterout_reg [`REG_COUNTEROUT_WIDTH-1];
		ip2cpu_debug_reg <= #1    `REG_DEBUG_DEFAULT+cpu2ip_debug_reg;
        end





endmodule // output_port_lookup
