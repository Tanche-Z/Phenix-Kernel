#include <ph1nix/types.h>
#include <stdio.h>

typedef struct descriptor /* totally 8 bytes */
{
    unsigned short limit_low; // boundary of section 0~15 bits
    unsigned int base_low : 24; //base address 0~23 bits (16M)
    unsigned char type : 4; // section type
    unsigned char segment : 1; // 1 indicates code segment or data segment, 0 indicates system segment
    unsigned char DPL : 2; // Descriptor Privilege Level 0~3
    unsigned char present : 1; // whether exist: 1 indicates in RAM, 0 indicates in disk
    unsigned char limit_high : 4; // section boundary 16~19 bits
    unsigned char available : 1; // for operating system
    unsigned long_mode : 1; // sign of 64 bits extention
    
} __attribute__((packed)) descriptor;
