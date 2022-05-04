#include <ph1nix/ph1nix.h>
#include <ph1nix/types.h>
#include <ph1nix/io.h>

#define CRT_ADDR_REG 0x3d4 // CRT adress regiter
#define CRT_DATA_REG 0x3d5 // CRT data regiter

#define CRT_CURSOR_H 0xe // the position of cursor (high)
#define CRT_CURSOR_L 0xf // the position of cursor (low)

void kernel_init()
{
    outb(CRT_ADDR_REG, CRT_CURSOR_H);
    u16 pos = inb(CRT_DATA_REG) << 8;
    outb(CRT_ADDR_REG, CRT_CURSOR_L);
    pos |= inb(CRT_DATA_REG);
    
    outb(CRT_ADDR_REG, CRT_CURSOR_H);
    outb(CRT_DATA_REG, 0);
    outb(CRT_ADDR_REG, CRT_CURSOR_L);
    outb(CRT_DATA_REG, 123);

    return;
}