/**
 * user32.c
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

#include "system32.h"
#include "system32.c"

void _user_start()
{

	String string = "ALOHA!\n\tHello World, Everyone!\0";
	String newline = "\n\0";
	uint32 color = COLOR32_WHITE;
	uint32 back_color = COLOR32_BLACK;
	uint32 number = 0x80000000;
	int32 number2 = 0x056789EF;
	int32 number3 = -0x056789EF;
	float32 float_number1 = -12.75;
	float32 float_number2 = 0.024;
	float32 float_number3 = 100000000000000.024;
	float32 start_radian = math32_degree_to_radian32( -180 );
	float32 end_radian = math32_degree_to_radian32( 180 );
	float32 start_sin = math32_sin32( start_radian );
	float32 end_sin = math32_sin32( end_radian );
	uchar8 random = _random( 127 );

	ObjArray renderbuffer = (ObjArray)heap32_malloc( 6 );

	renderbuffer[0] = (obj)heap32_malloc( draw32_renderbuffer );
	draw32_renderbuffer_init( renderbuffer[0], FB32_WIDTH, FB32_HEIGHT, FB32_DEPTH );
	renderbuffer[1] = (obj)heap32_malloc( draw32_renderbuffer );
	draw32_renderbuffer_init( renderbuffer[1], FB32_WIDTH, FB32_HEIGHT, FB32_DEPTH );
	renderbuffer[2] = (obj)heap32_malloc( draw32_renderbuffer );
	draw32_renderbuffer_init( renderbuffer[2], 300, 300, 32 );
	renderbuffer[3] = (obj)heap32_malloc( draw32_renderbuffer );
	draw32_renderbuffer_init( renderbuffer[3], 300, 300, 32 );
	renderbuffer[4] = (obj)heap32_malloc( draw32_renderbuffer );
	draw32_renderbuffer_init( renderbuffer[4], FB32_WIDTH, FB32_HEIGHT, FB32_DEPTH );
	renderbuffer[5] = (obj)heap32_malloc( draw32_renderbuffer );
	draw32_renderbuffer_init( renderbuffer[5], 300, 300, 32 );

	_attach_buffer( renderbuffer[0] );
	fb32_clear_color( COLOR32_NAVYBLUE );

	_attach_buffer( renderbuffer[1] );
	fb32_clear_color( COLOR32_NAVYBLUE );

	_set_doublebuffer( renderbuffer[0], renderbuffer[1] );

	draw32_arc( COLOR32_WHITE, 500, 200, 300, 300, start_radian, end_radian, 1, 1 );

	print32_set_caret( print32_string( string, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( string ), 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );
	arm32_convert_endianness( DATA_COLOR32_SAMPLE_IMAGE0, DATA_COLOR32_SAMPLE_IMAGE0_SIZE, 4 );
	draw32_rgba_to_argb( DATA_COLOR32_SAMPLE_IMAGE0, DATA_COLOR32_SAMPLE_IMAGE0_SIZE );
	draw32_change_alpha_argb( DATA_COLOR32_SAMPLE_IMAGE0, DATA_COLOR32_SAMPLE_IMAGE0_SIZE, 0xFF );
	fb32_image( DATA_COLOR32_SAMPLE_IMAGE0, 400, 520, 64, 64, 0, 0, 0, 0 );

	arm32_convert_endianness( DATA_COLOR32_SAMPLE_IMAGE1, DATA_COLOR32_SAMPLE_IMAGE1_SIZE, 4 );
	draw32_rgba_to_argb( DATA_COLOR32_SAMPLE_IMAGE1, DATA_COLOR32_SAMPLE_IMAGE1_SIZE );
	fb32_image( DATA_COLOR32_SAMPLE_IMAGE1, 500, 520, 64, 64, 0, 0, 0, 0 );

	String float_string1 = math32_float32_to_string( start_sin, 0, 10, 0 );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( float_string1, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( float_string1 ), 8, 12, FONT_MONO_12PX_ASCII ) );

	String float_string2 = math32_float32_to_string( end_sin, 0, 10, 0 );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( float_string2, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( float_string2 ), 8, 12, FONT_MONO_12PX_ASCII ) );

	String float_string3 = math32_float32_to_string( float_number3, 0, 20, 0 );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( float_string3, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( float_string3 ), 8, 12, FONT_MONO_12PX_ASCII ) );

	String num_string = math32_int32_to_string_deci( number, 0, 1 );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_number( (uint32)num_string, FB32_X_CARET, FB32_Y_CARET, color, back_color, 8, 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( num_string, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( num_string ), 8, 12, FONT_MONO_12PX_ASCII ) );

	String num_string3 = math32_int32_to_string_hexa( number3, 6, 1, 0 );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_number( (uint32)num_string3, FB32_X_CARET, FB32_Y_CARET, color, back_color, 8, 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( num_string3, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( num_string3 ), 8, 12, FONT_MONO_12PX_ASCII ) );

	String num_string2 = math32_int32_to_string_hexa( number2, 6, 1, 1 );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( num_string2, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( num_string2 ), 8, 12, FONT_MONO_12PX_ASCII ) );

	String num_cat = print32_strcat( num_string, num_string2 );
	print32_set_caret( print32_string( newline, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( newline ), 8, 12, FONT_MONO_12PX_ASCII ) );
	print32_set_caret( print32_string( num_cat, FB32_X_CARET, FB32_Y_CARET, color, back_color, print32_strlen( num_cat ), 8, 12, FONT_MONO_12PX_ASCII ) );

	//fb32_image( COLOR32_SAMPLE_IMAGE, -4, 500, 8, 12, 0, 0, 0, 0 );
	//fb32_image( COLOR32_SAMPLE_IMAGE, 300, 632, 8, 12, 0, 0, 0, 0 );
	//fb32_image( COLOR32_SAMPLE_IMAGE, 400, 400, 8, 12, 5, 8, 0, 0 );

	fb32_clear_color_block( COLOR32_WHITE, -300, 600, 600, 50 );
	fb32_clear_color_block( COLOR32_WHITE, 700, -25, 600, 50 );
	fb32_clear_color_block( COLOR32_WHITE, 700, 620, 50, 100 );

	draw32_line( COLOR32_WHITE, 0, 0, 300, 600, 1, 1 );
	draw32_line( COLOR32_RED, 300, 100, 0, 0, 4, 4 );
	draw32_line( COLOR32_GREEN, 400, 0, 0, 400, 5, 5 );
	draw32_line( COLOR32_BLUE, 0, 300, 300, 0, 3, 3 );
	draw32_line( COLOR32_CYAN, 100, 0, 100, 300, 4, 4 );
	draw32_line( COLOR32_RED, 0, 400, 300, 400, 20, 20 );
	draw32_line( COLOR32_RED, 0, 400, 300, 500, 20, 20 );

	//draw32_circle( COLOR32_BLUE, 300, 300, 150, 200 );
	//draw32_circle( COLOR32_CYAN, -100, 500, 200, 175 );

	_attach_buffer( renderbuffer[2] );
	fb32_clear_color( 0x66FFFFFF );

	_attach_buffer( renderbuffer[3] );
	fb32_clear_color( COLOR32_BLACK );
	draw32_circle( COLOR32_WHITE, 150, 150, 100, 100 );
	draw32_circle( COLOR32_BLACK, 150, 150, 50, 50 );

	draw32_mask_image( renderbuffer[3], renderbuffer[2], 0, 0 );

	_attach_buffer( renderbuffer[2] );
	fb32_clear_color( 0x00000000 );
	draw32_line( 0x9900FFFF, 20, 20, 100, 200, 1, 1 );
	draw32_line( 0x9900FFFF, 20, 20, 20, 100, 1, 1 );
	draw32_line( 0x9900FFFF, 20, 100, 100, 200, 1, 1 );
	draw32_fill_color( renderbuffer[2] );

	_attach_buffer( FB32_DOUBLEBUFFER_BACK );

	fb32_image(
			_load_32( renderbuffer[2] + draw32_renderbuffer_addr ),
			100,
			100,
			_load_32( renderbuffer[2] + draw32_renderbuffer_width ),
			_load_32( renderbuffer[2] + draw32_renderbuffer_height ),
			0,
			0,
			0,
			0
	);

	draw32_antialias( renderbuffer[5], renderbuffer[3] );

	fb32_image(
			_load_32( renderbuffer[5] + draw32_renderbuffer_addr ),
			100,
			100,
			_load_32( renderbuffer[5] + draw32_renderbuffer_width ),
			_load_32( renderbuffer[5] + draw32_renderbuffer_height ),
			0,
			0,
			0,
			0
	);

	draw32_line( COLOR32_MAGENTA, -50, 800, 100, 100, 20, 20 );

	draw32_line( COLOR32_GREEN, 1000, 800, 100, 100, 20, 20 );
	
	while(1) {
		_flush_doublebuffer();

		draw32_copy( FB32_DOUBLEBUFFER_FRONT, renderbuffer[4] );

		fb32_image(
				_load_32( renderbuffer[4] + draw32_renderbuffer_addr ),
				0,
				0,
				_load_32( renderbuffer[4] + draw32_renderbuffer_width ),
				_load_32( renderbuffer[4] + draw32_renderbuffer_height ),
				0,
				10,
				10,
				0
		);

		print32_number( (uint32)random, FB32_X_CARET, FB32_Y_CARET, color, back_color, 8, 8, 12, FONT_MONO_12PX_ASCII );

		random = _random( 127 );

		_sleep( 1000000 );
	}
}