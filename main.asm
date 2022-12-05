.model small
.stack 100h
.data

;File Writing is breaking Screen_Exit
;cant print the Score and lives 



;/// Structures Definition
BALL STRUCT 
    ;FOR THE BALL
    BSize dw 10 ;Size of the ball
    Row dw 10;
    Col dw 4
    Color db 5

    VelocRow dw 5 ;Velocity of the ball
    VelocCol dw 5

BALL ENDS


BRICK STRUCT
    ;FOR THE BRICKS
    BWidth dw 10
    BHeight dw 5
    BRow dw 10;
    BCol dw 4
    BColor db 5
    nHits db 0; Current number of hits
    nMaxHits db 2; Number of hits to destroy the brick

BRICK ENDS




Balls BALL <4,10,4,5,6,2> , <2,90,4,3,2,2> , <13,7,30,10,10> ,<4,10,4,5,6,2> , <2,90,4,3,2,2> , <1,4,90,10,10> 
nBalls dw 3 ;Number of balls



CANVA_SIZE_ROW dw 199
CANVA_SIZE_COL dw 319
COLLISION_MARGIN dw 10


;	File handling Variables
filename db 'Scores.txt',0	;the name of the file
fhandle dw 	?	;the address to be returned by ax
buffer db 100	;100 characters
Cursor_x db 16
Cursor_y db 2
COUNT_multi dw 0
newbuffer db 100


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



TimeTmp db 0fh
TimeTmp2 db 0  ;For Brick Drawing delay


;PLAYER DETAIlS
Username db 21 dup('$')
Score db 0  
currentLevel db 0 



;PLAYER DETAIlS
Username db 12 dup('$')
newUsername db 12 dup('$')
Score dw 12
currentLevel db 2
Score_str db 4 dup('$')
Username_COUNT db 0
lives dw 3

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



; FOR THE DrawBrick
BrickHeight db 42
BrickWidth db 4
BrickRow db 10;
BrickCol db 4
BrickColor db 5
BricknHits db 0; Current number of hits
BricknMaxHits db 1; Number of hits to destroy the brick





;For the pedal
PedalWidth dw 30
PedalHeight dw 4
pedalRow dw 170

pedalCol dw 50
pedalColor db 0ffh 
pedalVelocity dw 10





.code

main PROC

    mov ax, @data
    mov ds, ax

    Mov ah,00h ;set video mode
    Mov al,13 ;choose mode 13
    Int 10h  



    call Screen_Welcome
;	shows the score of the player 
;	Options for player to go back to main menu or exit game 
;	setting curser

   call ClearScreen

;	WElcome screen
	; call Screen_Welcome

   ; call DisplayMenu;  ;And Game loop can be called from this menu

    call gameLoop

   

    
    
  


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

         

        call moveAllBalls
        call drawAllBalls



        ; call DrawBrick

        ; call moveBall
        ; call DrawBall



        ; call DrawPedal

        call movePedal
        call DrawPedal



    jmp StartLoop





ret
gameLoop endp



;Draws all the balls in the BAlls Array
drawAllBalls PROC uses si cx ax 
	;mov dh, 2
	;mov dl, 17
	;call Display_Score
	;mov dh, 2
	;mov dl, 20
	;call Display_Lives

    mov cx,nBalls
    mov si,offset Balls

    LoopDraw:
        mov ax, [si].Row
        mov BallRow,ax

        mov ax, [si].Col
        mov BallCol,ax

        mov al, [si].Color
        mov BallColor,al

        call DrawBall

        add si,SIZEOF BALL
        
    loop loopDraw



ret
drawAllBalls ENDP
;Moves all the balls in the Balls Array
moveAllBalls PROC uses si cx ax 

    mov cx,nBalls
    mov si,offset Balls

    LoopMove:
        mov ax, [si].Row
        mov BallRow,ax

        mov ax, [si].Col
        mov BallCol,ax

        mov al, [si].Color
        mov BallColor,al

        mov ax, [si].VelocRow
        mov BallVelocRow,ax

        mov ax, [si].VelocCol
        mov BallVelocCol,ax


        call moveBall

        mov ax, BallRow
        mov [si].Row,ax

        mov ax, BallCol
        mov [si].Col,ax

        mov al, BallColor
        mov [si].Color,al

        mov ax, BallVelocRow
        mov [si].VelocRow,ax

        mov ax, BallVelocCol
        mov [si].VelocCol,ax





        add si,SIZEOF BALL
        
    loop LoopMove
       
        
