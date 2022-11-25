.model small
.stack 100h
.data

CANVA_SIZE_ROW dw 199
CANVA_SIZE_COL dw 319
COLLISION_MARGIN dw 5




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
BallColor db 5

BallVelocRow dw 5 ;Velocity of the ball
BallVelocCol dw 5


;For the pedal
PedalWidth dw 60
PedalHeight dw 8
pedalRow dw 170
pedalCol dw 50
pedalColor db 4 
pedalVelocity dw 10


.code

main PROC
    mov ax, @data
    mov ds, ax

   call ClearScreen



   ; call DisplayMenu;  ;And Game loop can be called from this menu

   call gameLoop

   
    
    
  


mov ah,04ch
int 21h

main endp

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
    ; dec BallRow ;  Move the ball a little bit to the right to avoid the collision 

    ;change ball color
    inc BallColor


    







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

end main