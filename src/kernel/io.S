.code32

.section .text

.global inb
inb:
    push %ebp
    mov %esp, %ebp

    xor %eax, %eax
    mov 0x8(%ebp), %edx
    in (%dx), %al

    jmp .+2
    jmp .+2
    jmp .+2

    leave
    ret

.global outb
outb:
    push %ebp
    mov %esp, %ebp

    mov 0x8(%ebp), %edx
    mov 0xc(%ebp), %eax
    out %al, (%dx)

    jmp .+2
    jmp .+2
    jmp .+2

    leave
    ret

.global inw
inw:
    push %ebp
    mov %esp, %ebp

    xor %eax, %eax
    mov 0x8(%ebp), %edx
    in (%dx), %ax

    jmp .+2
    jmp .+2
    jmp .+2

    leave
    ret

.global outw
outw:
    push %ebp
    mov %esp, %ebp

    mov 0x8(%ebp), %edx
    mov 0xc(%ebp), %eax
    out %ax, (%dx)

    jmp .+2
    jmp .+2
    jmp .+2

    leave
    ret