#ifndef PH1NIX_STD_ARG_H
#define PH1NIX_STD_ARG_H

// #include <ph1nix/types.h>

typedef char *va_list;


#define va_start(ap,v) (ap = (va_list)&v + sizeof(char *))
#define va_arg(ap, t) (*(t *)((ap += sizeof(char *)) - sizeof(char *)))
// #define va_end(ap) (ap = (va_list)_NULL)
#define va_end(ap) (ap = (va_list)0)

#endif 