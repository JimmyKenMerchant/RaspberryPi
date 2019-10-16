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

extern obj DATA_V3D_FRAGMENT_SHADER2;
extern uint32 DATA_V3D_FRAGMENT_SHADER2_SIZE;

extern obj DATA_COLOR32_SAMPLE_IMAGE0;
extern uint32 DATA_COLOR32_SAMPLE_IMAGE0_SIZE;
extern obj DATA_COLOR32_SAMPLE_IMAGE1;
extern uint32 DATA_COLOR32_SAMPLE_IMAGE1_SIZE;
extern obj DATA_COLOR32_SAMPLE_IMAGE2;
extern uint32 DATA_COLOR32_SAMPLE_IMAGE2_SIZE;
extern obj DATA_COLOR32_SAMPLE_BACKGROUND;
extern uint32 DATA_COLOR32_SAMPLE_BACKGROUND_SIZE;

void va_set_triangle3d( _GPUMemory* vertex_array, float32* vertices, uint32 num_vertex, obj matrix, uint32 width_pixel, uint32 height_pixel );

uint32 va_count; // Global for Setting Vertex Array

/**
 * Positive: X Right (Your View), Y Up, Z Forward (Towards You)
 * Front of Geometory: Counter Clock Wise
 * Calculation: Row order
 *              Multiplication of matrices needs to exchange Matrix 1 and Matrix 2 to get the same answer as column order.
 */

// X, Y, Z, S, T, Index of Images
float32 cube_vertices[] =
{
		// Front
		-0.25f, 0.25f, 0.25f, 0.0f, 1.0f, 1.0f,
		-0.25f,-0.25f, 0.25f, 0.0f, 0.0f, 1.0f,
		 0.25f,-0.25f, 0.25f, 1.0f, 0.0f, 1.0f,

		-0.25f, 0.25f, 0.25f, 0.0f, 1.0f, 1.0f,
		 0.25f,-0.25f, 0.25f, 1.0f, 0.0f, 1.0f,
		 0.25f, 0.25f, 0.25f, 1.0f, 1.0f, 1.0f,

		// Up
		-0.25f, 0.25f, -0.25f, 0.0f, 1.0f, 1.0f,
		-0.25f, 0.25f,  0.25f, 0.0f, 0.0f, 1.0f,
		 0.25f, 0.25f,  0.25f, 1.0f, 0.0f, 1.0f,

		-0.25f, 0.25f, -0.25f, 0.0f, 1.0f, 1.0f,
		 0.25f, 0.25f,  0.25f, 1.0f, 0.0f, 1.0f,
		 0.25f, 0.25f, -0.25f, 1.0f, 1.0f, 1.0f,

		// Right
		0.25f,  0.25f,  0.25f, 0.0f, 1.0f, 2.0f,
		0.25f, -0.25f,  0.25f, 0.0f, 0.0f, 2.0f,
		0.25f, -0.25f, -0.25f, 1.0f, 0.0f, 2.0f,

		0.25f,  0.25f,  0.25f, 0.0f, 1.0f, 2.0f,
		0.25f, -0.25f, -0.25f, 1.0f, 0.0f, 2.0f,
		0.25f,  0.25f, -0.25f, 1.0f, 1.0f, 2.0f,

		// Left
		-0.25f,  0.25f, -0.25f, 0.0f, 1.0f, 2.0f,
		-0.25f, -0.25f, -0.25f, 0.0f, 0.0f, 2.0f,
		-0.25f, -0.25f,  0.25f, 1.0f, 0.0f, 2.0f,

		-0.25f,  0.25f, -0.25f, 0.0f, 1.0f, 2.0f,
		-0.25f, -0.25f,  0.25f, 1.0f, 0.0f, 2.0f,
		-0.25f,  0.25f,  0.25f, 1.0f, 1.0f, 2.0f,

		// Back
		 0.25f,  0.25f, -0.25f, 0.0f, 1.0f, 1.0f,
		 0.25f, -0.25f, -0.25f, 0.0f, 0.0f, 1.0f,
		-0.25f, -0.25f, -0.25f, 1.0f, 0.0f, 1.0f,

		 0.25f,  0.25f, -0.25f, 0.0f, 1.0f, 1.0f,
		-0.25f, -0.25f, -0.25f, 1.0f, 0.0f, 1.0f,
		-0.25f,  0.25f, -0.25f, 1.0f, 1.0f, 1.0f,

		// Down
		-0.25f, -0.25f,  0.25f, 0.0f, 1.0f, 1.0f,
		-0.25f, -0.25f, -0.25f, 0.0f, 0.0f, 1.0f,
		 0.25f, -0.25f, -0.25f, 1.0f, 0.0f, 1.0f,

		-0.25f, -0.25f,  0.25f, 0.0f, 1.0f, 1.0f,
		 0.25f, -0.25f, -0.25f, 1.0f, 0.0f, 1.0f,
		 0.25f, -0.25f,  0.25f, 1.0f, 1.0f, 1.0f
};

