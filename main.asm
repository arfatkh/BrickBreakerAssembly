.model small
.stack 100h
.data

CANVA_SIZE_ROW dw 199
CANVA_SIZE_COL dw 319
COLLISION_MARGIN dw 10




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
        call DrawBall
        call moveBall




    jmp StartLoop






ret
gameLoop endp



;Moves the ball
moveBall PROC

    ;Move the ball
    mov ax,BallVelocRow
    add BallRow,ax
    mov ax,BallVelocCol
    add BallCol,ax

    ;Check if the ball is out of bounds in the X axis
    mov ax,CANVA_SIZE_ROW
    sub ax,BallSize ;Taking into account the size of the ball
    cmp BallRow,ax
    jg BallOutOfBoundsR
    cmp BallRow,0
    jl BallOutOfBoundsR

    ;Check if the ball is out of bounds in the Y axis
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

end main