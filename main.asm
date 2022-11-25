.model small
.stack 100h
.data

CANVA_SIZE_ROW dw 199
CANVA_SIZE_COL dw 319
COLLISION_MARGIN dw 10


Username db 21


;	WElcome Screen prompts
Text_Welcome_Game db 'Brick Breaker','$'
Text_Welcome db 'Enter Username:','$'

;Main Menu text prompts
Text_MainMenu_start db 'Start(S)','$'	;Start button
Text_MainMenu_highscore	db 'HighScores(H)','$';highScore button
Text_MainMenu_Instruction db 'Instructions(I)','$';Instructions button
Text_MainMenu_Exit db 'Exit(E)','$'
;Instructions screen prompts
Text_Instruction_head db 'Instructions','$'
Text_Instruction_content1 db 'press esc key to exit the game','$'
Text_Instruction_content2 db 'Left and Right arrow keys to move bar','$'
Text_Instruction_content3 db 'Each level is more difficult than previous','$'
Text_Instruction_content4 db 'Try not to lose ;)','$'
Text_Instruction_content5 db 'Press E to back to main menu','$'
;Pause Screen text prompts
Text_Pause_Resume db 'Resume(R)','$'	;Resume button
Text_Pause_Exit db 'Exit(E)','$'		;Exit button
;End Screen text prompts
Text_End_MainMenu db 'Main Menu(M)','$'	;Menu button
Text_End_Exit db 'Exit(E)','$'			;Exit game button


;Time for GameLoop
TimeTmp db 0





;Variables for funtions
DrawPixRow dw 0 ;Row to draw
DrawPixCol dw 0 ;Column to draw
DrawPixColor db 0 ;Color to draw


;FOR THE BALL
BallSize dw 10 ;Size of the ball
BallRow dw 10;
BallCol dw 4
BallColor db 4

BallVelocRow dw 5 ;Velocity of the ball
BallVelocCol dw 5


;For the pedal
PedalWidth dw 60
PedalHeight dw 8
pedalRow dw 150
pedalCol dw 50
pedalColor db 4 
pedalVelocity dw 10


.code

main PROC
    mov ax, @data
    mov ds, ax

   call ClearScreen

;	WElcome screen
	call Screen_Welcome

   ; call DisplayMenu;  ;And Game loop can be called from this menu

   ;call gameLoop

   
    
    
  


mov ah,04ch
int 21h

main endp

;before calling this function set the rows and cols : dh and dl
setCursor PROC
	mov ah, 02h
	mov bh, 00h
	int 10H

	ret
setCursor ENDP

;Basically a loop that runs 100 times a sec
gameLoop PROC


    StartLoop:
        ;Get Time using time interrupt
        mov ah,2Ch
        int 21h

        cmp dl,TimeTmp ;DL has the current Time Sec/100 (0-99) . And TimeTmp has the last time
        je StartLoop ;If the time is the same, then we are still in the same second, so we wait

        mov TimeTmp,dl
       
        call ClearScreen

        ;Do stuff here
        call moveBall
        call DrawBall
        
        call movePedal
        call DrawPedal




    jmp StartLoop






ret
gameLoop endp

;Draws the pedal
DrawPedal PROC uses AX BX CX DX
;Input Row Col of the Pedal
;Input width and height of the Pedal

    mov ax, pedalRow
    mov DrawPixRow,ax

    mov ax, pedalCol
    mov DrawPixCol,ax

    mov cx, PedalWidth
    mov dx, PedalHeight

    mov al, pedalColor
    mov DrawPixColor,al

    mov cx,PedalHeight  
    LoopPrintRowPedal:  ;Runs for each row
        push cx ;save cx
        push word ptr DrawPixCol ; save DrawPixCol

        mov cx,PedalWidth 
        LoopPrintColPedal:  ;Runs for each column
            call DrawPixel
            inc DrawPixCol
        loop LoopPrintColPedal

        inc DrawPixRow ;increment row

        pop word ptr DrawPixCol ; restore DrawPixCol
        pop cx

    loop LoopPrintRowPedal

    ret

DrawPedal ENDP

