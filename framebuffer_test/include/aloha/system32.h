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

extern uint32 FB_ADDRESS;
extern uint32 FB_DISPLAY_WIDTH;
extern uint32 FB_DISPLAY_HEIGHT;
extern uint32 FB_SIZE;
extern uint32 FB_DEPTH;
extern uint32 FB_WIDTH;
extern uint32 FB_HEIGHT;
extern uint32 FB_X_CARET;
extern uint32 FB_Y_CARET;
extern uint32* FONT_MONO_12PX_NUMBER;
extern uint32* FONT_MONO_12PX_ASCII;

void user_start();

extern void no_op();

/**
 * Set Caret Position from Return Vlue of `print_*` functions
 *
 * Return: Number of Characters Which Were Not Drawn
 */
extern uint32 set_caret
(
	uint64 return_print
);

/**
 * Count 1-Byte Words of String
 *
 * Return: Number of Words Maximum of 4,294,967,295 words
 */
extern uint32 strlen
(
	uchar8* string
);

/**
 * rint String with 1 Byte Character
 *
 * Return: Lower 32 bits (0 as sucess, 1 and more as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
extern uint64 print_string
(
	uchar8* string,
	uint32 x_coord,
	uint32 y_coord,
	uint32 color,
	uint32 length,
	uint32 font_width,
	uint32 font_height,
	uint32* font_base
);

/**
 * Print Hexadecimal Bases Numbers in 64-bit (16 Digits)
 *
 * Return: Lower 32 bits (0 as sucess, 1 and more as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
extern uint64 double_print_number
(
	uint64 number,
	uint32 x_coord,
	uint32 y_coord,
	uint32 color,
	uint32 length,
	uint32 font_width,
	uint32 font_height,
	uint32* font_base
);

/**
 * Print Hexadecimal Bases Numbers in 32-bit (8 Digits)
 *
 * Return: Lower 32 bits (0 as sucess, 1 and more as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
extern uint64 print_number
(
	uint32 number,
	uint32 x_coord,
	uint32 y_coord,
	uint32 color,
	uint32 length,
	uint32 font_width,
	uint32 font_height,
	uint32* font_base
);
