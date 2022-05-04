[bits 32]

section .text ; code section

global inb ; export inb
inb:
    push ebp
    mov ebp, esp ; store frame

    xor eax, eax ; clear eax (set to 0)
    mov edx, [ebp + 8] ; port
    in al, dx ; input 8 bits port number from dx to al
    
    jmp $+2 ; add a little latency time in simple way
    jmp $+2
    jmp $+2

    leave ; revover stack frame
    ret

global outb ; export outb
outb:
    push ebp
    mov ebp, esp ; store frame

    mov edx, [ebp + 8] ; port
    mov eax, [ebp + 12] ; value
    out dx, al ; output 8 bits port number from al to dx
    
    jmp $+2 ; add a little latency time in simple way
    jmp $+2
    jmp $+2

    leave ; revover stack frame
    ret

global inw ; export inw
inw:
    push ebp
    mov ebp, esp ; store frame

    xor eax, eax ; clear eax (set to 0)
    mov edx, [ebp + 8] ; port
    in ax, dx ; input 8 bits port number from dx to ax
    
    jmp $+2 ; add a little latency time in simple way
    jmp $+2
    jmp $+2

    leave ; revover stack frame
    ret

global outw ; export outw
outw:
    push ebp
    mov ebp, esp ; store frame

    mov edx, [ebp + 8] ; port
    mov eax, [ebp + 12] ; value
    out dx, ax ; output 8 bits port number from ax to dx
    
    jmp $+2 ; add a little latency time in simple way
    jmp $+2
    jmp $+2

    leave ; revover stack frame
    ret