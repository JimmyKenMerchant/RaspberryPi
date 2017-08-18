/**
 * system32.h
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

#ifndef AARCH_32

#define AARCH_32

#endif


/********************************
 * Unique Difinition
 ********************************/

#define uchar8 unsigned char
#define uint16 unsigned short int
#define uint32 unsigned long int
#define uint64 unsigned long long int
#define char8 char
#define int16 short int
#define int32 long int
#define int64 long long int
#define float32 float
#define float64 double

void user_start();


/********************************
 * system32/system32.s
 ********************************/

/* BCM2836 and BCM2837 Peripheral Base */
/* If BCM 2835, Peripheral Base is 0x20000000 */
#define equ32_bcm2835_peripherals_base  0x20000000
#define equ32_bcm2836_peripherals_base  0x3F000000
#define equ32_bcm2837_peripherals_base  0x3F000000
#define equ32_bcm2836_cores_base  0x40000000
#define equ32_bcm2837_cores_base  0x40000000

#define equ32_cores_mailbox_offset      0x10 // Core0 * 0, Core1 * 1, Core2 * 2, Core3 * 3
#define equ32_cores_mailbox0_writeset   0x80
#define equ32_cores_mailbox1_writeset   0x84
#define equ32_cores_mailbox2_writeset   0x88
#define equ32_cores_mailbox3_writeset   0x8C // Use for Inter-core Communication in RasPi's start.elf
#define equ32_cores_mailbox0_readclear  0xC0 // Write Hight to Clear
#define equ32_cores_mailbox1_readclear  0xC4
#define equ32_cores_mailbox2_readclear  0xC8
#define equ32_cores_mailbox3_readclear  0xCC

#define equ32_systemtimer_control_status          0x00
#define equ32_systemtimer_counter_lower_32_bits   0x04
#define equ32_systemtimer_counter_higher_32_bits  0x08
#define equ32_systemtimer_compare_0               0x0C
#define equ32_systemtimer_compare_1               0x10
#define equ32_systemtimer_compare_2               0x14
#define equ32_systemtimer_compare_3               0x18

#define equ32_interrupt_irq_basic_pending   0x00
#define equ32_interrupt_irq_pending_1       0x04
#define equ32_interrupt_irq_pending_2       0x08
#define equ32_interrupt_fiq_control         0x0C
#define equ32_interrupt_enable_irqs_1       0x10
#define equ32_interrupt_enable_irqs_2       0x14
#define equ32_interrupt_enable_basic_irqs   0x18
#define equ32_interrupt_disable_irqs_1      0x1C
#define equ32_interrupt_disable_irqs_2      0x20
#define equ32_interrupt_disable_basic_irqs  0x24

#define equ32_mailbox_channel0  0x00
#define equ32_mailbox_channel1  0x01
#define equ32_mailbox_channel2  0x02
#define equ32_mailbox_channel3  0x03
#define equ32_mailbox_channel4  0x04
#define equ32_mailbox_channel5  0x05
#define equ32_mailbox_channel6  0x06
#define equ32_mailbox_channel7  0x07
#define equ32_mailbox_channel8  0x08
#define equ32_mailbox_read      0x00
#define equ32_mailbox_poll      0x10
#define equ32_mailbox_sender    0x14
#define equ32_mailbox_status    0x18 // MSB has 0 for sender. Next Bit from MSB has 0 for receiver
#define equ32_mailbox_config    0x1C
#define equ32_mailbox_write     0x20
#define equ32_mailbox_offset    0x20 // 0-3 each maibox has 0x20 offset

#define equ32_mailbox_gpuconfirm  0x04
#define equ32_mailbox_gpuoffset   0x40000000
#define equ32_fb_armmask          0x3FFFFFFF

#define equ32_armtimer_load        0x00
#define equ32_armtimer_control     0x08
#define equ32_armtimer_clear       0x0C
#define equ32_armtimer_predivider  0x1C

