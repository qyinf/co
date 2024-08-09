`include "define.v"
module IDEX(
    input clk,
    input reset,
    input flush,
	 input req,
    input [31:0] instrD,
    input [31:0] rsdataD,
    input [31:0] rtdataD,
    input [31:0] pcD,
	 input [4:0] ExcCodeD,
	 input bdD,
	 input validD,

    output reg [31:0] instrE,
    output reg [31:0] rsdataE,
    output reg [31:0] rtdataE,
    output reg [31:0] pcE,
	 output reg [4:0] ExcCodeE,
	 output reg bdE,
	 output reg validE
);
    always@(posedge clk)begin
        if(reset == 1 || flush === 1 || req)begin
            instrE <= 0;
            rsdataE <= 0;
            rtdataE <= 0;
            pcE <= 0;
				ExcCodeE <= 0;
				bdE <= (flush == 1)? bdD : 0;
				validE <= 0;
        end
        else begin
            instrE <= instrD;
            rsdataE <= rsdataD;
            rtdataE <= rtdataD;
            pcE <= pcD;
				ExcCodeE <= ExcCodeD;
				bdE <= bdD;
				validE <= validD;
        end
    end
endmodule