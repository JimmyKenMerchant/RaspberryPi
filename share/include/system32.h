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

/* Relative System Calls  */

__attribute__((noinline)) void _sleep( uint32 u_seconds );

__attribute__((noinline)) uchar8 _random( uchar8 range_end );

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
 * Set Caret Position from Return Vlue of `print_*` functions
 *
 * Return: Number of Characters Which Were Not Drawn
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
	draw32_renderbuffer        = 5, // Size
	draw32_renderbuffer_addr   = 0,
	draw32_renderbuffer_width  = 4,
	draw32_renderbuffer_height = 8,
	draw32_renderbuffer_size   = 12,
	draw32_renderbuffer_depth  = 16
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
 * Draw Arc by Degree with Single Precision Float
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 * Range is -360 to 360 degrees inclusively, otherwise, value will be cut off by the limit.
 *
 * Return: 0 as success, 1 as error
 * Error: Part of Circle from Last Coordinate was Not Drawn, Caused by Not Defined Buffer
 */
extern uint32 draw32_arc_fdegree
(
	uint32 color,
	int32 x_coord,
	int32 y_coord,
	uint32 x_radius,
	uint32 y_radius,
	float32 start_fdegree,
	float32 end_fdegree,
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
 * system32/library/gpio32.s
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
 * system32/library/math32.s
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
extern String math32_float32_to_string
(
	float32 float_number,
	uint32 min_integer, // 16 Digits Max
	uint32 max_decimal, // Default 8 Digits
	uint32 min_exponent // 16 Digits Max
);


/**
 * Make String of Integer Value by Decimal System (Base 10)
 *
 * Return: Pointer of String, If Zero, Memory Space for String Can't Be Allocated
 */
extern String math32_int32_to_string_deci
(
	int32 number, // If You Use This for uint32, You Need to Cast It to int32 
	uint32 min_length,
	uint32 bool_signed
);


/**
 * Make String of Integer Value by Hexadecimal System (Base 16)
 *
 * Return: Pointer of String, If Zero, Memory Space for String Can't Be Allocated
 */
extern String math32_int32_to_string_hexa
(
	int32 number, // If You Use This for uint32, You Need to Cast It to int32 
	uint32 min_length,
	uint32 bool_signed,
	uint32 bool_basemark
);


/********************************
 * system32/library/vfp32.s
 ********************************/

extern bool vfp32_fgt
(
	float32 value1,
	float32 value2
);


extern float32 vfp32_fadd
(
	float32 value1,
	float32 value2
);


/********************************
 * system32/library/heap32.s
 ********************************/

extern uint32 heap32_malloc( uint32 block_size );


extern uint32 heap32_mfree( uint32 address );


extern uint32 heap32_mcopy( uint32 address_dst, uint32 address_src, uint32 offset, uint32 size );


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
