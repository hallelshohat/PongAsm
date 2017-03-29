IDEAL
model small
stack 100h
dataseg	
	u dw 0
	d dw 0
	x dw 100
	y dw 100
codeseg
include "res.asm"
start:
	mov ax, @data
	mov ds, ax
	call graphmode
l:
	call get_scan_code
	cmp al, 72
	je up
	cmp al, 80
	je down
	add al, 128
	cmp al, 200
	je nup
	cmp al, 208
	je ndown
	call update
	mov ax, 20 ;milisecs
	call delay
	jmp l
up:
	mov [u], 1
	jmp l
down:
	mov [d], 1
	jmp l
nup:
	mov [u], 0
	jmp l
ndown:	
	mov [d], 0
	jmp l
exit:
	call txtmode
	mov ah, 4Ch
	int 21h
PROC update
	mov ax, [y]
	sub ax, [u]
	mov [y], ax
	
	mov ax, [y]
	add ax, [d]
	mov [y], ax
	
	mov ah, 50
	mov al, 4
	mov bx, 20
	mov cx, [x]
	mov dx, [y]
	call print_rect
	ret
ENDP	
END start	