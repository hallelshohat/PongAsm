IDEAL
model small
stack 100h
dataseg
	fileName db "l", 0
	readBuffer dw 0
	writeBuffer dw 68
	w db "aa"
codeseg
include "res.asm"
start:
	mov ax, @data
	mov ds, ax
	
	call scan_num
	mov ax, cx 
	call print_uns
exit:
	mov ah, 04Ch
	int 21h

END start	