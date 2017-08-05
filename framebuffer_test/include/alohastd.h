/**
 * alohastd
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 * This Program is intended to be used in GNU Assembler with AArch32/ ARMv7-A.
 */

int alohamain();

extern void no_op();

/**
 * function print_string_ascii_8by8
 * Print String with ASCII Table
 *
 * Parameters
 * r0 unsigned char*: Pointer of Array of String
 * r1 unsigned integer: X Coordinate
 * r2 unsigned integer: Y Coordinate
 * r3 unsinged integer: Color (16-bit)
 * r4 unsigned integer: Length of Characters, Need of PUSH/POP
 *
 * Return: Lower 32 bits (0 as sucess, 1 and 2 as error), Upper 32 bits (Last Pointer of Framebuffer)
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 */
extern unsigned long long int print_string_ascii_8by8( unsigned char* string, unsigned long int x_coord, unsigned long int y_coord, unsigned long int color, unsigned long int length);
