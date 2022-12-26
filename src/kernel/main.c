#include <ph1nix/ph1nix.h>
#include <ph1nix/types.h>
#include <ph1nix/io.h>
#include <ph1nix/string.h>
#include <ph1nix/console.h>
// #include <ph1nix/printk.h>
// #include <ph1nix/stdarg.h>

char msg[] = "hello ph1nix!!!!\n";
char buf[1024];

void _kernel_init()
{
    console_init();

    u32 cnt = 30;
    while (cnt --)
    {
        console_write(msg, sizeof(msg) - 1);
    }

    // int cnt = 30 ;
    // while (cnt--)
    // {
    //     printk("hello ph1nix %#010x\n", cnt);
    // }

    return;
}