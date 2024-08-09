`include "define.v"
module CU(
	 input [31:0] instrF,
    input [31:0] instrD,
    input [31:0] instrE,
    input [31:0] instrM,
    input [31:0] instrW,
    output [1:0] rs_tuse,
    output [1:0] rt_tuse,
    output [1:0] tnewE,
    output [1:0] tnewM,
    output [1:0] tnewW,
	 output [1:0] eretUse,
	 output [1:0] mtE,
	 output [1:0] mtM,
	 output is_mf_D,
	 output is_mf_E,
	 output RI,
	 output bdF
);
	//F
	wire [5:0] funcF;
	wire [5:0] opF;
	assign funcF = instrF[`func];
	assign opF = instrF[`op];
	assign RI = !((opF == 0 && 
					(funcF == `mult_func || funcF == `multu_func ||
					 funcF == `div_func || funcF == `divu_func ||
					 funcF == `mfhi_func || funcF == `mflo_func ||
					 funcF == `mthi_func || funcF == `mtlo_func ||
					 funcF == `add_func || funcF == `sub_func || 
					 funcF == `and_func || funcF == `or_func ||
					 funcF == `slt_func || funcF == `sltu_func ||
					 funcF == `jr_func || funcF == `syscall_func)) ||
					 (opF == `ori_op || opF == `addi_op ||
					  opF == `lui_op || opF == `andi_op) ||
					 (opF == `beq_op || opF == `bne_op) ||
					 (opF == `jal_op) ||
					 (opF == `lb_op || opF == `lh_op || opF == `lw_op) ||
					 (opF == `sb_op || opF == `sh_op || opF == `sw_op) ||
					 (opF == `wrong_op) ||
					 (opF == 0 && funcF == 0));
	
	 assign bdF = (is_b_D || opD == `j_op || opD == `jal_op ||
			        (opD == 0 && funcD == `jr_func) ||
					  (opD == 0 && funcD == `jalr_func))? 1 : 0;
					 
    //D
    wire [5:0] funcD;
    wire [5:0] opD;
	 wire [4:0] rsD;
	 wire [4:0] rdD;
    wire is_b_D;
    wire is_r_D;
    wire is_i_D;
    wire is_l_D;
    wire is_s_D;
	 assign is_mf_D = (opD == 0 && 
							(funcD == `mult_func || funcD == `multu_func ||
							 funcD == `div_func || funcD == `divu_func ||
							 funcD == `mfhi_func || funcD == `mflo_func ||
							 funcD == `mthi_func || funcD == `mtlo_func))? 1 : 0;
    assign funcD = instrD[`func];
    assign opD = instrD[`op];
	 assign rsD = instrD[`rs];
	 assign rdD = instrD[`rd];
    assign is_b_D = (opD == `beq_op || opD == `bne_op)? 1 : 0;
    assign is_r_D = (opD == 0 && 
						  (funcD == `add_func || funcD == `sub_func || funcD == `and_func ||
							funcD == `or_func || funcD == `slt_func || funcD == `sltu_func ||
							funcD == `mult_func || funcD == `multu_func ||
							funcD == `div_func || funcD == `divu_func))? 1 : 0;//
    assign is_i_D = (opD == `ori_op || opD == `andi_op || opD == `addi_op)? 1 : 0;//lui
    assign is_l_D = (opD == `lw_op || opD == `lh_op || opD == `lb_op)? 1 : 0;
    assign is_s_D = (opD == `sw_op || opD == `sh_op || opD == `sb_op)? 1 : 0;
    
	 assign rs_tuse = (is_b_D == 1 || funcD == `jr_func || funcD == `jalr_func)? 0 :
                     (is_r_D || is_i_D || is_l_D || is_s_D ||
							(opD == 0 && funcD == `mthi_func) ||
							(opD == 0 && funcD == `mtlo_func))? 1 :
                     3;

    assign rt_tuse = (is_b_D == 1)? 0 :
                     (is_r_D == 1)? 1 :
							(is_s_D == 1)? 2 :
							(opD == `wrong_op && rsD == `mtc0_rs)? 2 :
                     3;
							
	 assign eretUse = (opD == `wrong_op && funcD == `eret_func)? 0 : 3;

    //E
    wire [5:0] funcE;
    wire [5:0] opE;
	 wire [4:0] rsE;
	 wire [4:0] rdE;
    wire is_r_E;
    wire is_i_E;
    wire is_l_E;
    wire is_s_E;
	 assign is_mf_E = (opE == 0 && 
							(funcE == `mult_func || funcE == `multu_func ||
							 funcE == `div_func || funcE == `divu_func))? 1 : 0;
    assign funcE = instrE[`func];
    assign opE = instrE[`op];
	 assign rsE = instrE[`rs];
	 assign rdE = instrE[`rd];
    assign is_r_E = (opE == 0 && 
						  (funcE == `add_func || funcE == `sub_func || funcE == `and_func ||
							funcE == `or_func || funcE == `slt_func || funcE == `sltu_func ||
							funcE == `mfhi_func || funcE == `mflo_func))? 1 : 0;
    assign is_i_E = (opE == `ori_op || opE == `lui_op || opE == `addi_op || opE == `andi_op)? 1 : 0;
    assign is_l_E = (opE == `lw_op || opE == `lb_op || opE == `lh_op)? 1 : 0;
    assign is_s_E = (opE == `sw_op || opE == `sb_op || opE == `sh_op)? 1 : 0;
    assign tnewE = (is_r_E == 1 || is_i_E == 1)? 1 :
                   (opE == `jal_op)? 1 :
                   (is_l_E == 1)? 2 :
						 (opE == `wrong_op && rsE == `mfc0_rs)? 2 :
                   0;
	 assign mtE = (opE == `wrong_op && rsE == `mtc0_rs && rdE == 14)? 2 : 0;

    //M
    wire [5:0] funcM;
    wire [5:0] opM;
	 wire [4:0] rsM;
	 wire [4:0] rdM;
    wire is_l_M;
    assign funcM = instrM[`func];
    assign opM = instrM[`op];
	 assign rsM = instrM[`rs];
	 assign rdM = instrM[`rd];
    assign is_l_M = (opM == `lw_op || opM == `lh_op || opM == `lb_op)? 1 : 0;
    assign tnewM = (is_l_M == 1)? 1 : 
						 (opM == `wrong_op && rsM == `mfc0_rs)? 1 :
						 0;
	 assign mtM = (opM == `wrong_op && rsM == `mtc0_rs && rdM == 14)? 1 : 0;
    
    //W
    assign tnewW = 0;
	always@(*)begin
	end
endmodule