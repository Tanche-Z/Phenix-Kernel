#include <ph1nix/types.h>
// #include <ph1nix/printk.h>
#include <ph1nix/stdio.h>
#include <ph1nix/assert.h>

static u8 buf[1024];

// force blocking
static void spin(char *name)
{
    printk("\nSpinning in %s ...", name);
    while(true)
        ;
}

void assertion_failure(char *exp, char *file, char *base, int line)
{
    printk(
        "\n-->assert(%s) failed!!!\n"
        "--> file: %s \n"
        "--> base: %s \n"
        "--> line: %d \n",
        exp, file, base, line);

    spin("assertion_failure()");

    // cannot be here, otherwise Error occur
    asm volatile ("ud2");
}

void panic (const char *fmt, ...)
{
    va_list args;
    va_start (args, fmt);
    int i = vsprintf(buf, fmt, args);
    va_end(args);

    printk("\n!!! HOLY SHIT !!!\n!!! Fxxking Panic !!!\n\n-_- %s -_-", buf);
    spin("panic");

    // cannot be here, otherwise Error occur
    asm volatile ("ud2");
}
