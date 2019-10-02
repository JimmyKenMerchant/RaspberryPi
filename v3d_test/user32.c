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
extern obj DATA_V3D_Z_SHADER;
extern uint32 DATA_V3D_Z_SHADER_SIZE;

extern obj DATA_COLOR32_SAMPLE_IMAGE0;
extern uint32 DATA_COLOR32_SAMPLE_IMAGE0_SIZE;
extern obj DATA_COLOR32_SAMPLE_IMAGE1;
extern uint32 DATA_COLOR32_SAMPLE_IMAGE1_SIZE;

void triangle3d( _GPUMemory* vertex_array, float32* vertices, uint32 num_vertex, obj matrix, uint32 width_pixel, uint32 height_pixel );

/**
 * Positive: X Right (Your View), Y Up, Z Forward (Towards You)
 * Front of Geometory: Counter Clock Wise
 * Calculation: Row order
 *              Multiplication of matrices needs to exchange Matrix 1 and Matrix 2 to get the same answer as column order.
 */

// X, Y, Z, S, T
float32 cube_vertices[] =
{
		// Front
		-0.25f, 0.25f, 0.25f, 0.0f, 1.0f,
		-0.25f,-0.25f, 0.25f, 0.0f, 0.0f,
		 0.25f,-0.25f, 0.25f, 1.0f, 0.0f,

		-0.25f, 0.25f, 0.25f, 0.0f, 1.0f,
		 0.25f,-0.25f, 0.25f, 1.0f, 0.0f,
		 0.25f, 0.25f, 0.25f, 1.0f, 1.0f,

		// Up
		-0.25f, 0.25f, -0.25f, 0.0f, 1.0f,
		-0.25f, 0.25f,  0.25f, 0.0f, 0.0f,
		 0.25f, 0.25f,  0.25f, 1.0f, 0.0f,

		-0.25f, 0.25f, -0.25f, 0.0f, 1.0f,
		 0.25f, 0.25f,  0.25f, 1.0f, 0.0f,
		 0.25f, 0.25f, -0.25f, 1.0f, 1.0f,

		// Right
		0.25f,  0.25f,  0.25f, 0.0f, 1.0f,
		0.25f, -0.25f,  0.25f, 0.0f, 0.0f,
		0.25f, -0.25f, -0.25f, 1.0f, 0.0f,

		0.25f,  0.25f,  0.25f, 0.0f, 1.0f,
		0.25f, -0.25f, -0.25f, 1.0f, 0.0f,
		0.25f,  0.25f, -0.25f, 1.0f, 1.0f,

		// Left
		-0.25f,  0.25f, -0.25f, 0.0f, 1.0f,
		-0.25f, -0.25f, -0.25f, 0.0f, 0.0f,
		-0.25f, -0.25f,  0.25f, 1.0f, 0.0f,

		-0.25f,  0.25f, -0.25f, 0.0f, 1.0f,
		-0.25f, -0.25f,  0.25f, 1.0f, 0.0f,
		-0.25f,  0.25f,  0.25f, 1.0f, 1.0f,

		// Back
		 0.25f,  0.25f, -0.25f, 0.0f, 1.0f,
		 0.25f, -0.25f, -0.25f, 0.0f, 0.0f,
		-0.25f, -0.25f, -0.25f, 1.0f, 0.0f,

		 0.25f,  0.25f, -0.25f, 0.0f, 1.0f,
		-0.25f, -0.25f, -0.25f, 1.0f, 0.0f,
		-0.25f,  0.25f, -0.25f, 1.0f, 1.0f,

		// Down
		-0.25f, -0.25f,  0.25f, 0.0f, 1.0f,
		-0.25f, -0.25f, -0.25f, 0.0f, 0.0f,
		 0.25f, -0.25f, -0.25f, 1.0f, 0.0f,

		-0.25f, -0.25f,  0.25f, 0.0f, 1.0f,
		 0.25f, -0.25f, -0.25f, 1.0f, 0.0f,
		 0.25f, -0.25f,  0.25f, 1.0f, 1.0f
};

