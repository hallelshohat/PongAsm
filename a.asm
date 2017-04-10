IDEAL
model small
stack 100h
dataseg	
codeseg
include "res.asm"
start:
	mov ax, @data
	mov ds, ax
					; 40x25
	call graphmode
	mov dh, 0
	mov bh, 0
l:
	putc 7
	mov ax, 100
	call delay
	jmp l
exit:
	mov ah, 04Ch
	int 21h
	
END start	