[bits 32]

extern exit

global main
main:
    ; push 5
    ; push eax
    ; pop ebx
    ; pop ecx

    pusha
    popa

    push 0 ; pass parameter
    call exit