#define equ32_gpio_gpfsel_0    0x00 // GPIO 0-9   Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
#define equ32_gpio_gpfsel_1    0x04 // GPIO 10-19 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
#define equ32_gpio_gpfsel_2    0x08 // GPIO 20-29 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
#define equ32_gpio_gpfsel_3    0x0C // GPIO 30-39 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
#define equ32_gpio_gpfsel_4    0x10 // GPIO 40-49 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions
#define equ32_gpio_gpfsel_5    0x14 // GPIO 50-53 Function Select, each 3 bits, 000 an input, 001 an output, Alt Functions

#define equ32_gpio_gpset_0     0x1C // GPIO 0-31, Output Set, each 1 bit, 0 no effect, 1 set Pin
#define equ32_gpio_gpset_1     0x20 // GPIO 32-53, Output Set, each 1 bit, 0 no effect, 1 set Pin

#define equ32_gpio_gpclr_0     0x28 // GPIO 0-31, Output Clear, 0 no effect, 1 clear Pin
#define equ32_gpio_gpclr_1     0x2C // GPIO 32-53, Output Clear, 0 no effect, 1 clear Pin

#define equ32_gpio_gplev_0     0x34 // GPIO 0-31, Actual Pin Level, 0 law, 1 high
#define equ32_gpio_gplev_1     0x38 // GPIO 32-53, Actual Pin Level, 0 law, 1 high

#define equ32_gpio_gpeds_0     0x40 // GPIO 0-31, Event Detect Status, 0 not detect, 1 detect, write 1 to clear
#define equ32_gpio_gpeds_1     0x44 // GPIO 32-53, Event Detect Status, 0 not detect, 1 detect, write 1 to clear

#define equ32_gpio_gpren_0     0x4C // GPIO 0-31, Rising Edge Detect, 0 disable, 1 detection corresponds to gpeds_n
#define equ32_gpio_gpren_1     0x50 // GPIO 32-53, Rising Edge Detect, 0 disable, 1 detection corresponds to gpeds_n

#define equ32_gpio_gpfen_0     0x58 // GPIO 0-31, Falling Edge Detect, 0 disable, 1 detection corresponds to gpeds_n
#define equ32_gpio_gpfen_1     0x5C // GPIO 32-53, Falling Edge Detect, 0 disable, 1 detection corresponds to gpeds_n

#define equ32_gpio_gphen_0     0x64 // GPIO 0-31, High Detect, 0 disable, 1 detection corresponds to gpeds_n
#define equ32_gpio_gphen_1     0x68 // GPIO 32-53, High Detect, 0 disable, 1 detection corresponds to gpeds_n

#define equ32_gpio_gplen_0     0x70 // GPIO 0-31, Low Detect, 0 disable, 1 detection corresponds to gpeds_n
#define equ32_gpio_gplen_1     0x74 // GPIO 32-53, Low Detect, 0 disable, 1 detection corresponds to gpeds_n

#define equ32_gpio_gparen_0    0x7C // GPIO 0-31, Async Rising Edge Detect, 0 disable, 1 detection corresponds to gpeds_n
#define equ32_gpio_gparen_1    0x80 // GPIO 32-53, Async Rising Edge Detect, 0 disable, 1 detection corresponds to gpeds_n

#define equ32_gpio_gpafen_0    0x88 // GPIO 0-31, Async Falling Edge Detect, 0 disable, 1 detection corresponds to gpeds_n
#define equ32_gpio_gpafen_1    0x8C // GPIO 32-53, Async Falling Edge Detect, 0 disable, 1 detection corresponds to gpeds_n

#define equ32_gpio_gppud       0x94 // Pull-up/down, 0-1 Bit, 00 off, 01 pull-down, 10, pull-up

#define equ32_gpio_gppudclk_0  0x98 // GPIO 0-31, Conjection with gppud
#define equ32_gpio_gppudclk_1  0x9C // GPIO 32-53, Conjection with gppud

