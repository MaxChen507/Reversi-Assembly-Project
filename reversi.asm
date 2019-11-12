.data
boardPieces:			.space	64
numX:				.word	2
numO:				.word	2
welcomeMessage:			.asciiz	"Welcome to Reversi!\nThe human player is represented by 'X', and the computer is represented by 'O'.\nPlease enter player move in the format of 'Row''Col' (e.g. \"A5\" or \"a5\")\n\n"
playerTurnText:			.asciiz	"It is the player's turn.\n\n"
computerTurnText:		.asciiz	"It is the computers's turn.\n\n"
newline:			.asciiz "\n"
columnNumbers:			.asciiz	"    1   2   3   4   5   6   7   8\n"
boardHorizontalLine:		.asciiz	"  +---+---+---+---+---+---+---+---+\n"
boardVerticalLine:		.asciiz " | "
countX:				.asciiz	"           X: "
countO:				.asciiz	"       O: "
playerWins:			.asciiz "Player Wins\n"
computerWins:			.asciiz	"Computer Wins\n"
tie:				.asciiz	"Tie\n"
playerCantPlay:			.asciiz "Player can't play\n\n"
computerCantPlay:		.asciiz "Computer can't play\n\n"
playerPrompt:			.asciiz	"Enter your move: "
invalidInputText:		.asciiz	"Invalid Input\n\n"
invalidMoveSpaceOccupied:	.asciiz	"Invalid Move, this space is occupied by another piece\n\n"
invalidMoveNoFlips:		.asciiz	"Invalid Move, this move will not flip any pieces\n\n"
input:				.asciiz	""

#----------------------------------------------------------------------------------------------------

.text
main:			li $v0, 4
			la $a0, welcomeMessage
			syscall
			li $s0, 0
			li $s1, 64
			li $s2, 32	# $s2 = ' '
initializeBoard:	beq $s0, $s1, endInitializeBoard	# memset(boardPieces, ' ', 64 * sizeof(char));
			sb $s2, boardPieces($s0)
			addi $s0, $s0, 1
			j initializeBoard
endInitializeBoard:	li $s0, 79	# $s0 = 'O'
			sb $s0, boardPieces + 27	# boardPieces[27] = 'O'
			sb $s0, boardPieces + 36	# boardPieces[36] = 'O'
			li $s0, 88	# $s0 = 'X'
			sb $s0, boardPieces + 28	# boardPieces[28] = 'X'
			sb $s0, boardPieces + 35	# boardPieces[35] = 'X'
			li $s0, 1	# playerCanPlay = true
			li $s1, 1	# computerCanPlay = true
			li $s2, 1	# playerTurn = true
playGame:		lw $s3, numX
			lw $s4, numO
			add $s3, $s3, $s4
			beq $s3, 64, endGame
			or $s3, $s0, $s1	# $s3 = playerCanPlay or ComputerCanPlay
			beq $s3, $zero, endGame
			move $a1, $s2
			beq $s2, $zero, computerTurn
			li $a0, 1
			jal printBoard
			jal playerMove
			move $s0, $v0	# playerCanPlay = return value of playerMove
			li $s2, 0	# playerTurn = false
			j playGame
computerTurn:		jal printBoard
			jal delay
			jal computerMove
			move $s1, $v0	# computerCanPlay = return value of computerMove
			li $s2, 1	# playerTurn = true
			j playGame
endGame:		li $v0, 4
			la $a0, newline
			syscall
			li $a1, 2
			jal printBoard
			lw $s0, numX	# $s0 = numX
			lw $s1, numO	# $s1 = numO
			sgt $s2, $s0, $s1	# $s2 = numX > numO
			beq $s2, $zero, playerDidNotWin
			la $a0, playerWins
			syscall
			j exit
playerDidNotWin:	sgt $s2, $s1, $s0	# $s2 = numO > numX
			beq $s2, $zero, tieGame
			la $a0, computerWins
			syscall
			j exit
tieGame:		la $a0, tie
			syscall
			j exit

#----------------------------------------------------------------------------------------------------
	
# printBoard subroutine
printBoard:		li $t0, 0
			li $t1, 100
			li $v0, 4
			la $a0, newline
clearOutput:		syscall
			addi $t0, $t0, 1
			bne $t0, $t1, clearOutput
			beq $a1, 2, afterTurnText
			la $a0, welcomeMessage
			syscall
			beq $a1, $zero, computerTurnMessage
			la $a0, playerTurnText
			syscall
			j afterTurnText
computerTurnMessage:	la $a0, computerTurnText
			syscall
afterTurnText:		li $t0, 65	# $t0 = 'A'
			li $v0, 4
			la $a0, columnNumbers
			syscall
			la $a0, boardHorizontalLine
			syscall
			li $t1, 0 	# i = 0
			li $t2, 8
boardLoop1:		beq $t1, $t2, endBoardLoop1	# for (i = 0; i < 8; i++)
			li $v0, 11
			move $a0, $t0
			syscall
			addi $t0, $t0, 1	# $t0 = next letter
			li $v0, 4
			la $a0, boardVerticalLine
			syscall
			li $t3, 0	# j = 0
			li $t4, 8
boardLoop2:		beq $t3, $t4, endBoardLoop2	# for (j = 0; j < 8; j++)
			mul $t5, $t1, 8		# $t5 = (8 * $t1) + $t3
			add $t5, $t5, $t3
			li $v0, 11
			lb $a0, boardPieces($t5)
			syscall
			li $v0, 4
			la $a0, boardVerticalLine
			syscall
			addi $t3, $t3, 1	# j++
			j boardLoop2
endBoardLoop2:		li $v0, 4
			la $a0, newline
			syscall
			la $a0, boardHorizontalLine
			syscall
			addi $t1, $t1, 1	# i++
			j boardLoop1
endBoardLoop1:		li $v0, 4
			la $a0, newline
			syscall
			la $a0, countX
			syscall
			li $v0, 1
			lw $a0, numX
			syscall
			li $v0, 4
			la $a0, countO
			syscall
			li $v0, 1
			lw $a0, numO
			syscall
			li $v0, 4
			la $a0, newline
			syscall
			la $a0, newline
			syscall
			jr $ra

#----------------------------------------------------------------------------------------------------

# delay subroutine
delay:		li $t0, 0
		li $t1, 2000000
delayLoop:	addiu $t0, $t0, 1
		bne $t0, $t1, delayLoop
		jr $ra
		
#------------------------------------------------------------------------------------

# playerMove subroutine
playerMove:			addi $sp, $sp, -4
				sw $ra, 0($sp)
				jal playerValidMoveExists
				beq $v0, $zero, playerValidMoveDoesNotExist
				jal readMove
				move $a0, $v0
				jal placePlayerPiece
				li $v0, 1
				lw $ra, 0($sp)
				addi $sp, $sp, 4
				jr $ra
playerValidMoveDoesNotExist:	li $v0, 4
				la $a0, playerCantPlay
				syscall
				jal delay
				li $v0, 0
				lw $ra, 0($sp)
				addi $sp, $sp, 4
				jr $ra

#----------------------------------------------------------------------------------------------------

# playerValidMoveExists subroutine
playerValidMoveExists:		addi $sp, $sp, -12
				sw $s1, 8($sp)
				sw $s0, 4($sp)
				sw $ra, 0($sp)
				li $s0, 0	# i = 0
				li $s1, 64
playerValidMoveExistsLoop:	beq $s0, $s1, endPlayerValidMoveExistsLoop	# for (i = 0; i < 64; i++)
				move $a0, $s0
				jal isPlayerMoveValid
				bne $v0, $zero, endPlayerValidMoveExistsLoop
				addi $s0, $s0, 1	# i++
				j playerValidMoveExistsLoop
endPlayerValidMoveExistsLoop:	lw $ra, 0($sp)
				lw $s0, 4($sp)
				lw $s1, 8($sp)
				addi $sp, $sp, 12
				jr $ra

#----------------------------------------------------------------------------------------------------
								
