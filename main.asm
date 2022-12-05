.model small
.stack 300h
.data

;File Writing is breaking Screen_Exit
;cant print the Score and lives 



;/// Structures Definition
BALL STRUCT 
    ;FOR THE BALL
    BSize dw 8 ;Size of the ball
    Row dw 150;
    Col dw 50
    Color db 5

    VelocRow dw 1 ;Velocity of the ball
    VelocCol dw 1

BALL ENDS
Balls BALL <,,,4,2,2> , <,,,,2,2> , <,,,3,3> 
;,<5,,,5,6,2> , <5,,,3,2,2> , <5,,,10,10> 
nBalls dw 1 ;Number of balls
nBallsLost dw 0 ;Number of balls lost


BRICK STRUCT
    ;FOR THE BRICKS
    BWidth dw 40
    BHeight dw 2
    BRow dw 10;
    BCol dw 4
    BColor db 4
    strength db 1; Number of hits to destroy the brick

BRICK ENDS

; FOR THE DrawBrick
; GlobalBrickHeight dw 15
GlobalBrickHeight dw 10
GlobalBrickWidth dw 20

; GlobalBrickWidth dw 30
BrickRow dw 1000;
BrickCol dw 4000
BrickColor db 4



;/// Variables Definition
StartingRow dw 50
StartingCol dw 55
rowGap dw 15
colGap dw 26
BricksInCol dw 8
NBrickRows dw 1

Bricks Brick 4 dup(<,,,,,>)

nBricks dw 4
nBricksDestroyed dw 0



;FOR COLLSION RECOGNITION AND RESPONSE
XOverlap dw 0
YOverlap dw 0



;TIMER
Timer dw 21


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



;FOR ANIMATIONS 

;LEVEL ANIMATION
LevelText db 'Level:','$'
LevelTextPress db 'Press any key to continue','$'





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

BallVelocRow dw 1 ;Velocity of the ball
BallVelocCol dw 1







;For the pedal
PedalWidth dw 60
PedalHeight dw 4
pedalRow dw 190

pedalCol dw 50
pedalColor db 0ffh 
pedalVelocity dw 30





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

	call NextLevel ;Starts the game from level 1

    StartLoop:

        ;Get Time using time interrupt
        mov ah,2Ch
        int 21h

        cmp dh,TimeTmp ;DL has the current Time Sec/100 (0-99) . And TimeTmp has the last time
        je SKipTimer ;If the time is the same, then skip the timer

        mov TimeTmp,dh
		dec Timer

		SkipTimer:

		; cmp Timer,0 ;If the timer is 0, then the game is over
		; je TimeOverGameOver


        call DrawAllBricks



        call moveAllBalls
        call drawAllBalls



        
        call movePedal
        call DrawPedal

     
        xor bx,bx
        MOV CX, 0
        mov dx, 0ddeeh
        ; MOV DX, 9680H
        mov al,0
        MOV AH, 86H
        INT 15H



        ; call drawAllBalls


        ; call DrawPedal
        ; call DrawAllBricks
  
        ; call DrawBrick

        call movePedal
        call DrawPedal

        call moveAllBalls
        call drawAllBalls

        call ClearScreen

    

 
        ; call ;    call DrawAllBricks

        ; call DrawPedal
        ; cmp Score, 9
        ; jge Level2

        ; jmp StartLoop

    ; Level2:
    ; inc pedalColor
    ; mov PedalWidth, 50


    jmp StartLoop

	TimeOverGameOver:
		; call GameOver
		mov ah,4ch
		int 21h
		; jmp main



ret
gameLoop endp

GenerateLevel PROC uses si cx ax dx

mov si , offset Bricks


mov cx , NBrickRows
mov bx , StartingRow
LoopOuter:
    push cx

    mov dx , StartingCol
    mov cx , BricksInCol
    GenerateLevelLoop:
        
            mov [si].BCol,dx
            mov [si].BRow,bx
			
			;Setting the color of the brick to a random color
			; mov [si].BColor,4

            add dx,colGap


        
        add si , SIZEOF BRICK
    loop GenerateLevelLoop
            
    add bx,rowGap




    pop cx
loop loopOuter







ret
GenerateLevel endp