// X, Y, Z, S, T, Index of Images
float32 background_vertices[] =
{
		-1.0f, 1.0f, -1.8f, 0.0f, 1.0f, 0.0f,
		-1.0f,-1.0f, -1.8f, 0.0f, 0.0f, 0.0f,
		 1.0f,-1.0f, -1.8f, 1.0f, 0.0f, 0.0f,

		-1.0f, 1.0f, -1.8f, 0.0f, 1.0f, 0.0f,
		 1.0f,-1.0f, -1.8f, 1.0f, 0.0f, 0.0f,
		 1.0f, 1.0f, -1.8f, 1.0f, 1.0f, 0.0f
};

float32 cube_position[] = { -0.5f, 0.0f, -2.0f };
float32 cube_scale[] = { 0.5f, 0.5f, 0.5f };
float32 versor_vector[] = { 1.0f, 1.0f, 1.0f };
float32 camera_position[] = { 0.0f, 0.5f, 2.0f };
float32 camera_target[] = { 0.0001f, 0.0001f, 0.0001f }; // Don't Initialize by Zeros, It's Invalid!
float32 camera_up[] = { 0.0f, 1.0f, 0.0f };
float32 angle;
float32 scale;
/**
 * Depth scale is depending on the values of the near and the far of the perspective projection.
 * If the near is 0.2f and the far is 4.0f, you need to make the 3D object visible in the distance 3.8f.
 * The software coordinate is between -1.0f to 1.0f in the distance 2.0f.
 * So multiply the calculated Z by 2.0f/3.8f.
 */
float32 depth_scale;
/**
 * Depth offset may be needed if you set the camera target other than 0.0f for all axis.
 */
float32 depth_offset;