#define equ32_gpio00_bit  0b1       // Bit High
#define equ32_gpio01_bit  0b1 << 1  // Bit High
#define equ32_gpio02_bit  0b1 << 2  // Bit High
#define equ32_gpio03_bit  0b1 << 3  // Bit High
#define equ32_gpio04_bit  0b1 << 4  // Bit High
#define equ32_gpio05_bit  0b1 << 5  // Bit High
#define equ32_gpio06_bit  0b1 << 6  // Bit High
#define equ32_gpio07_bit  0b1 << 7  // Bit High
#define equ32_gpio08_bit  0b1 << 8  // Bit High
#define equ32_gpio09_bit  0b1 << 9  // Bit High
#define equ32_gpio10_bit  0b1 << 10 // Bit High
#define equ32_gpio11_bit  0b1 << 11 // Bit High
#define equ32_gpio12_bit  0b1 << 12 // Bit High
#define equ32_gpio13_bit  0b1 << 13 // Bit High
#define equ32_gpio14_bit  0b1 << 14 // Bit High
#define equ32_gpio15_bit  0b1 << 15 // Bit High
#define equ32_gpio16_bit  0b1 << 16 // Bit High
#define equ32_gpio17_bit  0b1 << 17 // Bit High
#define equ32_gpio18_bit  0b1 << 18 // Bit High
#define equ32_gpio19_bit  0b1 << 19 // Bit High
#define equ32_gpio20_bit  0b1 << 20 // Bit High
#define equ32_gpio21_bit  0b1 << 21 // Bit High
#define equ32_gpio22_bit  0b1 << 22 // Bit High
#define equ32_gpio23_bit  0b1 << 23 // Bit High
#define equ32_gpio24_bit  0b1 << 24 // Bit High
#define equ32_gpio25_bit  0b1 << 25 // Bit High
#define equ32_gpio26_bit  0b1 << 26 // Bit High
#define equ32_gpio27_bit  0b1 << 27 // Bit High
#define equ32_gpio28_bit  0b1 << 28 // Bit High
#define equ32_gpio29_bit  0b1 << 29 // Bit High
#define equ32_gpio30_bit  0b1 << 30 // Bit High
#define equ32_gpio31_bit  0b1 << 31 // Bit High

#define equ32_gpio32_bit  0b1       // Bit High
#define equ32_gpio33_bit  0b1 << 1  // Bit High
#define equ32_gpio34_bit  0b1 << 2  // Bit High
#define equ32_gpio35_bit  0b1 << 3  // Bit High
#define equ32_gpio36_bit  0b1 << 4  // Bit High
#define equ32_gpio37_bit  0b1 << 5  // Bit High
#define equ32_gpio38_bit  0b1 << 6  // Bit High
#define equ32_gpio39_bit  0b1 << 7  // Bit High
#define equ32_gpio40_bit  0b1 << 8  // Bit High
#define equ32_gpio41_bit  0b1 << 9  // Bit High
#define equ32_gpio42_bit  0b1 << 10 // Bit High
#define equ32_gpio43_bit  0b1 << 11 // Bit High
#define equ32_gpio44_bit  0b1 << 12 // Bit High
#define equ32_gpio45_bit  0b1 << 13 // Bit High
#define equ32_gpio46_bit  0b1 << 14 // Bit High
#define equ32_gpio47_bit  0b1 << 15 // Bit High
#define equ32_gpio48_bit  0b1 << 16 // Bit High
#define equ32_gpio49_bit  0b1 << 17 // Bit High
#define equ32_gpio50_bit  0b1 << 18 // Bit High
#define equ32_gpio51_bit  0b1 << 19 // Bit High
#define equ32_gpio52_bit  0b1 << 20 // Bit High
#define equ32_gpio53_bit  0b1 << 21 // Bit High

