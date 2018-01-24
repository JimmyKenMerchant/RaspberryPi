/**
 * system32.h
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

#ifndef __AARCH32

#define __AARCH32

#endif


/********************************
 * Unique Definitions
 ********************************/

/* Constants */

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

#ifndef bool
#define bool unsigned char
#endif
#ifndef true
#define true 1
#endif
#ifndef false
#define false 0
#endif
#ifndef TRUE
#define TRUE 1
#endif
#ifndef FALSE
#define FALSE 0
#endif

#define obj uint32

/* Pointers, Array of Address of Data */
#define String char8*
#define ObjArray obj*

/**
 * GPIO Control and Status (Limited Between 0-29)
 */
#ifdef __BCM2835
	#define _gpio_base   0x20200000
#else
	/* BCM2836 and BCM2837 Peripheral Base */
	#define _gpio_base   0x3F200000
#endif

#define _gpio_gpfsel00     0x00 // GPIO 0-9   Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
#define _gpio_gpfsel10     0x04 // GPIO 10-19 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
#define _gpio_gpfsel20     0x08 // GPIO 20-29 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions

#define _gpio_gpfsel_0     0 // LSL
#define _gpio_gpfsel_1     3 // LSL
#define _gpio_gpfsel_2     6 // LSL
#define _gpio_gpfsel_3     9 // LSL
#define _gpio_gpfsel_4     12 // LSL
#define _gpio_gpfsel_5     15 // LSL
#define _gpio_gpfsel_6     18 // LSL
#define _gpio_gpfsel_7     21 // LSL
#define _gpio_gpfsel_8     24 // LSL
#define _gpio_gpfsel_9     27 // LSL

#define _gpio_gpfsel_input    0b000
#define _gpio_gpfsel_output   0b001
#define _gpio_gpfsel_alt0     0b100
#define _gpio_gpfsel_alt1     0b101
#define _gpio_gpfsel_alt2     0b110
#define _gpio_gpfsel_alt3     0b111
#define _gpio_gpfsel_alt4     0b011
#define _gpio_gpfsel_alt5     0b010
#define _gpio_gpfsel_clear    0b111 // Use With Bit Clear

#define _gpio_gpset0      0x1C // GPIO 0-31, Output Set, each 1 bit, 0 no effect, 1 set Pin
#define _gpio_gpclr0      0x28 // GPIO 0-31, Output Clear, 0 no effect, 1 clear Pin
#define _gpio_gplev0      0x34 // GPIO 0-31, Actual Pin Level, 0 law, 1 high
#define _gpio_gpeds0      0x40 // GPIO 0-31, Event Detect Status, 0 not detect, 1 detect, write 1 to clear
#define _gpio_gpren0      0x4C // GPIO 0-31, Rising Edge Detect, 0 disable, 1 detection corresponds to gpeds_n
#define _gpio_gpfen0      0x58 // GPIO 0-31, Falling Edge Detect, 0 disable, 1 detection corresponds to gpeds_n
#define _gpio_gphen0      0x64 // GPIO 0-31, High Detect, 0 disable, 1 detection corresponds to gpeds_n
#define _gpio_gplen0      0x70 // GPIO 0-31, Low Detect, 0 disable, 1 detection corresponds to gpeds_n
#define _gpio_gparen0     0x7C // GPIO 0-31, Async Rising Edge Detect, 0 disable, 1 detection corresponds to gpeds_n
#define _gpio_gpafen0     0x88 // GPIO 0-31, Async Falling Edge Detect, 0 disable, 1 detection corresponds to gpeds_n


/**
 * System calls
 * On _user_start, CPU runs with User mode. To access restricted memory area to write, usage of System calls is needed.
 * Plus, peripherals can't be directly accessed to write/read through user mode, and only can be accessed through System calls. 
 */

__attribute__((noinline)) uint32 _example_svc_0( int32 a, int32 b, int32 c, int32 d );


/* Regular Functions */

void _user_start();

bool _gpio_detect( uchar8 gpio_number );


/********************************
 * system32/arm/arm32.s
 ********************************/

extern uint32 ARM32_STOPWATCH_LOW;
extern uint32 ARM32_STOPWATCH_HIGH;

/* Relative System Calls  */

__attribute__((noinline)) void _stopwatch_start();

