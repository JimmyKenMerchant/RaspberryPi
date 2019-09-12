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

extern obj DATA_COLOR32_SAMPLE_IMAGE0;
extern uint32 DATA_COLOR32_SAMPLE_IMAGE0_SIZE;
extern obj DATA_COLOR32_SAMPLE_IMAGE1;
extern uint32 DATA_COLOR32_SAMPLE_IMAGE1_SIZE;

int32 _user_start() {
	_GPUMemory *output;
	_GPUMemory *vertex_array;
	_FragmentShader *fragmentshader;
	_Texture2D *texture2d;
	uint32 width_pixel = 800;
	uint32 height_pixel = 648;
	uint32 result;

	_control_qpul2cache( 0b101 );
	_clear_qpucache( 0x0F0F0F0F );

	output = (_GPUMemory*)heap32_malloc( _wordsizeof( _GPUMemory ) );
	_gpumemory_init( output, 8, 16, 0xC );
	vertex_array = (_GPUMemory*)heap32_malloc( _wordsizeof( _GPUMemory ) );
	_gpumemory_init( vertex_array, 256, 16, 0xC );
	fragmentshader = (_FragmentShader*)heap32_malloc( _wordsizeof( _FragmentShader ) );
	_fragmentshader_init( fragmentshader, DATA_V3D_FRAGMENT_SHADER, DATA_V3D_FRAGMENT_SHADER_SIZE );

	_make_cl_binning( width_pixel, height_pixel, 0b101 );
	_make_cl_rendering( FB32_FRAMEBUFFER->addr, width_pixel, height_pixel, 0b101 );
	//Tested //_unmake_cl_binning();
	//Tested //_unmake_cl_rendering();
	_config_cl_binning( 0x009003 ); // Enable Both Forward and Reverse Facing Primitive, Depth Test LT, Z Update Enable 
	_clear_cl_rendering( 0xFF00FFFF, 0x000000, 0x0, 0x0 );

	vertex_array->arm[0].u32 = 0*16|(0*16)<<16; // X and Y
	vertex_array->arm[1].f32 = 1.0f;
	vertex_array->arm[2].f32 = 1.0f;
	vertex_array->arm[3].f32 = 0.0f;
	vertex_array->arm[4].f32 = 1.0f;
	vertex_array->arm[5].u32 = 0*16|(256*16)<<16; // X and Y
	vertex_array->arm[6].f32 = 1.0f;
	vertex_array->arm[7].f32 = 1.0f;
	vertex_array->arm[8].f32 = 0.0f;
	vertex_array->arm[9].f32 = 0.0f;
	vertex_array->arm[10].u32 = 256*16|(256*16)<<16; // X and Y
	vertex_array->arm[11].f32 = 1.0f;
	vertex_array->arm[12].f32 = 1.0f;
	vertex_array->arm[13].f32 = 1.0f;
	vertex_array->arm[14].f32 = 0.0f;
	vertex_array->arm[15].u32 = 256*16|(0*16)<<16; // X and Y
	vertex_array->arm[16].f32 = 1.0f;
	vertex_array->arm[17].f32 = 1.0f;
	vertex_array->arm[18].f32 = 1.0f;
	vertex_array->arm[19].f32 = 1.0f;
	vertex_array->arm[20].u32 = 0*16|(0*16)<<16; // X and Y
	vertex_array->arm[21].f32 = 1.0f;
	vertex_array->arm[22].f32 = 1.0f;
	vertex_array->arm[23].f32 = 0.0f;
	vertex_array->arm[24].f32 = 1.0f;
	_set_nv_shaderstate( fragmentshader->gpu, vertex_array->gpu, 2, 20 );

	texture2d = (_Texture2D*)heap32_malloc( _wordsizeof( _Texture2D ) );
	_texture2d_init( texture2d, 64<<16|64, 64 * 64 * 4, 0 );
	_load_texture2d( texture2d, DATA_COLOR32_SAMPLE_IMAGE0, 0 );
	bit32_convert_endianness( texture2d->gpu&0x3FFFFFFF, DATA_COLOR32_SAMPLE_IMAGE0_SIZE, 4 );
	draw32_rgba_to_argb( texture2d->gpu&0x3FFFFFFF, DATA_COLOR32_SAMPLE_IMAGE0_SIZE );
	_set_texture2d( texture2d, 0x190, 0b10000, 0 ); // Flip Y Axis and NEAREST for Magnification and Minification Filter

	result = _execute_cl_binning( 5, 5, 0, 0xFF0000 ); // TRIANGLE_STRIP, 5 Vertices
print32_debug( result, 0, 114 );
	result = _execute_cl_rendering( true, 0xFF0000 );
print32_debug( result, 0, 126 );

	result = _texture2d_free( texture2d );
print32_debug( result, 0, 138 );
	result = _gpumemory_free( vertex_array );
print32_debug( result, 0, 150 );
	result = _fragmentshader_free( fragmentshader );
print32_debug( result, 0, 162 );

	while( true ) {
	}
	return EXIT_SUCCESS;
}

