`include "define.v"
module PC(
    input clk,
    input reset,
    input en,
	 input req,
	 input eretD,
    input [31:0] npc,
    output reg [31:0] pcF
);
	initial begin
		pcF = 32'h0000_3000;
	end
    always@(posedge clk)begin
        if(reset)pcF <= 32'h0000_3000;
		  else if(req == 1)pcF <= `exception;
        else if(en == 1)pcF <= npc;
		  //$display("en=%d,npc=%h",en,npc);
    end
endmodule