#define equ32_user_mode  0x10 // 0b00010000 User mode (not priviledged)
#define equ32_fiq_mode   0x11 // 0b00010001 Fast Interrupt Request (FIQ) mode
#define equ32_irq_mode   0x12 // 0b00010010 Interrupt Request (IRQ) mode
#define equ32_svc_mode   0x13 // 0b00010011 Supervisor mode
#define equ32_mon_mode   0x16 // 0b00010110 Secure Monitor mode
#define equ32_abt_mode   0x17 // 0b00010111 Abort mode for prefetch and data abort exception
#define equ32_hyp_mode   0x1A // 0b00011010 Hypervisor mode
#define equ32_und_mode   0x1B // 0b00011011 Undefined mode for undefined instruction exception
#define equ32_sys_mode   0x1F // 0b00011111 System mode

#define equ32_thumb_bit      0x20  // 0b00100000
#define equ32_fiq_disable    0x40  // 0b01000000
#define equ32_irq_disable    0x80  // 0b10000000
#define equ32_abort_disable  0x100 // 0b100000000


extern uint32* SYSTEM32_HEAP;
extern uint32* SYSTEM32_RENDER_BUFFER;

/**
 * Convert Endianness
 *
 * Return: 0 as sucess, 1 as error
 * Error: Align Bytes is not 2/4
 */
extern uint32 system32_convert_endianness
(
	uint32* data,
	uint32 size,
	uint32 align_bytes
);

extern void system32_no_op();

extern void system32_sleep( uint32 u_seconds );

extern void system32_store_32( uint32* address, int32 data);

extern void system32_store_16( uint32* address, int16 data);

extern void system32_store_8( uint32* address, char8 data);

extern int32 system32_load_32( uint32* address );

extern int16 system32_load_16( uint32* address );

extern char8 system32_load_8( uint32* address );



/********************************
 * system32/fb32.s
 ********************************/

extern uint32 FB32_ADDRESS;
extern uint32 FB32_DISPLAY_WIDTH;
extern uint32 FB32_DISPLAY_HEIGHT;
extern uint32 FB32_SIZE;
extern uint32 FB32_DEPTH;
extern uint32 FB32_PIXELORDER;
extern uint32 FB32_ALPHAMODE;
extern uint32 FB32_WIDTH;
extern uint32 FB32_HEIGHT;
extern int32 FB32_X_CARET;
extern int32 FB32_Y_CARET;


/**
 * Convert 32-bit Depth Color RBGA to ARGB
 *
 * Return: 0 as sucess
 */
extern uint32 fb32_rgba_to_argb
(
	uint32* data,
	uint32 size
);


/**
 * Draw Line
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Lower 32 bits (0 as sucess, 1 and more as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Y Length Which Were Not Drawn
 */

extern uint64 fb32_draw_line
(
	uint32 color,
	int32 x_coord_1,
	int32 y_coord_1,
	int32 x_coord_2,
	int32 y_coord_2,
	uint32 width,
	uint32 height
);


/**
 * Copy Framebuffer to Renderbuffer
 *
 * Return: 0 as sucess, 1 as error
 * Error(1): When Framebuffer is not Defined
 */
extern uint32 fb32_copy
(
	uint32* render_buffer_point
);


/**
 * Draw Image
 *
 * Return: Lower 32 bits (0 as sucess, 1 and 2 as error), Upper 32 bits (Last Pointer of Framebuffer)
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 */
extern uint64 fb32_draw_image
(
	uint32* image_point,
	int32 x_coord,
	int32 y_coord,
	uint32 width,
	uint32 height,
	uint32 x_offset,
	uint32 y_offset,
	uint32 x_crop,
	uint32 y_crop
);


/**
 * Clear Block by Color
 *
 * Return: Lower 32 bits (0 as sucess, 1 and 2 as error), Upper 32 bits (Last Pointer of Framebuffer)
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 */
extern uint64 fb32_clear_color_block
(
	uint32 color,
	int32 x_coord,
	int32 y_coord,
	uint32 width,
	uint32 height
);


/**
 * Fill Out Framebuffer by Color
 *
 * Return: 0 as sucess, 1 as error
 * Error(1): When Framebuffer is not Defined
 */
