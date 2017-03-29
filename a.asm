IDEAL
model small
stack 100h
dataseg	
codeseg
include "res.asm"
start:
	mov ax, @data
	mov ds, ax
	
	lea bx, [00]
l:	
	mov al, [bx]
	print_color al, al
	inc bx
	jmp l
exit:
	mov ah, 04Ch
	int 21h
	
END start	