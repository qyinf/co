`include "define.v"
module ALU(
    input [31:0] instrEX,
    input [31:0] rsdataEX,
    input [31:0] rtdataEX,
	 input [31:0] pcEX,
	 input [31:0] ldata,
	 input [31:0] hdata,
    output [31:0] aluOutEX,
	 output RegWrite,
	 output [31:0] RegData,
	 output [4:0] RegAddr
);
	 //alu_type
	 wire [5:0] func;
    wire [5:0] op;
	 wire [5:0] alu_type;
	 assign op = instrEX[`op];
	 assign func = instrEX[`func];
    assign alu_type = (op == 0 && func == `add_func)? `add:
                      (op == 0 && func == `sub_func)? `sub:
							 (op == 0 && func == `and_func)? `andd:
							 (op == 0 && func == `or_func)? `orr:
							 (op == 0 && func == `slt_func)? `slt:
							 (op == 0 && func == `sltu_func)? `sltu:
							 //
                      (op == `ori_op)? `ori:
							 (op == `lui_op)? `lui:
							 (op == `andi_op)? `andi:
							 (op == `addi_op)? `addi:
                      (op == `lw_op || op == `lb_op || op == `lh_op)? `sl:
                      (op == `sw_op || op == `sb_op || op == `sh_op)? `sl:
							 (op == `jal_op)? `jal:
							 (func == `jalr_func)? `jalr:
                      0;
							 
    //alu
    wire [15:0] imm16;
	 wire [25:0] imm26;
    wire [31:0] zero_ext;
    wire [31:0] sign_ext;
    wire [31:0] alu1;
    wire [31:0] alu2;
	 wire [31:0] imm32;
	 wire slt;
	 wire sltu;
	 assign slt = ($signed(rsdataEX) < $signed(rtdataEX))? 1 : 0;
	 assign sltu = (rsdataEX < rtdataEX)? 1 : 0;
    assign imm16 = instrEX[`imm16];
	 assign imm26 = instrEX[`imm26];
    assign zero_ext = {{16{1'b0}},imm16};
    assign sign_ext = {{16{imm16[15]}},imm16};
    assign imm32 = {imm16,{16{1'b0}}};
    assign aluOutEX = (alu_type == `add)? rsdataEX + rtdataEX:
                     (alu_type == `sub)? rsdataEX - rtdataEX:
							(alu_type == `andd)? rsdataEX & rtdataEX:
							(alu_type == `orr)? rsdataEX | rtdataEX:
							(alu_type == `slt)? slt:
							(alu_type == `sltu)? sltu :
							//
                     (alu_type == `ori)? rsdataEX | zero_ext:
							(alu_type == `lui)? imm32 :
							(alu_type == `andi)? rsdataEX & zero_ext:
							(alu_type == `addi)? rsdataEX + sign_ext:
							//
                     (alu_type == `sl)? rsdataEX + sign_ext:
							(alu_type == `jalr)? rsdataEX + 8:
							(alu_type == `jal)? pcEX + 8:
							//
                     0;
	
	//流水
	assign RegWrite = (op == 0 &&(
							func == `add_func || func == `and_func || func == `sub_func ||
							func == `or_func || func == `slt_func || func == `sltu_func ||
							func == `mflo_func || func == `mfhi_func))? 1 :
							
							(op == `ori_op || op == `lui_op || op == `jal_op ||
							 op == `andi_op || op == `addi_op)? 1 :
							 
							(op == `lw_op || op == `lb_op || op == `lh_op)? 1 ://要写，但还没开始写
							0;
	assign RegData = (op == 0 && func == `mflo_func)? ldata :
						  (op == 0 && func == `mfhi_func)? hdata :
						  (alu_type != 0)? aluOutEX :
						  0;
						  
	assign RegAddr = (op == 0 &&(
							func == `add_func || func == `and_func || func == `sub_func ||
							func == `or_func || func == `slt_func || func == `sltu_func ||
							func == `mflo_func || func == `mfhi_func))? instrEX[`rd] :
							
						  (op == `ori_op || op == `lui_op || op == `andi_op || op == `addi_op)? instrEX[`rt] :
						  (op == `jal_op)? 31 :
						  (op == `lw_op || op == `lb_op || op == `lh_op)? instrEX[`rt] :
						  0;
	
	always@(*)begin
	end
endmodule