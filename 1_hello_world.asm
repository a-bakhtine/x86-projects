.model small
.stack 100h
.data
	sHello db "Hello World!", 13, 10, "$"
	sPrompt db "Enter a number:$"
	sNewLine db 13, 10, "$"
.code
start:
	mov ax, @data
	mov ds, ax

	; print prompt
	mov ah, 9
	mov dx, offset sPrompt
	int 21h

	; int 21h, ah=1: read char from stdin with echo
	mov ah, 1
	int 21h
	sub al, '0'

	; print new line
	mov ah, 9
	mov dx, offset sNewLine
	int 21h

	xor cx, cx
	mov cl, al
	; label that will be used for our loop
	printMore:
	; save our counter
	; (interrupts don’t have
	; to preserve ax, cx, dx)
	push cx
	; print our string
	mov ah, 9
	mov dx, OFFSET sHello
	int 21h
	; restore our counter
	pop cx
	; decrement counter and jump back if it’s not 0
	dec cx
	jnz short printMore

	; int 21h, ah=4c: terminate program
	; al is the return code (i.e. ax=4c00h is the same as ah=4c and al=00)
	mov ax, 4c00h
	int 21h
END start