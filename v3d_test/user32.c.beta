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
	_ObjectV3D *objectv3d;
	_GPUMemory *output;
	_GPUMemory *vertex_array;
	_GPUMemory *additional_uniforms;
	_FragmentShader *fragmentshader;
	_Texture2D *texture2d;
	uint32 width_pixel = 800;
	uint32 height_pixel = 648;
	uint32 result;

	_control_qpul2cache( 0b101 );
	_clear_qpucache( 0x0F0F0F0F );

	objectv3d = (_ObjectV3D*)heap32_malloc( _wordsizeof( _ObjectV3D ) );
	_bind_objectv3d( objectv3d );

	output = (_GPUMemory*)heap32_malloc( _wordsizeof( _GPUMemory ) );
	_gpumemory_init( output, 8, 16, 0xC );
	vertex_array = (_GPUMemory*)heap32_malloc( _wordsizeof( _GPUMemory ) );
	_gpumemory_init( vertex_array, 256, 16, 0xC );
	additional_uniforms = (_GPUMemory*)heap32_malloc( _wordsizeof( _GPUMemory ) );
	_gpumemory_init( additional_uniforms, 256, 16, 0xC );
	fragmentshader = (_FragmentShader*)heap32_malloc( _wordsizeof( _FragmentShader ) );
	_fragmentshader_init( fragmentshader, DATA_V3D_FRAGMENT_SHADER, DATA_V3D_FRAGMENT_SHADER_SIZE );

	_make_cl_binning( width_pixel, height_pixel, 0b101 );
	_make_cl_rendering( width_pixel, height_pixel, 0b101 );
	_setbuffer_cl_rendering( FB32_FRAMEBUFFER->addr );
	//Tested //_unmake_cl_binning();
	//Tested //_unmake_cl_rendering();
	_config_cl_binning( 0x039007 ); // Enable Forward Facing Primitive, Depth Test LT, Z Update Enable 
	_clear_cl_rendering( COLOR32_CYAN, 0xFFFFFF, 0x0, 0x0 );
	_set_nv_shaderstate( fragmentshader->gpu, vertex_array->gpu, 2, 20 );

	vertex_array->arm[0].u32 = 300*16|(300*16)<<16; // X and Y
	vertex_array->arm[1].f32 = 0.5f;
	vertex_array->arm[2].f32 = 1.0f;
	vertex_array->arm[3].f32 = 0.0f;
	vertex_array->arm[4].f32 = 1.0f;
	vertex_array->arm[5].u32 = 300*16|(332*16)<<16; // X and Y
	vertex_array->arm[6].f32 = 0.5f;
	vertex_array->arm[7].f32 = 1.0f;
	vertex_array->arm[8].f32 = 0.0f;
	vertex_array->arm[9].f32 = 0.0f;
	vertex_array->arm[10].u32 = 332*16|(332*16)<<16; // X and Y
	vertex_array->arm[11].f32 = 0.5f;
	vertex_array->arm[12].f32 = 1.0f;
	vertex_array->arm[13].f32 = 1.0f;
	vertex_array->arm[14].f32 = 0.0f;
	vertex_array->arm[15].u32 = 300*16|(300*16)<<16; // X and Y
	vertex_array->arm[16].f32 = 0.5f;
	vertex_array->arm[17].f32 = 1.0f;
	vertex_array->arm[18].f32 = 0.0f;
	vertex_array->arm[19].f32 = 1.0f;
	vertex_array->arm[20].u32 = 332*16|(332*16)<<16; // X and Y
	vertex_array->arm[21].f32 = 0.5f;
	vertex_array->arm[22].f32 = 1.0f;
	vertex_array->arm[23].f32 = 1.0f;
	vertex_array->arm[24].f32 = 0.0f;
	vertex_array->arm[25].u32 = 332*16|(300*16)<<16; // X and Y
	vertex_array->arm[26].f32 = 0.5f;
	vertex_array->arm[27].f32 = 1.0f;
	vertex_array->arm[28].f32 = 1.0f;
	vertex_array->arm[29].f32 = 1.0f;

	vertex_array->arm[30].u32 = 256*16|(256*16)<<16; // X and Y
	vertex_array->arm[31].f32 = 0.6f;
	vertex_array->arm[32].f32 = 1.0f;
	vertex_array->arm[33].f32 = 0.0f;
	vertex_array->arm[34].f32 = 1.0f;
	vertex_array->arm[35].u32 = 256*16|(512*16)<<16; // X and Y
	vertex_array->arm[36].f32 = 0.6f;
	vertex_array->arm[37].f32 = 1.0f;
	vertex_array->arm[38].f32 = 0.0f;
	vertex_array->arm[39].f32 = 0.0f;
	vertex_array->arm[40].u32 = 512*16|(512*16)<<16; // X and Y
	vertex_array->arm[41].f32 = 0.6f;
	vertex_array->arm[42].f32 = 1.0f;
	vertex_array->arm[43].f32 = 1.0f;
	vertex_array->arm[44].f32 = 0.0f;
	vertex_array->arm[45].u32 = 256*16|(256*16)<<16; // X and Y
	vertex_array->arm[46].f32 = 0.6f;
	vertex_array->arm[47].f32 = 1.0f;
	vertex_array->arm[48].f32 = 0.0f;
	vertex_array->arm[49].f32 = 1.0f;
	vertex_array->arm[50].u32 = 512*16|(512*16)<<16; // X and Y
	vertex_array->arm[51].f32 = 0.6f;
	vertex_array->arm[52].f32 = 1.0f;
	vertex_array->arm[53].f32 = 1.0f;
	vertex_array->arm[54].f32 = 0.0f;
	vertex_array->arm[55].u32 = 512*16|(256*16)<<16; // X and Y
	vertex_array->arm[56].f32 = 0.6f;
	vertex_array->arm[57].f32 = 1.0f;
	vertex_array->arm[58].f32 = 1.0f;
	vertex_array->arm[59].f32 = 1.0f;

	additional_uniforms->arm[0].u32 = COLOR32_BLUE;
	additional_uniforms->arm[1].u32 = COLOR32_GRAY;
	additional_uniforms->arm[2].u32 = COLOR32_PINK;

	texture2d = (_Texture2D*)heap32_malloc( _wordsizeof( _Texture2D ) );
	_texture2d_init( texture2d, 64<<16|64, 64 * 64 * 4, 0 );
	_load_texture2d( texture2d, DATA_COLOR32_SAMPLE_IMAGE0, 0 );
	//_load_texture2d( texture2d, DATA_COLOR32_SAMPLE_IMAGE1, 1 );
	bit32_convert_endianness( texture2d->gpu&0x3FFFFFFF, DATA_COLOR32_SAMPLE_IMAGE0_SIZE, 4 );
	draw32_rgba_to_argb( texture2d->gpu&0x3FFFFFFF, DATA_COLOR32_SAMPLE_IMAGE0_SIZE );
	// Flip Y Axis, NEAREST for Magnification, NEAR_MIP_NEAR for Minification Filter
	_set_texture2d( texture2d, 0x1A0, 0b10000, additional_uniforms->gpu );

	result = _execute_cl_binning( 4, 12, 0, 0xFF0000 ); // TRIANGLE_STRIP, 5 Vertices, Index from 5
print32_debug( result, 0, 114 );
	result = _execute_cl_rendering( 0xFF0000 ); // The Point to Actually Draw Using Vertices
print32_debug( result, 0, 126 );

	result = _texture2d_free( texture2d );
print32_debug( result, 0, 138 );
	result = _gpumemory_free( vertex_array );
print32_debug( result, 0, 150 );
	result = _gpumemory_free( additional_uniforms );
print32_debug( result, 0, 162 );
	result = _fragmentshader_free( fragmentshader );
print32_debug( result, 0, 174 );

	while( true ) {
	}
	return EXIT_SUCCESS;
}

