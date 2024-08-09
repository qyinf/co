`include "define.v"
module DM(
    input clk,
    input reset,
	 input [31:0] instrM,
	 input [31:0] load_data,
	 input [31:0] aluOutM,
	 
	 output [3:0] MemWrite,
	 output [31:0] lOut
);
	//info
	 wire [5:0] op;
	 wire [4:0] rs;
	 wire [5:0] func;
	 wire [1:0] type;
    assign op = instrM[`op];
	 assign rs = instrM[`rs];
	 assign func = instrM[`func];
	 assign type = aluOutM[1:0];
	 
	 //store
	 reg [3:0] tmp;
	 initial begin tmp = 0;end
	 assign MemWrite = tmp;
	 always@(*)begin
	    if(op == `sw_op)tmp = 4'b1111;
		 else if(op == `sh_op)begin
		      if(type[1] == 0)tmp = 4'b0011;
			   else if(type[1] == 1)tmp = 4'b1100;
				else tmp = 4'b0000;
		 end
		 else if(op == `sb_op)begin
			   if(type == 2'b00)tmp = 4'b0001;
			   else if(type == 2'b01)tmp = 4'b0010;
			   else if(type == 2'b10)tmp = 4'b0100;
			   else if(type == 2'b11)tmp = 4'b1000;
				else tmp = 4'b0000;
		 end
		 else tmp = 0;
	 end
	 
	 //load
	 assign lOut = (op == `lw_op)? load_data :
		           (op == `lh_op && type[1] == 0)? {{16{load_data[15]}},load_data[15:0]} :
					  (op == `lh_op && type[1] == 1)? {{16{load_data[31]}},load_data[31:16]}:
					  (op == `lb_op && type == 2'b00)? {{24{load_data[7]}},load_data[7:0]}:
					  (op == `lb_op && type == 2'b01)? {{24{load_data[15]}},load_data[15:8]}:
					  (op == `lb_op && type == 2'b10)? {{24{load_data[23]}},load_data[23:16]}:
					  (op == `lb_op && type == 2'b11)? {{24{load_data[31]}},load_data[31:24]}:
					  0;
endmodule