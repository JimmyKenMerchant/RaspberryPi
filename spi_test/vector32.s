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

	mov r1, #0x0000                           @ High 1 Byte of decimal 1 (2 - 1), 16 bits counter on default
	add r1, r1, #0x01                         @ Low 1 Byte of decimal 1, 16 bits counter on default
	str r1, [r0, #equ32_armtimer_load]

	mov r1, #0x3E0000                         @ High 2 Bytes
	add r1, r1, #0b10100100                   @ Low 2 Bytes (00A4), Timer Enable and Timer Interrupt Enable, Prescaler 1/16 to 100K
	                                          @ 1/16 is #0b10100100, 1/256 is #0b10101000
	str r1, [r0, #equ32_armtimer_control]

	/* So We can get a 50Khz Timer Interrupt (100000/2) */

	/* GPIO */
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	/* Use ACT LED Only in Debugging to Reduce Noise */
.ifndef __RASPI3B
	ldr r1, [r0, #equ32_gpio_gpfsel40]
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_7
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7     @ Set GPIO 47 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel40]
.endif

	ldr r1, [r0, #equ32_gpio_gpfsel00]
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_7      @ Clear GPIO 7
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_7       @ Set GPIO 7 ALT 0
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_8      @ Clear GPIO 8
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_8       @ Set GPIO 8 ALT 0
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_9      @ Clear GPIO 9 
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_9       @ Set GPIO 9 ALT 0
	str r1, [r0, #equ32_gpio_gpfsel00]

	ldr r1, [r0, #equ32_gpio_gpfsel10]
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_0      @ Clear GPIO 10
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_0       @ Set GPIO 10 ALT 0
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_1      @ Clear GPIO 11
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_1       @ Set GPIO 11 ALT 0
	str r1, [r0, #equ32_gpio_gpfsel10]

	/* Obtain Framebuffer from VideoCore IV */

	mov r0, #spi_test_fiqhandler_display_width
	ldr r1, ADDR32_BCM32_DISPLAY_WIDTH
	str r0, [r1]

	macro32_clean_cache r1, ip

	mov r0, #spi_test_fiqhandler_display_width
	ldr r1, ADDR32_BCM32_WIDTH
	str r0, [r1]

	macro32_clean_cache r1, ip

	mov r0, #spi_test_fiqhandler_display_height
	ldr r1, ADDR32_BCM32_DISPLAY_HEIGHT
	str r0, [r1]

	macro32_clean_cache r1, ip

	mov r0, #spi_test_fiqhandler_display_height
	ldr r1, ADDR32_BCM32_HEIGHT
	str r0, [r1]

	macro32_clean_cache r1, ip

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

/*
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
*/

	bl spi_test_fiqhandler

	macro32_dsb ip

	pop {r0-r7,pc}


/**
 * Handler to Use in FIQ
 */
spi_test_fiqhandler:
	temp         .req r0
	horizon      .req r1
	previous     .req r2
	horizon_next .req r3
	current      .req r4
	resolution   .req r5
	xcount       .req r6
	xdivision    .req r7

	push {r4-r7,lr}

	/* Get Data from MCP3002 AD Converter */
	bl spi32_spirx                        @ Return Data to r0
	mov current, r0

	lsr current, current, #16             @ Get Only Higher 16-bit

	/* Convert 10-bit (0x3FF) to 8-bit (0xFF) in Default */
	lsr current, current, #2              @ Substitute of Division by 4

	/* Reverse Value for Drawing Line with This Value as Height */
	mov temp, #0xFF
	and current, current, temp
	sub current, current, temp
	mvn current, current                  @ Logical Not to Convert Minus to Plus
	add current, current, #1              @ Add 1 to Convert Minus to Plus
	and current, current, temp
	add current, current, #spi_test_fiqhandler_ystart
	
	ldr previous, spi_test_fiqhandler_previous
	ldr horizon, spi_test_fiqhandler_horizon
	ldr resolution, spi_test_fiqhandler_resolution
	ldr xcount, spi_test_fiqhandler_xcount
	ldr xdivision, spi_test_fiqhandler_xdivision

	macro32_dsb ip

	add xcount, xcount, #1
	cmp xcount, xdivision
	blo spi_test_fiqhandler_common

	mov xcount, #0

/*macro32_debug current, 200, 200*/
/*macro32_debug previous, 200, 212*/

	add horizon_next, horizon, resolution

/*macro32_debug horizon, 200, 224*/

	push {r0-r3}
	mov r0, #0xFF
	add r0, r0, #1                @ draw32_line draws the end of the point inclusively
	push {r0}
	ldr r0, ADDR32_COLOR32_BLUE
	ldr r0, [r0]
	mov r1, horizon
	mov r2, #spi_test_fiqhandler_ystart
	mov r3, resolution
	bl fb32_block_color
	add sp, sp, #4
	pop {r0-r3}

	macro32_dsb ip

	push {r0-r4}
	ldr r0, ADDR32_COLOR32_YELLOW
	ldr r0, [r0]                  @ Color (16-bit or 32-bit)
	mov r1, horizon               @ X Coordinate1
	mov r2, previous              @ Y Coordinate1
	sub r3, horizon_next, #1      @ X Coordinate2, draw32_line draws the end of the point inclusively
	mov r4, current               @ Y Coordinate2, draw32_line draws the end of the point inclusively
	mov r5, #1                    @ Point Width in Pixels
	mov r6, #1                    @ Point Height in Pixels
	push {r4-r6}
	bl draw32_line
	add sp, sp, #12
	pop {r0-r4}  

	mov temp, #spi_test_fiqhandler_xend_upper
	add temp, temp, #spi_test_fiqhandler_xend_lower
	cmp horizon_next, temp
	movhs horizon_next, #spi_test_fiqhandler_xstart

	macro32_dsb ip

	str current, spi_test_fiqhandler_previous
	str horizon_next, spi_test_fiqhandler_horizon

	spi_test_fiqhandler_common:
		str xcount, spi_test_fiqhandler_xcount

		/* Command to MCP3002 AD Converter */
		mov r0, #0b11<<equ32_spi0_cs_clear
		mov r1, #0b01100000<<24
		mov r2, #100                      @ 240Mhz/100, 2.4Mhz
		/*mov r2, #80*/                       @ 240Mhz/80, 3Mhz
		bl spi32_spitx

		pop {r4-r7,pc}

.unreq temp
.unreq horizon
.unreq previous
.unreq horizon_next
.unreq current
.unreq resolution
.unreq xcount
.unreq xdivision

spi_test_fiqhandler_previous:      .word spi_test_fiqhandler_ystart
spi_test_fiqhandler_horizon:       .word spi_test_fiqhandler_xstart
spi_test_fiqhandler_xcount:        .word 0x00

/**
 * Increasing resolution makes faster horizontal sync. This causes incorrect displaying.
 * In contrast, increasing xdivision makes slower horizontal sync.
 * Duration of each horizontal sync seems to be needed at least 80 milliseconds.
 */
.globl spi_test_fiqhandler_resolution
.globl spi_test_fiqhandler_xdivision
spi_test_fiqhandler_resolution:    .word 1       @ Shorten Seconds in Width of Display
spi_test_fiqhandler_xdivision:     .word 4       @ Lengthen Seconds in Width of Display

.equ spi_test_fiqhandler_display_width,  0x460  @ Decimal 1120, Multiplies of 8 Seems to Be Preferred
.equ spi_test_fiqhandler_display_height, 0x280  @ Decimal 640, Multiplies of 8 Seems to Be Preferred

/**
 * Adjust Width to Fit to 20 Milliseconds per Horizontal Trace (If Resolution Is 1 and X Division Is 1).
 * 1 Second Divided by 50Khz Equals 20 Micro Seconds.
 * 20 Micro Seconds Multiplied by 1000 Equals 20 Milliseconds.
 */
.equ spi_test_fiqhandler_xstart,         60
.equ spi_test_fiqhandler_xend_upper,     0x3E0  @ Decimal 1000
.equ spi_test_fiqhandler_xend_lower,     0x008
.equ spi_test_fiqhandler_ystart,         100 

/**
 * Variables
 */
.balign 4
_string_hello:
	.ascii "\nAloha! WE ARE OHANA!\n\0" @ Add Null Escape Character on The End
.balign 4
string_hello:
	.word _string_hello
os_fiq_gpio_toggle: .byte 0b00000000
.balign 4

.include "addr32.s" @ If you want binary, use `.incbin`
.balign 4
/* End of Line is Needed */
