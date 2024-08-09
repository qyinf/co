`include "define.v"
module NPC(
    input [31:0] pcIF,
	 input [31:0] pcID,
	 input [31:0] instrID,
    input [31:0] rsdataID,
    input [31:0] rtdataID,
    output reg [31:0] npc
);   
    wire [4:0] jump_type;
    wire [5:0] func;
    wire [5:0] op;
    wire [15:0] imm16;
    wire [25:0] imm26;
    wire [31:0] ext_imm16;
    wire [31:0] ext_imm26;
    wire [31:0] pc4;
    wire beq;
    
    assign func = instrID[`func];
    assign op = instrID[`op];
    assign imm16 = instrID[`imm16];
    assign imm26 = instrID[`imm26];
    assign ext_imm16 = {{14{imm16[15]}},imm16,{2{1'b0}}};
    assign ext_imm26 = {{pcID[31:28]},imm26,{2{1'b0}}};
    assign beq = (rsdataID == rtdataID)? 1 : 0;

    assign jump_type = (op == `beq_op)? `beqt:
                   (op == `jal_op)? `jalt:
                   (op == 0 && func == `jr_func)? `jrt:
						 (op == `j_op)? `jt :
						 (op == 0 && func == `jalr_func)? `jalrt :
                   0;
    
    always@(*)begin
        if(jump_type == `beqt)begin
            if(beq == 1)begin
					npc = pcID + 4 + ext_imm16;
				end
            else npc = pcIF+4;
        end
        else if(jump_type == `jalt || jump_type == `jt)begin
            npc = ext_imm26;
        end
        else if(jump_type == `jrt || jump_type == `jalrt)begin
            npc = rsdataID;
        end
        else npc = pcIF+4;
		  //$display("op:%b",op);
    end
endmodule 