`include"define.v"
module MEMWB(
    input clk,
	 input reset,
	 input req,
    input [31:0] instrM,
    input [31:0] pcM,
	 input RegWriteM,
	 input [4:0] RegAddrM,
	 input [31:0] RegDataM,

    output reg [31:0] instrW,
    output reg [31:0] pcW,
	 output reg RegWriteW,
	 output reg [4:0] RegAddrW,
	 output reg [31:0] RegDataW
);
    always@(posedge clk)begin
        if(reset || req)begin
            instrW <= 0;
            pcW <= 0;
				RegWriteW <= 0;
				RegAddrW <= 0;
				RegDataW <= 0;
        end
        else begin
            instrW <= instrM;
            pcW <= pcM;
				RegWriteW <= RegWriteM;
				RegAddrW <= RegAddrM;
				RegDataW <= RegDataM;
        end
    end
endmodule