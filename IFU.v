`include "define.v"
module IFU(
    input [31:0] pc,
    output[5:0] func,
    output[4:0] shamt,
    output[4:0] rd,
    output[4:0] rt,
    output[4:0] rs,
    output[5:0] op,
    output[15:0] imm16,
    output[26:0] imm26,
    output[31:0] instr
);
    reg [31:0] mem [4097:0]; 
	 integer i;
	 initial begin
		  for(i = 0;i <=4097;i = i + 1)mem[i] = 0;
        $readmemh("./code.txt", mem);
    end  
    wire[31:0] instruction;
    assign instruction = mem[(pc-32'h0000_3000)>>2];
    assign func = instruction[5:0];
    assign shamt = instruction[10:6];
    assign rd = instruction[15:11];
    assign rt = instruction[20:16];
    assign rs = instruction[25:21];
    assign op = instruction[31:26];
    assign imm26 = instruction[25:0];
    assign imm16 = instruction[15:0];
    assign instr = instruction;
endmodule