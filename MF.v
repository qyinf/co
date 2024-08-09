include "define.v";
module MF(
    input clk,
	 input reset,
    input [31:0] instrE,
	 input [31:0] rsdataE,
	 input [31:0] rtdataE,
	 input start,
	 input req,
    output reg busy,
    output [31:0] ldata,
    output [31:0] hdata
);
	reg [31:0] cnt;
	reg [31:0] hi;
	reg [31:0] lo;
	reg [31:0] tmphi;
	reg [31:0] tmplo;
	initial begin 
		cnt = 0;
		hi = 0;
		lo = 0;
		tmphi = 0;
		tmplo = 0;
	end
	//info
	wire [5:0] func;
	wire [5:0] op;
	assign func = instrE[`func];
	assign op = instrE[`op];
	
	//mthi,mtlo
	always@(posedge clk)begin
		if(req == 0)begin
			if(op == 0 && func == `mthi_func)hi <= rsdataE;
			else if(op == 0 && func == `mtlo_func)lo <= rsdataE;
		end
	end
	
	//mfhi,mflo
	assign ldata = lo;
	assign hdata = hi;
	
	//calculate
	always@(posedge clk)begin
		if(reset)begin
			cnt <= 0;
			lo <= 0;
			hi <= 0;
			busy <= 0;
			tmplo <= 0;
			tmphi <= 0;
		end
		else if(req == 0)begin
			if(cnt == 0)begin
				if(start)begin
					busy <= 1;
					if(op == 0 && (func == `mult_func || func == `multu_func))cnt <= 5;
					else if(op == 0 && (func == `div_func || func == `divu_func))cnt <= 10;
			
					if(op == 0 && func == `multu_func){tmphi,tmplo} <= rsdataE * rtdataE;
					else if(op == 0 && func == `mult_func){tmphi,tmplo} <= $signed(rsdataE)*$signed(rtdataE);
					else if(op == 0 && func == `div_func)begin
						tmplo <= $signed(rsdataE) / $signed(rtdataE);
						tmphi <= $signed(rsdataE) % $signed(rtdataE);
					end
					else if(op == 0 && func == `divu_func)begin
						tmplo <= rsdataE / rtdataE;
						tmphi <= rsdataE % rtdataE;
					end
				end
				else begin
					cnt <= 0;
				end
			end
			else if(cnt == 1)begin
				lo <= tmplo;
				hi <= tmphi;
				busy <= 0;
				cnt <= 0;
			end
			else begin
				cnt <= cnt - 1;
			end
		end
	end
endmodule