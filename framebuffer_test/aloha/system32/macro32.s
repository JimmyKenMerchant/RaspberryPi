/**
 * macro32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * Data Synchronization Barrier for compatibility to ARMv6
 */
.macro macro32_dsb_v6 reg0
	mov \reg0, #0
	mcr p15, 0, \reg0, c7, c10, 4
.endm

/**
 * Data Memory Barrier for compatibility to ARMv6
 */
.macro macro32_dmb_v6 reg0
	mov \reg0, #0
	mcr p15, 0, \reg0, c7, c10, 5
.endm

/**
 * Instruction Synchronization Barrier for compatibility to ARMv6
 * Using Flush Prefetch Buffer and Flush Entire Branch Target Cache
 */
.macro macro32_isb_v6 reg0
	mov \reg0, #0
	mcr p15, 0, \reg0, c7, c5, 4
	mcr p15, 0, \reg0, c7, c5, 6
.endm
