/**
 * addr.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
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
 * include/aloha/system32.h
 */

.globl user_start


/**
 * system32/system32.s
 */

.globl SYSTEM32_SYSTEMTIMER_BASE
.globl SYSTEM32_INTERRUPT_BASE
.globl SYSTEM32_ARMTIMER_BASE
.globl SYSTEM32_MAILBOX_BASE
.globl SYSTEM32_GPIO_BASE
.globl system32_convert_endianness
.globl system32_sleep
.globl system32_no_op
.globl system32_store_32
.globl system32_store_16
.globl system32_store_8
.globl system32_load_32
.globl system32_load_16
.globl system32_load_8
.globl SYSTEM32_HEAP
.globl SYSTEM32_RENDER_BUFFER

ADDR32_SYSTEM32_SYSTEMTIMER_BASE: .word SYSTEM32_SYSTEMTIMER_BASE
ADDR32_SYSTEM32_INTERRUPT_BASE:   .word SYSTEM32_INTERRUPT_BASE
ADDR32_SYSTEM32_ARMTIMER_BASE:    .word SYSTEM32_ARMTIMER_BASE
ADDR32_SYSTEM32_MAILBOX_BASE:     .word SYSTEM32_MAILBOX_BASE
ADDR32_SYSTEM32_GPIO_BASE:        .word SYSTEM32_GPIO_BASE
ADDR32_SYSTEM32_HEAP:             .word SYSTEM32_HEAP
ADDR32_SYSTEM32_RENDER_BUFFER:    .word SYSTEM32_RENDER_BUFFER


/**
 * system32/fb32.s
 */

.globl fb32_rgba_to_argb
.globl fb32_draw_line
.globl fb32_copy
.globl fb32_draw_image
.globl fb32_clear_color_block
.globl fb32_clear_color
.globl fb32_get
.globl FB32_X_CARET
.globl FB32_Y_CARET
.globl FB32_DISPLAY_WIDTH
.globl FB32_DISPLAY_HEIGHT
.globl FB32_WIDTH
.globl FB32_HEIGHT
.globl FB32_DEPTH
.globl FB32_PIXELORDER
.globl FB32_ALPHAMODE
.globl FB32_ADDRESS
.globl FB32_SIZE

ADDR32_FB32_X_CARET:        .word FB32_X_CARET
ADDR32_FB32_Y_CARET:        .word FB32_Y_CARET
ADDR32_FB32_DISPLAY_WIDTH:  .word FB32_DISPLAY_WIDTH
ADDR32_FB32_DISPLAY_HEIGHT: .word FB32_DISPLAY_HEIGHT
ADDR32_FB32_WIDTH:          .word FB32_WIDTH
ADDR32_FB32_HEIGHT:         .word FB32_HEIGHT
ADDR32_FB32_DEPTH:          .word FB32_DEPTH
ADDR32_FB32_PIXELORDER:     .word FB32_PIXELORDER
ADDR32_FB32_ALPHAMODE:      .word FB32_ALPHAMODE
ADDR32_FB32_ADDRESS:        .word FB32_ADDRESS
ADDR32_FB32_SIZE:           .word FB32_SIZE


/**
 * system32/print32.s
 */

.globl print32_set_caret
.globl print32_strlen
.globl print32_string
.globl print32_number_double
.globl print32_number
.globl print32_char


/**
 * system32/font_mono_12px.s
 */

.globl FONT_MONO_12PX_ASCII
.globl FONT_MONO_12PX_NUMBER

ADDR32_FONT_MONO_12PX_ASCII:  .word FONT_MONO_12PX_ASCII
ADDR32_FONT_MONO_12PX_NUMBER: .word FONT_MONO_12PX_NUMBER


/**
 * system32/color.s
 */

