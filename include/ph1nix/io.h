#ifndef PH1NIX_IO_H
#define PH1NIX_IO_H

#include <ph1nix/types.h>

extern u8 inb(u16 port); // intput a byte
extern u16 inw(u16 port); // input a word

extern void outb(u16 port, u8 value); // output a byte
extern void outw(u16 port, u16 value); // output a word

#endif