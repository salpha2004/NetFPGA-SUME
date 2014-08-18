/*******************************************************************************
 *
 *  NetFPGA-10G http://www.netfpga.org
 *
 *  File:
 *        nf10_bram_output_queues.v
 *
 *  Library:
 *        hw/std/pcores/nf10_bram_output_queues_v1_10_a
 *
 *  Module:
 *        nf10_bram_output_queues
 *
 *  Author:
 *        James Hongyi Zeng
 *
 *  Description:
 *        BRAM Output queues
 *        Outputs have a parameterizable width
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

`include "boq_cpu_regs_defines.v"

module output_queues
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
    // Part 1: System side signals
    // Global Ports
    input axi_aclk,
    input axi_resetn,

    // Slave Stream Ports (interface to data path)
    input [C_S_AXIS_DATA_WIDTH - 1:0] s_axis_tdata,
    input [((C_S_AXIS_DATA_WIDTH / 8)) - 1:0] s_axis_tstrb,
    input [C_S_AXIS_TUSER_WIDTH-1:0] s_axis_tuser,
    input s_axis_tvalid,
    output reg s_axis_tready,
    input s_axis_tlast,

    // Master Stream Ports (interface to TX queues)
    output [C_M_AXIS_DATA_WIDTH - 1:0] m_axis_tdata_0,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_tstrb_0,
    output [C_M_AXIS_TUSER_WIDTH-1:0] m_axis_tuser_0,
    output  m_axis_tvalid_0,
    input m_axis_tready_0,
    output  m_axis_tlast_0,

    output [C_M_AXIS_DATA_WIDTH - 1:0] m_axis_tdata_1,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_tstrb_1,
    output [C_M_AXIS_TUSER_WIDTH-1:0] m_axis_tuser_1,
    output  m_axis_tvalid_1,
    input m_axis_tready_1,
    output  m_axis_tlast_1,

    output [C_M_AXIS_DATA_WIDTH - 1:0] m_axis_tdata_2,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_tstrb_2,
    output [C_M_AXIS_TUSER_WIDTH-1:0] m_axis_tuser_2,
    output  m_axis_tvalid_2,
    input m_axis_tready_2,
    output  m_axis_tlast_2,

    output [C_M_AXIS_DATA_WIDTH - 1:0] m_axis_tdata_3,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_tstrb_3,
    output [C_M_AXIS_TUSER_WIDTH-1:0] m_axis_tuser_3,
    output  m_axis_tvalid_3,
    input m_axis_tready_3,
    output  m_axis_tlast_3,

    output [C_M_AXIS_DATA_WIDTH - 1:0] m_axis_tdata_4,
    output [((C_M_AXIS_DATA_WIDTH / 8)) - 1:0] m_axis_tstrb_4,
    output [C_M_AXIS_TUSER_WIDTH-1:0] m_axis_tuser_4,
    output  m_axis_tvalid_4,
    input m_axis_tready_4,
    output  m_axis_tlast_4,

    // stats
    output reg  [C_S_AXI_DATA_WIDTH-1:0] bytes_stored,
    output reg  [NUM_QUEUES-1:0]         pkt_stored,

    output [C_S_AXI_DATA_WIDTH-1:0]  bytes_removed_0,
    output [C_S_AXI_DATA_WIDTH-1:0]  bytes_removed_1,
    output [C_S_AXI_DATA_WIDTH-1:0]  bytes_removed_2,
    output [C_S_AXI_DATA_WIDTH-1:0]  bytes_removed_3,
    output [C_S_AXI_DATA_WIDTH-1:0]  bytes_removed_4,
    output                           pkt_removed_0,
    output                           pkt_removed_1,
    output                           pkt_removed_2,
    output                           pkt_removed_3,
    output                           pkt_removed_4,

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

    output reg [C_S_AXI_DATA_WIDTH-1:0]  bytes_dropped,
    output reg [NUM_QUEUES-1:0]          pkt_dropped
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

   localparam NUM_QUEUES_WIDTH = log2(NUM_QUEUES);

   localparam BUFFER_SIZE         = 4096; // Buffer size 4096B
   localparam BUFFER_SIZE_WIDTH   = log2(BUFFER_SIZE/(C_M_AXIS_DATA_WIDTH/8));

   localparam MAX_PACKET_SIZE = 1600;
   localparam BUFFER_THRESHOLD = (BUFFER_SIZE-MAX_PACKET_SIZE)/(C_M_AXIS_DATA_WIDTH/8);

   localparam NUM_STATES = 3;
   localparam IDLE = 0;
   localparam WR_PKT = 1;
   localparam DROP = 2;

   localparam NUM_METADATA_STATES = 2;
   localparam WAIT_HEADER = 0;
   localparam WAIT_EOP = 1;


   // ------------- Regs/ wires -----------

   reg [NUM_QUEUES-1:0]                nearly_full;
   wire [NUM_QUEUES-1:0]               nearly_full_fifo;
   wire [NUM_QUEUES-1:0]               empty;

   reg [NUM_QUEUES-1:0]                metadata_nearly_full;
   wire [NUM_QUEUES-1:0]               metadata_nearly_full_fifo;
   wire [NUM_QUEUES-1:0]               metadata_empty;

   wire [C_M_AXIS_TUSER_WIDTH-1:0]             fifo_out_tuser[NUM_QUEUES-1:0];
   wire [C_M_AXIS_DATA_WIDTH-1:0]        fifo_out_tdata[NUM_QUEUES-1:0];
   wire [((C_M_AXIS_DATA_WIDTH/8))-1:0]  fifo_out_tstrb[NUM_QUEUES-1:0];
   wire [NUM_QUEUES-1:0] 	           fifo_out_tlast;

   wire [NUM_QUEUES-1:0]               rd_en;
   reg [NUM_QUEUES-1:0]                wr_en;

   reg [NUM_QUEUES-1:0]                metadata_rd_en;
   reg [NUM_QUEUES-1:0]                metadata_wr_en;

   reg [NUM_QUEUES-1:0]          cur_queue;
   reg [NUM_QUEUES-1:0]          cur_queue_next;
   wire [NUM_QUEUES-1:0]         oq;

   reg [NUM_STATES-1:0]                state;
   reg [NUM_STATES-1:0]                state_next;

   reg [NUM_METADATA_STATES-1:0]       metadata_state[NUM_QUEUES-1:0];
   reg [NUM_METADATA_STATES-1:0]       metadata_state_next[NUM_QUEUES-1:0];

   reg								   first_word, first_word_next;

   reg [NUM_QUEUES-1:0] pkt_stored_next;
   reg [C_S_AXI_DATA_WIDTH-1:0] bytes_stored_next;
   reg [NUM_QUEUES-1:0] pkt_dropped_next;
   reg [C_S_AXI_DATA_WIDTH-1:0] bytes_dropped_next;
   reg [NUM_QUEUES-1:0] pkt_removed;
   reg [C_S_AXI_DATA_WIDTH-1:0] bytes_removed[NUM_QUEUES-1:0];

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
   for(i=0; i<NUM_QUEUES; i=i+1) begin: output_queues
      fallthrough_small_fifo
        #( .WIDTH(C_M_AXIS_DATA_WIDTH+C_M_AXIS_DATA_WIDTH/8+1),
           .MAX_DEPTH_BITS(BUFFER_SIZE_WIDTH),
           .PROG_FULL_THRESHOLD(BUFFER_THRESHOLD))
      output_fifo
        (// Outputs
         .dout                           ({fifo_out_tlast[i], fifo_out_tstrb[i], fifo_out_tdata[i]}),
         .full                           (),
         .nearly_full                    (),
	 	 .prog_full                      (nearly_full_fifo[i]),
         .empty                          (empty[i]),
         // Inputs
         .din                            ({s_axis_tlast, s_axis_tstrb, s_axis_tdata}),
         .wr_en                          (wr_en[i]),
         .rd_en                          (rd_en[i]),
         .reset                          (~axi_resetn),
         .clk                            (axi_aclk));

      fallthrough_small_fifo
        #( .WIDTH(C_M_AXIS_TUSER_WIDTH),
           .MAX_DEPTH_BITS(2))
      metadata_fifo
        (// Outputs
         .dout                           (fifo_out_tuser[i]),
         .full                           (),
         .nearly_full                    (metadata_nearly_full_fifo[i]),
	 	 .prog_full                      (),
         .empty                          (metadata_empty[i]),
         // Inputs
         .din                            (s_axis_tuser),
         .wr_en                          (metadata_wr_en[i]),
         .rd_en                          (metadata_rd_en[i]),
         .reset                          (~axi_resetn),
         .clk                            (axi_aclk));


   always @(metadata_state[i], rd_en[i], fifo_out_tlast[i]) begin
        metadata_rd_en[i] = 1'b0;
        pkt_removed[i]= 1'b0;
	bytes_removed[i]=32'b0;
	metadata_state_next[i] = metadata_state[i];
      	case(metadata_state[i])
      		WAIT_HEADER: begin
      			if(rd_en[i]) begin
      				metadata_state_next[i] = WAIT_EOP;
      				metadata_rd_en[i] = 1'b1;
				pkt_removed[i]= 1'b1;
				bytes_removed[i]=fifo_out_tuser[i][15:0];
      			end
      		end
      		WAIT_EOP: begin
      			if(rd_en[i] & fifo_out_tlast[i]) begin
      				metadata_state_next[i] = WAIT_HEADER;
      			end
      		end
        endcase
      end

      always @(posedge axi_aclk) begin
      	if(~axi_resetn) begin
         	metadata_state[i] <= WAIT_HEADER;
      	end
      	else begin
         	metadata_state[i] <= metadata_state_next[i];
      	end
      end

   end 
   endgenerate

   // Per NetFPGA-10G AXI Spec
   localparam DST_POS = 24;
   assign oq = s_axis_tuser[DST_POS] |
   			   (s_axis_tuser[DST_POS + 2] << 1) |
   			   (s_axis_tuser[DST_POS + 4] << 2) |
   			   (s_axis_tuser[DST_POS + 6] << 3) |
   			   ((s_axis_tuser[DST_POS + 1] | s_axis_tuser[DST_POS + 3] | s_axis_tuser[DST_POS + 5] | s_axis_tuser[DST_POS + 7]) << 4);

   always @(*) begin
      state_next     = state;
      cur_queue_next = cur_queue;
      wr_en          = 0;
      metadata_wr_en = 0;
      s_axis_tready  = 0;
      first_word_next = first_word;
     
      bytes_stored_next = 0;
      pkt_stored_next = 0;
      pkt_dropped_next = 0;
      bytes_dropped_next = 0;

      case(state)

        /* cycle between input queues until one is not empty */
        IDLE: begin
           cur_queue_next = oq;
           if(s_axis_tvalid) begin
              if(~|((nearly_full | metadata_nearly_full) & oq)) begin // All interesting oqs are NOT _nearly_ full (able to fit in the maximum pacekt).
                  state_next = WR_PKT;
                  first_word_next = 1'b1;
		  pkt_stored_next = oq;
		  bytes_stored_next = s_axis_tuser[15:0];
              end
              else begin
              	  state_next = DROP;
	          pkt_dropped_next = oq;
		  bytes_dropped_next = s_axis_tuser[15:0];
              end
           end
        end

        /* wait until eop */
        WR_PKT: begin
           s_axis_tready = 1;
           if(s_axis_tvalid) begin
           		first_word_next = 1'b0;
				wr_en = cur_queue;
				if(first_word) begin
					metadata_wr_en = cur_queue;
				end
				if(s_axis_tlast) begin
					state_next = IDLE;
				end
           end
        end // case: WR_PKT

        DROP: begin
           s_axis_tready = 1;
           if(s_axis_tvalid & s_axis_tlast) begin
           	  state_next = IDLE;
           end
        end

      endcase // case(state)
   end // always @ (*)



   always @(posedge axi_aclk) begin
      if(~axi_resetn) begin
         state <= IDLE;
         cur_queue <= 0;
         first_word <= 0;

 	 bytes_stored <= 0;
         pkt_stored <= 0;
         pkt_dropped <=0;
         bytes_dropped <=0;
      end
      else begin
         state <= state_next;
         cur_queue <= cur_queue_next;
         first_word <= first_word_next;

	 bytes_stored <= bytes_stored_next;
         pkt_stored <= pkt_stored_next;
         pkt_dropped<= pkt_dropped_next;
         bytes_dropped<= bytes_dropped_next;
      end

      nearly_full <= nearly_full_fifo;
      metadata_nearly_full <= metadata_nearly_full_fifo;
   end


   assign m_axis_tdata_0	 = fifo_out_tdata[0];
   assign m_axis_tstrb_0	 = fifo_out_tstrb[0];
   assign m_axis_tuser_0	 = fifo_out_tuser[0];
   assign m_axis_tlast_0	 = fifo_out_tlast[0];
   assign m_axis_tvalid_0	 = ~empty[0];
   assign rd_en[0]		 = m_axis_tready_0 & ~empty[0];
   assign pkt_removed_0		 = pkt_removed[0];
   assign bytes_removed_0          = bytes_removed[0];

   assign m_axis_tdata_1	 = fifo_out_tdata[1];
   assign m_axis_tstrb_1	 = fifo_out_tstrb[1];
   assign m_axis_tuser_1	 = fifo_out_tuser[1];
   assign m_axis_tlast_1	 = fifo_out_tlast[1];
   assign m_axis_tvalid_1	 = ~empty[1];
   assign rd_en[1]		 = m_axis_tready_1 & ~empty[1];
   assign pkt_removed_1          = pkt_removed[1];
   assign bytes_removed_1          = bytes_removed[1];

   assign m_axis_tdata_2	 = fifo_out_tdata[2];
   assign m_axis_tstrb_2	 = fifo_out_tstrb[2];
   assign m_axis_tuser_2	 = fifo_out_tuser[2];
   assign m_axis_tlast_2	 = fifo_out_tlast[2];
   assign m_axis_tvalid_2	 = ~empty[2];
   assign rd_en[2]		 = m_axis_tready_2 & ~empty[2];
   assign pkt_removed_2          = pkt_removed[2];
   assign bytes_removed_2          = bytes_removed[2];

   assign m_axis_tdata_3	 = fifo_out_tdata[3];
   assign m_axis_tstrb_3	 = fifo_out_tstrb[3];
   assign m_axis_tuser_3	 = fifo_out_tuser[3];
   assign m_axis_tlast_3	 = fifo_out_tlast[3];
   assign m_axis_tvalid_3	 = ~empty[3];
   assign rd_en[3]		 = m_axis_tready_3 & ~empty[3];
   assign pkt_removed_3          = pkt_removed[3];
   assign bytes_removed_3          = bytes_removed[3];

   assign m_axis_tdata_4	 = fifo_out_tdata[4];
   assign m_axis_tstrb_4	 = fifo_out_tstrb[4];
   assign m_axis_tuser_4	 = fifo_out_tuser[4];
   assign m_axis_tlast_4	 = fifo_out_tlast[4];
   assign m_axis_tvalid_4	 = ~empty[4];
   assign rd_en[4]		 = m_axis_tready_4 & ~empty[4];
   assign pkt_removed_4          = pkt_removed[4];
   assign bytes_removed_4          = bytes_removed[4];

