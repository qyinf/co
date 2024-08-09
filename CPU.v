`include "define.v"
module CPU(
    input clk,
    input reset,
	 input [5:0] HWInt,
	 input [31:0] load_data,
	 input [31:0] i_inst_rdata,
	 
	 //GRF_read,
	 output [31:0] i_inst_addr,
	 output w_grf_we,
	 output [4:0] w_grf_addr,
	 output [31:0] w_grf_wdata,
	 output [31:0] w_inst_addr,
	 //DM
	 output [3:0] MByteen,
	 output [31:0] MAddr,
	 output [31:0] Mpc,
	 output [31:0] rtdata,
	 output Req
	 
);

always@(*)begin
    //$display("t:%d,EPC:%h,macro:%h",$time,EPC,macropc);
    //$display("t:%d,pcM=%h,aluOutM:%h,ExcCode:%d",$time,pcM,aluOutM,ExcCodeM);
    //$display("npc=%h,pcF=%h,pcD=%h,EPC=%h,eretD=%d,stall=%d",npc,pcF,pcD,EPC,eretD,stall);
end
//
assign i_inst_addr = pcF;
//
assign w_grf_we = RegWriteW;
assign w_grf_addr = RegAddrW;
assign w_grf_wdata = RegDataW;
assign w_inst_addr = pcW;

assign MByteen = (req == 1)? 0 : MemWrite;
assign MAddr = aluOutM;
assign Mpc = macropc;
assign rtdata = forward_rtdataM;

assign Req = req;


//macro
wire [31:0] macropc;
assign macropc = (validM == 1)? pcM :
					  (validE == 1)? pcE :
					  (validD == 1)? pcD :
					  pcF;
//data
 
//F
//pipeline
wire [31:0] pcF;
wire [31:0] instrF;
wire [4:0] ExcCodeF;
wire bdF;
//debug
wire validF;
//control
wire RI;
wire [5:0] opF;
wire [5:0] funcF;
assign instrF = i_inst_rdata;
assign opF = instrF[`op];
assign funcF = instrF[`func];
assign ExcCodeF = ((|pcF[1:0]!= 0) || (pcF < 32'h0000_3000) || (pcF > 32'h0000_6fff))? 4 :
						(opF == 0 && funcF == `syscall_func)? 8 :
					   (RI == 1)? 10 :
						0;
						
						
