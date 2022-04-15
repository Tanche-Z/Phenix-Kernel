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
mov ax, 0xb800
mov ds, ax
mov byte [0],'H'

; block
jmp $

times 510 - ($ - $$) db 0

; bios required (main boot record (MBR) last two bytes 
; must be 0x55 and 0xaa)
db 0x55, 0xaa
; or 
; dw 0xaa55