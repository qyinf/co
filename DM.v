`include "define.v"
module DM(
    input clk,
    input reset,
	 input [31:0] instrMEM,
	 input [31:0] dmOut,
	 input [31:0] aluOutMEM,
	 input [31:0] rtdataMEM,
	 
	 input [31:0] RegDataMEM,
	 input [4:0] RegAddrMEM,
	 input RegWriteMEM,
	 
    output [31:0] RegDataMEM1,
	 output [4:0] RegAddrMEM1,
	 output RegWriteMEM1,
	 output [3:0] MemWrite,
	 output reg [31:0] MemData
);
	//type
	 wire [5:0] op;
	 wire [5:0] func;
	 wire [1:0] type;
    assign op = instrMEM[`op];
	 assign func = instrMEM[`func];
	 assign type = aluOutMEM[1:0];
	 //
	 reg [3:0] tmp;
	 initial begin tmp = 0; MemData = 0;end
	 assign MemWrite = tmp;
	 always@(*)begin
	    if(op == `sw_op)begin
				tmp = 4'b1111;
				MemData = rtdataMEM;
		 end
		 else if(op == `sh_op)begin
			 if(type[1] == 0)begin
					tmp = 4'b0011;
					MemData = rtdataMEM;
			 end
			 else if(type[1] == 1)begin
					tmp = 4'b1100;
					MemData = {rtdataMEM[15:0],{16{1'b0}}};
			end
		 end
		 else if(op == `sb_op)begin
			  if(type == 2'b00)begin
					tmp = 4'b0001;
					MemData = rtdataMEM;
			  end
			  else if(type == 2'b01)begin
					tmp = 4'b0010;
					MemData = {{16{1'b0}},rtdataMEM[7:0],{8{1'b0}}};
			  end
			  else if(type == 2'b10)begin
					tmp = 4'b0100;
					MemData = {{8{1'b0}},rtdataMEM[7:0],{16{1'b0}}};
			  end
			  else if(type == 2'b11)begin
					tmp = 4'b1000;
					MemData = {rtdataMEM[7:0],{24{1'b0}}};
			  end
		 end
		 else tmp = 0;
	 end
	 
	 //Á÷Ë®
	 wire [31:0] ans;
	 assign ans = (op == `lw_op)? dmOut :
		           (op == `lh_op && type[1] == 0)? {{16{dmOut[15]}},dmOut[15:0]} :
					  (op == `lh_op && type[1] == 1)? {{16{dmOut[31]}},dmOut[31:16]}:
					  (op == `lb_op && type == 2'b00)? {{24{dmOut[7]}},dmOut[7:0]}:
					  (op == `lb_op && type == 2'b01)? {{24{dmOut[15]}},dmOut[15:8]}:
					  (op == `lb_op && type == 2'b10)? {{24{dmOut[23]}},dmOut[23:16]}:
					  (op == `lb_op && type == 2'b11)? {{24{dmOut[31]}},dmOut[31:24]}:
					  0;
	 assign RegWriteMEM1 = (op == `lw_op || op == `lb_op || op == `lh_op)? 1 : RegWriteMEM;
	 assign RegAddrMEM1 = (op == `lw_op || op == `lb_op || op == `lh_op)? instrMEM[`rt] : RegAddrMEM;
	 assign RegDataMEM1 = (op == `lw_op || op == `lb_op || op == `lh_op)? ans : RegDataMEM;
endmodule