// .text
    .code16
.global _start
_start:
.word 0x55aa # magic for Error judgement

# indicating has entered boot loader
mov $loading, %si
call print

detect_memory:
    # set ebx to 0
    xor %ebx, %ebx

    # es : di the location of cache of stuctural body
    mov $0, %ax
    mov %ax, %es
    mov $ards_buffer, %edi

    mov $0x534d4150, %edx # a fix signiture (ASCII for `SMAP`)

.next:
    # number of subfuction of BIOS (Memory detecting)
    mov $0xe820, %eax
    # the size of ARDS structure (in bytes)
    mov $20, %ecx
    # system call 0x15
    int $0x15

    # Output Error if CF=1
    jc error

    # let cache pointer point to next structure body
    add %cx, %di

    # add 1 to count of structural body
    incl ards_count

    cmp $0, %ebx
    jnz .next

    # finished detecting memory
    mov $detecting, %si
    call print

    mov ards_count, %cx
    mov $0, %si

// # show ARDS ???
// .show:
//     mov $ards_buffer, %bx
//     mov %si, %ax
//     add %ax, %bx
//     mov (%bx), %ax

//     xchg %bx, %bx
//     loop .show

    jmp pre_protected_mode

pre_protected_mode:
    cli # clear interrupt
    # open the A20
    in $0x92, %al
    or $0b10, %al
    out %al, $0x92
    lgdtl gdt_ptr # load GDT
    # PE(Protect Enable) (set cr0 to 1)
    mov %cr0, %eax
    or $1, %eax
    mov %eax, %cr0
    ljmp $code_selector, $protect_mode # use jmp to refresh cache

# pirnt in Real Mode
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
    .asciz "Detecting Memory Success ^_^\n\r"

error:
    mov $.msg, %si
    call print
    hlt
    jmp .
    .msg:
        .asciz "Loading Error!!!\n\r"


// code bening trunc!!! No high bits
// why???
    .code32
protect_mode:
    mov $data_selector, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss # initialize segment register

    mov $0x10000, %esp # set stack top

    // # Reset first char in display with 'P', indicating entered Proteted Mode
    // movb $0x50, 0xb8000
    // movb $0x50, 0x200000

    mov $0x10000, %edi # read target memory (kernel)
    mov $10, %ecx # start sector
    mov $200, %bl # sector count
    call read_disk

    ljmp $code_selector, $0x10000 # go to kernel
    ud2 # means error occur (should never excute to here) (if here, error occur)
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

code_selector = gdt_code - gdt_base
data_selector = gdt_data - gdt_base

gdt_ptr:
    .word (gdt_end - gdt_base) - 1
    .long gdt_base

gdt_base:
    .long 0, 0

gdt_code:
    .word 0xffff
    .word 0x00
    .byte 0x00
    .byte 0b10011010
    .byte 0b11000000
    .byte 0x00

gdt_data:
    .word 0xffff
    .word 0x00
    .byte 0x00
    .byte 0b10010010
    .byte 0b11000000
    .byte 0x00

gdt_end:

ards_count:
    .long 0
ards_buffer:
