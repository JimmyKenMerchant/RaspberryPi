/**
 * system32.c
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * In SVC mode, Regular Registers Stay, but SP, LR, and SPSR are Banked.
 * So, as SVCm, you need to have only r0-r3 registers to execute functions.
 */
__attribute__((noinline)) uint32 example_svc_30( int32 a, int32 b, int32 c, int32 d )
{
	register uint32 result asm("r0");
	asm volatile ("svc #30");
	return result;
}
