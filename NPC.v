`include "define.v"
module NPC( 
    input[31:0] rsdata,
    input[31:0] rtdata,
    input[31:0] pc,
    input[15:0] imm16,
    input[25:0] imm26,
	 input [5:0] func,
	 input [5:0] op,
    output reg [31:0] npc
);
	//pc4
	wire [31:0] pc4;
	assign pc4 = pc + 4;
	
	//jump_type
	wire [2:0] jump_type;
	assign jump_type = (op == `beq_op)? `beqt:
                       (op == `jal_op)? `jalt:
                       (op == 0 && func == `jr_func)? `jrt:
                       0;
	//npc
    wire beq;
    wire [31:0] ext_imm16;
	 wire [31:0] ext_imm26;
	 assign ext_imm16 = {{14{imm16[15]}},imm16,{2{1'b0}}};
	 assign ext_imm26 = {pc[31:28],imm26,{2{1'b0}}};
    assign beq = (rsdata == rtdata)? 1 : 0;
    always@(*)begin
        if(jump_type == `beqt)begin
            if(beq == 1)begin
					npc = pc4 + ext_imm16;
				end
            else npc = pc4;
        end
        else if(jump_type == `jalt)begin
            npc = ext_imm26;
        end
        else if(jump_type == `jrt)begin
            npc = rsdata;
        end
        else npc = pc4;
		 //$display("rsdata=%h,",rsdata);
    end
endmodule 