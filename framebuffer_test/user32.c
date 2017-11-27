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
	float32 end_sec;

	float32 start_min;
	float32 end_min;

	float32 start_hour;
	float32 end_hour;

	float32 delta_sec = vfp32_fdiv( -360.0, 600 );
	float32 delta_min = vfp32_fdiv( -360.0, 60 );
	float32 delta_hour = vfp32_fdiv( -360.0, 12 );

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
		_flush_doublebuffer();
		fb32_clear_color( COLOR32_NAVYBLUE );

		start_sec = math32_round_degree32( vfp32_fmul( os_fiq_sec, delta_sec ) );
		start_sec = vfp32_fadd( start_sec, 90.0 );
		end_sec = vfp32_fadd( start_sec, 60.0 );

		start_min = math32_round_degree32( vfp32_fmul( os_fiq_min, delta_min ) );
		start_min = vfp32_fadd( start_min, 90.0 );
		end_min = vfp32_fadd( start_min, 30.0 );

		start_hour = math32_round_degree32( vfp32_fmul( os_fiq_hour, delta_hour ) );
		start_hour = vfp32_fadd( start_hour, 90.0 );
		end_hour = vfp32_fadd( start_hour, 15.0 );

		//if ( vfp32_fgt( start_sec, end_sec ) ) start_sec = vfp32_fsub( start_sec, 360.0 );
		draw32_arc(
			COLOR32_CYAN,
			400,
			320,
			300,
			300,
			math32_degree_to_radian32( start_sec ),
			math32_degree_to_radian32( end_sec ),
			4,
			4
		);
		draw32_arc(
			COLOR32_GREEN,
			400,
			320,
			296,
			296,
			math32_degree_to_radian32( start_min ),
			math32_degree_to_radian32( end_min ),
			4,
			4
		);
		draw32_arc(
			COLOR32_MAGENTA,
			400,
			320,
			292,
			292,
			math32_degree_to_radian32( start_hour ),
			math32_degree_to_radian32( end_hour ),
			4,
			4
		);

		_sleep( 10000 );
	}
}