;MACROS:
;	PUTC - parameters: char(byte), prints the character.
;	gotoXY - parameters: a- row, b- colomn. puts the cursor in this location
;	PRINT_COLOR - paramaters: char(byte), color(byte). prints the character with the color. color table- end of file
;	LINE - going down one line.
;	PRINT_STR - parameters: string, prints the string(without a line ending).
;	PRINTN - parameters: string, prints the string(with a line ending).
 
;PROCEDURES:
;	PRINT_UNS - prints the value in ax register(unsigned).
;	PRINTS - prints the value in ax register(signed).
;	SCAN_NUM - scans a number to cx register.
;	SCAN_STR - scans a string to the memory address in cx(0 - end of string).
;	graphmode - moves to video mode.
;	txtmode - moves to text mode
;	delay - delays in ax millisecs
;	clearBuffer - clears the keyboard buffer
;	checkKeyPress 	check for keyPress in the buffer. 
;					ZF: 0 - if there is a keyPress, 1 - if any key pressed. 
;					ah = scan code, al = ascii char
;	waitForKeyPress - waits for a keypress. no echo
;	PRINT_PIXEL - prints a pixel in the specified location and color. cx - x, dx - y, al - color.
;	PRINT_LINE - prints a line. bx - length, cx - x, dx -  y, al - color
;	PRINT_RECT - prints a rectangle. ah - height, cx - x, dx - y, bx - width, al - color.
;	INIT_MOUSE - initializes the mouse in graphics mode
;	GET_MOUSE_POS - gets the position and status of the mouse. returns: CX - x, DX - y, BX - status(right bit- left key, 2nd bit- right key).	

;-------------------------variables-----------------------------------------------------------------------------------
count db 0
;-------------------------macros--------------------------------------------------------------------------------------
MACRO PUTC char
        push    ax dx
        mov     dl, char
        mov		ah, 02h
        int     21h     
        POP     dx ax
ENDM

MACRO gotoXY a, b ; a = row, b = col  
    push ax bx dx
	mov ah, 02h
    mov dh, a
    mov dl, b
    mov bh, 0
    int 10h
	pop dx bx ax
ENDM    

MACRO PRINT_COLOR char, color ; 4 upper bits: background color, 4 lower bits: character color.
	push ax bx cx dx
	mov ah, 09h
	mov al, char
	mov bh, 0 ;page number
	mov bl, color 
	mov cx, 1
	int 10h
	pop dx cx bx ax
ENDM

MACRO LINE
	putc 0Ah
	putc 0Dh
ENDM	

MACRO PRINT_STR string
		local start, print, done, s
		push si ax dx	
		jmp start
		s db string, 0
start:		
		lea si, [s]
print:
		mov dl, [cs:[si]]
		cmp dl, 0
		je done
		mov ah, 02h
		int 21h
		inc si
		jmp print
done:
		pop dx ax si
ENDM
 
MACRO PRINTN string
	print_str string
	line
ENDM


;---------------------------procedures----------------------------------------------------------------------------------
PROC PRINT_UNS ; prints the value in ax reg
    push ax bx cx dx
    
    mov bx, 10
    mov cx, 0
@@l:
    mov dx, 0
    div bx ; result - ax, mod: dx < 10
    add dl, '0' ; printable
    push dx
    inc cx
    cmp ax, 9
    ja @@l
    add ax, '0' ;last digit
    push ax
    inc cx
	mov bx, cx
	jmp @@g
@@checkIfZero:
	dec cx
	cmp dx, '0'
	je @@g
	putc dl
	jmp @@g
@@g:
	pop dx
	cmp cx, bx
	je @@checkIfZero
    putc dl
    loop @@g        
    
    pop dx cx bx ax
    ret        
ENDP PRINT_UNS

PROC PRINTS ; prints the value in ax reg(signed)
	push ax
	jmp @@check
	@@s dw 0
@@check:
	mov [@@s], ax
	shl ax, 1
	jc @@minus
	jmp @@plus
@@minus:
	putc '-'
	mov ax, [@@s]
	neg ax
	call print_uns
	pop ax
	ret
	
@@plus:
	call print_uns
	pop ax
	ret
ENDP PRINTS

PROC SCAN_NUM ; result - cx
	push ax bx dx
    mov bx, 1   
    mov cx, 0
@@sc:
    mov ah, 01h
    int 21h ; al - char
    cmp al, 0Dh ; enter
    je @@done
    cmp al, 08h ; backspace    
    je @@bsp
    mov ah, 0
    sub ax, '0'
    push ax
    inc [count]
    cmp [count], 5
    jbe @@sc
    jmp @@done
    
@@bsp:
    pop ax
    dec [count]
    mov ah, 02h
    mov dl, 20h
    int 21h
    mov dl, 08h
    int 21h
    jmp @@sc
@@done:
    pop ax
    mul bx
    add cx, ax
    mov ax, bx
    mov dx, 10
    mul dx
    mov bx, ax
    dec [count]
    cmp [count], 0
    jne @@done         
@@exit:
    pop dx bx dx
    ret  
ENDP SCAN_NUM

; SCAN_STR      Reads a string from the keyboard (WITH PRINTING), and puts a ZERO at the end of the string
;
; Paramaters:   CX - The memory address to read the string to
;
; Returns:      None (The memory contains the string)
; 
; 
PROC SCAN_STR
        PUSH    AX bx
        MOV     BX,CX
@@next_char:

        ; get char from keyboard
        ; into AL:
        MOV     AH, 00h
        INT     16h

        ; check for ENTER key:
        CMP     AL, 13  ; carriage return?
        JE      @@done_input

        ; check for ENTER key:
        CMP     AL, 8   ; Back space?
        JE      @@handle_backspace
        
        ; print it:
        MOV     AH, 0Eh
        INT     10h

        MOV     [BX],AL
        INC     BX     
        JMP     @@next_char

@@handle_backspace:
        CMP     BX, CX  ; Are we at the beginning of the string?
        JE      @@next_char
        DEC     BX

        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered not digit.
        PUTC    8       ; backspace again.        
        JMP     @@next_char ; wait for next input.       

@@done_input:
		mov al, 0
        MOV [BX], al
        mov dl, 0Ah
		mov ah, 02h
		int 21h
		mov dl, 0Dh
		int 21h

        POP     BX ax
        RET   
ENDP SCAN_STR

PROC graphmode ; moves to 320x200 video mode
	push ax
	mov ax, 13h
	int 10h ; 200x320 graphics mode
	pop ax
	ret
ENDP

PROC txtmode ; moves to text mode
	push ax
	mov ax, 2 ; return to text mode
	int 10h
	pop ax
	ret
ENDP

PROC delay ;delays in ax millisecs.
	push ax bx cx dx
	mov bx, 1000
	mul bx ; result in dx:ax
	mov cx, dx
	mov dx, ax
	mov ah, 86h
	int 15h	
	pop dx cx bx ax
	ret
ENDP

PROC clearBuffer ; clears the keyboard buffer
	pushf
	push ax
	mov al, 0
	mov ah, 0Ch
	int 21h
	pop ax
	popf
	ret
ENDP 

PROC checkKeyPress ; check for keyPress in the buffer. zf: 0- if there is a keyPress, 1- if any key pressed. ah = scan code, al = ascii char
	mov ah, 01h
	int 16h
	jnz @@yes
	ret
@@yes:
	call clearBuffer
	ret
ENDP

PROC waitForKeyPress
	push ax
	mov ah, 0
	int 16h
	pop ax
	ret
ENDP

PROC PRINT_PIXEL; prints a pixel in the specified location and color. cx - x, dx - y, al - color
	push ax bx cx dx
	mov bh, 0
	mov ah, 0Ch
	int 10h
	pop dx cx bx ax
	ret
ENDP

PROC PRINT_LINE ; bx - length, cx - x, dx -  y, al - color
	push ax bx cx dx
@@p:
	call print_pixel
	inc cx
	dec bx
	cmp bx, 0
	jne @@p	
	pop dx cx bx ax
	ret
ENDP

PROC print_rect ; ah - height, cx - x, dx - y, bx - width, al - color
	push ax bx cx dx
@@a:
	call print_line
	inc dx
	dec ah
	cmp ah, 0
	jne @@a
	pop dx cx bx ax
	ret
ENDP

PROC INIT_MOUSE
	;initializes the mouse 
	mov ax, 0
	int 33h
	;shows the mouse
	mov ax, 1
	int 33h
ENDP

PROC GET_MOUSE_POS
	mov ax, 3
	int 33h
ENDP

;COLOR TABLE: 4 upper bits: background color, 4 lower bits: character color.
;	0		Black
;	1		Blue
;	2		Green
;	3		Cyan
;	4		Red
;	5		Magenta
;	6		Brown
;	7		Light Gray
;	8		Dark Gray
;	9		Light Blue
;	A		Light Green		
;	B		Light Cyan
;	C		Light Red
;	D		Light Magenta
;	E		Yellow
;	F		White