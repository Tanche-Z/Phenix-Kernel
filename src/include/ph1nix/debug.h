#ifndef PH1NIX_DEBUG_H
#define PH1NIX_DEBUG_H

void debugk(char *file, int line, const char *fmt, ...);

#define BMB asm volatile("xchgw %bx, %bx") // for bochs magic breakpoint
#define DEBUGK(fmt, args...) debugk(__BASE_FILE__, __LINE__, fmt, ##args);

#endif