# isPlayerMoveValid subroutine
isPlayerMoveValid:		addi $sp, $sp, -8
				sw $a0, 4($sp)
				sw $ra, 0($sp)
				li $v0, 0	# $v0 = false
				li $v1, 0	# $v1 = false
				li $t0, 32	# $t0 = ' '
				lb $t1, boardPieces($a0) # $t1 = boardPieces[$a0]
				bne $t0, $t1, isPlayerMoveValidReturn	# branches to isPlayerMoveValidReturn if boardPieces[$a0] != ' '
				li $v1, 1	# $v1 = true
				jal playerCheckUp
				bne $v0, $zero, isPlayerMoveValidReturn		# branches to isPlayerMoveValidReturn if playerCheckUp is true
				lw $a0, 4($sp)
				jal playerCheckRight
				bne $v0, $zero, isPlayerMoveValidReturn		# branches to isPlayerMoveValidReturn if playerCheckRight is true
				lw $a0, 4($sp)
				jal playerCheckDown
				bne $v0, $zero, isPlayerMoveValidReturn		# branches to isPlayerMoveValidReturn if playerCheckDown is true
				lw $a0, 4($sp)
				jal playerCheckLeft
				bne $v0, $zero, isPlayerMoveValidReturn		# branches to isPlayerMoveValidReturn if playerCheckLeft is true
				lw $a0, 4($sp)
				jal playerCheckUpLeft
				bne $v0, $zero, isPlayerMoveValidReturn		# branches to isPlayerMoveValidReturn if playerCheckUpLeft is true
				lw $a0, 4($sp)
				jal playerCheckUpRight
				bne $v0, $zero, isPlayerMoveValidReturn		# branches to isPlayerMoveValidReturn if playerCheckUpRight is true
				lw $a0, 4($sp)
				jal playerCheckDownRight
				bne $v0, $zero, isPlayerMoveValidReturn		# branches to isPlayerMoveValidReturn if playerCheckDownRight is true
				lw $a0, 4($sp)
				jal playerCheckDownLeft
isPlayerMoveValidReturn:	lw $ra 0($sp)
				addi $sp, $sp, 8
				jr $ra

#----------------------------------------------------------------------------------------------------

# readMove subroutine
readMove:	addi $sp, $sp, -16
		sw $s2, 12($sp)
		sw $s1, 8($sp)
		sw $s0, 4($sp)
		sw $ra, 0($sp)
		li $s0, 10	# $s0 = '\n'
		li $s1, 2	# $s1 = 2
readMoveLoop:	li $v0, 4
		la $a0, playerPrompt
		syscall
		li $v0, 8
		la $a0, input
		li $a1, 2
read:		syscall		# reads a character
		lb $t0, 0($a0)	# $t0 = read character
		beq $t0, $s0, endRead	# branches to endRead if $t0 == '\n'
		addi $a0, $a0, 1	# sets $a0 to the next byte in memory
		j read
endRead:	la $t0, input 	# $t0 = address of input
		sub $t0, $a0, $t0	# $t0 = address of last read character - address of input
		bne $t0, $s1, invalidInput	# branches to invalidInput if $t0 != 2
		lb $t0, input		# $t0 = first charater
		lb $t1, input + 1	# $t1 = second character
		sge $t2, $t0, 65	# $t2 = $t0 >= 'A'
		sle $t3, $t0, 72	# $t3 = $t0 <= 'H'
		and $t2, $t2, $t3	# $t2 = 'A' <= $t0 <= 'H'
		sge $t3, $t0, 97	# $t3 = $t0 >= 'a'
		sle $t4, $t0, 104	# $t4 = $t0 <= 'h'
		and $t3, $t3, $t4	# $t2 = 'a' <= $t0 <= 'h'
		or $t2, $t2, $t3	# $t2 = ('A' <= $t0 <= 'H') || ('a' <= $t0 <= 'h')
		sge $t3, $t1, 49	# $t3 = $t1 >= '1'
		sle $t4, $t1, 56	# $t4 = $t1 <= '8'
		and $t3, $t3, $t4	# $t3 = '1' <= $t1 <= '8'
		and $t2, $t2, $t3	# $t2 = (('A' <= $t0 <= 'H') || ('a' <= $t0 <= 'h')) && ('1' <= $t1 <= '8')
		beq $t2, $zero, invalidInput
		jal convertToBoardLocation	# returns the int value of a valid input
		move $s2, $v0	# $s2 = int value of valid input
		move $a0, $v0	# $a0 = int value of valid input
		jal isPlayerMoveValid
		beq $v0, $zero, invalidMove
		li $v0, 4
		la $a0, newline
		syscall
		move $v0, $s2	# $v0 = int value of valid move
		lw $ra, 0($sp)
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		addi $sp, $sp, 16
		jr $ra
invalidInput:	li $v0, 4
		la $a0, invalidInputText
		syscall
		j readMoveLoop
invalidMove:	li $v0, 4
		beq $v1, 1, noFlips
		la $a0, invalidMoveSpaceOccupied
		syscall
		j readMoveLoop
noFlips:	la $a0, invalidMoveNoFlips
		syscall
		j readMoveLoop
		
#----------------------------------------------------------------------------------------------------

# convertToBoardLocation subroutine
convertToBoardLocation:	lb $v0, input		# $v0 = first character
			lb $t0, input + 1	# $t0 = second character
			li $t1, 97	# $t1 = 'a'
			bge $v0, $t1, convert	# branches to convert if $v0 >= 'a'
			li $t1, 65	# $t1 = 'A'
convert:		sub $v0, $v0, $t1	
			mul $v0, $v0, 8	
			subi $t0, $t0, 49
			add $v0, $v0, $t0	# $v0 = (8 * ($v0 - $t1)) + ($t0 - '1')
			jr $ra

#----------------------------------------------------------------------------------------------------
			
# placePlayerPiece subroutine
placePlayerPiece:	addi $sp, $sp, -8
			sw $a0, 4($sp)
			sw $ra, 0($sp)
			li $t0, 88	# $t0 = 'X'
			sb $t0, boardPieces($a0)	# boardPieces[$a0] = 'X'
			lw $t0, numX
			addi $t0, $t0, 1	# numX++
			sw $t0, numX
			jal playerFlipUp
			lw $a0, 4($sp)
			jal playerFlipRight
			lw $a0, 4($sp)
			jal playerFlipDown
			lw $a0, 4($sp)
			jal playerFlipLeft
			lw $a0, 4($sp)
			jal playerFlipUpLeft
			lw $a0, 4($sp)
			jal playerFlipUpRight
			lw $a0, 4($sp)
			jal playerFlipDownRight
			lw $a0, 4($sp)
			jal playerFlipDownLeft
			lw $ra, 0($sp)
			addi $sp, $sp, 8
			jr $ra

#----------------------------------------------------------------------------------------------------

# computerMove subroutine
computerMove:			addi $sp, $sp, -4
				sw $ra, 0($sp)
				jal getComputerMove
				li $t0, -1
				beq $v0, $t0, computerValidMoveDoesNotExist	
				move $a0, $v0
				jal placeComputerPiece
				li $v0, 1
				lw $ra, 0($sp)
				addi $sp, $sp, 4
				jr $ra
computerValidMoveDoesNotExist:	li $v0, 4
				la $a0, computerCantPlay
				syscall
				jal delay
				li $v0, 0
				lw $ra, 0($sp)
				addi $sp, $sp, 4
				jr $ra

#----------------------------------------------------------------------------------------------------
								
# getComputerMove subroutine
getComputerMove:	addi $sp, $sp, -4
			sw $ra, 0($sp)
			jal getComputerEdgeMove
			li $t0, -1
			bne $v0, $t0, getComputerMoveReturn	# branches to getComputerMoveReturn if edge move exists 
			jal getComputerInsideMove
getComputerMoveReturn:	lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra

#----------------------------------------------------------------------------------------------------

# getComputerEdgeMove subroutine
getComputerEdgeMove:		addi $sp, $sp, -36
				sw $s7, 32($sp)
				sw $s6, 28($sp)
				sw $s5, 24($sp)
				sw $s4, 20($sp)
				sw $s3, 16($sp)
				sw $s2, 12($sp)
				sw $s1, 8($sp)
				sw $s0, 4($sp)
				sw $ra, 0($sp)
				li $s0, -1	# bestMove = -1
				li $s1, 0	# bestNumFlips = 0
				li $s2, 0	# i = 0
				li $s3, 64
				li $s4, 32	# $s4 = ' '
				li $s5, 8	# $s5 = 8
				li $s6, 55	# $s6 = 55
				li $s7, 7	# $s7 = 7
getComputerEdgeMoveLoop:	beq $s2, $s3, endGetComputerEdgeMoveLoop	# for (i = 0; i < 64; i++)
				lb $t0, boardPieces($s2)	# $t0 = boardPieces[i]
				bne $t0, $s4, getComputerEdgeMoveLoopNext	# branches to getComputerEdgeMoveLoopNext if boardPieces[i] != ' '
				blt $s2, $s5, getComputerEdgeMoveCheck		# branches to getComputerEdgeMoveCheck if i is in the first row
				bgt $s2, $s6, getComputerEdgeMoveCheck		# branches to getComputerEdgeMoveCheck if i is in the last row
				div $s2, $s5
				mfhi $t0	# $t0 = i % 8
				beq $t0, $zero, getComputerEdgeMoveCheck	# branches to getComputerEdgeMoveCheck if i is in the first column
				bne $t0, $s7, getComputerEdgeMoveLoopNext	# branches to getComputerEdgeMoveLoopNext if i is not in the last column