ret
moveAllBalls ENDP


;Draw Brick [For single brick]
DrawBrick PROC uses si cx ax bx

 ; X-Y coordinates of the ball
    ; mov ax, BrickCol
    ; mov DrawPixCol,ax
    ; mov ax, BrickRow
    ; mov DrawPixRow,ax
    ; mov al, BrickColor
    ; mov DrawPixColor,al

    ; mov cx,BrickHeight  ;
    ; LoopPrintRowBrick:  ;Runs for each row
    ;     push cx ;save cx
    ;     push word ptr DrawPixCol ; save DrawPixCol

    ;     mov cx,BrickWidth
    ;     LoopPrintColBrick:  ;Runs for each column
    ;         call DrawPixel
    ;         inc DrawPixCol
    ;     loop LoopPrintColBrick

    ;     inc DrawPixRow ;increment row

    ;     pop word ptr DrawPixCol ; restore DrawPixCol
    ;     pop cx

    ; loop LoopPrintRowBrick


    mov ah, 6

    mov al, BrickHeight
    mov bh, 4

    mov ch, BrickRow  ;Top Row
    mov cl, BrickCol  ;Left Column


    mov dh,ch   ;Bottom Row
    add dh,BrickHeight


    mov dl, BrickCol  ;Right Column
    add dl,BrickWidth ;

    int 10h



    

ret
DrawBrick ENDP

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

    cmp ah, 01h
    je ShowPause
    
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

    ShowPause:
    	call Screen_Pause
 


    SkipMove:


    ret
movePedal ENDP


;Draws the balls
DrawBall PROC Uses ax bx dx cx
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
moveBall PROC uses ax 

    ;Move the ball
    mov ax,BallVelocRow
    add BallRow,ax
    mov ax,BallVelocCol
    add BallCol,ax

    ;Check if the ball is out of bounds in the y axis
    mov ax,CANVA_SIZE_ROW
    sub ax,BallSize ;Taking into account the size of the ball
    sub ax,COLLISION_MARGIN ;Taking into account the margin

    cmp BallRow,ax
    jg BallOutOfBoundsR
    cmp BallRow,0
    jl BallOutOfBoundsR

    ;Check if the ball is out of bounds in the x axis
    mov ax,CANVA_SIZE_COL
    sub ax,BallSize ;Taking into account the size of the ball
    sub ax,COLLISION_MARGIN ;Taking into account the margin

    cmp BallCol,ax
    jg BallOutOfBoundsC
    cmp BallCol,0
    jl BallOutOfBoundsC



    ;Check if the ball is colliding with the pedal Using AABB collision Algorithm 
    ;Source https://developer.mozilla.org/en-US/docs/Games/Techniques/2D_collision_detection
    ; rect1.x < rect2.x + rect2.w &&
    ; rect1.x + rect1.w > rect2.x &&
    ; rect1.y < rect2.y + rect2.h &&
    ; rect1.h + rect1.y > rect2.y

    ;All these conditions must be true for a collision to occur

    ; BallCol < pedalCol + PedalWidth &&
    ; BallCol + BallSize > pedalCol &&
    ; BallRow < pedalRow + PedalHeight &&
    ; BallSize + BallRow > pedalRow
    
    mov ax,pedalCol
    add ax,PedalWidth
    cmp BallCol,ax
    jnl SkipPedalCollision

    mov ax,BallCol
    add ax,BallSize
    cmp pedalCol,ax
    jnl SkipPedalCollision

    mov ax,pedalRow
    add ax,PedalHeight
    cmp BallRow,ax
    jnl SkipPedalCollision

    mov ax,BallRow
    add ax,BallSize
    cmp pedalRow,ax
    jnl SkipPedalCollision

    ;If no skips means collison occured

    ;Change the direction of the ball
    NEG BallVelocRow ; Negate the velocity of the ball in the y axis
    ; add BallCol,3 ;Move the ball in the x axis to avoid the collision
    ; NEG BallVelocCol ; Negate the velocity of the ball in the x axis

    
    ;Adding interia to the ball based on if the pedal is moving right or left
    


    ; dec BallRow ;  Move the ball a little bit to the right to avoid the collision 

    ;change ball color JUST FOR FUN






    ret

    BallOutOfBoundsR:
        neg BallVelocRow
        ret

    BallOutOfBoundsC:
        neg BallVelocCol
        ret
    
    SkipPedalCollision:


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

