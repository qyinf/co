include "define.v";
module MF(
    input clk,
	 input reset,
    input [31:0] instrEX,
	 input [31:0] rsdataEX,
	 input [31:0] rtdataEX,
	 input start,
    output reg busy,
    output reg [31:0] ldata,
    output reg [31:0] hdata
);
	reg [31:0] cnt;
	reg [31:0] hi;
	reg [31:0] lo;
	initial begin 
		cnt = 0;
		hi = 0;
		lo = 0;
		ldata = 0;
		hdata = 0;
	end
	wire [5:0] func;
	wire [5:0] op;
	assign func = instrEX[`func];
	assign op = instrEX[`op];
	always@(posedge clk)begin
		if(op == 0 && func == `mthi_func)hdata <= rsdataEX;
		else if(op == 0 && func == `mtlo_func)ldata <= rsdataEX;
	end
	always@(posedge clk)begin
		if(reset)begin
			cnt <= 0;
			hi <= 0;
			lo <= 0;
			busy <= 0;
			ldata <= 0;
			hdata <= 0;
		end
		else begin
			if(cnt == 0)begin
				if(start)begin
					busy <= 1;
					if(op == 0 && (func == `mult_func || func == `multu_func))cnt <= 5;
					else if(op == 0 && (func == `div_func || func == `divu_func))cnt <= 10;
			
					if(op == 0 && func == `multu_func){hi,lo} <= rsdataEX * rtdataEX;
					else if(op == 0 && func == `mult_func){hi,lo} <= $signed(rsdataEX)*$signed(rtdataEX);
					else if(op == 0 && func == `div_func)begin
						lo <= $signed(rsdataEX) / $signed(rtdataEX);
						hi <= $signed(rsdataEX) % $signed(rtdataEX);
					end
					else if(op == 0 && func == `divu_func)begin
						lo <= rsdataEX / rtdataEX;
						hi <= rsdataEX % rtdataEX;
					end
				end
				else begin
					cnt <= 0;
				end
			end
			else if(cnt == 1)begin
				ldata <= lo;
				hdata <= hi;
				busy <= 0;
				cnt <= 0;
			end
			else begin
				cnt <= cnt - 1;
			end
		end
	end
endmodule