getComputerEdgeMoveCheck:	move $a0, $s2	# $a0 = i
				jal getComputerNumFlips
				bge $s1, $v0 getComputerEdgeMoveLoopNext	# branches to getComputerEdgeMoveLoopNext if bestNumFlips >= getComputerNumFlips(i)
				move $s0, $s2	# bestMove = i
				move $s1, $v0	# bestNumFlips = getComputerNumFlips(i)
getComputerEdgeMoveLoopNext:	addi $s2, $s2, 1	# i++
				j getComputerEdgeMoveLoop
endGetComputerEdgeMoveLoop:	move $v0, $s0	# $v0 = bestMove
				lw $ra, 0($sp)
				lw $s0, 4($sp)
				lw $s1, 8($sp)
				lw $s2, 12($sp)
				lw $s3, 16($sp)
				lw $s4, 20($sp)
				lw $s5, 24($sp)
				lw $s6, 28($sp)
				lw $s7, 32($sp)
				addi $sp, $sp, 36
				jr $ra		

#----------------------------------------------------------------------------------------------------

# getComputerInsideMove subroutine
getComputerInsideMove:		addi $sp, $sp, -32
				sw $s6, 28($sp)
				sw $s5, 24($sp)
				sw $s4, 20($sp)
				sw $s3, 16($sp)
				sw $s2, 12($sp)
				sw $s1, 8($sp)
				sw $s0, 4($sp)
				sw $ra, 0($sp)
				li $s0, -1	# bestMove = -1
				li $s1, 0	# bestNumFlips = 0
				li $s2, 9	# i = 9
				li $s3, 55	
				li $s4, 32	# $s4 = ' '
				li $s5, 8	# $s5 = 8
				li $s6, 7	# $s6 = 7
getComputerInsideMoveLoop:	beq $s2, $s3, endGetComputerInsideMoveLoop	# for (i = 9; i < 55; i++)
				lb $t0, boardPieces($s2)	# $t0 = boardPieces[i]
				bne $t0, $s4, getComputerInsideMoveLoopNext	# branches to getComputerInsideMoveLoopNext if boardPieces[i] != ' '
				div $s2, $s5
				mfhi $t0	# $t0 = i % 8
				beq $t0, $zero, getComputerInsideMoveLoopNext	# branches to getComputerInsideMoveLoopNext if i is in the first column
				beq $t0, $s6, getComputerInsideMoveLoopNext	# branches to getComputerInsideMoveLoopNext if i is in the last column
				move $a0, $s2	# $a0 = i
				jal getComputerNumFlips
				bge $s1, $v0 getComputerInsideMoveLoopNext	# branches to getComputerInsideMoveLoopNext if bestNumFlips >= getComputerNumFlips(i)
				move $s0, $s2	# bestMove = i
				move $s1, $v0	# bestNumFlips = getComputerNumFlips(i)
getComputerInsideMoveLoopNext:	addi $s2, $s2, 1	# i++
				j getComputerInsideMoveLoop
endGetComputerInsideMoveLoop:	move $v0, $s0	# $v0 = bestMove
				lw $ra, 0($sp)
				lw $s0, 4($sp)
				lw $s1, 8($sp)
				lw $s2, 12($sp)
				lw $s3, 16($sp)
				lw $s4, 20($sp)
				lw $s5, 24($sp)
				lw $s6, 28($sp)
				addi $sp, $sp, 32
				jr $ra
#----------------------------------------------------------------------------------------------------

# getComputerNumFlips
getComputerNumFlips:	addi $sp, $sp, -12
			sw $s0, 8($sp)
			sw $a0, 4($sp)
			sw $ra, 0($sp)
			jal getComputerNumFlipsUp
			move $s0, $v0	# $s0 = getComputerNumFlipsUp(i)
			lw $a0, 4($sp)
			jal getComputerNumFlipsRight
			add $s0, $s0, $v0	# $s0 += getComputerNumFlipsRight(i)
			lw $a0, 4($sp)
			jal getComputerNumFlipsDown
			add $s0, $s0, $v0	# $s0 += getComputerNumFlipsDown(i)
			lw $a0, 4($sp)
			jal getComputerNumFlipsLeft
			add $s0, $s0, $v0	# $s0 += getComputerNumFlipsLeft(i)
			lw $a0, 4($sp)
			jal getComputerNumFlipsUpLeft
			add $s0, $s0, $v0	# $s0 += getComputerNumFlipsUpLeft(i)
			lw $a0, 4($sp)
			jal getComputerNumFlipsUpRight
			add $s0, $s0, $v0	# $s0 += getComputerNumFlipsUpRight(i)
			lw $a0, 4($sp)
			jal getComputerNumFlipsDownRight
			add $s0, $s0, $v0	# $s0 += getComputerNumFlipsDownRight(i)
			lw $a0, 4($sp)
			jal getComputerNumFlipsDownLeft
			add $v0, $s0, $v0	# $v0 = $s0 + getComputerNumFlipsDownLeft(i)
			lw $ra, 0($sp)
			lw $s0, 8($sp)
			addi $sp, $sp, 12
			jr $ra

#----------------------------------------------------------------------------------------------------

# placeComputerPiece subroutine
placeComputerPiece:	addi $sp, $sp, -8
			sw $a0, 4($sp)
			sw $ra, 0($sp)
			li $t0, 79	# $t0 = 'O'
			sb $t0, boardPieces($a0)	# boardPieces[$a0] = 'O'
			lw $t0, numO
			addi $t0, $t0, 1	# numO++
			sw $t0, numO
			jal computerFlipUp
			lw $a0, 4($sp)
			jal computerFlipRight
			lw $a0, 4($sp)
			jal computerFlipDown
			lw $a0, 4($sp)
			jal computerFlipLeft
			lw $a0, 4($sp)
			jal computerFlipUpLeft
			lw $a0, 4($sp)
			jal computerFlipUpRight
			lw $a0, 4($sp)
			jal computerFlipDownRight
			lw $a0, 4($sp)
			jal computerFlipDownLeft
			lw $ra, 0($sp)
			addi $sp, $sp, 8
			jr $ra

#----------------------------------------------------------------------------------------------------

# playerCheckUp subroutine
playerCheckUp:	
	# int j = i - 8;			
	addi $t0, $a0, -8	#j = $t0, 	$i = a0
	#condtion 1
	sgt $t1, $a0, 15 	#$t1 is 1 if $a0 > 15
	#condition 2
	lb $t2, boardPieces($t0) #t2 = boardPieces[j]
	seq $t2, $t2, 79    #t2 is 1 if t2==79 else 0
	#and of c1, c2
	and $t1, $t1, $t2 	#t1 is 1 if c1 and c2 are true, else 0
	beq $t1, $0, playerCheckUpreturnFalse
	li $t2, 88	# $t2 = 'X'
	li $t3, 32	# $t3 = ' '
doloop_playerCheckUp:
	# j -= 8;	
	addi $t0, $t0, -8
	lb $t1, boardPieces($t0) #t1 = boardPieces[j]
	# (if boardPieces[j] == 'X') return true
	beq $t1, $t2, playerCheckUpreturnTrue	
	#if (boardPieces[j] == ' ') return false
	beq $t1, $t3, playerCheckUpreturnFalse
	#while (j > 7)
	bgt $t0, 7, doloop_playerCheckUp	
playerCheckUpreturnFalse:
	li $v0, 0
	jr $ra
playerCheckUpreturnTrue:
	li $v0, 1
	jr $ra

#----------------------------------------------------------------------------------------------------

playerCheckRight:
	# int j = i + 1;				
	addi $t0, $a0, 1	#j = $t0, 	$i = a0
	li $t1, 8
	div $a0, $t1
	mfhi $t1	# $t1 = i % 8
	#condtion 1:	(i % 8) != 6
	sne $t2, $t1, 6
	#condition 2:	(i % 8) != 7
	sne $t3, $t1, 7
	#and of c1, c2
	and $t1 $t2, $t3	# $t1 = ((i % 8) != 6) && ((i % 8) != 7)	
	#condition 3:	boardPieces[j] == 'O'
	lb $t2, boardPieces($t0) #t2 = boardPieces[j]
	seq $t2, $t2, 79    	#t2 is 1 if t2==79 ('O') else 0
	#and of (c1 && c2), c3
	and $t1, $t1, $t2	#t1 is 1 if (c1 && c2) and c3 are true, else 0
	beq $t1, $0, playerCheckRightreturnFalse
	li $t2, 88	# $t2 = 'X'
	li $t3, 32	# $t3 = ' '
