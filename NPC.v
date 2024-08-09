`include "define.v"
module NPC(
    input [31:0] pcF,
	 input [31:0] pcD,
	 input [31:0] instrD,
    input [31:0] rsdataD,
    input [31:0] rtdataD,
	 input [31:0] EPC,
	 input eretD,
    output reg [31:0] npc
); 
	
	//info
    wire [5:0] func;
    wire [5:0] op;
    wire [15:0] imm16;
    wire [25:0] imm26;
    
    assign func = instrD[`func];
    assign op = instrD[`op];
    assign imm16 = instrD[`imm16];
    assign imm26 = instrD[`imm26];
    
	 
	 //calculate
	 wire [31:0] ext_imm16;
    wire [31:0] ext_imm26;
    wire beq;
	 wire bne;
	 assign ext_imm16 = {{14{imm16[15]}},imm16,{2{1'b0}}};
    assign ext_imm26 = {{pcD[31:28]},imm26,{2{1'b0}}};
    assign beq = (rsdataD == rtdataD)? 1 : 0;
	 assign bne = (rsdataD != rtdataD)? 1 : 0;

	 //mux
	 wire [4:0] jump_type;
    assign jump_type = (op == `beq_op)? `beqt:
	                    (op == `bne_op)? `bnet:
                       (op == `jal_op)? `jalt:
                       (op == 0 && func == `jr_func)? `jrt:
						     (op == `j_op)? `jt :
						     (op == 0 && func == `jalr_func)? `jalrt :
                        0;
    
    always@(*)begin
        if(jump_type == `beqt)begin
            if(beq == 1) npc = pcD + 4 + ext_imm16;
            else npc = pcF + 4;
        end
		  else if(jump_type == `bnet)begin
				if(bne == 1) npc = pcD + 4 + ext_imm16;
				else npc = pcF + 4;
		  end
        else if(jump_type == `jalt || jump_type == `jt) npc = ext_imm26;
        else if(jump_type == `jrt || jump_type == `jalrt) npc = rsdataD;
		  else if(eretD == 1)npc = EPC;
        else npc = pcF + 4;
    end
endmodule 