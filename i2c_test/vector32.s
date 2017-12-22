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
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_2      @ Clear GPIO 2
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_2       @ Set GPIO 2 ALT 0 as SDA1
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_3      @ Clear GPIO 3
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_3       @ Set GPIO 3 ALT 0 as SCL1
	str r1, [r0, #equ32_gpio_gpfsel00]

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

	pop {r0-r7,pc}


os_debug:
	/* Auto (Local) Variables, but just Aliases */
	heap .req r0
	addr .req r1
	data .req r2

	push {lr}

	push {r0-r3}
	mov r0, #0x960          @ Divisor of Clock to Decimal 2400
	mov r1, #0x0030         @ Delay
	orr r1, r1, #0x00300000 @ Delay
	mov r2, #0x40           @ Clock Stretch Timeout
	bl i2c32_i2cinit
	pop {r0-r3}

	push {r1-r3}
	mov heap, #1
	bl heap32_malloc
	pop {r1-r3}

	mov addr, #0x0011       @ Most Significant at First, Little Endian
	orr addr, addr, #0x2200 @ Least Significant at Second, Little Endian

	mov data, #0x99
	orr addr, addr, data, lsl #16
	
	str addr, [heap]

macro32_debug_hexa heap, 100, 88, 3

	/* Actual Write of Data */
	push {r0-r3}
	mov r1, #0b01010000     @ Device Address, Address Bit[7:1] to Bit[6:0]
	mov r2, #3              @ Transfer Size  
	bl i2c32_i2ctx

macro32_debug r0, 100, 100

	pop {r0-r3}

	push {r0-r3}
	mov r0, #0xFF00
	bl arm32_sleep
	pop {r0-r3}

	/* Dummy Write to Stay Current Address*/
	push {r0-r3}
	mov r1, #0b01010000     @ Device Address, Address Bit[7:1] to Bit[6:0]
	mov r2, #2              @ Transfer Size  
	bl i2c32_i2ctx

macro32_debug r0, 100, 112

	pop {r0-r3}

	push {r0-r3}
	mov r0, #0xFF00
	bl arm32_sleep
	pop {r0-r3}

	/* Read */
	push {r0-r3}
	mov r1, #0b01010000     @ Device Address, Address Bit[7:1] to Bit[6:0]
	mov r2, #1              @ Transfer Size 
	bl i2c32_i2crx

macro32_debug r0, 100, 124

	pop {r0-r3}

macro32_debug_hexa heap, 100, 136, 3

	pop {pc}

.unreq heap
.unreq addr
.unreq data


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