doloop_playerCheckRight:
	# j += 1;	
	addi $t0, $t0, 1
	lb $t1, boardPieces($t0) #t1 = boardPieces[j]
	# (if boardPieces[j] == 'X') return true
	beq $t1, $t2, playerCheckRightreturnTrue	
	#if (boardPieces[j] == ' ') return false
	beq $t1, $t3, playerCheckRightreturnFalse
	#while ((j % 8) != 7)
	li $t1, 8
	div $t0, $t1
	mfhi $t1	# t1 = j % 8
	bne $t1, 7, doloop_playerCheckRight	
playerCheckRightreturnFalse:
	li $v0, 0
	jr $ra
playerCheckRightreturnTrue:
	li $v0, 1
	jr $ra

#----------------------------------------------------------------------------------------------------
playerCheckDown:
	# int j = i + 8;				
	addi $t0, $a0, 8	#j = $t0, 	$i = a0
	#condtion 1
	slti $t1, $a0, 48 	#$t1 is 1 if $a0 < 48
	#condition 2
	lb $t2, boardPieces($t0) #t2 = boardPieces[j]
	seq $t2, $t2, 79    #t2 is 1 if t2==79 else 0
	#and of c1, c2
	and $t1, $t1, $t2 	#t1 is 1 if c1 and c2 are true, else 0
	beq $t1, $0, playerCheckDownreturnFalse
	li $t2, 88	# $t2 = 'X'
	li $t3, 32	# $t3 = ' '
doloop_playerCheckDown:
	# j += 8;	
	addi $t0, $t0, 8
	lb $t1, boardPieces($t0) #t1 = boardPieces[j]
	# (if boardPieces[j] == 'X') return true
	beq $t1, $t2, playerCheckDownreturnTrue	
	#if (boardPieces[j] == ' ') return false
	beq $t1, $t3, playerCheckDownreturnFalse	
	#while (j < 56)
	blt $t0, 56, doloop_playerCheckDown	
playerCheckDownreturnFalse:
	li $v0, 0
	jr $ra
playerCheckDownreturnTrue:
	li $v0, 1
	jr $ra
#----------------------------------------------------------------------------------------------------

playerCheckLeft:
	# int j = i - 1;				
	addi $t0, $a0, -1	#j = $t0, 	$i = a0
	li $t1, 8
	div $a0, $t1
	mfhi $t1	# $t1 = i % 8
	#condtion 1:	(i % 8) != 0
	sne $t2, $t1, 0
	#condition 2:	(i % 8) != 1
	sne $t3, $t1, 1
	#and of c1, c2
	and $t1 $t2, $t3	# $t1 = ((i % 8) != 0) && ((i % 8) != 1)	
	#condition 3:	boardPieces[j] == 'O'
	lb $t2, boardPieces($t0) #t2 = boardPieces[j]
	seq $t2, $t2, 79    	#t2 is 1 if t2==79 ('O') else 0
	#and of (c1 && c2), c3
	and $t1, $t1, $t2	#t1 is 1 if (c1 && c2) and c3 are true, else 0
	beq $t1, $0, playerCheckLeftreturnFalse
	li $t2, 88	# $t2 = 'X'
	li $t3, 32	# $t3 = ' '
doloop_playerCheckLeft:
	# j -= 1;	
	addi $t0, $t0, -1
	lb $t1, boardPieces($t0) #t1 = boardPieces[j]
	# (if boardPieces[j] == 'X') return true
	beq $t1, $t2, playerCheckLeftreturnTrue	
	#if (boardPieces[j] == ' ') return false
	beq $t1, $t3, playerCheckLeftreturnFalse	
	#while ((j % 8) != 0)
	li $t1, 8
	div $t0, $t1
	mfhi $t1	# t1 = j % 8
	bne $t1, 0, doloop_playerCheckLeft	
playerCheckLeftreturnFalse:
	li $v0, 0
	jr $ra
playerCheckLeftreturnTrue:
	li $v0, 1
	jr $ra

#----------------------------------------------------------------------------------------------------

playerCheckUpLeft:
	# int j = i - 9;				
	addi $t0, $a0, -9	#j = $t0, 	$i = a0
	li $t1, 8
	div $a0, $t1
	mfhi $t1	# $t1 = i % 8
	#condition 0:	i > 15
	sgt $t2, $a0, 15 	#$t2 is 1 if $a0 > 15
	#condition 1:	(i % 8) != 0
	sne $t3, $t1, 0
	#condition 2:	(i % 8) != 1
	sne $t4, $t1, 1
	#and of c0, c1
	and $t1, $t2, $t3 	#t1 is 1 if c0 and c1 are true, else 0
	#and of (c0 && c1), c2
	and $t1, $t1, $t4 	#t1 is 1 if (c0 && c1) and c2 are true, else 0
	#condition 3:	$t5
	lb $t2, boardPieces($t0) #t2 = boardPieces[j]
	seq $t2, $t2, 79    	#t2 is 1 if t2==79 ('O') else 0
	#and of (c0 && c1 && c2), c3
	and $t1, $t1, $t2	#t1 is 1 if (c0 && c1 && c2) and c3 are true, else 0
	beq $t1, $0, playerCheckUpLeftreturnFalse
	li $t2, 88	# $t2 = 'X'
	li $t3, 32	# $t3 = ' '
doloop_playerCheckUpLeft:
	# j -= 9;	
	addi $t0, $t0, -9
	lb $t1, boardPieces($t0) #t1 = boardPieces[j]
	# (if boardPieces[j] == 'X') return true
	beq $t1, $t2, playerCheckUpLeftreturnTrue	
	#if (boardPieces[j] == ' ') return false
	beq $t1, $t3, playerCheckUpLeftreturnFalse
	#while (j > 7 && (j % 8) != 0)
	li $t1, 8
	div $t0, $t1
	mfhi $t1	# t1 = j % 8
	sne $t1, $t1, 0
	sgt $t4, $t0, 7
	and $t1, $t1, $t4
	bne $t1, $0, doloop_playerCheckUpLeft
playerCheckUpLeftreturnFalse:
	li $v0, 0
	jr $ra
playerCheckUpLeftreturnTrue:
	li $v0, 1
	jr $ra

#----------------------------------------------------------------------------------------------------

playerCheckUpRight:
	# int j = i - 7;				
	addi $t0, $a0, -7	#j = $t0, 	$i = a0
	li $t1, 8
	div $a0, $t1
	mfhi $t1	# $t1 = i % 8
	#condition 0:	i > 15
	sgt $t2, $a0, 15 	#$t2 is 1 if $a0 > 15
	#condition 1:	(i % 8) != 6
	sne $t3, $t1, 6
	#condition 2:	(i % 8) != 7
	sne $t4, $t1, 7
	#and of c0, c1
	and $t1, $t2, $t3 	#t1 is 1 if c0 and c1 are true, else 0
	#and of (c0 && c1), c2
	and $t1, $t1, $t4 	#t1 is 1 if (c0 && c1) and c2 are true, else 0
	#condition 3:	$t5
	lb $t2, boardPieces($t0) #t2 = boardPieces[j]
	seq $t2, $t2, 79    	#t2 is 1 if t2==79 ('O') else 0
	#and of (c0 && c1 && c2), c3
	and $t1, $t1, $t2	#t1 is 1 if (c0 && c1 && c2) and c3 are true, else 0
	beq $t1, $0, playerCheckUpRightreturnFalse
	li $t2, 88	# $t2 = 'X'
	li $t3, 32	# $t3 = ' '
doloop_playerCheckUpRight:
	# j -= 7;	
	addi $t0, $t0, -7
	lb $t1, boardPieces($t0) #t1 = boardPieces[j]
	# (if boardPieces[j] == 'X') return true
	beq $t1, $t2, playerCheckUpRightreturnTrue	
	#if (boardPieces[j] == ' ') return false
	beq $t1, $t3, playerCheckUpRightreturnFalse
	#wwhile (j > 7 && ((j % 8) != 7);
	li $t1, 8
	div $t0, $t1
	mfhi $t1	# t1 = j % 8
	sne $t1, $t1, 7
	sgt $t4, $t0, 7
	and $t1, $t1, $t4
	bne $t1, $0, doloop_playerCheckUpRight	
