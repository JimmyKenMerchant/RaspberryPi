/**
 * vector32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/* Define Debug Status */
/*.equ __DEBUG, 1*/

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

	/**
	 * In this project, using UART IRQ #57 will have missing characters because of no handshake ("copy that") between devices.
	 */

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
	 * Get a 20hz Timer Interrupt (120000/6000).
	 */
	mov r0, #equ32_armtimer_ctl_enable|equ32_armtimer_ctl_interrupt_enable|equ32_armtimer_ctl_prescale_16|equ32_armtimer_ctl_23bit_counter @ Prescaler 1/16 to 120K
	mov r1, #0x1700                           @ High 1 Byte of decimal 5999 (6000 - 1), 16 bits counter on default
	add r1, r1, #0x6F                         @ Low 1 Byte of decimal 5999, 16 bits counter on default
	mov r2, #0x7C                             @ Decimal 124 to divide 240Mz by 125 to 1.92Mhz (Predivider is 10 Bits Wide)
	bl arm32_armtimer

	/**
	 * GPIO
	 */

	/* GPIO0-45 Reset and Pull Down */
	/**
	 * No use because of keeping default GPIO status, gpio32_gpioreset accesses GPIO peripheral a lot of times.
	 * These behaviors in gpio32_gpioreset may affect GPIO status such as output of GPCLK1.
	 */
	/*bl gpio32_gpioreset*/

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base

	/* I/O Settings */

	ldr r1, [r0, #equ32_gpio_gpfsel00]
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_4     @ Set GPIO 4 ALT 0 as GPCLK0
	str r1, [r0, #equ32_gpio_gpfsel00]

	ldr r1, [r0, #equ32_gpio_gpfsel10]
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_4     @ Set GPIO 14 ALT 0 as TXD0
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_5     @ Set GPIO 15 ALT 0 as RXD0
	str r1, [r0, #equ32_gpio_gpfsel10]

	/* Set Status Detect */
	ldr r1, [r0, #equ32_gpio_gpren0]
	orr r1, r1, #equ32_gpio04                                      @ Set GPIO4 Rising Edge Detect
	str r1, [r0, #equ32_gpio_gpren0]

	macro32_dsb ip

.ifdef __B
	ldr r1, [r0, #equ32_gpio_gpfsel40]
.ifdef __RASPI3B
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_2     @ Set GPIO 42 AlT0 (GPCLK1)
.else
	orr r1, r1, #equ32_gpio_gpfsel_alt0 << equ32_gpio_gpfsel_4     @ Set GPIO 44 AlT0 (GPCLK1)
.endif
	str r1, [r0, #equ32_gpio_gpfsel40]

	macro32_dsb ip

	/**
	 * Set GPCLK1 to 25.00Mhz
	 */
	mov r0, #equ32_cm_gp1
	mov r1, #equ32_cm_ctl_mash_0
	add r1, r1, #equ32_cm_ctl_enab|equ32_cm_ctl_src_plld       @ 500Mhz
	mov r2, #20<<equ32_cm_div_integer
	bl arm32_clockmanager
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

	push {r0-r3}
	bl bcm32_get_framebuffer
	pop {r0-r3}

	/* UART 115200 Baud */
	push {r0-r3}
	mov r0, #9                                                @ Integer Divisor Bit[15:0], 18000000 / 16 * 115200 is 9.765625
	mov r1, #0b110001                                         @ Fractional Divisor Bit[5:0], Fixed Point Float 0.765625
	mov r2, #0b11<<equ32_uart0_lcrh_wlen|equ32_uart0_lcrh_fen @ Line Control
	mov r3, #equ32_uart0_cr_rxe|equ32_uart0_cr_txe            @ Coontrol
	bl uart32_uartinit
	pop {r0-r3}

	/**
	 * Clock Manager for GPCLK0. Make 12500Hz (80.00 Micro Seconds)
	 */
	mov r0, #equ32_cm_gp0
	mov r1, #equ32_cm_ctl_mash_1
	add r1, r1, #equ32_cm_ctl_enab|equ32_cm_ctl_src_osc            @ 19.2Mhz
	mov r2, #0x600<<equ32_cm_div_integer                           @ Decimal 1536
	bl arm32_clockmanager

	push {r0-r3}
	mov r0, #128                                             @ 128 Words
	bl uart32_uartmalloc_client
	pop {r0-r3}

	push {r0-r3}
	bl bcm32_poweron_usb
	pop {r0-r3}

	/*
	push {r0-r3}
	mov r0, #0x3
	mov r1, #0b01
	bl bcm32_set_powerstate
	pop {r0-r3}
	*/

	pop {pc}

os_debug:
	push {r0-r8,lr}
/*
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

macro32_debug r0 500 200

	cmp r0, #-2                                   @ Whether No Hub
	moveq r0, #0
	streq r0, os_fiq_usbticket
	beq os_debug_jump

	push {r0-r1}
	mov r1, r0
	mov r0, #2
	bl usb2032_hub_search_device
	mov r3, r0
	pop {r0-r1}
*/

/**
 * Type B has an ethernet interface on the port #0.
 * So if you serach another device, you need to search these again.
 */
/*
.ifdef __B
	push {r0-r1}
	mov r1, r0
	mov r0, #2
	bl usb2032_hub_search_device
	mov r3, r0
	pop {r0-r1}
.endif

	str r3, os_fiq_usbticket

macro32_debug r3 500 212

	os_debug_jump:

		mov r0, #2
		mov r1, #1
		mov r2, #0
		ldr r3, os_fiq_usbticket        @ Ticket

		bl hid32_hid_activate
		cmp r0, #1                      @ Wheter Direct Connection, If So Function Returns Just 1
		streq r0, os_fiq_usbticket

macro32_debug r0 500 224
*/

	pop {r0-r8,pc}

os_irq:
	push {r0-r12,lr}

.ifdef __ARMV6
	macro32_invalidate_instruction_all ip
	macro32_dsb ip
.endif

	mov r0, #equ32_peripherals_base
	add r0, r0, #equ32_gpio_base
	ldr r1, [r0, #equ32_gpio_gpeds0]                               @ Clear GPIO Event Detect
	str r1, [r0, #equ32_gpio_gpeds0]                               @ Clear GPIO Event Detect

	bl uart32_uartint_client

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
	/* ACT Blinker, GPIO 47 Is Preset as OUT */
	mov r0, #47
	mov r1, #2
	bl gpio32_gpiotoggle
	macro32_dsb ip
.endif

	/* Get HID IN */
	/*
	mov r0, #2                      @ Channel
	mov r1, #1                      @ Endpoint
	ldr r2, os_fiq_usbticket        @ Ticket

	push {r1-r3}
	bl hid32_keyboard_get
	pop {r1-r3}

macro32_debug r0, 500, 254
	*/

	mov r0, #1
	str r0, OS_FIQ_TIMER

	pop {r0-r7,pc}

.globl OS_FIQ_TIMER_ADDR
.globl OS_FIQ_TIMER
OS_FIQ_TIMER_ADDR: .word OS_FIQ_TIMER
OS_FIQ_TIMER:      .word 0x00

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
