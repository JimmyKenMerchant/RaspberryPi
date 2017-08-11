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
	uint32 back_color =0x00000000;

	set_caret( print_number( strlen( string ), FB_X_CARET, FB_Y_CARET, color, back_color, 8, 8, 12, FONT_MONO_12PX_NUMBER ) );

	set_caret( print_string( newline, FB_X_CARET, FB_Y_CARET, color, back_color, strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );

	set_caret( print_string( string, FB_X_CARET, FB_Y_CARET, color, back_color, strlen( string ), 8, 12, FONT_MONO_12PX_ASCII ) );

	set_caret( print_string( string2, FB_X_CARET, FB_Y_CARET, color, back_color, strlen( string2 ), 8, 12, FONT_MONO_12PX_ASCII ) );

	set_caret( print_string( string3, FB_X_CARET, FB_Y_CARET, color, back_color, strlen( string3 ), 8, 12, FONT_MONO_12PX_ASCII ) );

	set_caret( print_string( newline, FB_X_CARET, FB_Y_CARET, color, back_color, strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );

	set_caret( print_number( FB_DEPTH, FB_X_CARET, FB_Y_CARET, color, back_color, 8 , 8, 12, FONT_MONO_12PX_NUMBER ) );

	set_caret( print_string( newline, FB_X_CARET, FB_Y_CARET, color, back_color, strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );

	set_caret( print_number( FB_SIZE, FB_X_CARET, FB_Y_CARET, color, back_color, 8, 8, 12, FONT_MONO_12PX_NUMBER ) );


	while(1) {
		no_op();
	}
}