`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/07 16:38:23
// Design Name: 
// Module Name: tb_ads_ctrl
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



`timescale 1ns/1ps

module tb_ADS_CTRL (); /* this is automatically generated */

	// clock
	logic clk;
	initial begin
		clk = '0;
		forever #(2.5) clk = ~clk;
	end

	// asynchronous reset
	logic sys_rst;
	initial begin
		sys_rst <= '0;
		#10
		sys_rst <= '1;
		#10
		sys_rst <= '0;		
	end

	// synchronous reset
	logic srstb;
	initial begin
		srstb <= '0;
		repeat(10)@(posedge clk)
		srstb <= '1;
	end

	// (*NOTE*) replace reset, clock, others

	localparam     [3:0] IDLE = 4'd0;
	localparam    [3:0] RESET = 4'd1;
	localparam   [3:0] CONVST = 4'd2;
	localparam      [3:0] FSN = 4'd3;
	localparam     [3:0] READ = 4'd4;
	localparam [3:0] TIME_OUT = 4'd5;
	localparam    TIME_CONVST = 8'd40;
	localparam     TIME_RESET = 8'd20;
	localparam   TIME_BUSY2FS = 8'd20;
	localparam   TIME_FS2SCLK = 8'd4;
	localparam      TIME_SCLK = 8'd5;

	logic        sys_rst;
	logic        trig_convst;
	logic        reset;
	logic        convst;
	logic        busy;
	logic        fs_n;
	logic        sclk;
	logic        sdi;
	logic  [3:0] sdo;
	logic        data_valid;
	logic [63:0] ad_data;

	ADS_CTRL inst_ADS_CTRL
		(
			.sys_clk     (clk),
			.sys_rst     (sys_rst),
			.trig_convst (trig_convst),
			.reset       (reset),
			.convst      (convst),
			.busy        (busy),
			.fs_n        (fs_n),
			.sclk        (sclk),
			.sdi         (sdi),
			.sdo         (sdo),
			.data_valid  (data_valid),
			.ad_data     (ad_data)
		);

	task init();
		trig_convst <= '0;
		busy        <= '0;
		sdo         <= '0;
	endtask


	initial begin
		// do something
		init();

	end

	reg	[5:0]	state 		=	0,
				next		=	0;
	always @(posedge clk) begin
		if(sys_rst) begin
			state <= 1;
		end else begin
			state	<= next;
		end
	end

	reg flag_convst_over	=	1'b0;
	reg flag_read_over		=	1'b0;

	always_comb begin
		next	=	0;
		case (1)
			state[IDLE]		:	if (convst)
									next[CONVST]	=	1;
								else
									next[IDLE]		=	1;
	
			state[CONVST]	:	if (flag_convst_over)
									next[READ]		=	1;
								else
									next[CONVST]	=	1;
			
			state[READ]		:	if (flag_read_over)
									next[IDLE]		=	1;
								else
									next[READ]		=	1;
			default : /* default */;
		endcase
	
	end

	reg	sclk_d	=	1'b0;
	reg	[7:0]	time_cnt	=	0;
	reg	[15:0]	data		=	1;
	reg	[7:0]	byte_cnt	=	0;	
	reg [3:0]	bit_cnt		=	0;

	always_ff @(posedge clk) begin
		sclk_d	<=	sclk;
		case (1)
			next[IDLE]		:	begin 
				time_cnt	<=	0;
				byte_cnt	<=	0;
				bit_cnt		<=	1;
				sdo[0]		<=	data[15];
				sdo[1]		<=	data[15];
				sdo[2]		<=	data[15];
				sdo[3]		<=	data[15];	
			end

			next[CONVST]	:	begin 
				if (time_cnt == 50) begin 
					busy             <=  0;
					time_cnt         <=  0;
					flag_convst_over <=  1;
				end
				else begin 
					busy             <=  1;
					time_cnt         <=  time_cnt + 1;
					flag_convst_over <= 0;
				end
			end

			next[READ]		:	begin 
					if (!sclk && sclk_d) begin 
						bit_cnt	<=	bit_cnt + 1;
						sdo[0]	<=	data[15-bit_cnt];
						sdo[1]	<=	data[15-bit_cnt];
						sdo[2]	<=	data[15-bit_cnt];
						sdo[3]	<=	data[15-bit_cnt];
					end
					else begin 
						bit_cnt	<=	bit_cnt;
						sdo		<=	sdo;
					end

					if (bit_cnt == 15 && !sclk && sclk_d) begin
						byte_cnt	<=	byte_cnt + 1;
						data		<=	data + 1;
					end
					else begin 
						byte_cnt	<=	byte_cnt;
						data		<=	data;
					end

					flag_read_over	<=	(byte_cnt == 128);
			end
			default : /* default */;
		endcase
	end

	reg [9:0]	trig_cnt	=	0;
	always_ff @(posedge clk) begin 
		trig_cnt	<=	trig_cnt + 1;
		trig_convst	<=	(trig_cnt == 100);
	end

endmodule

