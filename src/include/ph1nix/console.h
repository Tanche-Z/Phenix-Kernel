#ifndef _PH1NIX_CONSOLE_H
#define _PH1NIX_CONSOLE_H

#include <ph1nix/types.h>

void console_init();
void console_clear();
void console_write(char *buf, u32 count);

#endif