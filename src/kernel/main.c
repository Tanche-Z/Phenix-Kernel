#include <ph1nix/ph1nix.h>
#include <ph1nix/types.h>
#include <ph1nix/io.h>
#include <ph1nix/string.h>
#include <ph1nix/console.h>
#include <ph1nix/stdarg.h>


void _kernel_init()
{
    console_init();
    int cnt =30 ;
    while (cnt--)
    {
        printk("hello ph1nix %#010x\n", cnt);
    }

    return;
}