;Moves the pedal based on the keyboard input
movePedal PROC uses AX BX CX DX


    mov ah,01
    int 16h
    jz SkipMove  ;ZeroFlag=0 means no key was pressed ==> no need to move the pedal

    ;==> Key was pressed
    mov ah,00h
    int 16h ;Get the key pressed

    cmp ah,04DH ;if ight Arrow
    je movePedalToRight
    cmp ah,04BH ;if Left Arrow
    je movePedalToLeft
    
    ret

    movePedalToLeft:
        mov ax, pedalVelocity
        sub pedalCol,ax
        
       ;Check if pedal is out of bounds X axis
        cmp pedalCol, 0
        jle FixLeftMove
        ret

    movePedalToRight:
        mov ax, pedalVelocity
        add pedalCol,ax

        ;Check if pedal is out of bounds X axis
        mov ax, pedalCol
        add ax, PedalWidth
        cmp ax, CANVA_SIZE_COL
        jge FixRightMove

        ret        


    FixLeftMove:
        mov pedalCol, 0
        ret
    
    FixRightMove:
        mov ax, CANVA_SIZE_COL
        sub ax, PedalWidth
        mov pedalCol, ax
        ret





    SkipMove:


    ret
movePedal ENDP


;Draws the balls
DrawBall PROC
;Input Row Col of the Ball
;Input Size of the ball

    ; X-Y coordinates of the ball
    mov ax, BallCol
    mov DrawPixCol,ax
    mov ax, BallRow
    mov DrawPixRow,ax
    mov al, BallColor
    mov DrawPixColor,al

    mov cx,BallSize  ;
    LoopPrintRow:  ;Runs for each row
        push cx ;save cx
        push word ptr DrawPixCol ; save DrawPixCol

        mov cx,BallSize
        LoopPrintCol:  ;Runs for each column
            call DrawPixel
            inc DrawPixCol
        loop LoopPrintCol

        inc DrawPixRow ;increment row

        pop word ptr DrawPixCol ; restore DrawPixCol
        pop cx

    loop LoopPrintRow




ret
DrawBall endp

;Moves the ball
moveBall PROC

    ;Move the ball
    mov ax,BallVelocRow
    add BallRow,ax
    mov ax,BallVelocCol
    add BallCol,ax

    ;Check if the ball is out of bounds in the y axis
    mov ax,CANVA_SIZE_ROW
    sub ax,BallSize ;Taking into account the size of the ball
    cmp BallRow,ax
    jg BallOutOfBoundsR
    cmp BallRow,0
    jl BallOutOfBoundsR

    ;Check if the ball is out of bounds in the x axis
    mov ax,CANVA_SIZE_COL
    sub ax,BallSize ;Taking into account the size of the ball
    cmp BallCol,ax
    jg BallOutOfBoundsC
    cmp BallCol,0
    jl BallOutOfBoundsC


    ret

    BallOutOfBoundsR:
        neg BallVelocRow
        ret

    BallOutOfBoundsC:
        neg BallVelocCol
        ret
    


ret

moveBall endp
;Draws a pixel at the specified row and column
DrawPixel PROC uses ax bx cx dx
;Input: DrawPixRow, DrawPixRowCol, DrawPixColor


    MOV AH, 0Ch
    MOV AL, DrawPixColor
    MOV CX, DrawPixCol
    MOV DX, DrawPixRow
    INT 10H

  

    ret

DrawPixel endp
;Clears The Screen
ClearScreen PROC uses ax bx


    ;set video mode
    Mov ah,00h ;set video mode
    Mov al,13 ;choose mode 13
    Int 10h


    ;Set background color
    MOV AH,0Bh 		
    MOV BH,00h 		
    MOV BL,00h 		
    INT 10h    	


ret
ClearScreen ENDP


;//////////////////////////////////////////////////////
;	Screens Display Functions
;//////////////////////////////////////////////////////




;	Welcome screen 1st screen when game is openned
Screen_Welcome PROC near
	;takes input the name of the player

;	setting curser position
	mov ah, 02h
	mov bh, 00h
	mov dh, 4	; row 
	mov dl, 12	; cols
	int 10H
;	outputing Name of the game
	lea dx, Text_Welcome_Game
	mov ah, 09h
	int 21h