//D
wire [31:0] npc;
//pipeline
wire [31:0] instrD;
wire [31:0] pcD;
wire [4:0] ExcCodeD;
wire bdD;
wire [31:0] rsdataD;
wire [31:0] rtdataD;
wire validD;
//control
wire is_mf_D;
wire [31:0] EPC;
wire eretD = (instrD[`op] == `wrong_op && instrD[`func] == `eret_func)? 1 : 0;
//forward
wire [4:0] rsD = instrD[`rs];
wire [4:0] rtD = instrD[`rt];
wire [31:0] forward_rsdataD = (rsD == RegAddrM && RegAddrM != 0 && RegWriteM == 1)? RegDataM :
								      (rsD == RegAddrW && RegAddrW != 0 && RegWriteW == 1)? RegDataW :
								      rsdataD;
wire [31:0] forward_rtdataD = (rtD == RegAddrM && RegAddrM != 0 && RegWriteM == 1)? RegDataM :
								      (rtD == RegAddrW && RegAddrW != 0 && RegWriteW == 1)? RegDataW :
								      rtdataD;


//E
//pipeline
wire [31:0] instrE;
wire [31:0] rsdataE;
wire [31:0] rtdataE;
wire [31:0] pcE;
wire [4:0] ExcCodeE;
wire [4:0] ExcCodeE1;
wire bdE;
wire start;
wire busy;
wire validE;

//forward
wire [4:0] rsE = instrE[`rs];
wire [4:0] rtE = instrE[`rt];
wire [31:0] forward_rsdataE = (rsE == RegAddrM && RegAddrM != 0 && RegWriteM == 1)? RegDataM :
								      (rsE == RegAddrW && RegAddrW != 0 && RegWriteW == 1)? RegDataW :
								      rsdataE;

wire [31:0] forward_rtdataE = (rtE == RegAddrM && RegAddrM != 0 && RegWriteM == 1)? RegDataM :
								      (rtE == RegAddrW && RegAddrW != 0 && RegWriteW == 1)? RegDataW :
								      rtdataE;
//other
wire [31:0] ldata;
wire [31:0] hdata;
wire [31:0] RegDataE;
wire [4:0] RegAddrE;
wire RegWriteE;
wire [31:0] aluOutE;


//M
//pipeline
wire [31:0] instrM;
wire [31:0] aluOutM;
wire [31:0] rtdataM;
wire [31:0] pcM;
wire [31:0] RegDataM;
wire [4:0] RegAddrM;
wire RegWriteM;
wire [4:0] ExcCodeM;
wire bdM;
wire validM;

//forward
wire [4:0] rtM = instrM[`rt];
wire [31:0] forward_rtdataM = (rtM == RegAddrW && RegAddrW != 0 && RegWriteW == 1)? RegDataW :
									rtdataM ;

//other
wire [31:0] RegDataM1;
wire [4:0]RegAddrM1;
wire RegWriteM1;
wire [3:0] MemWrite;
wire [31:0] cp0Out;
wire [31:0] lOut;
wire req;

//W
wire [31:0] instrW;
wire [31:0] pcW;
wire [31:0] RegDataW;
wire [4:0] RegAddrW;
wire RegWriteW;




//control
wire [1:0] rs_tuse;
wire [1:0] rt_tuse;
wire [1:0] tnewE;
wire [1:0] tnewM;
wire [1:0] tnewW;
wire [1:0] eretUse;
wire [1:0] mtE;
wire [1:0] mtM;
//stall
wire stall;
assign stall = (eretUse < mtE)? 1 :
					(eretUse < mtM)? 1 :
					(is_mf_D == 1 && (start == 1 || busy != 0 ))? 1 :
				   ((rs_tuse < tnewE) && rsD == RegAddrE && RegAddrE != 0 && RegWriteE)? 1 :
					((rs_tuse < tnewM) && rsD == RegAddrM && RegAddrM != 0 && RegWriteM)? 1 :
					((rt_tuse < tnewE) && rtD == RegAddrE && RegAddrE != 0 && RegWriteE)? 1 :
					((rt_tuse < tnewM) && rtD == RegAddrM && RegAddrM != 0 && RegWriteM)? 1 :
					0;
					
					
CU cuu(
	.instrF(i_inst_rdata),
	.instrD(instrD),
	.instrE(instrE),
	.instrM(instrM),
	.instrW(instrW),
	.rs_tuse(rs_tuse),
	.rt_tuse(rt_tuse),
	.tnewE(tnewE),
	.tnewM(tnewM),
	.tnewW(tnewW),
	.eretUse(eretUse),
	.mtE(mtE),
	.mtM(mtM),
	.is_mf_D(is_mf_D),
	.is_mf_E(start),
	.RI(RI),
	.bdF(bdF)
);								 								 

PC pc_module(
    .clk(clk),
    .reset(reset),
    .en(!stall),
	 .req(req),
	 .eretD(eretD),
    .npc(npc),
    .pcF(pcF)
);

/*---------------------------------*/

IFID ifid_module(
    //input
    .clk(clk),
    .reset(reset),
    .en(!stall),
	 .req(req),
	 .eretD(eretD),
    .instrF(i_inst_rdata),
    .pcF(pcF),
	 .ExcCodeF(ExcCodeF),
	 .bdF(bdF),
	 .npc(npc),
	 //output
    .instrD(instrD),
    .pcD(pcD),
	 .ExcCodeD(ExcCodeD),
	 .bdD(bdD),
	 .validD(validD)
);
/*---------------------------------*/


NPC npc_module(
	  //input
    .instrD(instrD),
    .rsdataD(forward_rsdataD),
    .rtdataD(forward_rtdataD),
    .pcF(pcF),
	 .pcD(pcD),
	 .eretD(eretD),
	 .EPC(EPC),
	 //output
    .npc(npc)
);

GRF grf_module(
	 //input
    .clk(clk),
    .reset(reset),
	 //write
    .RegWrite(RegWriteW),
    .RegData(RegDataW),
    .RegAddr(RegAddrW),
	 //read
    .instrD(instrD),
	 //output
    .rsdataD(rsdataD),
    .rtdataD(rtdataD)
);

/*-------------------------------------------*/
IDEX idex_module(
    //input
    .clk(clk),
    .reset(reset),
	 .flush(stall),
	 .req(req),
    
	 .instrD(instrD),
    .rsdataD(forward_rsdataD),
    .rtdataD(forward_rtdataD),
    .pcD(pcD),
	 .ExcCodeD(ExcCodeD),
	 .bdD(bdD),
	 .validD(validD),
    
    //output
	 .instrE(instrE),
    .rsdataE(rsdataE),
    .rtdataE(rtdataE),
    .pcE(pcE),
	 .ExcCodeE(ExcCodeE),
	 .bdE(bdE),
	 .validE(validE)
);
/*-------------------------------------------*/
ALU alu_module(
	 //input
    .instrE(instrE),
	 .pcE(pcE),
    .rsdataE(forward_rsdataE),
    .rtdataE(forward_rtdataE),
	 .ExcCodeE(ExcCodeE),
	 //output
	 .aluOutE(aluOutE),
	 //P7
	 .ExcCodeE1(ExcCodeE1)
);

MF mf_module(
	//input
	.clk(clk),
	.reset(reset),
	.req(req),
	.start(start),
	.instrE(instrE),
	.rsdataE(forward_rsdataE),
	.rtdataE(forward_rtdataE),
	.busy(busy),
	.ldata(ldata),
	.hdata(hdata)
);

MUX0 mux0_module(
	.instrE(instrE),
	.aluOutE(aluOutE),
	.ldata(ldata),
	.hdata(hdata),
	.req(req),
	.RegWriteE(RegWriteE),
	.RegAddrE(RegAddrE),
	.RegDataE(RegDataE)
);

/*-------------------------------------------*/
EXMEM exmem_module(
	 //input
    .clk(clk),
    .reset(reset),
	 .req(req),
    
	 .instrE(instrE),
    .aluOutE(aluOutE),
    .rtdataE(forward_rtdataE),
    .pcE(pcE),
	 .RegDataE(RegDataE),
	 .RegWriteE(RegWriteE),
	 .RegAddrE(RegAddrE),
	 .ExcCodeE(ExcCodeE1),
	 .bdE(bdE),
	 .validE(validE),
	 
	 //output
    .instrM(instrM),
    .aluOutM(aluOutM),
    .rtdataM(rtdataM),
    .pcM(pcM),
	 .RegDataM(RegDataM),
	 .RegWriteM(RegWriteM),
	 .RegAddrM(RegAddrM),
	 .ExcCodeM(ExcCodeM),
	 .bdM(bdM),
	 .validM(validM)
);

/*-------------------------------------------*/

DM dm_module(
	 //input
    .clk(clk),
    .reset(reset),
	 .instrM(instrM),
	 .load_data(load_data),
	 .aluOutM(aluOutM),
	 //output
	 .lOut(lOut),
	 .MemWrite(MemWrite)
);

CP0 cp0_module(
   //input
	.clk(clk),
	.reset(reset),
	.BDIn(bdM),
	.ExcCodeIn(ExcCodeM),
	.HWInt(HWInt),
	
	.instr(instrM),
	.macropc(macropc),
	.rtdataM(forward_rtdataM),
	
	//output
	.Req(req),
	.cp0Out(cp0Out),
	.EPCout(EPC)
);
MUX1 mux1_module(
	.RegWriteM(RegWriteM),
	.RegAddrM(RegAddrM),
	.RegDataM(RegDataM),
	.instrM(instrM),
	.lOut(lOut),
	.cp0Out(cp0Out),
	.ExcCodeM(ExcCodeM),
	.req(req),
	.RegWriteM1(RegWriteM1),
	.RegAddrM1(RegAddrM1),
	.RegDataM1(RegDataM1)
);

/*-------------------------------------------*/
MEMWB memdb_module(
	 //input
    .clk(clk),
	 .reset(reset),
	 .req(req),
    .instrM(instrM),
    .pcM(pcM),
    .RegDataM(RegDataM1),
	 .RegWriteM(RegWriteM1),
	 .RegAddrM(RegAddrM1),
	 //output
	 .instrW(instrW),
    .pcW(pcW),
	 .RegDataW(RegDataW),
	 .RegWriteW(RegWriteW),
	 .RegAddrW(RegAddrW)
);
/*-------------------------------------------*/

//debug
wire[32*8-1:0] stringF;
wire[32*8-1:0] stringD;
wire[32*8-1:0] stringE;
wire[32*8-1:0] stringM;
wire[32*8-1:0] stringW;
LOGGER logger1(.pc(pcF), .instr(i_inst_rdata), .reg_name(0), .imm_as_dec(1), .asm(stringF));
LOGGER logger2(.pc(pcD), .instr(instrD), .reg_name(0), .imm_as_dec(1), .asm(stringD));
LOGGER logger3(.pc(pcE), .instr(instrE), .reg_name(0), .imm_as_dec(1), .asm(stringE));
LOGGER logger4(.pc(pcM), .instr(instrM), .reg_name(0), .imm_as_dec(1), .asm(stringM));
LOGGER logger5(.pc(pcW), .instr(instrW), .reg_name(0), .imm_as_dec(1), .asm(stringW));

	always @(*) begin
		//$display("%s",stringF);
		//$display("%s",stringD);
		//$display("%s",stringE);
		//$display("%s",stringM);
		//$display("%s",stringW);
		//$display("???:%d",MByteen);
	end
endmodule

