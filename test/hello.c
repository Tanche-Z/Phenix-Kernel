#include <stdio.h>

char hello[] = "Hello World!!!\n";
char buf [1024]; //.bss

int main()
{
    printf(hello);
    return 0;
}