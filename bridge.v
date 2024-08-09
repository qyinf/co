`include "define.v"
module bridge(
    input [31:0] MAddr,
    input [31:0] dm_data,
	 input [31:0] rtdata,
    input [31:0] TIn1,
    input [31:0] TIn2,
    input [3:0] MByteen,
	 input req,
    output WE1,
    output WE2,
	 output [31:0] load_data,
    output [31:0] m_wdata,
    output [3:0] m_data_byteen,
    output [3:0] m_int_byteen
);
    
	 //store
	 wire sel_t1;
    wire sel_t2;
	 wire sel_dm;
	 wire sel_stall;
    assign sel_t1 =  (MAddr >= `TC1_start && MAddr <= `TC1_end)? 1 : 0;
    assign sel_t2 =  (MAddr >= `TC2_start && MAddr <= `TC2_end)? 1 : 0;
	 assign sel_dm = (MAddr >= `DM_start && MAddr <= `DM_end)? 1 : 0;
	 assign sel_stall = (MAddr >= `stall_start && MAddr <= `stall_end)? 1 : 0;
    assign WE1 = (sel_t1 == 1 && req == 0)? MByteen : 0;
    assign WE2 = (sel_t2 == 1 && req == 0)? MByteen : 0;
	 assign m_data_byteen = (sel_dm == 1 && req == 0)? MByteen : 0 ;
    assign m_int_byteen = (sel_stall == 1 && req == 0)? MByteen : 0;

	
	 wire [31:0] tmp;
    assign tmp = //(sel_t1 == 1)? TIn1 :
                 //(sel_t2 == 1)? TIn2 :
                 rtdata ;
	 assign m_wdata = (MByteen == 4'b1100)? {tmp[15:0],{16{1'b0}}} :
								  (MByteen == 4'b0010)? {{16{1'b0}},tmp[7:0],{8{1'b0}}} :
								  (MByteen == 4'b0100)? {{8{1'b0}},tmp[7:0],{16{1'b0}}} :
								  (MByteen == 4'b1000)? {tmp[7:0],{24{1'b0}}} :
								  tmp;
	
	 //load_data
	 assign load_data = (sel_t1 == 1)? TIn1 :
							  (sel_t2 == 1)? TIn2 :
							  dm_data;
							  
	 always@(*)begin
		//$display("%h",addr);
		//$display("???:%d",(addr >= `DM_start && addr <= `DM_end));
		//$display("MB:%d",MByteen);
		//$display("%d",m_data_byteen);
	 end

endmodule