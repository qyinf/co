`include "define.v"
module mips(
    input clk,
    input reset
);
//F
wire [31:0] pcIF;
wire [31:0] npc;
wire [31:0] instrIF;


//D
//和转发有关的数据
wire [4:0] rsD;
wire [4:0] rtD;
wire [31:0] rsdataID;
wire [31:0] rtdataID;
wire [31:0] forward_rsdataID;
wire [31:0] forward_rtdataID;
//流水下去的数据
wire [31:0] instrID;
wire [31:0] pcID; 

//E
//和转发有关的数据
wire [4:0] rsE;
wire [4:0] rtE;
wire [31:0] rsdataEX;
wire [31:0] rtdataEX;
wire [31:0] forward_rsdataEX;
wire [31:0] forward_rtdataEX;
//要流水下去的数据
wire [31:0] instrEX;
wire [31:0] pcEX;
wire [31:0] RegDataEX;
wire [4:0] RegAddrEX;
wire RegWriteEX;
wire [31:0] aluOutEX;

//M
//和转发有关的数据
wire [4:0] rtM;
wire [31:0] rtdataMEM;
wire [31:0] forward_rtdataMEM;
//要流水下去的数据
wire [31:0] instrMEM;
wire [31:0] pcMEM;
wire [31:0] RegDataMEM;
wire [4:0] RegAddrMEM;
wire RegWriteMEM;
//这里算是一个mux吧
wire [31:0] RegDataMEM1;
wire [4:0]RegAddrMEM1;
wire RegWriteMEM1;
//出bug辽
wire [31:0] aluOutMEM;

//W
wire [31:0] instrWB;
wire [31:0] pcWB;
wire [31:0] RegDataWB;
wire [4:0] RegAddrWB;
wire RegWriteWB;

wire[32*8-1:0] string;

//control
wire [1:0] rs_tuse;
wire [1:0] rt_tuse;
wire [1:0] tnewE;
wire [1:0] tnewM;
wire [1:0] tnewW;
//stall
wire stall;
assign rsD = instrID[`rs];
assign rtD = instrID[`rt];
assign rsE = instrEX[`rs];
assign rtE = instrEX[`rt];
assign rtM = instrMEM[`rt];
assign stall = (rs_tuse < tnewE && rsD == RegAddrEX && RegAddrEX != 0 && RegWriteEX)? 1 :
					(rs_tuse < tnewM && rsD == RegAddrMEM && RegAddrMEM != 0 && RegWriteMEM)? 1 :
					(rt_tuse < tnewE && rtD == RegAddrEX && RegAddrEX != 0 && RegWriteEX)? 1 :
					(rt_tuse < tnewM && rtD == RegAddrMEM && RegAddrMEM != 0 && RegWriteMEM)? 1 :
					0;
//forward
assign forward_rsdataID = (rsD == RegAddrMEM && RegAddrMEM != 0 && RegWriteMEM == 1)? RegDataMEM :
								  (rsD == RegAddrWB && RegAddrWB != 0 && RegWriteWB == 1)? RegDataWB :
								  rsdataID;
assign forward_rtdataID = (rtD == RegAddrMEM && RegAddrMEM != 0 && RegWriteMEM == 1)? RegDataMEM :
								  (rtD == RegAddrWB && RegAddrWB != 0 && RegWriteWB == 1)? RegDataWB :
								  rtdataID;


assign forward_rsdataEX = (rsE == RegAddrMEM && RegAddrMEM != 0 && RegWriteMEM == 1)? RegDataMEM :
								  (rsE == RegAddrWB && RegAddrWB != 0 && RegWriteWB == 1)? RegDataWB :
								  rsdataEX;

assign forward_rtdataEX = (rtE == RegAddrMEM && RegAddrMEM != 0 && RegWriteMEM == 1)? RegDataMEM :
								  (rtE == RegAddrWB && RegAddrWB != 0 && RegWriteWB == 1)? RegDataWB :
								  rtdataEX;//有bug

assign forward_rtdataMEM = (rtM == RegAddrWB && RegAddrWB != 0 && RegWriteWB == 1)? RegDataWB :
									rtdataMEM ;
								 								 

always@(*)begin
	//$display("rsE:%d,RegAddrWB:%d",rsE);
end
PC pc_module(
    .clk(clk),
    .reset(reset),
    .en(!stall),
    .npc(npc),
    .pcIF(pcIF)
);

IFU ifu_module(
    .pcIF(pcIF),
    .instrIF(instrIF)
);

