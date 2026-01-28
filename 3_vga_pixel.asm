.286
.model small
.stack 100h
.code
start:
    mov ax, 0013h ; video mode
    int 10h

    mov ah, 00h
    int 16h ; wait for keypress

    mov ax, 0a000h ; vga cpu address space
    mov es, ax

    mov dl, 3 ; color = 3 (cyan)
    mov bx, 32160 ; center pixel
    mov BYTE PTR es:[bx], dl

    mov ah, 00h 
    int 16h ; wait for keypress

    mov ax, 0003h ; text mode
    int 10h

    mov ax, 4c00h 
    int 21h
end start