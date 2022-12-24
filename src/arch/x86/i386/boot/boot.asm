[org 0x7c00] ; just for NASM to output bin file (hint for assembler and linkder of base address(entry point))
; Set screen mode as text mode, clear screen.
mov ax, 3
int 0x10

; initial segment register
mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00 ; MBR Load into this address after find magic number of 0x55, 0xAA
mov si, booting
call print

; mov ax, 0xb800
; mov ds, ax
; mov byte [0], 'H'

mov edi, 0x1000; read target memory
mov ecx, 2; start sector
mov bl, 4; sector count
call read_disk

cmp word [0x1000], 0x55aa
jnz error

jmp 0:0x1002

; mov edi, 0x1000; write target memory
; mov ecx, 1; start sector
; mov bl, 1; sector count
; call write_disk
; xchg bx, bx ; bochs magic break

jmp $ ; block


read_disk:

    ; set the number of reading/writing sectors
    mov dx, 0x1f2
    mov al, bl
    out dx, al
    
    inc dx ; 0x1f3
    mov al, cl; the low 8 bits of start sector 
    out dx, al

    inc dx ; 0x1f4
    shr ecx, 8
    mov al, cl
    out dx, al

    inc dx; 0x1f5
    shr ecx, 8
    mov al, cl; the high 8 bits of start sector 
    out dx, al

    inc dx; 0x1f6
    shr ecx, 8
    and cl, 0b1111; set high 4 bit as 0

    mov al, 0b1110_0000;
    or al, cl
    out dx, al ; LBA mode

    inc dx; 0x1f7
    mov al, 0x20 ; read hard disk
    out dx, al

    xor ecx, ecx; clear ecx
    ;mov ecx, 0

    mov cl, bl ; get the count of read/write sectors

    .read:
        push cx; store cx
        call .waits;wait for data ready
        call .reads; read a sector
        pop cx; restore cx
        loop .read

    ret

    .waits:
        mov dx, 0x1f7
        .check:
            in al, dx
            jmp $+2;jump to next line
            jmp $+2
            jmp $+2
            and al, 0b1000_1000
            cmp al, 0b0000_1000
            jnz .check
        ret

    .reads:
        mov dx, 0x1f0
        mov cx, 256
        .readw:
            in ax,dx
            jmp $+2
            jmp $+2
            jmp $+2
            mov [edi], ax
            add edi, 2
            loop .readw
        ret

; write_disk:

;     ; set the number of reading/writing sectors
;     mov dx, 0x1f2
;     mov al, bl
;     out dx, al
    
;     inc dx; 0x1f3
;     mov al, cl; the low 8 bits of start sector 
;     out dx, al

;     inc dx; 0x1f4
;     shr ecx, 8
;     mov al, cl
;     out dx, al

;     inc dx; 0x1f5
;     shr ecx, 8
;     mov al, cl; the high 8 bits of start sector 
;     out dx, al

;     inc dx; 0x1f6
;     shr ecx, 8
;     and cl, 0b1111; set high 4 bit as 0

;     mov al, 0b1110_0000;
;     or al, cl
;     out dx, al ;LBA mdoe

;     inc dx; 0x1f7
;     mov al, 0x30 ; write hard disk
;     out dx, al

;     xor ecx, ecx; clear ecx
;     ;mov ecx, 0

;     mov cl, bl ; get the count of read/write sectors

;     .write:
;         push cx; store cx
;         call .writes; write a sector
;         call .waits; wait for end of busy hard disk
;         pop cx; restore xc
;         loop .write

;     ret

;     .waits:
;         mov dx, 0x1f7
;         .check:
;             in al, dx
;             jmp $+2;jump to next line
;             jmp $+2
;             jmp $+2
;             and al, 0b1000_0000
;             cmp al, 0b0000_0000
;             jnz .check
;         ret

;     .writes:
;         mov dx, 0x1f0
;         mov cx, 256
;         .writew:
;             mov ax, [edi]
;             out dx, ax
;             jmp $+2
;             jmp $+2
;             jmp $+2
;             add edi, 2
;             loop .writew
;         ret

; print:
;     mov ah, 0x0e
; .next:
;     mov al, [si]
;     cmp al, 0
;     jz .done
;     int 0x10
;     inc si
;     jmp .next
; .done:
;     ret


booting:
    db "Booting ph1nix...", 10, 13, 0 ;\n\r

error:
    mov si, .msg
    call print
    hlt
    jmp $
    .msg db "Booting Error!!!", 10, 13, 0

; Padding MBR with data 0
times 510 - ($ - $$) db 0

; bios required (main boot record (MBR) last two bytes 
; must be 0x55 and 0xaa)
db 0x55, 0xaa
; or 
; dw 0xaa55