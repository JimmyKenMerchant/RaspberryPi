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

	ldr r1, [r0, #equ32_gpio_gpfsel10]
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

	push {r0-r3,lr}
	bl bcm32_get_framebuffer
	pop {r0-r3,lr}

	/* UART 115200 Baud */
	push {r0-r3,lr}
	mov r0, #10                                              @ Integer Divisor, 18432000 / 16 Multiplies by 115200 Equals 10
	mov r1, #0                                               @ Fractional Divisor
	mov r2, #0b11<<equ32_uart0_lcrh_sps|equ32_uart0_lcrh_fen @ Line Control
	mov r3, #equ32_uart0_cr_rxe|equ32_uart0_cr_txe           @ Coontrol
	bl uart32_uartinit
	pop {r0-r3,lr}

	/* Each FIFO is 16 Words Depth (8-bit on Tx, 12-bit on Rx) */
	/* The Setting Below Triggers Interrupt on Reaching 2 Bytes of RxFIFO (0b000) */
	push {r0-r3,lr}
	mov r0, #0b000<<equ32_uart0_ifls_rxiflsel|0b000<<equ32_uart0_ifls_txiflsel @ Trigger Points of Both FIFOs Levels to 1/4
	mov r1, #equ32_uart0_intr_rx @ equ32_uart0_intr_rt When Exceeding Trigger Point of RxFIFO
	bl uart32_uartsetint
	pop {r0-r3,lr}

	push {r0-r3,lr}
	mov r0, #8      @ 8 Words, 32 Bytes
	bl heap32_malloc
	str r0, os_irq_heap
	pop {r0-r3,lr}

	mov pc, lr

os_irq:
	/* Auto (Local) Variables, but just Aliases */
	heap  .req r0
	temp  .req r1

	push {r0-r12,lr}

	ldr temp, _os_irq_busy
	tst temp, #0x1
	bne os_irq_error1        @ If Busy

	bl uart32_uartclrint     @ Clear All Flags of Interrupt

	ldr heap, os_irq_heap

macro32_debug heap, 100, 88

	push {r0}
	ldr r1, _os_irq_count    @ Add Offset
	add r0, r1
	mov r1, #2               @ 2 Bytes
	bl uart32_uartrx

macro32_debug r0, 100, 100

	tst r0, #0x8             @ Whether Overrun or Not

	pop {r0}

	bne os_irq_error2        @ If Overrun

	/* If Succeed to Receive */
	ldr temp, _os_irq_count
	add temp, temp, #2
	cmp temp, #32
	movge temp, #0           @ If Exceeds 32 Bytes
	str temp, _os_irq_count

	push {r0}
	ldr r1, #os_irq_crlf     @ Ascii Codes of Carriage Return and Line Feed
	bl print32_strindex
	mov temp, r0
	pop {r0}

	cmp temp, #-1
	beq os_irq_common

	/* If Newline is Indicated (To Run Command) */

	mov temp, #1
	str temp, _os_irq_busy

	/* Mirror Received Data to Another */
	push {r0}
	mov r1, #32
	bl uart32_uarttx
	pop {r0}

	b os_irq_common

	os_irq_error1:
		/* If Busy (Not Yet Proceeded on Previous Command) */
		push {r0}
		mov r0, #0xFF00
		bl arm32_sleep
		pop {r0}
		b os_irq_common

	os_irq_error2:
		/* If Overrun to Receive */
		bl uart32_uartclrrx
		ldr heap, os_irq_warn_overrun

		push {r0}
		mov r1, #12
		bl uart32_uarttx
		pop {r0}

	os_irq_common:

macro32_debug_hexa heap, 100, 112, 32

		pop {r0-r12,lr}
		mov pc, lr

.unreq heap
.unreq temp

.globl os_irq_heap
.globl os_irq_count
.globl os_irq_busy
.balign 4
os_irq_heap:   .word 0x00
os_irq_count:  .word _os_irq_count
_os_irq_count: .word 0x00
os_irq_busy:   .word _os_irq_busy
_os_irq_busy:  .word 0x00
os_irq_crlf:   .word _os_irq_crlf
_os_irq_crlf:  .ascii "\r\n\0"
.balign 4


.balign 4
_os_irq_warn_overrun:
	.ascii "Er:Overrun\r\n\0"    @ Add Null Escape Character on The End
.balign 4
os_irq_warn_overrun:
	.word _os_irq_warn_overrun

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
