.data 
array: .space 4000
xy: .space 4000

.macro end
li $v0,10
syscall
.end_macro

.macro getInt(%ans)
li $v0,5
syscall 
move %ans,$v0
.end_macro

.macro printInt(%src)
move $a0,%src
li $v0,1
syscall
.end_macro

.text
getInt($s0)		# s0 = n
addi $s0,$s0,1		# n = n+1
li $t0,1
sll $t1,$t0,2
sw $t0,array($t1)	# array[1] = 1
sw $t0,array($zero)	# array[0] = 0
li $t0,1 		# t0 use as 循环变量 (t0 = y)
for_1_begin:
beq $t0,$s0,for_1_end
lw $s1,array($zero)
addi $s1,$s1,1		# s1 = array[0] + 1 
li $t1,0		# use as 循环变量		
reset_xy_begin:		# memset(xy,0,sizeof(xy))
beq $t1,$s1,reset_xy_end
sll $t2,$t1,2
sw $zero,xy($t2)	# xy[i] = 0
addi $t1,$t1,1
j reset_xy_begin

reset_xy_end:
lw $s3,array($zero)	# s3 = array[0]
sw $s3,xy($zero)	# xy[0] = array[0]
addi $s3,$s3,1	
li $t1,1		# 作为循环变量 (t1 = i)
for_2_begin:	
beq $t1,$s3,for_2_end
sll $t2,$t1,2
lw $t3,xy($t2)		# t3 = xy[i]
lw $t4,array($t2)	# t4 = array[i]
mult $t4,$t0
mflo $t4		# t4 = a[i]*y
add $t3,$t3,$t4		# t3 += a[i]*y
li $s2,1000		# 压3位
div $t3,$s2
mflo $t6		# t6 = xy[i]/10
addi $t5,$t1,1
sll $t5,$t5,2
sw $t6,xy($t5)		# xy[i+1] = xy[i] /10
mfhi $t3		# t3 = xy[i] %10
sw $t3,xy($t2)		# xy[i] = t3
addi $t1,$t1,1	
j for_2_begin

for_2_end:
li $t1,0
lw $s1,xy($zero)	# s1 = xy[0]
addi $s1,$s1,1		# s1 = xy[0] + 1 
sll $t1,$s1,2
lw $s2,xy($t1)		# s2 = xy[xy[0]+1]
bgtz $s2,while_1_begin
j while_1_end

while_1_begin:
li $t2,1000		#压3位(补0输出)
div $s2,$t2		
mflo $t4		# t4 = xy[ xy[0]+1 ] / 10
addi $t5,$s1,1		# t1 = xy[0] + 2
sll $t3,$t5,2
sw $t4,xy($t3)		# xy[ xy[0] + 2 ] = xy[ xy[0]+1 ] / 10
mfhi $t4
sw $t4,xy($t1)		# xy[xy[0]+1] %= 10
lw $t1,xy($zero)	# t1 = xy[0]
addi $t1,$t1,1		
sw $t1,xy($zero)	# xy[0]++
j for_2_end

while_1_end:
li $t1,1		# t1 = i
lw $s1,xy($zero)	# s1 = xy[0]
addi $s1,$s1,1
for_3_begin:
beq $t1,$s1,for_3_end
sll $t2,$t1,2
lw $t3,xy($t2)		# t3 = xy[i]
sw $t3,array($t2)	# array[i] = xy[i]
addi $t1,$t1,1
j for_3_begin

 for_3_end:
 lw $t1,xy($zero)	# t1 = xy[0]
 sw $t1,array($zero)	# array[0] = xy[0]
 addi $t0,$t0,1
 j for_1_begin
 
 for_1_end:
 lw $s1,array($zero)	# s1 = array[0]
 move $t0,$s1		# t0 = a[0]
 sll $t2,$t0,2
 lw $t2,array($t2)	# t2 = array[i]
 printInt($t2)		#先输出第一个（三位）数
 addi $t0,$t0,-1	# t0 = i-1 循环变量
 for_4_begin:
 beq $t0,$zero,for_4_end	
 sll $t2,$t0,2
 lw $t2,array($t2)	# t2 = array[i]
 li $s2,100
 div $t2,$s2		
 mflo $t2
 printInt($t2)
 mfhi $t2
 li $s2,10
 div $t2,$s2
 mflo $t2
 printInt($t2)
 mfhi $t2
 printInt($t2)
 addi $t0,$t0,-1
 j for_4_begin
 for_4_end:
 end
 
  
   
     


















