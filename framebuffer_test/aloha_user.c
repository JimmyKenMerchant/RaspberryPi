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

void _user_start()
{

	char8 string[] = "ALOHA!\n\tHello World, Everyone!\0";
	char8 string2[] = "\nABCDEFGHIJKLMNOPQSTUVWXYZ\t\t\t\tabcdefghijklmnopqrstuvwxyz\0";
	char8 string3[] = "\t$@^~ABCDEFGHIJKLMNOPQSTUVWXYZ\t\t\t\tabcdefghijklmnopqrstuvwxyz\0";
	char8 newline[] = "\n\0";
	FB32_X_CARET = 0;
	FB32_Y_CARET = 200;
	uint32 color = COLOR32_WHITE;
	uint32 color_move = COLOR32_BLACK;
	uint32 back_color = COLOR32_BLACK;
	uint32 number = 0x1234ABCD;
	int32 number2 = 0x056789EF;
	int32 number3 = -0x056789EF;

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

	system32_convert_endianness( DATA_COLOR32_SAMPLE_IMAGE0, DATA_COLOR32_SAMPLE_IMAGE0_SIZE, 4 );
	fb32_rgba_to_argb( DATA_COLOR32_SAMPLE_IMAGE0, DATA_COLOR32_SAMPLE_IMAGE0_SIZE );
	fb32_draw_image( DATA_COLOR32_SAMPLE_IMAGE0, 500, 500, 64, 64, 0, 0, 0, 0 );

	system32_convert_endianness( DATA_COLOR32_SAMPLE_IMAGE1, DATA_COLOR32_SAMPLE_IMAGE1_SIZE, 4 );
	fb32_rgba_to_argb( DATA_COLOR32_SAMPLE_IMAGE1, DATA_COLOR32_SAMPLE_IMAGE1_SIZE );
	fb32_draw_image( DATA_COLOR32_SAMPLE_IMAGE1, 500, 500, 64, 64, 0, 0, 0, 0 );

	char8* num_string = math32_int32_to_string_hexa( number, 8, 0, 1 );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_number( (uint32)num_string, FB32_X_CARET, FB32_Y_CARET, color, back_color, 8, 8, 12, FONT_MONO_12PX_NUMBER ) );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( num_string, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( num_string ), 8, 12, FONT_MONO_12PX_ASCII ) );

	char8* num_string3 = math32_int32_to_string_hexa( number3, 6, 1, 0 );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( num_string3, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( num_string3 ), 8, 12, FONT_MONO_12PX_ASCII ) );

	char8* num_string2 = math32_int32_to_string_hexa( number2, 6, 1, 1 );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( num_string2, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( num_string2 ), 8, 12, FONT_MONO_12PX_ASCII ) );

	char8* num_cat = print32_strcat( num_string, num_string2 );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( num_cat, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( num_cat ), 8, 12, FONT_MONO_12PX_ASCII ) );

	//fb32_draw_image( COLOR32_SAMPLE_IMAGE, -4, 500, 8, 12, 0, 0, 0, 0 );
	//fb32_draw_image( COLOR32_SAMPLE_IMAGE, 300, 632, 8, 12, 0, 0, 0, 0 );
	//fb32_draw_image( COLOR32_SAMPLE_IMAGE, 400, 400, 8, 12, 5, 8, 0, 0 );

	fb32_clear_color_block( COLOR32_WHITE, -300, 600, 600, 50 );
	fb32_clear_color_block( COLOR32_WHITE, 700, -25, 600, 50 );
	fb32_clear_color_block( COLOR32_WHITE, 700, 620, 50, 100 );

	system32_sleep( 1000000 );

	fb32_draw_line( COLOR32_WHITE, 0, 0, 300, 600, 1, 1 );
	fb32_draw_line( COLOR32_RED, 300, 100, 0, 0, 4, 4 );
	fb32_draw_line( COLOR32_GREEN, 400, 0, 0, 400, 5, 5 );
	fb32_draw_line( COLOR32_BLUE, 0, 300, 300, 0, 3, 3 );
	fb32_draw_line( COLOR32_CYAN, 100, 0, 100, 300, 4, 4 );
	fb32_draw_line( COLOR32_RED, 0, 400, 300, 400, 20, 20 );
	fb32_draw_line( COLOR32_RED, 0, 400, 300, 500, 20, 20 );

	//fb32_draw_circle( COLOR32_GREEN, 300, 300, 150, 200 );
	//fb32_draw_circle( COLOR32_WHITE, -100, 500, 200, 175 );

	system32_sleep( 9000000 );

	int32* renderbuffer0 = (int32*)system32_load_32( FB32_RENDERBUFFER0 );

	//print32_set_caret( print32_number( (uint32)renderbuffer0, FB32_X_CARET, FB32_Y_CARET, color, back_color, 8 , 8, 12, FONT_MONO_12PX_NUMBER ) );

	fb32_copy( FB32_FRAMEBUFFER, FB32_RENDERBUFFER0 );
	uint32 renderbuffer0_width = system32_load_32(FB32_RENDERBUFFER0 + 1 ); // 4 bytes offset
	uint32 renderbuffer0_height = system32_load_32(FB32_RENDERBUFFER0 + 2 ); // 8 bytes offset
	
	while(1) {
		fb32_copy( FB32_FRAMEBUFFER, FB32_RENDERBUFFER0 );
		color_move++;
		print32_number( FB32_ADDRESS, 500, 500, color, back_color, 8 , 8, 12, FONT_MONO_12PX_NUMBER );
		fb32_draw_image( renderbuffer0, 0, 0, renderbuffer0_width, renderbuffer0_height, 0, 10, 10, 0 );
		system32_sleep( 2000000 );
	}
}