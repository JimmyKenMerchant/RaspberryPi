/**
 * system32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * Aliases: Does Not Affect Memory in Program
 * Left rotated 1 byte (even order) in Immediate Operand of ARM instructions
 */

/* BCM2836 and BCM2837 Peripheral Base */
/* If BCM 2835, Peripheral Base is 0x20000000 */
.equ peripherals_base, 0x3F000000

.equ systemtimer_control_status,         0x00
.equ systemtimer_counter_lower_32_bits,  0x04
.equ systemtimer_counter_higher_32_bits, 0x08
.equ systemtimer_compare_0,              0x0C
.equ systemtimer_compare_1,              0x10
.equ systemtimer_compare_2,              0x14
.equ systemtimer_compare_3,              0x18

.equ interrupt_irq_basic_pending,  0x00
.equ interrupt_irq_pending_1,      0x04
.equ interrupt_irq_pending_2,      0x08
.equ interrupt_fiq_control,        0x0C
.equ interrupt_enable_irqs_1,      0x10
.equ interrupt_enable_irqs_2,      0x14
.equ interrupt_enable_basic_irqs,  0x18
.equ interrupt_disable_irqs_1,     0x1C
.equ interrupt_disable_irqs_2,     0x20
.equ interrupt_disable_basic_irqs, 0x24

.equ mailbox_confirm,          0x04
.equ mailbox_gpuoffset,        0x40000000
.equ mailbox_channel8,         0x08
.equ mailbox0_read,            0x00
.equ mailbox0_poll,            0x10
.equ mailbox0_sender,          0x14
.equ mailbox0_status,          0x18         @ MSB has 0 for sender. Next Bit from MSB has 0 for receiver
.equ mailbox0_config,          0x1C
.equ mailbox0_write,           0x20
.equ fb_armmask,               0x3FFFFFFF

.equ armtimer_load,            0x00
.equ armtimer_control,         0x08
.equ armtimer_clear,           0x0C
.equ armtimer_predivider,      0x1C

.equ gpio_gpfsel_4,            0x10
.equ gpio_gpset_1,             0x20         @ 0b00100000
.equ gpio_gpclr_1,             0x2C         @ 0b00101100
.equ gpio47_bit,               0b1 << 15    @ 0x8000 Bit High for GPIO 47

.equ user_mode,                0x10         @ 0b00010000 User mode (not priviledged)
.equ fiq_mode,                 0x11         @ 0b00010001 Fast Interrupt Request (FIQ) mode
.equ irq_mode,                 0x12         @ 0b00010010 Interrupt Request (IRQ) mode
.equ svc_mode,                 0x13         @ 0b00010011 Supervisor mode
.equ mon_mode,                 0x16         @ 0b00010110 Secure Monitor mode
.equ abt_mode,                 0x17         @ 0b00010111 Abort mode for prefetch and data abort exception
.equ hyp_mode,                 0x1A         @ 0b00011010 Hypervisor mode
.equ und_mode,                 0x1B         @ 0b00011011 Undefined mode for undefined instruction exception
.equ sys_mode,                 0x1F         @ 0b00011111 System mode

.equ thumb_bit,                0x20         @ 0b00100000
.equ fiq_disable,              0x40         @ 0b01000000
.equ irq_disable,              0x80         @ 0b10000000
.equ abort_disable,            0x100        @ 0b100000000


/**
 * Variables
 */
.globl SYSTEM32_SYSTEMTIMER_BASE
.globl SYSTEM32_INTERRUPT_BASE
.globl SYSTEM32_ARMTIMER_BASE
.globl SYSTEM32_MAILBOX_BASE
.globl SYSTEM32_GPIO_BASE
.balign 4
SYSTEM32_SYSTEMTIMER_BASE:   .word 0x00003000
SYSTEM32_INTERRUPT_BASE:     .word 0x0000B200
SYSTEM32_ARMTIMER_BASE:      .word 0x0000B400
SYSTEM32_MAILBOX_BASE:       .word 0x0000B880
SYSTEM32_GPIO_BASE:          .word 0x00200000


/**
 * function system32_convert_endianness
 * Convert Endianness
 *
 * Parameters
 * r0: Pointer of Data to Convert Endianness
 * r1: Size of Data
 * r2: Align Bytes to Be Convert Endianness (2/4) 
 *
 * Usage: r0-r7
 * Return: r0 (0 as sucess, 1 as error)
 * Error: Align Bytes is not 2/4
 */
.globl system32_convert_endianness
system32_convert_endianness:
	/* Auto (Local) Variables, but just aliases */
	data_point      .req r0 @ Parameter, Register for Argument and Result, Scratch Register
	size            .req r1 @ Parameter, Register for Argument and Result, Scratch Register
	align_bytes     .req r2 @ Parameter, Register for Argument and Result, Scratch Register
	swap_1          .req r3
	swap_2          .req r4
	convert_result  .req r5
	i               .req r6
	j               .req r7

	push {r4-r7}

	cmp align_bytes, #4
	cmpne align_bytes, #2
	bne system32_convert_endianness_error

	add size, size, data_point

	system32_convert_endianness_loop:
		cmp data_point, size
		bge system32_convert_endianness_success

		cmp align_bytes, #4
		ldreq swap_1, [data_point]
		cmp align_bytes, #2
		ldreqh swap_1, [data_point]

		mov convert_result, #0

		mov i, #0
		cmp align_bytes, #4
		moveq j, #24
		cmp align_bytes, #2
		moveq j, #8

		system32_convert_endianness_loop_byte:
			cmp j, #0
			blt system32_convert_endianness_loop_byte_common

			lsr swap_2, swap_1, i
			and swap_2, swap_2, #0xFF
			lsl swap_2, swap_2, j
			add convert_result, convert_result, swap_2
			add i, i, #8
			sub j, j, #8

			b system32_convert_endianness_loop_byte

			system32_convert_endianness_loop_byte_common:
				cmp align_bytes, #4
				streq convert_result, [data_point]
				addeq data_point, data_point, #4
				cmp align_bytes, #2
				streqh convert_result, [data_point]
				addeq data_point, data_point, #2

				b system32_convert_endianness_loop

	system32_convert_endianness_error:
		mov r0, #1
		b system32_convert_endianness_common

	system32_convert_endianness_success:
		mov r0, #0

	system32_convert_endianness_common:
		pop {r4-r7}
		mov pc, lr