//Registers section
 boq_cpu_regs 
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
 ) boq_cpu_regs_inst
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
                                                               
		counterout_reg [`REG_COUNTEROUT_WIDTH-2:0]<= #1  counterout_reg_clear ? 'h0  : counterout_reg [`REG_COUNTEROUT_WIDTH-2:0] + (m_axis_tvalid_0 && m_axis_tvalid_0) + (m_axis_tvalid_1 && m_axis_tvalid_1)+ (m_axis_tvalid_2 && m_axis_tvalid_2)+ (m_axis_tvalid_3 && m_axis_tvalid_3)+ (m_axis_tvalid_4 && m_axis_tvalid_4) ;
                counterout_reg [`REG_COUNTEROUT_WIDTH-1]<= #1  counterout_reg_clear ? 'h0  : counterout_reg [`REG_COUNTEROUT_WIDTH-2:0] + + (m_axis_tvalid_0 && m_axis_tvalid_0) + (m_axis_tvalid_1 && m_axis_tvalid_1)+ (m_axis_tvalid_2 && m_axis_tvalid_2)+ (m_axis_tvalid_3 && m_axis_tvalid_3)+ (m_axis_tvalid_4 && m_axis_tvalid_4)  > {(`REG_COUNTEROUT_WIDTH-1){1'b1}} ?
                                                                1'b1 : counterout_reg [`REG_COUNTEROUT_WIDTH-1];
		ip2cpu_debug_reg <= #1    `REG_DEBUG_DEFAULT+cpu2ip_debug_reg;
        end





endmodule
