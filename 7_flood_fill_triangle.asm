.286
.model small
.stack 8000h
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
    je pllDone

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
    x1_high EQU word ptr ss:[bp+6]
    y1_high EQU word ptr ss:[bp+8]
    x2_high EQU word ptr ss:[bp+10]
    y2_high EQU word ptr ss:[bp+12]

    push bp
    mov bp, sp

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
    jb pllBranch

    ; make sure y1 <= y2 for loop in plotlinehigh
    mov ax, y1_l
    cmp ax, y2_l
    jg plhSwap

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
    jg pllSwap

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


; void drawTriangle(int color, int x1, int y1, int x2, int y2, int x3, int y3)
drawTriangle:
    color_dt EQU word ptr ss:[bp+4]
    x1_dt EQU word ptr ss:[bp+6]
    y1_dt EQU word ptr ss:[bp+8]
    x2_dt EQU word ptr ss:[bp+10]
    y2_dt EQU word ptr ss:[bp+12]
    x3_dt EQU word ptr ss:[bp+14]
    y3_dt EQU word ptr ss:[bp+16]

    push bp
    mov bp, sp

    ; drawLine(int color, int x1, int y1, int x2, int y2)
    ; below to draw triangle
    push y2_dt
    push x2_dt
    push y1_dt
    push x1_dt
    push color_dt
    call drawLine

    push y3_dt
    push x3_dt
    push y2_dt
    push x2_dt
    push color_dt
    call drawLine

    push y1_dt
    push x1_dt
    push y3_dt
    push x3_dt
    push color_dt
    call drawLine
    
    pop bp

    ret 14


; readPixel(int x, int y), returns color in AL
readPixel:
    x_rp EQU word ptr ss:[bp+4]
    y_rp EQU word ptr ss:[bp+6]

    push bp
    mov bp, sp

    push bx
    push cx
    push dx
    push es

    mov ax, 0A000h
    mov es, ax

    ; offset = y*320 + x
    mov bx, x_rp
    mov cx, 320
    mov ax, y_rp
    xor dx, dx
    mul cx
    add bx, ax

    mov al, BYTE ptr es:[bx]

    pop es
    pop dx
    pop cx
    pop bx
    pop bp
    ret 4


; void fill(int x1, int y1, int fillColor, int edgeColor), flood fill algo
fill:
    x1_f EQU word ptr ss:[bp+4]
    y1_f EQU word ptr ss:[bp+6]
    fillColor_f EQU word ptr ss:[bp+8]
    edgeColor_f EQU word ptr ss:[bp+10]

    push bp
    mov bp, sp

    push ax
    push bx

    ; 1. if (x,y) not valid coord, return
    mov ax, x1_f
    cmp ax, 0
    jl fill_done
    cmp ax, 319
    jg fill_done

    mov ax, y1_f
    cmp ax, 0
    jl fill_done
    cmp ax, 199
    jg fill_done

    ; 2. if color = edgeColor/fillColor, return
    push y1_f
    push x1_f
    call readPixel ; AL = curr color

    mov bl, BYTE ptr edgeColor_f
    cmp al, bl
    je fill_done

    mov bl, BYTE ptr fillColor_f
    cmp al, bl
    je fill_done

    ; 3. set pixel to fillColor
    push y1_f
    push x1_f
    push fillColor_f
    call drawPixel

    ; 4. recursion in 4 directions
    ; fill(x-1, y, fillColor, edgeColor)
    mov ax, x1_f
    dec ax
    push edgeColor_f
    push fillColor_f
    push y1_f
    push ax
    call fill

    ; fill(x+1, y, fillColor, edgeColor)
    mov ax, x1_f
    inc ax
    push edgeColor_f
    push fillColor_f
    push y1_f
    push ax
    call fill

    ; fill(x, y-1, fillColor, edgeColor)
    mov ax, y1_f
    dec ax
    push edgeColor_f
    push fillColor_f
    push ax
    push x1_f
    call fill

    ; fill(x, y+1, fillColor, edgeColor)
    mov ax, y1_f
    inc ax
    push edgeColor_f
    push fillColor_f
    push ax
    push x1_f
    call fill

fill_done:
    pop bx
    pop ax
    pop bp
    ret 8


start:
    mov ax, @data
    mov ds, ax

    mov ax, 0013h
    int 10h

    ; drawTriangle(edgeColor, x1,y1, x2,y2, x3,y3)
    push 15
    push 90
    push 60
    push 130
    push 70 
    push 40 
    push 0004h
    call drawTriangle

    ; fill(x, y, fillColor, edgeColor)
    push 0004h
    push 000Ch 
    push 50
    push 90
    call fill

    mov ah, 0
    int 16h

    mov ax, 0003h
    int 10h

    mov ax, 4C00h
    int 21h

END start