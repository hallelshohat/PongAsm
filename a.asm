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
	call scan_num
	mov ax, cx
	cmp ax, 0
	je exit
	call print_uns
	line
	jmp l
exit:
	mov ah, 04Ch
	int 21h

END start	