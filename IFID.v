module IFID(
    input clk,
    input reset,
    input en,
    input [31:0] instrIF,
    input [31:0] pcIF,
    output reg [31:0] instrID,
    output reg [31:0] pcID
);
    always@(posedge clk)begin
        if(reset)begin
            instrID <= 0;
            pcID <= 0;
        end
        else if(en)begin
            instrID <= instrIF;
            pcID <= pcIF;
        end
    end
endmodule