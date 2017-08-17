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
	uint32 color = COLOR32_WHITE;
	uint32 color_move = COLOR32_BLACK;
	uint32 back_color = COLOR32_BLACK;

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

	system32_convert_endianness( DATA_COLOR32_SAMPLE_IMAGE0, DATA_COLOR32_SAMPLE_IMAGE0_SIZE, 4 );

	fb32_rgba_to_argb( DATA_COLOR32_SAMPLE_IMAGE0, DATA_COLOR32_SAMPLE_IMAGE0_SIZE );

	fb32_draw_image( DATA_COLOR32_SAMPLE_IMAGE0, 500, 500, 64, 64, 0, 0, 0, 0 );

	//fb32_draw_image( COLOR32_SAMPLE_IMAGE, -4, 500, 8, 12, 0, 0, 0, 0 );

	//fb32_draw_image( COLOR32_SAMPLE_IMAGE, 300, 632, 8, 12, 0, 0, 0, 0 );

	//fb32_draw_image( COLOR32_SAMPLE_IMAGE, 400, 400, 8, 12, 5, 8, 0, 0 );

	fb32_clear_color_block( COLOR32_WHITE, -300, 600, 600, 50 );

	fb32_clear_color_block( COLOR32_WHITE, 700, -25, 600, 50 );

	fb32_clear_color_block( COLOR32_WHITE, 700, 620, 50, 100 );

	system32_sleep( 1000000 );

	fb32_draw_line( COLOR32_WHITE, 0, 0, 300, 600, 2, 2 );

	fb32_draw_line( COLOR32_RED, 300, 100, 0, 0, 4, 4 );

	fb32_draw_line( COLOR32_GREEN, 400, 0, 0, 400, 5, 5 );

	fb32_draw_line( COLOR32_BLUE, 0, 300, 300, 0, 3, 3 );


	fb32_draw_line( COLOR32_CYAN, 100, 0, 100, 300, 4, 4 );

	fb32_draw_line( COLOR32_RED, 0, 400, 400, 400, 20, 20 );

	system32_sleep( 9000000 );

	while(1) {
		fb32_copy( SYSTEM32_RENDER_BUFFER );
		color_move++;
		print32_number( FB32_ADDRESS, 500, 500, color, back_color, 8 , 8, 12, FONT_MONO_12PX_NUMBER );
		fb32_draw_image( SYSTEM32_RENDER_BUFFER, 0, 0, FB32_WIDTH, FB32_HEIGHT, 0, 10, 10, 0 );
		system32_sleep( 2000000 );
	}
}