/**
 * user32.c
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

#include "system32.h"

void _user_start()
{

	char8 string1[] = "ALOHA!\n\tHello World, Everyone!\0";
	char8 string2[] = "Konnichiwa!\n\tSekai No Minasan!\0";
	char8 newline[] = "\n\0";
	FB32_X_CARET = 0;
	FB32_Y_CARET = 200;
	uint32 color = COLOR32_WHITE;
	uint32 back_color = COLOR32_BLACK;
	uint32 clear_color = COLOR32_NAVYBLUE;
	float32 start_radian = math32_degree_to_radian32( -180 );
	float32 end_radian = math32_degree_to_radian32( 179 );

	print32_set_caret( print32_string( string1, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( string1 ), 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( string2, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( string2 ), 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );

	char8 char_key = 0x56; // "V"

	int32 search_char = print32_charindex( string1, char_key );

	int32 search_string = print32_strindex( string1, "HA!" );

	char8* copy_string1 = (char8*)system32_malloc(7); // 28 Bytes

	copy_string1[0] = 0x56; // "V"
	copy_string1[1] = 0x57; // "W"
	copy_string1[2] = 0x58; // "X"
	copy_string1[3] = 0x59; // "Y"
	copy_string1[4] = 0x5A; // "Z"
	copy_string1[5] = 0x0; // "\0"

	char8* copy_string2 = (char8*)system32_malloc(7); // 28 Bytes

	int32* error = system32_mcopy( (int32*)copy_string2, (int32*)copy_string1, 1, 3);

	print32_set_caret( print32_number( (uint32)search_char, FB32_X_CARET, FB32_Y_CARET, color, back_color, 8, 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );

	print32_set_caret( print32_number( (uint32)search_string, FB32_X_CARET, FB32_Y_CARET, color, back_color, 8, 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );

	print32_set_caret( print32_string( copy_string1, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( copy_string1 ), 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );

	print32_set_caret( print32_string( copy_string2, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( copy_string2 ), 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );

	print32_set_caret( print32_number( (uint32)error, FB32_X_CARET, FB32_Y_CARET, color, back_color, 8, 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );

	system32_mfree( (int32*)copy_string1 );

	system32_mfree( (int32*)copy_string2 );

	system32_sleep( 10000000 );

	system32_convert_endianness( DATA_COLOR32_SAMPLE_IMAGE0, DATA_COLOR32_SAMPLE_IMAGE0_SIZE, 4 );
	draw32_rgba_to_argb( DATA_COLOR32_SAMPLE_IMAGE0, DATA_COLOR32_SAMPLE_IMAGE0_SIZE );
	draw32_change_alpha_argb( DATA_COLOR32_SAMPLE_IMAGE0, DATA_COLOR32_SAMPLE_IMAGE0_SIZE, 0x99 );

	system32_convert_endianness( DATA_COLOR32_SAMPLE_IMAGE1, DATA_COLOR32_SAMPLE_IMAGE1_SIZE, 4 );
	draw32_rgba_to_argb( DATA_COLOR32_SAMPLE_IMAGE1, DATA_COLOR32_SAMPLE_IMAGE1_SIZE );
	
	while(1) {
		fb32_clear_color( clear_color );
		fb32_draw_line( COLOR32_BLUE, -50, 800, 100, 100, 20, 20 );
		fb32_draw_circle( COLOR32_CYAN, -100, 500, 200, 175 );
		fb32_draw_arc( COLOR32_WHITE, 500, 200, 500, 100, start_radian, end_radian, 10, 1 );
		fb32_draw_image( DATA_COLOR32_SAMPLE_IMAGE0, 400, 500, 64, 64, 0, 0, 0, 0 );
		fb32_draw_image( DATA_COLOR32_SAMPLE_IMAGE1, 500, 500, 64, 64, 0, 0, 0, 0 );
		clear_color = clear_color + 20;
		system32_sleep( 2000000 );
	}
}