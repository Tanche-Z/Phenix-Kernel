.code16
.global _start
_start:
    # text mode, clear display
    mov $3, %ax
    int $0x10

    mov $0, %ax
    mov %ax, %ds
    mov %ax, %es
    mov %ax, %ss
    mov $0x7c00, %sp # MBR address load to 0x7c00 after scan for 0x55, 0xaa

    mov $booting, %si
    call print

    // # Real mode addressing:
    // # effective addr = segment addr * 16 + excursion addr
    // mov $0xb800, %ax
    // mov %ax, %ds
    // movb $0x48, 0 # print `H`

    movl $0x1000, %edi # read target mem
    movl $2, %ecx # start sector
    mov $4, %bl # sector count
    call read_disk

    // xchg %bx, %bx # magic break point for bochs

    # magic (0x55aa) for detecting if the loader have been read to right location
    cmpw $0x55aa, 0x1000
    jnz error

    ljmp $0, $0x1002 # long jump $section, $offset (Bytes)

    jmp . # block

read_disk:

    mov $0x1f2, %dx # read quantities of sectors, 0x1f2 is port
    mov %bl, %al
    out %al, (%dx)

    inc %dx # 0x1f3
    mov %cl, %al # first 8 bits of start section
    out %al, (%dx)

    inc %dx # 0x1f4
    shr $8, %ecx
    mov %cl, %al # middle 8 bits of start section
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
        push %cx #store cx
        call .waits #wait for data ready
        call .reads #read a sector
        pop %cx #restore cx
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


//    read_disk:

//     mov $0x1f2, %dx
//     mov %bl, %al
//     out %al, (%dx)

//     inc %dx # 0x1f3
//     mov %cl, %al
//     out %al, (%dx)

//     inc %dx # 0x1f4
//     shr $8, %ecx
//     mov %cl, %al
//     out %al, (%dx)

//     inc %dx # 0x1f5
//     shr $8, %ecx
//     mov %cl, %al # the high 8 bits of start sector
//     out %al, (%dx)

//     inc %dx # 0x1f6
//     shr $8, %ecx
//     and $0b1111, %cl # set the high 4 bits as 0

//     mov $0b11100000, %al
//     or %cl, %al
//     out %al, %dx # LBA mode

//     inc %dx # 0x1f7
//     mov $0x20, %al
//     out %al, (%dx)

//     xor %ecx, %ecx # clear ECX

//     mov %bl, %cl # get the count of read/write sectors

//     .read:
//         push %cx
//         call .waits
//         call .reads
//         pop %cx
//         loop .read

//     ret

//     .waits:
//         mov $0x1f7, %dx
//         .check:
//         in (%dx), %al
//         jmp .+2 # jump to next line
//         jmp .+2
//         jmp .+2
//         and $0b10001000, %al
//         cmp $0b00001000, %al
//         jnz .check
//         ret

//     .reads:
//         mov $0x1f0, %dx
//         mov $256, %cx
//         .readw:
//             in (%dx), %ax
//             jmp .+2
//             jmp .+2
//             jmp .+2
//             mov %ax, (%edi)
//             add $2, %edi
//             loop .readw
//         ret

print:
    mov $0x0e, %ah
.next:
    mov (%si), %al
    cmp $0, %al
    jz .done
    int $0x10
    inc %si
    jmp .next
.done:
    ret

booting:
    .asciz "Booting ph1nix...\n\r"

error:
    mov $error_msg, %si
    call print
    hlt
    jmp .
    error_msg:
    .asciz "Booting Error!!!\n\r"

// # 512-2=510 total size minus last two bytes
// # 510-size of previews code (fill with 0)
// .space 510 -(. - _start) ,0

. = _start + 510

# last 2 bytes in MBR (2 Byts = 1 Word = 16 Bits)
.word 0xaa55
