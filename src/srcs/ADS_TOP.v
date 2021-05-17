// -----------------------------------------------------------------------------
// Copyright (c) 2014-2021 All rights reserved
// -----------------------------------------------------------------------------
// Author : wings
// File   : ADS_TOP.v
// Create : 2021-04-08 13:57:43
// Revise : 2021-04-25 14:37:53
// Editor : sublime text3, tab size (4)
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps


module ADS_TOP #(
	// AD series number
	parameter	AD_SERIES_NUMBER		= 4,
	// AXI parameters
    parameter C_AXI_ID_WIDTH           	= 4, 		// The AXI id width used for read and write // This is an integer between 1-16
    parameter C_AXI_ADDR_WIDTH         	= 32, 		// This is AXI address width for all 		// SI and MI slots
    parameter C_AXI_DATA_WIDTH 			= 64, 		// Width of the AXI write and read data
    parameter C_AXI_NBURST_SUPPORT     	= 1'b0, 	// Support for narrow burst transfers 		// 1-supported, 0-not supported 
    parameter C_AXI_BURST_TYPE  		= 2'b00, 	// 00:FIXED 01:INCR 10:WRAP
    parameter WATCH_DOG_WIDTH  			= 12,
    // Channel parameters
    parameter C_ADDR_AD2ETH				= 32'h1000_0000,
    parameter C_ADDR_SUMOFFSET			= 32'h0000_1000
)(
	input	sys_clk,    	// Clock	200m
	input	sys_rst,  		// synchronous reset active high
	input	trig_convst,

	//	ads interface
	output			ad1_reset,
	output			ad1_convst,
	input			ad1_busy,
	output			ad1_fs_n,
	output			ad1_sclk,	//	40m
	output			ad1_sdi,
	input	[3:0]	ad1_sdo,	//	bit[0]:a	bit[1]:b	bit[2]:c	bit[3]:d

	output			ad0_reset,
	output			ad0_convst,
	input			ad0_busy,
	output			ad0_fs_n,
	output			ad0_sclk,	//	40m
	output			ad0_sdi,
	input	[3:0]	ad0_sdo,		//	bit[0]:a	bit[1]:b	bit[2]:c	bit[3]:d

// AXI write address channel signals
   	input                               maxi_wready, // Indicates slave is ready to accept a 
   	output [C_AXI_ID_WIDTH-1:0]         maxi_wid,    // Write ID
   	output [C_AXI_ADDR_WIDTH-1:0]       maxi_waddr,  // Write address
   	output [7:0]                        maxi_wlen,   // Write Burst Length
   	output [2:0]                        maxi_wsize,  // Write Burst size
   	output [1:0]                        maxi_wburst, // Write Burst type
   	output [1:0]                        maxi_wlock,  // Write lock type
   	output [3:0]                        maxi_wcache, // Write Cache type
   	output [2:0]                        maxi_wprot,  // Write Protection type
   	output                              maxi_wvalid, // Write address valid
  
// AXI write data channel signals
   	input                               maxi_wd_wready,  // Write data ready
   	output [C_AXI_DATA_WIDTH-1:0]       maxi_wd_wdata,    // Write data
   	output [C_AXI_DATA_WIDTH/8-1:0]     maxi_wd_wstrb,    // Write strobes
   	output                              maxi_wd_wlast,    // Last write transaction   
   	output                              maxi_wd_wvalid,   // Write valid
  
// AXI write response channel signals
   	input  [C_AXI_ID_WIDTH-1:0]         maxi_wb_bid,     // Response ID
   	input  [1:0]                        maxi_wb_bresp,   // Write response
   	input                               maxi_wb_bvalid,  // Write reponse valid
   	output                              maxi_wb_bready,  // Response ready
  
// AXI read address channel signals
   	input                               maxi_rready,     // Read address ready
   	output [C_AXI_ID_WIDTH-1:0]         maxi_rid,        // Read ID
   	output [C_AXI_ADDR_WIDTH-1:0]       maxi_raddr,      // Read address
   	output [7:0]                        maxi_rlen,       // Read Burst Length
   	output [2:0]                        maxi_rsize,      // Read Burst size
   	output [1:0]                        maxi_rburst,     // Read Burst type
   	output [1:0]                        maxi_rlock,      // Read lock type
   	output [3:0]                        maxi_rcache,     // Read Cache type
   	output [2:0]                        maxi_rprot,      // Read Protection type
   	output                              maxi_rvalid,     // Read address valid
  
// AXI read data channel signals   
   	input  [C_AXI_ID_WIDTH-1:0]         maxi_rd_bid,     // Response ID
   	input  [1:0]                        maxi_rd_rresp,   // Read response
   	input                               maxi_rd_rvalid,  // Read reponse valid
   	input  [C_AXI_DATA_WIDTH-1:0]       maxi_rd_rdata,   // Read data
   	input                               maxi_rd_rlast,   // Read last
   	output                              maxi_rd_rready   // Read Response ready		
);

	wire			ad1_valid,ad0_valid;
	wire	[63:0]	ad1_data,ad0_data;
	wire			w_fifo_valid,r_fifo_valid;
	wire			w_fifo_full,r_fifo_empty;
	wire	[15:0]	w_fifo_data;
	wire	[63:0]	r_fifo_data;
	wire 			fifo_reset;

	ADS_CTRL #(
			.AD_SERIES_NUMBER(AD_SERIES_NUMBER)
		) inst_ADS0_CTRL (
			.sys_clk     (sys_clk),
			.sys_rst     (sys_rst),
			.trig_convst (trig_convst),
			.reset       (ad0_reset),
			.convst      (ad0_convst),
			.busy        (ad0_busy),
			.fs_n        (ad0_fs_n),
			.sclk        (ad0_sclk),
			.sdi         (ad0_sdi),
			.sdo         (ad0_sdo),
			.ad_valid    (ad0_valid),
			.ad_data     (ad0_data)
		);



	ADS_CTRL #(
			.AD_SERIES_NUMBER(AD_SERIES_NUMBER)
		) inst_ADS1_CTRL (
			.sys_clk     (sys_clk),
			.sys_rst     (sys_rst),
			.trig_convst (trig_convst),
			.reset       (ad1_reset),
			.convst      (ad1_convst),
			.busy        (ad1_busy),
			.fs_n        (ad1_fs_n),
			.sclk        (ad1_sclk),
			.sdi         (ad1_sdi),
			.sdo         (ad1_sdo),
			.ad_valid    (ad1_valid),
			.ad_data     (ad1_data)
		);



	ADS_SUM #(
			.AD_SERIES_NUMBER(AD_SERIES_NUMBER),
			.C_AXI_ID_WIDTH(C_AXI_ID_WIDTH),
			.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
			.C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
			.C_AXI_NBURST_SUPPORT(C_AXI_NBURST_SUPPORT),
			.C_AXI_BURST_TYPE(C_AXI_BURST_TYPE),
			.WATCH_DOG_WIDTH(WATCH_DOG_WIDTH),
			.C_ADDR_AD2ETH(C_ADDR_AD2ETH),
			.C_ADDR_SUMOFFSET(C_ADDR_SUMOFFSET)
		) inst_ADS_SUM (
			.sys_clk        (sys_clk),
			.sys_rst        (sys_rst),
			.maxi_wready    (maxi_wready),
			.maxi_wid       (maxi_wid),
			.maxi_waddr     (maxi_waddr),
			.maxi_wlen      (maxi_wlen),
			.maxi_wsize     (maxi_wsize),
			.maxi_wburst    (maxi_wburst),
			.maxi_wlock     (maxi_wlock),
			.maxi_wcache    (maxi_wcache),
			.maxi_wprot     (maxi_wprot),
			.maxi_wvalid    (maxi_wvalid),
			.maxi_wd_wready (maxi_wd_wready),
			.maxi_wd_wdata  (maxi_wd_wdata),
			.maxi_wd_wstrb  (maxi_wd_wstrb),
			.maxi_wd_wlast  (maxi_wd_wlast),
			.maxi_wd_wvalid (maxi_wd_wvalid),
			.maxi_wb_bid    (maxi_wb_bid),
			.maxi_wb_bresp  (maxi_wb_bresp),
			.maxi_wb_bvalid (maxi_wb_bvalid),
			.maxi_wb_bready (maxi_wb_bready),
			.maxi_rready    (maxi_rready),
			.maxi_rid       (maxi_rid),
			.maxi_raddr     (maxi_raddr),
			.maxi_rlen      (maxi_rlen),
			.maxi_rsize     (maxi_rsize),
			.maxi_rburst    (maxi_rburst),
			.maxi_rlock     (maxi_rlock),
			.maxi_rcache    (maxi_rcache),
			.maxi_rprot     (maxi_rprot),
			.maxi_rvalid    (maxi_rvalid),
			.maxi_rd_bid    (maxi_rd_bid),
			.maxi_rd_rresp  (maxi_rd_rresp),
			.maxi_rd_rvalid (maxi_rd_rvalid),
			.maxi_rd_rdata  (maxi_rd_rdata),
			.maxi_rd_rlast  (maxi_rd_rlast),
			.maxi_rd_rready (maxi_rd_rready),
			.ad1_valid      (ad1_valid),
			.ad1_data       (ad1_data),
			.ad0_valid      (ad0_valid),
			.ad0_data       (ad0_data),
			.w_fifo_valid   (w_fifo_valid),
			.w_fifo_data    (w_fifo_data),
			.w_fifo_full    (w_fifo_full),
			.r_fifo_valid   (r_fifo_valid),
			.r_fifo_data    (r_fifo_data),
			.r_fifo_empty   (r_fifo_empty),
			.fifo_reset		(fifo_reset)
		);


ad_fifo ad_fifo (
  .clk		(sys_clk),      // input wire clk
  .srst		(fifo_reset),    // input wire srst
  .din		(w_fifo_data),      // input wire [15 : 0] din
  .wr_en	(w_fifo_valid),  // input wire wr_en
  .rd_en	(r_fifo_valid),  // input wire rd_en
  .dout		(r_fifo_data),    // output wire [63 : 0] dout
  .full		(),    // output wire full
  .empty	(),  // output wire empty
  .almost_full(w_fifo_full),    // output wire almost_full
  .almost_empty(r_fifo_empty)  // output wire almost_empty  
);
endmodule