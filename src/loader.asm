[org 0x1000]

dw 0x55aa ;magic for judgement

mov si, loading
call print

xchg bx, bx ;break point

detect_memory:
    ;set ebx to 0
    xor ebx, ebx

    ; es : di the location of cache of stuctural body
    mov ax, 0
    mov es, ax
    mov edi, ards_buffer
    
    mov edx, 0x534d4150


.next:
    ; No. of subfuction
    mov eax, 0xe820
    ;ards the size of stucture (in in bytes)
    mov ecx, 20
    ; system call 0x15
    int 0x15

    ; Error occurred if CF = 0
    jc error

    ; let cache pointer point to next structure
    add di, cx

    ; add 1 to count of structural body
    inc word [ards_count]

    cmp ebx, 0
    jnz .next

    mov si, detecting
    call print

    xchg bx, bx

    ; the count of structural body
    mov cx, [ards_count]
    ; the pointer of structural body
    mov si, 0
.show:
    mov eax, [ards_buffer + si]
    mov ebx, [ards_buffer + si + 8]
    mov edx, [ards_buffer + si + 16]
    add si, 20
    xchg bx, bx
    loop .show

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
detecting:
    db "Detecting Memory Success...", 10, 13, 0;\n\r

error:
    mov si, .msg
    call print
    hlt
    jmp $
    .msg db "Loading Error!!!", 10, 13,0

ards_count:
    dw 0
ards_buffer:
