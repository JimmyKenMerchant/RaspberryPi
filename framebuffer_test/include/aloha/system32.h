/**
 * system32.h
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

#ifndef AARCH_32

#define AARCH_32

#endif

#define uchar8 unsigned char
#define uint16 unsigned short int
#define uint32 unsigned long int
#define uint64 unsigned long long int
#define char8 char
#define int16 short int
#define int32 long int
#define int64 long long int
#define float32 float
#define float64 double

/**
 * system32/color.s
 */

extern uint32 FB32_ADDRESS;
extern uint32 FB32_DISPLAY_WIDTH;
extern uint32 FB32_DISPLAY_HEIGHT;
extern uint32 FB32_SIZE;
extern uint32 FB32_DEPTH;
extern uint32 FB32_PIXELORDER;
extern uint32 FB32_ALPHAMODE;
extern uint32 FB32_WIDTH;
extern uint32 FB32_HEIGHT;
extern int32 FB32_X_CARET;
extern int32 FB32_Y_CARET;
extern uint32* FONT_MONO_12PX_NUMBER;
extern uint32* FONT_MONO_12PX_ASCII;
extern uint32* HEAP;
extern uint32* RENDER_BUFFER;

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
extern uint32* COLOR16_SAMPLE_IMAGE;

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


/**
 * Unique Difinition
 */

void user_start();


/**
 * system32/system32
 */

extern void system32_no_op();

extern void system32_sleep( uint32 u_seconds );


/**
 * system32/print32.s
 */

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
 * Count 1-Byte Words of String
 *
 * Return: Number of Words Maximum of 4,294,967,295 words
 */
extern uint32 print32_strlen
(
	uchar8* string
);


/**
 * rint String with 1 Byte Character
 *
 * Return: Lower 32 bits (0 as sucess, 1 and more as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
extern uint64 print32_string
(
	uchar8* string,
	int32 x_coord,
	int32 y_coord,
	uint32 color,
	uint32 back_color,
	uint32 length,
	uint32 width,
	uint32 height,
	uint32* font_base
);


/**
 * Print Hexadecimal Bases Numbers in 64-bit (16 Digits)
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
	uint32* font_base
);


/**
 * Print Hexadecimal Bases Numbers in 32-bit (8 Digits)
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
	uint32* font_base
);


/**
 * system32/fb32.s
 */


/**
 * Draw Line
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Lower 32 bits (0 as sucess, 1 and more as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Y Length Which Were Not Drawn
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
 * Copy Framebuffer to Renderbuffer
 *
 * Return: 0 as sucess, 1 as error
 * Error(1): When Framebuffer is not Defined
 */
extern uint32 fb32_copy
(
	uint32* render_buffer_point
);


/**
 * Draw Image
 *
 * Return: Lower 32 bits (0 as sucess, 1 and 2 as error), Upper 32 bits (Last Pointer of Framebuffer)
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 */
extern uint64 fb32_draw_image
(
	uint32* image_point,
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
 * Return: Lower 32 bits (0 as sucess, 1 and 2 as error), Upper 32 bits (Last Pointer of Framebuffer)
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
