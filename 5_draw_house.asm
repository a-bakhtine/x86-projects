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
	mul cx ; ax = ax * cx = y1 * 320
	add bx, ax
	
	mov dx, color
	mov BYTE PTR es:[bx], dl ; bc moving a byte must specify w BYTE
	
	pop es
	pop dx
	pop cx
	pop bx
	pop bp
	
	ret 6 ; bc 6 bytes returned as args (earlier in start)

; void drawLine_h(int color, int x1, int y, int x2)
drawLine_h:
    color_h EQU word ptr ss:[bp+4]
	x1_h EQU word ptr ss:[bp+6]
	y_h EQU word ptr ss:[bp+8]
	x2_h EQU word ptr ss:[bp+10]
	
	push bp
	mov bp, sp
	
	push cx ; use cx because typical loop reg
	mov cx, x1_h

loop_h:
    ; check if drawing complete
	cmp cx, x2_h
	jg end_h
	
    ; load arg for drawpixel
	push y_h 
	push cx
	push color_h
	call drawPixel
	
	inc cx
	jmp loop_h
	
end_h:
	pop cx
	pop bp
	ret 8 


; void drawLine_v(int color, int x, int y1, int y2)
drawLine_v:
	color_v EQU word ptr ss:[bp+4]
	x_v EQU word ptr ss:[bp+6]
	y1_v EQU word ptr ss:[bp+8]
	y2_v EQU word ptr ss:[bp+10]
	
	push bp        
	mov bp, sp

	push cx

	; init w/ starting y coordinate
	mov cx, y1_v 
	
loop_v:
	; check if drawing completed  
	cmp cx, y2_v 
	jg end_v
	
    ; push arg for draw pixel
	push cx 
	push x_v 
	push color_v 
	call drawPixel 
	
	; Move to next y coordinate
	inc cx 
	jmp loop_v
	
end_v:
	pop cx
	pop bp
	ret 8 

; void drawLine_d1(int color, int x1, int y, int x2)
drawLine_d1:
	color_d1 EQU word ptr ss:[bp+4]
	x1_d1 EQU word ptr ss:[bp+6]
	y_d1 EQU word ptr ss:[bp+8] 
	x2_d1 EQU word ptr ss:[bp+10]
	
	push bp
	mov bp, sp 
	
	push cx    
	push dx    
	
    ; init loop var (cx = x1, dx = y)
	mov cx, x1_d1 
	mov dx, y_d1
	
loop_d1:
    ; check if all drawn
	cmp cx, x2_d1
	jg end_d1
	
    ; draw pixel
	push dx
	push cx
	push color_d1
	call drawPixel
	
    ; slope of 1
	inc cx
	inc dx
	jmp loop_d1
	
end_d1:
	pop dx
	pop cx
	pop bp
	ret 8 

; void drawLine_d2(int color, int x1, int y, int x2)
drawLine_d2: 
	color_d2 EQU word ptr ss:[bp+4]
	x1_d2 EQU word ptr ss:[bp+6]
	y_d2 EQU word ptr ss:[bp+8]
	x2_d2 EQU word ptr ss:[bp+10]
	
	push bp
	mov bp, sp 
	
	push cx 
	push dx 
	
    ; init loop var (cx = x1, dx = y)
	mov cx, x1_d2
	mov dx, y_d2 
	
loop_d2:
    ; check if all drawn
	cmp cx, x2_d2
	jg end_d2
	
    ; draw pixel
	push dx
	push cx
	push color_d2
	call drawPixel
	
	; slope of -1
	inc cx 
	dec dx
	jmp loop_d2 
	
end_d2:
	pop dx 
	pop cx 
	pop bp 
	ret 8  


start:
	mov ax, @data
	mov ds, ax
	
	; enter video mode
	mov ax, 0013h 
	int 10h
	
    ; draw the house - square base and triangle roof

    ; square base
	; bottom horizontal line
	push 240 ; x2       
	push 150 ; y
	push 80 ; x1
	push 0Ch ; red
	call drawLine_h
	
	; top horizontal line
	push 240 ; x2
	push 90  ; y
	push 80 ; x1
	push 03h ; cyan
	call drawLine_h
	
	; left vertical line
	push 150 ; y2
	push 90  ; y1
	push 80 ; x
	push 01h ; dark blue
	call drawLine_v
	
	; right vertical line
	push 150 ; y2
	push 90  ; y1
	push 240 ; x
	push 0Ah ; lime
	call drawLine_v
	
	; triangle closing roof part

	; left roof part (-1 slope up)
	push 160 ; x2 
	push 90 ; y
	push 80 ; x1
	push 0Dh ; orange
	call drawLine_d2
	
	; right roof part (+1 slope down)
	push 240 ; x2 
	push 10  ; y 
	push 160 ; x1
	push 2Ah ; pink
	call drawLine_d1


	; wait for key press
	mov ah, 0
	int 16h
	
	mov ax, 0003h
	int 10h
	
	; exit
	mov ax, 4c00h
    int 21h
END start