IDEAL 
model small
stack 100h
dataseg
	cells db 100 dup(0)
codeseg
	include "res.asm"
start:
	mov ax, @data
	mov ds, ax
	call graphmode
	call INIT_MOUSE
	mov ah, 10
	mov cx, 100
	mov dx, 50
	mov bx, 100
	mov al, 4
	call print_rect
	call GET_MOUSE_POS
	call waitForKeyPress
	call txtmode

exit:
	mov ah, 4Ch
	int 21h
END start	