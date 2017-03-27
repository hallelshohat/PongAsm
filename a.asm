IDEAL
model small
stack 100h
dataseg	
	save db 0
codeseg
include "res.asm"
start:
	mov ax, @data
	mov ds, ax
l:	
	call check
	cmp al, [save]
	mov ah, 0
	call print_uns
	jmp l
g:
	
exit:
	mov ah, 4Ch
	int 21h
PROC check ; in dl - 	
	in al, 60h
	call clearBuffer
	ret
ENDP	
END start	