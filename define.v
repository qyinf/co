//R
`define add_func 6'b100000
`define sub_func 6'b100010

// j
`define j_op 6'b000010 //Ìø×ªimm26
`define jalr_func 6'b001001
`define jr_func 6'b001000
`define jal_op 6'b000011

// b
`define beq_op 6'b000100

//s
`define sw_op 6'b101011

//l
`define lw_op 6'b100011

// i
`define ori_op 6'b001101
`define lui_op 6'b001111

//mf,div
`define mult_func 6'b011000
`define div_func 6'b011010


//alu_type
`define add 4'd1
`define sub 4'd2
`define ori 4'd3
`define sl 4'd4
`define lui 4'd5
`define jal 4'd6
`define jalr 4'd7

//jump_type
`define beqt 5'd1
`define jalrt 5'd2
`define jrt 5'd3
`define jalt 5'd4
`define jt 5'd5

//hmmm
`define func 5:0
`define shamt 10:6
`define rd 15:11
`define rt 20:16
`define rs 25:21
`define op 31:26
`define imm26 25:0
`define imm16 15:0