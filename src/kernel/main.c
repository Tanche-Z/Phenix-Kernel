#include <ph1nix/ph1nix.h>
// #include <ph1nix/types.h>
// #include <ph1nix/io.h>
// #include <ph1nix/string.h>
// #include <ph1nix/console.h>
// #include <ph1nix/stdarg.h>


int magic = _PH1NIX_MAGIC;
char msg[] = "Hello ph1nix!!!";
char buf[1024];

void _kernel_init()
{
    char *video = (char *) 0xb8000;

    for (int i =0; i < sizeof (msg); i++)
    {
        video[i * 2] = msg [i];
    }

    // console_init();
    // int cnt =30 ;
    // while (cnt--)
    // {
    //     printk("hello ph1nix %#010x\n", cnt);
    // }

    return;
}