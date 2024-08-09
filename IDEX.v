module IDEX(
    input clk,
    input reset,
    input flush,
    input [31:0] instrID,
    input [31:0] rsdataID,
    input [31:0] rtdataID,
    input [31:0] pcID,

    output reg [31:0] instrEX,
    output reg [31:0] rsdataEX,
    output reg [31:0] rtdataEX,
    output reg [31:0] pcEX 
);
    always@(posedge clk)begin
        if(reset == 1 || flush == 1)begin
            instrEX <= 0;
            rsdataEX <= 0;
            rtdataEX <= 0;
            pcEX <= 0;
        end
        else begin
            instrEX <= instrID;
            rsdataEX <= rsdataID;
            rtdataEX <= rtdataID;
            pcEX <= pcID;
        end
    end
endmodule