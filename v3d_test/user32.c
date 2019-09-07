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
extern obj V3D_SIN;
extern uint32 V3D_SIN_SIZE;

int32 _user_start() {
	_GPUMemory *output;
	_GPUMemory *uniforms;
	_FragmentShader *fragmentshader;
	uint32 *jobs;
	uint32 width_pixel = 384;
	uint32 height_pixel = 320;
	bool flag_multi = true;
	uint32 result;

	result = _control_qpul2cache( 0b101 );
print32_debug( result, 0, 0 );
	result = _clear_qpucache( 0x0F0F0F0F );
print32_debug( result, 0, 12 );

	output = (_GPUMemory*)heap32_malloc( _wordsizeof( _GPUMemory ) );
	result = _gpumemory_init( output, 8, 16, 0xC );
print32_debug( result, 0, 24 );
	uniforms = (_GPUMemory*)heap32_malloc( _wordsizeof( _GPUMemory ) );
	result = _gpumemory_init( uniforms, 8, 16, 0xC );
print32_debug( result, 72, 24 );
	uniforms->arm[0] = vfp32_f32tohexa( 0.5f );
	uniforms->arm[1] = output->gpu;
	fragmentshader = (_FragmentShader*)heap32_malloc( _wordsizeof( _FragmentShader ) );
	result = _fragmentshader_init( fragmentshader, V3D_SIN, V3D_SIN_SIZE );
print32_debug( result, 144, 24 );
	jobs = (uint32*)heap32_malloc( 2 );
	jobs[0] = uniforms->gpu;
	//jobs[1] = V3D_SIN; // There Isn't Code in Cache, Needed to Be Loaded to GPU Cache;
	jobs[1] = fragmentshader->gpu;
	result = _execute_qpu( 1, jobs, false, 0xFF0000 );
print32_debug( result, 216, 24 );
print32_debug_hexa( (obj)output->arm, 288, 24, 4 );

	_make_cl_binning( width_pixel, height_pixel, flag_multi );
	_make_cl_rendering( FB32_FRAMEBUFFER->addr, width_pixel, height_pixel, flag_multi );
	//Tested //_unmake_cl_binning();
	//Tested //_unmake_cl_rendering();
	result = _clear_cl_rendering( 0x01020304, 0x08090A0B, 0xCD, 0xEF );
print32_debug( result, 0, 36 );
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

