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

extern obj DATA_V3D_FRAGMENT_SHADER;
extern uint32 DATA_V3D_FRAGMENT_SHADER_SIZE;
extern obj DATA_V3D_SIN;
extern uint32 DATA_V3D_SIN_SIZE;

extern obj DATA_COLOR32_SAMPLE_IMAGE0;
extern uint32 DATA_COLOR32_SAMPLE_IMAGE0_SIZE;
extern obj DATA_COLOR32_SAMPLE_IMAGE1;
extern uint32 DATA_COLOR32_SAMPLE_IMAGE1_SIZE;

int32 _user_start() {
	_GPUMemory *output;
	_GPUMemory *uniforms;
	_GPUMemory *vertex_array;
	_FragmentShader *fragmentshader;
	_Texture2D *texture2d;
	uint32 *jobs;
	uint32 width_pixel = 384;
	uint32 height_pixel = 320;
	bool flag_multi = true;
	uint32 result;

	_control_qpul2cache( 0b101 );
	_clear_qpucache( 0x0F0F0F0F );

	output = (_GPUMemory*)heap32_malloc( _wordsizeof( _GPUMemory ) );
	_gpumemory_init( output, 8, 16, 0xC );
	uniforms = (_GPUMemory*)heap32_malloc( _wordsizeof( _GPUMemory ) );
	_gpumemory_init( uniforms, 8, 16, 0xC );
	vertex_array = (_GPUMemory*)heap32_malloc( _wordsizeof( _GPUMemory ) );
	_gpumemory_init( vertex_array, 256, 16, 0xC );

	uniforms->arm[0].f32 = 0.5f;
	uniforms->arm[1].u32 = output->gpu;
	fragmentshader = (_FragmentShader*)heap32_malloc( _wordsizeof( _FragmentShader ) );
	result = _fragmentshader_init( fragmentshader, DATA_V3D_SIN, DATA_V3D_SIN_SIZE );
	jobs = (uint32*)heap32_malloc( 2 );
	jobs[0] = uniforms->gpu;
	//jobs[1] = V3D_SIN; // There Isn't Code in Cache, Needed to Be Loaded to GPU Cache;
	jobs[1] = fragmentshader->gpu;
	result = _execute_qpu( 1, jobs, false, 0xFF0000 );
print32_debug( result, 0, 0 );
print32_debug( output->arm[0].u32, 72, 0 );

	_make_cl_binning( width_pixel, height_pixel, flag_multi );
	_make_cl_rendering( FB32_FRAMEBUFFER->addr, width_pixel, height_pixel, flag_multi );
	//Tested //_unmake_cl_binning();
	//Tested //_unmake_cl_rendering();
	_clear_cl_rendering( 0x01020304, 0x08090A0B, 0xCD, 0xEF );

	//_execute_cl_binning( uchar8 primitive, uint32 num_vertex, uint32 index_vertex, uint32 timeout );
	//_execute_cl_rendering( bool flag_clear, uint32 timeout );

	vertex_array->arm[0].u32 = 11;
	vertex_array->arm[1].u32 = 12;
	_set_nv_shaderstate( fragmentshader->gpu, vertex_array->gpu, 2, 20 );

	texture2d = (_Texture2D*)heap32_malloc( _wordsizeof( _Texture2D ) );
	result = _texture2d_init( texture2d, DATA_COLOR32_SAMPLE_IMAGE0, 64<<16|64, 0 );
print32_debug( result, 0, 12 );
print32_debug( texture2d->gpu, 72, 12);
print32_debug( texture2d->handle_gpu_memory, 144, 12);
print32_debug( texture2d->width, 216, 12);
print32_debug( texture2d->height, 288, 12);
print32_debug( texture2d->lod, 360, 12);
print32_debug_hexa( texture2d->gpu&0x3FFFFFFF, 0, 24, 256 );
	result = _set_texture2d( texture2d, 1, 0, 0 );
print32_debug( result, 0, 126 );
	result = _texture2d_free( texture2d );
print32_debug( result, 0, 138 );

	while( true ) {
	}
	return EXIT_SUCCESS;
}

