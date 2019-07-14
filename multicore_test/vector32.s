/**
 * vector32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/* Define Debug Status */
.equ __DEBUG, 1

.include "system32/equ32.s"
.include "system32/macro32.s"

.ifdef __ARMV6
	.include "vector32/el01_armv6.s"
	.include "vector32/el3_armv6.s"
.else
	.include "vector32/el01_armv7.s"
	.include "vector32/el2_armv7.s"
	.include "vector32/el3_armv7.s"
.endif

.include "vector32/os.s"

os_reset:

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_interrupt_base

	mvn r1, #0                                       @ Whole Inverter

	str r1, [r0, #equ32_interrupt_disable_irqs1]     @ Make Sure Disable All IRQs
	str r1, [r0, #equ32_interrupt_disable_irqs2]
	str r1, [r0, #equ32_interrupt_disable_basic_irqs]

	mov r1, #0b11000000                       @ Index 64 (0-6bits) for ARM Timer + Enable FIQ 1 (7bit)
	str r1, [r0, #equ32_interrupt_fiq_control]

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_armtimer_base

	mov r1, #0x95                             @ Decimal 149 to divide 240Mz by 150 to 1.6Mhz (Predivider is 10 Bits Wide)
	str r1, [r0, #equ32_armtimer_predivider]

	mov r1, #0x2700                           @ 0x2700 High 1 Byte of decimal 9999 (10000 - 1), 16 bits counter on default
	add r1, r1, #0x0F                         @ 0x0F Low 1 Byte of decimal 9999, 16 bits counter on default
	str r1, [r0, #equ32_armtimer_load]

	mov r1, #0x3E0000                         @ High 2 Bytes
	add r1, r1, #0b10100100                   @ Low 2 Bytes (00A4), Timer Enable and Timer Interrupt Enable, Prescaler 1/16 to 100K
	                                          @ 1/16 is #0b10100100, 1/256 is #0b10101000
	str r1, [r0, #equ32_armtimer_control]

	/* So We can get a 10hz Timer Interrupt (100000/10000) */

.ifndef __RASPI3B
	/* GPIO */
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	ldr r1, [r0, #equ32_gpio_gpfsel40]
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_7   @ Clear GPIO 21
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7  @ Set GPIO 47 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel40]
.endif

	/* Obtain Framebuffer from VideoCore IV */
	mov r0, #32
	ldr r1, ADDR32_BCM32_DEPTH
	str r0, [r1]

	macro32_clean_cache r1, ip

	mov r0, #2
	ldr r1, ADDR32_BCM32_ALPHAMODE
	str r0, [r1]

	macro32_clean_cache r1, ip

	push {r0-r3,lr}
	bl bcm32_get_framebuffer
	pop {r0-r3,lr}

	mov pc, lr

os_debug:
	push {r0-r8,lr}
	
	ldr r0, ADDR32_COLOR32_NAVYBLUE
	ldr r0, [r0]
	bl fb32_clear_color

	/* Full Decending Stack */
	mov r0, #0xFF
	bl heap32_malloc
	mov r4, r0
	mov r0, #0xFF
	lsl r0, r0, #2                            @ Multiply by 4
	add r4, r4, r0

	/* Core 3 */

	mov r0, #3
	bl heap32_malloc                          @ Obtain Memory Space (2 Block Means 8 Bytes)
	ldr r1, core123_handler
	str r1, [r0]                              @ Store Pointer of Function to First of Heap Array
	str r4, [r0, #4]                          @ Store Pointer of Full Decending Stack
	mov r1, #0
	str r1, [r0, #8]                          @ Store Number of Arguments to Second of Heap Array
	push {r0-r3}
	mov r1, #3                                @ Indicate Number of Core
	bl arm32_core_call
	pop {r0-r3}

	ldr r1, ADDR32_ARM32_CORE_HANDLE_3
	_os_render_loop2:
		macro32_invalidate_cache r1 ip
		macro32_dsb ip
		ldr r1, [r1]
		cmp r1, #0
		bne _os_render_loop2

	bl heap32_mfree                           @ Clear Memory Space

	/* Core 3 */

	mov r0, #10
	bl heap32_malloc                          @ Obtain Memory Space (10 Block Means 40 Bytes)
	ldr r1, core123_handler2
	str r1, [r0]                              @ Store Pointer of Function to First of Heap Array
	str r4, [r0, #4]                          @ Store Pointer of Full Decending Stack
	mov r1, #7
	str r1, [r0, #8]                          @ Store Number of Arguments to Second of Heap Array
	mov r1, #0x1
	str r1, [r0, #12]
	mov r1, #0x2
	str r1, [r0, #16]
	mov r1, #0x3
	str r1, [r0, #20]
	mov r1, #0x4
	str r1, [r0, #24]
	mov r1, #0x5
	str r1, [r0, #28]
	mov r1, #0x6
	str r1, [r0, #32]
	mov r1, #0x7
	str r1, [r0, #36]
	push {r0-r3}
	mov r1, #3                                @ Indicate Number of Core
	bl arm32_core_call
	pop {r0-r3}

	ldr r1, ADDR32_ARM32_CORE_HANDLE_3
	_os_render_loop3:
		macro32_invalidate_cache r1 ip
		macro32_dsb ip
		ldr r1, [r1]
		cmp r1, #0
		bne _os_render_loop3

	push {r0-r3}
	mov r1, #0                                @ Invalidate for Core to Send
	bl arm32_cache_operation_heap
	pop {r0-r3}

	ldr r1, [r0]

macro32_debug r1 500 500

	bl heap32_mfree                           @ Clear Memory Space

	ldr r0, string_hello                      @ Pointer of Array of String
	macro32_print_string r0, 0, 0, 100

	ldr r0, string_test                       @ Pointer of Array of String
	macro32_print_string r0, 0, 100, 100

	push {r1-r3}
	ldrb r0, core0
	ldrb r1, core1
	ldrb r2, core2
	ldrb r3, core3
	add r0, r0, r1
	add r0, r0, r2
	add r0, r0, r3
	pop {r1-r3}

macro32_debug r0 500 512

	pop {r0-r8,pc}

os_irq:
	push {r0-r12}
	pop {r0-r12}
	mov pc, lr

os_fiq:
	push {r0-r7}
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_armtimer_base

	mov r1, #0
	str r1, [r0, #equ32_armtimer_clear]       @ any write to clear/ acknowledge

.ifndef __RASPI3B
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	ldr r1, gpio_toggle
	eor r1, #0b00000001                       @ Exclusive OR to toggle
	str r1, gpio_toggle

	cmp r1, #0
	addeq r0, r0, #equ32_gpio_gpclr1
	addne r0, r0, #equ32_gpio_gpset1
	mov r1, #equ32_gpio47
	str r1, [r0]
.endif

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_systemtimer_base

	ldr r0, [r0, #equ32_systemtimer_counter_lower] @ Get Lower 32 Bits
	ldr r1, sys_timer_previous
	sub r2, r0, r1
	str r0, sys_timer_previous

	push {lr}
	mov r0, r2
	bl cvt32_hexa_to_deci
	pop {lr}

	macro32_print_number_double r0 r1 80 388 16

	ldr r0, timer_sub
	ldr r1, timer_main

	add r0, r0, #1
	cmp r0, #10
	addge r1, #1
	movge r0, #0

	str r0, timer_sub
	str r1, timer_main

	macro32_print_number_double r0 r1 80 400 16

	pop {r0-r7}
	mov pc, lr

core123_handler: .word _core123_handler

_core123_handler:
	macro32_multicore_id r0
	ldr r1, core_addr
	mul r2, r0, r0
	ldrb r3, [r1,r0]
	add r2, r2, r3
	strb r2, [r1,r0]
	macro32_dsb ip
	macro32_isb ip
	mov pc, lr

core123_handler2: .word _core123_handler2
_core123_handler2:
	push {r4-r11}

	add sp, sp, #32                 @ r4-r11 offset 32 bytes
	pop {r4-r6}                     @ Get Fifth to Seventh Arguments
	sub sp, sp, #44

	add r0, r0, r1
	add r0, r0, r2
	add r0, r0, r3
	add r0, r0, r4
	add r0, r0, r5
	add r0, r0, r6
	macro32_dsb ip
	macro32_isb ip
	pop {r4-r11}
	mov pc, lr

/**
 * Variables
 */
.balign 4
gpio_toggle:       .byte 0b00000000
.balign 4
_string_hello:
	.ascii "\nMAHALO! WE ARE OHANA!\n\0" @ Add Null Escape Character on The End
.balign 4
string_hello:
	.word _string_hello
_string_test:
	.ascii "Sytem Timer Interval\n\t100K? 100K by 10 Equals 1M!\n\tSystem Timer is 1M Hz!\0"
.balign 4
string_test:
	.word _string_test
timer_main:
	.word 0x00000000
timer_sub:
	.word 0x00000000
sys_timer_previous:
	.word 0x00000000
core_addr:
	.word core0
core0:
	.byte 0x00000000
core1:
	.byte 0x00000000
core2:
	.byte 0x00000000
core3:
	.byte 0x00000000
.balign 4

.include "addr32.s" @ If you want binary, use `.incbin`
.balign 4
/* End of Line is Needed */