.globl COLOR16_RED
.globl COLOR16_GREEN
.globl COLOR16_BLUE
.globl COLOR16_YELLOW
.globl COLOR16_MAGENTA
.globl COLOR16_CYAN
.globl COLOR16_PINK
.globl COLOR16_LIME
.globl COLOR16_SKYBLUE
.globl COLOR16_LIGHTYELLOW
.globl COLOR16_SCARLET
.globl COLOR16_DARKGREEN
.globl COLOR16_NAVYBLUE
.globl COLOR16_WHITE
.globl COLOR16_LIGHTGRAY
.globl COLOR16_GRAY
.globl COLOR16_BLACK
.globl COLOR16_SAMPLE_IMAGE

.globl COLOR32_RED
.globl COLOR32_GREEN
.globl COLOR32_BLUE
.globl COLOR32_YELLOW
.globl COLOR32_MAGENTA
.globl COLOR32_CYAN
.globl COLOR32_PINK
.globl COLOR32_LIME
.globl COLOR32_SKYBLUE
.globl COLOR32_LIGHTYELLOW
.globl COLOR32_SCARLET
.globl COLOR32_DARKGREEN
.globl COLOR32_NAVYBLUE
.globl COLOR32_WHITE
.globl COLOR32_LIGHTGRAY
.globl COLOR32_GRAY
.globl COLOR32_BLACK

ADDR32_COLOR16_RED:          .word COLOR16_RED
ADDR32_COLOR16_GREEN:        .word COLOR16_GREEN
ADDR32_COLOR16_BLUE:         .word COLOR16_BLUE
ADDR32_COLOR16_YELLOW:       .word COLOR16_YELLOW
ADDR32_COLOR16_MAGENTA:      .word COLOR16_MAGENTA
ADDR32_COLOR16_CYAN:         .word COLOR16_CYAN
ADDR32_COLOR16_PINK:         .word COLOR16_PINK
ADDR32_COLOR16_LIME:         .word COLOR16_LIME
ADDR32_COLOR16_SKYBLUE:      .word COLOR16_SKYBLUE
ADDR32_COLOR16_LIGHTYELLOW:  .word COLOR16_LIGHTYELLOW
ADDR32_COLOR16_SCARLET:      .word COLOR16_SCARLET
ADDR32_COLOR16_DARKGREEN:    .word COLOR16_DARKGREEN
ADDR32_COLOR16_NAVYBLUE:     .word COLOR16_NAVYBLUE
ADDR32_COLOR16_WHITE:        .word COLOR16_WHITE
ADDR32_COLOR16_LIGHTGRAY:    .word COLOR16_LIGHTGRAY
ADDR32_COLOR16_GRAY:         .word COLOR16_GRAY
ADDR32_COLOR16_BLACK:        .word COLOR16_BLACK
ADDR32_COLOR16_SAMPLE_IMAGE: .word COLOR16_SAMPLE_IMAGE

ADDR32_COLOR32_RED:          .word COLOR32_RED
ADDR32_COLOR32_GREEN:        .word COLOR32_GREEN
ADDR32_COLOR32_BLUE:         .word COLOR32_BLUE
ADDR32_COLOR32_YELLOW:       .word COLOR32_YELLOW
ADDR32_COLOR32_MAGENTA:      .word COLOR32_MAGENTA
ADDR32_COLOR32_CYAN:         .word COLOR32_CYAN
ADDR32_COLOR32_PINK:         .word COLOR32_PINK
ADDR32_COLOR32_LIME:         .word COLOR32_LIME
ADDR32_COLOR32_SKYBLUE:      .word COLOR32_SKYBLUE
ADDR32_COLOR32_LIGHTYELLOW:  .word COLOR32_LIGHTYELLOW
ADDR32_COLOR32_SCARLET:      .word COLOR32_SCARLET
ADDR32_COLOR32_DARKGREEN:    .word COLOR32_DARKGREEN
ADDR32_COLOR32_NAVYBLUE:     .word COLOR32_NAVYBLUE
ADDR32_COLOR32_WHITE:        .word COLOR32_WHITE
ADDR32_COLOR32_LIGHTGRAY:    .word COLOR32_LIGHTGRAY
ADDR32_COLOR32_GRAY:         .word COLOR32_GRAY
ADDR32_COLOR32_BLACK:        .word COLOR32_BLACK
