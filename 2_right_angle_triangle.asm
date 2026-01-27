; Please input triangle size: 3
; Please input triangle symbol: o
;   o
;  oo
; ooo
; void triangle(char symbol, int size)
.286
.model small
.stack 100h
.data
    sSize db "Please input triangle size: $"
    sSymbol db "Please input triangle symbol: $"
.code
newline:
    push ax
    push dx
    mov ah, 2
    mov dl, 13 ; carriage return
    int 21h
    mov ah, 2
    mov dl, 10
    int 21h
    pop dx
    pop ax
    ret 

space:
    push ax
    push dx
    mov ah, 2
    mov dl, ' '
    int 21h
    pop dx
    pop ax
    ret

; triangle(symbol, size)
triangle:
    ; set bp
    push bp
    mov bp, sp

    ; preserve registers
    push ax
    push bx
    push cx
    push dx

    ; get arguments
    mov dx, word ptr ss:[bp+4] ; symbol in dl
    mov bx, word ptr ss:[bp+6] ; size in bl 

    mov cl, 1 ; counter for line number

triangle_outer:
    ; if cl>bl, exit outer loop
    cmp cl, bl
    jg triangle_outer_end ; jump if cl greater bl
    
    call newline

    ; spaces to make right-aligned instead
    mov al, bl
    sub al, cl

space_loop:
    ; if al<=0 exit space loop
    cmp al, 0
    jle space_end

    ; print spaces
    call space

    dec al
    jmp space_loop

space_end:
    mov ch, 1 ; counter for inner loop

triangle_inner:
    ; if ch > cl ; triangle_inner_end
    cmp ch, cl
    jg triangle_inner_end

    ; print symbol  
    mov ah, 2
    ; dl is already the symbol
    int 21h

    inc ch
    jmp triangle_inner

triangle_inner_end:
    inc cl
    jmp triangle_outer

triangle_outer_end:
    ; restore registers
    pop dx
    pop cx
    pop bx
    pop ax

    ; restore bp
    mov sp, bp
    pop bp
    ret 4

start:
    mov ax, @data
    mov ds, ax
    
    ; print size prompt
    mov ah, 9
    mov dx, offset sSize
    int 21h

    ; int 21h, ah=1: read char from stdin with echo
    mov ah, 1
    int 21h
    ; al now has the char
    sub al, '0'
    xor ah, ah ; ax = al (so high bits = 0 and al make up lower)
    push ax

    call newline

    ; print symbol prompt
    mov ah, 9
    mov dx, offset sSymbol
    int 21h

    ; get symbol
    mov ah, 1
    int 21h
    xor ah, ah ; ax = al
    push ax

    call triangle

    ; terminate program
    mov ax, 4c00h
    int 21h
END start