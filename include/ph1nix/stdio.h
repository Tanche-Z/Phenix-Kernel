#ifndef PH1NIX_STDIO_H
#define PH1NIX_STDIO_H

#include <ph1nix/stdarg.h>

int vsprintf(char *buf, const char *fmt, va_list args);
int sprintf(char *buf, const char *fmt, ...);

#endif