/**
 * system32.h
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 * This Program is intended to be used in GNU Assembler with AArch32/ ARMv7-A.
 */

#define uint16 unsigned short int
#define uint32 unsigned long int
#define uint64 unsigned long long int
#define int16 short int
#define int32 long int
#define int64 long long int

void user_start();

extern void no_op();

/**
 * Return: Lower 32 bits (0 as sucess, 1 and 2 as error), Upper 32 bits (Last Pointer of Framebuffer)
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 */
extern uint64 print_string_ascii_8by8
(
	unsigned char* string,
	uint32 x_coord,
	uint32 y_coord,
	uint32 color,
	uint32 length
);

/**
 * Return: Lower 32 bits (0 as sucess, 1 and 2 as error), Upper 32 bits (Last Pointer of Framebuffer)
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 */
extern uint64 double_print_number_8by8
(
	uint64 number,
	uint32 x_coord,
	uint32 y_coord,
	uint32 color,
	uint32 length
);