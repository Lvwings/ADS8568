`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/08 16:51:24
// Design Name: 
// Module Name: tb_ads_top
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

module tb_ADS_TOP (); /* this is automatically generated */

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

	// (*NOTE*) replace reset, clock, others

	parameter       C_AXI_ID_WIDTH = 4;
	parameter     C_AXI_ADDR_WIDTH = 32;
	parameter     C_AXI_DATA_WIDTH = 64;
	parameter C_AXI_NBURST_SUPPORT = 1'b0;
	parameter     C_AXI_BURST_TYPE = 2'b00;
	parameter      WATCH_DOG_WIDTH = 12;
	parameter        C_ADDR_AD2ETH = 32'h0000_0000;
	parameter     C_ADDR_SUMOFFSET = 32'h0000_1000;

	logic                          sys_clk;
	logic                          sys_rst;
	logic                          trig_convst;
	logic                          ad1_reset;
	logic                          ad1_convst;
	logic                          ad1_busy;
	logic                          ad1_fs_n;
	logic                          ad1_sclk;
	logic                          ad1_sdi;
	logic                    [3:0] ad1_sdo;
	logic                          ad0_reset;
	logic                          ad0_convst;
	logic                          ad0_busy;
	logic                          ad0_fs_n;
	logic                          ad0_sclk;
	logic                          ad0_sdi;
	logic                    [3:0] ad0_sdo;
	logic                          maxi_wready;
	logic     [C_AXI_ID_WIDTH-1:0] maxi_wid;
	logic   [C_AXI_ADDR_WIDTH-1:0] maxi_waddr;
	logic                    [7:0] maxi_wlen;
	logic                    [2:0] maxi_wsize;
	logic                    [1:0] maxi_wburst;
	logic                    [1:0] maxi_wlock;
	logic                    [3:0] maxi_wcache;
	logic                    [2:0] maxi_wprot;
	logic                          maxi_wvalid;
	logic                          maxi_wd_wready;
	logic   [C_AXI_DATA_WIDTH-1:0] maxi_wd_wdata;
	logic [C_AXI_DATA_WIDTH/8-1:0] maxi_wd_wstrb;
	logic                          maxi_wd_wlast;
	logic                          maxi_wd_wvalid;
	logic     [C_AXI_ID_WIDTH-1:0] maxi_wb_bid;
	logic                    [1:0] maxi_wb_bresp;
	logic                          maxi_wb_bvalid;
	logic                          maxi_wb_bready;
	logic                          maxi_rready;
	logic     [C_AXI_ID_WIDTH-1:0] maxi_rid;
	logic   [C_AXI_ADDR_WIDTH-1:0] maxi_raddr;
	logic                    [7:0] maxi_rlen;
	logic                    [2:0] maxi_rsize;
	logic                    [1:0] maxi_rburst;
	logic                    [1:0] maxi_rlock;
	logic                    [3:0] maxi_rcache;
	logic                    [2:0] maxi_rprot;
	logic                          maxi_rvalid;
	logic     [C_AXI_ID_WIDTH-1:0] maxi_rd_bid;
	logic                    [1:0] maxi_rd_rresp;
	logic                          maxi_rd_rvalid;
	logic   [C_AXI_DATA_WIDTH-1:0] maxi_rd_rdata;
	logic                          maxi_rd_rlast;
	logic                          maxi_rd_rready;

	ADS_TOP #(
			.C_AXI_ID_WIDTH(C_AXI_ID_WIDTH),
			.C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
			.C_AXI_DATA_WIDTH(C_AXI_DATA_WIDTH),
			.C_AXI_NBURST_SUPPORT(C_AXI_NBURST_SUPPORT),
			.C_AXI_BURST_TYPE(C_AXI_BURST_TYPE),
			.WATCH_DOG_WIDTH(WATCH_DOG_WIDTH),
			.C_ADDR_AD2ETH(C_ADDR_AD2ETH),
			.C_ADDR_SUMOFFSET(C_ADDR_SUMOFFSET)
		) inst_ADS_TOP (
			.sys_clk        (clk),
			.sys_rst        (sys_rst),
			.trig_convst    (trig_convst),
			.ad1_reset      (ad1_reset),
			.ad1_convst     (ad1_convst),
			.ad1_busy       (ad1_busy),
			.ad1_fs_n       (ad1_fs_n),
			.ad1_sclk       (ad1_sclk),
			.ad1_sdi        (ad1_sdi),
			.ad1_sdo        (ad1_sdo),
			.ad0_reset      (ad0_reset),
			.ad0_convst     (ad0_convst),
			.ad0_busy       (ad0_busy),
			.ad0_fs_n       (ad0_fs_n),
			.ad0_sclk       (ad0_sclk),
			.ad0_sdi        (ad0_sdi),
			.ad0_sdo        (ad0_sdo),
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
			.maxi_rd_rready (maxi_rd_rready)
		);

	task init();
		trig_convst <= '0;
		ad1_busy    <= '0;
		ad1_sdo     <= '0;
		ad0_busy    <= '0;
		ad0_sdo     <= '0;
		maxi_wready    <= '1;
		maxi_wd_wready <= '0;
		maxi_wb_bid    <= '0;
		maxi_wb_bresp  <= '0;
		maxi_wb_bvalid <= '1;
		maxi_rready    <= '0;
		maxi_rd_bid    <= '0;
		maxi_rd_rresp  <= '0;
		maxi_rd_rvalid <= '0;
		maxi_rd_rdata  <= '0;
		maxi_rd_rlast  <= '0;		
	endtask

	
	initial begin
		// do something
		init();
	end

	localparam     [3:0] IDLE = 4'd0;
	localparam    [3:0] RESET = 4'd1;
	localparam   [3:0] CONVST = 4'd2;
	localparam      [3:0] FSN = 4'd3;
	localparam     [3:0] READ = 4'd4;

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
			state[IDLE]		:	if (ad0_convst)
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
	reg	[15:0]	data0		=	16'h0001;
	reg	[15:0]	data1 		=	16'h1001;
	reg	[15:0]	data2		=	16'h2001;
	reg	[15:0]	data3 		=	16'h3001;	
	reg	[7:0]	byte_cnt	=	0;	
	reg [3:0]	bit_cnt		=	0;

	always_ff @(posedge clk) begin
		sclk_d	<=	ad0_sclk;
		case (1)
			next[IDLE]		:	begin 
				time_cnt	<=	0;
				byte_cnt	<=	0;
				bit_cnt		<=	1;
				ad0_sdo[0]		<=	data0[15];
				ad0_sdo[1]		<=	data0[15];
				ad0_sdo[2]		<=	data0[15];
				ad0_sdo[3]		<=	data0[15];	
				ad1_sdo[0]		<=	data1[15];
				ad1_sdo[1]		<=	data1[15];
				ad1_sdo[2]		<=	data1[15];
				ad1_sdo[3]		<=	data1[15];				
			end

			next[CONVST]	:	begin 
				if (time_cnt == 55) begin 
					ad0_busy         <=  0;
					ad1_busy         <=  0;
					time_cnt         <=  0;
					flag_convst_over <=  1;
				end
				else if (time_cnt >= 54) begin 
					ad0_busy         <=  1;
					ad1_busy         <=  0;
					time_cnt         <=  time_cnt + 1;
					flag_convst_over <= 0;
				end				
				else begin 
					ad0_busy         <=  1;
					ad1_busy         <=  1;
					time_cnt         <=  time_cnt + 1;
					flag_convst_over <= 0;
				end
			end

			next[READ]		:	begin 
					if (!ad0_sclk && sclk_d) begin 
						bit_cnt	<=	bit_cnt + 1;
						ad0_sdo[0]	<=	data0[15-bit_cnt];
						ad0_sdo[1]	<=	data0[15-bit_cnt];
						ad0_sdo[2]	<=	data1[15-bit_cnt];
						ad0_sdo[3]	<=	data1[15-bit_cnt];
						ad1_sdo[0]	<=	data2[15-bit_cnt];
						ad1_sdo[1]	<=	data2[15-bit_cnt];
						ad1_sdo[2]	<=	data3[15-bit_cnt];
						ad1_sdo[3]	<=	data3[15-bit_cnt];						
					end
					else begin 
						bit_cnt	<=	bit_cnt;
						ad0_sdo		<=	ad0_sdo;
						ad1_sdo		<=	ad1_sdo;
					end

					if (bit_cnt == 15 && !ad0_sclk && sclk_d) begin
						byte_cnt	<=	byte_cnt + 1;
						data0		<=	data0 + 1;
						data1		<=	data1 + 1;
						data2		<=	data2 + 1;
						data3		<=	data3 + 1;						
					end
					else begin 
						byte_cnt	<=	byte_cnt;
						data0		<=	data0;
						data1		<=	data1;
						data2		<=	data2;
						data3		<=	data3;						
					end

					flag_read_over	<=	(byte_cnt == 32);
			end
			default : /* default */;
		endcase
	end

	reg [9:0]	trig_cnt	=	0;
	always_ff @(posedge clk) begin 
		if (next[IDLE])
			trig_cnt	<=	trig_cnt + 1;
		else
			trig_cnt	<=	trig_cnt;
		trig_convst	<=	(trig_cnt == 100);
	end

/*	reg [1:0] valid_cnt	=	0;
	always @(posedge clk) begin
		if(sys_rst) begin
			maxi_wd_wready  <= 0;
			valid_cnt	<=	0;
		end else begin
			if (maxi_wd_wvalid)	
				valid_cnt	<=	valid_cnt + 1;
			else
				valid_cnt	<=	valid_cnt;

			maxi_wd_wready	<=	(valid_cnt == 3);
		end
	end	*/
	assign	maxi_wd_wready	=	maxi_wd_wvalid;
endmodule

