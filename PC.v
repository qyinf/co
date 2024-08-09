`include "define.v"
module PC(
    input clk,
    input reset,
    input en,
    input [31:0] npc,
    output reg [31:0] pcIF
);
	initial begin
		pcIF = 32'h0000_3000;
	end
    always@(posedge clk)begin
        if(reset)begin
            pcIF <= 32'h0000_3000;
        end 
        else if(en)begin
            pcIF <= npc;
        end
		  //$display("???");
    end
endmodule