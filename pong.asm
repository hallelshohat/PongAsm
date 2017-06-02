IDEAL
model small
stack 100h
jumps
dataseg
	bufferSize equ 100
	
	sM dw 2 ;step size 
	mils dw 10
	wid dw 10
	height db 50 
	
	maxScore db ?
	
	colorMatka db 0Ah
	colorBall db 01h
	
	lx dw 20
	ly dw 50
	ldy dw 0
	
	rx dw 300
	ry dw 50
	rdy dw 0
	
	ballX dw ?
	ballY dw ?
	balldX dw ?
	balldY dw ?
	ballW dw 7
	ballH db 7
	
	gameOver db 0 ; BOOLEAN
	won db 0 ; BOOLEAN
	
	rScore db 0
	lScore db 0
	isWait db 0 ; BOOLEAN
	reset db 0
	
	song 	dw 2 dup(2712, 3044, 2712, 3620, 4561, 3620, 5424, 50), 2712, 2416, 2280, 2416, 2280, 2712, 2416, 2712, 2416, 3044, 2712, 3044, 3620, 3044, 2712, 50 ;first verse
			dw 2 dup(2712, 3044, 2712, 3620, 4561, 3620, 5424, 50), 2712, 2416, 2280, 2416, 2280, 2712, 2416, 2712, 2416, 3044, 2712, 3044, 2712, 2416, 2280, 50 ;second verse
			dw 2 dup(1810, 2032, 1810, 2280, 3044, 2280, 3620, 50), 1810, 1612, 1522, 1612, 1522, 1810, 1612, 1810, 1612, 2032, 1810, 2032, 2416, 2032, 1810, 50 ;first verse - high
			dw 2 dup(1810, 2032, 1810, 2280, 3044, 2280, 3620, 50), 1810, 1612, 1522, 1612, 1522, 1810, 1612, 1810, 1612, 2032, 1810, 2032, 2416, 3044, 3620, 50 ;second verse - high
			dw 0
	songP db 0
	pointSong dw 2712, 2152, 1810, 1356, 50, 1810, 1356, 50, 50, 50, 50, 1356, 1810, 2152, 2712, 50, 2152, 2712, 50, 50, 50, 50, 0
	pointSongP db 0
	ticksNotes dw 0
	
	fileName db "last", 0
	buffer db bufferSize dup(0FFh)
	fileHandle dw 0
	fileS dw 0
codeseg
include "res.asm"
start:
	mov ax, @data
	mov ds, ax
	call close_speaker
	mov [reset], 0 ; the game is not reseted
	call cls 
	call showStart ; shows the start menu
	call graphmode 
	call init ; initializes the game 
mainLoop:
	call printMatkot ; prints the paddles
	call print_score ; prints the score 
	call updateM ; updates the paddles 
	inc [ticksNotes] ; for checking the note 
	cmp [reset], 1 ; is the game needs to be restarted?
	je start 
	mov ax, [mils] ; milisecs
	call delay ; delays the game 
	cmp [gameOver], 0 ; is the game over? 
	jne exit
	cmp [isWait], 0 ; is the game NOT paused
	je ballUpd
	jne printWait
	jmp mainLoop
ballUpd:
	call playSong ; plays the popcorn song
	call printBall ; prints the ball 
	call updateB ; updates the ball
	jmp mainLoop 
printWait:
	call playPoint ; plays the point song
	cmp [won], 0 ; is someone NOT won?
	jne mainLoop
	gotoXY 5, 8 ; 40x25
	print_str "press enter to continue..."
	jmp mainLoop
exit:
	call close_speaker ; last note on popcorn song
	call txtmode
	printn "bye!"
	mov ah, 4Ch
	int 21h
; shows the start dialog
PROC showStart
	gotoXY 0, 0
	printn " ___  _  _  _  __ "
	printn "| o \/ \| \| |/ _|"
	printn "|  _( o ) \\ ( |_n"
	printn "|_|  \_/|_|\_|\__/"
	line
	printn "---------------------------------------"
	printn "         WELCOME TO PONG GAME          "
	printn "---------------------------------------"
	line
	printn "  _  _   ___ _  _  ___  _  _   _ _____ "
	printn " | || | / __| || |/ _ \| || | /_\_   _|"
	printn " | __ |_\__ \ __ | (_) | __ |/ _ \| |  "
	printn " |_||_(_)___/_||_|\___/|_||_/_/ \_\_|  "
	line
	printn "TO PLAY, PRESS SPACE"
	printn "TO SEE LAST GAMES, PRESS ENTER"
@@wait:
	call waitForKeyPress 
	cmp ah, 39h ; space
	je @@play
	cmp ah, 1Ch ; enter
	je @@scores
	jmp @@wait
@@scores:
	call showScores ;shows the last scores from the file
@@play:	
	line
	printn "ENTER THE SCORE TO WIN:"
	call scan_num ; scans the max score 
	line 
	mov [maxScore], cl
	ret
ENDP	
;	restarting the game vars 
PROC restart
	mov [reset], 1
	mov [gameOver], 0
	mov [won], 0
	mov [isWait], 0
	mov [rScore], 0
	mov [lScore], 0
	mov [songP], 0
	mov [pointSongP], 0
	call txtmode
	ret
ENDP
;	reads the scores from the file
PROC showScores
	call graphmode
	gotoXY 0, 14
	printn "LAST SCORES:"
	call readF ; reads the data from the file
	lea si, [buffer]
	mov [fileS], si 
	add si, bufferSize ; si is in the end of the file 
@@sub:
	dec si 
	cmp si, [fileS] ; is si in the start of the file?  
	je @@cont
	mov al, [si] 
	cmp al, 0FFh ; is si NOT in the start of the scores
	je @@sub
	mov cx, 5 ; reads 5 scores
@@read:
	mov al, [si]
	mov bl, 6 ; line #6 is the end of the scores
	sub bl, cl
	shl bl, 1 ; one line space between the scores 
	gotoXY bl, 17
	add al, 30h ; ascii adjust
	print_color al, 02h 
	dec si 
	putc " "
	putc ":"
	putc " "
	mov al, [si]
	add al, 30h ; ascii adjust
	print_color al, 04h
	dec si
	cmp si, [FileS] ; is si in the start of the file?
	jb @@cont
	loop @@read
@@cont:	
	gotoXY 10, 5
	print_str "press any key to continue..."
	call waitForKeyPress
	call txtmode
	ret
ENDP
;	opens the file
PROC openF
	push dx ax
@@open:	
	lea dx, [fileName]
	call openFile
	jc @@create
	mov [fileHandle], ax
	pop ax dx ; bypass_pop_match
	ret
@@create:
	call createF
	jmp @@open
ENDP
; creates the file
PROC createF
	push ax bx cx dx 
	lea dx, [fileName]
	call createFile
	call openFile
	mov [fileHandle], ax
	mov bx, [fileHandle]
	mov cx, bufferSize
	lea dx, [buffer]
	call writeFile
	pop dx cx bx ax 
	ret
ENDP 
;	closes the file
PROC closeF
	push bx ax
	mov bx, [fileHandle]
	call closeFile
	pop ax bx ; bypass_pop_match
	ret
ENDP
;	reads from the file
PROC readF
	push ax bx cx dx
	call openF
	lea dx, [buffer]
	mov bx, [fileHandle]
	mov cx, bufferSize
	call readFile
	call closeF
	pop dx cx bx ax ; bypass_pop_match
	ret
ENDP
;	writes the points to the file
PROC writePoints
	call openF
	lea si, [buffer]
@@check:
	mov al, [si]
	cmp al, 0FFh ; EOF 
	je @@add
	inc si
	jmp @@check
@@add:	
	mov al, [rscore]
	mov [si], al
	inc si
	mov al, [lScore]
	mov [si], al
	lea dx, [buffer]
	mov bx, [fileHandle]
	mov cx, bufferSize
	call writeFile
	call closeF
	ret
ENDP

; initializes the ball position and direction
PROC init
	push ax bx
	mov [ballX], 153
	mov [ballY], 93
	mov bx, 10
	call rand
	cmp ax, 5
	jb @@xzero
	mov [balldX], 1
	jmp @@y
@@xzero:
	mov [balldX], -1
@@y:
	call rand
	cmp ax, 5
	jb @@yzero
	mov [balldY], 1
	jmp @@exit
@@yzero:
	mov [balldY], -1
@@exit:
	pop bx ax ; bypass_pop_match
	ret
ENDP 
; prints the scores for each player
PROC print_score
	push ax
	gotoXY 0, 15
	print_str "to win: "
	mov ah, 0
	mov al, [maxScore]
	call print_uns
	gotoXY 1, 17
	mov al, [lScore]
	mov ah, 0
	call print_uns
	gotoXY 1, 19
	putc ':'
	gotoXY 1, 21
	mov al, [rScore]
	call print_uns
	pop ax ; bypass_pop_match
	ret
ENDP
; prints the rackets
PROC printMatkot 
	push ax bx cx dx
	call printBlack	
	mov cx, [lx] ;x
	mov dx, [ly] ;y
	mov bx, [wid] ;width
	mov al, [colorMatka] ;color
	mov ah, [height] ;height
	call print_rect
	
	mov cx, [rx] ;x
	mov dx, [ry] ;y
	mov bx, [wid] ;width
	mov al, [colorMatka] ;color
	mov ah, [height] ;height
	call print_rect
	pop dx cx bx ax ; bypass_pop_match
	ret
ENDP
; updates the y values
PROC updateM 
	push ax
	call checkKeyPress ; al-scan code
	;PRESSED
	cmp al, 72 ; up key
	je @@up
	cmp al, 80 ; down key
	je @@down
	cmp al, 17 ; w key
	je @@w
	cmp al, 31 ; s key
	je @@s
	;RELEASED
	cmp al, 200 ; up key
	je @@nru
	cmp al, 208 ; down key
	je @@nrd
	cmp al, 145 ; w key
	je @@nlu
	cmp al, 159 ; d key
	je @@nld
	cmp al, 1 ; esc key
	je @@stop
	cmp al, 13h ;r key - restart after won
	je @@restart
	cmp al, 1Ch ; enter key
	je @@dwait
	jmp @@add
@@up:
	mov ax, [sM]
	neg ax
	mov [rdy], ax 
	jmp @@add
@@down:
	mov ax, [sM]
	mov [rdy], ax
	jmp @@add
@@w:
	mov ax, [sM]
	neg ax
	mov [ldy], ax 
	jmp @@add
@@s:
	mov ax, [sM]
	mov [ldy], ax
	jmp @@add
@@nru:
	cmp [rdy], 0
	jg @@add
	mov [rdy], 0
	jmp @@add
@@nlu:	
	cmp [ldy], 0
	jg @@add
	mov [ldy], 0
	jmp @@add
@@nrd:
	cmp [rdy], 0
	jl @@add
	mov [rdy], 0
	jmp @@add
@@nld:	
	cmp [ldy], 0
	jl @@add
	mov [ldy], 0
	jmp @@add	
@@stop:
	pop ax ; bypass_pop_match
	mov [gameOver], 1
	ret
@@restart:
	cmp [won], 0
	je @@add
	call restart
	pop ax ; ignore_line
	ret ; ignore_line
@@add:
	call ad
	pop ax ; ignore_line
	ret	; ignore_line
@@dWait:
	cmp [won], 0
	jne @@add
	mov [isWait], 0
	call eraseMsg
	jmp @@add
ENDP
; erases the wait message
PROC eraseMsg
	gotoXY 5, 0
	mov cx, 40
@@l:
	PUTC ' '
	loop @@l
	gotoXY 3, 0
	mov cx, 40
@@r:
	PUTC ' '
	loop @@r
	ret
ENDP
; adds the values of the rackets dx, dy
PROC ad
	push ax
@@chkl:
	mov ax, [ly]
	add ax, [ldy]
	cmp ax, 0
	jle @@zl 
	add al, [height]
	cmp ax, 200
	jae @@zl
	jmp @@chkr
@@zl:
	mov [ldy], 0
	jmp @@chkr
@@chkr:
	mov ax, [ry]
	add ax, [rdy]
	cmp ax, 0
	jle @@zr 
	add al, [height]
	cmp ax, 200
	jae @@zr
	jmp @@add
@@zr:
	mov [rdy], 0
	jmp @@add
@@add:
	mov ax, [ly]
	add ax, [ldy]
	mov [ly], ax
	
	mov ax, [ry]
	add ax, [rdy]
	mov [ry], ax
	pop ax ; bypass_pop_match
	ret
ENDP 
; prints a black area under and above the rackets
PROC printBlack
	push ax bx cx dx
	mov cx, [lx] ; x
	mov dx, 0 ; y
	mov bx, [wid] ;width
	mov ax, [ly] ; height
	mov ah, al
	mov al, 0 ;color
	call print_rect ; prints the top of the left paddle
	
	mov cx, [lx] ;x
	mov dx, [ly] ;y
	add dl, [height] 
	mov ah, 200 ;height
	mov bx, [ly]
	add bl, [height]
	sub ah, bl 
	mov al, 0
	mov bx, [wid]
	call print_rect ; prints the bottom of the left paddle

	mov cx, [rx] ; x
	mov dx, 0 ; y
	mov bx, [wid] ;width
	mov ax, [ry] ; height
	mov ah, al
	mov al, 0 ;color
	call print_rect ; prints the top of the right paddle
	
	mov cx, [rx] ;x
	mov dx, [ry] ;y
	add dl, [height] 
	mov ah, 200 ;height
	mov bx, [ry]
	add bl, [height]
	sub ah, bl 
	mov al, 0
	mov bx, [wid]
	call print_rect ; prints the bottom of the right paddle
	pop dx cx bx ax ; bypass_pop_match
	ret
ENDP
; prints the ball
PROC printBall
	push ax bx cx dx
	mov cx, [ballX]
	mov dx, [ballY]
	mov bx, [ballW]
	mov al, [colorBall]
	mov ah, [ballH]
	call print_rect
	call ball_black
	pop dx cx bx ax ; bypass_pop_match
	ret
ENDP
; updates the ball x and y values
PROC updateB
	push ax
	call checkCollision
	mov ax, [balldX]
	add [ballX], ax
	mov ax, [balldY]
	add [ballY], ax
	pop ax ; bypass_pop_match
	ret
ENDP
; prints a black area in the previous location of the ball
PROC ball_black
	push ax bx cx dx
	mov bx, [balldX]
	cmp bx, 0
	je @@checkY
	jl @@Xminus
	jmp @@Xplus

@@Xminus:
	mov cx, [ballX]
	add cx, [ballW] ; x
	neg bx ; width
	shl bx, 1 ; for preventing next step
	mov dx, [ballY] ; y
	dec dx 
	mov ah, [ballH] ; height
	add ah, 3
	mov al, 0 ;color
	call print_rect
	jmp @@checkY
@@Xplus:
	mov cx, [ballX]
	sub cx, [balldX] ; x
	shl bx, 1
	mov dx, [ballY] ; y
	dec dx
	mov ah, [ballH] ; height
	add ah, 2
	mov al, 0 ;color
	call print_rect
	jmp @@checkY
@@checkY:
	mov ax, [balldY]
	cmp ax, 0
	je @@exit
	jl @@yMinus
	jmp @@yPlus
@@yMinus:
	mov cx, [ballX]
	dec cx
	mov dx, [ballY]
	add dl, [ballH]
	mov bx, [ballW]
	add bx, 2
	neg ax
	mov ah, al ;height
	shl ah, 1
	mov al, 0
	call print_rect
	jmp @@exit
@@yPlus:
	mov cx, [ballX]
	dec cx
	mov dx, [ballY]
	sub dx, [balldY]
	mov bx, [ballW]
	add bx, 2
	mov ah, al
	shl ah, 1
	mov al, 0
	call print_rect
	jmp @@exit
@@exit:
	pop ax bx cx dx ; bypass_pop_match
	ret
ENDP
; checks if the ball touches the screen borders
PROC checkCollision
	push ax
	; screen collision
	mov ax, [ballX]
	cmp ax, 0 
	je @@lrScreen
	add ax, [ballW]
	cmp ax, 320
	je @@lrScreen
	
	mov ax, [ballY]
	cmp ax, 0
	je @@tbScreen
	add al, [ballH]
	cmp ax, 200
	je @@tbScreen
	jmp @@exit
@@lrScreen:
	neg [balldX]
	call ball_black
	jmp @@exit
@@tbScreen:
	neg [balldY]
	call ball_black
	jmp @@exit		
@@exit:
	pop ax ; bypass_pop_match
	call checkColiisionM
	ret
ENDP
; checks if the ball touches the rackets
PROC checkColiisionM
	push ax bx
	; left matka
	mov ax, [ballY]
	mov bl, [ballH]
	add al, bl
	cmp ax, [ly]
	ja @@aboveL
	jmp @@checkR
@@aboveL:
	mov bx, [ly]
	add bl, [height]
	cmp ax, bx
	jb @@belowL
	jmp @@checkR
@@belowL:
	mov ax, [lx]
	add ax, [wid]
	cmp ax, [ballX]
	je @@yes
@@checkR:
	;right matka
	mov ax, [ballY]
	mov bl, [ballH]
	add al, bl
	cmp ax, [ry]
	ja @@aboveR
	jmp @@checkScore
@@aboveR:
	mov bx, [ry]
	add bl, [height]
	cmp ax, bx
	jb @@belowR
	jmp @@checkScore
@@belowR:	
	mov ax, [ballX]
	add ax, [ballW]
	cmp ax, [rx]
	je @@yes
	jmp @@checkScore
@@yes:
	neg [balldX]
	call ball_black
	jmp @@exit
@@checkScore:
	mov ax, [lx]
	add ax, [wid]
	cmp [ballX], ax
	je @@rightScore
	mov ax, [ballX]
	add ax, [ballW]
	cmp ax, [rx]
	je @@leftScore; jumps to leftScore
	jmp @@exit
@@score:
	mov [isWait], 1
	call eraseBall
	call init
	call close_speaker
	jmp @@exit	
@@rightScore:
	inc [rScore]
	mov al, [maxScore]
	cmp [rScore], al
	je @@rwon
	gotoXY 3, 12
	print_str "right scored!!"
	jmp @@score
@@rwon:
	call graphmode
	call print_score
	gotoXY 3, 14
	print_str "right won!!"
	jmp @@won
@@leftScore:
	inc [lScore]
	mov al, [maxScore]
	cmp [lScore], al
	je @@lwon
	gotoXY 3, 14
	print_str "left scored!!"
	jmp @@score		
@@lwon:
	call graphmode
	call print_score
	gotoXY 3, 14
	print_str "left won!!"
	jmp @@won
@@won:
	mov [isWait], 1
	mov [won], 1
	call eraseBall
	gotoXY 5, 14
	print_str "RESTART - R"
	gotoXY 7, 14
	print_str "EXIT - ESC"
	call writePoints
	jmp @@exit
@@exit:
	pop bx ax ; bypass_pop_match
	ret
ENDP

; erases the ball after a score
PROC eraseBall
	push ax bx cx dx
	mov ah, [ballH]
	add ah, 2
	mov cx, [ballX]
	dec cx
	mov dx, [ballY]
	dec dx
	mov bx, [ballW]
	add bx, 2
	mov al, 0 ; color
	call print_rect
	pop dx cx bx ax ; bypass_pop_match
	ret
ENDP

PROC playSong
	push ax bx dx si
	mov ax, [ticksNotes]
	mov dx, 0
	mov bx, 12
	div bx
	cmp dx, 0 ; modulo
	je @@yesNote
	jmp @@exit
@@updateSong:
	mov [songP], 0
	jmp @@yesNote
@@yesNote:
	lea si, [song]
	mov al, [songP]
	shl al, 1 ;words
	mov ah, 0
	add si, ax
	mov ax, [si]
	cmp ax, 0
	je @@updateSong
	call close_speaker
	call open_speaker
	call send_note
	inc [songP]
@@exit:
	pop si dx bx ax ; bypass_pop_match
	ret
ENDP

PROC playPoint
	push ax bx dx si
	mov ax, [ticksNotes]
	mov dx, 0
	mov bx, 8
	div bx
	cmp dx, 0 ;modulo
	je @@yesNote
	jmp @@exit
@@updateSong:
	mov [pointSongP], 0
@@yesNote:
	lea si, [pointSong]
	mov al, [pointSongP]
	shl al, 1 ; the array is words
	mov ah, 0
	add si, ax
	mov ax, [si]
	cmp ax, 0
	je @@updateSong
	call close_speaker
	call open_speaker
	call send_note
	inc [pointSongP]
@@exit:
	pop si dx bx ax ; bypass_pop_match
	ret
ENDP
END start