playerCheckUpRightreturnFalse:
	li $v0, 0
	jr $ra
playerCheckUpRightreturnTrue:
	li $v0, 1
	jr $ra

#----------------------------------------------------------------------------------------------------
playerCheckDownRight:
	# int j = i + 9;				
	addi $t0, $a0, 9	#j = $t0, 	$i = a0
	li $t1, 8
	div $a0, $t1
	mfhi $t1	# $t1 = i % 8
	#condition 0:	i < 48
	slti $t2, $a0, 48 	#$t2 is 1 if $a0 < 48
	#condition 1:	(i % 8) != 6
	sne $t3, $t1, 6
	#condition 2:	(i % 8) != 7
	sne $t4, $t1, 7
	#and of c0, c1
	and $t1, $t2, $t3 	#t1 is 1 if c0 and c1 are true, else 0
	#and of (c0 && c1), c2
	and $t1, $t1, $t4 	#t1 is 1 if (c0 && c1) and c2 are true, else 0
	#condition 3:	$t5
	lb $t2, boardPieces($t0) #t2 = boardPieces[j]
	seq $t2, $t2, 79    	#t2 is 1 if t2==79 ('O') else 0
	#and of (c0 && c1 && c2), c3
	and $t1, $t1, $t2	#t1 is 1 if (c0 && c1 && c2) and c3 are true, else 0
	beq $t1, $0, playerCheckDownRightreturnFalse
	li $t2, 88	# $t2 = 'X'
	li $t3, 32	# $t3 = ' '
doloop_playerCheckDownRight:
	# j += 9;	
	addi $t0, $t0, 9
	lb $t1, boardPieces($t0) #t1 = boardPieces[j]
	# (if boardPieces[j] == 'X') return true
	beq $t1, $t2, playerCheckDownRightreturnTrue	
	#if (boardPieces[j] == ' ') return false
	beq $t1, $t3, playerCheckDownRightreturnFalse
	#while (j < 56 && ((j % 8) != 7);
	li $t1, 8
	div $t0, $t1
	mfhi $t1	# t1 = j % 8
	sne $t1, $t1, 7
	slti $t4, $t0, 56
	and $t1, $t1, $t4
	bne $t1, $0, doloop_playerCheckDownRight	
playerCheckDownRightreturnFalse:
	li $v0, 0
	jr $ra
playerCheckDownRightreturnTrue:
	li $v0, 1
	jr $ra

#----------------------------------------------------------------------------------------------------

playerCheckDownLeft:
	# int j = i + 7;				
	addi $t0, $a0, 7	#j = $t0, 	$i = a0
	li $t1, 8
	div $a0, $t1
	mfhi $t1	# $t1 = i % 8
	#condition 0:	i < 48
	slti $t2, $a0, 48 	#$t2 is 1 if $a0 < 48
	#condition 1:	(i % 8) != 0
	sne $t3, $t1, 0
	#condition 2:	(i % 8) != 1
	sne $t4, $t1, 1
	#and of c0, c1
	and $t1, $t2, $t3 	#t1 is 1 if c0 and c1 are true, else 0
	#and of (c0 && c1), c2
	and $t1, $t1, $t4 	#t1 is 1 if (c0 && c1) and c2 are true, else 0
	#condition 3:	$t5
	lb $t2, boardPieces($t0) #t2 = boardPieces[j]
	seq $t2, $t2, 79    	#t2 is 1 if t2==79 ('O') else 0
	#and of (c0 && c1 && c2), c3
	and $t1, $t1, $t2	#t1 is 1 if (c0 && c1 && c2) and c3 are true, else 0
	beq $t1, $0, playerCheckDownLeftreturnFalse
	li $t2, 88	# $t2 = 'X'
	li $t3, 32	# $t3 = ' '
doloop_playerCheckDownLeft:
	# j += 7;	
	addi $t0, $t0, 7
	lb $t1, boardPieces($t0) #t1 = boardPieces[j]
	# (if boardPieces[j] == 'X') return true
	beq $t1, $t2, playerCheckDownLeftreturnTrue	
	#if (boardPieces[j] == ' ') return false
	beq $t1, $t3, playerCheckDownLeftreturnFalse
	#while (j < 56 && (j % 8) != 0)
	li $t1, 8
	div $t0, $t1
	mfhi $t1	# t1 = j % 8
	sne $t1, $t1, 0
	slti $t4, $t0, 56
	and $t1, $t1, $t4
	bne $t1, $0, doloop_playerCheckDownLeft	
playerCheckDownLeftreturnFalse:
	li $v0, 0
	jr $ra
playerCheckDownLeftreturnTrue:
	li $v0, 1
	jr $ra
	
#----------------------------------------------------------------------------------------------------

# playerFlipUp subroutine
playerFlipUp:	
	#saving to stack
	addi	$sp, $sp, -8
	sw	$a0, 4($sp)	#save i  to ($sp)
	sw	$ra, 0($sp)	#save $ra
	#Nested: call playerCheckUp
	jal	playerCheckUp
	beq $v0, $0, playerFlipUpEnd	#if s0 is 0 (false), then call end
	lw $a0, 4($sp)
	#j = i - 8;
	addi $t0, $a0, -8
	li $t1, 88	# $t1 = 'X'
	lw $t2, numX
	lw $t3, numO
whileloop_playerFlipUp:
	# (if boardPieces[j] != 'X')
	lb $t4, boardPieces($t0) #t4 = boardPieces[j]
	beq $t4, 88, playerFlipUpEndLoop
	sb $t1, boardPieces($t0)	# boardPieces[j] = 'X'
	addi $t2, $t2, 1	# numX++
	addi $t3, $t3, -1	# numO--
	#j -= 8;
	addi $t0, $t0, -8
	j whileloop_playerFlipUp
playerFlipUpEndLoop:
	sw $t2, numX
	sw $t3, numO	
playerFlipUpEnd:
	#recovering stack
	lw	$ra, 0($sp)
	addi	$sp, $sp, 8
	jr	$ra
	
#----------------------------------------------------------------------------------------------------

# playerFlipRight subroutine
playerFlipRight:	
	#saving to stack
	addi	$sp, $sp, -8
	sw	$a0, 4($sp)	#save i  to ($sp)
	sw	$ra, 0($sp)	#save $ra
	#Nested: call playerCheckRight
	jal	playerCheckRight
	beq $v0, $0, playerFlipRightEnd	#if s0 is 0 (false), then call end
	lw $a0, 4($sp)
	#j = i + 1;
	addi $t0, $a0, 1
	li $t1, 88	# $t1 = 'X'
	lw $t2, numX
	lw $t3, numO
whileloop_playerFlipRight:
	# (if boardPieces[j] != 'X')
	lb $t4, boardPieces($t0) #t4 = boardPieces[j]
	beq $t4, 88, playerFlipRightEndLoop
	sb $t1, boardPieces($t0)	# boardPieces[j] = 'X'
	addi $t2, $t2, 1	# numX++
	addi $t3, $t3, -1	# numO--
	#j++;
	addi $t0, $t0, 1
	j whileloop_playerFlipRight
playerFlipRightEndLoop:
	sw $t2, numX
	sw $t3, numO
playerFlipRightEnd:
	#recovering stack
	lw	$ra, 0($sp)
	addi	$sp, $sp, 8
	jr	$ra
	
#----------------------------------------------------------------------------------------------------
	
# playerFlipDown subroutine
playerFlipDown:	
	#saving to stack
	addi	$sp, $sp, -8
	sw	$a0, 4($sp)	#save i  to ($sp)
	sw	$ra, 0($sp)	#save $ra
	#Nested: call playerCheckDown
	jal	playerCheckDown
	beq $v0, $0, playerFlipDownEnd	#if s0 is 0 (false), then call end
	lw $a0, 4($sp)
	#j = i + 8;
	addi $t0, $a0, 8
	li $t1, 88	# $t1 = 'X'
	lw $t2, numX
	lw $t3, numO
whileloop_playerFlipDown:
	# (if boardPieces[j] != 'X')
	lb $t4, boardPieces($t0) #t4 = boardPieces[j]
	beq $t4, 88, playerFlipDownEndLoop
	sb $t1, boardPieces($t0)	# boardPieces[j] = 'X'
	addi $t2, $t2, 1	# numX++
	addi $t3, $t3, -1	# numO--
	#j += 8;
	addi $t0, $t0, 8
	j whileloop_playerFlipDown
playerFlipDownEndLoop:
	sw $t2, numX
	sw $t3, numO
playerFlipDownEnd:
	#recovering stack
	lw	$ra, 0($sp)
	addi	$sp, $sp, 8
	jr	$ra
	
