`include "define.v"
module EXMEM(
    input clk,
    input reset,
	 input req,
    input [31:0] instrE,
    input [31:0] aluOutE,
    input [31:0] rtdataE,
    input [31:0] pcE,
	 input RegWriteE,
	 input [4:0] RegAddrE,
	 input [31:0] RegDataE,
	 input [4:0] ExcCodeE,
	 input bdE,
	 input validE,

    output reg [31:0] instrM,
    output reg [31:0] aluOutM,
    output reg [31:0] rtdataM,
    output reg [31:0] pcM,
	 output reg RegWriteM,
	 output reg [4:0] RegAddrM,
	 output reg [31:0] RegDataM,
	 output reg [4:0] ExcCodeM,
	 output reg bdM,
	 output reg validM
);
    always@(posedge clk)begin
        if(reset || (req == 1))begin
            instrM <= 0;
            aluOutM <= 0;
            rtdataM <= 0;
            pcM <= 0;
				RegWriteM <= 0;
				RegAddrM <= 0;
				RegDataM <= 0;
				ExcCodeM <= 0;
				bdM <= 0;
				validM <= 0;
        end
        else begin
            instrM <= instrE;
            aluOutM <= aluOutE;
            rtdataM <= rtdataE;
            pcM <= pcE;
				RegWriteM <= RegWriteE;
				RegAddrM <= RegAddrE;
				RegDataM <= RegDataE;
				ExcCodeM <= ExcCodeE;
				bdM <= bdE;
				validM <= validE;
        end
    end

endmodule