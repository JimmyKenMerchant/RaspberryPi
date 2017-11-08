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

	mov r1, #0x7C                             @ Decimal 124 to divide 240Mz by 125 to 1.92Mhz (Predivider is 10 Bits Wide)
	str r1, [r0, #equ32_armtimer_predivider]

	mov r1, #0x2700                           @ 0x2700 High 1 Byte of decimal 9999 (10000 - 1), 16 bits counter on default
	add r1, r1, #0x0F                         @ 0x0F Low 1 Byte of decimal 9999, 16 bits counter on default
	str r1, [r0, #equ32_armtimer_load]

	mov r1, #0x3E0000                         @ High 2 Bytes
	add r1, r1, #0b10100100                   @ Low 2 Bytes (00A4), Timer Enable and Timer Interrupt Enable, Prescaler 1/16 to 120K
	                                          @ 1/16 is #0b10100100, 1/256 is #0b10101000
	str r1, [r0, #equ32_armtimer_control]

	/* So We can get a 12hz Timer Interrupt (120000/10000) */

	/* GPIO */
	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	mov r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_2         @ Set GPIO 12 PWM0
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_3     @ Set GPIO 13 PWM1
	str r1, [r0, #equ32_gpio_gpfsel10]

	mov r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7       @ Set GPIO 47 OUTPUT
.ifndef __ZERO
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_0     @ Set GPIO 40 PWM0 (to Minijack)
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_5     @ Set GPIO 45 PWM1 (to Minijack)
.endif
	str r1, [r0, #equ32_gpio_gpfsel40]


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
	bl arm32_set_cache
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
	ldr r2, ADDR32_SYSTEM32_DATAMEMORY
	mov r3, #equ32_system32_datamemory_size
	bl arm32_set_cache
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
	ldr r2, ADDR32_ARM32_VADESCRIPTOR_ADDR
	ldr r2, [r2]
	ldr r3, ADDR32_ARM32_VADESCRIPTOR_SIZE
	ldr r3, [r3]
	bl arm32_set_cache
	pop {r0-r3,lr}

	macro32_dsb ip
	macro32_invalidate_tlb_all ip
	macro32_isb ip
	macro32_dsb ip
	macro32_invalidate_instruction_all ip
	macro32_isb ip

	/**
	 * 20-21 Bits for CP 10, 22-23 Bits for CP 11
	 * Each 0b01 is for Enable in Previlege Mode
	 * Each 0b11 is for Enable in Previlege and User Mode
	 */
	mov r0, #0b1111
	lsl r0, r0, #20

	mcr p15, 0, r0, c1, c0, 2                 @ CPACR

	macro32_dsb ip
	macro32_isb ip                            @ Must Need When You Renew CPACR

	mov r0, #0x40000000                       @ Enable NEON/VFP
	vmsr fpexc, r0

	/**
	 * DMA
	 */

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

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_dma_base
	add r0, r0, #equ32_dma_channel_offset

ldr r1, [r0, #equ32_dma_cs]
macro32_debug r1, 0, 0

ldr r1, [r0, #equ32_dma_conblk_ad]
macro32_debug r1, 0, 12

ldr r1, [r0, #8]
macro32_debug r1, 0, 24

ldr r1, [r0, #12]
macro32_debug r1, 0, 36

ldr r1, [r0, #16]
macro32_debug r1, 0, 48

ldr r1, [r0, #20]
macro32_debug r1, 0, 60

ldr r1, [r0, #24]
macro32_debug r1, 0, 72

ldr r1, [r0, #28]
macro32_debug r1, 0, 84

ldr r1, [r0, #32]
macro32_debug r1, 0, 96
	
	mov pc, lr

os_irq:
	push {r0-r12}
	pop {r0-r12}
	mov pc, lr

os_fiq:
	push {r0-r7}

	/* Clear Timer Interrupt */

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_armtimer_base

	mov r1, #0
	str r1, [r0, #equ32_armtimer_clear]       @ any write to clear/ acknowledge

	/* Blinker */

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	ldrb r1, os_fiq_gpio_toggle
	eor r1, #0b00000001                       @ Exclusive OR to toggle
	strb r1, os_fiq_gpio_toggle

	tst r1, #0b00000001
	addeq r0, r0, #equ32_gpio_gpclr1
	addne r0, r0, #equ32_gpio_gpset1
	mov r1, #equ32_gpio47
	str r1, [r0]

	macro32_dsb ip

	pop {r0-r7}
	mov pc, lr

/**
 * Variables
 */
os_fiq_gpio_toggle:       .byte 0b00000000
.balign 4
_string_hello:
	.ascii "\nMAHALO! WE ARE OHANA!\n\0" @ Add Null Escape Character on The End
.balign 4
string_hello:
	.word _string_hello

.include "addr32.s" @ If you want binary, use `.incbin`

/* End of Line is Needed */
