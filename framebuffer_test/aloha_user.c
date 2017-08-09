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

	uchar8 string[] = "ALOHA!\n\tHello World, Everyone!\0";
	uchar8 string2[] = "\nABCDEFGHIJKLMNOPQSTUVWXYZ\t\t\t\tabcdefghijklmnopqrstuvwxyz\0";
	uchar8 string3[] = "\t$@^~ABCDEFGHIJKLMNOPQSTUVWXYZ\t\t\t\tabcdefghijklmnopqrstuvwxyz\0";
	uchar8 newline[] = "\n\0";
	FB_X_CARET = 0;
	FB_Y_CARET = 200;
	uint32 color = 0x0000ffff;

	set_caret( print_number_8by8( strlen_ascii( string ), FB_X_CARET, FB_Y_CARET, color, 8 ) );

	set_caret( print_string_ascii_8by8( string, FB_X_CARET, FB_Y_CARET, color, strlen_ascii( string ) ) );

	set_caret( print_string_ascii_8by8( string2, FB_X_CARET, FB_Y_CARET, color, strlen_ascii( string2 ) ) );

	set_caret( print_string_ascii_8by8( string3, FB_X_CARET, FB_Y_CARET, color, strlen_ascii( string3 ) ) );

	set_caret( print_string_ascii_8by8( newline, FB_X_CARET, FB_Y_CARET, color, strlen_ascii( newline ) ) );

	set_caret( print_number_8by8( FB_DEPTH, FB_X_CARET, FB_Y_CARET, color, 8 ) );

	set_caret( print_string_ascii_8by8( newline, FB_X_CARET, FB_Y_CARET, color, strlen_ascii( newline ) ) );

	set_caret( print_number_8by8( FB_SIZE, FB_X_CARET, FB_Y_CARET, color, 8 ) );


	while(1) {
		no_op();
	}
}