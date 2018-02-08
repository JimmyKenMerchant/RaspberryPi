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

	mov r1, #0x10000
	add r1, r1, #0x8600
	add r1, r1, #0x9F                         @ Decimal 99999 (100000 - 1), 23 bits counter
	str r1, [r0, #equ32_armtimer_load]

	mov r1, #equ32_armtimer_enable|equ32_armtimer_interrupt_enable|equ32_armtimer_prescale_16|equ32_armtimer_23bit_counter @ Prescaler 1/16 to 100K

	str r1, [r0, #equ32_armtimer_control]

	/**
	 * So We need to get a 1hz Timer Interrupt (100000/100000).
	 */

	/* GPIO */
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

.ifndef __RASPI3B
	ldr r1, [r0, #equ32_gpio_gpfsel40]
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_7   @ Clear GPIO 47
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7  @ Set GPIO 47 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel40]
.endif

	ldr r1, [r0, #equ32_gpio_gpfsel00]
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_4   @ Clear GPIO 4
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_4    @ Set GPIO 4 AlT0 (GPCLK0)
	str r1, [r0, #equ32_gpio_gpfsel00]

	ldr r1, [r0, #equ32_gpio_gpfsel10]
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_2   @ Clear GPIO 12
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_2    @ Set GPIO 12 AlT0 (PWM0)
	str r1, [r0, #equ32_gpio_gpfsel10]

	ldr r1, [r0, #equ32_gpio_gpfsel20]
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_1   @ Clear GPIO 21
	orr r1, r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_1   @ Set GPIO 21 INPUT
	str r1, [r0, #equ32_gpio_gpfsel20]

	ldr r1, [r0, #equ32_gpio_gpren0]
	orr r1, r1, #equ32_gpio21                                     @ Set GPIO21 Rising Edge Detect
	str r1, [r0, #equ32_gpio_gpren0]

	/**
	 * PWM
	 * Makes 19.2Mhz (From Oscillator) Div by 3 Equals 6.4Mhz
	 * And Div by 32 (Default Range) Equals 200KHz.
	 * Data is Just 1, so Voltage Will Be One 32th to Full if Lowpass Filter is Attached.
	 */
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_cm_base_lower
	add r0, r0, #equ32_cm_base_upper

	mov r1, #equ32_cm_passwd
	add r1, r1, #3 << equ32_cm_div_integer
	str r1, [r0, #equ32_cm_pwmdiv]

	mov r1, #equ32_cm_passwd
	add r1, r1, #equ32_cm_ctl_mash_0
	add r1, r1, #equ32_cm_ctl_enab|equ32_cm_ctl_src_osc        @ 19.2Mhz
	str r1, [r0, #equ32_cm_pwmctl]

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_pwm_base_lower
	add r0, r0, #equ32_pwm_base_upper

	mov r1, #1
	str r1, [r0, #equ32_pwm_dat1]

	mov r1, #equ32_pwm_ctl_msen1|equ32_pwm_ctl_pwen1
	str r1, [r0, #equ32_pwm_ctl]


	/**
	 * Set GPCLK0 to 5.00Mhz
	 * Considering of the latency by instructions,
	 * The counted value has a minus error toward the right value.
	 */

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_cm_base_lower
	add r0, r0, #equ32_cm_base_upper

	mov r1, #equ32_cm_passwd
	add r1, r1, #100 << equ32_cm_div_integer
	str r1, [r0, #equ32_cm_gp0div]

	mov r1, #equ32_cm_passwd
	add r1, r1, #equ32_cm_ctl_mash_0
	add r1, r1, #equ32_cm_ctl_enab|equ32_cm_ctl_src_plld       @ 500Mhz
	str r1, [r0, #equ32_cm_gp0ctl]

	/* Obtain Framebuffer from VideoCore IV */
	mov r0, #400
	ldr r1, ADDR32_BCM32_WIDTH
	str r0, [r1]

	macro32_clean_cache r1, ip

	mov r0, #320
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

os_debug:
	push {lr}

	ldr r0, ADDR32_COLOR32_NAVYBLUE
	ldr r0, [r0]
	bl fb32_clear_color

	ldr r0, ADDR32_PRINT32_FONT_BACKCOLOR
	ldr r1, ADDR32_COLOR32_BLUE
	ldr r1, [r1]
	str r1, [r0]

	ldr r0, string_hello                      @ Pointer of Array of String
	macro32_print_string r0 0 48 200

	ldr r0, string_helts                      @ Pointer of Array of String
	macro32_print_string r0 232 200 2

	ldr r0, string_copy1                      @ Pointer of Array of String
	macro32_print_string r0 148 284 30

	ldr r0, string_copy2                      @ Pointer of Array of String
	macro32_print_string r0 148 300 30

	ldr r0, ADDR32_PRINT32_FONT_COLOR
	ldr r1, ADDR32_COLOR32_YELLOW
	ldr r1, [r1]
	str r1, [r0]

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base
	mov r1, #equ32_gpio21

	multiply       .req r5
	basement       .req r6
	freq_count     .req r7
	vfp_correction .req s0
	vfp_freq_count .req s1

	ldr r4, mem_correction
	vmov vfp_correction, r4
	ldr multiply, mem_multiply
	ldr basement, mem_basement
	mov freq_count, #0

	cpsie f

	_os_render_loop:
		ldr r2, [r0, #equ32_gpio_gpeds0]
		tst r2, r1
		strne r1, [r0, #equ32_gpio_gpeds0]
		addne freq_count, freq_count, #1
		b _os_render_loop

	pop {pc}

os_irq:
	push {r0-r12}
	pop {r0-r12}
	mov pc, lr

os_fiq:
	push {r0-r4}                              @ r5-r7 is used across modes

.ifdef __ARMV6
	macro32_invalidate_instruction_all ip
	macro32_dsb ip
.endif

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_armtimer_base

	mov r1, #0                                @ Disable Timer
	str r1, [r0, #equ32_armtimer_control]

	mov r1, #0
	str r1, [r0, #equ32_armtimer_clear]       @ any write to clear/ acknowledge

	macro32_dsb ip                            @ Ensure to Disable Timer

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

	macro32_dsb ip                            @ Data Synchronization Barrier is Needed
.endif
 
	/* Correct and Set Basement */

	vmov vfp_freq_count, freq_count
	vcvt.f32.u32 vfp_freq_count, vfp_freq_count
	vmul.f32 vfp_freq_count, vfp_freq_count, vfp_correction
	vcvtr.u32.f32 vfp_freq_count, vfp_freq_count
	vmov r0, vfp_freq_count
	mul r0, r0, multiply
	add r0, r0, basement

	push {lr}
	bl cvt32_hexa_to_deci
	pop {lr}

	macro32_print_number_double r0, r1, 100, 200, 16

	/* Reset Sequence */

	mov freq_count, #0

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_armtimer_base

	mov r1, #0x10000
	add r1, r1, #0x8600
	add r1, r1, #0x9F                         @ Decimal 99999 (100000 - 1), 23 bits counter
	str r1, [r0, #equ32_armtimer_load]        @ Reset Counter

	mov r1, #equ32_armtimer_enable|equ32_armtimer_interrupt_enable|equ32_armtimer_prescale_16|equ32_armtimer_23bit_counter @ Prescaler 1/16 to 100K

	str r1, [r0, #equ32_armtimer_control]

	macro32_dsb ip                            @ Ensure to Enable Timer
	pop {r0-r4}
	mov pc, lr

.unreq multiply
.unreq basement
.unreq freq_count
.unreq vfp_correction
.unreq vfp_freq_count


/**
 * Variables
 */
.balign 4
gpio_toggle:       .byte 0b00000000
.balign 4
_string_hello:
	.ascii "\tALOHA!\n\tFrequency Counter.\n\tGPIO 21 is Input Pin.\n\n\tNote: Voltage Limitation is UP TO 3.3V!\n\tGPIO 12 is Output Pin for Test.\n\tGPIO 4 is Output Pin for Max. Frequency Test.\n\tMahalo!\0" @ Add Null Escape Character on The End
.balign 4
string_hello:
	.word _string_hello
_string_helts:
	.ascii "Hz\0" @ Add Null Escape Character on The End
.balign 4
string_helts:
	.word _string_helts
_string_copy1:
	.ascii "Product of Kenta Ishii\0" @ Add Null Escape Character on The End
.balign 4
string_copy1:
	.word _string_copy1
_string_copy2:
	.ascii "Powered by ALOHA SYSTEM32\0" @ Add Null Escape Character on The End
.balign 4
string_copy2:
	.word _string_copy2
.balign 4
mem_correction:
	.float 0.999991
.balign 4
mem_multiply:
	.word 1
.balign 4
mem_basement:
	.word 0
.balign 4

.include "addr32.s" @ If you want binary, use `.incbin`
.balign 4
/* End of Line is Needed */