; DrawMac MACRO Color x ,y

;     MOV AH, 0Ch
;     MOV AL, Color
;     MOV CX, x
;     MOV DX, y
;     INT 10H


; DrawMac ENDM


;Clears The Screen
ClearScreen PROC uses ax bx


    ;set video mode
    ; Mov ah,00h ;set video mode
    ; Mov al,13 ;choose mode 13
    ; Int 10h

 mov al,00h
    MOV AH,0Bh
    MOV BH,00h
    MOV BL,00h
    INT 10h


   mov ah,06h
    xor al,al
    xor cx,cx
    mov dh,30
    mov dl,80
    mov bh,00010000b
    int 10h

; ;  set video mode
;     Mov ah,00h ;set video mode
;     Mov al,13 ;choose mode 13
;     Int 10h
  
    ; ;Set background color
    ; mov al,00h
    ; MOV AH,0Bh 		
    ; MOV BH,00h 		
    ; MOV BL,00h 		
    ; INT 10h    	

    ; ; ;Set foreground color 
    ; mov al,00h
    ; MOV AH,0Bh
    ; MOV BH,00h
    ; MOV BL,00h
    ; INT 10h


;    mov ah,06h
;     xor al,al
;     xor cx,cx
;     mov dh,30
;     mov dl,80
;     mov bh,00010000b
;     int 10h

   


    ;Set background color
    MOV AH,0Bh 		
    MOV BH,00h 		
    MOV BL,00h 		
    INT 10h    	


ret
ClearScreen ENDP
;****
;When Score is being written in file
;Writes the Score in the buffer
;****

;!!! this aint working!!!
MultipleDigit_int_to_str PROC
mov si, offset buffer	
_OUTP:
	MOV AX,Score
	MOV DX,0
_HERE:
	CMP AX,0
	JE _Ex2

	MOV BL,10
	DIV BL

	MOV DL,AH
	MOV DH,0
	PUSH DX
	MOV CL,AL
	MOV CH,0
	MOV AX,CX
	INC COUNT_multi
	mov cx, COUNT_multi
	JMP _HERE
_Ex2:
	mov cx, COUNT_multi
	cmp cx, 0
	je Multi_END
	pop dx
	mov [si], dx
	inc si
	dec cx
	jmp _Ex2
Multi_END:
	mov [si],'$'
	ret
MultipleDigit_int_to_str ENDP
;***
;Used when reading from the file and putting it in Score Variables
;***
MultipleDigit_str_to_int PROC
mov si, offset Score_str
_INP:
	mov al, [si]
	CMP AL,'$'
	JE _Ex
	SUB AL,48
	MOV CL,AL
	MOV CH,0
	MOV AX,Score
	MOV BL,10
	MUL BL
	ADD AX,CX
	MOV Score,AX
	JMP _INP
_Ex:
	ret
	
MultipleDigit_str_to_int ENDP

;takes dh and dl as parameters to set the curser
Display_Score PROC uses dx
	call setCursor
	call MultipleDigit_int_to_str
	mov dx, offset Score_str
	mov ah, 09h
	int 21h

	ret
Display_Score ENDP
;takes dh and dl as parameters to set the curser	
Display_Lives PROC
	call setCursor
	mov cx, lives
Lives_loop:
	mov dl, 03h
	mov ah, 02h
	int 21h	
	loop Lives_loop

	mov dx, lives
	add dx, 48
	mov ah, 02h
	int 21h


	ret
Display_Lives ENDP

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
	call Screen_Exit
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
	mov dl, 14
	mov dh, 3
	call setCursor
;	text prompts
	lea dx, Text_Instruction_head
	mov ah, 09h
	int 21h
;	setting curser
	mov dl, 1
	mov dh, 6
	call setCursor
;	text prompts
	lea dx, Text_Instruction_content2
	mov ah, 09h
	int 21h
;	setting curser
	mov dl, 1
	mov dh, 9
	call setCursor
;	text prompts
	lea dx, Text_Instruction_content3
	mov ah, 09h
	int 21h
;	setting curser
	mov dl, 8
	mov dh, 12
	call setCursor
;	text prompts
	lea dx, Text_Instruction_content4
	mov ah, 09h
	int 21h
;	setting curser
	mov dl, 4
	mov dh, 15
	call setCursor
