[bits 32]

extern kernel_init

global _start
_start:
    ; mov byte [0xb8000], 'K' ; Show "K" in first charator of display print. means entered kernel
    ; xchg bx, bx
    call kernel_init
    ; xchg bx, bx
    jmp $