[bits 32]

extern _kernel_init

global _start
_start:
    ; call _kernel_init
    mov byte [0xb8000], "K"
    jmp $