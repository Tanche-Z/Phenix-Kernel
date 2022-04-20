[org 0x1000]

dw 0x55aa ;magic for judgement

mov bx, bx ;break point

mov si, loading
call print

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


loading:
    db "Loading ph1nix...", 10, 13, 0;\n\r