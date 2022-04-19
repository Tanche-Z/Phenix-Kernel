[org 0x7c00]

; Set screen mode as text mode, clear screen.
mov ax, 3
int 0x10

; initial segment register
mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00

; 0x800 is the ram of text display
; mov ax, 0xb800
; mov ds, ax
; mov byte [0],'H'
; mov byte [2],'e'
; mov byte [4],'l'
; mov byte [6],'l'
; mov byte [8],'o'
; mov byte [10],' '
; mov byte [12],'W'
; mov byte [14],'o'
; mov byte [16],'r'
; mov byte [18],'l'
; mov byte [20],'d'
; mov byte [22],'!'
; mov byte [24],'!'
; mov byte [26],'!'

xchg bx, bx ; bochs magic break


mov si, booting
call print

; block
jmp $

print:
    mov ah, 0x0e
.next:
    mov al, [si]
    cmp al, 0
    jz .done
    int 0x10
    inc si
    jmp .next
.done:
    ret


booting:
    db "Booting ph1nix...", 10, 13, 0;\n\r

times 510 - ($ - $$) db 0

; bios required (main boot record (MBR) last two bytes 
; must be 0x55 and 0xaa)
db 0x55, 0xaa
; or 
; dw 0xaa55