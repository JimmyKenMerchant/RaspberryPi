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
.equ __MATH32_PRECISION_HIGH, 1
/*.equ __SOUND, 1*/

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

	str r1, [r0, #equ32_interrupt_disable_irqs1]     @ Make Sure Disable All
	str r1, [r0, #equ32_interrupt_disable_irqs2]
	str r1, [r0, #equ32_interrupt_disable_basic_irqs]

	macro32_dsb ip

	/* Enable UART IRQ */
	mov r1, #1<<25                                   @ UART IRQ #57
	str r1, [r0, #equ32_interrupt_enable_irqs2]

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

	ldr r1, [r0, #equ32_gpio_gpfsel10]
.ifdef __SOUND
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_2      @ Clear GPIO 12
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_2       @ Set GPIO 12 PWM0
.endif
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_4      @ Clear GPIO 14
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_4       @ Set GPIO 14 ALT 0 as TXD0
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_5      @ Clear GPIO 15
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_5       @ Set GPIO 15 ALT 0 as RXD0
	str r1, [r0, #equ32_gpio_gpfsel10]

	/* Obtain Framebuffer from VideoCore IV */

	mov r0, #32
	ldr r1, ADDR32_BCM32_DEPTH
	str r0, [r1]

	macro32_clean_cache r1, ip

	mov r0, #2
	ldr r1, ADDR32_BCM32_ALPHAMODE
	str r0, [r1]

	macro32_clean_cache r1, ip

	push {r0-r3}
	bl bcm32_get_framebuffer
	pop {r0-r3}

	/* UART 115200 Baud */
	push {r0-r3}
	mov r0, #5                                               @ Integer Divisor, 9216000 / 16 Multiplies by 115200 Equals 5
	mov r1, #0                                               @ Fractional Divisor
	mov r2, #0b11<<equ32_uart0_lcrh_sps|equ32_uart0_lcrh_fen @ Line Control
	mov r3, #equ32_uart0_cr_rxe|equ32_uart0_cr_txe           @ Coontrol
	bl uart32_uartinit
	pop {r0-r3}

	/* Each FIFO is 16 Words Depth (8-bit on Tx, 12-bit on Rx) */
	/* The Setting of r1 Below Triggers Tx and Rx Interrupts on Reaching 2 Bytes of RxFIFO (0b000) */
	/* But Now on Only Using Rx Timeout */
	push {r0-r3}
	mov r0, #0b000<<equ32_uart0_ifls_rxiflsel|0b000<<equ32_uart0_ifls_txiflsel @ Trigger Points of Both FIFOs Levels to 1/4
	mov r1, #equ32_uart0_intr_rt @ When 1 Byte and More Exist on RxFIFO
	bl uart32_uartsetint
	pop {r0-r3}

	push {r0-r3}
	mov r0, #128                                             @ 128 Lines Minus 1 Line for #0, 127 Lines Available
	mov r1, #16                                              @ 16 Words, 64 Bytes per Each Row
	bl uart32_uartmalloc
	pop {r0-r3}

	push {r0-r3}
	bl bcm32_poweron_usb
	pop {r0-r3}

	push {r0-r3}
	mov r0, #0xF0           @ Divisor of Clock to Decimal 240 for 1MHz
	mov r1, #0x0030         @ Delay
	orr r1, r1, #0x00300000 @ Delay
	mov r2, #0x40           @ Clock Stretch Timeout
	bl i2c32_i2cinit
	pop {r0-r3}

.ifdef __SOUND
	/**
	 * PWM
	 * Makes 19.2Mhz (From Oscillator).
	 * Sampling Rate 32000hz, Bit Depth 8bit (Max. Range is 300, but is Actually 255 on This)
	 */
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_cm_base_lower
	add r0, r0, #equ32_cm_base_upper

	mov r1, #equ32_cm_passwd
	add r1, r1, #2 << equ32_cm_div_integer
	str r1, [r0, #equ32_cm_pwmdiv]

	mov r1, #equ32_cm_passwd
	add r1, r1, #equ32_cm_ctl_mash_0
	add r1, r1, #equ32_cm_ctl_enab|equ32_cm_ctl_src_osc        @ 19.2Mhz
	str r1, [r0, #equ32_cm_pwmctl]

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_pwm_base_lower
	add r0, r0, #equ32_pwm_base_upper

	mov r1, #300
	str r1, [r0, #equ32_pwm_rng1]

	mov r1, #equ32_pwm_dmac_enable
	orr r1, r1, #7<<equ32_pwm_dmac_panic
	orr r1, r1, #7<<equ32_pwm_dmac_dreq
	str r1, [r0, #equ32_pwm_dmac]

	mov r1, #equ32_pwm_ctl_usef1|equ32_pwm_ctl_clrf1|equ32_pwm_ctl_pwen1
	str r1, [r0, #equ32_pwm_ctl]
.endif

	pop {pc}

os_irq:
	push {r0-r12,lr}

	mov r0, #63                                              @ Last Byte For Null Character
	mov r1, #1
	bl uart32_uartint

	pop {r0-r12,pc}

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

.ifdef __SOUND
	push {r0-r3}
	bl snd32_soundplay
	pop {r0-r3}

	macro32_dsb ip
.endif

	pop {r0-r7,pc}

os_debug:
	push {lr}
	pop {pc}


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