NPC npc_module(
	  //input
    .instrID(instrID),
    .rsdataID(forward_rsdataID),
    .rtdataID(forward_rtdataID),
    .pcIF(pcIF),
	 .pcID(pcID),
	 //output
    .npc(npc)
);

IFID ifid_module(
    //input
    .clk(clk),
    .reset(reset),
    .en(!stall),
    .instrIF(instrIF),
    .pcIF(pcIF),
	 //output
    .instrID(instrID),
    .pcID(pcID)
);


GRF grf_module(
	 //input
    .clk(clk),
    .reset(reset),
	 //write
	 .instrWB(instrWB),
	 .pcWB(pcWB),
    .RegWrite(RegWriteWB),
    .RegData(RegDataWB),
    .RegAddr(RegAddrWB),
	 //read
    .instrID(instrID),
	 //output
    .rsdataID(rsdataID),
    .rtdataID(rtdataID)
);

IDEX idex_module(
    //input
    .clk(clk),
    .reset(reset),
	 .flush(stall),
    
	 .instrID(instrID),
    .rsdataID(forward_rsdataID),
    .rtdataID(forward_rtdataID),//为了解决jalr的通路
    .pcID(pcID),
    
    //output
	 .instrEX(instrEX),
    .rsdataEX(rsdataEX),
    .rtdataEX(rtdataEX),
    .pcEX(pcEX)
);

ALU alu_module(
	 //input
    .instrEX(instrEX),
	 .pcEX(pcEX),
    .rsdataEX(forward_rsdataEX),
    .rtdataEX(forward_rtdataEX),
	 //output
	 .RegData(RegDataEX),
	 .RegAddr(RegAddrEX),
	 .RegWrite(RegWriteEX),
	 .aluOutEX(aluOutEX)
);

EXMEM exmem_module(
	 //input
    .clk(clk),
    .reset(reset),
    
	 .instrEX(instrEX),
    .aluOutEX(aluOutEX),
    .rtdataEX(forward_rtdataEX),
    .pcEX(pcEX),
	 .RegDataEX(RegDataEX),
	 .RegWriteEX(RegWriteEX),
	 .RegAddrEX(RegAddrEX),
	 
	 //output
    .instrMEM(instrMEM),
    .aluOutMEM(aluOutMEM),
    .rtdataMEM(rtdataMEM),
    .pcMEM(pcMEM),
	 .RegDataMEM(RegDataMEM),
	 .RegWriteMEM(RegWriteMEM),
	 .RegAddrMEM(RegAddrMEM)
);

DM dm_module(
	 //input
    .clk(clk),
    .reset(reset),
	 .instrMEM(instrMEM),
	 //write
    .aluOutMEM(aluOutMEM),
    .rtdataMEM(forward_rtdataMEM),
    .pcMEM(pcMEM),
	 //mux
	 .RegDataMEM(RegDataMEM),
	 .RegWriteMEM(RegWriteMEM),
	 .RegAddrMEM(RegAddrMEM),
	 //output
	 .RegDataMEM1(RegDataMEM1),
	 .RegWriteMEM1(RegWriteMEM1),
	 .RegAddrMEM1(RegAddrMEM1)
);

MEMWB memdb_module(
	 //input
    .clk(clk),
    .instrMEM(instrMEM),
    .pcMEM(pcMEM),
    .RegDataMEM(RegDataMEM1),
	 .RegWriteMEM(RegWriteMEM1),
	 .RegAddrMEM(RegAddrMEM1),
	 //output
	 .instrWB(instrWB),
    .pcWB(pcWB),
	 .RegDataWB(RegDataWB),
	 .RegWriteWB(RegWriteWB),
	 .RegAddrWB(RegAddrWB)
);

LOGGER logger(
	.pc(pcIF),
	.instr(instrIF),
	.reg_name(0),
	.imm_as_dec(1),
	.asm(string)
);

CU cuu(
	.instrD(instrID),
	.instrE(instrEX),
	.instrM(instrMEM),
	.instrW(instrWB),
	.rs_tuse(rs_tuse),
	.rt_tuse(rt_tuse),
	.tnewE(tnewE),
	.tnewM(tnewM),
	.tnewW(tnewW)
);
	always @(*) begin
		//$display("fors = %d,fort = %d",rsdataID,rtdataID);
		//$display("rstuse = %d,rttuse = %d,stall=:%d ",rs_tuse,rt_tuse,stall);
		//$display("%s", string);
	end
endmodule

