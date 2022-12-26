#include <ph1nix/ph1nix.h>
#include <ph1nix/types.h>
#include <ph1nix/io.h>
#include <ph1nix/string.h>
// #include <ph1nix/console.h>
// #include <ph1nix/stdarg.h>

char msg[] = "Hello phinix!!!";
char buf[1024];

void _kernel_init()
{
    // testing io
    // outb(CRT_ADDR_REG, CRT_CURSOR_H);
    // u16 pos = inb(CRT_DATA_REG) << 8;
    // outb(CRT_ADDR_REG, CRT_CURSOR_L);
    // pos |= inb(CRT_DATA_REG); // every line has 80 char, start from  index 0
    // outb(CRT_ADDR_REG, CRT_CURSOR_H);
    // outb(CRT_DATA_REG, 0);
    // outb(CRT_ADDR_REG, CRT_CURSOR_L);
    // outb(CRT_DATA_REG, 239);
    // u8 data = inb (CRT_DATA_REG);

    // testing string.c
    int res;
    res = strcmp(buf, msg); // compare
    
    strcpy(buf, msg); // copy
    res = strcmp(buf, msg); // compare
    
    strcat(buf, msg); // 2xmsg
    res = strcmp(buf, msg); // compare

    res = strlen(msg); // length
    res =sizeof(msg); // include '/0' (length + 1)

    char *ptr = strchr(msg, '!'); // find first '!'
    ptr = strrchr(msg, '!'); // find last '!' (most right one)

    memset(buf, 0, sizeof(buf)); // set content in 'buf' to '0'
    res = memcmp(buf, msg, sizeof(msg));
    memcpy(buf, msg, sizeof(msg));
    res = memcmp(buf, msg, sizeof(msg));
    ptr = memchr(buf, '!', sizeof(msg));

    // console_init();
    // int cnt =30 ;
    // while (cnt--)
    // {
    //     printk("hello ph1nix %#010x\n", cnt);
    // }

    return;
}