NextLevelAnimation PROC


	AnimationLoop:

	;Wait for a few miliseconds

        xor bx,bx
        MOV CX, 0
        mov dx, 0ddeeh
        ; MOV DX, 9680H
        mov al,0
        MOV AH, 86H
        INT 15H


	call clearScreen

	;SET CURSOR TO THE CENTER OF THE SCREEN
	mov ah,02h
	mov bh,0
	mov dh,10
	mov dl,16
	int 10h

	; ;PRINT THE LEVEL TEXT
	mov ah,09h
	mov dx,offset LevelText
	int 21h

	
	;PRINT THE LEVEL NUMBER
	mov cx,1
	mov al,currentLevel
	add al,48
	mov bh,0
	mov ah,09h
	mov bl,4h
	int 10h


	;SET CURSOR TO THE CENTER OF THE SCREEN
	mov ah,02h
	mov bh,0
	mov dh,20
	mov dl,8
	int 10h



	;PRINT THE PRESS ANY KEY TO CONTINUE TEXT



	mov ah,09h
	mov dx,offset LevelTextPress
	int 21h


	;WAIT FOR A KEY TO BE PRESSED
	mov ah,00h
	int 16h

	jz AnimationLoop




	loop AnimationLoop



ret
NextLevelAnimation endp






;Makes the new level
NextLevel PROC uses ax bx cx dx si 

	mov BallCol,50
	mov BallRow,120

	inc currentLevel

	call NextLevelAnimation


	;Resetting the Balls
	mov nBallsLost,0
	mov nBalls,1
	mov BallVelocCol,2
	mov BallVelocRow,2
	mov BallColor,4






	
	cmp currentLevel, 1
	je Level1

	cmp currentLevel, 2
	je Level2

	cmp currentLevel, 3
	je Level3

	; cmp currentLevel, 3
	; je Level4

	; cmp currentLevel, 4
	; je YouWin

YouWin:
	mov ax, 4c00h
	int 21h

Level1:
	; mov currentLevel, 1 ;Set the level to 1
	mov Lives, 3 ;Set the lives to 3
	mov nBricksDestroyed , 0 ;Set the bricks destroyed to 0
	call GenerateLevel ;Generate the level
	ret ;Return

Level2:
	; mov currentLevel, 2 ;Set the level to 2
	mov Lives, 3 ;Set the lives to 3
	mov nBricksDestroyed , 0 ;Set the bricks destroyed to 0

	mov si,offset Balls
	add [si].VelocCol,2 ;Increase the velocity of the ball
	add [si].VelocRow,2 ;Increase the velocity of the ball
	sub PedalWidth, 10 ;Decrease the width of the pedal

	;Increase the brick strength 
	mov si, offset Bricks
	mov cx, nBricks
	LoopIncreaseStrenght:
		mov [si].strength,2
		add si, SIZEOF BRICK
	loop LoopIncreaseStrenght

	call GenerateLevel ;Generate the level
	
	ret
Level3:
	;close
	mov ah,4ch
	int 21h





	ret
NextLevel endp

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
moveAllBalls PROC uses ax bx cx dx si

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

		mov ax,[si].BSize
		mov BallSize,ax


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
DrawBrick PROC uses si cx ax bx dx
;BrickCol ==> bx
;BrickRow ==> dx
;BrickColor ==> al


;---------------
; IF YOU WANT TO USE VARIABLES
;---------------

;  X-Y coordinates of the ball
    mov bx, BrickCol
    ; mov DrawPixCol,ax
    mov dx, BrickRow
    ; mov DrawPixRow,ax
    mov al, BrickColor
    ; mov DrawPixColor,al

    mov cx,GlobalBrickHeight  ;
    LoopPrintRowBrick:  ;Runs for each row
        push cx ;save cx
        push bx ; save DrawPixCol

        mov cx,GlobalBrickWidth
        LoopPrintColBrick:  ;Runs for each column
            push cx
            mov cx,bx
            call DrawPixelFast
            inc bx
            pop cx
        loop LoopPrintColBrick

        inc dx ;increment row

        pop bx ; restore DrawPixCol
        pop cx

    loop LoopPrintRowBrick



    

ret
DrawBrick ENDP


