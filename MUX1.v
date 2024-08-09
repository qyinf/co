`include "define.v"
module MUX1(
    input RegWriteM,
    input [4:0] RegAddrM,
    input [31:0] RegDataM,
    input [31:0] instrM,
    input [31:0] lOut,
    input [31:0] cp0Out,
	 input [3:0] ExcCodeM,
	 input req,
    output RegWriteM1,
    output [4:0] RegAddrM1,
    output [31:0] RegDataM1 
);
    //info
    wire [5:0] op;
    wire [5:0] func;
    wire [4:0] rs;
    wire is_l;
    wire is_mfc0;
    assign op = instrM[`op];
    assign func = instrM[`func];
    assign rs = instrM[`rs];
    assign is_l = (op == `lw_op || op == `lh_op || op == `lb_op)? 1 : 0;
    assign is_mfc0 = (op == `wrong_op && rs == `mfc0_rs)? 1 : 0;
    //mux
    assign RegWriteM1 = (req == 1)? 0 :RegWriteM;
    assign RegAddrM1 = (is_l == 1)? instrM[`rt] :
                       (is_mfc0 == 1)? instrM[`rt] :
                       RegAddrM;
    assign RegDataM1 = (is_l == 1)? lOut :
                       (is_mfc0 == 1)? cp0Out :
                       RegDataM;
							  
	always@(*)begin
		//$display("l:%d",lOut);
		//$display("???");
	end
                       
endmodule