;	text prompts
	lea dx, Text_Instruction_content5
	mov ah, 09h
	int 21h

	mov ah, 00h
	int 16H
	cmp al, 'E'
	je belowIns
	cmp al, 'e'
	je belowIns
	jmp instScreen
belowIns:
	ret
Screen_Instructions ENDP

Screen_Highscore PROC
	;reads from the file and prints the player names and their score
	call ClearScreen
	
highScreen:
	call File_openRW

	;write the Username in the file
;keep reading the file 
	call File_read
	lea dx, buffer
	mov ah, 09h
	int 21h
	call newLine



;	call MultipleDigit_int_to_str
;	call AppendToFile

; NOW READING FROM FILE
;	call File_read
	mov di, offset newbuffer
	mov si, offset newUsername
jumpb0:

	mov ax, [di]
	mov [si], ax
	inc si
	inc di
	cmp [di], 10d
	
	jne jumpb0

	inc di
	mov ax, [di]
	mov Score, ax


	mov dx, offset newbuffer
	mov ah, 09h
	int 21h

	mov [si],'$'
	inc di
	call newLine
	lea dx, Username
	mov ah, 09h
	int 21h
	call newLine

	;mov ax, [di]
	;sub ax, 48
	;mov Score, ax

	mov dx, Score
	add dl, 48
	mov ah, 02h
	int 21h
	call newLine
	;call File_read

	lea dx, newbuffer
	mov ah, 09h
	int 21h

	call File_read
	lea dx, buffer
	mov ah, 09h
	int 21h
	call newLine



;	call MultipleDigit_int_to_str
;	call AppendToFile

; NOW READING FROM FILE
;	call File_read
	mov di, offset newbuffer
	mov si, offset newUsername
_1jumpb1:

	mov ax, [di]
	mov [si], ax
	inc si
	inc di
	cmp [di], 10d
	
	jne _1jumpb1

	inc di
	mov ax, [di]
	mov Score, ax


	mov dx, offset newbuffer
	mov ah, 09h
	int 21h

	mov [si],'$'
	inc di
	call newLine
	lea dx, Username
	mov ah, 09h
	int 21h
	call newLine

	;mov ax, [di]
	;sub ax, 48
	;mov Score, ax

	mov dx, Score
	add dl, 48
	mov ah, 02h
	int 21h
	call newLine
	;call File_read

	lea dx, newbuffer
	mov ah, 09h
	int 21h
		call File_read
	lea dx, buffer
	mov ah, 09h
	int 21h
	call newLine



;	call MultipleDigit_int_to_str
;	call AppendToFile

; NOW READING FROM FILE
;	call File_read
	mov di, offset newbuffer
	mov si, offset newUsername
_2jumpb2:

	mov ax, [di]
	mov [si], ax
	inc si
	inc di
	cmp [di], 10d
	
	jne _2jumpb2

	inc di
	mov ax, [di]
	mov Score, ax


	mov dx, offset newbuffer
	mov ah, 09h
	int 21h

	mov [si],'$'
	inc di
	call newLine
	lea dx, Username
	mov ah, 09h
	int 21h
	call newLine

	;mov ax, [di]
	;sub ax, 48
	;mov Score, ax

	mov dx, Score
	add dl, 48
	mov ah, 02h
	int 21h
	call newLine
	;call File_read

	lea dx, newbuffer
	mov ah, 09h
	int 21h
		call File_read
	lea dx, buffer
	mov ah, 09h
	int 21h
	call newLine


	call File_close	

	;call File_close	
endoffile:
	mov ah, 00h
	int 16H
	cmp al, 'E'
	je belowHigh
	cmp al, 'e'
	je belowHigh
	jmp highScreen
belowHigh:
	ret
Screen_Highscore ENDP

;//////////////////////////////////////////////////////
;//////////////////////////////////////////////////////

Screen_Exit PROC
	;after the game is finished
	call ClearScreen
; open the file and write the details of the player
	;call File_open
	   call File_openRW
    ; call File_read
    ; call WriteToFile
    lea si, Username
	lea di, buffer

jumpb1:

	mov ax, [si]
	mov [di], ax
	inc si
	inc di

	cmp [si], '$'
	jne jumpb1

	mov [di], 32d
	inc di
;	Multidigit variable code
	mov ax, Score
	mov dx, 0