extern uint64 fb32_clear_color
(
	uint32 color
);


/********************************
 * system32/print32.s
 ********************************/

/**
 * Set Caret Position from Return Vlue of `print_*` functions
 *
 * Return: Number of Characters Which Were Not Drawn
 */
extern uint32 print32_set_caret
(
	uint64 return_print
);


/**
 * Count 1-Byte Words of String
 *
 * Return: Number of Words Maximum of 4,294,967,295 words
 */
extern uint32 print32_strlen
(
	uchar8* string
);


/**
 * rint String with 1 Byte Character
 *
 * Return: Lower 32 bits (0 as sucess, 1 and more as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
extern uint64 print32_string
(
	uchar8* string,
	int32 x_coord,
	int32 y_coord,
	uint32 color,
	uint32 back_color,
	uint32 length,
	uint32 width,
	uint32 height,
	uint32* font_base
);


/**
 * Print Hexadecimal Bases Numbers in 64-bit (16 Digits)
 *
 * Return: Lower 32 bits (0 as sucess, 1 and more as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
extern uint64 print32_number_double
(
	uint64 number,
	int32 x_coord,
	int32 y_coord,
	uint32 color,
	uint32 back_color,
	uint32 length,
	uint32 width,
	uint32 height,
	uint32* font_base
);


/**
 * Print Hexadecimal Bases Numbers in 32-bit (8 Digits)
 *
 * Return: Lower 32 bits (0 as sucess, 1 and more as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
extern uint64 print32_number
(
	uint32 number,
	int32 x_coord,
	int32 y_coord,
	uint32 color,
	uint32 back_color,
	uint32 length,
	uint32 width,
	uint32 height,
	uint32* font_base
);


/********************************
 * system32/font_mono_12px.s
 ********************************/

extern uint32* FONT_MONO_12PX_NUMBER;
extern uint32* FONT_MONO_12PX_ASCII;


/**
 * system32/color.s
 */

extern uint16 COLOR16_RED;
extern uint16 COLOR16_GREEN;
extern uint16 COLOR16_BLUE;
extern uint16 COLOR16_YELLOW;
extern uint16 COLOR16_MAGENTA;
extern uint16 COLOR16_CYAN;
extern uint16 COLOR16_PINK;
extern uint16 COLOR16_LIME;
extern uint16 COLOR16_SKYBLUE;
extern uint16 COLOR16_LIGHTYELLOW;
extern uint16 COLOR16_SCARLET;
extern uint16 COLOR16_DARKGREEN;
extern uint16 COLOR16_NAVYBLUE;
extern uint16 COLOR16_WHITE;
extern uint16 COLOR16_LIGHTGRAY;
extern uint16 COLOR16_GRAY;
extern uint16 COLOR16_BLACK;
extern uint32* COLOR16_SAMPLE_IMAGE;

extern uint32 COLOR32_RED;
extern uint32 COLOR32_GREEN;
extern uint32 COLOR32_BLUE;
extern uint32 COLOR32_YELLOW;
extern uint32 COLOR32_MAGENTA;
extern uint32 COLOR32_CYAN;
extern uint32 COLOR32_PINK;
extern uint32 COLOR32_LIME;
extern uint32 COLOR32_SKYBLUE;
extern uint32 COLOR32_LIGHTYELLOW;
extern uint32 COLOR32_SCARLET;
extern uint32 COLOR32_DARKGREEN;
extern uint32 COLOR32_NAVYBLUE;
extern uint32 COLOR32_WHITE;
extern uint32 COLOR32_LIGHTGRAY;
extern uint32 COLOR32_GRAY;
extern uint32 COLOR32_BLACK;


/********************************
 * system32/data.s
 ********************************/

extern uint32* DATA_COLOR32_SAMPLE_IMAGE0;
extern uint32 DATA_COLOR32_SAMPLE_IMAGE0_SIZE;
