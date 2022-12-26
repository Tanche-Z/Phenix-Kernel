#include <ph1nix/string.h>

// string copy
char *strcpy(char *dest, const char *src)
{
    char *ptr = dest;
    while (true)
    {
        *ptr++ = *src;
        if (*src++ == _EOS)
            return dest;
    }
}

// string cat
char *strcat(char *dest, const char *src)
{
    char *ptr = dest;
    while (*ptr != _EOS)
    {
        ptr++;
    }
    while (true)
    {
        *ptr++ = *src;
        if (*src++ ==_EOS)
        {
            return dest;
        }
    }
}

// string length
size_t strlen(const char *str)
{
    char *ptr = (char *)str;
    while (*ptr != _EOS)
    {
        ptr++;
    }
    return ptr - str;
}

// string compare
int strcmp(const char *lhs, const char *rhs)
{
    while (*lhs == *rhs && *lhs != _EOS && *rhs !=_EOS)
    {
        lhs++;
        rhs++;
    }
    return *lhs < *rhs ? -1 : *lhs > *rhs; // if not less, return -1; if same, return 0, if greater, return 1
}

// find char (first (most left))
char *strchr(const char *str, int ch)
{
    char *ptr = (char *)str;
    while (true)
    {
        if (*ptr == ch)
        {
            return ptr;
        }
        if (*ptr++ == _EOS)
        {
            return _NULL;
        }
    }
}

// find char (last(most right)))
char *strrchr (const char *str, int ch) // return pointer to the last (most right) char in a string
{
    char *last = _NULL;
    char *ptr = (char *)str;
    while (true)
    {
        if (*ptr == ch)
        {
            last = ptr;
        }
        if (*ptr++ ==_EOS)
        {
            return last;
        }
    }
}
// memory content compare
int memcmp (const void *lhs, const void *rhs, size_t count)
{
    char *lptr = (char *) lhs;
    char *rptr = (char *) rhs;
    while (*lptr == *rptr && count-- > 0)
    {
        lptr++;
        rptr++;
    }
    return *lptr < *rptr ? -1 : *lptr > *rptr;
}

// set memory content to 'dest' with content of 'ch' for 'count'
void *memset(void *dest, int ch, size_t count)
{
    char *ptr = dest;
    while (count--)
    {
        *ptr++ = ch;
    }
    return dest;
}

// memory content copy
void *memcpy(void *dest, const void *src, size_t count)
{
    char *ptr = dest;
    while (count--)
    {
        *ptr++ = *((char *)(src++));
    }
    return dest;
}

// find first char in memory
void *memchr(const void *str, int ch, size_t count) // find char in a block of memory
{
    char *ptr = (char *) str;
    while (count--)
    {
        if (*ptr == ch)
        {
            return (void *) ptr;
        }
        ptr++;
    }
}