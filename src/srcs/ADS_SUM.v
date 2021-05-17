`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/07 14:08:03
// Design Name: 
// Module Name: ADS_SUM
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


module ADS_SUM#(
	// AD series number
	parameter AD_SERIES_NUMBER			= 4,	
	// AXI parameters
    parameter C_AXI_ID_WIDTH           	= 4, 		// The AXI id width used for read and write // This is an integer between 1-16
    parameter C_AXI_ADDR_WIDTH         	= 32, 		// This is AXI address width for all 		// SI and MI slots
    parameter C_AXI_DATA_WIDTH 			= 64, 		// Width of the AXI write and read data
    parameter C_AXI_NBURST_SUPPORT     	= 1'b0, 	// Support for narrow burst transfers 		// 1-supported, 0-not supported 
    parameter C_AXI_BURST_TYPE  		= 2'b00, 	// 00:FIXED 01:INCR 10:WRAP
    parameter WATCH_DOG_WIDTH  			= 12,
    // Channel parameters
    parameter C_ADDR_AD2ETH				= 32'h0000_0000,
    parameter C_ADDR_SUMOFFSET			= 32'h0000_1000

)(	
    input                               sys_clk,
    input                               sys_rst,	
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
   	output                              maxi_rd_rready,   // Read Response ready

//	ad data input
	input								ad1_valid,
	input	[63:0]						ad1_data,
	input								ad0_valid,
	input	[63:0]						ad0_data,

//	ad fifo
	output								w_fifo_valid,
	output	[15:0]						w_fifo_data,
	input								w_fifo_full,
	output								r_fifo_valid,
	input	[63:0]						r_fifo_data,
	input								r_fifo_empty,
	output								fifo_reset
    );
//*****************************************************************************
// local reset
//*****************************************************************************			
	reg							local_reset	=	1'b0;
	always @(posedge sys_clk) begin
		local_reset	<=	sys_rst;
	end
//*****************************************************************************
// reorder ad data
// original: 	ad1_data :	{ch1,ch3,ch5,ch7};	ad0_data :	{ch0,ch2,ch4,ch6};
// reorder:		fifo input order :	ch0 ch1 ch2 ch3	ch4 ch5 ch6 ch7 ...
//*****************************************************************************			
	reg	[63:0]					ad1_data_r		=	0,
								ad0_data_r		=	0;
	reg 						ad1_valid_r		=	1'b0,
								ad0_valid_r		=	1'b0;

	localparam	[2:0]			RECEIVE 		=	0,
								FIFO		=	1;

	reg	[1:0]					fifo_state		=	0,
								fifo_next		=	0;
	reg	[3:0]					fifo_cnt		=	0;
	reg							flag_trans_one	=	1'b0;							

	//	fifo
	reg	[15:0]					o_fifo_data		=	0;
	reg							o_wfifo_valid	=	1'b0;
	reg							o_rfifo_valid	=	1'b0;
	reg	[31:0]					ad_sum			=	0;

	assign						w_fifo_valid	=	o_wfifo_valid;
	assign						w_fifo_data		=	o_fifo_data;
	assign						r_fifo_valid	=	o_rfifo_valid;
	assign						fifo_reset		=	local_reset;

//********************************************************************
// state machine
//********************************************************************

	always @(posedge sys_clk) begin
		if(local_reset) begin
			fifo_state <= 1;
		end else begin
			fifo_state	<= fifo_next;
		end
	end

	always @(*) begin
		fifo_next	=	0;
		case (1)
			fifo_state[RECEIVE]	:	if(ad1_valid_r && ad0_valid_r)
										fifo_next[FIFO]	=	1;
									else
										fifo_next[RECEIVE]	=	1;
			fifo_state[FIFO]:		if(flag_trans_one)
										fifo_next[RECEIVE]	=	1;
									else
										fifo_next[FIFO]	=	1;
			default : fifo_next[RECEIVE]	=	1;	
		endcase	
	end

	always @(posedge sys_clk) begin
		case (1)
			fifo_next[RECEIVE]	:	begin 
									fifo_cnt       <=  0;
									flag_trans_one <=  0;
									o_fifo_data    <=  0;  
									o_wfifo_valid   <=  0;
									//	receive ad1	:	suppose ad1 and ad0 exist time deviation
									if (ad1_valid) begin 
										ad1_data_r	<=	ad1_data;
										ad1_valid_r	<=	1;
									end
									else begin 
										ad1_data_r	<=	ad1_data_r;
										ad1_valid_r	<=	ad1_valid_r;			
									end
									//	receive ad0
									if (ad0_valid) begin 
										ad0_data_r	<=	ad0_data;
										ad0_valid_r	<=	1;
									end
									else begin 
										ad0_data_r	<=	ad0_data_r;
										ad0_valid_r	<=	ad0_valid_r;			
									end						
			end
			fifo_next[FIFO]	:	begin 
									if (!w_fifo_full)
										fifo_cnt	<=	fifo_cnt + 1;
									else
										fifo_cnt	<=	fifo_cnt;

									case (fifo_cnt)
										4'd0	:	begin	o_fifo_data	<=	ad0_data_r[63:48];	o_wfifo_valid	<=	!w_fifo_full;	end
										4'd1	:	begin	o_fifo_data	<=	ad1_data_r[63:48];	o_wfifo_valid	<=	!w_fifo_full;	end
										4'd2	:	begin	o_fifo_data	<=	ad0_data_r[47:32];	o_wfifo_valid	<=	!w_fifo_full;	end
										4'd3	:	begin	o_fifo_data	<=	ad1_data_r[47:32];	o_wfifo_valid	<=	!w_fifo_full;	end
										4'd4	:	begin	o_fifo_data	<=	ad0_data_r[31:16];	o_wfifo_valid	<=	!w_fifo_full;	end
										4'd5	:	begin	o_fifo_data	<=	ad1_data_r[31:16];	o_wfifo_valid	<=	!w_fifo_full;	end
										4'd6	:	begin	o_fifo_data	<=	ad0_data_r[15:00];	o_wfifo_valid	<=	!w_fifo_full;	end
										4'd7	:	begin	o_fifo_data	<=	ad1_data_r[15:00];	o_wfifo_valid	<=	!w_fifo_full;	
															flag_trans_one	<=	1;
															ad1_valid_r		<=	0;
															ad0_valid_r		<=	0;		
													end	
										default : 	begin	o_fifo_data	<=	0;	o_wfifo_valid	<=	0; end
									endcase
			end
			default : /* default */;
		endcase			
	end
//*****************************************************************************
// ad sum
//*****************************************************************************			
	reg [7:0]	trans_cnt			=	0;
	reg			flag_trans_complete	=	1'b0;
	localparam	TRANSFER_NUMBER		=	AD_SERIES_NUMBER << 1;
	reg 		flag_maxi_respond	=	1'b0;
	//reg 		flag_maxi_data		=	1'b0;
	//reg		flag_maxi_addr		=	1'b0;

	always @(posedge sys_clk) begin
	//	flag_maxi_addr		<=	maxi_waddr && maxi_wready;
	//	flag_maxi_data		<=	maxi_wd_wvalid && maxi_wd_wready && maxi_wd_wlast;
		flag_maxi_respond	<=	maxi_wb_bvalid && maxi_wb_bready;
	end

	always @(posedge sys_clk) begin
		//	data trans cnt : 1 trans -> 8 channel
		 if (flag_maxi_respond)
		 	trans_cnt           <=  0;
		 else if (fifo_state[RECEIVE] && fifo_next[FIFO])
		 	trans_cnt	<=	trans_cnt + 1;
		 else
		 	trans_cnt	<=	trans_cnt;

		 //	all channel data completely trans to fifo 
		 if (flag_maxi_respond)
		 	flag_trans_complete	<=	0;
		 else
		 	flag_trans_complete	<=	(trans_cnt == TRANSFER_NUMBER && flag_trans_one) ? 1 : flag_trans_complete;
		 
		 //	ad data sum 
		 if (flag_maxi_respond)
		 	ad_sum	<=	0;
		 else begin 
		 	if (fifo_next[FIFO])
		 		if (!fifo_cnt[0]) 	//	even
		 			ad_sum	<=	ad_sum + ad0_data_r[63 - 16*fifo_cnt[3:1] -: 16];
		 		else
		 			ad_sum	<=	ad_sum + ad1_data_r[63 - 16*fifo_cnt[3:1] -: 16];
		 	else
		 		ad_sum	<=	ad_sum;
		 end
	end
//*****************************************************************************
// AXI Internal register and wire declarations
//*****************************************************************************

// AXI m_write address channel signals

	reg	[C_AXI_ID_WIDTH-1:0]		m_wid 		=	0;
	reg	[C_AXI_ADDR_WIDTH-1:0]		m_waddr		=	0;
	reg	[7:0]						m_wlen		=	0;
	reg	[1:0]						m_wburst	=	0;
	reg								m_wvalid	=	1'b0;

// AXI m_write data channel signals

	reg	[C_AXI_DATA_WIDTH-1:0]		m_wd_wdata		=	0;
	reg	[C_AXI_DATA_WIDTH/8-1:0]	m_wd_wstrb		=	0;
	reg								m_wd_wlast		=	1'b0;
	reg								m_wd_wvalid		=	1'b0;

// AXI m_write response channel signals
	
	reg								m_wb_ready 	=	1'b0;

// AXI read address channel signals

	reg	[C_AXI_ID_WIDTH-1:0]		m_rid 		=	0;
	reg	[C_AXI_ADDR_WIDTH-1:0]		m_raddr		=	0;
	reg	[7:0]						m_rlen		=	0;
	reg	[2:0]						m_rsize		=	0;
	reg	[1:0]						m_rburst	=	0;
	reg								m_rvalid	=	1'b0;

// AXI read data channel signals
	
	reg								m_rd_rready	=	1'b0;
//*****************************************************************************
// AXI support signals
//*****************************************************************************	
	// function called clogb2 that returns an integer which has the 
	// value of the ceiling of the log base 2.                      
	function integer clogb2 (input integer bit_depth);              
	begin                                                           
	for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
	  bit_depth = bit_depth >> 1;                                 
	end                                                           
	endfunction 

	//	AXI_SIZE : the data bytes of each burst
	localparam	[2:0]	AXI_SIZE	=	clogb2(C_AXI_DATA_WIDTH/8-1);

	//	AXI_ADDR_INC : axi address increment associate with data width
	localparam 	[7:0]	AXI_ADDR_INC	=	C_AXI_DATA_WIDTH/8;

	localparam	[2:0]	SUM_SIZE	=	clogb2(32/C_AXI_DATA_WIDTH-1);
//*****************************************************************************
// m_write Internal parameter declarations
//*****************************************************************************							
	localparam  [3:0]               M_WRITE_IDLE     = 4'd0, 
									M_WRITE_ADDR     = 4'd1,
									M_WRITE_DATA     = 4'd2,										
									M_WRITE_RESPONSE = 4'd3,
									M_WRITE_TIME_OUT = 4'd4;								
	//	use one-hot encode								
    reg [4:0]                       m_write_state      =   0,
									m_write_next       =   0;

	reg [WATCH_DOG_WIDTH : 0]       m_wt_watch_dog_cnt	=   0;      
	reg	[7:0]						m_write_data_cnt	=	0;    
	reg                             trig_m_write_start 	=   1'b0;
//*****************************************************************************
// Write channel control signals
//*****************************************************************************	
	always @(posedge sys_clk) begin
		if (m_write_state[M_WRITE_IDLE])
			trig_m_write_start <= flag_trans_complete;			//	user setting
		else
			trig_m_write_start <= 0;
	end
//*****************************************************************************
// Write data state machine
//*****************************************************************************
	always @(posedge sys_clk) begin
		if(local_reset) begin
			m_write_state <= 1;
		end else begin
			m_write_state	<= m_write_next;
		end
	end

	always @(*) begin
		m_write_next	=	0;		//	next state reset
		case (1)
			m_write_state[M_WRITE_IDLE]	:	begin 
				if (trig_m_write_start)
					m_write_next[M_WRITE_ADDR]		=	1;
				else
					m_write_next[M_WRITE_IDLE]		=	1;
			end

			m_write_state[M_WRITE_ADDR]	:	begin 
				if (maxi_wready && maxi_wvalid)
					m_write_next[M_WRITE_DATA]		=	1;
				else
					m_write_next[M_WRITE_ADDR]		=	1;
			end

			m_write_state[M_WRITE_DATA] :	begin 
				if (maxi_wd_wvalid && maxi_wd_wready && maxi_wd_wlast)
					m_write_next[M_WRITE_RESPONSE]	=	1;
				else
					m_write_next[M_WRITE_DATA]		=	1;
			end

			m_write_state[M_WRITE_RESPONSE]	:	begin 
				if (maxi_wb_bvalid && maxi_wb_bready)
					m_write_next[M_WRITE_IDLE]		=	1;
				else
					m_write_next[M_WRITE_RESPONSE]	=	1;			
			end

			m_write_state[M_WRITE_TIME_OUT] :	begin 
					m_write_next[M_WRITE_IDLE]		=	1;
			end
													
			default : m_write_next[M_WRITE_IDLE]		=	1;
		endcase
	end	
//*****************************************************************************
// Watch dog signals
//*****************************************************************************	
	always @(posedge sys_clk) begin
		 if (m_write_state != m_write_next)
		 	m_wt_watch_dog_cnt	<=	0;
		 else
		 	m_wt_watch_dog_cnt	<=	m_wt_watch_dog_cnt + 1; 
	end

//*****************************************************************************
// Write channel address signals
//*****************************************************************************	
	//	m_waddr	m_wvalid
	always @(posedge sys_clk) begin
		if (m_write_state[M_WRITE_ADDR] && m_write_next[M_WRITE_ADDR]) begin
			m_waddr  <=  flag_trans_complete ? (C_ADDR_AD2ETH + C_ADDR_SUMOFFSET) : C_ADDR_AD2ETH;   //  user setting                
			m_wvalid <=  1;
		end
		else begin 
			m_waddr  <=  m_waddr;
			m_wvalid <=  0;              
		end
	end

	//	m_wid
	always @(posedge sys_clk) begin
		if(local_reset) begin
			 m_wid	<=	0;
		end else begin
			 if (m_write_state[M_WRITE_IDLE] && m_write_next[M_WRITE_ADDR])
			 	m_wid	<=	m_wid + 1;
			 else
			 	m_wid	<=	m_wid;
		end
	end

	//	m_wlen	:	INCR bursts
	localparam	AXI_TRANSFER_NUMBER	=	AD_SERIES_NUMBER << 2;

	always @(posedge sys_clk) begin
		 if (m_write_state[M_WRITE_IDLE] && m_write_next[M_WRITE_ADDR])
		 	m_wlen	<=	flag_trans_complete ? (1 - 1) : (AXI_TRANSFER_NUMBER - 1);			 			//	user setting
		 else
		 	m_wlen	<=	m_wlen;
	end	

	//	m_wburst	
	//	C_AXI_BURST_TYPE :01 INCR bursts :support burst_len max to 256 (default) 	
	//	C_AXI_BURST_TYPE :10 WRAP bursts :support burst_len 2,4,8,16 				
	//always @(posedge sys_clk) begin
	//	if(local_reset) begin
	//		m_wburst	<=	0;
	//	end else begin
	//		m_wburst	<=	C_AXI_BURST_TYPE;	
	//	end
	//end	

	assign	maxi_wid	=	m_wid;
	assign	maxi_waddr	=	m_waddr;
	assign	maxi_wlen	=	m_wlen;
	assign	maxi_wsize	=	AXI_SIZE;
	assign	maxi_wburst	=	C_AXI_BURST_TYPE;
	assign	maxi_wvalid	=	m_wvalid;

	// Not supported and hence assigned zeros
	assign	maxi_wlock	=	2'b0;
	assign	maxi_wcache	=	4'b0;
	assign	maxi_wprot	=	3'b0;	
//*****************************************************************************
// Write channel data signals
//*****************************************************************************	
	//	data count
	always @(posedge sys_clk) begin
		if (m_write_next[M_WRITE_IDLE])
			m_write_data_cnt	<=	0;
		else if (m_write_state[M_WRITE_ADDR] && m_write_next[M_WRITE_DATA])
			m_write_data_cnt	<=	maxi_wlen;
		else if (maxi_wd_wvalid && maxi_wd_wready)
			m_write_data_cnt	<=	m_write_data_cnt - 1;
		else
			m_write_data_cnt	<=	m_write_data_cnt;
	end

	//	r_fifo_valid
//	always @(posedge sys_clk) begin
//		if (m_write_next[M_WRITE_DATA] && !flag_trans_complete)
//			if (maxi_wd_wvalid && maxi_wd_wready && !maxi_wd_wlast)
//				o_rfifo_valid	<=	1;
//			else if (m_wt_watch_dog_cnt == 0)	//	second fifo data update
//				o_rfifo_valid	<=	1;
//			else
//				o_rfifo_valid	<=	0;
//		else
//			o_rfifo_valid	<=	0;
//	end
	always @(*) begin
		if (m_write_state[M_WRITE_DATA] && !flag_trans_complete)
			if (maxi_wd_wvalid && maxi_wd_wready && !maxi_wd_wlast)
				o_rfifo_valid	=	1;
			else if (!m_wd_wvalid)	//	second fifo data update
				o_rfifo_valid	=	1;
			else
				o_rfifo_valid	=	0;
		else
			o_rfifo_valid	=	0;
	end

	//	m_wd_wdata
	always @(posedge sys_clk) begin
		if (m_write_state[M_WRITE_DATA] && m_write_next[M_WRITE_DATA])
			if (flag_trans_complete)
				m_wd_wdata	<=	ad_sum;
			else begin 
				if (r_fifo_valid)
					m_wd_wdata	<=	r_fifo_data;
				else
					m_wd_wdata	<=	m_wd_wdata;
			end			
		else begin 
			m_wd_wdata	<=	0;				 	
		end
	end

	//	m_wd_wvalid
	always @(posedge sys_clk) begin		 
		 if (m_write_state[M_WRITE_DATA] && m_write_next[M_WRITE_DATA]) begin 
		 	//if (r_fifo_valid || flag_trans_complete)
		 	//	m_wd_wvalid	<=	1;	 				//	user setting
		 	//else if (maxi_wd_wready)
		 	//	m_wd_wvalid	<=	0;
		 	//else
		 	//	m_wd_wvalid	<=	m_wd_wvalid;
		 	m_wd_wvalid	<=	1;
		 end 
		 else begin 
		 	m_wd_wvalid	<=	0;				 	
		 end		
	end	

	//	m_wd_wlast
	always @(posedge sys_clk) begin		 
		 if (m_write_state[M_WRITE_DATA] && m_write_next[M_WRITE_DATA]) begin 
		 	if (maxi_wlen == 0)										//	user setting					
		 		m_wd_wlast	<=	1;
		 	else if (m_write_data_cnt == 1 && maxi_wd_wready)
		 		m_wd_wlast	<=	1;
		 	else
		 		m_wd_wlast	<=	m_wd_wlast;				
		 end 
		 else begin 
		 	m_wd_wlast	<=	0;				 	
		 end		
	end	

	//	m_wd_wstrb
	//	used in narrow transfer, data bytes mask, wstrb = 4'b0001 -> only last byte valid
	always @(posedge sys_clk) begin
		if (m_write_state[M_WRITE_DATA] && m_write_next[M_WRITE_DATA])
			m_wd_wstrb	<=	{(C_AXI_DATA_WIDTH/8){1'b1}};
		else
			m_wd_wstrb	<=	0;
	end

	assign	maxi_wd_wdata	=	m_wd_wdata;
	assign	maxi_wd_wstrb	=	m_wd_wstrb;
	assign	maxi_wd_wlast	=	m_wd_wlast;
	assign	maxi_wd_wvalid	=	m_wd_wvalid;

//*****************************************************************************
// Write channel response signals
//*****************************************************************************	
	always @(posedge sys_clk) begin
		if (m_write_state[M_WRITE_RESPONSE] && !m_wb_ready)
			m_wb_ready <= maxi_wb_bvalid;
		else
			m_wb_ready <= 0;
	end

	assign	maxi_wb_bready	=	m_wb_ready;	

endmodule
