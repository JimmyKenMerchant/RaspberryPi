#include "alohastd.h"

int alohamain()
{

	unsigned char string[] = "ALOHA!\0";
	unsigned long int x_coord = 200;
	unsigned long int y_coord = 100;
	unsigned long int color = 0x0000ffff;
	unsigned long int length = 6;

	print_string_ascii_8by8( string, x_coord, y_coord, color, length );

	while(1) {
		no_op();
	}
}