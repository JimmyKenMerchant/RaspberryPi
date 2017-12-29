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

extern float32 os_fiq_sec;
extern float32 os_fiq_min;
extern float32 os_fiq_hour;

void _user_start()
{
	float32 start_sec;

	float32 start_min;
	float32 end_min;

	float32 start_hour;
	float32 end_hour;

	float32 delta_sec = vfp32_fdiv( -360.0, 600 );
	float32 delta_min = vfp32_fdiv( -360.0, 60 );
	float32 delta_hour = vfp32_fdiv( -360.0, 12 );

	uint32 time = 0;

	ObjArray renderbuffer = (ObjArray)heap32_malloc( 2 );

	renderbuffer[0] = (obj)heap32_malloc( draw32_renderbuffer );
	draw32_renderbuffer_init( renderbuffer[0], FB32_WIDTH, FB32_HEIGHT, FB32_DEPTH );
	renderbuffer[1] = (obj)heap32_malloc( draw32_renderbuffer );
	draw32_renderbuffer_init( renderbuffer[1], FB32_WIDTH, FB32_HEIGHT, FB32_DEPTH );

	_attach_buffer( renderbuffer[0] );
	fb32_clear_color( COLOR32_NAVYBLUE );

	_attach_buffer( renderbuffer[1] );
	fb32_clear_color( COLOR32_NAVYBLUE );

	_set_doublebuffer( renderbuffer[0], renderbuffer[1] );

	while(1) {
		_stopwatch_start();
		fb32_clear_color( COLOR32_NAVYBLUE );

		String num_string = math32_int32_to_string_deci( time, 0, 0 );
		print32_string( num_string, 0, 0, COLOR32_YELLOW, COLOR32_BLUE, print32_strlen( num_string ), 8, 12, FONT_MONO_12PX_ASCII );

		start_sec = vfp32_fmul( os_fiq_sec, delta_sec );
		start_sec = vfp32_fadd( start_sec, 90.0 );

		start_min = math32_round_degree32( vfp32_fmul( os_fiq_min, delta_min ) );
		start_min = vfp32_fadd( start_min, 90.9 );
		end_min = vfp32_fadd( start_min, 30.0 );

		start_hour = math32_round_degree32( vfp32_fmul( os_fiq_hour, delta_hour ) );
		start_hour = vfp32_fadd( start_hour, 91.4 );
		end_hour = vfp32_fadd( start_hour, 15.0 );

		//if ( vfp32_fgt( start_sec, end_sec ) ) start_sec = vfp32_fsub( start_sec, 360.0 );
		draw32_arc(
			COLOR32_CYAN,
			398, // 400 - 4/2
			318, // 320 - 4/2
			300, // 302 - 4/2, Minute Hand Will Be 302 - 4, 298
			300, // 302 - 4/2, Minute Hand Will Be 302 - 4, 298
			math32_degree_to_radian32( start_sec ),
			math32_degree_to_radian32( 90.0 ),
			4,
			4
		);
		draw32_arc(
			COLOR32_GREEN,
			396, // 400 - 8/2
			316, // 320 - 8/2
			294, // 298 - 8/2, Minute Hand Will Be 298 - 8, 290
			294, // 298 - 8/2, Minute Hand Will Be 298 - 8, 290
			math32_degree_to_radian32( start_min ),
			math32_degree_to_radian32( end_min ),
			8,
			8
		);
		draw32_arc(
			COLOR32_MAGENTA,
			394, // 400 - 12/2
			314, // 320 - 12/2
			284, // 290 - 12/2
			284, // 290 - 12/2
			math32_degree_to_radian32( start_hour ),
			math32_degree_to_radian32( end_hour ),
			12,
			12
		);
		draw32_bezier( COLOR32_YELLOW, 335, 400, 335, 500, 455, 500, 455, 400, 10, 10 );
		_flush_doublebuffer();

		time = _stopwatch_end();
		heap32_mfree( (obj)num_string );

		_sleep( 100000 );
	}
}