;Draw all bricks
DrawAllBricks PROC uses si cx ax bx

    mov cx,nBricks
    mov si,offset Bricks

    LoopDrawBrick:
       
        mov ax, [si].BRow
        mov BrickRow,ax

        mov ax, [si].BCol
        mov BrickCol,ax

        mov al, [si].BColor
        mov BrickColor,al

        call DrawBrick

        add si,SIZEOF BRICK
        
    loop LoopDrawBrick

    ret

DrawAllBricks ENDP


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


	; ;if Tab is pressed
	; cmp ah, 0fh
	; je increasenBalls



    cmp ah,04DH ;if ight Arrow
    je movePedalToRight
    cmp ah,04BH ;if Left Arrow
    je movePedalToLeft
    
    cmp ah, 01h ;if ESC
    je ShowPause
    


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

	increasenBalls:
		inc nBalls

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
moveBall PROC uses ax bx cx dx si di


	;SEt the cursor position
		mov ah,02h
		mov bh,0
		mov dl,20
		mov dh,20
		int 10h

		;Print the number of balls
		mov cx,1
		mov al,byte ptr Timer
		mov bh,0
		add al,48
		mov ah,09h
		mov bl,4h 
		int 10h



		;SEt the cursor position
		mov ah,02h
		mov bh,0
		mov dl,30
		mov dh,20
		int 10h

		;Print the number of balls
		mov cx,1
		mov al,byte ptr Lives
		mov bh,0
		add al,48
		mov ah,09h
		mov bl,5h 
		int 10h



		
		




    ;Move the ball
    mov ax,BallVelocRow
    add BallRow,ax
    mov ax,BallVelocCol
    add BallCol,ax


    ;Check if the ball is out of bounds in the y axis
    mov ax,CANVA_SIZE_ROW
    sub ax,BallSize ;Taking into account the size of the ball
    ; sub ax,COLLISION_MARGIN ;Taking into account the margin

    cmp BallRow,ax
    jg BallOutOfBoundsRDown
    cmp BallRow,0
    jl BallOutOfBoundsR

    ;Check if the ball is out of bounds in the x axis
    mov ax,CANVA_SIZE_COL
    sub ax,BallSize ;Taking into account the size of the ball
    ; sub ax,COLLISION_MARGIN ;Taking into account the margin

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

    jmp StopAllCollsion ; return from the procedure


    SkipPedalCollision:
   ;Checking brick collisons
    mov di,offset Bricks 
    mov cx,nBricks

   LoopBrickCollision:

         ;All these conditions must be true for a collision to occur

        ; BallCol < BrickCol + BrickWidth &&
        ; BallCol + BallSize > BrickCol &&
        ; BallRow < BrickRow + GlobalBrickHeight &&
        ; BallSize + BallRow > BrickRow

        mov ax, [di].BCol
        add ax, GlobalBrickWidth
        cmp BallCol,ax
        jnl SkipBrickCollision

        mov ax,BallCol 
        add ax,BallSize
        cmp [di].BCol,ax
        jnl SkipBrickCollision

        mov ax,[di].BRow
        add ax,GlobalBrickHeight
        cmp BallRow,ax
        jnl SkipBrickCollision


        mov ax,BallRow
        add ax,BallSize
        cmp [di].BRow,ax
        jnl SkipBrickCollision

        ;If no skips means collison occured


        ;Change the direction of the ball
        ; inc BallColor
        inc [di].BColor
        dec [di].strength


		;Collision resolution by using overlap method
		
		;Calculate the overlap on both axis
		mov ax, BallCol
		sub ax, [di].BCol
		mov bx, GlobalBrickWidth
		sub bx, BallSize
		sub bx, ax
		mov XOverlap, bx

		mov ax, BallRow
		sub ax, [di].BRow
		mov bx, GlobalBrickHeight
		sub bx, BallSize
		sub bx, ax
		mov YOverlap, bx


		


		;Check which axis has the smallest overlap
		mov ax,YOverlap
		cmp XOverlap, ax
		jl XAxisOverlap

		;Y Axis has the smallest overlap
		;Return the ball to previous position
			mov ax,BallVelocRow
			sub BallRow,ax
			sub BallRow,2 ;To avoid the ball getting stuck in the brick

			mov ax, BallVelocCol
			sub BallCol,ax
			sub BallCol,2 ;To avoid the ball getting stuck in the brick

			NEG BallVelocRow ; Negate the velocity of the ball in the y axis
			
			jmp DoneOverlap ; return from the procedure

		XAxisOverlap:
			;X Axis has the smallest overlap
			;Return the ball to previous position
			mov ax,BallVelocRow
			sub BallRow,ax
			sub BallRow,2 ;To avoid the ball getting stuck in the brick


			mov ax, BallVelocCol
			sub BallCol,ax
			sub BallCol,2 ;To avoid the ball getting stuck in the brick


			NEG BallVelocCol ; Negate the velocity of the ball in the x axis
			jmp DoneOverlap




		DoneOverlap:


		mov ah,0
        cmp ah,[di].strength ;If the strength is 0 then the brick is destroyed
        je BrickDestroyed

		jmp StopAllCollsion ; return from the procedure

        ;Things to do when a brick is destroyed
        BrickDestroyed:
			mov [di].BCol,300h ;Move the brick out of the screen
			mov al,[di].BColor ; Because the score depends on the color of the brick
			add Score,al
			inc nBricksDestroyed ;Increment the number of bricks destroyed

			mov ax,nBricks
			cmp nBricksDestroyed,ax ;If all the bricks are destroyed
			jne StopAllCollsion ;If not all the bricks are destroyed


			;If all the bricks are destroyed
			call NextLevel
			call WaitForKeypress

			





        SkipBrickCollision:

        add di,SIZEOF Brick ; Move to the next brick

	dec cx
    jnz LoopBrickCollision


	ret
	BallOutOfBoundsRDown:
		;If the ball is out of bounds in the y axis
		inc nBallsLost

		;IF there is only one ball 
		mov ax,nBalls
		cmp ax,1
		je SkipHideBall

	


		;Hiding the ball
		; mov BallCol,
		mov BallRow,0
		mov BallCol,0
		mov BallColor,4
		mov BallVelocCol,0
		mov BallVelocRow,0




		; Check if the player has lost all the balls
		mov ax,nBallsLost
		cmp ax,nBalls
		jne NextBall

		SkipHideBall:

		;If the player has lost all the balls
		dec Lives
		call ResetBall;

		;Check if the player has lost all the lives
		cmp Lives,0
		jne NextBall

		;If the player has lost all the lives
		; call GameOver
		mov ah,4ch
		int 21h

	

		

		;If the player has lost all the balls
		ret

		NextBall:
		
	

		


		ret

	BallOutOfBoundsR:
		;Return the ball to previous position
		mov ax,BallVelocRow
		sub BallRow,ax
		mov ax, BallVelocCol
		sub BallCol,ax

		neg BallVelocRow





		ret

	BallOutOfBoundsC:
		;Return the ball to previous position
		mov ax,BallVelocRow
		sub BallRow,ax
		mov ax, BallVelocCol
		sub BallCol,ax
		neg BallVelocCol
		ret

	StopAllCollsion:

