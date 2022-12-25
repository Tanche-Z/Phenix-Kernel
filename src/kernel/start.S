.code32

.extern _kernel_init

.global _start
_start:
    xchg %bx, %bx
    call _kernel_init
    xchg %bx, %bx
    // movb $0x4b, 0xb8000 # print K at first char in display
    jmp .