#----------------------------------------------------------------------------------------------------
	
# playerFlipLeft subroutine
playerFlipLeft:	
	#saving to stack
	addi	$sp, $sp, -8
	sw	$a0, 4($sp)	#save i  to ($sp)
	sw	$ra, 0($sp)	#save $ra
	#Nested: call playerCheckLeft
	jal	playerCheckLeft
	beq $v0, $0, playerFlipLeftEnd	#if s0 is 0 (false), then call end
	lw $a0, 4($sp)
	#j = i - 1;
	addi $t0, $a0, -1
	li $t1, 88	# $t1 = 'X'
	lw $t2, numX
	lw $t3, numO
whileloop_playerFlipLeft:
	# (if boardPieces[j] != 'X')
	lb $t4, boardPieces($t0) #t4 = boardPieces[j]
	beq $t4, 88, playerFlipLeftEndLoop
	sb $t1, boardPieces($t0)	# boardPieces[j] = 'X'
	addi $t2, $t2, 1	# numX++
	addi $t3, $t3, -1	# numO--
	#j -= 1;
	addi $t0, $t0, -1
	j whileloop_playerFlipLeft
playerFlipLeftEndLoop:
	sw $t2, numX
	sw $t3, numO
playerFlipLeftEnd:
	#recovering stack
	lw	$ra, 0($sp)
	addi	$sp, $sp, 8
	jr	$ra
	
#----------------------------------------------------------------------------------------------------

# playerFlipUpLeft subroutine
playerFlipUpLeft:	
	#saving to stack
	addi	$sp, $sp, -8
	sw	$a0, 4($sp)	#save i  to ($sp)
	sw	$ra, 0($sp)	#save $ra
	#Nested: call playerCheckUpLeft
	jal	playerCheckUpLeft
	beq $v0, $0, playerFlipUpLeftEnd	#if s0 is 0 (false), then call end
	lw $a0, 4($sp)
	#j = i - 9;
	addi $t0, $a0, -9
	li $t1, 88	# $t1 = 'X'
	lw $t2, numX
	lw $t3, numO
whileloop_playerFlipUpLeft:
	# (if boardPieces[j] != 'X')
	lb $t4, boardPieces($t0) #t4 = boardPieces[j]
	beq $t4, 88, playerFlipUpLeftEndLoop
	sb $t1, boardPieces($t0)	# boardPieces[j] = 'X'
	addi $t2, $t2, 1	# numX++
	addi $t3, $t3, -1	# numO--
	#j -= 9;
	addi $t0, $t0, -9
	j whileloop_playerFlipUpLeft
playerFlipUpLeftEndLoop:
	sw $t2, numX
	sw $t3, numO
playerFlipUpLeftEnd:
	#recovering stack
	lw	$ra, 0($sp)
	addi	$sp, $sp, 8
	jr	$ra
	
#----------------------------------------------------------------------------------------------------

# playerFlipUpRight subroutine
playerFlipUpRight:	
	#saving to stack
	addi	$sp, $sp, -8
	sw	$a0, 4($sp)	#save i  to ($sp)
	sw	$ra, 0($sp)	#save $ra
	#Nested: call playerCheckUpRight
	jal	playerCheckUpRight
	beq $v0, $0, playerFlipUpRightEnd	#if s0 is 0 (false), then call end
	lw $a0, 4($sp)
	#j = i - 7;
	addi $t0, $a0, -7
	li $t1, 88	# $t1 = 'X'
	lw $t2, numX
	lw $t3, numO
whileloop_playerFlipUpRight:
	# (if boardPieces[j] != 'X')
	lb $t4, boardPieces($t0) #t4 = boardPieces[j]
	beq $t4, 88, playerFlipUpRightEndLoop
	sb $t1, boardPieces($t0)	# boardPieces[j] = 'X'
	addi $t2, $t2, 1	# numX++
	addi $t3, $t3, -1	# numO--
	#j -= 7;
	addi $t0, $t0, -7
	j whileloop_playerFlipUpRight
playerFlipUpRightEndLoop:
	sw $t2, numX
	sw $t3, numO
playerFlipUpRightEnd:
	#recovering stack
	lw	$ra, 0($sp)
	addi	$sp, $sp, 8
	jr	$ra
	
#----------------------------------------------------------------------------------------------------

# playerFlipDownRight subroutine
playerFlipDownRight:	
	#saving to stack
	addi	$sp, $sp, -8
	sw	$a0, 4($sp)	#save i  to ($sp)
	sw	$ra, 0($sp)	#save $ra
	#Nested: call playerCheckDownRight
	jal	playerCheckDownRight
	beq $v0, $0, playerFlipDownRightEnd	#if s0 is 0 (false), then call end
	lw $a0, 4($sp)
	#j = i + 9;
	addi $t0, $a0, 9
	li $t1, 88	# $t1 = 'X'
	lw $t2, numX
	lw $t3, numO
whileloop_playerFlipDownRight:
	# (if boardPieces[j] != 'X')
	lb $t4, boardPieces($t0) #t4 = boardPieces[j]
	beq $t4, 88, playerFlipDownRightEndLoop
	sb $t1, boardPieces($t0)	# boardPieces[j] = 'X'
	addi $t2, $t2, 1	# numX++
	addi $t3, $t3, -1	# numO--
	#j += 9;
	addi $t0, $t0, 9
	j whileloop_playerFlipDownRight
playerFlipDownRightEndLoop:
	sw $t2, numX
	sw $t3, numO
playerFlipDownRightEnd:
	#recovering stack
	lw	$ra, 0($sp)
	addi	$sp, $sp, 8
	jr	$ra
	
#----------------------------------------------------------------------------------------------------

# playerFlipDownLeft subroutine
playerFlipDownLeft:	
	#saving to stack
	addi	$sp, $sp, -8
	sw	$a0, 4($sp)	#save i  to ($sp)
	sw	$ra, 0($sp)	#save $ra
	#Nested: call playerCheckDownLeft
	jal	playerCheckDownLeft
	beq $v0, $0, playerFlipDownLeftEnd	#if s0 is 0 (false), then call end
	lw $a0, 4($sp)
	#j = i + 7;
	addi $t0, $a0, 7
	li $t1, 88	# $t1 = 'X'
	lw $t2, numX
	lw $t3, numO
whileloop_playerFlipDownLeft:
	# (if boardPieces[j] != 'X')
	lb $t4, boardPieces($t0) #t4 = boardPieces[j]
	beq $t4, 88, playerFlipDownLeftEndLoop
	sb $t1, boardPieces($t0)	# boardPieces[j] = 'X'
	addi $t2, $t2, 1	# numX++
	addi $t3, $t3, -1	# numO--
	#j += 7;
	addi $t0, $t0, 7
	j whileloop_playerFlipDownLeft
playerFlipDownLeftEndLoop:
	sw $t2, numX
	sw $t3, numO
playerFlipDownLeftEnd:
	#recovering stack
	lw	$ra, 0($sp)
	addi	$sp, $sp, 8
	jr	$ra
	
#----------------------------------------------------------------------------------------------------

computerFlipUp:
	addi $sp,$sp,-8
	sw $a0,4($sp)
	sw $ra, 0($sp)
	jal getComputerNumFlipsUp
	lw $ra,0($sp)
	lw $a0,4($sp)
	addi $sp,$sp,8
	beq $v0,$zero,computerFlipUpReturn
	addi $t0,$a0,-8
	li $t1,79
	lw $t2,numO
	lw $t3, numX
computerFlipUpLoop:
	lb $t4,boardPieces($t0)
	beq $t4, $t1, computerFlipUpEndLoop
	sb $t1, boardPieces($t0)
	addi $t2,$t2,1
	addi $t3,$t3,-1
	addi $t0,$t0,-8
	j computerFlipUpLoop
computerFlipUpEndLoop:
	sw $t2,numO
	sw $t3,numX
computerFlipUpReturn:
	jr $ra
	
	#------------------------------------------------------------------------------------

computerFlipRight:
	addi $sp,$sp,-8
	sw $a0,4($sp)
	sw $ra, 0($sp)
	jal getComputerNumFlipsRight
	lw $ra,0($sp)
	lw $a0,4($sp)
	addi $sp,$sp,8
	beq $v0,$zero,computerFlipRightReturn
	addi $t0,$a0,1
	li $t1,79
	lw $t2,numO
	lw $t3, numX
computerFlipRightLoop:
	lb $t4,boardPieces($t0)
	beq $t4, $t1, computerFlipRightEndLoop
	sb $t1, boardPieces($t0)
	addi $t2,$t2,1
	addi $t3,$t3,-1
	addi $t0,$t0,1
	j computerFlipRightLoop	