ret
moveBall endp


ResetBall PROC

	mov BallCol,100
	mov BallRow,100

	call DrawBall
	call WaitForKeypress


ret
ResetBall endp


;Waits for a keypress
WaitForKeypress PROC uses ax

	mov ah,0
	int 16h
	ret

WaitForKeypress endp



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


;Draws a pixel at the specified row and column
DrawPixelFast PROC uses ax 
;Input:
;DrawPixRow ==> DX
;DrawPixCol; ==> CX
;DrawPixColor ==> AL


    MOV AH, 0Ch
    INT 10H

  

    ret

DrawPixelFast endp



; DrawMac MACRO Color x ,y

;     MOV AH, 0Ch
;     MOV AL, Color
;     MOV CX, x
;     MOV DX, y
;     INT 10H


; DrawMac ENDM


;Clears The Screen
ClearScreen PROC uses ax bx


    ; ;set video mode
    Mov ah,00h ;set video mode
    Mov al,13 ;choose mode 13
    Int 10h

;  mov al,00h
;     MOV AH,0Bh
;     MOV BH,00h
;     MOV BL,00h
; ;     INT 10h


;    mov ah,06h
;     xor al,al
;     xor cx,cx
;     mov dh,30
;     mov dl,80
;     mov bh,00010000b
;     int 10h

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

   


    ; ;Set background color
    ; MOV AH,0Bh 		
    ; MOV BH,00h 		
    ; MOV BL,00h 		
    ; INT 10h    	


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
