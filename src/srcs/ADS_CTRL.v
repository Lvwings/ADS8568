// -----------------------------------------------------------------------------
// Copyright (c) 2014-2021 All rights reserved
// -----------------------------------------------------------------------------
// Author : wings
// File   : ADS_CTRL.v
// Create : 2021-04-07 14:13:12
// Revise : 2021-04-25 16:27:48
// Editor : sublime text3, tab size (4)
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
// -----------------------------------------------------------------------------
`timescale 1ns / 1ps

module ADS_CTRL #(
	parameter	AD_SERIES_NUMBER	=	4
	)
	(
	input	sys_clk,    	// Clock	200m
	input	sys_rst,  		// synchronous reset active high
	input	trig_convst,

	//	ads interface
	output	reset,
	output	convst,
	input	busy,
	output	fs_n,
	output	sclk,			//	40m
	output	sdi,
	input	[3:0]	sdo,	//	bit[0]:a	bit[1]:b	bit[2]:c	bit[3]:d

	//	data transfer
	output	ad_valid,
	output	[63:0]	ad_data	//	with 2 channel data per time
	
);

//*****************************************************************************
// output registers
//*****************************************************************************			
	reg			o_reset		=	1'b0;
	reg			o_convst	=	1'b0;
	reg			o_fs_n		=	1'b1;
	reg			sclk_p		=	1'b1;
	reg			sclk_n		=	1'b1;	

	reg			valid		=	1'b0;
	reg	[63:0]	data		=	0;
	
	assign		convst		=	o_convst;
	assign		reset		=	o_reset;
	assign		fs_n		=	o_fs_n;
	assign		sclk		=	sclk_p & sclk_n;
	assign		sdi			=	0;

	assign		ad_valid	=	valid;
	assign		ad_data		=	data;
//********************************************************************
// state machine parameter declarations
//********************************************************************							
	localparam  [3:0]               IDLE     		= 4'd0, 
									RESET     		= 4'd1,
									CONVST     		= 4'd2,	
									FSN				= 4'd3,						
									READ 			= 4'd4,
									TIME_OUT 		= 4'd5;						
	//	use one-hot encode									
    reg [5:0]                       state			=   0,
    								next			=   0;	
    localparam	SAMPLE_CHANNEL	=	AD_SERIES_NUMBER << 3;				

//*****************************************************************************
// local reset
//*****************************************************************************			
	reg							local_reset	=	1'b0;
	always @(posedge sys_clk) begin
		local_reset	<=	sys_rst;
	end
	
//********************************************************************
// Watch dog signals
//********************************************************************	
	reg	[15:0]		watch_dog_cnt	=	0;	

	always @(posedge sys_clk) begin
		if (state != next)
			watch_dog_cnt	<=	0;
		else
			watch_dog_cnt	<=	watch_dog_cnt + 1; 
	end	
//********************************************************************
// state machine
//********************************************************************

	always @(posedge sys_clk) begin
		if(local_reset) begin
			state <= 2;
		end else begin
			state	<= next;
		end
	end

	
	reg			flag_fs_over	=	1'b0;
	reg			flag_read_over	=	1'b0;
	reg			flag_reset_over	=	1'b0;
	reg			flag_convst_over=	1'b0;


	reg	[15:0]	time_cnt		=	0;
	localparam	TIME_CONVST		=	16'd200,	//	1000ns	:	convst high
				TIME_RESET		=	16'd20,		//	100ns	:	reset time
				TIME_BUSY2FS	=	16'd200,	//	1000ns	:	busy negedge -> fs negedge
				TIME_FS2SCLK	=	16'd4,		//	20ns	:	fs negedge -> sclk negedge
				TIME_SCLK		=	16'd200;	//	1000ns	:	sclk period


	reg			busy_d			=	1'b0;
	reg			busy_d2			=	1'b0;
	reg	[3:0]	bit_cnt			=	0;
	reg	[7:0]	channel_cnt		=	0;	
	reg	[15:0]	sdoa			=	0,
				sdob			=	0,
				sdoc			=	0,
				sdod			=	0;

	always @(posedge sys_clk) begin
		busy_d		<=	busy;
		busy_d2		<=	busy_d;
		case (1)
			next[IDLE]	:	begin 
							bit_cnt          <=  0;
							time_cnt         <=  0;
							channel_cnt      <=  0;

							flag_read_over   <=  0;
							flag_fs_over     <=  0;
							flag_reset_over  <=  0;
							flag_convst_over <=  0;

							o_reset          <=  0;
							o_convst         <=  0;
							o_fs_n           <=  1;

							sdoa             <=  0;              
							sdob             <=  0;                                                  
							sdoc             <=  0;                                                  
							sdod             <=  0;                                  
			end

			next[CONVST]:	begin 
							if (!busy_d && busy_d2) begin 
								time_cnt         <=  0;
								flag_convst_over <=  1;
							end
							else if (time_cnt == TIME_CONVST) begin
								time_cnt         <=  time_cnt;
								o_convst         <=  0;
							end
							else begin 
								time_cnt         <=  time_cnt + 1;
								o_convst         <=  1;
							end
			end

			next[FSN]	:	begin 
							if (time_cnt == TIME_BUSY2FS + 1) begin
								time_cnt     <=  0;
								flag_fs_over <=  1;
								o_convst     <=  0;
							end
							else begin 
								o_fs_n       <=  (time_cnt < TIME_BUSY2FS);
								time_cnt     <=  time_cnt + 1;
							end
			end

			next[READ]	:	begin 
							//	sclk cnt
							if (time_cnt == TIME_SCLK - 1)
								time_cnt	<=	0;
							else
								time_cnt	<=	time_cnt + 1;

							//	data receive
							if (time_cnt == 1) begin
								bit_cnt	<=	bit_cnt + 1;
								sdoa[15-bit_cnt]	<=	sdo[0];
								sdob[15-bit_cnt]	<=	sdo[1];
								sdoc[15-bit_cnt]	<=	sdo[2];
								sdod[15-bit_cnt]	<=	sdo[3];
							end
							else begin 
								bit_cnt	<=	bit_cnt;
								sdoa	<=	sdoa;				
								sdob	<=	sdob;													
								sdoc	<=	sdoc;													
								sdod	<=	sdod;				
							end

							//	channel cnt		one sample for 4 channel
							if (bit_cnt == 15 && time_cnt == 1)	
								channel_cnt	<=	channel_cnt + 4;									
							else
								channel_cnt	<=	channel_cnt;

							//	fsn
							o_fs_n	<=	(channel_cnt == SAMPLE_CHANNEL && time_cnt == 0);

							flag_read_over	<=	(channel_cnt == SAMPLE_CHANNEL && time_cnt == 0);
			end

			next[RESET]	:	begin 
							if (time_cnt == TIME_RESET)	begin 
								o_reset         <=  0;
								time_cnt        <=  0;
								flag_reset_over <=  1;
							end
							else begin 
								o_reset         <=  1;
								time_cnt        <=  time_cnt + 1;
							end
			end
			default : /* default */;
		endcase
	end
				
	always @(*) begin
		next	=	0;		//	next state reset
		case (1)
			state[IDLE]		:	if (trig_convst)
									next[CONVST]	=	1;
								else
									next[IDLE]		=	1;

			state[CONVST]	:	if 	(flag_convst_over)
									next[FSN]		=	1;
								else
									next[CONVST]	=	1;

			state[FSN]		:	if 	(flag_fs_over)
									next[READ]		=	1;
								else
									next[FSN]		=	1;					

			state[READ]		:	if 	(flag_read_over)
									next[IDLE]		=	1;
								else
									next[READ]		=	1;	
			state[RESET]	:	if 	(flag_reset_over)
									next[IDLE]		=	1;
								else
									next[RESET]		=	1;				
			default : next[IDLE]	=	1;
		endcase
	end		

//*****************************************************************************
// sclk generate
//*****************************************************************************			
//	always @(posedge sys_clk) begin
//		if (next[READ]) begin
//			sclk_p	<=	(time_cnt <= TIME_SCLK/2);
//		end
//		else
//			sclk_p	<=	1;
//	end
//
//	always @(negedge sys_clk) begin
//		if (next[READ]) begin
//			sclk_n	<=	(time_cnt <= TIME_SCLK/2);
//		end
//		else
//			sclk_n	<=	1;
//	end
 	always @(posedge sys_clk) begin
 		if (next[READ]) begin
 			sclk_p	<=	(time_cnt <= (TIME_SCLK/2 - 1));
 		end
 		else
 			sclk_p	<=	1;
 	end
//*****************************************************************************
// ad data output
//*****************************************************************************			
	always @(posedge sys_clk) begin
		 if (bit_cnt == 0 && (|channel_cnt) && (time_cnt == 1)) begin
		 	 data	<=	{sdoa,sdob,sdoc,sdod};
		 	 valid	<=	1;
		 end	 
		 else begin
		 	data	<=	0;
		 	valid	<=	0;
		 end
	end

endmodule