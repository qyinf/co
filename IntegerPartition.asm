.macro scanf(%des)
    li $v0,5
    syscall
    move %des,$v0
.end_macro

.macro printInt(%des)
    move $a0,%des
    li $v0,1
    syscall
.end_macro

.macro end()
    li $v0,10
    syscall
.end_macro

.macro printChar(%des)
	la $a0,%des
	li $v0,4
	syscall
.end_macro

.macro push(%des)
	sw %des,0($sp)
	subi $sp,$sp,4
.end_macro

.macro pop(%des)
	addi $sp,$sp,4
	lw %des,0($sp)
.end_macro

.data:
a:.space 400
plus:.asciiz "+"
enter:.asciiz "\n"

.text:
li $s1,1
scanf($s0)
move $a1,$s0
move $a2,$s1
jal dfs
end()

dfs:
push($ra)
push($t0)
push($t1)
push($t2)
push($t3)
push($t4)
push($s2)
move $t0,$a1
move $t1,$a2
beq $t0,$0,print
elsee:
li $t2,1
for_begin:
    addi $t3,$t1,-1
    sll $t3,$t3,2
    lw $t4,a($t3)
    if1:
        bgt $t4,$t2,else
    if2:
    	bge $t2,$s0,else
    sll $t3,$t1,2
    sw $t2,a($t3)
    sub $t0,$t0,$t2
    addi $t3,$t1,1
    move $a1,$t0
    move $a2,$t3
    jal dfs
    add $t0,$t0,$t2
    else:
    beq $t2,$t0,for_end
    addi $t2,$t2,1
    j for_begin
print:
li $t0,1
addi $t1,$t1,-1
for1_begin:
	beq $t0,$t1,for1_end
	sll $t2,$t0,2
	lw $t3,a($t2)
	printInt($t3)
	printChar(plus)
	addi $t0,$t0,1
	j for1_begin
for1_end:
sll $t2,$t1,2
lw $t3,a($t2)
printInt($t3)
printChar(enter)

for_end:
pop($s2)
pop($t4)
pop($t3)
pop($t2)
pop($t1)
pop($t0)
pop($ra)
jr $ra
    




