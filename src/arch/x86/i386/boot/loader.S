// .text
.code16
.global _start
_start:
.word 0x55aa # magic for Error judgement

# indicating entered boot loader
mov $loading, %si
call print

detect_memory:
    # set ebx to 0
    xor %ebx, %ebx

    # es : di the location of cache of stuctural body
    mov $0, %ax
    mov %ax, %es
    mov $ards_buffer, %edi

    mov $0x534d4150, %edx

.next:
    # number of subfuction of BIOS (Memory detecting)
    mov $0xe820, %eax
    # ards the size of structure (in bytes)
    mov $20, %ecx
    # system call 0x15
    int $0x15

    # Output Error if CF=0
    jc error

    # let cache pointer point to next structure
    add %cx, %di

    # add 1 to count of structural body
    incw ards_count

    cmp $0, %ebx
    jnz .next

    mov $detecting, %si
    call print

    jmp pre_protected_mode

pre_protected_mode:
    cli # clear interrupt
    # open the A20
    in $0x92, %al
    or $0b10, %al
    out %al, $0x92
    lgdtl gdt_ptr # load GDT
    # PE(Protect Enable)
    mov %cr0, %eax
    or $1, %eax
    mov %eax, %cr0
    ljmp $code_selector, $protect_mode # use jmp to refresh cache

print:
    mov $0x0e, %ah
.p_next:
    mov (%si), %al
    cmp $0, %al
    jz .done
    int $0x10
    inc %si
    jmp .p_next
.done:
    ret

loading:
    .asciz "Loading ph1nix...\n\r"
detecting:
    .asciz "Detecting Memory Success...\n\r"

error:
    mov $.msg, %si
    call print
    hlt
    jmp .
    .msg:
        .asciz "Loading Error!!!\n\r"

.code32
protect_mode:
    mov $data_selector, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss # initialize segment register

    mov $0x10000, %esp # set stack top

    mov $0x10000, %edi # read target memory
    mov $10, %ecx # start sector
    mov $200, %bl # sector count
    call read_disk

    ljmp $code_selector, $0x10000
    ud2 # means error occur
jmp .

read_disk:

    mov $0x1f2, %dx
    mov %bl, %al
    out %al, (%dx)

    inc %dx # 0x1f3
    mov %cl, %al
    out %al, (%dx)

    inc %dx # 0x1f4
    shr $8, %ecx
    mov %cl, %al
    out %al, (%dx)

    inc %dx # 0x1f5
    shr $8, %ecx
    mov %cl, %al # the high 8 bits of start sector
    out %al, (%dx)

    inc %dx # 0x1f6
    shr $8, %ecx
    and $0b1111, %cl # set the high 4 bits as 0

    mov $0b11100000, %al
    or %cl, %al
    out %al, (%dx) # LBA mode

    inc %dx # 0x1f7
    mov $0x20, %al
    out %al, (%dx)

    xor %ecx, %ecx # clear ECX

    mov %bl, %cl # get the count of read/write sectors

    .read:
        push %cx
        call .waits
        call .reads
        pop %cx
        loop .read

    ret

    .waits:
        mov $0x1f7, %dx
        .check:
        in (%dx), %al
        jmp .+2 # jump to next line
        jmp .+2
        jmp .+2
        and $0b10001000, %al
        cmp $0b00001000, %al
        jnz .check
    ret

    .reads:
        mov $0x1f0, %dx
        mov $256, %cx
        .readw:
            in (%dx), %ax
            jmp .+2
            jmp .+2
            jmp .+2
            mov %ax, (%edi)
            add $2, %edi
            loop .readw
        ret

.equ code_selector, (1 << 3)
.equ data_selector, (2 << 3)

.equ memory_base, 0 # base address: where the memory start
.equ memory_limit, 1048575 # ((1024* 1024* 1024 * 4) / (1024 * 4)) -1

gdt_ptr:
    .word (gdt_end - gdt_base) - 1
    .long gdt_base
gdt_base:
    .long 0, 0 # NULL Discriptor
gdt_code:
    .word memory_limit & 0xffff # segment limit 0~15
    .word memory_base & 0xffff # base address 0~15
    .byte (memory_base >> 16) & 0xff # base address 16~23
    .byte 0b10011010 # exist_dpl(discriptor privilege level) is 0_S is Code_ NOT compliance_writable_haven't been accessed
    .byte 0b11000000 | (memory_limit >> 16) & 0xf # 4K_32bit_not 64bit_available to OS_segment limit 16~19
    .byte (memory_base >> 24) & 0xff # base address 24~31

gdt_data:
    .word memory_limit & 0xffff # segment limit 0~15
    .word memory_base & 0xffff # base address 0~15
    .byte (memory_base >> 16) & 0xff # base address 16~23
    .byte 0b10010010 # exist_dpl(discriptor privilege level) is 0_S is Data_upward extend_writable_haven't been accesseds
    .byte 0b11000000 | (memory_limit >> 16) & 0xf # 4K_32bit_not 64bit_available to OS_segment limit 16~19
    .byte (memory_base >> 24) & 0xff # base address 24~31

gdt_end:

ards_count:
    .long 0
ards_buffer:
