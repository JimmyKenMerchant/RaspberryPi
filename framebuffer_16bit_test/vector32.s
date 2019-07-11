/**
 * vector32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

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
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_7   @ Clear GPIO 47
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7  @ Set GPIO 47 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel40]
.endif

	/* Obtain Framebuffer from VideoCore IV */
	mov r0, #16
	ldr r1, ADDR32_BCM32_DEPTH
	str r0, [r1]

	macro32_clean_cache r1, ip

	mov r0, #2
	ldr r1, ADDR32_BCM32_ALPHAMODE
	str r0, [r1]

	macro32_clean_cache r1, ip

	bl bcm32_get_framebuffer

	mov r0, #1
	bl bcm32_get_celcius

	mov r0, #1
	bl bcm32_get_voltage

	mov r0, #4
	bl bcm32_get_clockrate

	/* Get DMA Channels (Know Available Channel with ARM) */
	mov r0, #0x00060000
	orr r0, r0, #0x00000001
	mov r1, #4
	bl bcm32_get_response

	pop {pc}

os_irq:
	push {r0-r12}
	pop {r0-r12}
	mov pc, lr

os_fiq:
	push {r0-r7,lr}

.ifdef __ARMV6
	macro32_invalidate_instruction_all ip
	macro32_dsb ip
.endif

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_armtimer_base

	mov r1, #0
	str r1, [r0, #equ32_armtimer_clear]       @ any write to clear/ acknowledge

	macro32_dsb ip

.ifndef __RASPI3B
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	ldrb r1, os_fiq_gpio_toggle
	eor r1, #0b00000001                       @ Exclusive OR to toggle
	strb r1, os_fiq_gpio_toggle

	cmp r1, #0
	addeq r0, r0, #equ32_gpio_gpclr1
	addne r0, r0, #equ32_gpio_gpset1
	mov r1, #equ32_gpio47
	str r1, [r0]

	macro32_dsb ip
.endif

	/*
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_systemtimer_base

	ldr r0, [r0, #equ32_systemtimer_counter_lower] @ Get Lower 32 Bits
	ldr r1, sys_timer_previous
	sub r2, r0, r1
	str r0, sys_timer_previous

	push {lr}
	mov r0, r2
	bl math32_hexa_to_deci32
	pop {lr}

	ldr r2, ADDR32_COLOR16_YELLOW             @ Color (16-bit or 32-bit)
	ldr r2, [r2]
	ldr r3, ADDR32_COLOR16_BLUE               @ Background Color (16-bit or 32-bit)
	ldr r3, [r3]
	ldr r4, ADDR32_FONT_MONO_12PX_ASCII       @ Font
	ldr r4, [r4]
	macro32_print_number_double r0, r1, 80, 388, r2, r3, 16, 8, 12, r4

	ldr r0, timer_sub
	ldr r1, timer_main

	add r0, r0, #1
	cmp r0, #10
	addge r1, #1
	movge r0, #0

	str r0, timer_sub
	str r1, timer_main

	macro32_print_number_double r0, r1, 80, 400, r2, r3, 16, 8, 12, r4

	macro32_dsb ip
	*/

        bl framebuffer_test_fiqhandler

	mov r0, #0
	bl bcm32_get_celcius

	macro32_dsb ip

	pop {r0-r7,pc}

/**
 * Handler to Use in FIQ
 */
framebuffer_test_fiqhandler:
	vfp_sec  .req s0
	vfp_min  .req s1
	vfp_hour .req s2
	vfp_one  .req s3
	vfp_zero .req s4
	vfp_600  .req s5
	vfp_60   .req s6
	vfp_12   .req s7

	vpush {s0-s7}

	vldr vfp_sec, os_fiq_sec
	vldr vfp_min, os_fiq_min
	vldr vfp_hour, os_fiq_hour
	vldr vfp_one, os_fiq_one
	vldr vfp_zero, os_fiq_zero
	vldr vfp_600, os_fiq_600
	vldr vfp_60, os_fiq_60
	vldr vfp_12, os_fiq_12

	macro32_dsb ip

	vadd.f32 vfp_sec, vfp_sec, vfp_one
	vcmp.f32 vfp_sec, vfp_600
	vmrs apsr_nzcv, fpscr                                   @ Transfer FPSCR Flags to CPSR's NZCV
	blt framebuffer_test_fiqhandler_common

	vmov vfp_sec, vfp_zero
	vadd.f32 vfp_min, vfp_min, vfp_one
	vcmp.f32 vfp_min, vfp_60
	vmrs apsr_nzcv, fpscr                                   @ Transfer FPSCR Flags to CPSR's NZCV
	blt framebuffer_test_fiqhandler_common

	vmov vfp_min, vfp_zero
	vadd.f32 vfp_hour, vfp_hour, vfp_one
	vcmp.f32 vfp_hour, vfp_12
	vmrs apsr_nzcv, fpscr                                   @ Transfer FPSCR Flags to CPSR's NZCV
	blt framebuffer_test_fiqhandler_common

	vmov vfp_hour, vfp_zero

	framebuffer_test_fiqhandler_common:
		vstr vfp_sec, os_fiq_sec
		vstr vfp_min, os_fiq_min
		vstr vfp_hour, os_fiq_hour
		macro32_dsb ip
		vpop {s0-s7}
		mov pc, lr 

.unreq vfp_sec
.unreq vfp_min
.unreq vfp_hour
.unreq vfp_one
.unreq vfp_zero
.unreq vfp_600
.unreq vfp_60
.unreq vfp_12


/**
 * Variables
 */
.globl os_fiq_sec
.globl os_fiq_min
.globl os_fiq_hour
.balign 4
os_fiq_gpio_toggle: .byte 0b00000000
.balign 4
os_fiq_sec:         .float 0.0               @ Max. 600
.balign 4
os_fiq_min:         .float 0.0               @ Max. 600
.balign 4
os_fiq_hour:        .float 0.0               @ Max. 720
.balign 4
os_fiq_one:         .float 1.0
.balign 4
os_fiq_zero:        .float 0.0
.balign 4
os_fiq_600:         .float 600.0
.balign 4
os_fiq_60:          .float 60.0
.balign 4
os_fiq_12:          .float 12.0
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
.balign 4

.include "addr32.s" @ If you want binary, use `.incbin`
.balign 4
/* End of Line is Needed */
