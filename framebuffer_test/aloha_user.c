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
	FB32_X_CARET = 0;
	FB32_Y_CARET = 200;
	uint32 color = 0x0000ffff;
	uint32 color_move = 0x00000000;
	uint32 back_color =0x00000000;

	print32_set_caret( print32_number( print32_strlen( string ), FB32_X_CARET, FB32_Y_CARET, color, back_color, 8, 8, 12, FONT_MONO_12PX_NUMBER ) );

	system32_sleep( 1000000 );

	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );

	system32_sleep( 1000000 );

	print32_set_caret( print32_string( string, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( string ), 8, 12, FONT_MONO_12PX_ASCII ) );

	system32_sleep( 1000000 );

	print32_set_caret( print32_string( string2, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( string2 ), 8, 12, FONT_MONO_12PX_ASCII ) );

	system32_sleep( 1000000 );

	print32_set_caret( print32_string( string3, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( string3 ), 8, 12, FONT_MONO_12PX_ASCII ) );

	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );

	system32_sleep( 1000000 );

	print32_set_caret( print32_number( FB32_DEPTH, FB32_X_CARET, FB32_Y_CARET, color, back_color, 8 , 8, 12, FONT_MONO_12PX_NUMBER ) );

	system32_sleep( 1000000 );

	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );

	system32_sleep( 1000000 );

	print32_set_caret( print32_number( FB32_SIZE, FB32_X_CARET, FB32_Y_CARET, color, back_color, 8, 8, 12, FONT_MONO_12PX_NUMBER ) );

	system32_sleep( 1000000 );

	fb32_draw_image( COLOR16_SAMPLE_IMAGE, 300, -4, 8, 12, 0, 0, 0, 0 );

	fb32_draw_image( COLOR16_SAMPLE_IMAGE, -4, 500, 8, 12, 0, 0, 0, 0 );

	fb32_draw_image( COLOR16_SAMPLE_IMAGE, 300, 632, 8, 12, 0, 0, 0, 0 );

	fb32_draw_image( COLOR16_SAMPLE_IMAGE, 400, 400, 8, 12, 5, 8, 0, 0 );

	fb32_clear_color_block( 0x0000FFFF, -300, 600, 600, 50 );

	fb32_clear_color_block( 0x0000FFFF, 700, -25, 600, 50 );

	fb32_clear_color_block( 0x0000FFFF, 700, 620, 50, 100 );

	system32_sleep( 1000000 );

	fb32_draw_line( COLOR16_WHITE, 0, 0, 300, 600, 2, 2 );

	fb32_draw_line( COLOR16_RED, 300, 100, 0, 0, 4, 4 );

	fb32_draw_line( COLOR16_GREEN, 400, 0, 0, 400, 5, 5 );

	fb32_draw_line( COLOR16_BLUE, 0, 300, 300, 0, 3, 3 );



	fb32_draw_line( COLOR16_CYAN, 100, 0, 100, 300, 4, 4 );

	fb32_draw_line( COLOR16_MAGENTA, 0, 400, 400, 400, 10, 10 );

	system32_sleep( 9000000 );

	while(1) {
		fb32_copy( SYSTEM32_RENDER_BUFFER );
		fb32_clear_color( color_move );
		color_move++;
		print32_number( FB32_ADDRESS, 500, 500, color, back_color, 8 , 8, 12, FONT_MONO_12PX_NUMBER );
		fb32_draw_image( SYSTEM32_RENDER_BUFFER, 0, 0, FB32_WIDTH, FB32_HEIGHT, 0, 10, 10, 0 );
		system32_sleep( 1000000 );
	}
}