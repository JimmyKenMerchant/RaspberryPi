/**
 * sound32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * function sound32_soundtest
 *
 * Parameters
 * r0:
 * r1:
 *
 * Return: r0 (0 as success, 1 and 2 as error)
 * Error(1):
 * Error(2):
 */
.globl sound32_soundtest
sound32_soundtest:
	/* Auto (Local) Variables, but just Aliases */
	temp .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	push {r4-r11}

	push {r0-r3,lr}
	mov r0, #144                            @ 144 Words Equals 576 Bytes
	bl heap32_malloc
	mov r4, r0
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, r4
	mov r1, #144                           @ Length in Words, Intended that 3.2KHz/144 Equals 222.2Hz
	mov r2, #63                            @ Height in Bytes
	mov r3, #128                           @ Medium in Bytes
	bl heap32_wave_triangle
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, r4
	mov r1, #1                                @ Clean
	bl arm32_cache_operation_heap
	pop {r0-r3,lr}

	/* Channel Block Setting */

	push {r0-r6,lr}
	mov r0, #0                                              @ CB Number
	mov r1, #5<<equ32_dma_ti_permap
	orr r1, r1, #equ32_dma_ti_src_inc|equ32_dma_ti_dst_dreq @ Transfer Information
	mov r2, r4                                              @ Source Address
	mov r3, #equ32_bus_peripherals_base
	add r3, r3, #equ32_pwm_base_lower
	add r3, r3, #equ32_pwm_base_upper
	add r3, r3, #equ32_pwm_fif1                             @ Destination Address
	mov r4, #576	                                        @ Transfer Length
	mov r5, #0                                              @ 2D Stride
	mov r6, #0                                              @ Next CB Number
	push {r4-r6}
	bl dma32_set_cb
	mov r7, r0
	add sp, sp, #12
	pop {r0-r6,lr}

	push {r0-r3,lr}
	mov r0, #1
	mov r1, r7
	bl dma32_set_channel
	pop {r0-r3,lr}

	b sound32_soundtest_success

	sound32_soundtest_error1:
		mov r0, #1                                 @ Return with Error 1
		b sound32_soundtest_common

	sound32_soundtest_error2:
		mov r0, #2                                 @ Return with Error 2
		b sound32_soundtest_common

	sound32_soundtest_success:
		mov r0, #0                                 @ Return with Success

	sound32_soundtest_common:
		pop {r4-r11}
		mov pc, lr

.unreq temp
