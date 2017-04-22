IDEAL
model small
stack 100h
dataseg	
codeseg
include "res.asm"
start:
	mov ax, @data
	mov ds, ax
	mov ax, 0
l:
	mov bx, 100
	call rand
	cmp ax, 50
	jb @@xzero
	mov cx, 1
	jmp @@y
@@xzero:
	mov cx, -1
@@y:
	call rand
	cmp ax, 50
	jb @@yzero
	mov dx, 1
	jmp l
@@yzero:
	mov dx, -1
	mov ax, cx
	call prints
	mov ax, dx
	putc ' '
	call prints
	mov ax, 1000
	call delay
	line
	jmp l
exit:
	mov ah, 04Ch
	int 21h

END start	