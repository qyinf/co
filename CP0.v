`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:33:52 11/27/2022 
// Design Name: 
// Module Name:    CP0 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`include "define.v"
`define IM SR[15:10]
`define EXL SR[1]
`define IE SR[0]
`define BD Cause[31]
`define hwint_pend Cause[15:10]
`define ExcCode Cause[6:2]
module CP0(
	 input clk,
	 input reset,
	 input BDIn,//该指令是否为延迟槽指令
	 input [4:0] ExcCodeIn,//异常码
	 input [5:0] HWInt,//中断信号
	 
	 input [31:0] instr,//用于mtc0和mfc0的实现
	 input [31:0] rtdataM,
	 input [31:0] pcM,
	 
	 input [31:0] macropc,//宏观pc
	 
    output Req,//控制外面的流水
	 output [31:0] EPCout,//用于eret
	 output [31:0] cp0Out//可以类比lw
    );  
	 
	 always@(*)begin
		//$display("pcM=%h,req=%d,ExcCode=%d",pcM,Req,ExcCodeIn);
		//$display("EPC=%h",EPCout);
	 end
	//qwp
	reg [31:0] SR;
	reg [31:0] Cause;
	reg [31:0] EPCreg; 
	reg [31:0] PRId;
	initial begin SR = 0;Cause = 0;EPCreg = 0;PRId = 0;end
	//
	wire IntReq;
	wire ExcReq;
	assign IntReq = (|(HWInt & `IM)) & !`EXL & `IE;
	assign ExcReq = (|ExcCodeIn) & !`EXL;
	assign Req = IntReq | ExcReq;

	wire [31:0] EPCtmp;
	assign EPCtmp = (Req == 1 && BDIn == 1)? macropc - 4 :
						 (Req == 1)? macropc :
					    EPCreg;
	
	assign EPCout = EPCtmp;
	
	//mfc0
	wire [5:0] op;
	wire [4:0] rs;
	wire [4:0] rd;
	wire [5:0] func;
	wire is_jump;
	assign func = instr[`func];
	assign op = instr[`op];
	assign rs = instr[`rs];
	assign rd = instr[`rd];

	assign cp0Out = (rd == 12)? SR :
						 (rd == 13)? Cause:
						 (rd == 14)? EPCout:
						 (rd == 15)? PRId :
						 6;
						 
	//mtc0
	always@(posedge clk)begin
		if(reset)begin
			SR <= 0;
			EPCreg <= 0;
			Cause <= 0;
			PRId <= 0;
		end
		else begin
			if(op == `wrong_op && func == `eret_func) `EXL <= 0;
			if(Req)begin
				`ExcCode <= IntReq ? 0 :ExcCodeIn;
				`EXL <= 1'b1;
				EPCreg <= EPCtmp;
				`BD <= BDIn;
			end
			else if(op == `wrong_op && rs == `mtc0_rs)begin
				if(rd == 12) SR <= rtdataM ;
				else if(rd == 14) EPCreg <= rtdataM;
			end
			`hwint_pend <= HWInt;
		end
	end
endmodule
