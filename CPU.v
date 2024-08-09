`include "define.v"
module mips(
    input clk,
    input reset
);
	 //pc
    wire[31:0] npc;
    wire[31:0] pc;
	 
	 //F
    wire[5:0] func;
    wire[5:0] op;
    wire[2:0] jump_type;
    wire[4:0] rd;
    wire[4:0] rt;
    wire[4:0] rs;
    wire[4:0] shamt;
    wire[25:0] imm26;
    wire[15:0] imm16;
    wire[31:0] instr;
	 
	 //D
	 wire[31:0] rsdata;
	 wire[31:0] rtdata;
	 
	 //W
    wire[31:0] alu_out;
	 
	 //M
	 wire[31:0] dm_out;
	 
	 //DEBUG
	 wire[32*8-1:0] string;

PC pc_module(
    .clk(clk),
    .reset(reset),
    .npc(npc),
    .pc(pc)
);

NPC npc_module(
	 .func(func),
	 .op(op),
	 //
    .rsdata(rsdata),
    .rtdata(rtdata),
	 //
    .imm16(imm16),
    .imm26(imm26),
    .pc(pc),
	 //output
    .npc(npc)
);

IFU ifu_module(
    .pc(pc),
	 //output
    .func(func),
    .op(op),
    .shamt(shamt),
    .rd(rd),
    .rt(rt),
    .rs(rs),
    .imm26(imm26),
    .imm16(imm16),
    .instr(instr)
);


GRF grf_module(
	 .clk(clk),
    .reset(reset),
	 //write
	 .instr(instr),
	 .op(op),
	 .func(func),
	 .pc(pc),
	 .rd(rd),
	 .alu_out(alu_out),
	 .dm_out(dm_out),
	 //output
	 .rs(rs),
    .rt(rt),
    .rsdata(rsdata),
    .rtdata(rtdata)
);

ALU alu_module(
	 .func(func),
	 .op(op),
    .imm16(imm16),
    .rsdata(rsdata),
    .rtdata(rtdata),
	 //output
	 .alu_out(alu_out)
);


DM dm_module(
    .clk(clk),
	 .reset(reset),
	 //write
	 .op(op),
	 .func(func),
    .pc(pc),
    .alu_out(alu_out),
    .rtdata(rtdata),
	 //output
    .dm_out(dm_out)
);

LOGGER logger(
	.pc(pc),
	.instr(instr),
	.reg_name(0),
	.imm_as_dec(1),
	.asm(string)
);

	always @(*) begin
		//$display("rs = %d,rsdata = %h",rs,rsdata);
		//$display("%s", string);
	end
endmodule