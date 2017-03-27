IDEAL
model small
stack 100h
dataseg
	s dw 3 ;step size
	wid dw 10
	height db 50 
	color db 0Ah
	
	lx dw 20
	ly dw 50
	
	rx dw 300
	ry dw 50
codeseg
include "res.asm"
start:
	mov ax, @data
	mov ds, ax
	call graphmode
l:
	call printMatkot
	call update
	mov ax, 50 ; milisecs
	call delay
	jmp l
	call txtmode
exit:
	mov ah, 4Ch
	int 21h

PROC printMatkot ; prints the matkot
	push ax bx cx dx
	call printBlack	
	mov cx, [lx] ;x
	mov dx, [ly] ;y
	mov bx, [wid] ;width
	mov al, [color] ;color
	mov ah, [height] ;height
	call print_rect
	
	mov cx, [rx] ;x
	mov dx, [ry] ;y
	mov bx, [wid] ;width
	mov al, [color] ;color
	mov ah, [height] ;height
	call print_rect
	pop dx cx bx ax
	ret
ENDP

PROC update ; updates the y values
	push ax
	call checkKeyPress ; ah-scan code
	jnz @@pressed
	jmp @@exit
@@pressed:
	cmp ah, 72 ; up key
	je @@up
	cmp ah, 80 ; down key
	je @@down
	cmp ah, 17 ; w key
	je @@w
	cmp ah, 31 ; s key
	je @@s
	cmp ah, 1 ; esc key
	je @@stop
	jmp @@exit
@@up:
	mov ax, [ry]
	sub ax, [s]
	cmp ax, 0
	jle @@exit
	mov ax, [s]
	sub [ry], ax
	jmp @@exit
@@down:
	mov ax, [ry]
	add ax, [s]
	add al, [height]
	cmp ax, 200
	jae @@exit	
	mov ax, [s]
	add [ry], ax
	jmp @@exit
@@w:
	mov ax, [ly]
	sub ax, [s]
	cmp ax, 0
	jle @@exit	
	mov ax, [s]
	sub [ly], ax
	jmp @@exit
@@s:
	mov ax, [ly]
	add al, [height]
	add ax, [s]
	cmp ax, 200
	jae @@exit	
	mov ax, [s]
	add [ly], ax
	jmp @@exit
@@exit:
	pop ax
	ret	
@@stop:
	pop ax
	call txtmode
	printn "bye"
	mov ah, 04Ch
	int 21h
	ret
ENDP

PROC printBlack
	push ax bx cx dx
	mov cx, [lx] ; x
	mov dx, 0 ; y
	mov bx, [wid] ;width
	mov ax, [ly] ; height
	mov ah, al
	mov al, 4 ;color
	call print_rect ; prints the top of the left paddle
	
	mov cx, [lx] ;x
	mov dx, [ly] ;y
	add dl, [height] 
	mov ah, 200 ;height
	mov bx, [ly]
	add bl, [height]
	sub ah, bl 
	mov al, 03h
	mov bx, [wid]
	call print_rect ; prints the bottom of the left paddle

	mov cx, [rx] ; x
	mov dx, 0 ; y
	mov bx, [wid] ;width
	mov ax, [ry] ; height
	mov ah, al
	mov al, 4 ;color
	call print_rect ; prints the top of the right paddle
	
	mov cx, [rx] ;x
	mov dx, [ry] ;y
	add dl, [height] 
	mov ah, 200 ;height
	mov bx, [ry]
	add bl, [height]
	sub ah, bl 
	mov al, 03h
	mov bx, [wid]
	call print_rect ; prints the bottom of the right paddle
	pop dx cx bx ax
	ret
ENDP
END start