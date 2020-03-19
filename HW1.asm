#Derek Trom 
#Program Excercise 1

.data
    p0:     .asciiz    "\nContinue? Y/N: "
    p1:     .asciiz    "\nChoose X or O to start: "
    p2:     .asciiz    "\nDo you wan't to continue? Y/N: "
    p3:     .asciiz    "\nPlay again?: "
    xprint: .asciiz    "In x player"
    oprint: .asciiz    "In o player"
    yes:    .asciiz    "Y"
    no:     .asciiz    "N"
    x:      .asciiz    "X"
    o:      .asciiz    "O"
    blank:  .asciiz    " "
    Prompt:.asciiz    "\nChoose a number 1-9 to play: " 
    wrong:  .asciiz    "\nIncorrect input try again...\n"
    wrongPiece: .asciiz "\nInvalid piece...\n"
    spotTaken: .asciiz "\nSpot taken...\n"
    str1:   .space     2    #space for input of Y/N    
    str2:   .space     2    #space for input of X/O
    board:  .ascii     "\n\n        | |        1|2|3\n       -----       -----"
            .ascii    "\n        | |        4|5|6\n       -----       -----"
            .asciiz   "\n        | |        7|8|9\n"         

.text
    main:
        
        lb    $t5, x #load "X" to $t5
        lb    $t6, o #load "O" to $t6
        li    $v0, 4   #prepare
        la    $a0, p1 #print x/o prompt
        syscall
        li    $v0, 8
        la    $a0, str2 #store in str2
        li    $a1, 2 #allocate space for input
        move  $t9, $a0 #move from a0 to t9
        syscall
        lb    $t9, 0($t9) #load choice of X or O to $t9 to keep track of turn
        beq   $t9, $t5, displayBoard  #branch to start game if valid
        beq   $t9, $t6, displayBoard  #branch to start game if valid      
        j   errorMain #catch wrong choice
        li    $v0, 10 #exit just in case
        syscall
                   
    offset:
    	#offset = 2×$v0 + 7 + [($v0-1)÷3]×44
    	move  $t0, $t7   #move number choice to $t0
    	move  $t1, $t7   #move number choice to $t1
    	sub   $t0, $t0, 1  #minus 1
    	div   $t0, $t0, 3  #divide by three
    	mul   $t0, $t0, 44  #multiply by 44
    	mul   $t1, $t1, 2   #$t1 X 2
    	add   $t1, $t1, 7   #add 7 to $t1
    	add   $t7, $t1, $t0 #add $t1 and $t0
    	jr $ra  #return to caller
    	
    	
    displayBoard: 
         li $v0, 4      #prepare to print
         la $a0, board  #print board 
         syscall
         j getInt       #jump to get int
         
    continue:
        li    $v0, 4 #prepare continue statement
        la    $a0, p0 #print continue
        syscall
        li    $v0, 8  #receive input
        la    $a0, str1 #store in str1
        li    $a1, 2 #allocate space for input
        move  $t0, $a0 #move from a0 to t0 
        syscall
        lb    $t1, yes #load yes
        lb    $t2, no
        lb    $t0, 0($t0) #get value
        beq   $t0, $t2, newGame #if equal to no branch to exit
        beq   $t0, $t1, xoro    #if yes branch to xoro
        syscall
        j   error     #wrong input
        
        #jal displayBoard #call displayboard     
    #offset:
    xoro: 
    	beq $t9, $t6, oPlayer #if o go to o
    	beq $t9, $t5, xPlayer #if x go to x
    getInt:
        li    $t8, 9 #used to test if the number is less than 9
        li    $v0, 4 #prepare
        la    $a0, Prompt  #print prompt
        syscall 
        li    $v0, 5 #prepare for int input
        li    $a1, 2 #allocate space
        syscall
        move  $t7, $v0  #move response to $t7
        bgt   $t7, $t8, errorInt  #catch if > 9
        blez  $t7, errorInt  #catch if < 1
        jal     offset  #calculate offset
        move  $t0, $t7     # Load $t0 with the offset.
        move  $t1, $t9     # Load $t1 with the marker 'X' or O.
        move  $t2, $t5    #copy x to t2
        move  $t3, $t6    #copy o to t3
        lb    $t4, board($t0) #load byte of board offset
        beq   $t4, $t2, taken #if equals x error
        beq   $t4, $t3, taken #if equals o error
        sb    $t1, board($t0) #else store in board
        li $v0, 4      #prepare to print
        la $a0, board  #print board 
        syscall
        j     continue #continue
                   
    exit:
        #exit call
        li    $v0, 10
        syscall
        jr    $ra
    errorInt:
        #error for getInt
        li    $v0, 4
        la    $a0, wrong
        syscall
        j     getInt
    error:
    	#error for continue
    	li    $v0, 4
        la    $a0, wrong
        syscall
        j     continue
    errorMain:
        #error for wrong piece choice
        li    $v0, 4
        la    $a0, wrongPiece
        syscall
        j     main
    errorNew:
        #error for new game
        li    $v0, 4
        la    $a0, wrong
        syscall
        j     newGame
    taken:
        #error if spot taken on board
        li    $v0, 4
        la    $a0, spotTaken
        syscall
        j     displayBoard
    xPlayer:
         #switch for players
         lb   $t9, o
         j  displayBoard     
    oPlayer:
	lb   $t9, x
        j   displayBoard
    newGame:
    	li    $v0, 4 #prepare continue statement
        la    $a0, p3 #print continue
        syscall
        li    $v0, 8  #receive input
        la    $a0, str1 #store in str1
        li    $a1, 2 #allocate space for input
        move  $t0, $a0 #move from a0 to t0 
        syscall
        lb    $t1, yes #load yes
        lb    $t2, no
        lb    $t0, 0($t0) #get value
        beq   $t0, $t2, exit #if equal to no branch to exit
        beq   $t0, $t1, resetBoard
        syscall
        j   error
    resetBoard:
    	#reset all possible spots on board with blank again
    	lb   $s0, blank
    	li   $s2, 9
    	sb   $s0, board($s2) 
    	li   $s2, 11
    	sb   $s0, board($s2)
    	li   $s2, 13
    	sb   $s0, board($s2)  	
    	li   $s2, 59
    	sb   $s0, board($s2)   	
    	li   $s2, 61
    	sb   $s0, board($s2)	
    	li   $s2, 63
    	sb   $s0, board($s2)    	
    	li   $s2, 109
    	sb   $s0, board($s2)   	
    	li   $s2, 111
    	sb   $s0, board($s2)   	
    	li   $s2, 113
    	sb   $s0, board($s2) 
    	j    main
        
