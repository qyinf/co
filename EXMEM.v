`include "define.v"
module EXMEM(
    input clk,
    input reset,
    input [31:0] instrEX,
    input [31:0] aluOutEX,
    input [31:0] rtdataEX,
    input [31:0] pcEX,
	 input RegWriteEX,
	 input [4:0] RegAddrEX,
	 input [31:0] RegDataEX,

    output reg [31:0] instrMEM,
    output reg [31:0] aluOutMEM,
    output reg [31:0] rtdataMEM,
    output reg [31:0] pcMEM,
	 output reg RegWriteMEM,
	 output reg [4:0] RegAddrMEM,
	 output reg [31:0] RegDataMEM
);
    always@(posedge clk)begin
        if(reset)begin
            instrMEM <= 0;
            aluOutMEM <= 0;
            rtdataMEM <= 0;
            pcMEM <= 0;
				RegWriteMEM <= 0;
				RegAddrMEM <= 0;
				RegDataMEM <= 0;
        end
        else begin
            instrMEM <= instrEX;
            aluOutMEM <= aluOutEX;
            rtdataMEM <= rtdataEX;
            pcMEM <= pcEX;
				RegWriteMEM <= RegWriteEX;
				RegAddrMEM <= RegAddrEX;
				RegDataMEM <= RegDataEX;
        end
    end

endmodule