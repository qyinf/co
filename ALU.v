`include "define.v"
module ALU(
    input [31:0] instrE,
    input [31:0] rsdataE,
    input [31:0] rtdataE,
	 input [31:0] pcE,
	 input [4:0] ExcCodeE,
    output [31:0] aluOutE,
	 output reg [4:0] ExcCodeE1
);
	 //alu_type
	 wire [5:0] func;
    wire [5:0] op;
	 wire [5:0] alu_type;
	 assign op = instrE[`op];
	 assign func = instrE[`func];
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
	 assign slt = ($signed(rsdataE) < $signed(rtdataE))? 1 : 0;
	 assign sltu = (rsdataE < rtdataE)? 1 : 0;
    assign imm16 = instrE[`imm16];
	 assign imm26 = instrE[`imm26];
    assign zero_ext = {{16{1'b0}},imm16};
    assign sign_ext = {{16{imm16[15]}},imm16};
    assign imm32 = {imm16,{16{1'b0}}};
    assign aluOutE = (alu_type == `add)? rsdataE + rtdataE:
                     (alu_type == `sub)? rsdataE - rtdataE:
							(alu_type == `andd)? rsdataE & rtdataE:
							(alu_type == `orr)? rsdataE | rtdataE:
							(alu_type == `slt)? slt:
							(alu_type == `sltu)? sltu :
							//
                     (alu_type == `ori)? rsdataE | zero_ext:
							(alu_type == `lui)? imm32 :
							(alu_type == `andi)? rsdataE & zero_ext:
							(alu_type == `addi)? rsdataE + sign_ext:
							//
                     (alu_type == `sl)? rsdataE + sign_ext:
							(alu_type == `jalr)? rsdataE + 8:
							(alu_type == `jal)? pcE + 8:
							//
                     0;
							
	//ExcCodeE
	reg [32:0] tmp1;
	reg [32:0] tmp2;
	reg [32:0] tmpOut;
	initial begin tmp1 =0;tmp2=0;tmpOut=0;end
	wire getT;
	wire outRange;
	wire storeCnt;
	assign getT = (aluOutE >= `TC1_start && aluOutE <= `TC1_end) ||
					  (aluOutE >= `TC2_start && aluOutE <= `TC2_end);
	
	assign outRange = !((aluOutE >= `DM_start && aluOutE <= `DM_end) ||
					  (aluOutE >= `stall_start && aluOutE <= `stall_end) ||
					   getT == 1);
	assign storeCnt = (aluOutE >= `cnt1_start && aluOutE <= `cnt1_end) ||
						   (aluOutE >= `cnt2_start && aluOutE <= `cnt2_end);
	
	
	//
	initial begin ExcCodeE1 = ExcCodeE;end
	always@(*)begin
		if(op == 0 && func == `add_func)begin
			tmp1 = {rsdataE[31],rsdataE};
			tmp2 = {rtdataE[31],rtdataE};
			tmpOut = tmp1 + tmp2;
			if(tmpOut[32] != tmpOut[31])ExcCodeE1 = 12;
			else ExcCodeE1 = ExcCodeE;
		end
		else if(op == 0 && func == `sub_func)begin
			tmp1 = {rsdataE[31],rsdataE};
			tmp2 = {rtdataE[31],rtdataE};
			tmpOut = tmp1 - tmp2;
			if(tmpOut[32] != tmpOut[31])ExcCodeE1 = 12;
			else ExcCodeE1 = ExcCodeE;
		end
		else if(op == `addi_op)begin
			tmp1 = {rsdataE[31],rsdataE};
			tmp2 = {sign_ext[31],sign_ext};
			tmpOut = tmp1 + tmp2;
			if(tmpOut[32] != tmpOut[31])ExcCodeE1 = 12;
			else ExcCodeE1 = ExcCodeE;
		end
		else if(alu_type == `sl)begin
			tmp1 = {rsdataE[31],rsdataE};
			tmp2 = {sign_ext[31],sign_ext};
			tmpOut = tmp1 + tmp2;
			if(op == `lw_op || op == `lh_op || op == `lb_op)begin
				 if(tmpOut[32] != tmpOut[31])ExcCodeE1 = 4;
				 else if(outRange == 1)ExcCodeE1 = 4;
				 else if(op == `lw_op && (|aluOutE[1:0]) != 0)ExcCodeE1 = 4;
				 else if(op == `lh_op && aluOutE[0] != 0)ExcCodeE1 = 4;
				 else if((op == `lh_op || op == `lb_op) && getT == 1)ExcCodeE1 = 4;
				 //else if(aluOutE >= `s && aluOutE <= `e && pcE >= 32'h0000_3000 && pcE <= 32'h0000_417f) ExcCodeE1 = 4;
				 else ExcCodeE1 = ExcCodeE;
			end
			else begin
				if(tmpOut[32] != tmpOut[31])ExcCodeE1 = 5;
				else if(outRange == 1)ExcCodeE1 = 5;
				else if(op == `sw_op && (|aluOutE[1:0]) != 0)ExcCodeE1 = 5;
            else if(op == `sh_op && aluOutE[0] != 0)ExcCodeE1 = 5;
            else if((op == `sh_op || op == `sb_op) && getT == 1)ExcCodeE1 = 5;		
				else if(storeCnt == 1)ExcCodeE1 = 5;
				//else if(aluOutE >= `s && aluOutE <= `e && pcE >= 32'h0000_3000 && pcE <= 32'h0000_417f) ExcCodeE1 = 5;
				else ExcCodeE1 = ExcCodeE;
				//$display("tmp:%b",tmpOut);
				//$display("T:%d,pcE=%h,aluOutE:%h,ExcCode:%d",$time,pcE,aluOutE,ExcCodeE1);
			end
		end
		else ExcCodeE1 = ExcCodeE;
		//$display("tmp1=%b",tmp1);
		//$display("tmp2=%b",tmp2);
		//$display("tmpOut=%b",tmpOut);
		//$display("instrE = %b",instrE);
		//$display("PCE = %h,ExcCodeE1=%d",pcE,ExcCodeE1);
	end
	
	//Á÷Ë®
	
	always@(*)begin
	end
endmodule