;	setting curser position
	mov ah, 02h
	mov bh, 00h
	mov dh, 10	; row 
	mov dl, 5	; cols
	int 10H
;	outputing the string
	lea dx, Text_Welcome
	mov ah, 09h
	int 21h

	lea dx, Username ; load our pointer to the beginning of the structure
	mov ah, 10 ; GetLine function
	int 21h
	mov [Username], 0
	
	xor dx, dx
	mov dx, offset Username
	mov ah, 09h
	int 21h

	call Screen_Main_Menu

	ret
Screen_Welcome ENDP

;	Main Menu and Exit menu fuctions

;//////////////////////////////////////////////////////
;//////////////////////////////////////////////////////

Screen_Main_Menu PROC near	
;	printes the name of Player at the top
MenuScreen:
	call ClearScreen
;	setting the curser
	mov ah, 02h
	mov bh, 00h
	mov dh, 2	; rows
	mov dl, 12	;cols
	int 10H
;	printing the user name
	lea dx, Username
	mov ah, 09h
	int 21h


;	printing the text and buttons for the main menu
	;setting curser
	mov dh, 6
	mov dl, 10
	call setCursor

	lea dx, Text_MainMenu_start
	mov ah, 09h
	int 21h

;	Instruction Screen button
	mov dh, 8
	mov dl, 10
	call setCursor

	lea dx, Text_MainMenu_Instruction
	mov ah, 09h
	int 21h


;	highScore screen and the names of the player
	mov dh, 10
	mov dl, 10
	call setCursor

	lea dx, Text_MainMenu_highscore
	mov ah, 09h
	int 21h

;	Exit game button
	mov dh, 12
	mov dl, 10
	call setCursor

	lea dx, Text_MainMenu_Exit
	mov ah, 09h
	int 21h

;	Choosing the next page by key pressing
	mov ah, 00h
	int 16h
;	Starting the game
	cmp al, 'S'
	je start_game
	cmp al,'s'
	je start_game
;	Instruction
	cmp al, 'I'
	je instruct
	cmp al,'i'
	je instruct
;	HighScores
	cmp al, 'H'
	je highSc
	cmp al,'h'
	je highSc
;	Exit
	cmp al, 'E'
	je below
	cmp al,'e'
	je below
start_game:
	call gameLoop
	jmp below
instruct:
	call Screen_Instructions
	jmp MenuScreen
highSc:
	call Screen_Highscore
	jmp MenuScreen
below:
	ret
Screen_Main_Menu ENDP

Screen_Instructions PROC
	;a bunch of Instruction
instScreen:
	call ClearScreen
;	setting curser
	mov dh, 2
	mov dl, 8
	call setCursor
;	text prompts
	lea dx, Text_Instruction_content1
	mov ah, 09h
	int 21h
;	setting curser
	mov dh, 4
	mov dl, 2
	call setCursor
;	text prompts
	lea dx, Text_Instruction_content2
	mov ah, 09h
	int 21h
;	setting curser
	mov dh, 12
	mov dl, 2
	call setCursor
;	text prompts
	lea dx, Text_Instruction_content3
	mov ah, 09h
	int 21h
;	setting curser
	mov dh, 14
	mov dl, 2
	call setCursor
;	text prompts
	lea dx, Text_Instruction_content4
	mov ah, 09h
	int 21h
;	setting curser
	mov dh, 16
	mov dl, 10
	call setCursor
;	text prompts
	lea dx, Text_Instruction_content5
	mov ah, 09h
	int 21h

	mov ah, 00h
	int 16H
	cmp al, 'E'
	je belowInstruction
	cmp al, 'e'
	je belowInstruction
	jmp instScreen
belowInstruction:
	ret
Screen_Instructions ENDP

Screen_Highscore PROC
	;reads from the file and prints the player names and their score


	ret
Screen_Highscore ENDP

;//////////////////////////////////////////////////////
;//////////////////////////////////////////////////////
Screen_Exit PROC
	;after the game is finished
;	shows the score of the player 
;	Options for player to go back to main menu or exit game 

	ret
Screen_Exit ENDP

;	Pause Screen when the game is running
Screen_Pause PROC
	;exit button

;	continue button

	ret
Screen_Pause ENDP

end main
