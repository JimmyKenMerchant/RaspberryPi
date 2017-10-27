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

	mov r1, #0x2700                           @ 0x2700 High 1 Byte of decimal 9999 (10000 - 1), 16 bits counter on default
	add r1, r1, #0x0F                         @ 0x0F Low 1 Byte of decimal 9999, 16 bits counter on default
	str r1, [r0, #equ32_armtimer_load]

	mov r1, #equ32_armtimer_enable|equ32_armtimer_interrupt_enable|equ32_armtimer_prescale_16 @ Prescaler 1/16 to 100K

	str r1, [r0, #equ32_armtimer_control]

	/**
	 * So We need to get a 10hz Timer Interrupt (100000/10000).
	 * But in this case, counter will be reset on FIQ.
	 * For correction on the reset, make 9999, but not 10000.
	 */

	/* GPIO */
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	mov r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7   @ Set GPIO 47 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel40]

	mov r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_4     @ Set GPIO 4 AlT0 (GPCLK0)
	str r1, [r0, #equ32_gpio_gpfsel00]

	mov r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_2     @ Set GPIO 12 AlT0 (PWM0)
	str r1, [r0, #equ32_gpio_gpfsel10]

	mov r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_1    @ Set GPIO 21 INPUT
	str r1, [r0, #equ32_gpio_gpfsel20]

	mov r1, #equ32_gpio21                                      @ Set GPIO21 Rising Edge Detect
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

	/* Set Cache Status for Memory Using as Framebuffer (By Section) */
	push {r0-r3,lr}
.ifndef __ARMV6
	mov r0, #1
.else
	mov r0, #0
.endif
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_none|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_none|equ32_mmu_section_access_rw_rw
.ifndef __ARMV6
	orr r1, r1, #equ32_mmu_section_nonsecure
.endif
	orr r1, r1, #equ32_mmu_domain00
	ldr r2, ADDR32_FB32_FRAMEBUFFER_ADDR
	ldr r2, [r2]
	ldr r3, ADDR32_FB32_FRAMEBUFFER_SIZE
	ldr r3, [r3]
	bl system32_set_cache
	pop {r0-r3,lr}

	/* Set Cache Status for HEAP */
	push {r0-r3,lr}
.ifndef __ARMV6
	mov r0, #1
.else
	mov r0, #0
.endif
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_wb_wa|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_wb_wa|equ32_mmu_section_access_rw_rw
.ifndef __ARMV6
	orr r1, r1, #equ32_mmu_section_nonsecure
.endif
	orr r1, r1, #equ32_mmu_domain00
	ldr r2, ADDR32_SYSTEM32_HEAP_ADDR
	ldr r2, [r2]
	ldr r3, ADDR32_SYSTEM32_HEAP_SIZE
	ldr r3, [r3]
	bl system32_set_cache
	pop {r0-r3,lr}

	/* Set Cache Status for Virtual Address Descriptor */
	push {r0-r3,lr}
.ifndef __ARMV6
	mov r0, #1
.else
	mov r0, #0
.endif
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_wb_wa|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_wb_wa|equ32_mmu_section_access_rw_rw
.ifndef __ARMV6
	orr r1, r1, #equ32_mmu_section_nonsecure
.endif
	orr r1, r1, #equ32_mmu_domain00
	ldr r2, ADDR32_SYSTEM32_VADESCRIPTOR_ADDR
	ldr r2, [r2]
	ldr r3, ADDR32_SYSTEM32_VADESCRIPTOR_SIZE
	ldr r3, [r3]
	bl system32_set_cache
	pop {r0-r3,lr}

	macro32_dsb ip
	macro32_invalidate_tlb_all ip
	macro32_isb ip
	macro32_dsb ip
	macro32_invalidate_instruction_all ip
	macro32_isb ip

	/* Clear Heap to All Zero */
	push {r0-r3,lr}
	bl system32_clear_heap
	pop {r0-r3,lr}

	/* Coprocessor Access Control Register (CPACR) For Floating Point and NEON (SIMD) */
	
	/**
	 * 20-21 Bits for CP 10, 22-23 Bits for CP 11
	 * Each 0b01 is for Enable in Previlege Mode
	 * Each 0b11 is for Enable in Previlege and User Mode
	 */
	mov r0, #0b0101
	lsl r0, r0, #20

	mcr p15, 0, r0, c1, c0, 2                 @ CPACR

	macro32_dsb ip
	macro32_isb ip                            @ Must Need When You Renew CPACR

	mov r0, #0x40000000                       @ Enable NEON/VFP
	vmsr fpexc, r0

_os_render:
	
	ldr r0, ADDR32_COLOR32_NAVYBLUE
	ldr r0, [r0]
	bl fb32_clear_color

	ldr r0, string_hello                      @ Pointer of Array of String
	ldr r1, ADDR32_COLOR32_WHITE              @ Color (16-bit or 32-bit)
	ldr r1, [r1]
	ldr r2, ADDR32_COLOR32_BLUE               @ Background Color (16-bit or 32-bit)
	ldr r2, [r2]
	ldr r3, ADDR32_FONT_MONO_12PX_ASCII       @ Font
	ldr r3, [r3]
	macro32_print_string r0 0 48 r1 r2 200 8 12 r3

	ldr r0, string_helts                      @ Pointer of Array of String
	macro32_print_string r0 232 200 r1 r2 2 8 12 r3

	ldr r0, string_copy1                      @ Pointer of Array of String
	macro32_print_string r0 148 284 r1 r2 30 8 12 r3

	ldr r0, string_copy2                      @ Pointer of Array of String
	macro32_print_string r0 148 300 r1 r2 30 8 12 r3

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base
	mov r1, #equ32_gpio21

	cpsie f

	_os_render_loop:
		ldr r2, [r0, #equ32_gpio_gpeds0]
		tst r2, r1
		strne r1, [r0, #equ32_gpio_gpeds0]
		ldrne r2, freq_count
		addne r2, r2, #1
		strne r2, freq_count
		b _os_render_loop

	mov pc, lr

os_irq:
	push {r0-r12}
	pop {r0-r12}
	mov pc, lr

os_fiq:
	push {r0-r7}

.ifdef __ARMV6
	macro32_invalidate_instruction_all ip
.endif

	ldr r1, gpio_toggle
	eor r1, #0b00000001                       @ Exclusive OR to toggle
	str r1, gpio_toggle

	cmp r1, #0
	addeq r0, r0, #equ32_gpio_gpclr1
	addne r0, r0, #equ32_gpio_gpset1
	mov r1, #equ32_gpio47
	str r1, [r0]

	ldr r0, irq_count
	add r0, r0, #1
	cmp r0, #10
	strlt r0, irq_count

	macro32_dsb ip                            @ Data Synchronization Barrier is Needed

	blt _os_fiq_handler_jump

	mov r0, #0
	str r0, irq_count

	ldr r0, freq_count
	mov r1, #0
	str r1, freq_count

	push {lr}
	bl math32_hexa_to_deci32
	pop {lr}

	ldr r2, ADDR32_COLOR32_YELLOW             @ Color (16-bit or 32-bit)
	ldr r2, [r2]
	ldr r3, ADDR32_COLOR32_BLUE               @ Background Color (16-bit or 32-bit)
	ldr r3, [r3]
	ldr r4, ADDR32_FONT_MONO_12PX_ASCII       @ Font
	ldr r4, [r4]
	macro32_print_number_double r0 r1 100 200 r2 r3 16 8 12 r4

	_os_fiq_handler_jump:

		mov r0, #equ32_peripherals_base
		add r0, r0, #equ32_armtimer_base

		mov r1, #0                                @ Disable Timer
		str r1, [r0, #equ32_armtimer_control]

		macro32_dsb ip                            @ Ensure to Disable Timer

		mov r1, #0
		str r1, [r0, #equ32_armtimer_clear]       @ any write to clear/ acknowledge

		mov r1, #0x2700                           @ 0x2700 High 1 Byte of decimal 9998 (9999 - 1), 16 bits counter on default
		add r1, r1, #0x0E                         @ 0x0E Low 1 Byte of decimal 9998, 16 bits counter on default
		str r1, [r0, #equ32_armtimer_load]        @ Reset Counter

		mov r1, #equ32_armtimer_enable|equ32_armtimer_interrupt_enable|equ32_armtimer_prescale_16

		str r1, [r0, #equ32_armtimer_control]

		macro32_dsb ip                            @ Ensure to Enable Timer
		pop {r0-r7}
		mov pc, lr

/**
 * Variables
 */
.balign 4
gpio_toggle:       .byte 0b00000000
.balign 4
_string_hello:
	.ascii "\tALOHA!\n\tFrequency Counter.\n\tGPIO 21 is Input Pin.\n\n\tNote: Voltage Limitation is UP TO 3.3V!\n\tGPIO 12 is Output Pin for Test.\n\tGPIO 5 is Output Pin for Max. Frequency Test.\n\tMahalo!\0" @ Add Null Escape Character on The End
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
freq_count:
	.word 0x00000000
irq_count:
	.word 0x00000000
.balign 4

.include "addr32.s" @ If you want binary, use `.incbin`
.balign 4
/* End of Line is Needed */
