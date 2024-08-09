`include "define.v"
module MUX0(
    input [31:0] instrE,
    input [31:0] aluOutE,
    input [31:0] ldata,
    input [31:0] hdata,
	 input req,
    output RegWriteE,
    output [4:0] RegAddrE,
    output [31:0] RegDataE
);
    wire [5:0] op;
    wire [5:0] func;
	 wire [4:0] rs;
    assign op = instrE[`op];
    assign func = instrE[`func];
	 assign rs = instrE[`rs];
    assign RegWriteE = (req == 1)? 0 : 
						(op == 0 &&(
					  func == `add_func || func == `and_func || func == `sub_func ||
					  func == `or_func || func == `slt_func || func == `sltu_func ||
					  func == `mflo_func || func == `mfhi_func))? 1 :
							
					  (op == `ori_op || op == `lui_op || op == `jal_op ||
					   op == `andi_op || op == `addi_op)? 1 :
							 
					  (op == `lw_op || op == `lb_op || op == `lh_op)? 1 ://
					  
					  (op == `wrong_op && rs == `mfc0_rs)? 1 :
					   0;
							
	assign RegDataE = (op == 0 && func == `mflo_func)? ldata :
					 (op == 0 && func == `mfhi_func)? hdata :
					  aluOutE ;

	assign RegAddrE = (op == 0 &&(
					 func == `add_func || func == `and_func || func == `sub_func ||
					 func == `or_func || func == `slt_func || func == `sltu_func ||
					 func == `mflo_func || func == `mfhi_func))? instrE[`rd] :
							
					 (op == `ori_op || op == `lui_op || op == `andi_op || op == `addi_op)? instrE[`rt] :
					 (op == `jal_op)? 31 :
					 (op == `lw_op || op == `lb_op || op == `lh_op)? instrE[`rt] :
					 (op == `wrong_op && rs == `mfc0_rs)? instrE[`rt] :
					 0;
endmodule