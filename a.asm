IDEAL
model small
stack 100h
dataseg	
codeseg
include "res.asm"
start:
	mov ax, @data
	mov ds, ax
					
	;call graphmode
	call scan_num
	mov ax, cx
	call print_uns
exit:
	mov ah, 04Ch
	int 21h
	
END start	