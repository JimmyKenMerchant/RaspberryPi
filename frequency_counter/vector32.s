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
.include "vector32/el01.s"
.include "vector32/el2.s"
.include "vector32/el3.s"

.section	.os_vector32
.globl _os_start
_os_start:
	ldr pc, _os_reset_addr                    @ 0x00 reset
	ldr pc, _os_undefined_instruction_addr    @ 0x04 (Hyp mode in Hyp mode)
	ldr pc, _os_supervisor_addr               @ 0x08 (Hyp mode in Hyp mode)
	ldr pc, _os_prefetch_abort_addr           @ 0x0C (Hyp mode in Hyp mode)
	ldr pc, _os_data_abort_addr               @ 0x10 (Hyp mode in Hyp mode)
	ldr pc, _os_reserve_addr                  @ If you call `HVC` in Hyp Mode, It translates to `SVC`
	ldr pc, _os_irq_addr                      @ 0x18 (Hyp mode in Hyp mode)
	ldr pc, _os_fiq_addr                      @ 0x1C (Hyp mode in Hyp mode)
_os_reset_addr:                 .word _os_reset
_os_undefined_instruction_addr: .word _os_reset
_os_supervisor_addr:            .word _os_reset
_os_prefetch_abort_addr:        .word _os_reset
_os_data_abort_addr:            .word _os_reset
_os_reserve_addr:               .word _os_reset
_os_irq_addr:                   .word _os_reset
_os_fiq_addr:                   .word _os_fiq

