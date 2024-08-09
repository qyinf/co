`include "define.v"
module GRF(
    input reset,
    input clk,
	 input [5:0] func,
	 input [5:0] op,
	 input [4:0] rd,
    input [4:0] rs,
    input [4:0] rt,
    input [31:0] pc,
	 input [31:0] alu_out,
    input [31:0] dm_out,
	 input [31:0] instr,
    output [31:0] rsdata,
    output [31:0] rtdata
);
	//init
    reg [31:0] regs[31:0];
	 integer i;
	 initial begin
        for(i = 0;i <= 31;i = i + 1)regs[i] <= 0;
    end
	 //read
	 assign rsdata = regs[rs];
    assign rtdata = regs[rt];
	 //write
	 wire RegWrite;
	 wire [4:0] RegAddr;
	 wire [31:0] RegData;
	 assign RegWrite = (instr == 0)? 0 ://nop
							 (op == 0 && func != `jr_func)? 1 ://r
							 (op == `ori_op || op == `lui_op)? 1 ://i
							 (op == `lw_op)? 1 ://load
							 (op == `jal_op)? 1 ://jal
							 0;
	 assign RegData = (instr == 0)? 0 ://nop
							(op == `lw_op)? dm_out : //load
							(op == `jal_op)? pc + 4 ://jal
							alu_out ;
	 assign RegAddr = (instr == 0)? 0 :
							(op == `lw_op)? rt :
							(op == `jal_op)? 31 :
							(op == `ori_op || op == `lui_op)? rt :
							(op == 0 && func !=`jr_func)? rd :
							0;
	
    always@(posedge clk)begin
        if(reset)begin
            for(i = 0;i <= 31;i = i + 1)begin
                regs[i] <= 0;
            end
        end
        else if(RegWrite)begin
            if(RegAddr)begin
					regs[RegAddr] <= RegData;
					$display("@%h: $%d <= %h",pc, RegAddr, RegData);
				end
        end
    end
endmodule