float32 cube_position[] = { -0.5f, 0.0f, -2.0f };
float32 cube_scale[] = { 0.5f, 0.5f, 0.5f };
float32 versor_vector[] = { 1.0f, 1.0f, 1.0f };
float32 camera_position[] = { 0.0f, 0.5f, 2.0f };
float32 camera_target[] = { 0.0001f, 0.0001f, 0.0001f }; // Don't Initialize by Zeros, It's Invalid!
float32 camera_up[] = { 0.0f, 1.0f, 0.0f };
float32 angle;
float32 scale;
float32 depth_offset;
float32 depth_scale; // Depending on Camera Position and Target, Depth Value Needs to Be Between 0.0f to 1.0f

int32 _user_start()
{

	_ObjectV3D *objectv3d;
	_GPUMemory *output;
	_GPUMemory *vertex_array;
	_GPUMemory *additional_uniforms;
	_FragmentShader *fragmentshader;
	_FragmentShader *zshader;
	_Texture2D *texture2d;

	uint32 width_pixel = FB32_WIDTH;
	uint32 height_pixel = FB32_HEIGHT;
	uint32 result;
	String num_string;
	uint32 time = 0;
	depth_offset = 0.0f;
	depth_scale = 0.5f;

	objectv3d = (_ObjectV3D*)heap32_malloc( _wordsizeof( _ObjectV3D ) );
	_bind_objectv3d( objectv3d );
	output = (_GPUMemory*)heap32_malloc( _wordsizeof( _GPUMemory ) );
	_gpumemory_init( output, 8, 16, 0xC );
	vertex_array = (_GPUMemory*)heap32_malloc( _wordsizeof( _GPUMemory ) );
	_gpumemory_init( vertex_array, 720, 16, 0xC );
	additional_uniforms = (_GPUMemory*)heap32_malloc( _wordsizeof( _GPUMemory ) );
	_gpumemory_init( additional_uniforms, 256, 16, 0xC );
	fragmentshader = (_FragmentShader*)heap32_malloc( _wordsizeof( _FragmentShader ) );
	_fragmentshader_init( fragmentshader, DATA_V3D_FRAGMENT_SHADER, DATA_V3D_FRAGMENT_SHADER_SIZE );
	zshader = (_FragmentShader*)heap32_malloc( _wordsizeof( _FragmentShader ) );
	_fragmentshader_init( zshader, DATA_V3D_Z_SHADER, DATA_V3D_Z_SHADER_SIZE );

	_RenderBuffer **renderbuffer = (_RenderBuffer**)heap32_malloc( 1 );
	renderbuffer[0] = (_RenderBuffer*)heap32_malloc( _wordsizeof( _RenderBuffer ) );
	draw32_renderbuffer_init( renderbuffer[0], width_pixel, height_pixel, FB32_DEPTH );

	/**
	 * Note: Camera Position Upside Down, Leftside Right
	 *       The coordinate system for the camera position is rotated 180 degrees along with Z axis.
	 */
	obj mat_view = mtx32_view3d( (obj)camera_position, (obj)camera_target, (obj)camera_up );
	obj mat_projection = mtx32_perspective3d( 75.0f, 1.234f, 0.2f, 2.0f );
	obj mat_p_v = mtx32_multiply( mat_view, mat_projection, 4 ); // Projection, View
	obj mat_translate;
	obj mat_scale;
	obj mat_t_s; // Translate and Scale
	obj versor;
	obj mat_versor;
	obj mat_model;
	obj mat_p_v_m; // Projection, View, Model

	angle = 0.0f;
	scale = 0.5f;

	_control_qpul2cache( 0b101 );
	_clear_qpucache( 0x0F0F0F0F );

	_make_cl_binning( width_pixel, height_pixel, 0b101 );
	_make_cl_rendering( width_pixel, height_pixel, 0b101 );
	_config_cl_binning( 0x039005 ); // Forward Primitive, CCW, Depth Test

	additional_uniforms->arm[0].u32 = COLOR32_BLUE;
	additional_uniforms->arm[1].u32 = COLOR32_GRAY;
	additional_uniforms->arm[2].u32 = COLOR32_PINK;

	texture2d = (_Texture2D*)heap32_malloc( _wordsizeof( _Texture2D ) );
	_texture2d_init( texture2d, 64<<16|64, 64 * 64 * 4, 0 );
	_load_texture2d( texture2d, DATA_COLOR32_SAMPLE_IMAGE0, 0, True );
	bit32_convert_endianness( texture2d->gpu&0x3FFFFFFF, DATA_COLOR32_SAMPLE_IMAGE0_SIZE, 4 );
	draw32_rgba_to_argb( texture2d->gpu&0x3FFFFFFF, DATA_COLOR32_SAMPLE_IMAGE0_SIZE );
	_set_texture2d( texture2d, 0x1A0, 0b10000, additional_uniforms->gpu );

	while(True) {
		_stopwatch_start();

		mat_translate = mtx32_translate3d( (obj)cube_position );
		mat_scale = mtx32_scale3d( (obj)cube_scale );
		mat_t_s = mtx32_multiply( mat_scale, mat_translate, 4 );
		versor = mtx32_versor( angle, (obj)versor_vector );
		mat_versor = mtx32_versortomatrix( versor );
		mat_model = mtx32_multiply( mat_t_s, mat_versor, 4 );
		mat_p_v_m = mtx32_multiply( mat_p_v, mat_model, 4 );
		triangle3d( vertex_array, cube_vertices, 36, mat_p_v_m, width_pixel, height_pixel );
		heap32_mfree( mat_translate );
		heap32_mfree( mat_scale );
		heap32_mfree( mat_t_s );
		heap32_mfree( versor );
		heap32_mfree( mat_versor );
		heap32_mfree( mat_model );
		heap32_mfree( mat_p_v_m );

		_clear_cl_rendering( COLOR32_CYAN, 0xFFFFFF, 0x0, 0x0 );
		_setbuffer_cl_rendering( FB32_FRAMEBUFFER->addr );
		_set_nv_shaderstate( fragmentshader->gpu, vertex_array->gpu, 2, 20 );
		_execute_cl_binning( 4, 36, 0, 0xFF0000 ); // TRIANGLE, 36 Vertices, Index from 0
		_execute_cl_rendering( 0xFF0000 ); // The Point to Actually Draw Using Vertices

		/*
		_clear_cl_rendering( 0x00FFFFFF, 0xFFFFFF, 0x0, 0x0 );
		_setbuffer_cl_rendering( renderbuffer[0]->addr );
		_set_nv_shaderstate( zshader->gpu, vertex_array->gpu, 2, 20 );
		_execute_cl_binning( 4, 36, 0, 0xFF0000 ); // TRIANGLE, 36 Vertices, Index from 0
		_execute_cl_rendering( 0xFF0000 ); // The Point to Actually Draw Using Vertices
		*/

		// Angle Change
		angle = vfp32_fadd( angle, 1.0f );
		if( vfp32_fge( angle, 360.0f ) ) angle = 0.0f;

		// Position Change
		cube_position[0] = vfp32_fadd( cube_position[0], 0.01f );
		if( vfp32_fge( cube_position[0], 0.5f ) ) cube_position[0] = -0.5f;
		cube_position[2] = vfp32_fadd( cube_position[2], 0.04f );
		if( vfp32_fge( cube_position[2], 2.0f ) ) cube_position[2] = -2.0f;

		// Scale Change
		scale = vfp32_fadd( scale, 0.01f );
		if( vfp32_fge( scale, 1.5f ) ) scale = 0.5f;
		cube_scale[0] = scale;
		cube_scale[1] = scale;
		cube_scale[2] = scale;

		time = _stopwatch_end();
num_string = cvt32_int32_to_string_deci( time, 0, 0 );
print32_string( num_string, 0, 0, str32_strlen( num_string ) );
print32_debug( mat_versor, 0, 50 );
//print32_debug_hexa( FB32_FRAMEBUFFER->addr + ((800 * 324) + 400)*4, 0, 64, 256 );
		heap32_mfree( (obj)num_string );
		_sleep( 100000 );
	}

	heap32_mfree( mat_view );
	heap32_mfree( mat_projection );
	heap32_mfree( mat_p_v );
	_texture2d_free( texture2d );
	_gpumemory_free( vertex_array );
	_gpumemory_free( additional_uniforms );
	_fragmentshader_free( fragmentshader );
	_unmake_cl_binning();
	_unmake_cl_rendering();

	return EXIT_SUCCESS;
}

void triangle3d( _GPUMemory* vertex_array, float32* vertices, uint32 num_vertex, obj matrix, uint32 width_pixel, uint32 height_pixel ) {
	uint32 offset = 0;
	float32 *vector_xyzw = (float32*)heap32_malloc( 4 );
	float32 *result;
	uint16 int_x;
	uint16 int_y;
	float32 width_float = vfp32_u32tof32( width_pixel );
	float32 height_float = vfp32_u32tof32( height_pixel );

	for ( uint32 i = 0; i < num_vertex; i++ ) {
		/* X of Vector*/
		vector_xyzw[0] = vertices[i*5];

		/* Y of Vector */
		vector_xyzw[1] = vertices[i*5+1];

		/* Z of Vector */
		vector_xyzw[2] = vertices[i*5+2];

		/* W of Vector */
		vector_xyzw[3] = 1.0f;

		result = (float32*)mtx32_multiply_vec( matrix, (obj)vector_xyzw, 4 );

		/* Software -1.0 to 1.0 Coordinate to Hardware 0,0 to 1.0 Coordinate, Flip Y and Z Coordinate  */
		result[0] = vfp32_fadd( result[0], 1.0f );
		result[1] = vfp32_fadd( result[1], 1.0f );
		result[2] = vfp32_fadd( result[2], 1.0f );
		result[0] = vfp32_fdiv( result[0], 2.0f );
		result[1] = vfp32_fdiv( result[1], 2.0f );
		result[2] = vfp32_fdiv( result[2], 2.0f );
		result[1] = vfp32_fsub( result[1], 1.0f );
		result[1] = vfp32_fmul( result[1], -1.0f );
		result[2] = vfp32_fsub( result[2], 1.0f );
		result[2] = vfp32_fmul( result[2], -1.0f );

		/* Depth Offset and Scale, Depending on Camera Position */
		result[2] = vfp32_fadd( result[2], depth_offset );
		result[2] = vfp32_fmul( result[2], depth_scale );

		/* Multiply 0.0 to 1.0 Coordinates by Actual Width and Height of Framebuffer, Convert Float to Integer */
		int_x = vfp32_f32tou32( vfp32_fmul( result[0], width_float ) );
		int_y = vfp32_f32tou32( vfp32_fmul( result[1], height_float ) );

		vertex_array->arm[i*5].u32 = int_x*16|(int_y*16)<<16; // X and Y
		vertex_array->arm[i*5+1].f32 = result[2]; // Z
		vertex_array->arm[i*5+2].f32 = 1.0f; // W
		vertex_array->arm[i*5+3].f32 = vertices[i*5+3]; // S
		vertex_array->arm[i*5+4].f32 = vertices[i*5+4]; // T

		heap32_mfree( (obj)result );
		arm32_dsb();
	}

	heap32_mfree( (obj)vector_xyzw );
}

