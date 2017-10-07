/**
 * system32.h
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

#ifndef AARCH32

#define AARCH32

#endif


/********************************
 * Unique Difinition
 ********************************/

#define uchar8 unsigned char
#define uint16 unsigned short int
#define uint32 unsigned long int
#define uint64 unsigned long long int
#define char8 char // Use as Pointer Too, Signed/Unsigned is Typically Unknown
#define int16 short int
#define int32 long int // Use as Pointer Too, Signed/Unsigned is Typically Unknown
#define int64 long long int
#define float32 float
#define float64 double

void _user_start();


/********************************
 * system32/system32.s
 ********************************/

/**
 * Convert Endianness
 *
 * Return: 0 as sucess, 1 as error
 * Error: Align Bytes is not 2/4
 */
extern uint32 system32_convert_endianness
(
	int32* data,
	uint32 size,
	uint32 align_bytes
);

extern void system32_no_op();

extern void system32_sleep( uint32 u_seconds );

extern void system32_store_32( int32* address, int32 data);

extern void system32_store_16( int16* address, int16 data);

extern void system32_store_8( char8* address, char8 data);

extern int32 system32_load_32( int32* address );

extern int16 system32_load_16( int16* address );

extern char8 system32_load_8( char8* address );

extern int32* system32_malloc( uint32 block_size );

extern uint32 system32_mfree( int32* address );

extern uint32 system32_memcpy( int32* address_dst, int32* address_src );

extern void system32_dsb();

extern void system32_msb();

extern void system32_isb();


/********************************
 * system32/fb32.s
 ********************************/

extern int32* FB32_FRAMEBUFFER;
extern int32* FB32_DOUBLEBUFFER_BACK;
extern int32* FB32_DOUBLEBUFFER_FRONT;

extern uint32 FB32_ADDR;
extern uint32 FB32_WIDTH;
extern uint32 FB32_HEIGHT;
extern uint32 FB32_SIZE;
extern uint32 FB32_DEPTH;
extern int32 FB32_X_CARET;
extern int32 FB32_Y_CARET;

/**
 * Draw Arc
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 * |Radius| <= PI is Preferred. If you want a circle, use -180 degrees to 180 degrees, i.e., -PI to PI.
 *
 * Return: Lower32 bits (0 as success, 1 as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Part of Circle from Last Coordinate was Not Drawn, Caused by Buffer Overflow
 */
extern uint64 fb32_draw_arc
(
	uint32 color,
	int32 x_coord,
	int32 y_coord,
	uint32 x_radius,
	uint32 y_radius,
	float32 start_radian,
	float32 end_radian,
	uint32 width,
	uint32 height
);

/**
 * Draw Circle Filled with Color
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Lower 32 bits (0 as sucess, 1 as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Part of Circle from Last Coordinate was Not Drawn, Caused by Framebuffer Overflow
 */
extern uint64 fb32_draw_circle
(
	uint32 color,
	int32 x_coord,
	int32 y_coord,
	uint32 x_radius,
	uint32 y_radius
);


/**
 * Draw Line
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Lower 32 bits (0 as sucess, 1 as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Part of Line from Last Coordinate was Not Drawn, Caused by Framebuffer Overflow
 */

extern uint64 fb32_draw_line
(
	uint32 color,
	int32 x_coord_1,
	int32 y_coord_1,
	int32 x_coord_2,
	int32 y_coord_2,
	uint32 width,
	uint32 height
);


/**
 * Draw Image
 *
 * Return: 0 as sucess, 1 and 2 as error
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 */
extern uint64 fb32_draw_image
(
	int32* image_point,
	int32 x_coord,
	int32 y_coord,
	uint32 width,
	uint32 height,
	uint32 x_offset,
	uint32 y_offset,
	uint32 x_crop,
	uint32 y_crop
);


/**
 * Clear Block by Color
 *
 * Return: 0 as sucess, 1 and 2 as error
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 */
extern uint64 fb32_clear_color_block
(
	uint32 color,
	int32 x_coord,
	int32 y_coord,
	uint32 width,
	uint32 height
);


/**
 * Fill Out Framebuffer by Color
 *
 * Return: 0 as sucess, 1 as error
 * Error(1): When Framebuffer is not Defined
 */
extern uint64 fb32_clear_color
(
	uint32 color
);


/**
 * Flush Back Buffer to Framebuffer and Swap Front and Back
 *
 * Return: 0 as sucess, 1 as error
 * Error(1): When buffer is not defined
 */
extern uint32 fb32_flush_doublebuffer();


