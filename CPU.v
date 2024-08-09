`include "define.v"
module mips(
    input clk,
    input reset,
	 //IM
	 output [31:0] i_inst_addr,
	 input [31:0] i_inst_rdata,
	 //DM
	 input [31:0] m_data_rdata,
	 output [31:0] m_data_addr,
	 output [31:0] m_data_wdata,
	 output [3:0] m_data_byteen,
	 output [31:0] m_inst_addr,
	 //GRF_read
	 output w_grf_we,
	 output [4:0] w_grf_addr,
	 output [31:0] w_grf_wdata,
	 output [31:0] w_inst_addr
);
//
assign i_inst_addr = pcIF;
//
assign m_data_addr = aluOutMEM;
assign m_data_wdata = MemData;
assign m_inst_addr = pcMEM;
assign m_data_byteen = MemWrite;
//
assign w_grf_we = RegWriteWB;
assign w_grf_addr = RegAddrWB;
assign w_grf_wdata = RegDataWB;
assign w_inst_addr = pcWB;


//F
wire [31:0] pcIF;
wire [31:0] npc;


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
//乘除模块
wire busy;
wire start;
wire [31:0] ldata;
wire [31:0] hdata;


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

wire [31:0] RegDataMEM1;
wire [4:0]RegAddrMEM1;
wire RegWriteMEM1;
//出bug辽
wire [31:0] aluOutMEM;
wire [3:0] MemWrite;
wire [31:0] MemData;

//W
wire [31:0] instrWB;
wire [31:0] pcWB;
wire [31:0] RegDataWB;
wire [4:0] RegAddrWB;
wire RegWriteWB;

wire[32*8-1:0] stringF;
wire[32*8-1:0] stringD;
wire[32*8-1:0] stringE;
wire[32*8-1:0] stringM;
wire[32*8-1:0] stringW;

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
assign stall = (is_mf_D == 1 && (start == 1 || busy != 0 ))? 1 :
				   ((rs_tuse < tnewE) && rsD == RegAddrEX && RegAddrEX != 0 && RegWriteEX)? 1 :
					((rs_tuse < tnewM) && rsD == RegAddrMEM && RegAddrMEM != 0 && RegWriteMEM)? 1 :
					((rt_tuse < tnewE) && rtD == RegAddrEX && RegAddrEX != 0 && RegWriteEX)? 1 :
					((rt_tuse < tnewM) && rtD == RegAddrMEM && RegAddrMEM != 0 && RegWriteMEM)? 1 :
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
end
//F
PC pc_module(
    .clk(clk),
    .reset(reset),
    .en(!stall),
    .npc(npc),
    .pcIF(pcIF)
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
    .instrIF(i_inst_rdata),
    .pcIF(pcIF),
	 //output
    .instrID(instrID),
    .pcID(pcID)
);

//D
GRF grf_module(
	 //input
    .clk(clk),
    .reset(reset),
	 //write
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
    .rtdataID(forward_rtdataID),
    .pcID(pcID),
    
    //output
	 .instrEX(instrEX),
    .rsdataEX(rsdataEX),
    .rtdataEX(rtdataEX),
    .pcEX(pcEX)
);
//E
ALU alu_module(
	 //input
    .instrEX(instrEX),
	 .pcEX(pcEX),
    .rsdataEX(forward_rsdataEX),
    .rtdataEX(forward_rtdataEX),
	 .ldata(ldata),
	 .hdata(hdata),
	 //output
	 .RegData(RegDataEX),
	 .RegAddr(RegAddrEX),
	 .RegWrite(RegWriteEX),
	 .aluOutEX(aluOutEX)
);

MF mf_module(
	//input
	.clk(clk),
	.reset(reset),
	.start(start),
	.instrEX(instrEX),
	.rsdataEX(forward_rsdataEX),
	.rtdataEX(forward_rtdataEX),
	.busy(busy),
	.ldata(ldata),
	.hdata(hdata)
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
	 .dmOut(m_data_rdata),
	 .aluOutMEM(aluOutMEM),
	 .rtdataMEM(forward_rtdataMEM),
	 //mux
	 .RegDataMEM(RegDataMEM),
	 .RegWriteMEM(RegWriteMEM),
	 .RegAddrMEM(RegAddrMEM),
	 //output
	 .RegDataMEM1(RegDataMEM1),
	 .RegWriteMEM1(RegWriteMEM1),
	 .RegAddrMEM1(RegAddrMEM1),
	 .MemWrite(MemWrite),
	 .MemData(MemData)
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

//LOGGER logger1(.pc(pcIF), .instr(i_inst_rdata), .reg_name(0), .imm_as_dec(1), .asm(stringF));
//LOGGER logger2(.pc(pcID), .instr(instrID), .reg_name(0), .imm_as_dec(1), .asm(stringD));
//LOGGER logger3(.pc(pcIE), .instr(instrEX), .reg_name(0), .imm_as_dec(1), .asm(stringE));
//LOGGER logger4(.pc(pcIM), .instr(instrMEM), .reg_name(0), .imm_as_dec(1), .asm(stringM));
//LOGGER logger5(.pc(pcIW), .instr(instrWB), .reg_name(0), .imm_as_dec(1), .asm(stringW));

CU cuu(
	.instrD(instrID),
	.instrE(instrEX),
	.instrM(instrMEM),
	.instrW(instrWB),
	.rs_tuse(rs_tuse),
	.rt_tuse(rt_tuse),
	.tnewE(tnewE),
	.tnewM(tnewM),
	.tnewW(tnewW),
	.is_mf_D(is_mf_D),
	.is_mf_E(start)
);
	always @(*) begin
	end
endmodule

