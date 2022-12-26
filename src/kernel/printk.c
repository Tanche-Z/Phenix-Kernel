#include <ph1nix/stdarg.h>
#include <ph1nix/console.h>
#include <ph1nix/stdio.h>

// buffer for storing ouput string
static char buf[1024];

int printk (const char *fmt, ...)
{
    // var args
    va_list args;
    int i;

    va_start(args, fmt);

    i = vsprintf(buf, fmt, args);

    va_end(args);

    console_write(buf, i);

    return i;
}
