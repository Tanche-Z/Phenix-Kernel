#include <ph1nix/console.h>
#include <ph1nix/io.h>

#define CRT_ADDR_REG 0x3D4 // CRT(6845) index register
#define CRT_DATA_REG 0x3D5 // CRT(6845) data register

#define CRT_START_ADDR_H 0xC // dispaly memory start (High)
#define CRT_START_ADDR_L 0xD // dispaly memory start (Low)
#define CRT_CURCOR_H 0xE     // cursor position (High)
#define CRT_CURCOR_L 0xF     // cursor position (Low)

#define MEM_BASE 0xB8000              // video card memory start
#define MEM_SIZE 0x4000               // video card memory size
#define MEM_END (MEM_BASE + MEM_SIZE) // video card memory end
#define WIDTH 80                      // row of text in one screen
#define HEIGHT 25                     // colume of text in one screen
#define ROW_SIZE (WIDTH * 2)          // number of Bytes in one row
#define SCR_SIZE (ROW_SIZE * HEIGHT)  // number of Bytes in one screen

#define ASCII_NUL 0x00
#define ASCII_ENQ 0x05
#define ASCII_BEL 0x07 // \a
#define ASCII_BS 0x08  // \b
#define ASCII_HT 0x09  // \t
#define ASCII_LF 0x0A  // \n
#define ASCII_VT 0x0B  // \v
#define ASCII_FF 0x0C  // \f
#define ASCII_CR 0x0D  // \r
#define ASCII_DEL 0x7F

static u32 screen; // start of current display
static u32 pos;    // start of current cursor position
static x, y;       // coordinate of current sursor

static u8 attr = 7;        // style of character
static u16 erase = 0x0720; // space with style

// get current start of display
static void get_screen()
{
    outb(CRT_ADDR_REG, CRT_START_ADDR_H); // start 8 bits high
    screen = inb (CRT_DATA_REG) << 8;
    outb(CRT_ADDR_REG, CRT_START_ADDR_L);
    screen |= inb (CRT_DATA_REG);

    screen <<= 1; // screen *= 2
    screen += MEM_BASE;
}

// set start of current display
static void set_screen()
{
    outb(CRT_ADDR_REG, CRT_START_ADDR_H); // start 8 bits high
    outb(CRT_DATA_REG, ((screen - MEM_BASE) >> 9) & 0xff);
    outb(CRT_ADDR_REG, CRT_START_ADDR_L);
    outb(CRT_DATA_REG, ((screen - MEM_BASE) >> 1) & 0xff);
}

void console_clear()
{
}

void console_write(char *buf, u32 count)
{
}

void console_init()
{
    // console_clear();
    screen = 80 * 2 + MEM_BASE;
    set_screen();
    get_screen();
}
