`include "define.v"
module GRF(
    input clk,
    input reset,
	 input RegWrite,
	 input [4:0] RegAddr,
	 input [31:0] RegData,
    input [31:0] pcWB,
    input [31:0] instrWB,
    input [31:0] instrID,
    output [31:0] rsdataID,
    output [31:0] rtdataID
);
	//init
   reg [31:0] regs[31:0];
	integer i;
	initial begin
        for(i = 0;i <= 31;i = i + 1)regs[i] <= 0;
    end

	 //read
    wire [4:0] rs;
    wire [4:0] rt;
    assign rs = instrID[`rs];
    assign rt = instrID[`rt];
    assign rsdataID = (rs == RegAddr && RegWrite && RegAddr != 0)? RegData :regs[rs];
    assign rtdataID = (rt == RegAddr && RegWrite && RegAddr != 0)? RegData :regs[rt];

    
	 //write
    always@(posedge clk)begin
        if(reset)begin
            for(i = 0;i <= 31;i = i + 1)begin
                regs[i] <= 0;
            end
        end
        else if(RegWrite)begin
            if(RegAddr)begin
					regs[RegAddr] <= RegData;
					$display("%d@%h: $%d <= %h",$time, pcWB, RegAddr, RegData);
				end
        end
		  //$display("%d",RegWrite);
    end
endmodule