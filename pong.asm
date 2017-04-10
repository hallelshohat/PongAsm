IDEAL
model small
stack 100h
dataseg
	sM dw 3 ;step size 

	wid dw 10
	height db 50 
	
	colorMatka db 0Ah
	colorBall db 01h
	
	lx dw 20
	ly dw 50
	ldy dw 0
	
	rx dw 300
	ry dw 50
	rdy dw 0
	
	ballX dw ?
	ballY dw ?
	balldX dw ?
	balldY dw ?
	ballW dw 7
	ballH db 7
	
	gameOver db 0 ; BOOLEAN
	
	rScore db 0
	lScore db 0
	isWait db 1 ; BOOLEAN
codeseg
include "res.asm"
start:
	mov ax, @data
	mov ds, ax
	call graphmode
	call init
l:
	call printMatkot

	call updateM
	gotoXY 0, 10
	mov ax, [ballX]
	call print_uns
	gotoXY 0, 25
	mov ax, [ballY]
	call print_uns
	mov ax, 20 ; milisecs
	call delay
	cmp [gameOver], 0
	jne exit
	cmp [isWait], 0
	je ballUpd
	jmp l
ballUpd:
	call printBall
	call updateB
	jmp l
exit:
	call txtmode
	printn "bye!"
	mov ah, 4Ch
	int 21h
PROC init
	push ax bx
	mov [ballX], 153
	mov [ballY], 93
	mov bx, 2
	call rand
	cmp ax, 0
	je @@xzero
	mov [balldX], ax
	jmp @@y
@@xzero:
	mov [balldX], -1
@@y:
	call rand
	cmp ax, 0
	je @@yzero
	mov [balldY], ax
	jmp @@exit
@@yzero:
	mov [balldY], -1
@@exit:
	pop bx ax
	ret
ENDP 

PROC printMatkot ; prints the matkot
	push ax bx cx dx
	call printBlack	
	mov cx, [lx] ;x
	mov dx, [ly] ;y
	mov bx, [wid] ;width
	mov al, [colorMatka] ;color
	mov ah, [height] ;height
	call print_rect
	
	mov cx, [rx] ;x
	mov dx, [ry] ;y
	mov bx, [wid] ;width
	mov al, [colorMatka] ;color
	mov ah, [height] ;height
	call print_rect
	pop dx cx bx ax
	ret
ENDP

PROC updateM ; updates the y values
	push ax
	call checkKeyPress ; al-scan code
	;PRESSED
	cmp al, 72 ; up key
	je @@up
	cmp al, 80 ; down key
	je @@down
	cmp al, 17 ; w key
	je @@w
	cmp al, 31 ; s key
	je @@s
	cmp al, 1 ; esc key
	je @@stop
	;RELEASED
	cmp al, 200 ; up key
	je @@nru
	cmp al, 208 ; down key
	je @@nrd
	cmp al, 145 ; w key
	je @@nlu
	cmp al, 159 ; d key
	je @@nld
	cmp al, 1Ch ; enter key
	je @@dWait
	jmp @@add
@@up:
	mov ax, [sM]
	neg ax
	mov [rdy], ax 
	jmp @@add
@@down:
	mov ax, [sM]
	mov [rdy], ax
	jmp @@add
@@w:
	mov ax, [sM]
	neg ax
	mov [ldy], ax 
	jmp @@add
@@s:
	mov ax, [sM]
	mov [ldy], ax
	jmp @@add
@@nru:
	cmp [rdy], 0
	jg @@add
	mov [rdy], 0
	jmp @@add
@@nlu:	
	cmp [ldy], 0
	jg @@add
	mov [ldy], 0
	jmp @@add
@@nrd:
	cmp [rdy], 0
	jl @@add
	mov [rdy], 0
	jmp @@add
@@nld:	
	cmp [ldy], 0
	jl @@add
	mov [ldy], 0
	jmp @@add	
@@stop:
	pop ax
	mov [gameOver], 1
	ret
@@add:
	call ad
	pop ax
	ret	
@@dWait:
	mov [isWait], 0
	jmp @@add
ENDP

PROC ad
	push ax
@@chkl:
	mov ax, [ly]
	add ax, [ldy]
	cmp ax, 0
	jle @@zl 
	add al, [height]
	cmp ax, 200
	jae @@zl
	jmp @@chkr
@@zl:
	mov [ldy], 0
	jmp @@chkr
@@chkr:
	mov ax, [ry]
	add ax, [rdy]
	cmp ax, 0
	jle @@zr 
	add al, [height]
	cmp ax, 200
	jae @@zr
	jmp @@add
@@zr:
	mov [rdy], 0
	jmp @@add
@@add:
	mov ax, [ly]
	add ax, [ldy]
	mov [ly], ax
	
	mov ax, [ry]
	add ax, [rdy]
	mov [ry], ax
	pop ax
	ret
ENDP 