/**
 * Set Buffer for Double Buffer Operation
 *
 * Parameters
 * r0: Pointer of Buffer to Front
 * r1: Pointer of Buffer to Back
 *
 * Return: 0 as success, 1 as error
 * Error(1): When buffer is not Defined
 */
extern uint32 fb32_set_doublebuffer
(
	int32* buffer_front,
	int32* buffer_back

);


/**
 * Attach Buffer to Draw on It
 *
 * Return: 0 as sucess, 1 as error
 * Error(1): Buffer In is not Defined
 */
extern uint32 fb32_attach_buffer
(
	int32* buffer
);


/********************************
 * system32/print32.s
 ********************************/

/**
 * Set Caret Position from Return Vlue of `print_*` functions
 *
 * Return: Number of Characters Which Were Not Drawn
 */
extern uint32 print32_set_caret
(
	uint64 return_print
);


/**
 * Concatenation of Two Strings
 *
 * Return: Pointer of Concatenated String
 */
extern char8* print32_strcat
(
	char8* string1,
	char8* string2
);


/**
 * Count 1-Byte Words of String
 *
 * Return: Number of Words Maximum of 4,294,967,295 words
 */
extern uint32 print32_strlen
(
	char8* string
);


/**
 * rint String with 1 Byte Character
 *
 * Return: Lower 32 bits (0 as sucess, 1 and more as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
extern uint64 print32_string
(
	char8* string,
	int32 x_coord,
	int32 y_coord,
	uint32 color,
	uint32 back_color,
	uint32 length,
	uint32 width,
	uint32 height,
	int32* font_base
);


/**
 * Print Hexadecimal System (Base 16) Numbers in 64-bit (16 Digits)
 *
 * Return: Lower 32 bits (0 as sucess, 1 and more as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
extern uint64 print32_number_double
(
	uint64 number,
	int32 x_coord,
	int32 y_coord,
	uint32 color,
	uint32 back_color,
	uint32 length,
	uint32 width,
	uint32 height,
	int32* font_base
);


/**
 * Print Hexadecimal System (Base 16) Numbers in 32-bit (8 Digits)
 *
 * Return: Lower 32 bits (0 as sucess, 1 and more as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
extern uint64 print32_number
(
	uint32 number,
	int32 x_coord,
	int32 y_coord,
	uint32 color,
	uint32 back_color,
	uint32 length,
	uint32 width,
	uint32 height,
	int32* font_base
);


/********************************
 * system32/draw32.s
 ********************************/

/**
 * Anti-aliasing
 * Caution! This Function is Used in 32-bit Depth Color
 * First and Last Pixel of Base is not anti-aliased, and there is no horizontal sync.
 *
 * Return: 0 as success, 1 and 2 as error
 * Error(1): When Buffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Buffer is not Defined, or Depth is not 32-bit
 */

extern uint64 draw32_antialias
(
	int32* buffer_result,
	int32* buffer_base
);

/**
 * Fill by Color
 *
 * Return: 0 as sucess, 1 and 2 as error
 * Error(1): When Buffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Buffer is not Defined
 */
extern uint64 draw32_fill_color
(
	int32* buffer
);


/**
 * Make Masked Image to Mask
 *
 * Return: 0 as sucess, 1 and 2 as error
 * Error(1): When Buffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Buffer is not Defined
 */
extern uint64 draw32_mask_image
(
	int32* buffer_mask,
	int32* buffer_base,
	int32 x_coord, // Mask
	int32 y_coord // Mask
);


/**
 * Change Value of Alpha Channel in ARGB Data
 * Caution! This Function is Used in 32-bit Depth Color
 *
 * Return: 0 as sucess
 */
extern uint32 draw32_change_alpha_argb
(
	int32* data,
	uint32 size,
	uint32 alpha // 0-7 bits
);


/**
 * Convert 32-bit Depth Color RBGA to ARGB
 *
 * Return: 0 as sucess
 */
extern uint32 draw32_rgba_to_argb
(
	int32* data,
	uint32 size
);


/**
 * Copy Framebuffer to Renderbuffer
 *
 * Return: 0 as sucess, 1 as error
 * Error(1): Buffer In is not Defined
 */
extern uint32 draw32_copy
(
	int32* buffer_in,
	int32* buffer_out
);


/**
 * Set Renderbuffer
 *
 * Render Buffer Will Be Set with Heap.
 * Content of Render Buffer is Same as Framebuffer.
 * First is Address of Buffer, Second is Width, Third is Height, Fourth is Size, Fifth is Depth.
 * So, Block Size is 5 (20 Bytes).
 *
 * Return: 0 as sucess
 */
