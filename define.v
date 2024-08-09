//R
`define add_func 6'b100000
`define sub_func 6'b100010
`define and_func 6'b100100
`define or_func 6'b100101
`define slt_func 6'b101010
`define sltu_func 6'b101011

// j
`define j_op 6'b000010 //Ìø×ªimm26
`define jalr_func 6'b001001
`define jr_func 6'b001000
`define jal_op 6'b000011

// b
`define beq_op 6'b000100
`define bne_op 6'b000101

//s
`define sw_op 6'b101011
`define sb_op 6'b101000
`define sh_op 6'b101001

//l
`define lw_op 6'b100011
`define lb_op 6'b100000
`define lh_op 6'b100001

// i
`define ori_op 6'b001101
`define lui_op 6'b001111
`define addi_op 6'b001000
`define andi_op 6'b001100

//mf,div
`define mult_func 6'b011000
`define multu_func 6'b011001
`define div_func 6'b011010
`define divu_func 6'b011011
`define mfhi_func 6'b010000
`define mflo_func 6'b010010
`define mthi_func 6'b010001
`define mtlo_func 6'b010011

//alu_type
`define add 6'd1
`define sub 6'd2
`define andd 6'd8//pay special attention
`define orr 6'd9
`define slt 6'd10
`define sltu 6'd11
`define mult 6'd14
`define multu 6'd15
`define div 6'd16
`define divu 6'd17

`define ori 6'd3
`define lui 6'd5
`define andi 6'd12
`define addi 6'd13

`define sl 6'd4

`define jal 6'd6
`define jalr 6'd7

//max = 17


//jump_type
`define beqt 5'd1
`define jalrt 5'd2
`define jrt 5'd3
`define jalt 5'd4
`define jt 5'd5
`define bnet 5'd6

//hmmm
`define func 5:0
`define shamt 10:6
`define rd 15:11
`define rt 20:16
`define rs 25:21
`define op 31:26
`define imm26 25:0
`define imm16 15:0