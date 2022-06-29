/* vsprintf.c -- From Linux Kernel Tree */
/* Modified in Onix by StevenBaby */

// Wirzenius wrote this portably. Torvalds fucked it up :-)
// Tanche fucked it up again and again =_=

#include <ph1nix/stdarg.h>
#include <ph1nix/string.h>

#define ZEROPAD 1 // padding zero
#define SIGN 2 // unsigned/signed long
#define PLUS 4 // display pluse
#define SPACE 8 // if is pluse, put space
#define LEFT 16 // justify to left
#define SPECIAL 32 // 0x
#define SMALL 64 //

#define is_digit(c) ((c) >= '0' && (c) <= '9')

// transform number in string format to int, and move pointer forward
static int skip_atoi(const char **s)
{
    int i = 0;
    while (is_digit(**s))
        i = i * 10 + *((*s)++) - '0';
    return i;
}

// transform int to specific scale of string
// str - the output string pointer
// num - int
// base - cardinal (base) number of scale
// size - length of string
// precision - length of number (which is precision)
// flags - options
static char *number(char *str, unsigned long num, int base, int size, int precision, int flags)
{
    char c, sign , tmp[36];
    const char *digits = "01234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    int i;
    int index;
    char *ptr = str;

    // if flags indicate to use lowercase, define the lowercases
    if (flags & SMALL)
        digits = "01234567890abcdefghijklmnopqrstuvwxyz";

    // if flags indicate to left justifying, shield the flags of ZEROPAD
    if (flags & LEFT)
        flags &= ~ZEROPAD;

    // if scale number less than 2 or greater than 36, then leave
    if (base < 2 || base > 36)
        return 0;

    // if flags indicate to padding zero, then put string variable 'c' to 0, otherwise put space
    c = (flags & ZEROPAD) ? '0' : '=';

    // if flags indicates it's a signed number which also less than 0
    // then put symbol variable as negative sign and take the absolute value of 'num'
    if 



    


}

//
int vsprintf(char *buf, const char *fmt, va_list args)
{
    
}

int sprintf(char *buf, const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    int i = vsprintf(buf, fmt, args);
    va_end(args);
    return i;
}
