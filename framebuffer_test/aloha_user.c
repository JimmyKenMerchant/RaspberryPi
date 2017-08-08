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

	uchar8 string[] = "ALOHA!\nHello World, Everyone!\0";
	FB_X_CARET = 80;
	FB_Y_CARET = 200;
	uint64 print_return;
	uint32 color = 0x0000ffff;
	uint32 length = strlen_ascii( string ); // string length - 1 (Null)

	print_return = print_number_8by8( length, FB_X_CARET, FB_Y_CARET, color, 8 );
	set_caret( print_return );

	print_return = print_string_ascii_8by8( string, FB_X_CARET, FB_Y_CARET, color, length );
	set_caret( print_return );

	print_return = double_print_number_8by8( print_return, FB_X_CARET, FB_Y_CARET, color, 16 );
	set_caret( print_return );

	print_return = print_number_8by8( FB_DEPTH, FB_X_CARET, FB_Y_CARET, color, 8 );
	set_caret( print_return );

	print_return = print_number_8by8( FB_SIZE, FB_X_CARET, FB_Y_CARET, color, 8 );
	set_caret( print_return );

	while(1) {
		no_op();
	}
}