IDEAL
model small
stack 100h
dataseg
	s dw 2 ;step size 
	
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
	
	ballX dw 170
	ballY dw 100
	balldX dw 0
	balldY dw 0
	ballW dw 10
	ballH db 10
	balldX dw 0
	balldY dw 0
	
	gameOver db 0 ; BOOLEAN
codeseg
include "res.asm"
start:
	mov ax, @data
	mov ds, ax
	call graphmode
l:
	call printMatkot
	call printBall
	call update
	mov ax, 20 ; milisecs
	call delay
	cmp [gameOver], 0
	jne exit
	jmp l
exit:
	call txtmode
	printn "bye!"
	mov ah, 4Ch
	int 21h

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

PROC printBall
	mov cx, [ballX]
	mov dx, [ballY]
	mov bx, [ballW]
	mov al, [colorBall]
	mov ah, [ballH]
	call print_rect
ENDP

PROC update ; updates the y values
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
	jmp @@add
@@up:
	mov ax, [s]
	neg ax
	mov [rdy], ax 
	jmp @@add
@@down:
	mov ax, [s]
	mov [rdy], ax
	jmp @@add
@@w:
	mov ax, [s]
	neg ax
	mov [ldy], ax 
	jmp @@add
@@s:
	mov ax, [s]
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
END start