.unreq data_point
.unreq size
.unreq align_bytes
.unreq swap_1
.unreq swap_2
.unreq convert_result
.unreq i
.unreq j


/**
 * function system32_sleep
 * Sleep in Micro Seconds
 *
 * Parameters
 * r0: Micro Seconds to Sleep
 *
 * Usage: r0-r5
 */
.globl system32_sleep
system32_sleep:
	push {r4-r5}
	mov r1, #peripherals_base
	ldr r2, SYSTEM32_SYSTEMTIMER_BASE
	add r1, r1, r2
	ldr r2, [r1, #systemtimer_counter_lower_32_bits]
	ldr r3, [r1, #systemtimer_counter_higher_32_bits]
	adds r2, r0                            @ Add with Changing Status Flags
	adc r3, #0                             @ Add with Carry Flag

	system32_sleep_loop:
		ldr r4, [r1, #systemtimer_counter_lower_32_bits]
		ldr r5, [r1, #systemtimer_counter_higher_32_bits]
		cmp r3, r5                     @ Similar to `SUBS`, Compare Higher 32 Bits
		cmpeq r2, r4                   @ Compare Lower 32 Bits if the Same on Higher 32 Bits
		bgt system32_sleep_loop

	pop {r4-r5}
	mov pc, lr


/**
 * Includes Enviromental Variables
 * Make sure to reach Address of Variables by `str/ldr Rd, [PC, #Immediate]`,
 * othewise, Compiler can't recognaize Labels of Variables or these Literal Pool.
 * This Immediate Can't be Over #4095 (0xFFF), i.e. within 4K Bytes.
 * BUT if you assign ".globl" to the label, then these are mapped when linker (check inter.map).
 * These are useful if you use `extern` in C lang file.
 */
.balign 4
.include "system32/fb32.s"
.balign 4
.include "system32/mail32.s"
.balign 4
.include "system32/color.s"
.balign 4
.include "system32/font_mono_12px.s"
.balign 4
.include "system32/print32.s"
.balign 4
.include "system32/math32.s"
.balign 4
.include "system32/data.s"
.balign 4

/**
 * function system32_no_op
 * Do Nothing
 */
.globl system32_no_op
system32_no_op:
	mov r0, r0
	mov pc, lr


/**
 * function system32_store_32
 * Store 32-Bit Data to Main Memory
 *
 * Parameters
 * r0: Pointer of Memory Address
 * r1: Data to Store
 *
 * Usage: r0-r1
 * Return: r0 (0 as sucess, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
 */
.globl system32_store_32
system32_store_32:
	str r1, [r0]
	mov pc, lr


/**
 * function system32_store_16
 * Store 16-Bit Data to Main Memory
 *
 * Parameters
 * r0: Pointer of Memory Address
 * r1: Data to Store
 *
 * Usage: r0-r1
 * Return: r0 (0 as sucess, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
 */
.globl system32_store_16
system32_store_16:
	strh r1, [r0]
	mov pc, lr


/**
 * function system32_store_8
 * Store 8-Bit Data to Main Memory
 *
 * Parameters
 * r0: Pointer of Memory Address
 * r1: Data to Store
 *
 * Usage: r0-r1
 * Return: r0 (0 as sucess, 1 and 2 as error), r1 (Last Pointer of Framebuffer)
 */
.globl system32_store_8
system32_store_8:
	strb r1, [r0]
	mov pc, lr


/**
 * function system32_load_32
 * Load 32-Bit Data from Main Memory
 *
 * Parameters
 * r0: Pointer of Memory Address
 *
 * Usage: r0-r1
 * Return: r0 (Data from Main Memory)
 */
.globl system32_load_32
system32_load_32:
	ldr r1, [r0]
	mov r0, r1
	mov pc, lr


/**
 * function system32_load_16
 * Load 16-Bit Data from Main Memory
 *
 * Parameters
 * r0: Pointer of Memory Address
 *
 * Usage: r0-r1
 * Return: r0 (Data from Main Memory)
 */
.globl system32_load_16
system32_load_16:
	ldrh r1, [r0]
	mov r0, r1
	mov pc, lr


/**
 * function system32_load_8
 * Load 8-Bit Data from Main Memory
 *
 * Parameters
 * r0: Pointer of Memory Address
 *
 * Usage: r0-r1
 * Return: r0 (Data from Main Memory)
 */
.globl system32_load_8
system32_load_8:
	ldrb r1, [r0]
	mov r0, r1
	mov pc, lr

.globl SYSTEM32_HEAP
SYSTEM32_HEAP: .word _SYSTEM32_HEAP
.globl SYSTEM32_RENDER_BUFFER
SYSTEM32_RENDER_BUFFER: .word _SYSTEM32_RENDER_BUFFER

_SYSTEM32_HEAP: 
.fill 65536, 1, 0x00
_SYSTEM32_RENDER_BUFFER:
.fill 1, 1, 0x00
