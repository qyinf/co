`include "define.v"
module IFID(
    input clk,
    input reset,
    input en,
	 input req,
	 input eretD,
    input [31:0] instrF,
    input [31:0] pcF,
	 input [4:0] ExcCodeF,
	 input bdF,
	 input [31:0] npc,
    output reg [31:0] instrD,
    output reg [31:0] pcD,
	 output reg [4:0] ExcCodeD,
	 output reg bdD,
	 output reg validD
);
    always@(posedge clk)begin
        if(reset || req || (eretD == 1 && en == 1))begin
            instrD <= 0;
            pcD <= 0;
				ExcCodeD <= 0;
				bdD <= 0;
				validD <= 0;
        end
        else if(en)begin
            instrD <= instrF;
            pcD <= pcF;
				ExcCodeD <= ExcCodeF;
				bdD <= bdF;
				validD <= 1;
        end
    end
endmodule