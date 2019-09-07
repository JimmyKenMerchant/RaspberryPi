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

extern obj V3D_FRAGMENT_SHADER;
extern uint32 V3D_FRAGMENT_SHADER_SIZE;

int32 _user_start() {
	uint32 width_pixel = 384;
	uint32 height_pixel = 320;
	bool flag_multi = true;
	uint32 result;
	//_control_qpul2cache( uchar8 ctrl_l2 );
	//_clear_qpucache( uint32 clear_bit );
	//_execute_qpu( uchar8 number_qpu, obj address_job, bool flag_noflush, uint32 timeout );
	_make_cl_binning( width_pixel, height_pixel, flag_multi );
	_make_cl_rendering( FB32_FRAMEBUFFER->addr, width_pixel, height_pixel, flag_multi );
	//Tested //_unmake_cl_binning();
	//Tested //_unmake_cl_rendering();
	result = _clear_cl_rendering( 0x01020304, 0x08090A0B, 0xCD, 0xEF );
print32_debug( result, 0, 0 );
	//_execute_cl_binning( uchar8 primitive, uint32 num_vertex, uint32 index_vertex, uint32 timeout );
	//_execute_cl_rendering( bool flag_clear, uint32 timeout );
	//_set_nv_shaderstate( obj address_shader, obj address_vertex, uint32 num_varying, uint32 stride_vertex );
	//_texture2d_init( _Texture2D* texture2d, obj address_texture, uint32 height_width_in_pixel, uchar8 mipmap_level_minus_1 );
	//_texture2d_free( _Texture2D* texture2d );
	//_set_texture2d( _Texture2D* texture2d, bool flag_flip, uchar8 data_type, obj address_additional_uniforms );
	while( true ) {
	}
	return EXIT_SUCCESS;
}

