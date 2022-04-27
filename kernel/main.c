#include <ph1nix/ph1nix.h>

int magic = PH1NIX_MAGIC;
char message[] = "Hello Ph1nix!!!"; // This would be in .data
char buf[1024]; //This would be .bss 

void kernel_init()
{
    char *video = (char *) 0xb8000; // The memory location of text display
    for (int i = 0; i < sizeof(message); i++)
    {
        video[i * 2] = message[i];
    }
}