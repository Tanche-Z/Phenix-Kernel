#include <ph1nix/ph1nix.h>
#include <ph1nix/types.h>
// #include <ph1nix/io.h>
// #include <ph1nix/string.h>
#include <ph1nix/console.h>
#include <ph1nix/stdio.h>
// #include <ph1nix/printk.h>
#include <ph1nix/assert.h>

// char msg[] = "hello ph1nix!!!!\n";
// char buf[1024];

void _kernel_init()
{
    console_init();

    // int cnt = 30 ;
    // while (cnt--)
    // {
    //     printk("hello ph1nix %#010x\n", cnt);
    // }

    assert(3 < 5);
    // assert(3 > 5);
    panic("Out of ass!!!");

    return;
}