; https://wiki.osdev.org/Entering_Long_Mode_Directly
; [org 0x1000]
; dw 0x55aa ;magic for judgement

; mov si, loading
; call print

; detect_memory:
;     ;set ebx to 0
;     xor ebx, ebx

;     ; es : di the location of cache of stuctural body
;     mov ax, 0
;     mov es, ax
;     mov edi, ards_buffer
    
;     mov edx, 0x534d4150


; .next:
;     ; No. of subfuction
;     mov eax, 0xe820
;     ;ards the size of structure (in bytes)
;     mov ecx, 20
;     ; system call 0x15
;     int 0x15

;     ; Error occurred if CF = 1
;     jc error

;     ; let cache pointer point to next structure
;     add di, cx

;     ; add 1 to count of structural body
;     inc dword [ards_count]

;     cmp ebx, 0
;     jnz .next

;     mov si, detecting
;     call print

;     mov cx, [ards_count]
;     mov si, 0

;     ; ; show ARDS
;     ; .show:
;     ;     mov eax, [ards_buffer + si]
;     ;     mov ebx, [ards_buffer + si + 8]
;     ;     mov edx, [ards_buffer + si + 16]
;     ;     add si, 20
;     ;     xchg bx, bx
;     ;     loop .show

;     jmp SwitchToLongMode

; Function to switch directly to long mode from real mode.
; Identity maps the first 2MiB.
; Uses Intel syntax.

; es:edi    Should point to a valid page-aligned 16KiB buffer, for the PML4, PDPT, PD and a PT.
; ss:esp    Should point to memory that can be used as a small (1 uint32_t) stack
; jmp SwitchToLongMode

%define PAGE_PRESENT    (1 << 0)
%define PAGE_WRITE      (1 << 1)

%define CODE_SEG     0x0008
%define DATA_SEG     0x0010

SwitchToLongMode:

    ; Zero out the 16KiB buffer.
    ; Since we are doing a rep stosd, count should be bytes/4.   
    push di                           ; REP STOSD alters DI.
    mov ecx, 0x1000
    xor eax, eax
    cld
    rep stosd
    pop di                            ; Get DI back.

    ; Build the Page Map Level 4.
    ; es:di points to the Page Map Level 4 table.
    lea eax, [es:di + 0x1000]         ; Put the address of the Page Directory Pointer Table in to EAX.
    or eax, PAGE_PRESENT | PAGE_WRITE ; Or EAX with the flags - present flag, writable flag.
    mov [es:di], eax                  ; Store the value of EAX as the first PML4E.


    ; Build the Page Directory Pointer Table.
    lea eax, [es:di + 0x2000]         ; Put the address of the Page Directory in to EAX.
    or eax, PAGE_PRESENT | PAGE_WRITE ; Or EAX with the flags - present flag, writable flag.
    mov [es:di + 0x1000], eax         ; Store the value of EAX as the first PDPTE.


    ; Build the Page Directory.
    lea eax, [es:di + 0x3000]         ; Put the address of the Page Table in to EAX.
    or eax, PAGE_PRESENT | PAGE_WRITE ; Or EAX with the flags - present flag, writeable flag.
    mov [es:di + 0x2000], eax         ; Store to value of EAX as the first PDE.


    push di                           ; Save DI for the time being.
    lea di, [di + 0x3000]             ; Point DI to the page table.
    mov eax, PAGE_PRESENT | PAGE_WRITE    ; Move the flags into EAX - and point it to 0x0000.


    ; Build the Page Table.
.LoopPageTable:
    mov [es:di], eax
    add eax, 0x1000
    add di, 8
    cmp eax, 0x200000                 ; If we did all 2MiB, end.
    jb .LoopPageTable

    pop di                            ; Restore DI.

    ; Disable IRQs
    mov al, 0xFF                      ; Out 0xFF to 0xA1 and 0x21 to disable all IRQs.
    out 0xA1, al
    out 0x21, al

    nop
    nop

    lidt [IDT]                        ; Load a zero length IDT so that any NMI causes a triple fault.

    ; Enter long mode.
    cli ; clear interrupt
    ; open A20
    in al, 0x92
    or al, 0b10
    out 0x92, al

    mov eax, 10100000b                ; Set the PAE and PGE bit.
    mov cr4, eax

    mov edx, edi                      ; Point CR3 at the PML4.
    mov cr3, edx

    mov ecx, 0xC0000080               ; Read from the EFER MSR. 
    rdmsr    

    or eax, 0x00000100                ; Set the LME bit.
    wrmsr

    mov ebx, cr0                      ; Activate long mode -
    or ebx,0x80000001                 ; - by enabling paging and protection simultaneously.
    mov cr0, ebx                    

    lgdt [GDT.Pointer]                ; Load GDT.Pointer defined below.

    jmp CODE_SEG:LongMode             ; Load CS with 64 bit segment and flush the instruction cache

; read_disk:
;     ; set the number of reading/writing sectors
;     mov dx, 0x1f2
;     mov al, bl
;     out dx, al
    
;     inc dx; 0x1f3
;     mov al, cl; the low 8 bits of start sector 
;     out dx, al

;     inc dx; 0x1f4
;     shr ecx, 8
;     mov al, cl
;     out dx, al

;     inc dx; 0x1f5
;     shr ecx, 8
;     mov al, cl; the high 8 bits of start sector 
;     out dx, al

;     inc dx; 0x1f6
;     shr ecx, 8
;     and cl, 0b1111; set high 4 bit as 0

;     mov al, 0b1110_0000;
;     or al, cl
;     out dx, al ;LBA mdoe

;     inc dx; 0x1f7
;     mov al, 0x20 ; read hard disk
;     out dx, al

;     xor ecx, ecx; clear ecx
;     ;mov ecx, 0

;     mov cl, bl ; get the count of read/write sectors

;     .read:
;         push cx; store cx
;         call .waits;wait for data ready
;         call .reads; read a sector
;         pop cx; restore xc
;         loop .read

;     ret

;     .waits:
;         mov dx, 0x1f7
;         .check:
;             in al, dx
;             jmp $+2;jump to next line
;             jmp $+2
;             jmp $+2
;             and al, 0b1000_1000
;             cmp al, 0b0000_1000
;             jnz .check
;         ret

;     .reads:
;         mov dx, 0x1f0
;         mov cx, 256
;         .readw:
;             in ax,dx
;             jmp $+2
;             jmp $+2
;             jmp $+2
;             mov [edi], ax
;             add edi, 2
;             loop .readw
;         ret

; ; print in Real Mode
; print:
;     mov ah, 0x0e
; .next:
;     mov al, [si]
;     cmp al, 0
;     jz .done
;     int 0x10
;     inc si
;     jmp .next
; .done:
;     ret

; loading:
;     db "Loading ph1nix...", 10, 13, 0;\n\r
; detecting:
;     db "Detecting Memory Success...", 10, 13, 0;\n\r

; error:
;     mov si, .msg
;     call print
;     hlt
;     jmp $
;     .msg db "Loading Error!!!", 10, 13,0


; Global Descriptor Table
; code_selector equ (1 << 3)
; data_selector equ (2 << 3)

; memory_base equ 0 ; base address: where the memory start
; memory_limit equ ((1024* 1024* 1024 * 4) / (1024 * 4)) -1

ALIGN 4
IDT:
    .Length       dw 0
    .Base         dd 0

GDT:
.Null:
    dq 0x0000000000000000             ; Null Descriptor - should be present.

.Code:
    dq 0x00209A0000000000             ; 64-bit code descriptor (exec/read).
    dq 0x0000920000000000             ; 64-bit data descriptor (read/write).

ALIGN 4
    dw 0                              ; Padding to make the "address of the GDT" field aligned on a 4-byte boundary

.Pointer:
    dw $ - GDT - 1                    ; 16-bit Size (Limit) of GDT.
    dd GDT                            ; 32-bit Base Address of GDT. (CPU will zero extend to 64-bit)

; ards_count:
;     dd 0
; ards_buffer:


[BITS 64]
LongMode:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Blank out the screen to a blue color.
    mov edi, 0xB8000
    mov rcx, 500                      ; Since we are clearing uint64_t over here, we put the count as Count/4.
    mov rax, 0x1F201F201F201F20       ; Set the value to set the screen to: Blue background, white foreground, blank spaces.
    rep stosq                         ; Clear the entire screen. 

    ; ; Display "Hello World!"
    ; mov edi, 0x00b8000              

    ; mov rax, 0x1F6C1F6C1F651F48    
    ; mov [edi],rax

    ; mov rax, 0x1F6F1F571F201F6F
    ; mov [edi + 8], rax

    ; mov rax, 0x1F211F641F6C1F72
    ; mov [edi + 16], rax

    mov byte [0xb8000], 'P' ; indicate protected mode

    ; mov rsp, 0x10000 ; modify stack top

    ; mov rdi, 0x10000 ; read target memory
    ; mov rcx, 10; start sector
    ; mov bl, 200; sector count
    ; call read_disk

    ; jmp code_selector:0x10000
    ; ud2; means error occur


    ; jmp .Long
    ; .Long:
    ;     hlt
    ;     jmp .Long

jmp long_mode_start
long_mode_start:
    hlt
    jmp long_mode_start

