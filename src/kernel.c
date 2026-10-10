#define VIDEO_MEMORY 0xb8000
#define WHITE_ON_BLACK 0x0F

void clear_screen(void);
void print(char* message, unsigned int line);

void k_main(void)
{
    clear_screen();
    print("This is line 1\n This is a second line", 0);
}

void clear_screen(void)
{
    char* vidmem = (char *) VIDEO_MEMORY;
	unsigned int i=0;
	while(i < (80*25*2))
	{
		vidmem[i]=' ';
		i++;
		vidmem[i]= WHITE_ON_BLACK;
		i++;
	};
}

void print(char* message, unsigned int line)
{
    char* vidmem = (char *) VIDEO_MEMORY;

    unsigned int i=0;

    i = (line*80*2);

    while(*message != 0)
    {
        if(*message == '\n')
        {
            line++;
            i = (line*80*2);
            message++;
        }
        else
        {
            vidmem[i] = *message;
            message++;
            i++;
            vidmem[i] = WHITE_ON_BLACK;
            i++;
        }
    }
}