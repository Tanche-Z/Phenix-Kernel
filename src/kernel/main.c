#include <ph1nix/ph1nix.h>
#include <ph1nix/types.h>
// #include <ph1nix/io.h>
// #include <ph1nix/string.h>
#include <ph1nix/console.h>
#include <ph1nix/stdio.h>
// #include <ph1nix/printk.h>
#include <ph1nix/assert.h>
#include <ph1nix/debug.h>

// char msg[] = "hello ph1nix!!!!\n";
// char buf[1024];

void _kernel_init()
{
    // console_init();

    BMB;

    DEBUGK("debug ph1nix!!!\n");

    return;
}