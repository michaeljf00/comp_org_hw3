#############################################################################	
#############################################################################
## Assignment 3: Michael Fababeir
#############################################################################
#############################################################################

#############################################################################
#############################################################################
## Data segment
#############################################################################
#############################################################################	
		.data
matrix_a:	.word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
matrix_b:	.word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
swap:	        .word 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,  0,  0,  0,  0,  0,  0	
result:	        .word 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,  0,  0,  0,  0,  0,  0
	
newline:        .asciiz "\n"
tab:	        .asciiz "\t"
		

#############################################################################	
#############################################################################
## Text segment
#############################################################################
#############################################################################
	
		.text		       # this is program code
		.align 2	       # instructions must be on word boundaries
		.globl main	       # main is a global label
	        .globl matrix_swap
	        .globl matrix_multiply
	        .globl matrix_print

#############################################################################	
main:
#############################################################################
		# alloc stack and store $ra
		sub $sp, $sp, 4
		sw $ra, 0($sp)

	        # load matrix A, swap and N into arg regs
	        la $a0, matrix_a
	        la $a1, swap
                li $a2, 4
	        jal matrix_swap
	
		# load A, B and C and N into arg regs
		la $a0, swap
		la $a1, matrix_b
		la $a2, result
	        li $a3, 4
		jal matrix_multiply

		la $a0, result
		jal matrix_print

		# restore $ra, free stack and return
		lw $ra, 0($sp)
		add $sp, $sp, 4
		jr $ra

##############################################################################
matrix_swap: 
##############################################################################
# does matrix swap for a specific 4x4 matrix like assignment 1.
# This is a leaf function and can be done without any stack allocation.
# It is ok if you use the stack.

	
	        # Loop Variables
	        add $t0, $zero, $zero
	        add $t1, $zero, $zero

	        add $t3, $a0, $zero    #t3 = matrix_a[0]
	        add $t4, $a1, $zero    #t4 = swap[0]

	
LS1:            # Copy Matrix
	        slt  $t5, $t0, $a2
                beq  $t5, $zero, EOLS1
                add  $t1, $zero, $zero              

LS2:            # Copy Row
	        slt  $t5, $t1, $a2
	        beq  $t5, $zero, EOLS2
	
	        lw   $t2, 0($t3)       # t2 = matirx_a[i][j]
	        sw   $t2, 0($t4)       # swap[i][j] = t2
	       
	        addi $t3, $t3, 4  
	        addi $t4, $t4, 4
	    
	        addi $t1, $t1, 1       # increment for L2
	        j    LS2               # jump to L2

EOLS2:
	        addi $t0, $t0, 1       # increment for L1
                j    LS1               # jump to L1

EOLS1:		
	        # Swap matrices
	        # Loop variables (Re-establish starting index of both)
	        add $t0, $zero, $zero
	        add $t1, $zero, $zero

	        add $t4, $a1, $zero
	
	        addi $t6, $a2, -2      # size - 2

	
L1swap:
	        slt $t5, $t0, $a2
	        beq $t5, $zero, EOL1swap
	        add $t1, $zero, $zero
	
L2swap:
	        # Swap columns
                slt $t5, $t1, $t6
	        beq $t5, $zero, EOL2swap
	
	        lw  $t2, 0($t4)         # t2 = swap[i][j]
	        lw  $t7, 8($t4)         # t7 = swap[i][j+2]
	        sw  $t7, 0($t4)         # swap[i][j] = t7
	        sw  $t2, 8($t4)         # swap[i][j+2] = t2
 
	        addi $t4, $t4, 4        # Increment swap array
	     
	        addi $t1, $t1, 1        # Increment L2swap
                j    L2swap
	
EOL2swap:
	        addi $t0, $t0, 1        # Increment L1swap
	        addi $t4, $t4, 8        # Move to next row
	        j    L1swap
EOL1swap:	
	        jr $ra
	
##############################################################################
matrix_multiply: 
##############################################################################
# mult matrices swap and B together of square size N and store in result.
	

		# alloc stack and store regs.
		sub $sp, $sp, 24
	        sw $ra, 0($sp)
	        sw $a0, 4($sp)
	        sw $a1, 8($sp)
	        sw $s0, 12($sp)
	        sw $s1, 16($sp)
	        sw $s2, 20($sp)

	        add $t6, $a0, $zero     # swap (matrix)
	        add $t7, $a1, $zero     # matrix_b

	        # setup for i loop
	        add $s0, $zero, $zero
