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

/* Baud Rate 115200 */
/*.equ __HIGHBAUD, 1*/

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
	push {lr}

	/**
	 * Video
	 */

.ifdef __DEBUG
	/* Obtain Framebuffer from VideoCore IV */
	bl bcm32_get_framebuffer
.else
	mov r0, #1
	bl bcm32_display_off
.endif

	/**
	 * Interrupt
	 */

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_interrupt_base

	mvn r1, #0                                       @ Whole Inverter
	str r1, [r0, #equ32_interrupt_disable_irqs1]     @ Make Sure Disable All IRQs
	str r1, [r0, #equ32_interrupt_disable_irqs2]
	str r1, [r0, #equ32_interrupt_disable_basic_irqs]

	/**
	 * Enable GPIO IRQ
	 * INT[0] is for 0-27 Pins
	 * INT[1] is for 28-45 Pins
	 * INT[2] is for 46-53 Pins
	 * INT[3] is for All Pins
	 */
	mov r1, #0b1111<<17                              @ GPIO INT[3:0]
	str r1, [r0, #equ32_interrupt_enable_irqs2]

	mov r1, #0b11000000                              @ Index 64 (0-6bits) for ARM Timer + Enable FIQ 1 (7bit)
	str r1, [r0, #equ32_interrupt_fiq_control]

	/**
	 * Timer
	 */

.ifdef __HIGHBAUD
	/* Get a 460652.59hz (Nearest to 4 * 115200) Timer Interrupt (240000000/521) */
	mov r0, #equ32_armtimer_ctl_enable|equ32_armtimer_ctl_interrupt_enable|equ32_armtimer_ctl_23bit_counter
	mov r1, #0x0200                           @ High 1 Byte of decimal 520 (521 - 1), 16 bits counter on default
	orr r1, r1, #0x08                         @ Low 1 Byte of decimal 520, 16 bits counter on default
	mov r2, #0x000                            @ Decimal 0 to divide 240Mz by 1 to 240Mhz (Predivider is 10 Bits Wide)
	orr r2, r2, #0x000                        @ Decimal 0 to divide 240Mz by 1 to 240Mhz (Predivider is 10 Bits Wide)
	bl arm32_armtimer
.else
	/* Get a 153550.86hz (Nearest to 4 * 38400) Timer Interrupt (240000000/1563) */
	mov r0, #equ32_armtimer_ctl_enable|equ32_armtimer_ctl_interrupt_enable|equ32_armtimer_ctl_23bit_counter
	mov r1, #0x0600                           @ High 1 Byte of decimal 1562 (1563 - 1), 16 bits counter on default
	orr r1, r1, #0x1A                         @ Low 1 Byte of decimal 1562, 16 bits counter on default
	mov r2, #0x000                            @ Decimal 0 to divide 240Mz by 1 to 240Mhz (Predivider is 10 Bits Wide)
	orr r2, r2, #0x000                        @ Decimal 0 to divide 240Mz by 1 to 240Mhz (Predivider is 10 Bits Wide)
	bl arm32_armtimer
.endif

	/**
	 * GPIO
	 */

	/* GPIO0-45 Reset and Pull Down */
	bl gpio32_gpioreset

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	/* I/O Settings */

	ldr r1, [r0, #equ32_gpio_gpfsel00]
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_4     @ Set GPIO 4 ALT 0 as GPCLK1
	str r1, [r0, #equ32_gpio_gpfsel00]

	/* Set Status Detect */
	ldr r1, [r0, #equ32_gpio_gpren0]
	orr r1, r1, #equ32_gpio04                                      @ Set GPIO4 Rising Edge Detect
	str r1, [r0, #equ32_gpio_gpren0]

	macro32_dsb ip

	/**
	 * Clock Manager for GPCLK1. Make 22721.89Hz (44.01 Micro Seconds)
	 */
	mov r0, #equ32_cm_gp0
	mov r1, #equ32_cm_ctl_mash_1
	add r1, r1, #equ32_cm_ctl_enab|equ32_cm_ctl_src_osc            @ 19.2Mhz
	mov r2, #0x340<<equ32_cm_div_integer                           @ Decimal 845
	orr r2, r2, #0x00D<<equ32_cm_div_integer                       @ Decimal 845
	bl arm32_clockmanager

	pop {pc}

os_debug:
	push {lr}

	/**
	 * Store Value
	 * Address 0x01000000 to 0x02000000 for SYSTEM32_HEAP
	 */

	mov r0, #0x01000000
	orr r0, r0, #0x0000F000
	mov r1, #0xFE000000
	orr r1, r1, #0x00DC0000
	orr r1, r1, #0x0000BA00
	orr r1, r1, #0x00000098
	str r1, [r0]

	mov r0, #0x01000000
	orr r0, r0, #0x0000F300
	mov r1, #0x1A000000
	orr r1, r1, #0x002B0000
	orr r1, r1, #0x00003C00
	orr r1, r1, #0x0000004D
	str r1, [r0]

	macro32_dsb ip

	/**
	 * Change Destination of Virtual Address
	 */

.ifndef __ARMV6
.ifndef __SECURE
	mov r0, #1
.else
	mov r0, #0
.endif
.else
	mov r0, #0
.endif
	mov r1, #0x01200000 @ Virtual Address (Bit[31:20], per 1M Bytes)
	mov r2, #0x01000000 @ Destination Address (Bit[31:20], per 1M Bytes)
	bl arm32_change_address

	macro32_dsb ip
	macro32_invalidate_tlb_all ip
	macro32_dsb ip
	macro32_isb ip
	macro32_dsb ip
	macro32_invalidate_instruction_all ip
	macro32_isb ip

	/**
	 * Load Value
	 * Address 0x01000000 to 0x02000000 for SYSTEM32_HEAP
	 */

	mov r0, #0x01000000
	orr r0, r0, #0x0000F000
	ldr r0, [r0]
macro32_debug r0, 300, 300
	mov r0, #0x01000000
	orr r0, r0, #0x0000F300
	ldr r0, [r0]
macro32_debug r0, 364, 300

	mov r0, #0x01100000
	orr r0, r0, #0x0000F000
	ldr r0, [r0]
macro32_debug r0, 300, 312
	mov r0, #0x01100000
	orr r0, r0, #0x0000F300
	ldr r0, [r0]
macro32_debug r0, 364, 312

	mov r0, #0x01200000
	orr r0, r0, #0x0000F000
	ldr r0, [r0]
macro32_debug r0, 300, 324
	mov r0, #0x01200000
	orr r0, r0, #0x0000F300
	ldr r0, [r0]
macro32_debug r0, 364, 324

	pop {pc}

os_irq:
	push {r0-r12,lr}

.ifdef __ARMV6
	macro32_invalidate_instruction_all ip
	macro32_dsb ip
.endif

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_interrupt_base
	ldr r1, [r0, #equ32_interrupt_pending_irqs2]
/*macro32_debug r1, 100, 88*/

	macro32_dsb ip

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base
	ldr r1, [r0, #equ32_gpio_gpeds0]                               @ Clear GPIO Event Detect
	str r1, [r0, #equ32_gpio_gpeds0]                               @ Clear GPIO Event Detect
/*macro32_debug r1, 100, 100*/

	macro32_dsb ip

	ldr r0, OS_IRQ_COUNT
	add r0, r0, #1
	str r0, OS_IRQ_COUNT
/*macro32_debug r0, 100, 112*/

	macro32_dsb ip

	pop {r0-r12,pc}

.globl OS_IRQ_COUNT
OS_IRQ_COUNT: .word 0x00

os_fiq:
	push {r0-r7,lr}

.ifdef __ARMV6
	macro32_invalidate_instruction_all ip
	macro32_dsb ip
.endif

	/* Clear Timer Interrupt */
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_armtimer_base
	mov r1, #0
	str r1, [r0, #equ32_armtimer_clear]       @ any write to clear/ acknowledge
	macro32_dsb ip

.ifdef __DEBUG
.ifndef __RASPI3B
	/* ACT Blinker */
	mov r0, #47
	mov r1, #2
	bl gpio32_gpiotoggle
	macro32_dsb ip
.endif
.endif

	ldr r0, OS_FIQ_COUNT
	add r0, r0, #1
	str r0, OS_FIQ_COUNT
/*macro32_debug r0, 100, 124*/

	macro32_dsb ip

	pop {r0-r7,pc}

.globl OS_FIQ_COUNT
OS_FIQ_COUNT: .word 0x00

/**
 * Variables
 */
.balign 4
_string_hello:
	.ascii "\nALOHA! WE ARE OHANA!\n\0" @ Add Null Escape Character on The End
.balign 4
string_hello:
	.word _string_hello

.include "addr32.s" @ If you want binary, use `.incbin`

/* End of Line is Needed */
