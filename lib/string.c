#include <ph1nix/string.h>

char *strcp(char *dest, const char *src)
{
    char *ptr = dest;
    while (true)
    {
        *ptr++ = *src;
        if (*src++ == _EOS)
            return dest;
    }
}

