.macro push(%des)
	sw %des,0($sp)
	subi $sp,$sp,4
.end_macro

.macro pop(%des)
	addi $sp,$sp,4
	lw %des,0($sp)
.end_macro

.macro getInt(%des)
	li $v0,5
	syscall
	move %des,$v0
.end_macro

.macro printInt(%des)
	move $a0,%des
	li $v0,1
	syscall
.end_macro

.macro getIndex(%ans,%i,%j)
	sll %ans,%i,3
	add %ans,%ans,%j
	sll %ans,%ans,2
.end_macro

.data
G:.space 256
book:.space 32
.text:
getInt($s0)
getInt($s1)
li $t0,0
for_begin:
	beq $t0,$s1,for_end
	getInt($t1)
	getInt($t2)
	addi $t1,$t1,-1
	addi $t2,$t2,-1
	li $t4,1
	getIndex($t3,$t1,$t2)
	sw $t4,G($t3)
	getIndex($t3,$t2,$t1)
	sw $t4,G($t3)
	addi $t0,$t0,1
	j for_begin
for_end:
	move $a0,$0
	jal dfs
	printInt($s2)
	li $v0,10
	syscall
	
dfs:
push($ra)
push($t0)
push($t1)
push($t2)
push($t3)
push($t4)
move $t0,$a0
sll $t1,$t0,2
li $t2,1
sw $t2,book($t1)

li $t1,0
for1_begin:
	beq $t1,$s0,for1_end
	sll $t3,$t1,2
	lw $t4,book($t3)
	and $t2,$t2,$t4
	addi $t1,$t1,1
	j for1_begin
for1_end:
getIndex($t3,$t0,$0)
lw $t4,G($t3)
and $t2,$t2,$t4
beq $t2,$0,else
li $s2,1
j dfs_end
else:
li $t1,0
for2_begin:
	beq $t1,$s0,for2_end
	sll $t2,$t1,2
	lw $t3,book($t2)
	beq $t3,$0,if2
	if1:
	li $t3,0
	j if_end
	if2:
	li $t3,1
	if_end:
	getIndex($t2,$t0,$t1)
	lw $t4,G($t2)
	and $t4,$t4,$t3
	beq $t4,$0,elsee
	move $a0,$t1
	jal dfs
	elsee:
	addi $t1,$t1,1
	j for2_begin

	for2_end:
	sll $t0,$t0,2
	sw $0,book($t0)
	j dfs_end
	
dfs_end:
pop($t4)
pop($t3)
pop($t2)
pop($t1)
pop($t0)
pop($ra)
jr $ra
