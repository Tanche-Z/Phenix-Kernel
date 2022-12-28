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

.align 4
idt:
    .word 0
    .long 0

pre_protected_mode:
    cli # clear interrupt
    # open the A20
    in $0x92, %al
    or $0b10, %al
    out %al, $0x92

    push %di
    mov $0x1000, %ecx
    xor %eax, %eax
    cld
    rep stosl
    pop %di

    lea %es:0x1000(%di), %eax
    or $0b10, %eax
    mov %eax, %es:(%di)

    lea %es:0x2000(%di), %eax
    or $0b10, %eax
    mov %eax, %es:0x1000(%di)

    lea %es:0x3000(%di), %eax
    or $0b10, %eax
    mov %eax, %es:0x2000(%di)

    push %di
    lea 0x3000(%di), %di
    mov 0b10, %eax

.looppagetable:
    mov %eax, %es:(%di)
    add $0x1000, %eax
    add $8, %di
    cmp 0x200000, %eax
    jb .looppagetable

    pop %di

    mov $0xff, %al
    out %al, 0xa1
    out %al, 0x21

    nop
    nop

    lidt idt

    # enter long mode
    mov $10100000b, %eax
    mov %eax, %cr4

    mov %edi, %edx
    mov %edx, %cr0

    mov $0xc0000080, %eax
    rdmsr

    or $0x00000100, %eax
    wrmsr

    mov %cr0, %ebx
    or $0x80000001, %ebx
    mov %ebx, %cr0

    lgdtl gdt_ptr # load GDT
    # PE(Protect Enable) (set cr0 to 1)
    // mov %cr0, %eax
    // or $1, %eax
    // mov %eax, %cr0
    ljmp $code_selector, $long_mode # use jmp to refresh cache

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

    .code64
long_mode:
    mov $data_selector, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %fs
    mov %ax, %gs
    mov %ax, %ss # initialize segment register

    // mov $0x10000, %esp # set stack top

    # clean screen with blue color
    mov $0xb8000, %edi
    mov $500, %rcx # count/4 (uint64_t)
    mov $0x1F201F201F201F20, %rax # set blue background, white foreground, blank spaces
    rep stosq # clear entire screen

    # Reset first char in display with 'L', indicating entered Long Mode
    movb $0x4C	, 0xb8000
    movb $0x4C	, 0x200000

    // mov $0x10000, %edi # read target memory (kernel)
    // mov $10, %rcx # start sector
    // mov $200, %bl # sector count
    // call read_disk

    // ljmp $code_selector, $0x10000 # go to kernel
    // ud2 # means error occur (should never excute to here) (if here, error occur)
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
    .word (gdt_end - gdt_base) - 1 # 16-bit Size (Limit) of GDT.
    .long gdt_base # 32-bit Base Address of GDT. (CPU will zero extend to 64-bit)

gdt_base:
    .quad 0x0000000000000000 

gdt_code:
    .quad 0x00209A0000000000 # 64-bit code descriptor (exec/read)

gdt_data:
    .quad 0x0000920000000000 # 64-bit data descriptor (read/write)

.align 4
    .long 0 # Padding to make the "address of the GDT" field aligned on a 4-byte boundary

gdt_end:

ards_count:
    .long 0
ards_buffer:
