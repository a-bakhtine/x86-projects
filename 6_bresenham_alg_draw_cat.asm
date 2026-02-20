.286
.model small
.stack 100h
.data
.code

; void drawPixel(int color, int x, int y)
drawPixel:
	color EQU word ptr ss:[bp+4]
	x1 EQU word ptr ss:[bp+6]
	y1 EQU word ptr ss:[bp+8]
	
	push bp
	mov bp, sp
	
	push bx
	push cx
	push dx
	push es
	
	; set ES to be base address
	mov ax, 0A000h ; have to put 0 in front to be valid hexa value
	mov es, ax
	
	; EX = (y1 * 320) + x1
	mov bx, x1
	mov cx, 320
	mov ax, y1
    xor dx, dx
	mul cx ; ax = ax * cx = y1 * 320
	add bx, ax
	
	mov dx, color
	mov BYTE PTR es:[bx], dl ; bc moving a byte must specify w BYTE
	
	pop es
	pop dx
	pop cx
	pop bx
	pop bp
	
	ret 6 

; void plotLineLow(int x1, int y1, int x2, int y2)
plotLineLow:
    color_low EQU word ptr ss:[bp+4]
    x1_low EQU word ptr ss:[bp+6]
	y1_low EQU word ptr ss:[bp+8]
    x2_low EQU word ptr ss:[bp+10]
    y2_low EQU word ptr ss:[bp+12]

    push bp
    mov bp, sp
    
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; bx = x1, dx = y1
    mov bx, x1_low
    mov dx, y1_low

    ; si = dx = x2 - x1
    mov si, x2_low
    sub si, bx

    ; di = dy = y2 - y1 
    mov di, y2_low
    sub di, dx

    ; yi = cx
    mov cx, 1

    ; if dy < 0 continue below jump
    cmp di, 0
    jge pllCont
    neg di 
    mov cx, -1 

pllCont:
    ; ax = D = 2*dy - dx
    mov ax, di
    shl ax, 1 
    sub ax, si 

pllLoop:
    push ax ; preserve

    ; drawPixel(color, x, y)
    push dx 
    push bx 
    push color_low 
    call drawPixel

    pop ax

    ; if x2 != x1 continue below
    cmp bx, x2_low
    je  pllDone

    ; if D > 0 continue below
    cmp ax, 0
    jle pllElse

    ; y = y + yi
    add dx, cx

    ; D = D + 2*(dy - dx)
    add ax, di
    add ax, di 
    sub ax, si
    sub ax, si 
    jmp pllNextIteration

pllElse:
    ; D = D + 2*dy
    add ax, di
    add ax, di

pllNextIteration:
    inc bx ; x++
    jmp pllLoop

pllDone:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 10

; void plotLineHigh(int color, int x1, int y1, int x2, int y2)
plotLineHigh:
    color_high EQU word ptr ss:[bp+4]
    x1_high    EQU word ptr ss:[bp+6]
    y1_high    EQU word ptr ss:[bp+8]
    x2_high    EQU word ptr ss:[bp+10]
    y2_high    EQU word ptr ss:[bp+12]

    push bp
    mov  bp, sp

    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; bx = x1, dx = y1
    mov bx, x1_high
    mov dx, y1_high

    ; si = dx = x2 - x1 
    mov si, x2_high
    sub si, bx

    ; di = dy = y2 - y1  
    mov di, y2_high
    sub di, dx

    ; xi = cx
    mov cx, 1

    ; if dx < 0 continue below jump
    cmp si, 0
    jge plhCont
    neg si 
    mov cx, -1

plhCont:
    ; ax = D = 2*dx - dy
    mov ax, si
    shl ax, 1 
    sub ax, di

plhLoop:
    push ax ; preserve

    ; drawPixel(color, x, y)
    push dx 
    push bx
    push color_high 
    call drawPixel

    pop ax

    ; if y1 != y2 continue below
    cmp dx, y2_high
    je  plhDone

    ; if D > 0 continue below
    cmp ax, 0
    jle plhElse

    ; x = x + xi
    add bx, cx

    ; D = D + 2*(dx - dy)
    add ax, si
    add ax, si 
    sub ax, di
    sub ax, di 
    jmp plhNextIteration

plhElse:
    ; D = D + 2*dx
    add ax, si
    add ax, si

plhNextIteration:
    inc dx ; y++
    jmp plhLoop

plhDone:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 10

; void drawLine(int color, int x1, int y1, int x2, int y2)
drawLine:
    color_l EQU word ptr ss:[bp+4]
	x1_l EQU word ptr ss:[bp+6]
	y1_l EQU word ptr ss:[bp+8]
    x2_l EQU word ptr ss:[bp+10]
    y2_l EQU word ptr ss:[bp+12]

    push bp
    mov bp, sp

    push ax
    push bx
    push cx
    push dx
    push si
    push di
    
    ; dx = x2 - x1 
    mov si, x2_l
    sub si, x1_l

    ; dy = y2 - y1
    mov di, y2_l
    sub di, y1_l

    ; bx = abs(dx)
    mov bx, si
    cmp bx, 0
    jge absDX
    neg bx

absDX:
    ; cx = abs(dy)
    mov cx, di
    cmp cx, 0
    jge absDY
    neg cx

absDY:
    ; if abs(dy) < abs(dx)
    cmp cx, bx
    jl pllBranch

    ; make sure y1 <= y2 for loop in plotlinehigh
    mov ax, y1_l
    cmp ax, y2_l
    jg  plhSwap

plhNoSwap:
    ; plotLineHigh(color, x1, y1, x2, y2)
    push y2_l
    push x2_l
    push y1_l
    push x1_l
    push color_l
    call plotLineHigh
    jmp dlDone

plhSwap:
    ; plotLineHigh(color, x2, y2, x1, y1)
    push y1_l
    push x1_l
    push y2_l
    push x2_l
    push color_l
    call plotLineHigh
    jmp dlDone

pllBranch:
    ; make sure x1 <= x2 for loop in plotlinelow
    mov ax, x1_l
    cmp ax, x2_l
    jg  pllSwap

pllNoSwap:
    ; plotLineLow(color, x1, y1, x2, y2)
    push y2_l
    push x2_l
    push y1_l
    push x1_l
    push color_l
    call plotLineLow
    jmp dlDone

pllSwap:
    ; plotLineLow(color, x2, y2, x1, y1)
    push y1_l
    push x1_l
    push y2_l
    push x2_l
    push color_l
    call plotLineLow
    jmp dlDone

dlDone:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 10
   

start:
    mov ax, @data
    mov ds, ax

    mov ax, 0013h
    int 10h

    ; CAT DRAWING 
    ; head 
    ; top of head
    push WORD PTR 80
    push WORD PTR 180
    push WORD PTR 80
    push WORD PTR 140
    push 0003h
    call drawLine
    ; bottom of head
    push WORD PTR 120
    push WORD PTR 180
    push WORD PTR 120
    push WORD PTR 140
    push 0003h
    call drawLine
    ; left of head
    push WORD PTR 120
    push WORD PTR 140
    push WORD PTR 80
    push WORD PTR 140
    push 0003h
    call drawLine
    ; right of head
    push WORD PTR 120
    push WORD PTR 180
    push WORD PTR 80
    push WORD PTR 180
    push 0003h
    call drawLine

    ; left ear 
    push WORD PTR 80
    push WORD PTR 145
    push WORD PTR 50
    push WORD PTR 150
    push 0003h
    call drawLine

    push WORD PTR 80
    push WORD PTR 155
    push WORD PTR 50
    push WORD PTR 150
    push 0003h
    call drawLine

    ; right ear 
    push WORD PTR 80
    push WORD PTR 165
    push WORD PTR 50
    push WORD PTR 170
    push 0003h
    call drawLine

    push WORD PTR 80
    push WORD PTR 175
    push WORD PTR 50
    push WORD PTR 170
    push 0003h
    call drawLine

    ; eyes
    ; left eye
    push WORD PTR 95
    push WORD PTR 154
    push WORD PTR 95
    push WORD PTR 150
    push 000Ah
    call drawLine

    push WORD PTR 96
    push WORD PTR 154
    push WORD PTR 96
    push WORD PTR 150
    push 000Ah
    call drawLine

    push WORD PTR 97
    push WORD PTR 154
    push WORD PTR 97
    push WORD PTR 150
    push 000Ah
    call drawLine

    ; left pupil
    push WORD PTR 96
    push WORD PTR 152
    push WORD PTR 96
    push WORD PTR 153
    push 0000h
    call drawLine

    ; right eye
    push WORD PTR 95
    push WORD PTR 170
    push WORD PTR 95
    push WORD PTR 166
    push 000Ah
    call drawLine

    push WORD PTR 96
    push WORD PTR 170
    push WORD PTR 96
    push WORD PTR 166
    push 000Ah
    call drawLine

    push WORD PTR 97
    push WORD PTR 170
    push WORD PTR 97
    push WORD PTR 166
    push 000Ah
    call drawLine

    ; right pupil
    push WORD PTR 96
    push WORD PTR 168
    push WORD PTR 96
    push WORD PTR 169
    push 0000h
    call drawLine

    ; nose (2 diagonals and 1 line horizontally)
    push WORD PTR 104
    push WORD PTR 160
    push WORD PTR 100
    push WORD PTR 158
    push 000Dh
    call drawLine

    push WORD PTR 104
    push WORD PTR 160
    push WORD PTR 100
    push WORD PTR 162
    push 000Dh
    call drawLine 

    push WORD PTR 100
    push WORD PTR 162
    push WORD PTR 100
    push WORD PTR 158
    push 000Dh
    call drawLine

    ; mouth (2 diagonals and 1 line vertically)
    push WORD PTR 112
    push WORD PTR 160
    push WORD PTR 108
    push WORD PTR 150
    push 000Fh
    call drawLine
    push WORD PTR 112
    push WORD PTR 160
    push WORD PTR 108
    push WORD PTR 170
    push 000Fh
    call drawLine

    push WORD PTR 106
    push WORD PTR 160
    push WORD PTR 112
    push WORD PTR 160
    push 000Fh
    call drawLine

    ; whiskers (3 each side)
    ; left whiskers
    push WORD PTR 108
    push WORD PTR 140
    push WORD PTR 108
    push WORD PTR 125
    push 000Fh
    call drawLine
    push WORD PTR 112
    push WORD PTR 140
    push WORD PTR 112
    push WORD PTR 125
    push 000Fh
    call drawLine
    push WORD PTR 116
    push WORD PTR 140
    push WORD PTR 116
    push WORD PTR 125
    push 000Fh
    call drawLine

    ; right whiskers
    push WORD PTR 108
    push WORD PTR 195
    push WORD PTR 108
    push WORD PTR 180
    push 000Fh
    call drawLine
    push WORD PTR 112
    push WORD PTR 195
    push WORD PTR 112
    push WORD PTR 180
    push 000Fh
    call drawLine
    push WORD PTR 116
    push WORD PTR 195
    push WORD PTR 116
    push WORD PTR 180
    push 000Fh
    call drawLine

    mov ah, 0
    int 16h

    mov ax, 0003h
    int 10h

    mov ax, 4C00h
    int 21h

END start