int32 _user_start()
{

	_ObjectV3D *objectv3d;
	_GPUMemory *vertex_array;
	_GPUMemory *additional_uniforms;
	_GPUMemory *overspillmemory;
	_FragmentShader *fragmentshader;
	_Texture2D *texture2d_0;
	_Texture2D *texture2d_background;
	_Texture2D *texture2d_1;
	_Texture2D *texture2d_2;

	uint32 width_pixel = FB32_WIDTH;
	uint32 height_pixel = FB32_HEIGHT;
	//uint32 result;
	String num_string;
	uint32 time = 0;
	depth_offset = 0.0f;
	depth_scale = 0.5263f;

	objectv3d = (_ObjectV3D*)heap32_malloc( _wordsizeof( _ObjectV3D ) );
	_bind_objectv3d( objectv3d );
	vertex_array = (_GPUMemory*)heap32_malloc( _wordsizeof( _GPUMemory ) );
	_gpumemory_init( vertex_array, 1008, 16, 0xC );
	additional_uniforms = (_GPUMemory*)heap32_malloc( _wordsizeof( _GPUMemory ) );
	_gpumemory_init( additional_uniforms, 256, 16, 0xC );
	overspillmemory = (_GPUMemory*)heap32_malloc( _wordsizeof( _GPUMemory ) );
	_gpumemory_init( overspillmemory, 0x20000, 256, 0xC );
	fragmentshader = (_FragmentShader*)heap32_malloc( _wordsizeof( _FragmentShader ) );
	_fragmentshader_init( fragmentshader, DATA_V3D_FRAGMENT_SHADER2, DATA_V3D_FRAGMENT_SHADER2_SIZE );

	_RenderBuffer **renderbuffer = (_RenderBuffer**)heap32_malloc( 1 );
	renderbuffer[0] = (_RenderBuffer*)heap32_malloc( _wordsizeof( _RenderBuffer ) );
	draw32_renderbuffer_init( renderbuffer[0], width_pixel, height_pixel, FB32_DEPTH );

	/**
	 * Note: Camera Position Upside Down, Leftside Right
	 *       The coordinate system for the camera position is rotated 180 degrees along with Z axis.
	 */
	obj mat_identity4 = mtx32_identity( 4 );
	obj mat_view = mtx32_view3d( (obj)camera_position, (obj)camera_target, (obj)camera_up );
	obj mat_projection = mtx32_perspective3d( 75.0f, 1.3333333f, 0.2f, 4.0f );
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

	texture2d_0 = (_Texture2D*)heap32_malloc( _wordsizeof( _Texture2D ) );
	_texture2d_init( texture2d_0, 1<<16|1, 32 * 32 * 4, 0 ); // Init Minimum Texture
	_set_texture2d( texture2d_0, 0x1A0, 0b10000, additional_uniforms->gpu ); // Texture Size Affects Speed of Shading

	texture2d_background = (_Texture2D*)heap32_malloc( _wordsizeof( _Texture2D ) );
	_texture2d_init( texture2d_background, 256<<16|256, 256 * 256 * 4, 0 );
	_load_texture2d( texture2d_background, DATA_COLOR32_SAMPLE_BACKGROUND, 0 );
	bit32_convert_endianness( texture2d_background->gpu&0x3FFFFFFF, DATA_COLOR32_SAMPLE_BACKGROUND_SIZE, 4 );
	draw32_rgba_to_argb( texture2d_background->gpu&0x3FFFFFFF, DATA_COLOR32_SAMPLE_BACKGROUND_SIZE );

	texture2d_1 = (_Texture2D*)heap32_malloc( _wordsizeof( _Texture2D ) );
	_texture2d_init( texture2d_1, 64<<16|64, 64 * 64 * 4, 0 );
	_load_texture2d( texture2d_1, DATA_COLOR32_SAMPLE_IMAGE0, 0 );
	bit32_convert_endianness( texture2d_1->gpu&0x3FFFFFFF, DATA_COLOR32_SAMPLE_IMAGE0_SIZE, 4 );
	draw32_rgba_to_argb( texture2d_1->gpu&0x3FFFFFFF, DATA_COLOR32_SAMPLE_IMAGE0_SIZE );

	texture2d_2 = (_Texture2D*)heap32_malloc( _wordsizeof( _Texture2D ) );
	_texture2d_init( texture2d_2, 64<<16|64, 64 * 64 * 4, 0 );
	_load_texture2d( texture2d_2, DATA_COLOR32_SAMPLE_IMAGE2, 0 );
	bit32_convert_endianness( texture2d_2->gpu&0x3FFFFFFF, DATA_COLOR32_SAMPLE_IMAGE2_SIZE, 4 );
	draw32_rgba_to_argb( texture2d_2->gpu&0x3FFFFFFF, DATA_COLOR32_SAMPLE_IMAGE2_SIZE );

	additional_uniforms->arm[0].u32 = texture2d_background->gpu;
	additional_uniforms->arm[1].u32 = texture2d_1->gpu;
	additional_uniforms->arm[2].u32 = texture2d_2->gpu;

	va_count = 0; // Offset for Background Vertices
	va_set_triangle3d( vertex_array, background_vertices, 6, mat_identity4, width_pixel, height_pixel );

	while(True) {
		_stopwatch_start();

		mat_translate = mtx32_translate3d( (obj)cube_position );
		mat_scale = mtx32_scale3d( (obj)cube_scale );
		mat_t_s = mtx32_multiply( mat_scale, mat_translate, 4 );
		versor = mtx32_versor( angle, (obj)versor_vector );
		mat_versor = mtx32_versortomatrix( versor );
		mat_model = mtx32_multiply( mat_t_s, mat_versor, 4 );
		mat_p_v_m = mtx32_multiply( mat_p_v, mat_model, 4 );
		va_count = 6; // Offset for Background Vertices
		va_set_triangle3d( vertex_array, cube_vertices, 36, mat_p_v_m, width_pixel, height_pixel );
		heap32_mfree( mat_translate );
		heap32_mfree( mat_scale );
		heap32_mfree( mat_t_s );
		heap32_mfree( versor );
		heap32_mfree( mat_versor );
		heap32_mfree( mat_model );
		heap32_mfree( mat_p_v_m );

		_clear_cl_rendering( COLOR32_CYAN, 0xFFFFFF, 0x0, 0x0 );
		_setbuffer_cl_rendering( FB32_FRAMEBUFFER->addr );
		_set_nv_shaderstate( fragmentshader->gpu, vertex_array->gpu, 3, 24 );
		_set_overspillmemory( overspillmemory->gpu, 0x20000 );
		_execute_cl_binning( 4, 42, 0, 0xFF0000 ); // TRIANGLE, 42 Vertices, Index from 0
		_execute_cl_rendering( 0xFF0000 ); // The Point to Actually Draw Using Vertices

		// Angle Change
		angle = vfp32_fadd( angle, 1.0f );
		if( vfp32_fge( angle, 360.0f ) ) angle = 0.0f;

		// Position Change
		cube_position[0] = vfp32_fadd( cube_position[0], 0.01f );
		if( vfp32_fge( cube_position[0], 0.5f ) ) cube_position[0] = -0.5f;
		cube_position[2] = vfp32_fadd( cube_position[2], 0.04f );
		if( vfp32_fge( cube_position[2], 2.0f ) ) cube_position[2] = -2.0f;

		// Scale Change
		// For accuracy, calculate the distance between eye and object, but not this linear incrementation.
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

	heap32_mfree( mat_identity4 );
	heap32_mfree( mat_view );
	heap32_mfree( mat_projection );
	heap32_mfree( mat_p_v );
	_gpumemory_free( vertex_array );
	heap32_mfree( (obj)vertex_array );
	_gpumemory_free( additional_uniforms );
	heap32_mfree( (obj)additional_uniforms );
	_gpumemory_free( overspillmemory );
	heap32_mfree( (obj)overspillmemory );
	_fragmentshader_free( fragmentshader );
	heap32_mfree( (obj)fragmentshader );
	_texture2d_free( texture2d_0 );
	heap32_mfree( (obj)texture2d_0 );
	_texture2d_free( texture2d_background );
	heap32_mfree( (obj)texture2d_background );
	_texture2d_free( texture2d_1 );
	heap32_mfree( (obj)texture2d_1 );
	_texture2d_free( texture2d_2 );
	heap32_mfree( (obj)texture2d_2 );
	_unmake_cl_binning();
	_unmake_cl_rendering();
	_bind_objectv3d( 0 );  // Unbind
	heap32_mfree( (obj)objectv3d );

	return EXIT_SUCCESS;
}

void va_set_triangle3d( _GPUMemory* vertex_array, float32* vertices, uint32 num_vertex, obj matrix, uint32 width_pixel, uint32 height_pixel ) {
	float32 *vector_xyzw = (float32*)heap32_malloc( 4 );
	float32 *result;
	int16 int_x;
	int16 int_y;
	float32 width_float = vfp32_u32tof32( width_pixel );
	float32 height_float = vfp32_u32tof32( height_pixel );

	for ( uint32 i = 0; i < num_vertex; i++ ) {

		/* X of Vector*/
		vector_xyzw[0] = vertices[i*6];

		/* Y of Vector */
		vector_xyzw[1] = vertices[i*6+1];

		/* Z of Vector */
		vector_xyzw[2] = vertices[i*6+2];

		/* W of Vector */
		vector_xyzw[3] = 1.0f;

		result = (float32*)mtx32_multiply_vec( matrix, (obj)vector_xyzw, 4 );

		/* Software (-1.0f, 1.0f) Coordinate to Hardware (0.0f, 1.0f) Coordinate, Flip Y and Z Coordinate */
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

		/* Depth Offset and Scale */
		result[2] = vfp32_fadd( result[2], depth_offset );
		result[2] = vfp32_fmul( result[2], depth_scale );

		/* Multiply 0.0 to 1.0 Coordinates by Actual Width and Height of Framebuffer, Convert Float to Integer */
		int_x = vfp32_f32tos32( vfp32_fmul( result[0], width_float ) );
		int_y = vfp32_f32tos32( vfp32_fmul( result[1], height_float ) );

		vertex_array->arm[va_count*6].u32 = int_x*16|(int_y*16)<<16; // X and Y
		vertex_array->arm[va_count*6+1].f32 = result[2]; // Z
		vertex_array->arm[va_count*6+2].f32 = 1.0f; // W
		vertex_array->arm[va_count*6+3].f32 = vertices[i*6+3]; // S
		vertex_array->arm[va_count*6+4].f32 = vertices[i*6+4]; // T
		vertex_array->arm[va_count*6+5].f32 = vertices[i*6+5]; // Index of Back Color
		va_count++;

		heap32_mfree( (obj)result );
		arm32_dsb();
	}

	heap32_mfree( (obj)vector_xyzw );
}