computerFlipRightEndLoop:
	sw $t2,numO
	sw $t3,numX
computerFlipRightReturn:
	jr $ra
	
	#------------------------------------------------------------------------------------
	
computerFlipDown:
	addi $sp,$sp,-8
	sw $a0,4($sp)
	sw $ra, 0($sp)
	jal getComputerNumFlipsDown
	lw $ra,0($sp)
	lw $a0,4($sp)
	addi $sp,$sp,8
	beq $v0,$zero,computerFlipDownReturn
	addi $t0,$a0,8
	li $t1,79
	lw $t2,numO
	lw $t3, numX
computerFlipDownLoop:
	lb $t4,boardPieces($t0)
	beq $t4, $t1, computerFlipDownEndLoop
	sb $t1, boardPieces($t0)
	addi $t2,$t2,1
	addi $t3,$t3,-1
	addi $t0,$t0,8
	j computerFlipDownLoop
computerFlipDownEndLoop:
	sw $t2,numO
	sw $t3,numX
computerFlipDownReturn:
	jr $ra
	
	#------------------------------------------------------------------------------------
	
computerFlipLeft:
	addi $sp,$sp,-8
	sw $a0,4($sp)
	sw $ra, 0($sp)
	jal getComputerNumFlipsLeft
	lw $ra,0($sp)
	lw $a0,4($sp)
	addi $sp,$sp,8
	beq $v0,$zero,computerFlipLeftReturn
	addi $t0,$a0,-1
	li $t1,79
	lw $t2,numO
	lw $t3, numX
computerFlipLeftLoop:
	lb $t4,boardPieces($t0)
	beq $t4, $t1, computerFlipLeftEndLoop
	sb $t1, boardPieces($t0)
	addi $t2,$t2,1
	addi $t3,$t3,-1
	addi $t0,$t0,-1
	j computerFlipLeftLoop
computerFlipLeftEndLoop:
	sw $t2,numO
	sw $t3,numX
computerFlipLeftReturn:
	jr $ra
	
	#------------------------------------------------------------------------------------
	
computerFlipUpLeft:
	addi $sp,$sp,-8
	sw $a0,4($sp)
	sw $ra, 0($sp)
	jal getComputerNumFlipsUpLeft
	lw $ra,0($sp)
	lw $a0,4($sp)
	addi $sp,$sp,8
	beq $v0,$zero,computerFlipUpLeftReturn
	addi $t0,$a0,-9
	li $t1,79
	lw $t2,numO
	lw $t3, numX
computerFlipUpLeftLoop:
	lb $t4,boardPieces($t0)
	beq $t4, $t1, computerFlipUpLeftEndLoop
	sb $t1, boardPieces($t0)
	addi $t2,$t2,1
	addi $t3,$t3,-1
	addi $t0,$t0,-9
	j computerFlipUpLeftLoop
computerFlipUpLeftEndLoop:
	sw $t2,numO
	sw $t3,numX
computerFlipUpLeftReturn:
	jr $ra
	
	#------------------------------------------------------------------------------------
	
computerFlipUpRight:
	addi $sp,$sp,-8
	sw $a0,4($sp)
	sw $ra, 0($sp)
	jal getComputerNumFlipsUpRight
	lw $ra,0($sp)
	lw $a0,4($sp)
	addi $sp,$sp,8
	beq $v0,$zero,computerFlipUpRightReturn
	addi $t0,$a0,-7
	li $t1,79
	lw $t2,numO
	lw $t3, numX
computerFlipUpRightLoop:
	lb $t4,boardPieces($t0)
	beq $t4, $t1, computerFlipUpRightEndLoop
	sb $t1, boardPieces($t0)
	addi $t2,$t2,1
	addi $t3,$t3,-1
	addi $t0,$t0,-7
	j computerFlipUpRightLoop	
computerFlipUpRightEndLoop:
	sw $t2,numO
	sw $t3,numX
computerFlipUpRightReturn:
	jr $ra
	
	#------------------------------------------------------------------------------------
	
computerFlipDownRight:
	addi $sp,$sp,-8
	sw $a0,4($sp)
	sw $ra, 0($sp)
	jal getComputerNumFlipsDownRight
	lw $ra,0($sp)
	lw $a0,4($sp)
	addi $sp,$sp,8
	beq $v0,$zero,computerFlipDownRightReturn
	addi $t0,$a0,9
	li $t1,79
	lw $t2,numO
	lw $t3, numX
computerFlipDownRightLoop:
	lb $t4,boardPieces($t0)
	beq $t4, $t1, computerFlipDownRightEndLoop
	sb $t1, boardPieces($t0)
	addi $t2,$t2,1
	addi $t3,$t3,-1
	addi $t0,$t0,9
	j computerFlipDownRightLoop
computerFlipDownRightEndLoop:
	sw $t2,numO
	sw $t3,numX
computerFlipDownRightReturn:
	jr $ra
	
	#------------------------------------------------------------------------------------

computerFlipDownLeft:
	addi $sp,$sp,-8
	sw $a0,4($sp)
	sw $ra, 0($sp)
	jal getComputerNumFlipsDownLeft
	lw $ra,0($sp)
	lw $a0,4($sp)
	addi $sp,$sp,8
	beq $v0,$zero,computerFlipDownLeftReturn
	addi $t0,$a0,7
	li $t1,79
	lw $t2,numO
	lw $t3, numX
computerFlipDownLeftLoop:
	lb $t4,boardPieces($t0)
	beq $t4, $t1, computerFlipDownLeftEndLoop
	sb $t1, boardPieces($t0)
	addi $t2,$t2,1
	addi $t3,$t3,-1
	addi $t0,$t0,7
	j computerFlipDownLeftLoop
computerFlipDownLeftEndLoop:
	sw $t2,numO
	sw $t3,numX
computerFlipDownLeftReturn:
	jr $ra
	
	#------------------------------------------------------------------------------------
	
getComputerNumFlipsUp:
	li $t0, 1   #numFlips = 1
	addi $t1,$a0,-8  #j = $t1
	sgt $t2,$a0,15   # check if i > 15
	lb $t3, boardPieces($t1) #t3 = boardPieces[j]
	seq $t3,$t3,88   # check if boardPieces[j] == 'X'
	and $t2,$t2,$t3  #if (i > 15 && boardPieces[j] == 'X')
	beq $t2,$zero,ReturnZeroNumFlipsUp
DoWhileLoopFlipsUp:
	addi $t1,$t1,-8
	lb $t2, boardPieces($t1) #t2 = boardPieces[j]
	beq $t2, 32, ReturnZeroNumFlipsUp	#check if boardPieces[j] == ' '
	beq $t2, 79, ReturnNumFlipsUp	#check if boardPieces[j] == 'O'
	addi $t0,$t0,1		#boardPieces[j] == 'X'
	bgt $t1,7,DoWhileLoopFlipsUp
ReturnZeroNumFlipsUp:
	li $v0,0
	jr $ra
ReturnNumFlipsUp:
	move $v0,$t0
	jr $ra
	
	#------------------------------------------------------------------------------------

getComputerNumFlipsRight:
	li $t0, 1   #numFlips = 1
	addi $t1,$a0,1  # j = $t1
	li $t2, 8
	div $a0, $t2
	mfhi $t2
	sne $t3, $t2, 6
	sne $t4, $t2, 7
	and $t2, $t3, $t4
	lb $t3, boardPieces($t1) #t4 = boardPieces[j]
	seq $t3,$t3,88    #check if boardPieces[j] == 'X'
	and $t2,$t2,$t3
	beq $t2,$zero,ReturnZeroNumFlipsRight	
DoWhileLoopFlipsRight:
	addi $t1,$t1,1
	lb $t2, boardPieces($t1) #t2 = boardPieces[j]
	beq $t2, 32, ReturnZeroNumFlipsRight	#check if boardPieces[j] == ' '
	beq $t2, 79, ReturnNumFlipsRight	#check if boardPieces[j] == 'O'
	addi $t0,$t0,1		#boardPieces[j] == 'X'
	li $t2, 8
	div $t1, $t2
	mfhi $t2
	bne $t2, 7, DoWhileLoopFlipsRight
ReturnZeroNumFlipsRight:
	li $v0,0
	jr $ra	
ReturnNumFlipsRight:
	move $v0,$t0
	jr $ra
	
	#------------------------------------------------------------------------------------
	
