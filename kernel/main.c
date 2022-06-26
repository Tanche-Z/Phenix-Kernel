#include <ph1nix/ph1nix.h>
#include <ph1nix/types.h>
#include <ph1nix/io.h>
#include <ph1nix/string.h>
#include <ph1nix/console.h>
#include <ph1nix/stdarg.h>

void test_args(int cnt, ...)
{
    va_list args;
    va_start(args, cnt);

    int arg;
    while (cnt--)
    {
        arg = va_arg(args, int);
    }
    
    va_end(args);
}

void _kernel_init()
{
    console_init();
    test_args(5, 1, 0xaa, 5, 0x55, 10);

    return;
}