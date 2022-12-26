/* vsprintf.c -- From Linux Kernel Tree */
/* Modified in Onix by StevenBaby */

// Wirzenius wrote this portably. Torvalds fucked it up :-)

#include <ph1nix/stdarg.h>
#include <ph1nix/string.h>

#define ZEROPAD 1 // padding zero
#define SIGN 2 // unsigned/signed long
#define PLUS 4 // display pluse
#define SPACE 8 // if is pluse, put space
#define LEFT 16 // justify to left
#define SPECIAL 32 // 0x
#define SMALL 64 // use lower case

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
    const char *digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    int i;
    int index;
    char *ptr = str;

    // if flags indicate to use lowercase, define the lowercases
    if (flags & SMALL)
        digits = "0123456789abcdefghijklmnopqrstuvwxyz";

    // if flags indicate to left justifying, shield the flags of ZEROPAD
    if (flags & LEFT)
        flags &= ~ZEROPAD;

    // if scale number less than 2 or greater than 36, then leave
    if (base < 2 || base > 36)
        return 0;

    // if flags indicate to padding zero, then put string variable 'c' to 0, otherwise put space
    c = (flags & ZEROPAD) ? '0' : ' ';

    // if flags indicates it's a signed number which also less than 0
    // then put symbol variable as negative sign and take the absolute value of 'num'
    if (flags & SIGN && num <0)
    {
        sign = '-';
        num = - num;
    }
    else // if the flags indicate positive, put sign as pluse symbol. Or if the format has `space` sign, put space sign, otherwise put 0.
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

    i = 0;
    // if the value of num is 0, put temporary string ='0'. Otherwize use given base tranform num into string format.
    if (num ==0)
        tmp[i++] = '0';
    else
        while  (num != 0)
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
    while (size-- > 0)
        *str++ = ' ';

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
        // each ordianry char which are NOT `format indicating string` would be put into str one by one in order
        if (*fmt != '%')
        {
            *str++ = *fmt;
            continue;
        }

        // finding FLAGS
        // get the the `sign` part from `format indicating string, and put const `sign` into variable `flags`
        flags = 0;
    repeat:
        // jump off 1st `%`
        ++fmt;
        switch (*fmt)
        {
        case '-':
            flags |= LEFT;
            goto repeat;
        case '+':
            flags |= PLUS;
            goto repeat;
        case ' ':
            flags |= SPACE;
            goto repeat;
        case '#':
            flags |= SPECIAL;
            goto repeat;
        case '0':
            flags |= ZEROPAD;
            goto repeat;
        }
        
        // finding width
        // get `width` part current parameter, and put into variable `feild_width`
        field_width = -1;

        // if the `width` part is number, then get the value as width
        if (is_digit(*fmt))
            field_width = skip_atoi(&fmt);
        
        // if is `*`, then the next parameter indicating width
        else if (*fmt == '*')
        {
            ++fmt;
            field_width = va_arg(args, int);

            if (field_width < 0)
            {
                // absolute value and put flag
                field_width = -field_width;
                flags |= LEFT;
            }
        }

        // finding precision
        precision = -1;
        // if the sign is `.`
        if (*fmt == '.')
        {
            ++fmt;
            if (is_digit(*fmt))
                precision = skip_atoi(&fmt);
        
            // if is `*`, then the next parameter indicating width
            else if (*fmt == '*')
            {
                precision = va_arg(args, int);
            }

            if (precision < 0)
                precision = 0;
        }

        qualifier = -1;
        if (*fmt == 'h' || *fmt == 'l' || *fmt == 'L')
        {
            qualifier = *fmt;
            ++fmt;
        }

        switch (*fmt)
        {
            // char
            case 'c':
                if (!(flags & LEFT))
                    while (--field_width > 0)
                        *str++ = ' ';
                *str++ = (unsigned char)va_arg(args, int);
                while (--field_width > 0)
                    *str++ = ' ';
                break;

            // string
            case 's':
                s = va_arg(args, char *);
                len = strlen(s);
                if (precision < 0)
                    precision = len;
                else if (len > precision)
                    len = precision;
                // if flags is not left padding
                if (!(flags & LEFT))
                    while (len < field_width--)
                        *str++ = ' ';
                for (int i = 0; i < len; ++i)
                    *str++ = *s++;
                while (len < field_width --)
                    *str++ = ' ';
                break;
            
            // octal
            case 'o':
                str = number(str, va_arg(args, unsigned long), 8, field_width, precision, flags);
                break;

            // pointer
            case 'p':
                if (field_width == -1)
                {
                    field_width = 8;
                    flags |= ZEROPAD;
                }
                str = number(str, (unsigned long)va_arg(args, void *), 16, field_width, precision, flags);
                break;

            // hex, `x` using lower case, `X` using upper case
            case 'x':
                flags |= SMALL;
            case 'X':
                str = number(str, va_arg(args, unsigned long), 16, field_width, precision, flags);
                break;

            // signed int
            case 'd':
            case 'i':
                flags |= SIGN;
            // unsigned int
            case 'u':
                str = number(str, va_arg(args, unsigned long), 10, field_width, precision, flags);
                break;
            
            case 'n':
                ip = va_arg(args, int *);
                *ip = (str - buf);
                break;

            default:
                if (*fmt != '%')
                    *str++ = '%'; // error, put a `%` into output string
                if (*fmt)
                    *str++ = *fmt;
                else
                    // procced to the end of string, break from loop
                    --fmt;
                break;
        }
    }
    // put end symbol at the proccessed string
    *str = '\0';

    // return the length of preccessed string
    return str - buf;
}

int sprintf(char *buf, const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    int i = vsprintf(buf, fmt, args);
    va_end(args);
    return i;
}
