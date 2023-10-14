#ifndef PH1NIX_GLOBAL_H
#define PH1NIX_GLOBAL_H

#include <ph1nix/types.h>

#define GDT_SIZE 128 // max to 8192

// GDT
typedef struct descriptor_t{
    unsigned short limit_low; // segment limit 0 to 15 bits
    unsigned int base_low : 24; // base address 0 to 23 bits for 16M
    unsigned char type : 4; // segment type
    unsigned char segment : 1; // 1 for data or code segment, 0 for system
    unsigned char DPL : 2; // descriptor privilege level (0 to 3)
    unsigned char present : 1; // 0 for present in RAM, 1 for disk
    unsigned char limit_high : 4; // segment limit 16 to 19
    unsigned char available : 1; // to os
    unsigned char long_mode : 1; // 64bits
    unsigned char big : 1; // 32 or 16 bits
    unsigned char granularity : 1; // 4kB or 1B
    unsigned char base_high; // 24 to 31 bits
}_packed descriptor_t;

// segment selector
typedef struct selector_t
{
    u8 RPL : 2;
    u8 TI : 1;
    u16 index : 13;
}selector_t;

typedef struct pointer_t
{
    u16 limit;
    u32 base;
}_packed pointer_t;

void gdt_init();

#endif