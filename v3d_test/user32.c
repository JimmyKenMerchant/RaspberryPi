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

/* Declare Global Variables Exported from data32.s */
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

/* Declare Global Variables Exported from vector32.s */
extern bool OS_FIQ_ONEFRAME;

/* Declare Unique Definitions */
#define MAXCOUNT_UPDATE 8 // 30Hz

typedef struct user32_Legend3D {
	uint32 image_index;
	float32 position[3];
	float32 speed_position[3];
	float32 scale[3];
	float32 versor_angle;
	float32 versor_vector[3];
} _Legend3D;

/* Declare Unique Functions */
void va_set_triangle3d( _GPUMemory* vertex_array, float32* vertices, uint32 num_vertex, _Legend3D* legend3d, obj mat_p_v, uint32 width_pixel, uint32 height_pixel );
void legend3D_change_position( _Legend3D* legend3d );

/* Declare Unique Global Variables, Zero Can't Be Stored If You Want to Define with Declaration */
uint32 va_count; // Global for Setting Vertex Array
uint32 count_update;

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

float32 camera_position[] = { 0.0f, 0.5f, 2.0f };
float32 camera_target[] = { 0.0001f, 0.0001f, 0.0001f }; // Don't Initialize by Zeros, It's Invalid!
float32 camera_up[] = { 0.0f, 1.0f, 0.0f };

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

	// Define Global Variables
	depth_offset = 0.0f;
	depth_scale = 0.5263f;
	va_count = 0; // Offset for Background Vertices
	count_update = 0;

	// Declare and Define Local Variables
	_ObjectV3D *objectv3d;
	_GPUMemory *vertex_array;
	_GPUMemory *additional_uniforms;
	_GPUMemory *overspillmemory;
	_FragmentShader *fragmentshader;
	_Texture2D *texture2d_0;
	_Texture2D *texture2d_background;
	_Texture2D *texture2d_1;
	_Texture2D *texture2d_2;
	_Legend3D *background;
	_Legend3D **cubes = (_Legend3D**)heap32_malloc( 2 );
	uint32 cubes_length = 0;
	uint32 width_pixel = FB32_WIDTH;
	uint32 height_pixel = FB32_HEIGHT;

	/**
	 * Note: Camera Position Upside Down, Leftside Right
	 *       The coordinate system for the camera position is rotated 180 degrees along with Z axis.
	 */
	obj mat_identity4 = mtx32_identity( 4 );
	obj mat_view = mtx32_view3d( (obj)camera_position, (obj)camera_target, (obj)camera_up );
	obj mat_projection = mtx32_perspective3d( 75.0f, 1.3333333f, 0.2f, 4.0f );
	obj mat_p_v = mtx32_multiply( mat_view, mat_projection, 4 ); // Projection, View

	vertex_array = (_GPUMemory*)heap32_malloc( _wordsizeof( _GPUMemory ) );
	_gpumemory_init( vertex_array, 1872, 16, 0xC );

	additional_uniforms = (_GPUMemory*)heap32_malloc( _wordsizeof( _GPUMemory ) );
	_gpumemory_init( additional_uniforms, 256, 16, 0xC );

	overspillmemory = (_GPUMemory*)heap32_malloc( _wordsizeof( _GPUMemory ) );
	_gpumemory_init( overspillmemory, 0x20000, 256, 0xC );

	fragmentshader = (_FragmentShader*)heap32_malloc( _wordsizeof( _FragmentShader ) );
	_fragmentshader_init( fragmentshader, DATA_V3D_FRAGMENT_SHADER2, DATA_V3D_FRAGMENT_SHADER2_SIZE );;

	texture2d_0 = (_Texture2D*)heap32_malloc( _wordsizeof( _Texture2D ) );
	_texture2d_init( texture2d_0, 1<<16|1, 32 * 32 * 4, 0 ); // Init Minimum Texture

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

	background = (_Legend3D*)heap32_malloc( _wordsizeof( _Legend3D ) );
	background->position[0] = 0.0f; // X
	background->position[1] = 0.0f; // Y
	background->position[2] = 0.0f; // Z
	background->speed_position[0] = 0.0f; // X
	background->speed_position[1] = 0.0f; // Y
	background->speed_position[2] = 0.0f; // Z
	background->scale[0] = 1.0f; // X
	background->scale[1] = 1.0f; // Y
	background->scale[2] = 1.0f; // Z
	background->versor_angle = 0.0f;
	background->versor_vector[0] = 0.0f; // X
	background->versor_vector[1] = 0.0f; // Y
	background->versor_vector[2] = 0.0f; // Z

	cubes[0] = (_Legend3D*)heap32_malloc( _wordsizeof( _Legend3D ) );
	cubes_length++;
	cubes[0]->position[0] = -0.5f; // X
	cubes[0]->position[1] = 0.0f; // Y
	cubes[0]->position[2] = -2.0f; // Z
	cubes[0]->speed_position[0] = 0.005f; // X
	cubes[0]->speed_position[1] = 0.0f; // Y
	cubes[0]->speed_position[2] = 0.02f; // Z
	cubes[0]->scale[0] = 0.5f; // X
	cubes[0]->scale[1] = 0.5f; // Y
	cubes[0]->scale[2] = 0.5f; // Z
	cubes[0]->versor_angle = 0.0f;
	cubes[0]->versor_vector[0] = 1.0f; // X
	cubes[0]->versor_vector[1] = 1.0f; // Y
	cubes[0]->versor_vector[2] = 1.0f; // Z

	cubes[1] = (_Legend3D*)heap32_malloc( _wordsizeof( _Legend3D ) );
	cubes_length++;
	cubes[1]->position[0] = -0.05f; // X
	cubes[1]->position[1] = 0.35f; // Y
	cubes[1]->position[2] = -0.2f; // Z
	cubes[1]->speed_position[0] = 0.005f; // X
	cubes[1]->speed_position[1] = 0.0f; // Y
	cubes[1]->speed_position[2] = 0.02f; // Z
	cubes[1]->scale[0] = 0.95f; // X
	cubes[1]->scale[1] = 0.95f; // Y
	cubes[1]->scale[2] = 0.95f; // Z
	cubes[1]->versor_angle = 0.0f;
	cubes[1]->versor_vector[0] = 1.0f; // X
	cubes[1]->versor_vector[1] = 1.0f; // Y
	cubes[1]->versor_vector[2] = 1.0f; // Z

	// Set Textures to Array
	additional_uniforms->arm[0].u32 = texture2d_background->gpu;
	additional_uniforms->arm[1].u32 = texture2d_1->gpu;
	additional_uniforms->arm[2].u32 = texture2d_2->gpu;

	// Make Control Lists for Binning and Rendering
	objectv3d = (_ObjectV3D*)heap32_malloc( _wordsizeof( _ObjectV3D ) );
	_bind_objectv3d( objectv3d );
	_make_cl_binning( width_pixel, height_pixel, 0b101 );
	_make_cl_rendering( width_pixel, height_pixel, 0b101 );
	_config_cl_binning( 0x039005 ); // Forward Primitive, CCW, Depth Test
	_set_texture2d( texture2d_0, 0x1A0, 0b10000, additional_uniforms->gpu ); // Texture Size Affects Speed of Shading

	// Treat Cache for QPU
	_control_qpul2cache( 0b101 );
	_clear_qpucache( 0x0F0F0F0F );

	va_count = 0; // Reset
	while(True) {
		if ( OS_FIQ_ONEFRAME ) {
			/**
			 * If the count reaches the number, update the display.
			 */
			if ( ++count_update >= MAXCOUNT_UPDATE ) { // Increment Count Before, Then Compare with Number
_stopwatch_start();

				// Actual Rendering
				_clear_cl_rendering( COLOR32_CYAN, 0xFFFFFF, 0x0, 0x0 );
				_setbuffer_cl_rendering( FB32_FRAMEBUFFER->addr );
				_set_nv_shaderstate( fragmentshader->gpu, vertex_array->gpu, 3, 24 );
				_set_overspillmemory( overspillmemory->gpu, 0x20000 );
				_execute_cl_binning( 4, va_count, 0, 0xFF0000 ); // TRIANGLE, 42 Vertices, Index from 0
				_execute_cl_rendering( 0xFF0000 ); // The Point to Actually Draw Using Vertices

				// Calculate Vertices, Z Sort is Needed for Proper Drawing
				va_count = 0; // Reset
				va_set_triangle3d( vertex_array, background_vertices, 6, background, mat_identity4, width_pixel, height_pixel );
				va_set_triangle3d( vertex_array, cube_vertices, 36, cubes[1], mat_p_v, width_pixel, height_pixel );
				va_set_triangle3d( vertex_array, cube_vertices, 36, cubes[0], mat_p_v, width_pixel, height_pixel );

				legend3D_change_position( cubes[0] );
				legend3D_change_position( cubes[1] );

uint32 time = _stopwatch_end();
String num_string = cvt32_int32_to_string_deci( time, 0, 0 );
print32_string( num_string, 0, 0, str32_strlen( num_string ) );
//print32_debug_hexa( FB32_FRAMEBUFFER->addr + ((800 * 324) + 400)*4, 0, 64, 256 );
heap32_mfree( (obj)num_string );

				count_update = 0;
			}
			OS_FIQ_ONEFRAME = False;
		}
		arm32_dsb();
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
	heap32_mfree( (obj)background );
	heap32_mfree( (obj)cubes[0] );
	heap32_mfree( (obj)cubes[1] );
	heap32_mfree( (obj)cubes );
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

void va_set_triangle3d( _GPUMemory* vertex_array, float32* vertices, uint32 num_vertex, _Legend3D* legend3d, obj mat_p_v, uint32 width_pixel, uint32 height_pixel ) {
	float32 *vector_xyzw = (float32*)heap32_malloc( 4 );
	float32 *result;
	int16 int_x;
	int16 int_y;
	float32 width_float = vfp32_u32tof32( width_pixel );
	float32 height_float = vfp32_u32tof32( height_pixel );
	obj mat_translate = mtx32_translate3d( (obj)legend3d->position );
	obj mat_scale = mtx32_scale3d( (obj)legend3d->scale );
	obj mat_t_s = mtx32_multiply( mat_scale, mat_translate, 4 ); // Translate and Scale
	obj versor = mtx32_versor( legend3d->versor_angle, (obj)legend3d->versor_vector );
	obj mat_versor = mtx32_versortomatrix( versor );
	obj mat_model = mtx32_multiply( mat_t_s, mat_versor, 4 );
	obj mat_p_v_m = mtx32_multiply( mat_p_v, mat_model, 4 ); // Projection, View, Model

	for ( uint32 i = 0; i < num_vertex; i++ ) {

		/* X of Vector*/
		vector_xyzw[0] = vertices[i*6];

		/* Y of Vector */
		vector_xyzw[1] = vertices[i*6+1];

		/* Z of Vector */
		vector_xyzw[2] = vertices[i*6+2];

		/* W of Vector */
		vector_xyzw[3] = 1.0f;

		result = (float32*)mtx32_multiply_vec( mat_p_v_m, (obj)vector_xyzw, 4 );

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

print32_debug( mat_versor, 0, 50 );

	heap32_mfree( (obj)vector_xyzw );
	heap32_mfree( mat_translate );
	heap32_mfree( mat_scale );
	heap32_mfree( mat_t_s );
	heap32_mfree( versor );
	heap32_mfree( mat_versor );
	heap32_mfree( mat_model );
	heap32_mfree( mat_p_v_m );
}

void legend3D_change_position( _Legend3D* legend3d ) {
	// Angle Change
	legend3d->versor_angle = vfp32_fadd( legend3d->versor_angle, 0.5f );
	if( vfp32_fge( legend3d->versor_angle, 360.0f ) ) legend3d->versor_angle = 0.0f;

	// Position Change
	legend3d->position[0] = vfp32_fadd( legend3d->position[0], legend3d->speed_position[0] ); // X
	if( vfp32_fge( legend3d->position[0], 0.5f ) ) legend3d->position[0] = -0.5f;
	legend3d->position[2] = vfp32_fadd( legend3d->position[2], legend3d->speed_position[2] ); // Z
	if( vfp32_fge( legend3d->position[2], 2.0f ) ) legend3d->position[2] = -2.0f;

	// Scale Change
	// For accuracy, calculate the distance between eye and object, but not this linear incrementation.
	legend3d->scale[0] = vfp32_fadd( legend3d->scale[0], 0.005f );
	if( vfp32_fge( legend3d->scale[0], 1.5f ) ) legend3d->scale[0] = 0.5f;
	legend3d->scale[1] = vfp32_fadd( legend3d->scale[1], 0.005f );
	if( vfp32_fge( legend3d->scale[1], 1.5f ) ) legend3d->scale[1] = 0.5f;
	legend3d->scale[2] = vfp32_fadd( legend3d->scale[2], 0.005f );
	if( vfp32_fge( legend3d->scale[2], 1.5f ) ) legend3d->scale[2] = 0.5f;
}