PROC printBlack
	push ax bx cx dx
	mov cx, [lx] ; x
	mov dx, 0 ; y
	mov bx, [wid] ;width
	mov ax, [ly] ; height
	mov ah, al
	mov al, 0 ;color
	call print_rect ; prints the top of the left paddle
	
	mov cx, [lx] ;x
	mov dx, [ly] ;y
	add dl, [height] 
	mov ah, 200 ;height
	mov bx, [ly]
	add bl, [height]
	sub ah, bl 
	mov al, 0
	mov bx, [wid]
	call print_rect ; prints the bottom of the left paddle

	mov cx, [rx] ; x
	mov dx, 0 ; y
	mov bx, [wid] ;width
	mov ax, [ry] ; height
	mov ah, al
	mov al, 0 ;color
	call print_rect ; prints the top of the right paddle
	
	mov cx, [rx] ;x
	mov dx, [ry] ;y
	add dl, [height] 
	mov ah, 200 ;height
	mov bx, [ry]
	add bl, [height]
	sub ah, bl 
	mov al, 0
	mov bx, [wid]
	call print_rect ; prints the bottom of the right paddle
	pop dx cx bx ax
	ret
ENDP

PROC printBall
	mov cx, [ballX]
	mov dx, [ballY]
	mov bx, [ballW]
	mov al, [colorBall]
	mov ah, [ballH]
	call print_rect
	call ball_black
ENDP

PROC updateB
	call checkCollision
	mov ax, [balldX]
	add [ballX], ax
	mov ax, [balldY]
	add [ballY], ax
	ret
ENDP

PROC ball_black
	push ax bx cx dx
	mov bx, [balldX]
	cmp bx, 0
	je @@checkY
	jl @@Xminus
	jmp @@Xplus

@@Xminus:
	mov cx, [ballX]
	add cx, [ballW] ; x
	neg bx ; width
	shl bx, 1 ; for preventing next step
	mov dx, [ballY] ; y
	dec dx 
	mov ah, [ballH] ; height
	add ah, 3
	mov al, 0 ;color
	call print_rect
	jmp @@checkY
@@Xplus:
	mov cx, [ballX]
	sub cx, [balldX] ; x
	shl bx, 1
	mov dx, [ballY] ; y
	dec dx
	mov ah, [ballH] ; height
	add ah, 2
	mov al, 0 ;color
	call print_rect
	jmp @@checkY
@@checkY:
	mov ax, [balldY]
	cmp ax, 0
	je @@exit
	jl @@yMinus
	jmp @@yPlus
@@yMinus:
	mov cx, [ballX]
	dec cx
	mov dx, [ballY]
	add dl, [ballH]
	mov bx, [ballW]
	add bx, 2
	neg ax
	mov ah, al ;height
	shl ah, 1
	mov al, 0
	call print_rect
	jmp @@exit
@@yPlus:
	mov cx, [ballX]
	dec cx
	mov dx, [ballY]
	sub dx, [balldY]
	mov bx, [ballW]
	add bx, 2
	mov ah, al
	shl ah, 1
	mov al, 0
	call print_rect
	jmp @@exit
@@exit:
	pop ax bx cx dx
	ret
ENDP

PROC checkCollision
	push ax
	; screen collision
	mov ax, [ballX]
	cmp ax, 0 
	je @@lrScreen
	add ax, [ballW]
	cmp ax, 320
	je @@lrScreen
	
	mov ax, [ballY]
	cmp ax, 0
	je @@tbScreen
	add al, [ballH]
	cmp ax, 200
	je @@tbScreen
	jmp @@exit
@@lrScreen:
	neg [balldX]
	jmp @@exit
@@tbScreen:
	neg [balldY]
	jmp @@exit	
	
@@exit:
	pop ax
	call checkColiisionM
	ret
ENDP

PROC checkColiisionM
	push ax bx
	; left matka
	mov ax, [ballY]
	cmp ax, [ly]
	ja @@aboveL
	jmp @@checkR
@@aboveL:
	add al, [ballH]
	mov bx, [ly]
	add bl, [height]
	cmp ax, bx
	jb @@belowL
	jmp @@checkR
@@belowL:
	mov ax, [lx]
	add ax, [wid]
	cmp ax, [ballX]
	je @@yes
@@checkR:
	;right matka
	mov ax, [ballY]
	cmp ax, [rY]
	ja @@aboveR
	jmp @@checkScore
@@aboveR:
	add al, [ballH]
	mov bx, [ry]
	add bl, [height]
	cmp ax, bx
	jb @@belowR
	jmp @@checkScore
@@belowR:	
	mov ax, [ballX]
	add ax, [ballW]
	cmp ax, [rx]
	je @@yes
	jmp @@checkScore
@@yes:
	neg [balldX]
	jmp @@exit
@@checkScore:
	mov ax, [lx]
	add ax, [wid]
	cmp [ballX], ax
	jb @@rightScore
	mov ax, [ballX]
	add ax, [ballW]
	cmp ax, [rx]
	ja @@leftScore
	jmp @@exit
@@rightScore:
	inc [rScore]
	jmp @@score
@@leftScore:
	inc [lScore]
	jmp @@score		
@@score:
	mov [isWait], 1
	call eraseBall
	call init
	jmp @@exit
@@exit:
	pop bx ax
	ret
ENDP

PROC eraseBall
	mov ah, [ballH]
	add ah, 2
	mov cx, [ballX]
	dec cx
	mov dx, [ballY]
	dec dx
	mov bx, [ballW]
	add bx, 2
	mov al, 0 ; color
	call print_rect
	ret
ENDP

END start