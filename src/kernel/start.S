.code32

.extern _kernel_init

.global _start
_start:
    # call _kernel_init
    movb $0x4b, 0xb8000 # print K at first char in display
    jmp .

