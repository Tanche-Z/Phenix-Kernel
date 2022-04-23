[org 0x1000]

dw 0x55aa ;magic for judgement

mov si, loading
call print

; xchg bx, bx ;break point

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
    mov byte [0xb8000], 'P'

    jmp pre_protected_mode

pre_protected_mode:
    xchg bx, bx
    cli ; close interrupt
    ; open A20
    in al, 0x92
    or al, 0b10
    out 0x92, al
    lgdt [gdt_ptr]; load get
    ; PE (Protect Enable)
    mov eax ,cr0
    or eax, 1
    mov cr0 , eax
    jmp dword code_selector:protect_mode ; use jmp to refresh cache

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

[bits 32]
protect_mode:
    xchg bx, bx
    mov ax, data_selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax ;initialize segment register

    mov sp, 0x10000 ; modify stack top
    mov byte [0xb8000], 'P'
    mov byte [0x200000], 'P'

jmp $

code_selector equ (1 << 3)
data_selector equ (2 << 3)

memory_base equ 0 ; base address: where the memory start
memory_limit equ ((1024* 1024* 1024 * 4) / (1024 * 4)) -1

gdt_ptr:
    dw (gdt_end - gdt_base) - 1
    dd gdt_base
gdt_base:
    dd 0, 0 ; NULL Discriptor
gdt_code:
    dw memory_limit & 0xffff ; segment limit 0~15
    dw memory_base & 0xffff ; base address 0~16
    db (memory_base >> 16) & 0xff; base address 16~24
    db 0b_1_00_1_1_0_1_0 ; exist_dpl(discriptor privilege level) is 0_S is Code_ NOT compliance_writable_haven't been accessed
    db 0b1_1_0_0_0000 | (memory_limit >> 16) & 0xf ; 4K_32bit_not 64bit_available to OS_segment limit 16~19
    db (memory_base >> 24) & 0xff ; base address 24~31

gdt_data:
    dw memory_limit & 0xffff ; segment limit 0~15
    dw memory_base & 0xffff ; base address 0~16
    db (memory_base >> 16) & 0xff; base address 16~24
    db 0b_1_00_1_0_0_1_0 ; exist_dpl(discriptor privilege level) is 0_S is Data_upward extend_writable_haven't been accessed
    db 0b1_1_0_0_0000 | (memory_limit >> 16) & 0xf ; 4K_32bit_not 64bit_available to OS_segment limit 16~19
    db (memory_base >> 24) & 0xff ; base address 24~31

gdt_end:

ards_count:
    dw 0
ards_buffer:
