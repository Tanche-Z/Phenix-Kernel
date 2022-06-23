#include <ph1nix/ph1nix.h>
#include <ph1nix/types.h>
#include <ph1nix/io.h>
#include <ph1nix/string.h>
#include <ph1nix/console.h>

char message[] = "hello ph1nix!!!\n";
char buf[1024];

void _kernel_init()
{
    console_init();

    while (true)
    {
        console_write(message, sizeof(message) - 1);
    }

    return;
}