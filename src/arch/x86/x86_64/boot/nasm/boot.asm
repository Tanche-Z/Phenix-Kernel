[ORG 0x7C00]
[BITS 16]

%define FREE_SPACE 0x9000
; Main entry point where BIOS leaves us.

Main:
    ; Some BIOS' may load us at 0x0000:0x7C00 while other may load us at 0x07C0:0x0000.
    ; Do a far jump to fix this issue, and reload CS to 0x0000.
    jmp 0x0000:.FlushCS

.FlushCS:   
    xor ax, ax

    ; Set up segment registers.
    mov ss, ax
    ; Set up stack so that it starts below Main.
    mov sp, Main

    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    cld

    ; ; Set screen mode as text mode, clear screen.
    ; mov ax, 3
    ; int 0x10
    ; ; initial segment register
    ; mov ax, 0
    ; mov ds, ax
    ; mov es, ax
    ; mov ss, ax
    ; mov sp, 0x7c00 ; MBR Load into this address after find magic number of 0x55, 0xAA
    ; mov si, booting
    ; call print

    ; call CheckCPU                     ; Check whether we support Long Mode or not.
    ; jc .NoLongMode

    ; Point edi to a free space bracket.
    mov edi, FREE_SPACE
    ; Switch to Long Mode.
    jmp SwitchToLongMode

    ; mov edi, 0x1000; read target memory
    ; mov ecx, 2; start sector
    ; mov bl, 4; sector count
    ; call read_disk

    ; cmp word [0x1000], 0x55aa
    ; jnz error

    ; jmp 0:0x1002

    ; mov edi, 0x1000; write target memory
    ; mov ecx, 1; start sector
    ; mov bl, 1; sector count
    ; call write_disk
    ; jmp $ ; block


; BITS 64
; .Long:
;     hlt
;     jmp .Long
;     ; jmp 


; BITS 16

; .NoLongMode:
;     mov si, NoLongMode
;     call Print

; .Die:
;     hlt
;     jmp .Die


; ; %include "LongModeDirectly.asm"
%include "loader.asm"

; [BITS 16]
; NoLongMode db "ERROR: CPU does not support long mode.", 0x0A, 0x0D, 0


; ; Checks whether CPU supports long mode or not.

; ; Returns with carry set if CPU doesn't support long mode.

; CheckCPU:
;     ; Check whether CPUID is supported or not.
;     pushfd                            ; Get flags in EAX register.

;     pop eax
;     mov ecx, eax  
;     xor eax, 0x200000 
;     push eax 
;     popfd

;     pushfd 
;     pop eax
;     xor eax, ecx
;     shr eax, 21 
;     and eax, 1                        ; Check whether bit 21 is set or not. If EAX now contains 0, CPUID isn't supported.
;     push ecx
;     popfd 

;     test eax, eax
;     jz .NoLongMode

;     mov eax, 0x80000000   
;     cpuid                 

;     cmp eax, 0x80000001               ; Check whether extended function 0x80000001 is available are not.
;     jb .NoLongMode                    ; If not, long mode not supported.

;     mov eax, 0x80000001  
;     cpuid                 
;     test edx, 1 << 29                 ; Test if the LM-bit, is set or not.
;     jz .NoLongMode                    ; If not Long mode not supported.

;     ret

; .NoLongMode:
;     stc
;     ret


; ; Prints out a message using the BIOS.

; ; es:si    Address of ASCIIZ string to print.

; Print:
;     pushad
; .PrintLoop:
;     lodsb                             ; Load the value at [@es:@si] in @al.
;     test al, al                       ; If AL is the terminator character, stop printing.
;     je .PrintDone                  	
;     mov ah, 0x0E	
;     int 0x10
;     jmp .PrintLoop                    ; Loop till the null character not found.

; .PrintDone:
;     popad                             ; Pop all general purpose registers to save them.
;     ret

; read_disk:

;     ; set the number of reading/writing sectors
;     mov dx, 0x1f2
;     mov al, bl
;     out dx, al
    
;     inc dx ; 0x1f3
;     mov al, cl; the low 8 bits of start sector 
;     out dx, al

;     inc dx ; 0x1f4
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
;     out dx, al ; LBA mode

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
;         pop cx; restore cx
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

; write_disk:

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
;     mov al, 0x30 ; write hard disk
;     out dx, al

;     xor ecx, ecx; clear ecx
;     ;mov ecx, 0

;     mov cl, bl ; get the count of read/write sectors

;     .write:
;         push cx; store cx
;         call .writes; write a sector
;         call .waits; wait for end of busy hard disk
;         pop cx; restore xc
;         loop .write

;     ret

;     .waits:
;         mov dx, 0x1f7
;         .check:
;             in al, dx
;             jmp $+2;jump to next line
;             jmp $+2
;             jmp $+2
;             and al, 0b1000_0000
;             cmp al, 0b0000_0000
;             jnz .check
;         ret

;     .writes:
;         mov dx, 0x1f0
;         mov cx, 256
;         .writew:
;             mov ax, [edi]
;             out dx, ax
;             jmp $+2
;             jmp $+2
;             jmp $+2
;             add edi, 2
;             loop .writew
;         ret

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


; booting:
;     db "Booting ph1nix...", 10, 13, 0 ;\n\r

; error:
;     mov si, .msg
;     call print
;     hlt
;     jmp $
;     .msg db "Booting Error!!!", 10, 13, 0

; Pad out file.
times 510 - ($-$$) db 0
dw 0xAA55