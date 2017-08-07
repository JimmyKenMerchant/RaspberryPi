/**
 * aloha_user.c
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 * This Program is tested by Raspberry Pi 2 Model B V1.1 whose CPU is BCM2836, Coretex-A7 MPCore (ARMv7-A).
 */

#include "aloha/system32.h"

void user_start()
{

	unsigned char string[] = "ALOHA!\nHello, World Everyone!\0";
	uint32 x_coord = 80;
	uint32 y_coord = 200;
	uint32 color = 0x0000ffff;
	uint32 length = 30; // string length - 1 (Null)

	uint64 number = print_string_ascii_8by8( string, x_coord, y_coord, color, length );

	x_coord = 80;
	y_coord = 216;
	length = 16;

	double_print_number_8by8( number, x_coord, y_coord, color, length );

	while(1) {
		no_op();
	}
}