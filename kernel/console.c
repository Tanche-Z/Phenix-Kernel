#include <ph1nix/console.h>
#include <ph1nix/io.h>

#define CRT_ADDR_REG 0x3D4 // CRT(6845) index register
#define CRT_DATA_REG 0x3D5 // CRT(6845) data register

#define CRT_START_ADDR_H 0xC // dispaly memory start (High)
#define CRT_START_ADDR_L 0xD // dispaly memory start (Low)
#define CRT_CURSOR_H 0xE     // cursor position (High)
#define CRT_CURSOR_L 0xF     // cursor position (Low)

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

static u32 screen_base; // start of current display
static u32 cursor_base; // start of current cursor position
static x, y;            // coordinate of current sursor

static u8 attr = 7;        // style of character
static u16 erase = 0x0720; // space with style


// get current start of display
static void get_screen()
{
    outb(CRT_ADDR_REG, CRT_START_ADDR_H);
    screen_base = inb(CRT_DATA_REG) << 8;
    outb(CRT_ADDR_REG, CRT_START_ADDR_L);
    screen_base |= inb(CRT_DATA_REG);

    screen_base <<= 1; // screen *= 2
    screen_base += MEM_BASE;
}

// set start of current creen base address
static void set_screen()
{
    outb(CRT_ADDR_REG, CRT_START_ADDR_H); // start 8 bits high
    outb(CRT_DATA_REG, ((screen_base - MEM_BASE) >> 9) & 0xff);
    outb(CRT_ADDR_REG, CRT_START_ADDR_L);
    outb(CRT_DATA_REG, ((screen_base - MEM_BASE) >> 1) & 0xff);
}

// get current cursor position
static void get_cursor()
{
    outb(CRT_ADDR_REG, CRT_CURSOR_H);
    cursor_base = inb(CRT_DATA_REG) << 8;
    outb(CRT_ADDR_REG, CRT_CURSOR_L);
    cursor_base |= inb(CRT_DATA_REG);

    get_screen();

    cursor_base <<= 1; // pos *= 2
    cursor_base += MEM_BASE;

    u32 delta = (cursor_base - screen_base) >> 1;
    x = delta % WIDTH;
    y = delta / WIDTH;
}

static void set_cursor()
{
    outb(CRT_ADDR_REG, CRT_CURSOR_H); // cursor high address
    outb(CRT_DATA_REG, ((cursor_base - MEM_BASE) >> 9) & 0xff);
    outb(CRT_ADDR_REG, CRT_CURSOR_L);
    outb(CRT_DATA_REG, ((cursor_base - MEM_BASE) >> 1) & 0xff);
}


static void command_del()
{
    *(u16 *)cursor_base = erase;
}

static void command_cr()
{
    cursor_base -= (x << 1);
    x = 0;
}

static void scroll_up()
{
    if (screen_base + SCR_SIZE + ROW_SIZE <= MEM_END)
    {
        u32 *ptr = (u32 *)(screen_base + SCR_SIZE);
        for (size_t i = 0; i < WIDTH; i++)
        {
            *ptr++ = erase;
        }

        screen_base += ROW_SIZE;
        y++;
        cursor_base += ROW_SIZE;
    }

    set_screen();
}

static void command_lf()
{
    if (y + 1 < HEIGHT)
    {
        y++;
        cursor_base += ROW_SIZE;
        return;
    }

    scroll_up();
}

static void command_bs()
{
    if (x)
    {
        x--;
        cursor_base -= 2;
        //*(u16 *)cursor_base = erase;
        command_del();
    }
}


void console_write(char *buf, u32 count)
{
    char ch;
    while (count--)
    {
        ch = *buf++;
        switch (ch)
        {
        case ASCII_NUL:
            break;
        case ASCII_BEL:
            // todo \a
            break;
        case ASCII_BS:
            command_bs();
            break;
        case ASCII_HT:
            break;
        case ASCII_LF:
            command_lf();
            command_cr();
            break;
        case ASCII_VT:
            break;
        case ASCII_FF:
            command_lf();
            break;
        case ASCII_CR:
            command_cr();
            break;
        case ASCII_DEL:
            command_del();
            break;
        default:
            if (x >= WIDTH)
            {
                x -= WIDTH;
                cursor_base -= ROW_SIZE;
                command_lf();
            }

            *((char *)cursor_base) = ch;
            cursor_base++;
            *((char *)cursor_base) = attr;
            cursor_base++;

            x++;
            break;
        }
        set_cursor();
    }
}


void console_clear()
{
    screen_base = MEM_BASE;
    cursor_base = MEM_BASE;
    x = y = 0;
    set_cursor();
    set_screen();

    u16 *ptr = (u16 *)MEM_BASE;
    while (ptr < MEM_END)
    {
        *ptr++ = erase;
    }
}

void console_init()
{
    console_clear();
}
