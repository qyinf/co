`include "define.v"
module DM(
    input clk,
    input reset,
	 input [31:0] instrMEM,
    input [31:0] rtdataMEM,
    input [31:0] aluOutMEM,
    input [31:0] pcMEM,
	 
	 input [31:0] RegDataMEM,
	 input [4:0] RegAddrMEM,
	 input RegWriteMEM,
    output [31:0] RegDataMEM1,
	 output [4:0] RegAddrMEM1,
	 output RegWriteMEM1
);
	//type
	 wire MemWrite;
	 wire [5:0] op;
	 wire [5:0] func;
    assign op = instrMEM[`op];
	 assign func = instrMEM[`func];
    assign MemWrite = (op == `sw_op)? 1 : 0;
	 
	 //init
    integer i;
    reg [31:0] mem [3073:0];
	 wire [31:0] addr;
	 assign addr = aluOutMEM >> 2;
 	 initial begin
        for(i = 0;i <= 3073;i = i + 1)mem[i] <= 0;
    end
    //load
	 wire[31:0] dmOut;
    assign dmOut = mem[addr] ;
    //save
    always@(posedge clk)begin
        if(reset)begin
            for(i = 0;i <= 3073; i = i + 1)begin
                mem[i] <= 0;
            end
        end
        else if(MemWrite)begin
            mem[addr] <= rtdataMEM;
            $display("%d@%h: *%h <= %h",$time,pcMEM, aluOutMEM, rtdataMEM);
        end
		  //$display("%d",rtdataMEM);
    end
	 
	 //Á÷Ë®
	 assign RegWriteMEM1 = (op == `lw_op)? 1 : RegWriteMEM;
	 assign RegAddrMEM1 = (op == `lw_op)? instrMEM[`rt] : RegAddrMEM;
	 assign RegDataMEM1 = (op == `lw_op)? dmOut : RegDataMEM;
endmodule