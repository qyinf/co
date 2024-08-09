`include "define.v"
module mips(
    input clk,
    input reset,
    input interrupt,
    output [31:0] macroscopic_pc,
	 
	 //IM
	 output [31:0] i_inst_addr,
	 input [31:0] i_inst_rdata,
	 
	 //GRF_read
	 output w_grf_we,  
	 output [4:0] w_grf_addr,
	 output [31:0] w_grf_wdata,
	 output [31:0] w_inst_addr,
	 
	 //DM  
	 input [31:0] m_data_rdata,
	 output [31:0] m_data_addr,
	 output [31:0] m_data_wdata,
	 output [3:0] m_data_byteen,
	 output [31:0] m_inst_addr,
	 
	 //P7
	 output [31:0] m_int_addr,
	 output [3:0] m_int_byteen
);
	always@(*)begin
		//$display("pcM=%h,MByteen:%b",pcM,MByteen);
		//$display("m_data_byteen=:%d,req=%d,MAddr=%h",m_data_byteen,req,MAddr);
		//$display("???");
		//$display("load_data=%d",load_data);
	end

 
    //IM
	 wire [31:0] i_inst_addr1;
	 assign i_inst_addr = i_inst_addr1;
	 
	 //W
	 wire w_grf_we1;
	 wire [4:0] w_grf_addr1;
	 wire [31:0] w_grf_wdata1;
	 wire [31:0] w_inst_addr1;
	 assign w_grf_we = w_grf_we1;
	 assign w_grf_addr = w_grf_addr1;
	 assign w_grf_wdata = w_grf_wdata1;
	 assign w_inst_addr = w_inst_addr1;
	 
	 
	 //M and Bridge
	 wire [31:0] pcM;
	 wire [31:0] MAddr;//equal to cpu's aluOut
	 wire [3:0] MByteen;//equal to cpu's MByteen
	 wire [31:0] rtdata;
	 wire [31:0] load_data;
	 wire [31:0] m_wdata;
	 assign macroscopic_pc = pcM;
	 assign m_inst_addr = pcM;
	 assign m_data_wdata = m_wdata;
	 assign m_int_wdata = m_wdata;
	 assign m_data_addr = MAddr;
	 assign m_int_addr = MAddr;
	 //m_data_byteen,m_int_byteen come from bridge
	 
	 //
	 wire req;
	
    //timer
    wire IRQ1;
    wire IRQ2;
	 wire WE1;
	 wire WE2;
    wire [5:0] HWInt;
	 wire [31:0] Dout1;
	 wire [31:0] Dout2;
    assign HWInt = {3'b0,interrupt,IRQ1,IRQ2};
	 
	 
	 bridge bridge_module(
		 //input
		 .MAddr(MAddr),
		 .dm_data(m_data_rdata),
		 .rtdata(rtdata),
		 .TIn1(Dout1),
		 .TIn2(Dout2),
		 .MByteen(MByteen),
		 .req(req),
		 //output
		 .WE1(WE1),
		 .WE2(WE2),
		 .load_data(load_data),
		 .m_wdata(m_wdata),
		 .m_data_byteen(m_data_byteen),
		 .m_int_byteen(m_int_byteen)
	 );


    TC tc1(
        .clk(clk),
        .reset(reset),
        .Addr(m_data_addr[31:2]),
        .WE(WE1),
        .Din(m_data_rdata),
        .Dout(Dout1),
        .IRQ(IRQ1)
    );

    TC tc2(
        .clk(clk),
        .reset(reset),
        .Addr(m_data_addr[31:2]),
        .WE(WE2),
        .Din(m_data_rdata),
        .Dout(Dout2),
        .IRQ(IRQ2)
    );
	 
	 
	 CPU cpu_module(
      //input
      .clk(clk),
      .reset(reset),
      .HWInt(HWInt),
		.i_inst_rdata(i_inst_rdata),
		.load_data(load_data),//load

      //output
		.i_inst_addr(i_inst_addr1),
		.w_grf_we(w_grf_we1),
		.w_grf_addr(w_grf_addr1),
		.w_grf_wdata(w_grf_wdata1),
		.w_inst_addr(w_inst_addr1),
		  
		//M and Bridge
		.MAddr(MAddr),
		.Mpc(pcM),
		.MByteen(MByteen),
		.rtdata(rtdata),//store
		
		.Req(req)
  );

	 
endmodule