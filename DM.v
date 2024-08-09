`include "define.v"
module DM(
    input clk,
    input reset,
	 input [5:0] op,
	 input [5:0] func,
    input [31:0] rtdata,
    input [31:0] alu_out,
    input [31:0] pc,
    output [31:0] dm_out
);
	 //init
    integer i;
    reg [31:0] mem [3073:0];
 	 initial begin
        for(i = 0;i <= 3073;i = i + 1)mem[i] <= 0;
    end
	 
	 
	 //read
    assign dm_out = (op == `lw_op)? mem[addr] : 0 ;
    
	 
	 //write
	 wire MemWrite;
	 wire [31:0] addr;
	 assign addr = alu_out >> 2;
	 assign MemWrite = (op == `sw_op)? 1 : 0;
    always@(posedge clk)begin
        if(reset)begin
            for(i = 0;i <= 3073; i = i + 1)begin
                mem[i] <= 0;
            end
        end
        else if(MemWrite)begin
            mem[addr] <= rtdata;
            $display("@%h: *%h <= %h", pc, alu_out, rtdata);
        end
    end
endmodule