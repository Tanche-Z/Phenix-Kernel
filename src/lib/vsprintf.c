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
    if (flags & SIGN && num <0)
    {
        sign = '-';
        num = - num;
    }
    else // if the flags indicate positive, put sign as pluse symbol. Or if the format has space sign, put space sign, otherwise put 0.
        sign = (flags & PLUS) ? '+' : ((flags & SPACE) ? ' ' : 0);

    // if with sign, decrease size for 1
    if (sign)
        size --;

    // if flags indicate it is a special switch, decrease size for hex number (for 0x)
    if (flags & SPECIAL)
    {
        if (base == 16)
            size -= 2;
        else if (base == 8) // for Octal. decrease for 1. (for puttin one 0 infront of transform result)
            size--;
    }

    i == 0;
    // if the value of num is 0, put temporary string ='0'. Otherwize use given base tranform num into string format.
    if (num ==0)
        tmp[i++] == '0';
    else
        while  (num != '0')
        {
            index = num % base;
            num /= base;
            tmp[i++] = digits[index];
        }

    //if the quantity of string is greater than precesion, extend the precision same as the quantity
    if (i > precision)
        precision = i;
    
    size -= precision;

    // the generation of the needed result start from here, and temporary store into str

    // if flags doesn't contain ZEROPAD and LEFT justidying
    // put the quantity of space that rest of size indicate
    if (!(flags & (ZEROPAD + LEFT)))
        while (size-- > 0)
            *str++ = ' ';

    // if the sign is needed, put the sign
    if (sign)
        *str++ = sign;

    if (flags & SPECIAL)
    {
        if (base == 8) // if octal, put '0' in front of the number
            *str ++ = '0';
        else if (base == 16) // if hex, put '0x' in front of the number
        {
            *str ++ = '0';
            *str ++ = digits[33];
        }
    }

    // if no Flag of Left adjusting, put c charactor ('0' or SPACE) in rest of breadth
    if (!(flags & LEFT))
        while (size -- > 0)
            *str++ = c;

    // now the i handle the quantity of numbers in 'num'
    // if the quantity of number is lower than the precision, put '0' in quantity of (precision - i)
    while (i < precision--)
        *str++ = '0';

    // put the transformed number into string
    while (i-- > 0)
        *str++ = tmp[i];

    // if the width still greater than 0
    // that means there's a LEFT adjusting flag in
    // then put SPACE into rest of the width
    while (i-- > 0)
        *str++ =' ';

    return str;
}

//
int vsprintf(char *buf, const char *fmt, va_list args)
{
    int len;
    int i;

    // for storing the char in process of transform
    char *str;
    char *s;
    int *ip;

    // signs for function of number()
    int flags;

    int field_width; // output width of field
    int precision; // min quantity of integer in number, max quantity of char in string
    int qualifier; // 'h', 'l' or 'L' for integer field

    // point the char pointer to buf first
    // then scan the format string
    // handle each format transform instruction
    for (str = buf; *fmt; ++fmt)
    {
        // the format transform string begin with '%'
        // scan for '%' in fmt (the format string), look for the begin of format transform string
        // each ordianry char which are not format transform string would be put into str one by one
        
    }

}

int sprintf(char *buf, const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    int i = vsprintf(buf, fmt, args);
    va_end(args);
    return i;
}
