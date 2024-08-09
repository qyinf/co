`include"define.v"
module MEMWB(
    input clk,
	 input reset,
    input [31:0] instrMEM,
    input [31:0] pcMEM,
	 input RegWriteMEM,
	 input [4:0] RegAddrMEM,
	 input [31:0] RegDataMEM,

    output reg [31:0] instrWB,
    output reg [31:0] pcWB,
	 output reg RegWriteWB,
	 output reg [4:0] RegAddrWB,
	 output reg [31:0] RegDataWB
);
    always@(posedge clk)begin
        if(reset)begin
            instrWB <= 0;
            pcWB <= 0;
				RegWriteWB <= 0;
				RegAddrWB <= 0;
				RegDataWB <= 0;
        end
        else begin
            instrWB <= instrMEM;
            pcWB <= pcMEM;
				RegWriteWB <= RegWriteMEM;
				RegAddrWB <= RegAddrMEM;
				RegDataWB <= RegDataMEM;
        end
    end
endmodule