extern uint32 draw32_set_renderbuffer
(
	int32* buffer,
	uint32 width,
	uint32 height,
	uint32 depth
);



/********************************
 * system32/math32.s
 ********************************/

/**
 * Return Radian from Degrees
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Value by Single Precision Float
 */
extern float32 math32_degree_to_radian32
(
	int32 degree
);


/**
 * Return sin(Radian) by Single Precision Float, Using Maclaurin (Taylor) Series, Untill n = 4
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Value by Single Precision Float
 */
extern float32 math32_sin32
(
	float32 radian
);


/**
 * Return cos(Radian) by Single Precision Float, Using Maclaurin (Taylor) Series, Untill n = 4
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Value by Single Precision Float
 */
extern float32 math32_cos32
(
	float32 radian
);


/**
 * Return tan(Radian) by Single Precision Float, Using Maclaurin (Taylor) Series, Untill n = 5
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 * Radian Must be |Radian| < pi, -pi through pi
 *
 * Return: Value by Single Precision Float
 */
extern float32 math32_tan32
(
	float32 radian
);


/**
 * Make String of Single Precision Float Value
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 * If Float Value Exceeds 1,000,000,000.0, String Will Be Shown With Exponent and May Have Loss of Signification.
 * If Float Value is less than 1.0, String Will Be Shown With Exponent.
 *
 * Return: Pointer of String, If Zero, Memory Space for String Can't Be Allocated
 */
extern char8* math32_float32_to_string
(
	float32 float_number,
	uint32 min_integer,  // 16 Digits Max
	uint32 max_decimal,  // Default 8 Digits
	uint32 min_exponent  // 16 Digits Max
);


/**
 * Make String of Integer Value by Decimal System (Base 10)
 *
 * Return: Pointer of String, If Zero, Memory Space for String Can't Be Allocated
 */
extern char8* math32_int32_to_string_deci
(
	int32 number,      // If You Use This for uint32, You Need to Cast It to int32 
	uint32 min_length,
	uint32 bool_signed
);


/**
 * Make String of Integer Value by Hexadecimal System (Base 16)
 *
 * Return: Pointer of String, If Zero, Memory Space for String Can't Be Allocated
 */
extern char8* math32_int32_to_string_hexa
(
	int32 number,      // If You Use This for uint32, You Need to Cast It to int32 
	uint32 min_length,
	uint32 bool_signed,
	uint32 bool_basemark
);


/********************************
 * system32/font_mono_12px.s
 ********************************/

extern int32* FONT_MONO_12PX_ASCII;


/**
 * system32/color.s
 */

extern uint16 COLOR16_RED;
extern uint16 COLOR16_GREEN;
extern uint16 COLOR16_BLUE;
extern uint16 COLOR16_YELLOW;
extern uint16 COLOR16_MAGENTA;
extern uint16 COLOR16_CYAN;
extern uint16 COLOR16_PINK;
extern uint16 COLOR16_LIME;
extern uint16 COLOR16_SKYBLUE;
extern uint16 COLOR16_LIGHTYELLOW;
extern uint16 COLOR16_SCARLET;
extern uint16 COLOR16_DARKGREEN;
extern uint16 COLOR16_NAVYBLUE;
extern uint16 COLOR16_WHITE;
extern uint16 COLOR16_LIGHTGRAY;
extern uint16 COLOR16_GRAY;
extern uint16 COLOR16_BLACK;
extern int32* COLOR16_SAMPLE_IMAGE;

extern uint32 COLOR32_RED;
extern uint32 COLOR32_GREEN;
extern uint32 COLOR32_BLUE;
extern uint32 COLOR32_YELLOW;
extern uint32 COLOR32_MAGENTA;
extern uint32 COLOR32_CYAN;
extern uint32 COLOR32_PINK;
extern uint32 COLOR32_LIME;
extern uint32 COLOR32_SKYBLUE;
extern uint32 COLOR32_LIGHTYELLOW;
extern uint32 COLOR32_SCARLET;
extern uint32 COLOR32_DARKGREEN;
extern uint32 COLOR32_NAVYBLUE;
extern uint32 COLOR32_WHITE;
extern uint32 COLOR32_LIGHTGRAY;
extern uint32 COLOR32_GRAY;
extern uint32 COLOR32_BLACK;


/********************************
 * system32/data.s
 ********************************/

extern int32* DATA_COLOR32_SAMPLE_IMAGE0;
extern uint32 DATA_COLOR32_SAMPLE_IMAGE0_SIZE;
extern int32* DATA_COLOR32_SAMPLE_IMAGE1;
extern uint32 DATA_COLOR32_SAMPLE_IMAGE1_SIZE;