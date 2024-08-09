`include "define.v"
module ALU(
	 input [5:0] func,
	 input [5:0] op,
    input [31:0] rsdata,
    input [31:0] rtdata,
    input [15:0] imm16,
    output [31:0] alu_out
);
	 //alu_type
	 wire [3:0] alu_type;
	 assign alu_type = (op == 0 && func == `add_func)? `add:
                      (op == 0 && func == `sub_func)? `sub:
                      (op == `ori_op)? `ori:
                      (op == `lw_op)? `sl:
                      (op == `sw_op)? `sl:
                      (op == `lui_op)? `lui:
                      0;
	 //alu
    wire[31:0] zero_ext = {{16{1'b0}},imm16};
    wire[31:0] sign_ext = {{16{imm16[15]}},imm16};
    wire[31:0] imm32 = {imm16,{16{1'b0}}};
    assign alu_out = (alu_type == `add)? rsdata + rtdata:
                     (alu_type == `sub)? rsdata - rtdata:
                     (alu_type == `ori)? rsdata | zero_ext:
                     (alu_type == `sl)? rsdata + sign_ext:
                     (alu_type == `lui)? imm32 :
                     8'hffffffff;
	 //always@(*)begin
			//$display("rsdata=%d, rtdata=%d, zero_ext=%d, sign_ext=%d, alu_type=%d, alu_out=%d",
			//rsdata,
			//rtdata,
			//zero_ext,
			//sign_ext,
			//alu_type,
			//alu_out);
	 //end
endmodule