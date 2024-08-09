`include "define.v"
module IFU(
    input [31:0] pcIF,
    output[31:0] instrIF
);
    reg [31:0] mem [4097:0]; 
	integer i;
	initial begin
		for(i = 0;i <= 4097;i = i + 1)mem[i] = 0;
        $readmemh("./code.txt", mem);
    end  
    assign instrIF = mem[(pcIF-32'h0000_3000)>>2];
	 always@(*)begin
		//$display("%h",instrIF);
		end
endmodule