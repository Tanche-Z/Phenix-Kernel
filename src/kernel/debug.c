#include <ph1nix/debug.h>
#include <ph1nix/stdarg.h>
#include <ph1nix/stdio.h>
#include <ph1nix/printk.h>

static char buf[1024];

void debugk( char *file, int line, const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    vsprintf(buf, fmt, args);
    printk("[%s] [%d] %s", file, line, buf);
}