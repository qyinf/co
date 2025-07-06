.data:
a:.space 256
flg:.space 256

.macro push(%src)
	sw %src,0($sp)
	subi $sp,$sp,4
.end_macro

.macro pop(%src)
	addi $sp,$sp,4
	lw %src,0($sp)
.end_macro

.macro getIndex(%ans,%i,%j,%rank)
	multu %i,%rank
	mflo %ans
	addu %ans,%ans,%j
	sll %ans,%ans,2
.end_macro

.macro scanf(%des)
	li $v0,5
	syscall
	move %des,$v0
.end_macro

.macro print(%des)
	move $a0,%des
	li $v0,1
	syscall
.end_macro

.text:

scanf($s0)
scanf($s1)
li $t0,0
li $t1,0
li $t2,0
li $t3,0
for_i_begin:
	beq $t0,$s0,for_i_end
	li $t1,0
	for_j_begin:
		beq $t1,$s1,for_j_end
		getIndex($t2,$t0,$t1,$s1)
		scanf($t3)
		sw $t3,a($t2)
		addi $t1,$t1,1
		j for_j_begin
	for_j_end:
		addi $t0,$t0,1
		j for_i_begin
for_i_end:
li $t0,0

scanf($s2)
scanf($s3)
scanf($s4)
scanf($s5)
addi $s2,$s2,-1
addi $s3,$s3,-1
addi $s4,$s4,-1
addi $s5,$s5,-1
move $a0,$s2
move $a1,$s3
jal dfs
print($a3)
li $v0,10
syscall

dfs:
push($ra)
push($a2)
push($t0)
push($t1)
push($t2)
push($t3)
push($t4)
push($t5)
push($t6)
push($t7)
push($t8)
push($t9)
push($s6)
push($s7)

move $t0,$a0
move $t1,$a1


bltz $t0,dfs_end
bltz $t1,dfs_end
beq $t0,$s0,dfs_end
beq $t1,$s1,dfs_end

if1:
beq $t0,$s4,if2
j main
if2:
beq $t1,$s5,find
j main
find:
addi $a3,$a3,1
j dfs_end

main:
getIndex($t2,$t0,$t1,$s1)
lw $t3,a($t2)
lw $t4,flg($t2)
bne $t3,$0,dfs_end
bne $t4,$0,dfs_end


getIndex($t2,$t0,$t1,$s1)
li $t3,1
sw $t3,flg($t2)

to_north:
addi $t2,$t0,0
addi $t3,$t1,-1
move $a0,$t2
move $a1,$t3
jal dfs

to_east:
addi $t2,$t0,1
addi $t3,$t1,0
move $a0,$t2
move $a1,$t3
jal dfs

to_south:
addi $t2,$t0,0
addi $t3,$t1,1
move $a0,$t2
move $a1,$t3
jal dfs

to_west:
addi $t2,$t0,-1
addi $t3,$t1,0
move $a0,$t2
move $a1,$t3
jal dfs

getIndex($t5,$t0,$t1,$s1)
sw $0,flg($t5)

dfs_end:
pop($s7)
pop($s6)
pop($t9)
pop($t8)
pop($t7)
pop($t6)
pop($t5)
pop($t4)
pop($t3)
pop($t2)
pop($t1)
pop($t0)
pop($a2)
pop($ra)
jr $ra
nop