getComputerNumFlipsDown:
	li $t0, 1   #numFlips = 1
	addi $t1,$a0,8  #j = $t1
	slti $t2, $a0, 48
	lb $t3, boardPieces($t1) #t3 = boardPieces[j]
	seq $t3,$t3,88    #check if boardPieces[j] == 'X'
	and $t2,$t2,$t3
	beq $t2,$zero,ReturnZeroNumFlipsDown  #return 0
DoWhileLoopFlipsDown:
	addi $t1,$t1,8
	lb $t2, boardPieces($t1) #t2 = boardPieces[j]
	beq $t2, 32, ReturnZeroNumFlipsDown	#check if boardPieces[j] == ' '
	beq $t2, 79, ReturnNumFlipsDown	#check if boardPieces[j] == 'O'
	addi $t0,$t0,1		#boardPieces[j] == 'X'
	blt $t1,56,DoWhileLoopFlipsDown
ReturnZeroNumFlipsDown:
	li $v0,0
	jr $ra	
ReturnNumFlipsDown:
	move $v0,$t0
	jr $ra
	
	#------------------------------------------------------------------------------------

getComputerNumFlipsLeft:
	li $t0, 1   #numFlips = 1
	addi $t1,$a0,-1  # j = $t1
	li $t2, 8
	div $a0, $t2
	mfhi $t2
	sne $t3, $t2, 0
	sne $t4, $t2, 1
	and $t2, $t3, $t4
	lb $t3, boardPieces($t1) #t4 = boardPieces[j]
	seq $t3,$t3,88    #check if boardPieces[j] == 'X'
	and $t2,$t2,$t3
	beq $t2,$zero,ReturnZeroNumFlipsLeft  #return 0
DoWhileLoopFlipsLeft:
	addi $t1,$t1,-1
	lb $t2, boardPieces($t1) #t2 = boardPieces[j]
	beq $t2, 32, ReturnZeroNumFlipsLeft	#check if boardPieces[j] == ' '
	beq $t2, 79, ReturnNumFlipsLeft	#check if boardPieces[j] == 'O'
	addi $t0,$t0,1		#boardPieces[j] == 'X'
	li $t2,8
	div $t1,$t2
	mfhi $t2
	bne $t2, 0, DoWhileLoopFlipsLeft
ReturnZeroNumFlipsLeft:
	li $v0,0
	jr $ra	
ReturnNumFlipsLeft:
	move $v0,$t0
	jr $ra
	
	#------------------------------------------------------------------------------------

getComputerNumFlipsUpLeft:
	li $t0, 1   #numFlips = 1
	addi $t1,$a0,-9  # j = $t1
	sgt $t2,$a0,15
	li $t3, 8
	div $a0, $t3
	mfhi $t3
	sne $t4, $t3, 0
	sne $t5, $t3, 1
	and $t3, $t4, $t5
	and $t2, $t2, $t3
	lb $t3, boardPieces($t1) #t3 = boardPieces[j]
	seq $t3,$t3,88    #check if boardPieces[j] == 'X'
	and $t2,$t2,$t3
	beq $t2,$zero,ReturnZeroNumFlipsUpLeft  #return 0
DoWhileLoopFlipsUpLeft:
	addi $t1,$t1,-9
	lb $t2, boardPieces($t1) #t2 = boardPieces[j]
	beq $t2, 32, ReturnZeroNumFlipsUpLeft	#check if boardPieces[j] == ' '
	beq $t2, 79, ReturnNumFlipsUpLeft	#check if boardPieces[j] == 'O'
	addi $t0,$t0,1		#boardPieces[j] == 'X'
	sgt $t2,$t1,7
	li $t3,8
	div $t1,$t3
	mfhi $t3
	sne $t3,$t3,0
	and $t2,$t2,$t3
	beq $t2,1,DoWhileLoopFlipsUpLeft
ReturnZeroNumFlipsUpLeft:
	li $v0,0
	jr $ra	
ReturnNumFlipsUpLeft:
	move $v0,$t0
	jr $ra
	
	#------------------------------------------------------------------------------------

getComputerNumFlipsUpRight:
	li $t0, 1   #numFlips = 1
	addi $t1,$a0,-7  # j = $t1
	sgt $t2,$a0,15
	li $t3, 8
	div $a0, $t3
	mfhi $t3
	sne $t4, $t3, 6
	sne $t5, $t3, 7
	and $t3, $t4, $t5
	and $t2, $t2, $t3
	lb $t3, boardPieces($t1) #t3 = boardPieces[j]
	seq $t3,$t3,88    #check if boardPieces[j] == 'X'
	and $t2,$t2,$t3
	beq $t2,$zero,ReturnZeroNumFlipsUpRight  #return 0
DoWhileLoopFlipsUpRight:
	addi $t1,$t1,-7
	lb $t2, boardPieces($t1) #t2 = boardPieces[j]
	beq $t2, 32, ReturnZeroNumFlipsUpRight	#check if boardPieces[j] == ' '
	beq $t2, 79, ReturnNumFlipsUpRight	#check if boardPieces[j] == 'O'
	addi $t0,$t0,1		#boardPieces[j] == 'X'
	sgt $t2,$t1,7
	li $t3,8
	div $t1,$t3
	mfhi $t3
	sne $t3,$t3,7
	and $t2,$t2,$t3
	beq $t2,1,DoWhileLoopFlipsUpRight
ReturnZeroNumFlipsUpRight:
	li $v0,0
	jr $ra	
ReturnNumFlipsUpRight:
	move $v0,$t0
	jr $ra
	
	#------------------------------------------------------------------------------------
	
getComputerNumFlipsDownRight:
	li $t0, 1   #numFlips = 1
	addi $t1,$a0,9  # j = $t1
	slti $t2,$a0,48
	li $t3, 8
	div $a0, $t3
	mfhi $t3
	sne $t4, $t3, 6
	sne $t5, $t3, 7
	and $t3, $t4, $t5
	and $t2, $t2, $t3
	lb $t3, boardPieces($t1) #t3 = boardPieces[j]
	seq $t3,$t3,88    #check if boardPieces[j] == 'X'
	and $t2,$t2,$t3
	beq $t2,$zero,ReturnZeroNumFlipsDownRight  #return 0
DoWhileLoopFlipsDownRight:
	addi $t1,$t1,9
	lb $t2, boardPieces($t1) #t2 = boardPieces[j]
	beq $t2, 32, ReturnZeroNumFlipsDownRight	#check if boardPieces[j] == ' '
	beq $t2, 79, ReturnNumFlipsDownRight	#check if boardPieces[j] == 'O'
	addi $t0,$t0,1		#boardPieces[j] == 'X'
	slti $t2,$t1,56
	li $t3,8
	div $t1,$t3
	mfhi $t3
	sne $t3,$t3,7
	and $t2,$t2,$t3
	beq $t2,1,DoWhileLoopFlipsDownRight
ReturnZeroNumFlipsDownRight:
	li $v0,0
	jr $ra	
ReturnNumFlipsDownRight:
	move $v0,$t0
	jr $ra
	
	#------------------------------------------------------------------------------------
	
getComputerNumFlipsDownLeft:
	li $t0, 1   #numFlips = 1
	addi $t1,$a0,7  # j = $t1
	slti $t2,$a0,48
	li $t3, 8
	div $a0, $t3
	mfhi $t3
	sne $t4, $t3, 0
	sne $t5, $t3, 1
	and $t3, $t4, $t5
	and $t2, $t2, $t3
	lb $t3, boardPieces($t1) #t3 = boardPieces[j]
	seq $t3,$t3,88    #check if boardPieces[j] == 'X'
	and $t2,$t2,$t3
	beq $t2,$zero,ReturnZeroNumFlipsDownLeft  #return 0
DoWhileLoopFlipsDownLeft:
	addi $t1,$t1,7
	lb $t2, boardPieces($t1) #t2 = boardPieces[j]
	beq $t2, 32, ReturnZeroNumFlipsDownLeft	#check if boardPieces[j] == ' '
	beq $t2, 79, ReturnNumFlipsDownLeft	#check if boardPieces[j] == 'O'
	addi $t0,$t0,1		#boardPieces[j] == 'X'
	slti $t2,$t1,56
	li $t3,8
	div $t1,$t3
	mfhi $t3
	sne $t3,$t3,0
	and $t2,$t2,$t3
	beq $t2,1,DoWhileLoopFlipsDownLeft
ReturnZeroNumFlipsDownLeft:
	li $v0,0
	jr $ra	
ReturnNumFlipsDownLeft:
	move $v0,$t0
	jr $ra
	
	#------------------------------------------------------------------------------------
		
# exits the program		
exit:
