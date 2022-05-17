#include <ph1nix/ph1nix.h>
#include <ph1nix/types.h>
#include <ph1nix/io.h>
#include <ph1nix/string.h>

// #define CRT_ADDR_REG 0x3d4 // CRT adress regiter
// #define CRT_DATA_REG 0x3d5 // CRT data regiter

// #define CRT_CURSOR_H 0xe // the position of cursor (high)
// #define CRT_CURSOR_L 0xf // the position of cursor (low)
char message[] = "Hello ph1nix!^_^";
char buf[1024];

void _kernel_init()
{
    // outb(CRT_ADDR_REG, CRT_CURSOR_H);
    // u16 pos = inb(CRT_DATA_REG) << 8;
    // outb(CRT_ADDR_REG, CRT_CURSOR_L);
    // pos |= inb(CRT_DATA_REG);
    
    // outb(CRT_ADDR_REG, CRT_CURSOR_H);
    // outb(CRT_DATA_REG, 0);
    // outb(CRT_ADDR_REG, CRT_CURSOR_L);
    // outb(CRT_DATA_REG, 123);

    int res;
    res = strcmp(buf, message);
    strcpy(buf, message);
    res = strcmp(buf, message);
    strcat(buf, message);
    res = strcmp(buf, message);
    res = strlen(message);
    res = sizeof(message);

    char *ptr = strchr(message, '^');
    ptr = strrchr(message, '^');

    memset(buf, 0, sizeof(buf));
    res = memcmp(buf, message,sizeof(message));
    memcpy(buf, message,sizeof(message));
    res = memcmp(buf, message,sizeof(message));
    ptr = memchr(buf, '^', sizeof(message));

    return;
}