L1mult:
	        beq $s0, $a3, EOL1mult

	
	
	        # setup for j loop
	        add $s1, $zero, $zero
L2mult:
	        beq $s1, $a3, EOL2mult

	
                # setup for k loop	
                add $s2, $zero, $zero
L3mult:
	        beq $s2, $a3, EOL3mult
	
                # compute matrix_b[i][k] address and load into $t5
                add $t0, $s0, $s0     # 2i
	        add $t0, $t0, $t0     # 4i
	        add $t0, $t0, $t0     # 8i
	        add $t0, $t0, $t0     # 16i

	        add $t1, $s2, $s2     # 2k
	        add $t1, $t1, $t1     # 4k
	        add $t0, $t0, $t1     # 16i + 4k
	        add $t0, $t0, $a1     # address of swap[i][k]
                 
	        lw  $t2, ($t0)        # t2 = swap[i][k]
	
                # compute swap[k][j] address and load into $t7
	        add $t3, $s2, $s2     # 2k
	        add $t3, $t3, $t3     # 4k
	        add $t3, $t3, $t3     # 8k
	        add $t3, $t3, $t3     # 16k

	        add $t4, $s1, $s1     # 2j
	        add $t4, $t4, $t4     # 4j
	        add $t3, $t3, $t4     # 16k + 4j
	        add $t3, $t3, $a0     # address of matrix_b[k][j]

	        lw  $t5, ($t3)        # t5 = matrix[k][j]  

		# invoke mul instruction or create you own integer multiple routine
                mul $t5, $t5, $t2     # t2 * t5

	        add $t0, $s0, $s0     # 2i
	        add $t0, $t0, $t0     # 4i
	        add $t0, $t0, $t0     # 8i
	        add $t0, $t0, $t0     # 16i

	        add $t1, $s1, $s1     # 2j
	        add $t1, $t1, $t1     # 4j
	        add $t0, $t0, $t1     # 16i + 4j
	        add $t0, $t0, $a2     # address of result[i][j]

	        lw  $t6, ($t0)        # t6 = result[i][j] 
	
	        add $t6, $t5, $t6     # t5 + t6
	        sw  $t6, ($t0)        # results[i][j] = t6 

	
	        # increment k and jump back or exit
	        addi $s2, $s2, 1
	        j    L3mult

	
EOL3mult:
                # Increment j and jump back or exit
	        addi $s1, $s1, 1
	        j    L2mult
	
EOL2mult:	#Increment i and jump back or exit 
	        addi $s0, $s0, 1
	        j    L1mult
	
EOL1mult:	
		# retore saved regs from stack
		lw $s2, 20($sp)
	        lw $s1, 16($sp)
		lw $s0, 12($sp)
		lw $a1, 8($sp)
		lw $a0, 4($sp)
	        lw $ra, 0($sp)
	
		# free stack and return
		add $sp, $sp, 24
		jr $ra


##############################################################################
matrix_print:
##############################################################################
		# alloc stack and store regs.
		sub $sp, $sp, 16
	        sw $ra, 0($sp)
	        sw $s0, 4($sp)
	        sw $s1, 8($sp)
		sw $a0, 12($sp)
	
		# do two for loops here
	        add  $s0, $zero, $zero
	        add  $s1, $zero, $zero
	        add  $t4, $a0,   $zero

L1:
	        slti $t1, $s0, 4
	        beq  $t1, $zero, EOL1
	        add  $s1, $zero, $zero
	
L2:
	        slti $t2, $s1, 4
	        beq  $t2, $zero, EOL2
	        li   $v0, 1
	        lw   $a0, ($t4)
	        syscall
	        addi $t4, $t4, 4
	        li   $v0, 4
	        la   $a0, tab
	        syscall
	        addi $s1, $s1, 1
	        j    L2
	
EOL2:	
	        li   $v0, 4
	        la   $a0, newline
	        syscall
	        addi $s0, $s0, 1
	        j    L1

EOL1:	
	        # setup to jump back and return

	        lw $ra, 0($sp)
	        lw $s0, 4($sp)
	        lw $s1, 8($sp)
		lw $a0, 12($sp)
		add $sp, $sp, 16
		jr $ra
	