__attribute__((noinline)) uint32 _stopwatch_end();

__attribute__((noinline)) void _sleep( uint32 u_seconds );

__attribute__((noinline)) uchar8 _random( uchar8 range_end );

__attribute__((noinline)) void _store_8( uint32 address, char8 data );

__attribute__((noinline)) char8 _load_8( uint32 address );

__attribute__((noinline)) void _store_16( uint32 address, int16 data );

__attribute__((noinline)) int16 _load_16( uint32 address );

__attribute__((noinline)) void _store_32( uint32 address, int32 data );

__attribute__((noinline)) int32 _load_32( uint32 address );


/* Regular Functions */

/**
 * Convert Endianness
 *
 * Return: 0 as sucess, 1 as error
 * Error: Align Bytes is not 2/4
 */
extern uint32 arm32_convert_endianness
(
	uint32 address_word,
	uint32 size,
	uint32 align_bytes
);

extern void arm32_no_op();

extern void arm32_dsb();

extern void arm32_msb();

extern void arm32_isb();


/********************************
 * system32/arm/uart32.s
 ********************************/

__attribute__((noinline)) uint32 _uartinit
(
	uint32 div_int,
	uint32 div_frac,
	uint32 line_ctl,
	uint32 ctl
);

__attribute__((noinline)) uint32 _uartsetint
(
	uint32 int_fifo,
	uint32 int_mask
);

__attribute__((noinline)) uint32 _uartclrint();

__attribute__((noinline)) uint32 _uarttx
(
	String address_heap,
	uint32 size
);

__attribute__((noinline)) uint32 _uartrx
(
	String address_heap,
	uint32 size
);

__attribute__((noinline)) uint32 _uartclrrx();

__attribute__((noinline)) uint32 _uartsetheap
(
	uint32 num_heap
);


/********************************
 * system32/arm/gpio32.s
 ********************************/

/* Constants */

#define gpio_sequence uint32


/* Relative System Calls  */

__attribute__((noinline)) uint32 _gpioset( gpio_sequence* gpio, uint32 length, uint32 count, int32 repeat );

__attribute__((noinline)) uint32 _gpioclear( bool stay ); // Clear All (false) or Stay GPIO Status (true)


/* Regular Functions */

/**
 * Play GPIO Sequence
 *
 * Return: 0 as success, 1 as error
 * Error: GPIO Sequence is not assigned
 */
extern uint32 gpio32_gpioplay();


/**
 * Count 4-Bytes Beats of GPIO Sequence
 *
 * Return: Number of Beats in GPIO Sequence, Maximum of 4,294,967,295 Beats
 */
extern uint32 gpio32_gpiolen
(
	gpio_sequence* gpio
);


/********************************
 * system32/library/vfp32.s
 ********************************/

extern uint32 vfp32_f32tohexa( float32 value );

extern float32 vfp32_hexatof32( uint32 value );

extern float32 vfp32_s32tof32( int32 value );

extern float32 vfp32_u32tof32( uint32 value );

extern int32 vfp32_f32tos32( float32 value );

extern uint32 vfp32_f32tou32( float32 value );

extern uint32 vfp32_fcmp
(
	float32 value1,
	float32 value2
);

extern bool vfp32_feq
(
	float32 value1,
	float32 value2
);

extern bool vfp32_fgt
(
	float32 value1,
	float32 value2
);

extern bool vfp32_flt
(
	float32 value1,
	float32 value2
);

extern bool vfp32_fge
(
	float32 value1,
	float32 value2
);

extern bool vfp32_fle
(
	float32 value1,
	float32 value2
);

extern float32 vfp32_fadd
(
	float32 value1,
	float32 value2
);

extern float32 vfp32_fsub
(
	float32 value1,
	float32 value2
);

extern float32 vfp32_fmul
(
	float32 value1,
	float32 value2
);

extern float32 vfp32_fdiv
(
	float32 value1,
	float32 value2
);


/********************************
 * system32/library/fb32.s
 ********************************/

/* Constants */

extern uint32 FB32_FRAMEBUFFER;
extern uint32 FB32_DOUBLEBUFFER_BACK;
extern uint32 FB32_DOUBLEBUFFER_FRONT;

extern uint32 FB32_ADDR;
extern uint32 FB32_WIDTH;
extern uint32 FB32_HEIGHT;
extern uint32 FB32_SIZE;
extern uint32 FB32_DEPTH;
extern int32 FB32_X_CARET;
extern int32 FB32_Y_CARET;


/* Relative System Calls  */

/**
 * Flush Back Buffer to Framebuffer and Swap Front and Back
 *
 * Return: 0 as sucess, 1 as error
 * Error(1): When buffer is not defined
 */
__attribute__((noinline)) uint32 _flush_doublebuffer();


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
__attribute__((noinline)) uint32 _set_doublebuffer( uint32 address_buffer_front, uint32 address_buffer_back );


/**
 * Attach Buffer to Draw on It
 *
 * Return: 0 as sucess, 1 as error
 * Error(1): Buffer In is not Defined
 */
__attribute__((noinline)) uint32 _attach_buffer( uint32 address_buffer );


/* Regular Functions */

/**
 * Draw Image
 *
 * Return: 0 as sucess, 1 and 2 as error
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 */
extern uint32 fb32_image
(
	uint32 address_image,
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
 * Place Colored Block
 *
 * Return: 0 as sucess, 1 and 2 as error
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 */
extern uint32 fb32_block_color
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
extern uint32 fb32_clear_color
(
	uint32 color
);


/********************************
 * system32/library/print32.s
 ********************************/

/**
 * Print Hexadecimal Values in Heap for Debug Use
 *
 * Return: 0 as sucess
 */
extern uint32 print32_debug_hexa
(
	uint32 address_heap,
	int32 x_coord,
	int32 y_coord,
	uint32 length
);


/**
 * Print Number in Register for Debug Use
 *
 * Return: 0 as sucess
 */
extern uint32 print32_debug
(
	uint32 value,
	int32 x_coord,
	int32 y_coord
);


/**
 * Set Caret Position from Return Vlue of `print_*` functions
 *
 * Return: 0 as success, 1 as error
 * Error: Y Caret Reaches Value of Height
 */
extern uint32 print32_set_caret
(
	uint64 return_print
);


/**
 * Search Second Key String in First String
 *
 * Return: Index of First Character in String, if not -1
 */
extern int32 print32_strindex
(
	String string,
	String string_key
);


/**
 * Search Byte Character in String
 *
 * Return: Index of Character, if not -1
 */
extern int32 print32_charindex
(
	String string,
	char8 character_key
);


/**
 * Search Byte Character in String within Range
 *
 * Return: Index of Character, if not -1
 */
extern int32 print32_charsearch
(
	String string,
	uint32 length_string,
	char8 character_key
);


/**
 * Search Second Key String in First String within Range
 *
 * Return: Index of First Character in String, if not -1
 */
extern int32 print32_strsearch
(
	String string,
	uint32 length_string,
	String string_key,
	uint32 length_string_key
);


/**
 * Count Byte Character in String
 *
 * Return: Number of Counts for Character Key
 */
extern uint32 print32_charcount
(
	String string,
	uint32 length,
	char8 character_key
);


/**
 * Concatenation of Two Strings
 * Caution! On the standard C Langage string.h library, strcat returns Pointer of Array of the first argument with
 * the concatenated string. That needs to have enough spaces of memory on the first one to concatenate.
 * But that makes buffer overflow easily. So in this function, print32_strcat returns new Pointer of Array.
 * Note that this function makes new memory space to be needed to make the memory free.
 *
 * Return: Pointer of Concatenated String
 */
extern String print32_strcat
(
	String string1,
	String string2
);


/**
 * Make Array of String List from One String
 * Caution! This Function Generates Two-dimensional Array in Heap Area.
 *
 * Return: Pointer of Two-dimensional Array of List, if 0, no enough space for new Pointer of Array
 */
extern obj print32_strlist
(
	String string,
	uint32 length_string,
	char8 separater
);


/**
 * Count 1-Byte Words of String
 *
 * Return: Number of Words Maximum of 4,294,967,295 words
 */
extern uint32 print32_strlen
(
	String string
);


/**
 * rint String with 1 Byte Character
 *
 * Return: Lower 32 bits (0 as sucess, 1 and more as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
extern uint64 print32_string
(
	String string,
	int32 x_coord,
	int32 y_coord,
	uint32 color,
	uint32 back_color,
	uint32 length,
	uint32 width,
	uint32 height,
	uint32 address_font_base
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
	uint32 address_font_base
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
	uint32 address_font_base
);


/********************************
 * system32/library/draw32.s
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

extern uint32 draw32_antialias
(
	uint32 address_buffer_result,
	uint32 address_buffer_base
);

/**
 * Fill by Color
 *
 * Return: 0 as sucess, 1 and 2 as error
 * Error(1): When Buffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Buffer is not Defined
 */
extern uint32 draw32_fill_color
(
	uint32 address_buffer
);


/**
 * Make Masked Image to Mask
 *
 * Return: 0 as sucess, 1 and 2 as error
 * Error(1): When Buffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Buffer is not Defined
 */
extern uint32 draw32_mask_image
(
	uint32 address_buffer_mask,
	uint32 address_buffer_base,
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
	uint32 address_image,
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
	uint32 address_image,
	uint32 size
);


enum Object_draw32_renderbuffer {
	draw32_renderbuffer        = 5, // Size of Object (Words)
	draw32_renderbuffer_addr   = 0, // Offset in Object
	draw32_renderbuffer_width  = 4, // Offset in Object
	draw32_renderbuffer_height = 8, // Offset in Object
	draw32_renderbuffer_size   = 12, // Offset in Object
	draw32_renderbuffer_depth  = 16 // Offset in Object
};

/**
 * Initialize Renderbuffer
 *
 * Render Buffer Will Be Set with Heap.
 * Content of Render Buffer is Same as Framebuffer.
 * First is Address of Buffer, Second is Width, Third is Height, Fourth is Size, Fifth is Depth.
 * So, Block Size is 5 (20 Bytes).
 *
 * Return: 0 as sucess
 */
extern uint32 draw32_renderbuffer_init
(
	uint32 address_buffer,
	uint32 width,
	uint32 height,
	uint32 depth
);

/**
 * Clear Renderbuffer with Freeing Memory
 *
 * Return: 0 as success, 1 as error
 * Error: Pointer of Buffer is Null (0)
 */
extern uint32 draw32_renderbuffer_free
(
	uint32 address_buffer
);

/* End Object_draw32_renderbuffer */


/**
 * Copy Framebuffer to Renderbuffer
 *
 * Return: 0 as sucess, 1 as error
 * Error(1): Buffer In is not Defined
 */
extern uint32 draw32_copy
(
	uint32 address_buffer_in,
	uint32 address_buffer_out
);


/**
 * Draw Cubic Bezier Curve
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Return: Lower32 bits (0 as success, 1 as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Buffer is Not Defined
 */
extern uint64 draw32_bezier
(
	uint32 color,
	int32 x_point0,
	int32 y_point0,
	int32 x_point1,
	int32 y_point1,
	int32 x_point2,
	int32 y_point2,
	int32 x_point3,
	int32 y_point3,
	uint32 width,
	uint32 height
);


/**
 * Draw Arc by Radian with Single Precision Float
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 * |Radius| <= PI is Preferred. If you want a circle, use -180 degrees to 180 degrees, i.e., -PI to PI.
 *
 * Return: Lower32 bits (0 as success, 1 as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Buffer is Not Defined
 */
extern uint64 draw32_arc
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
 * Error: Buffer is Not Defined
 */
extern uint64 draw32_circle
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
 * Error: Buffer is Not Defined
 */

extern uint64 draw32_line
(
	uint32 color,
	int32 x_coord_1,
	int32 y_coord_1,
	int32 x_coord_2,
	int32 y_coord_2,
	uint32 width,
	uint32 height
);


/********************************
 * system32/library/snd32.s
 ********************************/

/* Constants */

#define sound_index uint16
#define music_code uint16


/* Relative System Calls  */

__attribute__((noinline)) uint32 _sounddecode( sound_index* sound );

__attribute__((noinline)) uint32 _soundset( music_code* music, uint32 length, uint32 count, int32 repeat );

__attribute__((noinline)) uint32 _soundinterrupt( music_code* music, uint32 length, uint32 count, int32 repeat );

__attribute__((noinline)) uint32 _soundclear();


/* Regular Functions */

/**
 * Count 2-Bytes Beats of Music Code
 *
 * Return: Number of Beats in Music Code, Maximum of 4,294,967,295 Beats
 */
extern uint32 snd32_musiclen
(
	music_code* music
);


/********************************
 * system32/library/math32.s
 ********************************/

/* Constants */

extern float32 MATH32_PI;
extern float32 MATH32_PI_DOUBLE;
extern float32 MATH32_PI_HALF;
extern float32 MATH32_PI_PER_DEGREE;


/* Regular Functions */

/**
 * Return Rounded Degrees Between 0 to 360 with Single Precision Float
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Return: Value by Single Precision Float
 */
extern float32 math32_round_degree
(
	float32 degree
);


/**
 * Return Radian from Degrees
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Value by Single Precision Float
 */
extern float32 math32_degree_to_radian
(
	float32 degree
);


/**
 * Return sin(Radian) by Single Precision Float, Using Maclaurin (Taylor) Series, Untill n = 3
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Value by Single Precision Float
 */
extern float32 math32_sin
(
	float32 radian
);


/**
 * Return cos(Radian) by Single Precision Float, Using Sine's Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Value by Single Precision Float
 */
extern float32 math32_cos
(
	float32 radian
);


/**
 * Return tan(Radian) by Single Precision Float, Using Sine's Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 * Radian Must be |Radian| < pi, -pi through pi
 *
 * Return: Value by Single Precision Float
 */
extern float32 math32_tan
(
	float32 radian
);


/**
 * Return Natural Logarithm, Using Maclaurin (Taylor) Series, Untill n = 5
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Return: Value, Must Be Type of Single Precision Float and Signed Plus
 */
extern float32 math32_ln
(
	float32 value
);


/**
 * Return Common Logarithm, Using Natural Logarithm's Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Return: Value, Must Be Type of Single Precision Float and Signed Plus
 */
extern float32 math32_log
(
	float32 value
);


/**
 * Multiplies Two Matrix with Single Precision Float
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Return: Matrix to Be Calculated, If Zero Not Allocated Memory
 */
extern obj math32_mat_multiply
(
	obj matrix1,
	obj matrix2,
	uint32 number
);


/**
 * Get Identity of Matrix
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Return: Matrix to Have Identity, If Zero Not Allocated Memory
 */
extern obj math32_mat_identity
(
	uint32 number
);


/**
 * Square Matrix and Column Vector Multiplication
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Return: Vector to Be Calculated, If Zero Not Allocated Memory
 */
extern obj math32_mat_multiply_vec
(
	obj matrix,
	obj vector,
	uint32 number
);


/**
 * Normalize Vector
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Return: Vector to Have Been Normalized, If Zero Not Allocated Memory
 */
extern obj math32_vec_normalize
(
	obj vector,
	uint32 number
);


/**
 * Dot Product
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 *
 * Return: Value of Dot Product by Single Precision Float
 */
extern float32 math32_vec_dotproduct
(
	obj vector1,
	obj vector2,
	uint32 number
);


/**
 * Cross Product
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Return: Vector to Be Calculated, If Zero Not Allocated Memory
 */
extern obj math32_vec_crossproduct
(
	obj vector1, // Must Be Three of Vector Size
	obj vector2 // Must Be Three of Vector Size
);


/********************************
 * system32/library/deci32.s
 ********************************/

/**
 * Make String of Single Precision Float Value
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 * If Float Value Exceeds 1,000,000,000.0, String Will Be Shown With Exponent and May Have Loss of Signification.
 *
 * Return: Pointer of String, If Zero, Memory Space for String Can't Be Allocated
 */
extern String deci32_float32_to_string
(
	float32 float_number,
	uint32 min_integer, // 16 Digits Max
	uint32 max_decimal, // Default 8 Digits
	int32 indicator_expo // Indicates Exponential
);


/**
 * Make String of Integer Value by Decimal System (Base 10)
 *
 * Return: Pointer of String, If Zero, Memory Space for String Can't Be Allocated
 */
extern String deci32_int32_to_string_deci
(
	int32 number, // If You Use This for uint32, You Need to Cast It to int32 
	uint32 min_length,
	bool bool_signed
);


/**
 * Make String of Integer Value by Hexadecimal System (Base 16)
 *
 * Return: Pointer of String, If Zero, Memory Space for String Can't Be Allocated
 */
extern String deci32_int32_to_string_hexa
(
	int32 number, // If You Use This for uint32, You Need to Cast It to int32 
	uint32 min_length,
	bool bool_signed,
	bool base_mark
);


/**
 * Make 32-bit Unsigned Integer From String on Hexadecimal System
 * Caution! The Range of Decimal Number Is 0x0 through 0xFFFFFFFF
 * Max. Valid Digits Are 8, Otherwise, You'll Inaccurate Return.
 *
 * This function detects spaces, plus signs, commas, minus signs, periods, then ignores these.
 *
 * Return: Unsigned Integer
 */
extern uint32 deci32_string_to_hexa
(
	String string,
	uint32 length_string
);


/**
 * Make 64-bit Decimal Number From String on Decimal System
 * Caution! The Range of Decimal Number Is 0 through 9,999,999,999,999,999.
 * Max. Valid Digits Are 16, Otherwise, You'll Get Inaccurate Return.
 *
 * This function detects spaces, plus signs, commas, minus signs, periods, then ignores these.
 *
 * Return: Lower 32 Bits (Lower Bits of Decimal Number), Upper 32 Bits (Upper Bits of Decimal Number)
 */
extern int64 deci32_string_to_deci
(
	String string,
	uint32 length_string
);


/**
 * Make 32-bit Unsigned Integer From String on Binary System
 * Caution! The Range of Decimal Number Is 0b0 through 0b1111 1111 1111 1111 1111 1111 1111 1111
 * Max. Valid Digits Are 32, Otherwise, You'll Get Inaccurate Return.
 *
 * This function detects spaces, plus signs, commas, minus signs, periods, then ignores these.
 *
 * Return: Unsigned Integer
 */
extern uint32 deci32_string_to_bin
(
	String string,
	uint32 length_string
);


/**
 * Make 32-bit Unsigned/Signed Integer From String (Decimal System)
 * Caution! The Range of Decimal Number Is 0 through 4,294,967,295 on Unsigned, -2,147,483,648 thorugh 2,147,483,647 on Signed.
 * Maximum Number of Valid Digits Exists. If It Exceeds, You'll Get Inaccurate Return.
 *
 * This function detects spaces, plus signs, commas, minus signs, periods, then ignores these.
 *
 * Return: 32-bit Unsigned/Signed Integer
 */
extern int32 deci32_string_to_int32
(
	String string,
	uint32 length_string
);


/**
 * Make 32-bit Float From String (Decimal System)
 * Caution! The Range of Integer Part is -2,147,483,648 thorugh 2,147,483,647 on Signed.
 * Otherwise, You'll Get Inaccurate Integer Part to Return.
 *
 * Return: 32-bit Float
 */
extern float32 deci32_string_to_float32
(
	String string,
	uint32 length_string // Max. 10 if Unsigned, 11 if Signed
);


/**
 * Convert Hexadecimal Bases (0-F) to Decimal Bases (0-9)
 *
 * Return: Lower 32 Bits (Lower Bits of Decimal Number), Upper 32 Bits (Upper Bits of Decimal Number)
 */
extern uint64 deci32_hexa_to_deci
(
	uint32 number_hexa
);


/**
 * Convert Decimal Bases (0-9) to Hexadecimal Bases (0-F)
 * Caution! The Range of Decimal Number is 0 through 4,294,967,295. If Value of Upper Bits is 43 and Over, Returns 0.
 *
 * Return: Hexadecimal Number
 */
extern uint32 deci32_deci_to_hexa
(
	uint64 number_deci
);


/**
 * Addition with Decimal Bases (0-9)
 *
 * Return: Lower 32 Bits (Lower Bits of Decimal Number), Upper 32 Bits (Upper Bits of Decimal Number), -1 (ALL Ones on r0 and r1) as error
 * Error: This function could not calculate because of digit-overflow.
 */
extern uint64 deci32_deci_add64
(
	uint64 number_deci1,
	uint64 number_deci2
);


/**
 * Subtraction with Decimal Bases (0-9)
 *
 * Return: Lower 32 Bits (Lower Bits of Decimal Number), Upper 32 Bits (Upper Bits of Decimal Number), -1 (ALL Ones on r0 and r1) as error
 * Error: This function could not calculate because the result is signed minus.
 */
extern uint64 deci32_deci_sub64
(
	uint64 number_deci1,
	uint64 number_deci2
);


/**
 * Shift Place with Decimal Bases (0-9)
 *
 * Return: Lower Bits of Decimal Number, Upper Bits of Decimal Number
 */
extern uint64 deci32_deci_shift64
(
	uint64 number_deci,
	int32 number_shift
);


/**
 * Multiplication with Decimal Bases (0-9)
 *
 * Return: Lower 32 Bits (Lower Bits of Decimal Number), Upper 32 Bits (Upper Bits of Decimal Number), -1 (ALL Ones on r0 and r1) as error
 * Error: This function could not calculate because of digit-overflow.
 */
extern uint64 deci32_deci_mul64
(
	uint64 number_deci1,
	uint64 number_deci2
);


/**
 * Division with Decimal Bases (0-9)
 *
 * Return: Lower 32 Bits (Lower Bits of Decimal Number), Upper 32 Bits (Upper Bits of Decimal Number), -1 (ALL Ones on r0 and r1) as error
 * Error: This function could not calculate because of digit-overflow.
 */
extern uint64 deci32_deci_div64
(
	uint64 number_deci1,
	uint64 number_deci2
);


/**
 * Remainder of Division with Decimal Bases (0-9)
 *
 * Return: Lower 32 Bits (Lower Bits of Decimal Number), Upper 32 Bits (Upper Bits of Decimal Number), -1 (ALL Ones on r0 and r1) as error
 * Error: This function could not calculate because of digit-overflow.
 */
extern uint64 deci32_deci_rem64
(
	uint64 number_deci1,
	uint64 number_deci2
);


/********************************
 * system32/library/decix32.s
 ********************************/

/**
 * Make Array of Integers From String
 *
 * This function detects commas as separators between each Integers
 *
 * Return: Heap of Array, 0 as not succeeded
 */
extern obj decix32_string_to_intarray
(
	String string,
	uint32 length_string,
	uint32 size_block // 0 = 1 bytes; 1 = 2 bytes; 2 = 4 bytes
);


/**
 * Make String on Hexadecimal System From Array of Integers
 *
 * Return: Heap of String, 0 as not succeeded
 */
extern String decix32_intarray_to_string_hexa
(
	obj object_array,
	uint32 size_block, // 0 = 1 bytes; 1 = 2 bytes; 2 = 4 bytes
	uint32 min_length,
	bool bool_signed,
	bool base_mark
);


/**
 * Make String on Decimal System From Array of Integers
 *
 * Return: Heap of String, 0 as not succeeded
 */
extern String decix32_intarray_to_string_deci
(
	obj object_array,
	uint32 size_block, // 0 = 1 bytes; 1 = 2 bytes; 2 = 4 bytes
	uint32 min_length,
	bool bool_signed
);


/**
 * Make Array of Single Precision Floats From String on Decimal System
 *
 * This function detects commas as separators between each floats
 *
 * Return: Heap of Array, 0 as not succeeded
 */
extern obj decix32_string_to_farray
(
	String string,
	uint32 length_string
);


/**
 * Make String on Decimal System From Single Precision Floats
 *
 * Return: Heap of String, 0 as not succeeded
 */
extern String decix32_farray_to_string
(
	obj object_array,
	uint32 min_integer, // 16 Digits Max
	uint32 max_decimal, // Default 8 Digits
	int32 indicator_expo // Indicates Exponential
);


/********************************
 * system32/library/heap32.s
 ********************************/

extern uint32 heap32_malloc( uint32 block_size );

extern uint32 heap32_mfree( uint32 address );

extern uint32 heap32_mcount( uint32 address );

extern uint32 heap32_mfill( uint32 address, uint32 data );

extern uint32 heap32_mcopy( uint32 address_dst, uint32 address_src, uint32 offset_src, uint32 size_src );


/********************************
 * system32/library/font_mono_12px.s
 ********************************/

extern uint32 FONT_MONO_12PX_ASCII;


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
extern uint32 COLOR16_SAMPLE_IMAGE;

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
 * system32/library/data.s
 ********************************/

extern uint32 DATA_COLOR32_SAMPLE_IMAGE0;
extern uint32 DATA_COLOR32_SAMPLE_IMAGE0_SIZE;
extern uint32 DATA_COLOR32_SAMPLE_IMAGE1;
extern uint32 DATA_COLOR32_SAMPLE_IMAGE1_SIZE;
