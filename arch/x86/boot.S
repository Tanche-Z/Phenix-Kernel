#include "multiboot.h"

.section .nultiboot
    .long MB_MAGIC
    .long MB_ALIGHNED_4K_MEM_MAP
    .long CHECKSUM (MB_ALIGHNED_4K_MEM_MAP)

.section .bss
    .align 16 # the System-V ABI require the stack to be aligned at 16 bytes boundary
    stack_bottom:
        .skip 16318, 0
    stack_top:

.section .text
    start_:
        movl $stack_top, %esp
        call kernel_init

        pushl %ebx
        call kernel_main

        cli
    j_:
        hlt
        jmp j_