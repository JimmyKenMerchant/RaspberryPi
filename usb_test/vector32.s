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

	ldr r1, [r0, #equ32_gpio_gpfsel40]

.ifndef __ARMV6
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_4   @ Clear GPIO 44
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_4    @ Set GPIO 44 AlT0 (GPCLK1)
.endif

.ifndef __RASPI3B
	bic r1, r1, #equ32_gpio_gpfsel_clear << equ32_gpio_gpfsel_7   @ Clear GPIO 47
	orr r1, r1, #equ32_gpio_gpfsel_output << equ32_gpio_gpfsel_7  @ Set GPIO 47 OUTPUT
.endif

	str r1, [r0, #equ32_gpio_gpfsel40]

.ifndef __ARMV6
	/**
	 * Set GPCLK1 to 25.00Mhz
	 * Considering of the latency by instructions,
	 * The counted value has a minus error toward the right value.
	 */

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_cm_base_lower
	add r0, r0, #equ32_cm_base_upper

	ldr r1, [r0, #equ32_cm_gp1ctl]
	orr r1, r1, #equ32_cm_passwd
	bic r1, r1, #equ32_cm_ctl_enab
	str r1, [r0, #equ32_cm_gp1ctl]

	os_reset_loop1:
		ldr r1, [r0, #equ32_cm_gp1ctl]
		tst r1, #equ32_cm_ctl_busy
		bne os_reset_loop1

	mov r1, #equ32_cm_passwd
	add r1, r1, #20 << equ32_cm_div_integer
	str r1, [r0, #equ32_cm_gp1div]

	mov r1, #equ32_cm_passwd
	add r1, r1, #equ32_cm_ctl_mash_0
	add r1, r1, #equ32_cm_ctl_enab|equ32_cm_ctl_src_plld       @ 500Mhz
	str r1, [r0, #equ32_cm_gp1ctl]
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

	bl bcm32_poweron_usb

macro32_debug r0 500 90

	bl usb2032_otg_host_reset_bcm

macro32_debug r0 500 102

	mov r1, #equ32_peripherals_base
	add r1, r1, #equ32_usb20_otg_base
	ldr r0, [r1, #equ32_bcm_usb20_vbus_drv]

macro32_debug r0 500 114

	mov r1, #equ32_peripherals_base
	add r1, r1, #equ32_usb20_otg_base
	add r1, r1, #equ32_usb20_otg_host_base
	ldr r0, [r1, #equ32_usb20_otg_hprt]

macro32_debug r0 500 126

	mov r1, #equ32_peripherals_base
	add r1, r1, #equ32_usb20_otg_base
	ldr r0, [r1, #equ32_usb20_otg_grxfsiz]

macro32_debug r0 500 138

	mov r1, #equ32_peripherals_base
	add r1, r1, #equ32_usb20_otg_base
	ldr r0, [r1, #equ32_usb20_otg_gnptxfsiz]

macro32_debug r0 500 150

	mov r1, #equ32_peripherals_base
	add r1, r1, #equ32_usb20_otg_base
	add r1, r1, #equ32_usb20_otg_ptxfsiz_base
	ldr r0, [r1, #equ32_usb20_otg_hptxfsiz]

macro32_debug r0 500 162

	mov r0, #2
	mov r1, #0
	bl usb2032_hub_activate

macro32_debug r0 500 174

	push {r0-r1}
	mov r1, r0
	mov r0, #2
	bl usb2032_hub_search_device
	mov r3, r0
	pop {r0-r1}

.ifndef __ARMV6
	push {r0-r1}
	mov r1, r0
	mov r0, #2
	bl usb2032_hub_search_device
	mov r3, r0
	pop {r0-r1}
.endif

	str r3, os_fiq_usbticket

macro32_debug r3 500 186

	mov r0, #2
	mov r1, #1
	mov r2, #0
	ldr r3, os_fiq_usbticket        @ Ticket

	bl hid32_hid_activate

macro32_debug r0 500 198

	pop {r0-r8,lr}

	mov pc, lr

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

	ldrb r1, gpio_toggle
	eor r1, #0b00000001                       @ Exclusive OR to toggle
	strb r1, gpio_toggle

	cmp r1, #0
	addeq r0, r0, #equ32_gpio_gpclr1
	addne r0, r0, #equ32_gpio_gpset1
	mov r1, #equ32_gpio47
	str r1, [r0]
.endif

	/* Get HID IN */

	/* Buffer */
	push {lr}
	mov r0, #10                      @ 4 Bytes by 2 Words Equals 8 Bytes (Plus 8 Words for Alighment)
	bl usb2032_get_buffer_in
	mov r3, r0
	pop {lr}

	mov r0, #2                      @ Channel
	mov r1, #1                      @ Endpoint
	ldr r2, os_fiq_usbticket        @ Ticket

	push {r0-r3,lr}
	bl hid32_hid_get
	mov r4, r0
	pop {r0-r3,lr}

macro32_debug r2, 320, 0
macro32_debug r4, 320, 12
macro32_debug r3, 320, 24
macro32_debug_hexa r3, 320, 36, 8

	push {lr}
	mov r0, r3
	bl usb2032_clear_buffer_in
	pop {lr}

	macro32_dsb ip
	pop {r0-r7}
	mov pc, lr

/**
 * Variables
 */
.balign 4
gpio_toggle:       .byte 0b00000000
.balign 4
_string_hello:
	.ascii "\nALOHA! WE ARE OHANA!\n\0" @ Add Null Escape Character on The End
.balign 4
string_hello:
	.word _string_hello
_string_test:
	.ascii "System Timer Interval\n\t100K? 100K by 10 Equals 1M!\n\tSystem Timer is 1M Hz!\0"
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
os_fiq_usbticket:
	.word 0x00000000

.include "addr32.s" @ If you want binary, use `.incbin`
.balign 4
/* End of Line is Needed */