jumpb2:	
	cmp ax, 0
	je exx_1

	mov bl, 10
	div bx


	
	mov bx, ax
	mov [di], bx 	;tenth unit
	inc di
	add dl, 48
	mov [di], dl 	;unit
	inc di
exx_1:
	mov [di],'$'
	inc di
	mov [di], 10d
	
;THis not working
	;call MultipleDigit_int_to_str

	call File_write_append

	call File_close 

;	shows the score of the player 
;	Options for player to go back to main menu or exit game 
;	setting curser
	mov dh, 10	;row
	mov dl, 14	;cols
	call setCursor
;	text prompts
	lea dx, Text_End_MainMenu
	mov ah, 09h
	int 21h
;	setting curser
	mov dh, 14	;row
	mov dl, 17	;cols
	call setCursor
;	text prompts
	lea dx, Text_End_Exit
	mov ah, 09h
	int 21h
;	taking the key as input
	mov ah, 00h
	int 16h
;	Starting the game
	cmp al, 'M'
	je exitmenu
	cmp al,'m'
	je exitmenu
	jmp exitnext
exitmenu:
	call Screen_Main_Menu
	jmp exitBelow
exitnext:
;	Exit
	cmp al, 'E'
	je exitBelow
	cmp al,'e'
	je exitBelow
exitBelow:
	mov ah, 04ch
	int 21h
	ret
Screen_Exit ENDP

;	Pause Screen when the game is running
Screen_Pause PROC
	mov dh, 10	;row
	mov dl, 14	;cols
	call setCursor
;	text Resume
	lea dx, Text_Pause_Resume
	mov ah, 09h
	int 21h
;	setting curser
	mov dh, 14	;row
	mov dl, 15	;cols
	call setCursor

	;exit button
	lea dx, Text_Pause_Exit
	mov ah, 09h
	int 21h
;	taking the key as input
	mov ah, 00h
	int 16h
;	Starting the game
	cmp al, 'R'
	je pauseResume
	cmp al,'r'
	je pauseResume
	jmp pauseExit
pauseResume:
	ret
pauseExit:
;	Exit
	cmp al, 'E'
	je exitBelowPause
	cmp al,'e'
	je exitBelowPause
exitBelowPause:
	call Screen_Exit

	ret
Screen_Pause ENDP
;*************************************************
;*************************************************
;*************************************************
;writting and reading from file
;reading and writing is on a txt file and username highSc is recorded
File_open PROC

	mov ah, 3ch
	lea dx, filename
	mov cl, 0
	int 21h
	mov fhandle, ax	

	ret
File_open ENDP

File_openRW PROC

	mov ah, 3dh
	mov al, 2
	mov dx, offset filename
	int 21h
	mov fhandle, ax
	
	ret

File_openRW ENDP

File_openExisting_read PROC
	
	mov ah, 3dh
	lea dx, filename
	mov al, 0
	int 21h
	mov fhandle, ax

	ret
File_openExisting_read ENDP

File_openExisting_write PROC
	
	mov ah, 3dh
	lea dx, filename
	mov al, 1
	int 21h
	mov fhandle, ax

	ret
File_openExisting_write ENDP

File_close PROC
	
	mov ah, 3eh
	mov bx, fhandle
	int 21h

	ret
File_close ENDP

File_write PROC uses ax bx cx dx

	mov cx, 0
	mov dx, 0

	mov ah, 42h
	mov al, 2
	int 21h

	mov ah, 40h
	mov bx, fhandle
	mov cx, 12		;length of what you want to write

	mov dx, offset buffer
	int 21h

	ret

File_write ENDP

File_write_append PROC uses cx
	
	 mov cx,0
    mov dx, 0

    mov bx, fhandle


    mov ah,42h
    mov al,2
    int 21h

    mov ah, 40h ; service to write to a file
    mov cx, 25

    mov dx, offset buffer
    int 21h

	ret
File_write_append ENDP

File_read PROC uses dx cx ax	
	
	mov ah, 3fh
	mov bx, fhandle
	mov cx, 25	;characters/bytes to read
	lea dx, buffer
	;mov al,0
	int 21h

	ret
File_read ENDP

;Procedure to display a new line 
newLine proc
;Input Nothing
;Output Nothing
;Displays a new line on screen

    ;Printing new line
    push dx

    mov dl, 10
    mov ah, 02h
    int 21h
    mov dl, 13
    mov ah, 02h
    int 21h

    pop dx

    ret
newLine endp


end main
