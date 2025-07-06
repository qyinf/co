.macro getChar(%des)
	li $v0,12
	syscall
	move %des,$v0
.end_macro

.macro printChar(%des)
	move $a0,%des
	li $v0,11
	syscall
.end_macro


.macro printInt(%des)
	move $a0,%des
	li $v0,1
	syscall
.end_macro

.data
str:.asciiz "abcde dslkj"
key:.space 60
.text
la $a0,key
la $a1,10
li $v0,8
syscall
la $s0,str
la $s1,key
li $s2,10

while:
	lb $t0,0($s0)
	lb $t1,0($s1)
	beq $t1,$s2,find
	beqz $t0,not_find
	bne $t0,$t1,else
	addi $s0,$s0,1
	addi $s1,$s1,1
	j while
	else:
		la $s1,key
		addi $s0,$s0,1
		j while

	find:
	li $t0,1
	printInt($t0)
	j end
	
	not_find:
	li $t0,0
	printInt($t0)
	j end
	
	end:
	li $v0,10
	syscall
	