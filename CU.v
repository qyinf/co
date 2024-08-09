`include "define.v"
module CU(
    input [31:0] instrD,
    input [31:0] instrE,
    input [31:0] instrM,
    input [31:0] instrW,
    output [1:0] rs_tuse,
    output [1:0] rt_tuse,
    output [1:0] tnewE,
    output [1:0] tnewM,
    output [1:0] tnewW
);
    //D
    wire [5:0] funcD;
    wire [5:0] opD;
    wire is_b_D;
    wire is_r_D;
    wire is_i_D;
    wire is_l_D;
    wire is_s_D;
    assign funcD = instrD[`func];
    assign opD = instrD[`op];
    assign is_b_D = (opD == `beq_op)? 1 : 0;
    assign is_r_D = (opD == 0 && funcD != `jr_func && funcD != `jalr_func)? 1 : 0;//
    assign is_i_D = (opD == `ori_op)? 1 : 0;//
    assign is_l_D = (opD == `lw_op)? 1 : 0;
    assign is_s_D = (opD == `sw_op)? 1 : 0;
    assign rs_tuse = (is_b_D == 1 || funcD == `jr_func || funcD == `jalr_func)? 0 :
                     (is_r_D || is_i_D || is_l_D || is_s_D)? 1 :
                     3;

    assign rt_tuse = (is_b_D == 1)? 0 :
                     (is_r_D == 1)? 1 :
							(is_s_D == 1)? 2 :
                     3;

    //E
    wire [5:0] funcE;
    wire [5:0] opE;
    wire is_r_E;
    wire is_i_E;
    wire is_l_E;
    wire is_s_E;
    assign funcE = instrE[`func];
    assign opE = instrE[`op];
    assign is_r_E = (opE == 0 && funcE != `jr_func)? 1 : 0;
    assign is_i_E = (opE == `ori_op || opE == `lui_op)? 1 : 0;
    assign is_l_E = (opE == `lw_op)? 1 : 0;
    assign is_s_E = (opE == `sw_op)? 1 : 0;
    assign tnewE = (is_r_E == 1 || is_i_E == 1)? 1 :
                   (opE == `jal_op)? 1 :
                   (is_l_E == 1)? 2 :
                   0;

    //M
    wire [5:0] funcM;
    wire [5:0] opM;
    wire is_l_M;
    assign funcM = instrM[`func];
    assign opM =instrM[`op];
    assign is_l_M = (opM == `lw_op )? 1 : 0;
    assign tnewM = (is_l_M == 1)? 1 : 0;
    
    //W
    assign tnewW = 0;

endmodule