_os_reset:
	mov r0, sp                                @ Store Previous Stack Pointer
	mrc p15, 0, r1, c12, c0, 0                @ Last VBAR Address to Retrieve
	mov sp, #0x8000                           @ Stack Pointer to 0x8000
                                                  @ Memory size 1G(2^30|1024M) bytes, 0x3D090000 (0x00 - 0x3D08FFFF)
	push {r0-r1,lr}

	/* SVC mode FIQ Disable and IRQ Disable, Current Mode */
	mov r0, #equ32_svc_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0

	mov r0, #equ32_fiq_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0

	mov sp, #0x7000

	mov r0, #equ32_svc_mode|equ32_fiq_disable|equ32_irq_disable
	msr cpsr_c, r0

	mov r0, #0x8000
	mcr p15, 0, r0, c12, c0, 0                @ Change VBAR, IVT Base Vector Address

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

	mov r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7   @ Set GPIO 47 OUTPUT
	str r1, [r0, #equ32_gpio_gpfsel40]

	/* GPCLK1 is Already Set to 25Mhz */
	mov r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_5     @ Set GPIO 5 AlT0 (GPCLK1)
	str r1, [r0, #equ32_gpio_gpfsel00]

	mov r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_2     @ Set GPIO 12 AlT0 (PWM0)
	str r1, [r0, #equ32_gpio_gpfsel10]

	mov r1, #equ32_gpio_gpfsel_input << equ32_gpio_gpfsel_1    @ Set GPIO 21 INPUT
	str r1, [r0, #equ32_gpio_gpfsel20]

	mov r1, #equ32_gpio21                                      @ Set GPIO21 Async Rising Edge Detect
	str r1, [r0, #equ32_gpio_gparen0]

	/**
	 * PWM
	 * Makes 19.2Mhz (From Oscillator) Div by 512 Equals 37500Hz.
	 * And Makes 37500Hz Div by 32 (Default Range) Equals 1171.875Hz.
	 * Data is Just 1, so Voltage Will Be One 32th to Full if Lowpass Filter is Attached.
	 */
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_cm_base_lower
	add r0, r0, #equ32_cm_base_upper

	mov r1, #equ32_cm_passwd
	add r1, r1, #0x200 << equ32_cm_div_integer                 @ Decimal 512
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

	/* Obtain Framebuffer from VideoCore IV */
	mov r0, #400
	ldr r1, ADDR32_BCM32_WIDTH
	str r0, [r1]

	push {r0-r3}
	mov r0, r1
	mov r1, #1
	mov r2, #1
	bl system32_cache_operation
	pop {r0-r3}

	mov r0, #320
	ldr r1, ADDR32_BCM32_HEIGHT
	str r0, [r1]

	push {r0-r3}
	mov r0, r1
	mov r1, #1
	mov r2, #1
	bl system32_cache_operation
	pop {r0-r3}

	mov r0, #32
	ldr r1, ADDR32_BCM32_DEPTH
	str r0, [r1]

	push {r0-r3}
	mov r0, r1
	mov r1, #1
	mov r2, #1
	bl system32_cache_operation
	pop {r0-r3}

	mov r0, #2
	ldr r1, ADDR32_BCM32_ALPHAMODE
	str r0, [r1]

	push {r0-r3}
	mov r0, r1
	mov r1, #1
	mov r2, #1
	bl system32_cache_operation
	pop {r0-r3}

	push {r0-r3}
	bl bcm32_get_framebuffer
	pop {r0-r3}

	/* Set Cache Status for Memory Using as Framebuffer (By Section) */
	push {r0-r3}
	mov r0, #1
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_none|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_none|equ32_mmu_section_access_rw_rw
	orr r1, r1, #equ32_mmu_section_nonsecure
	orr r1, r1, #equ32_mmu_domain00
	ldr r2, ADDR32_FB32_FRAMEBUFFER_ADDR
	ldr r2, [r2]
	ldr r3, ADDR32_FB32_FRAMEBUFFER_SIZE
	ldr r3, [r3]
	bl system32_set_cache
	pop {r0-r3}

	/* Set Cache Status for HEAP */
	push {r0-r3}
	mov r0, #1
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_wb_wa|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_wb_wa|equ32_mmu_section_access_rw_rw
	orr r1, r1, #equ32_mmu_section_nonsecure
	orr r1, r1, #equ32_mmu_domain00
	ldr r2, ADDR32_SYSTEM32_HEAP_ADDR
	ldr r2, [r2]
	ldr r3, ADDR32_SYSTEM32_HEAP_SIZE
	ldr r3, [r3]
	bl system32_set_cache
	pop {r0-r3}

	/* Set Cache Status for Virtual Address Descriptor */
	push {r0-r3}
	mov r0, #1
	mov r1, #equ32_mmu_section|equ32_mmu_section_inner_wb_wa|equ32_mmu_section_executenever
	orr r1, r1, #equ32_mmu_section_outer_wb_wa|equ32_mmu_section_access_rw_rw
	orr r1, r1, #equ32_mmu_section_nonsecure
	orr r1, r1, #equ32_mmu_domain00
	ldr r2, ADDR32_SYSTEM32_VADESCRIPTOR_ADDR
	ldr r2, [r2]
	ldr r3, ADDR32_SYSTEM32_VADESCRIPTOR_SIZE
	ldr r3, [r3]
	bl system32_set_cache
	pop {r0-r3}

	macro32_dsb ip
	macro32_invalidate_tlb ip
	macro32_isb ip
	macro32_dsb ip
	macro32_invalidate_instruction ip
	macro32_isb ip

	/* Clear Heap to All Zero */
	push {r0-r3}
	bl system32_clear_heap
	pop {r0-r3}

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

	mov fp, #0x8000                          @ Retrieve Previous Stack Pointer, VBAR,and Link Register
	ldr r0, [fp, #-8]                        @ Stack Pointer
	ldr r1, [fp, #-4]                        @ Stack Pointer
	ldr lr, [fp]                             @ Link Register
	mov sp, r0
	mcr p15, 0, r1, c12, c0, 0               @ Retrieve VBAR Address
	mov pc, lr

_os_debug:
	cpsie f                                  @ cpsie is for enable IRQ (i), FIQ (f) and Abort (a) (all, ifa). cpsid is for disable
	_os_debug_loop1:
		b _os_debug_loop1

_os_fiq:
	cpsid f                                  @ Disable Aborts (a), FIQ(f), IRQ(i)

	push {r0-r12,lr}                         @ Equals to stmfd (stack pointer full, decrement order)
	mrs r0, spsr
	push {r0}

	bl _os_fiq_handler

	pop {r0}
	msr spsr, r0
	pop {r0-r12,lr}                          @ Equals to ldmfd (stack pointer full, decrement order)

	cpsie f                                  @ Enable Aborts (a), FIQ(f), IRQ(i)

	subs pc, lr, #4

_os_fiq_handler:
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_armtimer_base

	mov r1, #0
	str r1, [r0, #equ32_armtimer_clear]       @ any write to clear/ acknowledge

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
		mov pc, lr

/**
 * Variables
 */
.balign 4
gpio_toggle:       .byte 0b00000000
.balign 4
_string_hello:
	.ascii "\tALOHA!\n\tFrequency Counter.\n\tGPIO 21 is Input Pin.\n\n\tNote: Voltage Limitation is UP TO 3.3V!\n\tGPIO 12 is Output Pin for Test.\n\tGPIO 5 is Output Pin for Max. Frequency Test.\n\tMahalo!\0" @ Add Null Escape Character on The End
string_hello:
	.word _string_hello
_string_helts:
	.ascii "Hz\0" @ Add Null Escape Character on The End
string_helts:
	.word _string_helts
_string_copy1:
	.ascii "Product of Kenta Ishii\0" @ Add Null Escape Character on The End
string_copy1:
	.word _string_copy1
_string_copy2:
	.ascii "Powered by ALOHA SYSTEM32\0" @ Add Null Escape Character on The End
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
