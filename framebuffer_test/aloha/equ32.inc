/**
 * equ32.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/* BCM2836 and BCM2837 Peripheral Base */
/* If BCM 2835, Peripheral Base is 0x20000000 */
.equ equ32_bcm2835_peripherals_base,  0x20000000
.equ equ32_bcm2836_peripherals_base,  0x3F000000
.equ equ32_bcm2837_peripherals_base,  0x3F000000
.equ equ32_bcm2836_cores_base,  0x40000000
.equ equ32_bcm2837_cores_base,  0x40000000

.equ equ32_cores_mailbox_offset,      0x10 @ Core0 * 0, Core1 * 1, Core2 * 2, Core3 * 3
.equ equ32_cores_mailbox0_writeset,   0x80
.equ equ32_cores_mailbox1_writeset,   0x84
.equ equ32_cores_mailbox2_writeset,   0x88
.equ equ32_cores_mailbox3_writeset,   0x8C @ Use for Inter-core Communication in RasPi's start.elf
.equ equ32_cores_mailbox0_readclear,  0xC0 @ Write Hight to Clear
.equ equ32_cores_mailbox1_readclear,  0xC4
.equ equ32_cores_mailbox2_readclear,  0xC8
.equ equ32_cores_mailbox3_readclear,  0xCC

.equ equ32_systemtimer_control_status,          0x00
.equ equ32_systemtimer_counter_lower_32_bits,   0x04
.equ equ32_systemtimer_counter_higher_32_bits,  0x08
.equ equ32_systemtimer_compare_0,               0x0C
.equ equ32_systemtimer_compare_1,               0x10
.equ equ32_systemtimer_compare_2,               0x14
.equ equ32_systemtimer_compare_3,               0x18

.equ equ32_interrupt_irq_basic_pending,   0x00
.equ equ32_interrupt_irq_pending_1,       0x04
.equ equ32_interrupt_irq_pending_2,       0x08
.equ equ32_interrupt_fiq_control,         0x0C
.equ equ32_interrupt_enable_irqs_1,       0x10
.equ equ32_interrupt_enable_irqs_2,       0x14
.equ equ32_interrupt_enable_basic_irqs,   0x18
.equ equ32_interrupt_disable_irqs_1,      0x1C
.equ equ32_interrupt_disable_irqs_2,      0x20
.equ equ32_interrupt_disable_basic_irqs,  0x24

.equ equ32_mailbox_channel0,  0x00
.equ equ32_mailbox_channel1,  0x01
.equ equ32_mailbox_channel2,  0x02
.equ equ32_mailbox_channel3,  0x03
.equ equ32_mailbox_channel4,  0x04
.equ equ32_mailbox_channel5,  0x05
.equ equ32_mailbox_channel6,  0x06
.equ equ32_mailbox_channel7,  0x07
.equ equ32_mailbox_channel8,  0x08
.equ equ32_mailbox_read,      0x00
.equ equ32_mailbox_poll,      0x10
.equ equ32_mailbox_sender,    0x14
.equ equ32_mailbox_status,    0x18 @ MSB has 0 for sender. Next Bit from MSB has 0 for receiver
.equ equ32_mailbox_config,    0x1C
.equ equ32_mailbox_write,     0x20
.equ equ32_mailbox_offset,    0x20 @ 0-3 each maibox has 0x20 offset

.equ equ32_mailbox_gpuconfirm,  0x04
.equ equ32_mailbox_gpuoffset,   0x40000000
.equ equ32_fb_armmask,          0x3FFFFFFF

.equ equ32_armtimer_load,        0x00
.equ equ32_armtimer_control,     0x08
.equ equ32_armtimer_clear,       0x0C
.equ equ32_armtimer_predivider,  0x1C

.equ equ32_gpio_gpfsel_0,    0x00 @ GPIO 0-9   Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
.equ equ32_gpio_gpfsel_1,    0x04 @ GPIO 10-19 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
.equ equ32_gpio_gpfsel_2,    0x08 @ GPIO 20-29 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
.equ equ32_gpio_gpfsel_3,    0x0C @ GPIO 30-39 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
.equ equ32_gpio_gpfsel_4,    0x10 @ GPIO 40-49 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
.equ equ32_gpio_gpfsel_5,    0x14 @ GPIO 50-53 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions

.equ equ32_gpio_gpset_0,     0x1C @ GPIO 0-31, Output Set, each 1 bit, 0 no effect, 1 set Pin
.equ equ32_gpio_gpset_1,     0x20 @ GPIO 32-53, Output Set, each 1 bit, 0 no effect, 1 set Pin

.equ equ32_gpio_gpclr_0,     0x28 @ GPIO 0-31, Output Clear, 0 no effect, 1 clear Pin
.equ equ32_gpio_gpclr_1,     0x2C @ GPIO 32-53, Output Clear, 0 no effect, 1 clear Pin

.equ equ32_gpio_gplev_0,     0x34 @ GPIO 0-31, Actual Pin Level, 0 law, 1 high
.equ equ32_gpio_gplev_1,     0x38 @ GPIO 32-53, Actual Pin Level, 0 law, 1 high

.equ equ32_gpio_gpeds_0,     0x40 @ GPIO 0-31, Event Detect Status, 0 not detect, 1 detect, write 1 to clear
.equ equ32_gpio_gpeds_1,     0x44 @ GPIO 32-53, Event Detect Status, 0 not detect, 1 detect, write 1 to clear

.equ equ32_gpio_gpren_0,     0x4C @ GPIO 0-31, Rising Edge Detect, 0 disable, 1 detection corresponds to gpeds_n
.equ equ32_gpio_gpren_1,     0x50 @ GPIO 32-53, Rising Edge Detect, 0 disable, 1 detection corresponds to gpeds_n

.equ equ32_gpio_gpfen_0,     0x58 @ GPIO 0-31, Falling Edge Detect, 0 disable, 1 detection corresponds to gpeds_n
.equ equ32_gpio_gpfen_1,     0x5C @ GPIO 32-53, Falling Edge Detect, 0 disable, 1 detection corresponds to gpeds_n

.equ equ32_gpio_gphen_0,     0x64 @ GPIO 0-31, High Detect, 0 disable, 1 detection corresponds to gpeds_n
.equ equ32_gpio_gphen_1,     0x68 @ GPIO 32-53, High Detect, 0 disable, 1 detection corresponds to gpeds_n

.equ equ32_gpio_gplen_0,     0x70 @ GPIO 0-31, Low Detect, 0 disable, 1 detection corresponds to gpeds_n
.equ equ32_gpio_gplen_1,     0x74 @ GPIO 32-53, Low Detect, 0 disable, 1 detection corresponds to gpeds_n

.equ equ32_gpio_gparen_0,    0x7C @ GPIO 0-31, Async Rising Edge Detect, 0 disable, 1 detection corresponds to gpeds_n
.equ equ32_gpio_gparen_1,    0x80 @ GPIO 32-53, Async Rising Edge Detect, 0 disable, 1 detection corresponds to gpeds_n

.equ equ32_gpio_gpafen_0,    0x88 @ GPIO 0-31, Async Falling Edge Detect, 0 disable, 1 detection corresponds to gpeds_n
.equ equ32_gpio_gpafen_1,    0x8C @ GPIO 32-53, Async Falling Edge Detect, 0 disable, 1 detection corresponds to gpeds_n

.equ equ32_gpio_gppud,       0x94 @ Pull-up/down, 0-1 Bit, 00 off, 01 pull-down, 10, pull-up

.equ equ32_gpio_gppudclk_0,  0x98 @ GPIO 0-31, Conjection with gppud
.equ equ32_gpio_gppudclk_1,  0x9C @ GPIO 32-53, Conjection with gppud

