`include "define.v"
module GRF(
    input clk,
    input reset,
	 input RegWrite,
	 input [4:0] RegAddr,
	 input [31:0] RegData,
    input [31:0] instrD,
    output [31:0] rsdataD,
    output [31:0] rtdataD
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
    assign rs = instrD[`rs];
    assign rt = instrD[`rt];
    assign rsdataD = (rs == RegAddr && RegWrite && RegAddr != 0)? RegData :regs[rs];
    assign rtdataD = (rt == RegAddr && RegWrite && RegAddr != 0)? RegData :regs[rt];

    
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
				end
        end
    end
endmodule