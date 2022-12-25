#include <ph1nix/ph1nix.h>
#include <ph1nix/types.h>
#include <ph1nix/io.h>
// #include <ph1nix/string.h>
// #include <ph1nix/console.h>
// #include <ph1nix/stdarg.h>


// int magic = _PH1NIX_MAGIC;
// char msg[] = "Hello ph1nix!!!";
// char buf[1024];

#define CRT_ADDR_REG 0x3D4 // CRT(6845) index register
#define CRT_DATA_REG 0x3D5 // CRT(6845) data register
#define CRT_CURSOR_H 0xE     // cursor position (High)
#define CRT_CURSOR_L 0xF     // cursor position (Low)

void _kernel_init()
{
    // char *video = (char *) 0xb8000;

    // for (int i =0; i < sizeof (msg); i++)
    // {
    //     video[i * 2] = msg [i];
    // }

    // testing io
    outb(CRT_ADDR_REG, CRT_CURSOR_H);
    u16 pos = inb(CRT_DATA_REG) << 8;
    outb(CRT_ADDR_REG, CRT_CURSOR_L);
    pos |= inb(CRT_DATA_REG); // every line has 80 char, start from  index 0

    outb(CRT_ADDR_REG, CRT_CURSOR_H);
    outb(CRT_DATA_REG, 0);
    outb(CRT_ADDR_REG, CRT_CURSOR_L);
    outb(CRT_DATA_REG, 239);

    // u8 data = inb (CRT_DATA_REG);

    // console_init();
    // int cnt =30 ;
    // while (cnt--)
    // {
    //     printk("hello ph1nix %#010x\n", cnt);
    // }

    return;
}