.equ equ32_gpio00_bit,  0b1       @ Bit High
.equ equ32_gpio01_bit,  0b1 << 1  @ Bit High
.equ equ32_gpio02_bit,  0b1 << 2  @ Bit High
.equ equ32_gpio03_bit,  0b1 << 3  @ Bit High
.equ equ32_gpio04_bit,  0b1 << 4  @ Bit High
.equ equ32_gpio05_bit,  0b1 << 5  @ Bit High
.equ equ32_gpio06_bit,  0b1 << 6  @ Bit High
.equ equ32_gpio07_bit,  0b1 << 7  @ Bit High
.equ equ32_gpio08_bit,  0b1 << 8  @ Bit High
.equ equ32_gpio09_bit,  0b1 << 9  @ Bit High
.equ equ32_gpio10_bit,  0b1 << 10 @ Bit High
.equ equ32_gpio11_bit,  0b1 << 11 @ Bit High
.equ equ32_gpio12_bit,  0b1 << 12 @ Bit High
.equ equ32_gpio13_bit,  0b1 << 13 @ Bit High
.equ equ32_gpio14_bit,  0b1 << 14 @ Bit High
.equ equ32_gpio15_bit,  0b1 << 15 @ Bit High
.equ equ32_gpio16_bit,  0b1 << 16 @ Bit High
.equ equ32_gpio17_bit,  0b1 << 17 @ Bit High
.equ equ32_gpio18_bit,  0b1 << 18 @ Bit High
.equ equ32_gpio19_bit,  0b1 << 19 @ Bit High
.equ equ32_gpio20_bit,  0b1 << 20 @ Bit High
.equ equ32_gpio21_bit,  0b1 << 21 @ Bit High
.equ equ32_gpio22_bit,  0b1 << 22 @ Bit High
.equ equ32_gpio23_bit,  0b1 << 23 @ Bit High
.equ equ32_gpio24_bit,  0b1 << 24 @ Bit High
.equ equ32_gpio25_bit,  0b1 << 25 @ Bit High
.equ equ32_gpio26_bit,  0b1 << 26 @ Bit High
.equ equ32_gpio27_bit,  0b1 << 27 @ Bit High
.equ equ32_gpio28_bit,  0b1 << 28 @ Bit High
.equ equ32_gpio29_bit,  0b1 << 29 @ Bit High
.equ equ32_gpio30_bit,  0b1 << 30 @ Bit High
.equ equ32_gpio31_bit,  0b1 << 31 @ Bit High

.equ equ32_gpio32_bit,  0b1       @ Bit High
.equ equ32_gpio33_bit,  0b1 << 1  @ Bit High
.equ equ32_gpio34_bit,  0b1 << 2  @ Bit High
.equ equ32_gpio35_bit,  0b1 << 3  @ Bit High
.equ equ32_gpio36_bit,  0b1 << 4  @ Bit High
.equ equ32_gpio37_bit,  0b1 << 5  @ Bit High
.equ equ32_gpio38_bit,  0b1 << 6  @ Bit High
.equ equ32_gpio39_bit,  0b1 << 7  @ Bit High
.equ equ32_gpio40_bit,  0b1 << 8  @ Bit High
.equ equ32_gpio41_bit,  0b1 << 9  @ Bit High
.equ equ32_gpio42_bit,  0b1 << 10 @ Bit High
.equ equ32_gpio43_bit,  0b1 << 11 @ Bit High
.equ equ32_gpio44_bit,  0b1 << 12 @ Bit High
.equ equ32_gpio45_bit,  0b1 << 13 @ Bit High
.equ equ32_gpio46_bit,  0b1 << 14 @ Bit High
.equ equ32_gpio47_bit,  0b1 << 15 @ Bit High
.equ equ32_gpio48_bit,  0b1 << 16 @ Bit High
.equ equ32_gpio49_bit,  0b1 << 17 @ Bit High
.equ equ32_gpio50_bit,  0b1 << 18 @ Bit High
.equ equ32_gpio51_bit,  0b1 << 19 @ Bit High
.equ equ32_gpio52_bit,  0b1 << 20 @ Bit High
.equ equ32_gpio53_bit,  0b1 << 21 @ Bit High

.equ equ32_user_mode,  0x10 @ 0b00010000 User mode (not priviledged)
.equ equ32_fiq_mode,   0x11 @ 0b00010001 Fast Interrupt Request (FIQ) mode
.equ equ32_irq_mode,   0x12 @ 0b00010010 Interrupt Request (IRQ) mode
.equ equ32_svc_mode,   0x13 @ 0b00010011 Supervisor mode
.equ equ32_mon_mode,   0x16 @ 0b00010110 Secure Monitor mode
.equ equ32_abt_mode,   0x17 @ 0b00010111 Abort mode for prefetch and data abort exception
.equ equ32_hyp_mode,   0x1A @ 0b00011010 Hypervisor mode
.equ equ32_und_mode,   0x1B @ 0b00011011 Undefined mode for undefined instruction exception
.equ equ32_sys_mode,   0x1F @ 0b00011111 System mode

.equ equ32_thumb_bit,      0x20  @ 0b00100000
.equ equ32_fiq_disable,    0x40  @ 0b01000000
.equ equ32_irq_disable,    0x80  @ 0b10000000
.equ equ32_abort_disable,  0x100 @ 0b100000000
