/**
 * macro32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * Print String
 * Use r0 for string, r1 for color, r2 for back_color, r3 for font. Otherwise, printed incorrectly.
 */
.macro macro32_print_string reg0_string x_coord y_coord reg1_color reg2_back_color length char_width char_height reg3_font:req
	push {r0-r8,lr}
	mov r0, \reg0_string                      @ Pointer of Array of String
	mov r8, \reg3_font
	mov r3, \reg1_color                       @ Color (16-bit or 32-bit)
	mov r4, \reg2_back_color                  @ Background Color (16-bit or 32-bit)
	mov r1, #\x_coord                         @ X Coordinate
	mov r2, #\y_coord                         @ Y Coordinate
	mov r5, #\length                          @ Length of Characters, Need of PUSH/POP
	mov r6, #\char_width
	mov r7, #\char_height
	push {r4-r8}
	bl print32_string
	add sp, sp, #20                           @ Increment SP because of push
	pop {r0-r8,lr}
.endm


/**
 * Print Number (32-bit)
 * Use r0 for number, r1 for color, r2 for back_color, r3 for font. Otherwise, printed incorrectly.
 */
.macro macro32_print_number reg0_number x_coord y_coord reg1_color reg2_back_color digits char_width char_height reg3_font:req
	push {r0-r8,lr}
	mov r0, \reg0_number
	mov r8, \reg3_font
	mov r3, \reg1_color                       @ Color (16-bit or 32-bit)
	mov r4, \reg2_back_color                  @ Background Color (16-bit or 32-bit)
	mov r1, #\x_coord                         @ X Coordinate
	mov r2, #\y_coord                         @ Y Coordinate
	mov r5, #\digits                          @ Length of Characters, Need of PUSH/POP
	mov r6, #\char_width
	mov r7, #\char_height
	push {r4-r8}
	bl print32_number
	add sp, sp, #20                           @ Increment SP because of push
	pop {r0-r8,lr}
.endm


/**
 * Print Number (64-bit)
 * Use r0 for number_lower, r1 for number_upper, r2 for color, r3 for back_color, r4 for font. Otherwise, printed incorrectly.
 */
.macro macro32_print_number_double reg0_number_lower reg1_number_upper x_coord y_coord reg2_color reg3_back_color digits:req char_width char_height reg4_font
	push {r0-r9,lr}
	mov r0, \reg0_number_lower
	mov r1, \reg1_number_upper
	mov r9, \reg4_font
	mov r4, \reg2_color                       @ Color (16-bit or 32-bit)
	mov r5, \reg3_back_color                  @ Background Color (16-bit or 32-bit)
	mov r2, #\x_coord                         @ X Coordinate
	mov r3, #\y_coord                         @ Y Coordinate
	mov r6, #\digits                          @ Length of Characters, Need of PUSH/POP
	mov r7, #\char_width
	mov r8, #\char_height
	push {r4-r9}
	bl print32_number_double
	add sp, sp, #24                           @ Increment SP because of push
	pop {r0-r9,lr}
.endm


/**
 * Print Value of Register for Debug
 */
.macro macro32_debug reg0_number x_coord y_coord:req
	push {r0-r3,lr}
	mov r0, \reg0_number
	mov r1, #\x_coord
	mov r2, #\y_coord
	bl print32_debug
	pop {r0-r3,lr}
.endm


/**
 * Data Synchronization Barrier for compatibility between ARMv6 and ARMv7+
 * Available in User Mode
 */
.macro macro32_dsb reg0:vararg
.ifdef __ARMV6
	mov \reg0, #0                       @ If You Want Invalidate/ Clean Entire One, Needed Zero (SBZ)
	mcr p15, 0, \reg0, c7, c10, 4
.else
	dsb
.endif
.endm


/**
 * Data Memory Barrier for compatibility between ARMv6 and ARMv7+
 * Available in User Mode
 */
.macro macro32_dmb reg0:vararg
.ifdef __ARMV6
	mov \reg0, #0
	mcr p15, 0, \reg0, c7, c10, 5
.else
	dmb
.endif
.endm


/**
 * Instruction Synchronization Barrier for compatibility between ARMv6 and ARMv7+
 * Using Flush Prefetch Buffer on ARMv6
 * Available in User Mode
 */
.macro macro32_isb reg0:vararg
.ifdef __ARMV6
	mov \reg0, #0
	mcr p15, 0, \reg0, c7, c5, 4
.else
	isb                                 @ Includes Flush Entire Branch Target Cache
.endif
.endm


/**
 * Flush Entire Branch Target Cache
 * In IMB (Instruction Memory Barrier) Process, Use with Flush Prefetch Buffer on ARMv6
 */
.macro macro32_flush_branch reg0:vararg
.ifdef __ARMV6
	mov \reg0, #0
	mcr p15, 0, \reg0, c7, c5, 6
.else
	mov \reg0, #0
	mcr p15, 0, \reg0, c7, c5, 6
.endif
.endm


/**
 * Invalidate All Unlocked TLB
 */
.macro macro32_invalidate_tlb_all reg0:vararg
.ifdef __ARMV6
	mcr p15, 0, \reg0, c8, c7, 0 @ Unified (1176JZF-S is Unified Only)
.else
	mov \reg0, #0
	mcr p15, 0, \reg0, c8, c3, 0 @ TLB Inner Shareable
	mcr p15, 0, \reg0, c8, c5, 0 @ Instruction TLB
	mcr p15, 0, \reg0, c8, c6, 0 @ Data TLB
	mcr p15, 0, \reg0, c8, c7, 0 @ Unified TLB
.endif
.endm


/**
 * Invalidate Entire Data Cache
 * ARMv6 Only
 */
.macro macro32_invalidate_cache_all reg0:vararg
.ifdef __ARMV6
	mov \reg0, #0
	mcr p15, 0, \reg0, c7, c6, 0
.endif
.endm


/**
 * Invalidate Entire Both Cache and Flush Branch Target Cache
 * ARMv6 Only
 */
.macro macro32_invalidate_both_all reg0:vararg
.ifdef __ARMV6
	mov \reg0, #0
	mcr p15, 0, \reg0, c7, c7, 0
.endif
.endm


/**
 * Invalidate Entire Instruction Cache and Flush Branch Target Cache
 */
.macro macro32_invalidate_instruction_all reg0:vararg
.ifdef __ARMV6
	mov \reg0, #0
	mcr p15, 0, \reg0, c7, c5, 0
.else
	mov \reg0, #0
	mcr p15, 0, \reg0, c7, c5, 0
.endif
.endm


/**
 * Invalidate Data Cache by MVA
 */
.macro macro32_invalidate_cache reg0 reg1:req
	bic \reg1, \reg0, #0x1F
	mcr p15, 0, \reg1, c7, c6, 1
.endm


/**
 * Clean Data Cache by MVA
 */
.macro macro32_clean_cache reg0 reg1:req
	bic \reg1, \reg0, #0x1F
	mcr p15, 0, \reg1, c7, c10, 1
.endm


/**
 * Clean and Invalidate Data Cache by MVA
 */
.macro macro32_clean_invalidate_cache reg0 reg1:req
	bic \reg1, \reg0, #0x1F
	mcr p15, 0, \reg1, c7, c14, 1
.endm


/**
 * Get Multi-core Identifier
 */
.macro macro32_multicore_id reg0:req
.ifdef __ARMV6
	mov \reg0, #0
.else
	mrc p15, 0, \reg0, c0, c0, 5        @ Multiprocessor Affinity Register (MPIDR)
	and \reg0, \reg0, #0b11
.endif
.endm
