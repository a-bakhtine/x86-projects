.286
.model small
.stack 100h

.data
    SVGA_Info STRUC
        Signature dd ? ; Will be "VESA" if BIOS is present ; (set this to VBE2 instead of ? to receive v2.0 info)
        VersionL db ? ; Major Version Number ; notice that this was described as a WORD in previous slide
        VersionH db ? ; Minor Version Number ; but we can split into major and minor version number
        OEMStringPtr dd ? ; pointer to description string (manufacturer)
        CapableOf dd ? ; 32 flags of graphics card capabilities
        VidModePtr dd ? ; Pointer to list of available modes (list of WORDs terminated with FFFFh)
        TotalMemory dw ? ; Memory available of card (in 64 kb blocks)
        OEMSoftwareVersion dw ? ; OEM software version
        VendorName dd ? ; pointer to vendor name
        ProductName dd ? ; pointer to product name
        ProductRevisionStr dd ? ; pointer to product revision string
        Reserved db 478 DUP(?) ; Reserved
    SVGA_Info ENDS
    SVGA_i SVGA_Info <>

    SVGA_ModeInfo STRUC
        ModeAttributes dw ? ; mode attributes
        WinAAttributes db ? ; window A attributes
        WinBAttributes db ? ; window B attributes
        WinGranularity dw ? ; window granularity
        WinSize dw ? ; window size
        WinASegment dw ? ; window A start segment
        WinBSegment dw ? ; window B start segment
        WinFuncPtr dd ? ; pointer to window function
        BytesPerScanLine dw ? ; bytes per scan line
        XResolution dw ? ; horizontal resolution
        YResolution dw ? ; vertical resolution
        XCharSize db ? ; character cell width
        YCharSize db ? ; character cell height
        BitsPerPixel db ? ; bits per pixel
        NumberOfBanks db ? ; number of banks
        MemoryModel db ? ; memory model type
        BankSize db ? ; bank size in kb
        NumberOfImagePages db ? ; number of images
        Reserved1 db ? ; reserved for page function
        RedMaskSize db ? ; size of direct color red mask in bits
        RedFieldPosition db ? ; bit position of LSB of red mask
        GreenMaskSize db ? ; size of direct color green mask in bits
        GreenFieldPosition db ? ; bit position of LSB of green mask
        BlueMaskSize db ? ; size of direct color blue mask in bits
        BlueFieldPosition db ? ; bit position of LSB of blue mask
        RsvdMaskSize db ? ; size of direct color reserved mask in bits
        DirectColorModeInfo db ? ; Direct Color mode attributes
        Reserved2 db 216 DUP(?) ; remainder of ModeInfo
    SVGA_ModeInfo ENDS
    SVGA_mi SVGA_ModeInfo <>


    coordinate STRUC
      latitude dw ?
      longitude dw ?
      altitude dw ?
    coordinate ENDS

    my_position coordinate <45, 73, 36>

.code

; printInt (int number)
; prints 16bit # -> stdout
; convert # to ASCII before interupt
printInt:
    ; set bp
    push bp
    mov bp, sp

    ; preserve registers
    push ax
    push bx
    push cx
    push dx 

    ; AX = number
    mov ax, word ptr ss:[bp+4]

    cmp ax, 0
    jne convert
    mov ah, 02h
    mov dl, '0'
    int 21h
    jmp printInt_end

convert:
    mov bx, 10 ; bx = 10 = divisor
    xor cx, cx ; cx = # of pushed digits

push_digits:
    xor dx, dx ; DX must be 0 before div
    div bx ; AX = AX / 10
    push dx ; remainder (AX % 10)
    inc cx ; += 1
    cmp ax, 0 
    jne push_digits

print_digits:
    pop dx ; DX has the digits
    add dl, '0' ; convert to ascii
    mov ah, 02h
    int 21h
    dec cx
    jnz print_digits

printInt_end: 
    pop dx
    pop cx
    pop bx
    pop ax

    mov sp, bp
    pop bp
    ret 2

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

start:
    mov ax, @data
    mov ds, ax
    mov es, ax 

    ; print longitude
    mov ax, my_position.longitude
    push ax
    call printInt
    call newline


    ; SuperVGA information on display adaptaer
    mov byte ptr SVGA_i.Signature+0, 'V'
    mov byte ptr SVGA_i.Signature+1, 'B'
    mov byte ptr SVGA_i.Signature+2, 'E'
    mov byte ptr SVGA_i.Signature+3, '2'

    mov ax, 4f00h
    mov di, OFFSET SVGA_i
    int 10h

    mov ax, SVGA_i.TotalMemory
    push ax
    call printInt
    call newline

    ; SuperVGA mode information
    mov ax, 4f01h
    mov cx, 0104h
    mov di, OFFSET SVGA_mi
    int 10h

    ; print x-res x y-res
    mov ax, SVGA_mi.XResolution
    push ax
    call printInt

    mov ah, 02h
    mov dl, 'x'
    int 21h

    mov ax, SVGA_mi.YResolution
    push ax
    call printInt
    call newline

    ; terminate
    mov ax, 4c00h
    int 21h
end start