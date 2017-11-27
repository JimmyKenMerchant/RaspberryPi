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

	float32 start_sec = 90.0;
	float32 end_sec = 120.0;

	float32 start_min = 0.0;
	float32 end_min = 4.0;

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
		start_sec = math32_round_fdegree32( vfp32_fsub( start_sec, 0.6 ) );
		end_sec = math32_round_fdegree32( vfp32_fsub( end_sec, 0.6 ) );
		start_min = math32_round_fdegree32( vfp32_fsub( start_min, 0.1 ) );
		end_min = math32_round_fdegree32( vfp32_fsub( end_min, 0.1 ) );
		if ( vfp32_fgt( start_sec, end_sec ) ) start_sec = vfp32_fsub( start_sec, 360.0 );
		if ( vfp32_fgt( start_min, end_min ) ) start_min = vfp32_fsub( start_min, 360.0 );
		_sleep( 10000 );
	}
}