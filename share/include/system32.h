/**
 * system32.h
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

#ifndef __AARCH32

#define __AARCH32

#endif


/********************************
 * Unique Definitions on General
 ********************************/

/* Constants */

#define _RAP(...) __VA_ARGS__

#define _1_BIG(x) x
#define _2_BIG(x) x x
#define _3_BIG(x) x x x
#define _4_BIG(x) x x x x
#define _5_BIG(x) x x x x x
#define _6_BIG(x) x x x x x x
#define _7_BIG(x) x x x x x x x
#define _8_BIG(x) x x x x x x x x
#define _9_BIG(x) x x x x x x x x x
#define _10_BIG(x) x x x x x x x x x x
#define _11_BIG(x) _10_BIG(x) _1_BIG(x)
#define _12_BIG(x) _10_BIG(x) _2_BIG(x)
#define _13_BIG(x) _10_BIG(x) _3_BIG(x)
#define _14_BIG(x) _10_BIG(x) _4_BIG(x)
#define _15_BIG(x) _10_BIG(x) _5_BIG(x)
#define _16_BIG(x) _10_BIG(x) _6_BIG(x)
#define _17_BIG(x) _10_BIG(x) _7_BIG(x)
#define _18_BIG(x) _10_BIG(x) _8_BIG(x)
#define _19_BIG(x) _10_BIG(x) _9_BIG(x)
#define _20_BIG(x) _10_BIG(x) _10_BIG(x)

#define _1(x) x,
#define _2(x) x,x,
#define _3(x) x,x,x,
#define _4(x) x,x,x,x,
#define _5(x) x,x,x,x,x,
#define _6(x) x,x,x,x,x,x,
#define _7(x) x,x,x,x,x,x,x,
#define _8(x) x,x,x,x,x,x,x,x,
#define _9(x) x,x,x,x,x,x,x,x,x,
#define _10(x) x,x,x,x,x,x,x,x,x,x,
#define _11(x) _10(x) _1(x)
#define _12(x) _10(x) _2(x)
#define _13(x) _10(x) _3(x)
#define _14(x) _10(x) _4(x)
#define _15(x) _10(x) _5(x)
#define _16(x) _10(x) _6(x)
#define _17(x) _10(x) _7(x)
#define _18(x) _10(x) _8(x)
#define _19(x) _10(x) _9(x)
#define _20(x) _10(x) _10(x)
#define _21(x) _20(x) _1(x)
#define _22(x) _20(x) _2(x)
#define _23(x) _20(x) _3(x)
#define _24(x) _20(x) _4(x)
#define _25(x) _20(x) _5(x)
#define _26(x) _20(x) _6(x)
#define _27(x) _20(x) _7(x)
#define _28(x) _20(x) _8(x)
#define _29(x) _20(x) _9(x)
#define _30(x) _20(x) _10(x)
#define _31(x) _30(x) _1(x)
#define _32(x) _30(x) _2(x)
#define _33(x) _30(x) _3(x)
#define _34(x) _30(x) _4(x)
#define _35(x) _30(x) _5(x)
#define _36(x) _30(x) _6(x)
#define _37(x) _30(x) _7(x)
#define _38(x) _30(x) _8(x)
#define _39(x) _30(x) _9(x)
#define _40(x) _30(x) _10(x)
#define _41(x) _40(x) _1(x)
#define _42(x) _40(x) _2(x)
#define _43(x) _40(x) _3(x)
#define _44(x) _40(x) _4(x)
#define _45(x) _40(x) _5(x)
#define _46(x) _40(x) _6(x)
#define _47(x) _40(x) _7(x)
#define _48(x) _40(x) _8(x)
#define _49(x) _40(x) _9(x)
#define _50(x) _40(x) _10(x)
#define _51(x) _50(x) _1(x)
#define _52(x) _50(x) _2(x)
#define _53(x) _50(x) _3(x)
#define _54(x) _50(x) _4(x)
#define _55(x) _50(x) _5(x)
#define _56(x) _50(x) _6(x)
#define _57(x) _50(x) _7(x)
#define _58(x) _50(x) _8(x)
#define _59(x) _50(x) _9(x)

#define _60(x) _50(x) _10(x)
#define _70(x) _60(x) _10(x)
#define _80(x) _70(x) _10(x)
#define _90(x) _80(x) _10(x)
#define _100(x) _90(x) _10(x)
#define _200(x) _100(x) _100(x)
#define _300(x) _200(x) _100(x)
#define _400(x) _300(x) _100(x)
#define _500(x) _400(x) _100(x)
#define _600(x) _500(x) _100(x)
#define _700(x) _600(x) _100(x)
#define _800(x) _700(x) _100(x)
#define _900(x) _800(x) _100(x)
#define _1000(x) _900(x) _100(x)

#define uchar8 unsigned char
#define uint16 unsigned short int
#define uint32 unsigned long int
#define uint64 unsigned long long int
#define char8 char // Use as Pointer Too, Signed/Unsigned is Typically Unknown
#define int16 short int
#define int32 long int // Use as Pointer Too, Signed/Unsigned is Typically Unknown
#define int64 long long int
#define float32 float
#define float64 double

#ifndef EXIT_SUCCESS
#define EXIT_SUCCESS 0
#endif
#ifndef exit_success
#define exit_success 0
#endif
#ifndef EXIT_FAILURE
#define EXIT_FAILURE 1
#endif
#ifndef exit_failure
#define exit_failure 1
#endif
#ifndef bool
#define bool unsigned char
#endif
#ifndef true
#define true ((bool)1)
#endif
#ifndef false
#define false ((bool)0)
#endif
#ifndef True
#define True ((bool)1)
#endif
#ifndef False
#define False ((bool)0)
#endif
#ifndef TRUE
#define TRUE ((bool)1)
#endif
#ifndef FALSE
#define FALSE ((bool)0)
#endif
#ifndef null 
#define null 0
#endif
#ifndef NULL 
#define NULL 0
#endif
#ifndef Null 
#define Null 0
#endif

#define obj uint32

/* Pointers, Array of Address of Data */
#define String char8*
#define ObjArray obj*

/**
 * System calls
 * On _user_start, CPU runs with User mode. To access restricted memory area to write, usage of System calls is needed to acccess SVC mode.
 * Plus, peripherals can't be directly accessed to write/read through user mode, and only can be accessed through System calls. 
 */
__attribute__((noinline)) uint32 _example_svc_0( int32 a, int32 b, int32 c, int32 d );

/* Regular Functions */

int32 _user_start();


/********************************
 * system32/vendor/bcm32.s
 ********************************/

/* Constants */

extern uint32 BCM32_ARMMEMORY_BASE;
extern uint32 BCM32_ARMMEMORY_SIZE;
extern uint32 BCM32_VCMEMORY_BASE;
extern uint32 BCM32_VCMEMORY_SIZE;

/* Relative System Calls  */

__attribute__((noinline)) uint32 _display_off( bool bool_off );


/********************************
 * system32/arm/arm32.s
 ********************************/

/* Constants */

#define _cm_gp0             0x00000070 // Clock Manager General Purpose 0 (GPO) Base
#define _cm_gp1             0x00000078 // Clock Manager General Purpose 1 (GP1) Base
#define _cm_gp2             0x00000080 // Clock Manager General Purpose 2 (GP2) Base
#define _cm_pcm             0x00000098 // Clock Manager PCM Base
#define _cm_pwm             0x000000A0 // Clock Manager PWM Base

#define _cm_ctl_mash_0      0x00000000 // Integer Division
#define _cm_ctl_mash_1      0x00000200 // 1-stage Mash
#define _cm_ctl_mash_2      0x00000400 // 2-stage Mash
#define _cm_ctl_mash_3      0x00000600 // 3-stage Mash
#define _cm_ctl_flip        0x00000100 // Invert Output
#define _cm_ctl_src_gnd     0x00000000 // GND (0 Hz)
#define _cm_ctl_src_osc     0x00000001 // Oscillator (19.2Mhz)
#define _cm_ctl_src_deb0    0x00000002 // Test Debug 0 (0 Hz)
#define _cm_ctl_src_deb1    0x00000003 // Test Debug 1 (0 Hz)
#define _cm_ctl_src_plla    0x00000004 // PLL A (0Hz?)
#define _cm_ctl_src_pllc    0x00000005 // PLL C (1000Mhz but depends on CPU Clock?)
#define _cm_ctl_src_plld    0x00000006 // PLL D (500Mhz)
#define _cm_ctl_src_hdmi    0x00000007 // HDMI Auxiliary (216Mhz?)

#define _cm_div_integer     12 // LSL Bit[23:12]
#define _cm_div_fraction    0 // Bit[11:0] (Fractional Value is Bit[11:0] Divided by 1024. Valid Bit[9:0])

extern uint32 ARM32_STOPWATCH_LOW;
extern uint32 ARM32_STOPWATCH_HIGH;

/* Relative System Calls  */

__attribute__((noinline)) void _stopwatch_start();

__attribute__((noinline)) uint64 _stopwatch_end();

__attribute__((noinline)) void _sleep( uint32 u_seconds );

__attribute__((noinline)) uchar8 _random( uchar8 range_end );

__attribute__((noinline)) void _store_8( uint32 address, char8 data );

__attribute__((noinline)) char8 _load_8( uint32 address );

__attribute__((noinline)) void _store_16( uint32 address, int16 data );

__attribute__((noinline)) int16 _load_16( uint32 address );

__attribute__((noinline)) void _store_32( uint32 address, int32 data );

__attribute__((noinline)) int32 _load_32( uint32 address );

__attribute__((noinline)) uint64 _timestamp();

__attribute__((noinline)) uint32 _armtimer( uint32 timer_ctl, uint32 load, uint32 predivider );

__attribute__((noinline)) uint32 _armtimer_reload( uint32 reload );

__attribute__((noinline)) uint32 _armtimer_load( uint32 load );

__attribute__((noinline)) uint32 _clockmanager( uint32 clocktype_base, uint32 clk_ctl, uint32 clk_divisors );

/* Regular Functions */

/**
 * Convert Endianness
 *
 * Return: 0 as sucess, 1 as error
 * Error: Align Bytes is not 2/4
 */
extern uint32 arm32_convert_endianness
(
	uint32 address_word,
	uint32 size,
	uint32 align_bytes
);

extern void arm32_no_op();

extern void arm32_dsb();

extern void arm32_msb();

extern void arm32_isb();

/**
 * Count Leading Zero from Most Siginificant Bit in 32 Bit Register
 *
 * Return: Number of Count of Leading Zero
 */
extern uint32 arm32_count_zero32
(
	uint32 countee
);


/**
 * Return Word Bits Are Reflected
 *
 * Return: Word Bits Are Reflected
 */
extern uint32 arm32_reflect_bit
(
	uint32 reflectee,
	uchar8 number_bit // Number of Bits to Be Reflected from LSB, 1 to 32
);


/**
 * Multiplication of Two Integers
 *
 * Return: Answer of Multiplication
 */
extern int32 arm32_mul(
	int32 factor1,
	int32 factor2
);


/**
 * Unsigned Division of Two Integers
 *
 * Return: Answer of Division
 */
extern int32 arm32_udiv(
	int32 dividend,
	int32 divisor
);


/**
 * Return Remainder of Unsigned Division of Two Integers
 *
 * Return: Reminder of Division
 */
extern int32 arm32_urem(
	uint32 dividend,
	uint32 divisor
);


/**
 * Signed Division of Two Integers
 *
 * Return: Answer of Division
 */
extern int32 arm32_sdiv(
	int32 dividend,
	int32 divisor
);


/**
 * Return Remainder of Signed Division of Two Integers
 *
 * Return: Reminder of Division
 */
extern int32 arm32_srem(
	uint32 dividend,
	uint32 divisor
);


/**
 * Arithmetic Comparison by Subtraction and Return NZCV ALU Flags (Bit[31:28])
 *
 * Return: NZCV ALU Flags (Bit[31:28])
 */
extern uint32 arm32_cmp(
	uint32 value1,
	uint32 value2
);


/**
 * Logical Comparison by Logical AND and Return NZCV ALU Flags (Bit[31:28])
 *
 * Return: NZCV ALU Flags (Bit[31:28])
 */
extern uint32 arm32_tst(
	uint32 value1,
	uint32 value2
);


/********************************
 * system32/library/clk32.s
 ********************************/

extern uint32 CLK32_YEAR;
extern uint32 CLK32_YEARDAY;
extern uint32 CLK32_YEAR_INIT;
extern uint32 CLK32_YEARDAY_INIT;
extern int32 CLK32_UTC; // Minus Sign Exists
extern uchar8 CLK32_MONTH;
extern uchar8 CLK32_WEEK;
extern uchar8 CLK32_MONTHDAY;
extern uchar8 CLK32_HOUR;
extern uchar8 CLK32_MINUTE;
extern uchar8 CLK32_SECOND;
extern uchar8 CLK32_HOUR_INIT;
extern uchar8 CLK32_MINUTE_INIT;
extern uchar8 CLK32_SECOND_INIT;
extern uint32 CLK32_USECOND;
extern uint32 CLK32_USECOND_INIT;

__attribute__((noinline)) uint32 _calender_init( uint32 year, uchar8 month, uchar8 day );

__attribute__((noinline)) uint32 _clock_init( uchar8 hour, uchar8 minute, uchar8 second, uint32 usecond );

__attribute__((noinline)) uint32 _correct_utc( int32 distance_utc );

__attribute__((noinline)) uint32 _get_time();

__attribute__((noinline)) uint32 _set_time( uint64 timestamp );

extern uint32 clk32_check_leapyear
(
	uint32 year
);

extern uint32 clk32_check_week
(
	uint32 year,
	uchar8 month,
	uchar8 day_of_month
);


/********************************
 * system32/arm/uart32.s
 ********************************/

extern String UART32_UARTINT_HEAP;
extern uint32 UART32_UARTINT_BUSY_ADDR;
extern uint32 UART32_UARTINT_COUNT_ADDR;
extern uint32 UART32_UARTMALLOC_LENGTH;
extern uint32 UART32_UARTMALLOC_NUMBER;
extern uint32 UART32_UARTMALLOC_MAXROW;

__attribute__((noinline)) uint32 _uartinit
(
	uint32 div_int,
	uint32 div_frac,
	uint32 line_ctl,
	uint32 ctl
);

__attribute__((noinline)) uint32 _uartsettest
(
	bool rdr_on,
	bool tx_on,
	bool rx_on
);

__attribute__((noinline)) uint32 _uarttestwrite
(
	String address_heap,
	uint32 size
);

__attribute__((noinline)) uint32 _uarttestread(

	String address_heap,
	uint32 size
);

__attribute__((noinline)) uint32 _uartsetint
(
	uint32 int_fifo,
	uint32 int_mask
);

__attribute__((noinline)) String _uartint_emulate
(
	uint32 max_size,
	bool flag_mirror,
	uchar8 character_rx
);

__attribute__((noinline)) uint32 _uartclrint();

__attribute__((noinline)) uint32 _uarttx
(
	String address_heap,
	uint32 size
);

__attribute__((noinline)) uint32 _uartrx
(
	String address_heap,
	uint32 size
);

__attribute__((noinline)) uint32 _uartclrrx();

__attribute__((noinline)) uint32 _uartsetheap
(
	uint32 num_heap
);

__attribute__((noinline)) uint32 _uartclient
(
	bool mode_client
);


/********************************
 * system32/arm/usb2032.s
 ********************************/

__attribute__((noinline)) uint32 _otg_host_reset_bcm();

__attribute__((noinline)) int32 _hub_activate
(
	uint32 channel,
	uint32 ticket
);

__attribute__((noinline)) int32 _hub_search_device
(
	uint32 channel,
	uint32 address_hub 
);


/********************************
 * system32/arm/gpio32.s
 ********************************/

/* Constants */

#define gpio_sequence       uint32
#define GPIO32_END          0
#define _GPIOTOGGLE_LOW     0
#define _GPIOTOGGLE_HIGH    1
#define _GPIOTOGGLE_SWAP    2
#define _GPIOMODE_IN        0b000
#define _GPIOMODE_OUT       0b001
#define _GPIOMODE_ALT0      0b100
#define _GPIOMODE_ALT1      0b101
#define _GPIOMODE_ALT2      0b110
#define _GPIOMODE_ALT3      0b111
#define _GPIOMODE_ALT4      0b011
#define _GPIOMODE_ALT5      0b010
#define _GPIOEVENT_RISING   0
#define _GPIOEVENT_FALLING  1
#define _GPIOEVENT_HIGH     2
#define _GPIOEVENT_LOW      3
#define _GPIOEVENT_ARISING  4
#define _GPIOEVENT_AFALLING 5
#define _GPIOPULL_OFF       0
#define _GPIOPULL_DOWN      1
#define _GPIOPULL_UP        2

/* Relative System Calls  */

__attribute__((noinline)) uint32 _gpioplay( uint32 gpio_mask ); // Clear All (false) or Stay GPIO Status (true)

__attribute__((noinline)) uint32 _gpioset( gpio_sequence* gpio, uint32 length, uint32 count, int32 repeat );

__attribute__((noinline)) uint32 _gpioclear( uint32 gpio_mask, bool stay ); // Clear All (false) or Stay GPIO Status (true)

__attribute__((noinline)) uint32 _gpiotoggle( uint32 number_gpio, uchar8 control );

__attribute__((noinline)) uint32 _gpiomode( uint32 number_gpio, uchar8 function_select );

__attribute__((noinline)) uint32 _gpioevent( uint32 number_gpio, uchar8 event_select, bool on );

__attribute__((noinline)) uint32 _gpiopull( uint32 number_gpio, uchar8 control );


/* Regular Functions */

/**
 * Count 4-Bytes Beats of GPIO Sequence
 *
 * Return: Number of Beats in GPIO Sequence, Maximum of 4,294,967,295 Beats
 */
extern uint32 gpio32_gpiolen
(
	gpio_sequence* gpio
);


/********************************
 * Unique Definitions on GPIO
 ********************************/

/* Constants */

/**
 * GPIO Control and Status (Limited Between 0-29)
 */
#ifdef __BCM2835
	#define _gpio_base   0x20200000
#else
	/* BCM2836 and BCM2837 Peripheral Base */
	#define _gpio_base   0x3F200000
#endif

#define _gpio_gpset0      0x1C // GPIO 0-31, Output Set, each 1 bit, 0 no effect, 1 set Pin
#define _gpio_gpset1      0x20 // GPIO 32-63, Output Set, each 1 bit, 0 no effect, 1 set Pin
#define _gpio_gpclr0      0x28 // GPIO 0-31, Output Clear, 0 no effect, 1 clear Pin
#define _gpio_gpclr1      0x2C // GPIO 32-63, Output Clear, 0 no effect, 1 clear Pin
#define _gpio_gplev0      0x34 // GPIO 0-31, Actual Pin Level, 0 law, 1 high
#define _gpio_gplev1      0x38 // GPIO 32-63, Actual Pin Level, 0 law, 1 high
#define _gpio_gpeds0      0x40 // GPIO 0-31, Event Detect Status, 0 not detect, 1 detect, write 1 to clear
#define _gpio_gpeds1      0x44 // GPIO 32-63, Event Detect Status, 0 not detect, 1 detect, write 1 to clear

/* Regular Functions */

bool _gpio_detect( uchar8 gpio_number ); // Edge Detect

bool _gpio_in( uchar8 gpio_number ); // Actual Pin Level Status


/********************************
 * system32/arm/pwm32.s
 ********************************/

/* Constants */

#define pwm_sequence       uint32
#define PWM32_END          0

/* Relative System Calls  */

__attribute__((noinline)) uint32 _pwmplay();

__attribute__((noinline)) uint32 _pwmset( pwm_sequence* pwm, uint32 length, uint32 count, int32 repeat );

__attribute__((noinline)) uint32 _pwmclear( bool stay ); // Clear All (false) or Stay GPIO Status (true)

__attribute__((noinline)) uint32 _pwmselect( uint32 channel );


/* Regular Functions */

/**
 * Count 4-Bytes Beats of PWM Sequence
 *
 * Return: Number of Beats in PWM Sequence, Maximum of 4,294,967,295 Beats
 */
extern uint32 pwm32_pwmlen
(
	pwm_sequence* pwm
);


/********************************
 * system32/library/vfp32.s
 ********************************/

extern uint32 vfp32_f32tohexa( float32 value );

extern float32 vfp32_hexatof32( uint32 value );

extern int32 vfp32_f32tosfix32( float32 value, uint32 fraction_digits );

extern uint32 vfp32_f32toufix32( float32 value, uint32 fraction_digits );

extern float32 vfp32_s32tof32( int32 value );

extern float32 vfp32_u32tof32( uint32 value );

extern int32 vfp32_f32tos32( float32 value );

extern uint32 vfp32_f32tou32( float32 value );

extern float32 vfp32_fsqrt( float32 value );

extern uint32 vfp32_fcmp
(
	float32 value1,
	float32 value2
);

extern bool vfp32_feq
(
	float32 value1,
	float32 value2
);

extern bool vfp32_fgt
(
	float32 value1,
	float32 value2
);

extern bool vfp32_flt
(
	float32 value1,
	float32 value2
);

extern bool vfp32_fge
(
	float32 value1,
	float32 value2
);

extern bool vfp32_fle
(
	float32 value1,
	float32 value2
);

extern float32 vfp32_fadd
(
	float32 value1,
	float32 value2
);

extern float32 vfp32_fsub
(
	float32 value1,
	float32 value2
);

extern float32 vfp32_fmul
(
	float32 value1,
	float32 value2
);

extern float32 vfp32_fdiv
(
	float32 value1,
	float32 value2
);


/********************************
 * system32/library/vfp64.s
 ********************************/

extern float64 vfp64_f32tof64( float32 value );

extern float32 vfp64_f64tof32( float64 value );

extern float64 vfp64_s32tof64( int32 value );

extern float64 vfp64_u32tof64( uint32 value );

extern int32 vfp64_f64tos32( float64 value );

extern uint32 vfp64_f64tou32( float64 value );


/********************************
 * system32/library/fb32.s
 ********************************/

extern uint32 FB32_FRAMEBUFFER;
extern uint32 FB32_DOUBLEBUFFER_BACK;
extern uint32 FB32_DOUBLEBUFFER_FRONT;

extern uint32 FB32_ADDR;
extern uint32 FB32_WIDTH;
extern uint32 FB32_HEIGHT;
extern uint32 FB32_SIZE;
extern uint32 FB32_DEPTH;
extern int32 FB32_X_CARET;
extern int32 FB32_Y_CARET;


/* Relative System Calls  */

/**
 * Flush Back Buffer to Framebuffer and Swap Front and Back
 *
 * Return: 0 as sucess, 1 as error
 * Error(1): When buffer is not defined
 */
__attribute__((noinline)) uint32 _flush_doublebuffer();


/**
 * Set Buffer for Double Buffer Operation
 *
 * Parameters
 * r0: Pointer of Buffer to Front
 * r1: Pointer of Buffer to Back
 *
 * Return: 0 as success, 1 as error
 * Error(1): When buffer is not Defined
 */
__attribute__((noinline)) uint32 _set_doublebuffer( uint32 address_buffer_front, uint32 address_buffer_back );


/**
 * Attach Buffer to Draw on It
 *
 * Return: 0 as sucess, 1 as error
 * Error(1): Buffer In is not Defined
 */
__attribute__((noinline)) uint32 _attach_buffer( uint32 address_buffer );


/* Regular Functions */

/**
 * Draw Image
 *
 * Return: 0 as sucess, 1 and 2 as error
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 */
extern uint32 fb32_image
(
	uint32 address_image,
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
 * Place Colored Block
 *
 * Return: 0 as sucess, 1 and 2 as error
 * Error(1): When Framebuffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Framebuffer is not Defined
 */
extern uint32 fb32_block_color
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
extern uint32 fb32_clear_color
(
	uint32 color
);


/********************************
 * system32/library/print32.s
 ********************************/

extern uint32 PRINT32_FONT_BASE;
extern uint32 PRINT32_FONT_WIDTH;
extern uint32 PRINT32_FONT_HEIGHT;
extern uint32 PRINT32_FONT_COLOR;
extern uint32 PRINT32_FONT_BACKCOLOR;
extern bool PRINT32_FONT_UNDERLINE;
extern bool PRINT32_FONT_BOLD;

/**
 * Set Caret Position from Return Vlue of `print_*` functions
 *
 * Return: 0 as success, 1 as error
 * Error: Y Caret Reaches Value of Height
 */
extern uint32 print32_set_caret
(
	uint64 return_print
);


/**
 * Print String with 1 Byte Character
 *
 * Return: Lower 32 bits (0 as sucess, 1 and more as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
extern uint64 print32_string
(
	String string,
	int32 x_coord,
	int32 y_coord,
	uint32 length
);


/**
 * No Print String with 1 Byte Character, But Get Changes of X and Y coordinates
 *
 * Return: Lower 32 bits (0 as sucess, 1 and more as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
extern uint64 print32_string_dummy
(
	String string,
	int32 x_coord,
	int32 y_coord,
	uint32 length
);


/**
 * Print Hexadecimal System (Base 16) Numbers in 64-bit (16 Digits)
 *
 * Return: Lower 32 bits (0 as sucess, 1 and more as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
extern uint64 print32_number_double
(
	uint64 number,
	int32 x_coord,
	int32 y_coord,
	uint32 length
);


/**
 * Print Hexadecimal System (Base 16) Numbers in 32-bit (8 Digits)
 *
 * Return: Lower 32 bits (0 as sucess, 1 and more as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Number of Characters Which Were Not Drawn
 */
extern uint64 print32_number
(
	uint32 number,
	int32 x_coord,
	int32 y_coord,
	uint32 length
);


/**
 * Print Hexadecimal Values in Heap for Debug Use
 *
 * Return: 0 as sucess
 */
extern uint32 print32_debug_hexa
(
	uint32 address_heap,
	int32 x_coord,
	int32 y_coord,
	uint32 length
);


/**
 * Print Number in Register for Debug Use
 *
 * Return: 0 as sucess
 */
extern uint32 print32_debug
(
	uint32 value,
	int32 x_coord,
	int32 y_coord
);


/********************************
 * system32/library/str32.s
 ********************************/

/**
 * Search Second Key String in First String
 *
 * Return: Index of First Character in String, if not -1
 */
extern int32 str32_strindex
(
	String string,
	String string_key
);


/**
 * Search Byte Character in String
 *
 * Return: Index of Character, if not -1
 */
extern int32 str32_charindex
(
	String string,
	char8 character_key
);


/**
 * Search Byte Character in String within Range
 *
 * Return: Index of Character, if not -1
 */
extern int32 str32_charsearch
(
	String string,
	uint32 length_string,
	char8 character_key
);


/**
 * Search Second Key String in First String within Range
 *
 * Return: Index of First Character in String, if not -1
 */
extern int32 str32_strsearch
(
	String string,
	uint32 length_string,
	String string_key,
	uint32 length_string_key
);


/**
 * Count Byte Character in String
 *
 * Return: Number of Counts for Character Key
 */
extern uint32 str32_charcount
(
	String string,
	uint32 length,
	char8 character_key
);


/**
 * Check Whether One Pair of Strings Are Same
 *
 * Return: 1 is Match, 0 is Not Match
 */
extern uint32 str32_strmatch
(
	String string,
	uint32 length_string,
	String string_key,
	uint32 length_string_key
);


/**
 * Concatenation of Two Strings
 * Caution! On the standard C Langage string.h library, strcat returns Pointer of Array of the first argument with
 * the concatenated string. That needs to have enough spaces of memory on the first one to concatenate.
 * But that makes buffer overflow easily. So in this function, str32_strcat returns new Pointer of Array.
 * Note that this function makes new memory space to be needed to make the memory free.
 *
 * Return: Pointer of Concatenated String
 */
extern String str32_strcat
(
	String string1,
	String string2
);


/**
 * Make Array of String List from One String
 * Caution! This Function Generates Two-dimensional Array in Heap Area.
 *
 * Return: Pointer of Two-dimensional Array of List, if 0, no enough space for new Pointer of Array
 */
extern obj str32_strlist
(
	String string,
	uint32 length_string,
	char8 separater
);


/**
 * Count 1-Byte Words of String
 *
 * Return: Number of Words Maximum of 4,294,967,295 words
 */
extern uint32 str32_strlen
(
	String string
);


/********************************
 * system32/library/draw32.s
 ********************************/

/**
 * Anti-aliasing
 * Caution! This Function is Used in 32-bit Depth Color
 * First and Last Pixel of Base is not anti-aliased, and there is no horizontal sync.
 *
 * Return: 0 as success, 1 and 2 as error
 * Error(1): When Buffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Buffer is not Defined, or Depth is not 32-bit
 */

extern uint32 draw32_antialias
(
	uint32 address_buffer_result,
	uint32 address_buffer_base
);

/**
 * Fill by Color
 *
 * Return: 0 as sucess, 1 and 2 as error
 * Error(1): When Buffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Buffer is not Defined
 */
extern uint32 draw32_fill_color
(
	uint32 address_buffer,
	uint32 background_color
);


/**
 * Make Masked Image to Mask
 *
 * Return: 0 as sucess, 1 and 2 as error
 * Error(1): When Buffer Overflow Occured to Prevent Memory Corruption/ Manipulation
 * Error(2): When Buffer is not Defined
 */
extern uint32 draw32_mask_image
(
	uint32 address_buffer_mask,
	uint32 address_buffer_base,
	int32 x_coord, // Mask
	int32 y_coord // Mask
);


/**
 * Change Value of Alpha Channel in ARGB Data
 * Caution! This Function is Used in 32-bit Depth Color
 *
 * Return: 0 as sucess
 */
extern uint32 draw32_change_alpha_argb
(
	uint32 address_image,
	uint32 size,
	uint32 alpha // 0-7 bits
);


/**
 * Convert 32-bit Depth Color RBGA to ARGB
 *
 * Return: 0 as sucess
 */
extern uint32 draw32_rgba_to_argb
(
	uint32 address_image,
	uint32 size
);


enum Object_draw32_renderbuffer {
	draw32_renderbuffer        = 5, // Size of Object (Words)
	draw32_renderbuffer_addr   = 0, // Offset in Object
	draw32_renderbuffer_width  = 4, // Offset in Object
	draw32_renderbuffer_height = 8, // Offset in Object
	draw32_renderbuffer_size   = 12, // Offset in Object
	draw32_renderbuffer_depth  = 16 // Offset in Object
};

/**
 * Initialize Renderbuffer
 *
 * Render Buffer Will Be Set with Heap.
 * Content of Render Buffer is Same as Framebuffer.
 * First is Address of Buffer, Second is Width, Third is Height, Fourth is Size, Fifth is Depth.
 * So, Block Size is 5 (20 Bytes).
 *
 * Return: 0 as sucess
 */
extern uint32 draw32_renderbuffer_init
(
	uint32 address_buffer,
	uint32 width,
	uint32 height,
	uint32 depth
);

/**
 * Clear Renderbuffer with Freeing Memory
 *
 * Return: 0 as success, 1 as error
 * Error: Pointer of Buffer is Null (0)
 */
extern uint32 draw32_renderbuffer_free
(
	uint32 address_buffer
);

/* End Object_draw32_renderbuffer */


/**
 * Copy Framebuffer to Renderbuffer
 *
 * Return: 0 as sucess, 1 as error
 * Error(1): Buffer In is not Defined
 */
extern uint32 draw32_copy
(
	uint32 address_buffer_in,
	uint32 address_buffer_out
);


/**
 * Draw Cubic Bezier Curve
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Return: Lower32 bits (0 as success, 1 as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Buffer is Not Defined
 */
extern uint64 draw32_bezier
(
	uint32 color,
	int32 x_point0,
	int32 y_point0,
	int32 x_point1,
	int32 y_point1,
	int32 x_point2,
	int32 y_point2,
	int32 x_point3,
	int32 y_point3,
	uint32 width,
	uint32 height
);


/**
 * Draw Arc by Radian with Single Precision Float
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 * |Radius| <= PI is Preferred. If you want a circle, use -180 degrees to 180 degrees, i.e., -PI to PI.
 *
 * Return: Lower32 bits (0 as success, 1 as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Buffer is Not Defined
 */
extern uint64 draw32_arc
(
	uint32 color,
	int32 x_coord,
	int32 y_coord,
	uint32 x_radius,
	uint32 y_radius,
	float32 start_radian,
	float32 end_radian,
	uint32 width,
	uint32 height
);


/**
 * Draw Circle Filled with Color
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Lower 32 bits (0 as sucess, 1 as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Buffer is Not Defined
 */
extern uint64 draw32_circle
(
	uint32 color,
	int32 x_coord,
	int32 y_coord,
	uint32 x_radius,
	uint32 y_radius
);


/**
 * Draw Line
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Lower 32 bits (0 as sucess, 1 as error), Upper 32 bits (Upper 16 bits: Last X Coordinate, Lower 16 bits: Last Y Coordinate)
 * Error: Buffer is Not Defined
 */
extern uint64 draw32_line
(
	uint32 color,
	int32 x_coord_1,
	int32 y_coord_1,
	int32 x_coord_2,
	int32 y_coord_2,
	uint32 width,
	uint32 height
);


/********************************
 * system32/library/snd32.s
 ********************************/

/* Constants */

#define sound_index uint16
#define music_code uint16
#define SND32_PWM          0
#define SND32_PWM_BALANCED 1
#define SND32_I2S          2
#define SND32_I2S_BALANCED 3
#define SND32_END          0xFFFF


/* Relative System Calls  */

__attribute__((noinline)) uint32 _sounddecode( sound_index* sound, uchar8 mode ); // 0 as PWM Mode Monoral, 1 as PWM Mode Balanced Monoral, 2 as PCM Mode

__attribute__((noinline)) uint32 _soundset( music_code* music, uint32 length, uint32 count, int32 repeat );

__attribute__((noinline)) uint32 _soundplay();

__attribute__((noinline)) uint32 _soundinterrupt( music_code* music, uint32 length, uint32 count, int32 repeat );

__attribute__((noinline)) uint32 _soundclear();


/* Regular Functions */

/**
 * Count 2-Bytes Beats of Music Code
 *
 * Return: Number of Beats in Music Code, Maximum of 4,294,967,295 Beats
 */
extern uint32 snd32_musiclen
(
	music_code* music
);


/********************************
 * system32/library/sts32.s
 ********************************/

/* Constants */

#define synthe_precode uint32
#define synthe_code    uint32
#define STS32_END      0x00,0x00
#define STS32_FREQ     0
#define STS32_MAG      16
#define STS32_BEAT     0
#define STS32_RIS      0
#define STS32_FAL      16

/* Relative System Calls  */

__attribute__((noinline)) uint32 _synthewave_pwm();

__attribute__((noinline)) uint32 _synthewave_i2s();

__attribute__((noinline)) uint32 _syntheset( synthe_code* synthe, uint32 length, uint32 count, int32 repeat );

__attribute__((noinline)) uint32 _syntheplay();

__attribute__((noinline)) uint32 _syntheclear();


/* Regular Functions */

/**
 * Count 2-Bytes Beats of Music Code
 *
 * Return: Number of Beats in Music Code, Maximum of 4,294,967,295 Beats
 */
extern uint64 sts32_synthelen
(
	synthe_code* synthe
);


/**
 * Make LR Synthesizer Code from Pre-code
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Return: Pointer of Array of Synthesizer Code, If 0, 1, and 2 Error
 * Error(0): Memory Space for Synthesizer Code is Not Allocated (On heap32_malloc)
 * Error(1): Memory Space for Synthesizer Code is Not Allocated (On sts32_synthedecode)
 * Error(2): Overflow of Memory Space (On sts32_synthedecode)
 */
extern synthe_code* sts32_synthedecodelr
(
	synthe_precode* synthe_precode_l,
	synthe_precode* synthe_precode_r
);


/********************************
 * system32/library/hid32.s
 ********************************/

__attribute__((noinline)) int32 _hid_activate(
	uint32 channel,
	uint32 number_configuration,
	uint32 ticket
);

__attribute__((noinline)) int32 _hid_setidle(
	uint32 channel,
	uint32 number_interface,
	uint32 ticket
);

__attribute__((noinline)) String _keyboard_get(
	uint32 channel,
	uint32 number_endpoint,
	uint32 ticket
);


/********************************
 * system32/library/rom32.s
 ********************************/

__attribute__((noinline)) int32 _romread_i2c(
	uint32 address_heap,
	uint32 chip_select,
	uint32 address_memory, 
	uint32 length
);

__attribute__((noinline)) int32 _romwrite_i2c(
	uint32 address_heap,
	uint32 chip_select,
	uint32 address_memory, 
	uint32 length
);


/********************************
 * system32/library/math32.s
 ********************************/

/* Constants */

extern float32 MATH32_NAN;
extern float32 MATH32_INFINITY_POSITIVE;
extern float32 MATH32_INFINITY_NEGATIVE;
extern float32 MATH32_PI;
extern float32 MATH32_PI_DOUBLE;
extern float32 MATH32_PI_HALF;
extern float32 MATH32_PI_PER_DEGREE;


/* Regular Functions */

/**
 * Return Rounded Degrees Between 0 to 360 with Single Precision Float
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Return: Value by Single Precision Float
 */
extern float32 math32_round_degree
(
	float32 degree
);


/**
 * Return Radian from Degrees
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Value by Single Precision Float
 */
extern float32 math32_degree_to_radian
(
	float32 degree
);


/**
 * Return Degrees from Radian
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Value by Single Precision Float
 */
extern float32 math32_radian_to_degree
(
	float32 radian
);


/**
 * Return Sine by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Value by Single Precision Float
 */
extern float32 math32_sin
(
	float32 radian
);


/**
 * Return Cosine by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Value by Single Precision Float
 */
extern float32 math32_cos
(
	float32 radian
);


/**
 * Return Tangent by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Value by Single Precision Float
 */
extern float32 math32_tan
(
	float32 radian
);


/**
 * Return Secant by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Value by Single Precision Float
 */
extern float32 math32_sec
(
	float32 radian
);


/**
 * Return Cosecant by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Value by Single Precision Float
 */
extern float32 math32_csc
(
	float32 radian
);


/**
 * Return Cotangent by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Value by Single Precision Float
 */
extern float32 math32_cot
(
	float32 radian
);


/**
 * Return Arcsine by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Radian by Single Precision Float
 */
extern float32 math32_arcsin
(
	float32 value
);


/**
 * Return Arccosine by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Radian by Single Precision Float
 */
extern float32 math32_arccos
(
	float32 value
);


/**
 * Return Arctangent by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Radian by Single Precision Float
 */
extern float32 math32_arctan
(
	float32 value
);


/**
 * Return Arcsecant by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Radian by Single Precision Float
 */
extern float32 math32_arcsec
(
	float32 value
);


/**
 * Return Arccosecant by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Radian by Single Precision Float
 */
extern float32 math32_arccsc
(
	float32 value
);


/**
 * Return Arccotangent by Single Precision Float, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: Radian by Single Precision Float
 */
extern float32 math32_arccot
(
	float32 value
);


/**
 * Return Natural Logarithm, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Return: Value by Single Precision Float and Signed Plus
 */
extern float32 math32_ln
(
	float32 value
);


/**
 * Return Common Logarithm, Using Maclaurin (Taylor) Series
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Return: Value by Single Precision Float and Signed Plus
 */
extern float32 math32_log
(
	float32 value
);


/********************************
 * system32/library/chk32.s
 ********************************/

/**
 * Cyclic Redundancy Check CRC7 (8-bit) by One Byte Big Endian (MSB Order), No Reflection of Bits on Input and Result
 *
 * Return: Calculated Value, -1 as Error
 * Error: Length of Bits as Divisor Exceeds Length of Data
 */
extern uchar8 chk32_crc7
(
	uint32 address_data,
	uint32 length_data, // From 2
	uchar8 divisor,
	uchar8 xor_initial,
	uchar8 xor_final,
	uint32 number_bit // To Check, From 15
);


/**
 * Cyclic Redundancy Check CRC8 (9-bit) by One Byte Big Endian (MSB Order), No Reflection of Bits on Input and Result
 *
 * Return: Calculated Value, -1 as Error
 * Error: Length of Bits as Divisor Exceeds Length of Data
 */
extern uchar8 chk32_crc8
(
	uint32 address_data,
	uint32 length_data, // From 2
	uchar8 divisor, // Omit Bit[8] (Always High) to Hide Overflow
	uchar8 xor_initial,
	uchar8 xor_final,
	uint32 number_bit // To Check, From 16
);


/**
 * Cyclic Redundancy Check CRC16 (17-bit) by One Byte Big Endian (MSB Order), No Reflection of Bits on Input and Result
 *
 * Return: Calculated Value, -1 as Error
 * Error: Length of Bits as Divisor Exceeds Length of Data
 */
extern uint16 chk32_crc16
(
	uint32 address_data,
	uint32 length_data, // From 3
	uint16 divisor, // Omit Bit[16] (Always High) to Hide Overflow
	uint16 xor_initial,
	uint16 xor_final,
	uint32 number_bit // To Check, From 24
);


/**
 * Cyclic Redundancy Check CRC32 (33-bit) by One Byte Big Endian (MSB Order), No Reflection of Bits on Input and Result
 *
 * Return: Calculated Value, -1 as Error
 * Error: Length of Bits as Divisor Exceeds Length of Data
 */
extern uint32 chk32_crc32
(
	uint32 address_data,
	uint32 length_data, // From 5
	uint32 divisor, // Omit Bit[32] (Always High) to Hide Overflow
	uint32 xor_initial,
	uint32 xor_final,
	uint32 number_bit // To Check, From 40
);


/**
 * Make Table for Cyclic Redundancy Check
 * This function Makes Allocated Memory Space from Heap.
 *
 * Return: Pointer of CRC Table, If Zero Memory Allocation Fails
 */
extern uint32 chk32_crctable
(
	uint32 divisor, // Omit MSB
	uint32 crc_select // CRC8 (0)/ CRC16 (1)/ CRC32 (2)
);


/**
 * Cyclic Redundancy Check Using Table
 * Return value is not cut further bits. Use only lower 16 bits in CRC16.
 *
 * Return: Calculated Value
 */
extern uint32 chk32_crc
(
	uint32 address_data,
	uint32 length_data,
	uint32 xor_initial,
	uint32 xor_final,
	uint32 address_table,
	uint32 crc_select // CRC8 (0)/ CRC16 (1)/ CRC32 (2)
);



/********************************
 * system32/library/mtx32.s
 ********************************/

/**
 * Multiplies Two Matrix with Single Precision Float
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Return: Matrix to Be Calculated, If Zero Not Allocated Memory
 */
extern obj mtx32_multiply
(
	obj matrix1,
	obj matrix2,
	uint32 number
);


/**
 * Get Identity of Matrix
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Return: Matrix to Have Identity, If Zero Not Allocated Memory
 */
extern obj mtx32_identity
(
	uint32 number
);


/**
 * Square Matrix and Column Vector Multiplication
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Return: Vector to Be Calculated, If Zero Not Allocated Memory
 */
extern obj mtx32_multiply_vec
(
	obj matrix,
	obj vector,
	uint32 number
);


/**
 * Normalize Vector
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Return: Vector to Have Been Normalized, If Zero Not Allocated Memory
 */
extern obj mtx32_normalize
(
	obj vector,
	uint32 number
);


/**
 * Dot Product
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 *
 * Return: Value of Dot Product by Single Precision Float
 */
extern float32 mtx32_dotproduct
(
	obj vector1,
	obj vector2,
	uint32 number
);


/**
 * Cross Product
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Return: Vector to Be Calculated, If Zero Not Allocated Memory
 */
extern obj mtx32_crossproduct
(
	obj vector1, // Must Be Three of Vector Size
	obj vector2 // Must Be Three of Vector Size
);


/**
 * Make 4 by 4 Square Matrix (Column Order) with Vector of 3D Translation
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Return: 4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory
 */
extern obj mtx32_translate3d
(
	obj vector // Must Be Three of Vector Size, X, Y, and Z
);


/**
 * Make 4 by 4 Square Matrix (Column Order) with Vector of 3D Scale
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Return: 4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory
 */
extern obj mtx32_scale3d
(
	obj vector // Must Be Three of Vector Size, X, Y, and Z
);


/**
 * Make 4 by 4 Square Matrix (Column Order) with Vector of 3D Rotate X
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Return: 4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory
 */
extern obj mtx32_rotatex3d
(
	float32 degrees
);


/**
 * Make 4 by 4 Square Matrix (Column Order) with Vector of 3D Rotate Y
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Return: 4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory
 */
extern obj mtx32_rotatey3d
(
	float32 degrees
);


/**
 * Make 4 by 4 Square Matrix (Column Order) with Vector of 3D Rotate Z
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Return: 4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory
 */
extern obj mtx32_rotatez3d
(
	float32 degrees
);


/**
 * Make 4 by 4 Square Matrix (Column Order) with Perspective
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Return: 4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory
 */
extern obj mtx32_perspective3d
(
	float32 fovy, // Field of View Y: Vertical
	float32 aspect,
	float32 near,
	float32 far
);


/**
 * Make 4 by 4 Square Matrix (Column Order) with View
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Return: 4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory
 */
extern obj mtx32_view3d
(
	obj vector_camera, // Must Be Three of Vector Size, X, Y, and Z
	obj vector_target, // Must Be Three of Vector Size, X, Y, and Z
	obj vector_up  // Must Be Three of Vector Size, X, Y, and Z
);


/**
 * Make Versor
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Return: Versor, If Zero Not Allocated Memory
 */
extern obj mtx32_versor
(
	float32 angle,
	obj vector // Must Be Three of Vector Size, X, Y, and Z
);


/**
 * Make Matrix from Versor
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable.
 * This Function Makes Allocated Memory Space from Heap.
 *
 * Return: 4 by 4 Square Matrix to Be Calculated, If Zero Not Allocated Memory
 */
extern obj mtx32_versortomatrix
(
	obj versor // Must Be Four of Versor Size, W, X, Y, and Z
);


/********************************
 * system32/library/geo32.s
 ********************************/

/**
 * Return Sigma in Shoelace Formula
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Return: Value by Single Precision Float
 */
extern float32 geo32_shoelace_pre
(
	obj series_vector, // Series of X and Y by Single Precision Float
	uint32 number_vertices
);


/**
 * Return Area by Shoelace Formula
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Return: Value by Single Precision Float
 */
extern float32 geo32_shoelace
(
	obj series_vector, // Series of X and Y by Single Precision Float
	uint32 number_vertices
);


/**
 * Draw Polygon
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 *
 * Return: 0 as sucess, 1 as error
 * Error: Buffer is Not Defined
 */
extern uint32 geo32_polygon
(
	uint32 color,
	obj vertices, // Series of X and Y Must Be Long Integer
	int32 number_vertices,
	uint32 width,
	uint32 height
);




/**
 * Draw 3D Wire
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Return: 0 as Success, -1 as Warning, 1 and 2 as Error
 * Warning(-1): Last Polygon is Flip Side Not to Be Drawn
 * Error(1): Memory Allocation Fails
 * Error(2): Buffer Is Not Defined
 */
extern int32 geo32_wire3d
(
	uint32 color,
	obj vertices, // Series of X and Y by Single Precision Float
	uint32 number_vertices,
	uint32 number_units, // XYZ Units
	obj matrix,
	uint32 rotataion
);


/**
 * Draw Filled 3D
 * Caution! This Function Needs to Make VFPv2 Registers and Instructions Enable
 *
 * Return: 0 as Success, 1 and 2 as Error
 * Error(1): Memory Allocation Fails
 * Error(2): Buffer Is Not Defined
 */
extern int32 geo32_fill3d
(
	obj colors,
	obj vertices, // Series of X, Y, and Z by Single Precision Float
	uint32 number_vertices,
	uint32 number_units, // XYZ Units
	obj matrix,
	uint32 rotataion,
	uint32 backgroud_color
);


#define GEO32_CCW  0 // Polygon with Counter Clockwise Is Front to Be Drawn
#define GEO32_CW   1 // Polygon with Clockwise Is Front to Be Drawn
#define GEO32_BOTH 2 // Both Are Going to Be Drawn


/********************************
 * system32/library/math64.s
 ********************************/

/**
 * Return Factorial
 *
 * Return: Value by Double Precision Float
 */
extern float64 math64_factorial
(
	uint32 value
);


/**
 * Return Double Factorial
 *
 * Return: Value by Double Precision Float
 */
extern float64 math64_double_factorial
(
	uint32 value
);


/**
 * Return Gamma Function (Variable is Positive Integer)
 *
 * Return: Value by Double Precision Float
 */
extern float64 math64_gamma_integer
(
	uint32 value
);


/**
 * Return Gamma Function (Variable is Positive Half Integer)
 *
 * Return: Value by Double Precision Float, -1 by Integer as Error
 */
extern float64 math64_gamma_halfinteger
(
	uint32 value
);


/**
 * Return Gamma Function (Variable is Negative Half Integer)
 *
 * Return: Value by Double Precision Float, -1 by Integer as Error
 */
extern float64 math64_gamma_halfinteger_negative
(
	uint32 value // Must Be Odd
);


/**
 * Return Gaussian (2F1) Hypergeometric Function (First, Second, and Third Arguments are Half Integers) Using Power Series
 *
 * Return: Value by Double Precision Float, -1 by Integer as Error
 */
extern float64 math64_hypergeometric_halfinteger
(
	uint32 first,
	uint32 second,
	uint32 third,
	float32 fourth, // abs(fourth) < 1
	uint32 number_series
);


/********************************
 * system32/library/stat32.s
 ********************************/

extern float32 stat32_cdf_t( float32 t_value, uint32 degrees_of_freedom, uint32 number_series );

extern float32 stat32_ttest_correlation( float32 correlation, uint32 size_sample );

extern float32 stat32_ttest_1( float32 mean_population, float32 mean_sample, float32 sd_sample, uint32 size_sample );

extern float32 stat32_standard_error( float32 sd, uint32 size );

extern float32 stat32_correlation_pearson( float32 standard_deviation1, float32 standard_deviation2, float32 covariance );

extern float32 stat32_covariance( obj array_deviation1, obj array_deviation2, uint32 length, bool correction );

extern float32 stat32_standard_deviation( obj array, uint32 length, bool correction );

extern float32 stat32_variance( obj array, uint32 length, bool correction );

obj stat32_deviation( obj array, uint32 length, float32 average, bool bool_signed );

extern float32 stat32_max( obj array, uint32 length );

extern float32 stat32_min( obj array, uint32 length );

extern float32 stat32_mean( obj array, uint32 length );

extern float32 stat32_median( obj array, uint32 length ); // Array Must Be Ordered

extern float32 stat32_mode( obj array, uint32 length ); // Array Must Be Ordered

extern obj stat32_order( obj array, uint32 length, bool decreasing );


/********************************
 * system32/library/cvt32.s
 ********************************/

/**
 * Make String of Single Precision Float Value
 * Caution! This Function Needs to Make VFP/NEON Registers and Instructions Enable
 * If Float Value Exceeds 1,000,000,000.0, String Will Be Shown With Exponent and May Have Loss of Signification.
 *
 * Return: Pointer of String, If Zero, Memory Space for String Can't Be Allocated
 */
extern String cvt32_float32_to_string
(
	float32 float_number,
	uint32 min_integer, // 16 Digits Max
	uint32 max_decimal, // Default 8 Digits
	int32 indicator_expo // Indicates Exponential
);


/**
 * Make String of Integer Value by Decimal System (Base 10)
 *
 * Return: Pointer of String, If Zero, Memory Space for String Can't Be Allocated
 */
extern String cvt32_int32_to_string_deci
(
	int32 number, // If You Use This for uint32, You Need to Cast It to int32 
	uint32 min_length,
	bool bool_signed
);


/**
 * Make String of Integer Value by Hexadecimal System (Base 16)
 *
 * Return: Pointer of String, If Zero, Memory Space for String Can't Be Allocated
 */
extern String cvt32_int32_to_string_hexa
(
	int32 number, // If You Use This for uint32, You Need to Cast It to int32 
	uint32 min_length,
	bool bool_signed,
	bool base_mark
);


/**
 * Make String of Integer Value by Binary System (Base 2)
 * This function uses defined Ascii Codes for true ("1" on default) and false ("0" on default).
 *
 * Return: Pointer of String, If Zero, Memory Space for String Can't Be Allocated
 */
extern String cvt32_int32_to_string_bin
(
	uint32 number, 
	uint32 min_length,
	bool base_mark
);


/**
 * Make 32-bit Unsigned Integer From String on Hexadecimal System
 * Caution! The Range of Decimal Number Is 0x0 through 0xFFFFFFFF
 * Max. Valid Digits Are 8, Otherwise, You'll Inaccurate Return.
 *
 * This function detects spaces, plus signs, commas, minus signs, periods, then ignores these.
 *
 * Return: Unsigned Integer
 */
extern uint32 cvt32_string_to_hexa
(
	String string,
	uint32 length_string
);


/**
 * Make 64-bit Decimal Number From String on Decimal System
 * Caution! The Range of Decimal Number Is 0 through 9,999,999,999,999,999.
 * Max. Valid Digits Are 16, Otherwise, You'll Get Inaccurate Return.
 *
 * This function detects spaces, plus signs, commas, minus signs, periods, then ignores these.
 *
 * Return: Lower 32 Bits (Lower Bits of Decimal Number), Upper 32 Bits (Upper Bits of Decimal Number)
 */
extern int64 cvt32_string_to_deci
(
	String string,
	uint32 length_string
);


/**
 * Make 32-bit Unsigned Integer From String on Binary System
 * Caution! The Range of Decimal Number Is 0b0 through 0b1111 1111 1111 1111 1111 1111 1111 1111
 * Max. Valid Digits Are 32, Otherwise, You'll Get Inaccurate Return.
 *
 * This function detects spaces, plus signs, commas, minus signs, periods, then ignores these.
 *
 * Return: Unsigned Integer
 */
extern uint32 cvt32_string_to_bin
(
	String string,
	uint32 length_string
);


/**
 * Make 32-bit Unsigned/Signed Integer From String (Decimal System)
 * Caution! The Range of Decimal Number Is 0 through 4,294,967,295 on Unsigned, -2,147,483,648 thorugh 2,147,483,647 on Signed.
 * Maximum Number of Valid Digits Exists. If It Exceeds, You'll Get Inaccurate Return.
 *
 * This function detects spaces, plus signs, commas, minus signs, periods, then ignores these.
 *
 * Return: 32-bit Unsigned/Signed Integer
 */
extern int32 cvt32_string_to_int32
(
	String string,
	uint32 length_string
);


/**
 * Make 32-bit Float From String (Decimal System)
 * Caution! The Range of Integer Part is -2,147,483,648 thorugh 2,147,483,647 on Signed.
 * Otherwise, You'll Get Inaccurate Integer Part to Return.
 *
 * Return: 32-bit Float
 */
extern float32 cvt32_string_to_float32
(
	String string,
	uint32 length_string // Max. 10 if Unsigned, 11 if Signed
);


/**
 * Convert Hexadecimal Bases (0-F) to Decimal Bases (0-9)
 *
 * Return: Lower 32 Bits (Lower Bits of Decimal Number), Upper 32 Bits (Upper Bits of Decimal Number)
 */
extern uint64 cvt32_hexa_to_deci
(
	uint32 number_hexa
);


/**
 * Convert Decimal Bases (0-9) to Hexadecimal Bases (0-F)
 * Caution! The Range of Decimal Number is 0 through 4,294,967,295. If Value of Upper Bits is 43 and Over, Returns 0.
 *
 * Return: Hexadecimal Number
 */
extern uint32 cvt32_deci_to_hexa
(
	uint64 number_deci
);


/**
 * Make Array of Integers From String
 * This function detects defined separators (commas on default) between each Integers.
 *
 * Return: Heap of Array, 0 as not succeeded
 */
extern obj cvt32_string_to_intarray
(
	String string,
	uint32 length_string,
	uint32 size_block // 0 = 1 bytes; 1 = 2 bytes; 2 = 4 bytes
);


/**
 * Make String on Decimal System From Array of Integers
 *
 * Return: Heap of String, 0 as not succeeded
 */
extern String cvt32_intarray_to_string_deci
(
	obj object_array,
	uint32 size_block, // 0 = 1 bytes; 1 = 2 bytes; 2 = 4 bytes
	uint32 min_length,
	bool bool_signed
);


/**
 * Make String on Hexadecimal System From Array of Integers
 *
 * Return: Heap of String, 0 as not succeeded
 */
extern String cvt32_intarray_to_string_hexa
(
	obj object_array,
	uint32 size_block, // 0 = 1 bytes; 1 = 2 bytes; 2 = 4 bytes
	uint32 min_length,
	bool bool_signed,
	bool base_mark
);


/**
 * Make String on Binary System From Array of Integers
 *
 * Return: Heap of String, 0 as not succeeded
 */
extern String cvt32_intarray_to_string_bin
(
	obj object_array,
	uint32 size_block, // 0 = 1 bytes; 1 = 2 bytes; 2 = 4 bytes
	uint32 min_length,
	bool base_mark
);


/**
 * Make Array of Single Precision Floats From String on Decimal System
 * This function detects defined separators (commas on default) between each floats.
 *
 * Return: Heap of Array, 0 as not succeeded
 */
extern obj cvt32_string_to_farray
(
	String string,
	uint32 length_string
);


/**
 * Make String on Decimal System From Single Precision Floats
 *
 * Return: Heap of String, 0 as not succeeded
 */
extern String cvt32_farray_to_string
(
	obj object_array,
	uint32 min_integer, // 16 Digits Max
	uint32 max_decimal, // Default 8 Digits
	int32 indicator_expo // Indicates Exponential
);


/********************************
 * system32/library/bcd32.s
 ********************************/

/**
 * Signed Addition with Decimal Bases (0-9), -9,999,999,999,999,999 to 9,999,999,999,999,999
 * Caution! This function makes string allocated from Heap.
 *
 * Return: Pointer of String of Decimal Number, If Zero Memory Allocation Fails
 */
extern String bcd32_badd
(
	String string_deci1, // Needed between 0-9 in all digits
	uint32 length_deci1,
	String string_deci2, // Needed between 0-9 in all digits
	uint32 length_deci2
);


/**
 * Signed Subtraction with Decimal Bases (0-9), -9,999,999,999,999,999 to 9,999,999,999,999,999
 * If Saturated, Returns All F in 16 Digits
 * Caution! This function makes string allocated from Heap.
 *
 * Return: Pointer of String of Decimal Number, If Zero Memory Allocation Fails
 */
extern String bcd32_bsub
(
	String string_deci1, // Needed between 0-9 in all digits
	uint32 length_deci1,
	String string_deci2, // Needed between 0-9 in all digits
	uint32 length_deci2
);


/**
 * Signed Multiplication with Decimal Bases (0-9), -9,999,999,999,999,999 to 9,999,999,999,999,999
 * If Saturated, Returns All F in 16 Digits
 * Caution! This function makes string allocated from Heap.
 *
 * Return: Pointer of String of Decimal Number, If Zero Memory Allocation Fails
 */
extern String bcd32_bmul
(
	String string_deci1, // Needed between 0-9 in all digits
	uint32 length_deci1,
	String string_deci2, // Needed between 0-9 in all digits
	uint32 length_deci2
);


/**
 * Signed Division with Decimal Bases (0-9), -9,999,999,999,999,999 to 9,999,999,999,999,999
 * If Saturated, Returns All F in 16 Digits
 * Caution! This function makes string allocated from Heap.
 *
 * Return: Pointer of String of Decimal Number, If Zero Memory Allocation Fails
 */
extern String bcd32_bdiv
(
	String string_deci1, // Needed between 0-9 in all digits
	uint32 length_deci1,
	String string_deci2, // Needed between 0-9 in all digits
	uint32 length_deci2
);


/**
 * Remainder of Signed Division with Decimal Bases (0-9), -9,999,999,999,999,999 to 9,999,999,999,999,999
 * If Saturated, Returns All F in 16 Digits
 * Caution! This function makes string allocated from Heap.
 *
 * Return: Pointer of String of Decimal Number, If Zero Memory Allocation Fails
 */
extern String bcd32_brem
(
	String string_deci1, // Needed between 0-9 in all digits
	uint32 length_deci1,
	String string_deci2, // Needed between 0-9 in all digits
	uint32 length_deci2
);


/**
 * Compare Values with Decimal Bases (0-9), -9,999,999,999,999,999 to 9,999,999,999,999,999
 *
 * Return: NZCV ALU Flags (Bit[31:28])
 */
extern uint32 bcd32_bcmp
(
	String string_deci1, // Needed between 0-9 in all digits
	uint32 length_deci1,
	String string_deci2, // Needed between 0-9 in all digits
	uint32 length_deci2
);


/**
 * Unsigned Addition with Decimal Bases (0-9)
 *
 * Return: Lower 32 Bits (Lower Bits of Decimal Number), Upper 32 Bits (Upper Bits of Decimal Number), error if carry bit is set
 * Error: This function could not calculate because of digit-overflow.
 */
extern uint64 bcd32_deci_add64
(
	uint64 number_deci1,
	uint64 number_deci2
);


/**
 * Unsigned Subtraction with Decimal Bases (0-9)
 *
 * Return: Lower 32 Bits (Lower Bits of Decimal Number), Upper 32 Bits (Upper Bits of Decimal Number), error if carry bit is set
 * Error: This function could not calculate because the result is signed minus.
 */
extern uint64 bcd32_deci_sub64
(
	uint64 number_deci1,
	uint64 number_deci2
);


/**
 * Shift Place with Decimal Bases (0-9)
 *
 * Return: Lower Bits of Decimal Number, Upper Bits of Decimal Number, error if carry bit is set
 */
extern uint64 bcd32_deci_shift64
(
	uint64 number_deci,
	int32 number_shift
);


/**
 * Unsigned Multiplication with Decimal Bases (0-9)
 *
 * Return: Lower 32 Bits (Lower Bits of Decimal Number), Upper 32 Bits (Upper Bits of Decimal Number), error if carry bit is set
 * Error: This function could not calculate because of digit-overflow.
 */
extern uint64 bcd32_deci_mul64
(
	uint64 number_deci1,
	uint64 number_deci2
);


/**
 * Unsigned Division with Decimal Bases (0-9)
 *
 * Return: Lower 32 Bits (Lower Bits of Decimal Number), Upper 32 Bits (Upper Bits of Decimal Number), Remainder Exists If Carry Bit Is Set
 * Error: This function could not calculate because of digit-overflow.
 */
extern uint64 bcd32_deci_div64
(
	uint64 number_deci1,
	uint64 number_deci2
);


/**
 * Remainder of Unsigned Division with Decimal Bases (0-9)
 *
 * Return: Lower 32 Bits (Lower Bits of Decimal Number), Upper 32 Bits (Upper Bits of Decimal Number)
 * Error: This function could not calculate because of digit-overflow.
 */
extern uint64 bcd32_deci_rem64
(
	uint64 number_deci1,
	uint64 number_deci2
);


/********************************
 * system32/library/heap32.s
 ********************************/

typedef struct _darray {
	obj heap;
	uint32 current_length; // Current Length as Array (Per Data, Not Bytes)
	uint32 size_indicator; // Size Indicator 0 = 1 Byte, 1 = 2 Bytes, 3 = 4 Bytes, Indicating Each Data of Array
} darray;

extern uint32 heap32_mpush
(
	obj heap,
	uint32 data,
	uint32 current_length,
	uint32 size_indicator
);

extern uint32 heap32_msquash
(
	obj heap,
	uint32 index_data,
	uint32 current_length,
	uint32 size_indicator
);

extern obj heap32_malloc( uint32 block_size );

extern uint32 heap32_mfree( obj heap );

extern int32 heap32_mcount( obj heap );

extern uint32 heap32_mfill( obj heap, uint32 data );

extern obj heap32_mcopy( obj heap_dst, uint32 offset_dst, obj heap_src, uint32 offset_src, uint32 size_src );


/********************************
 * system32/library/font_mono_12px.s
 ********************************/

extern uint32 FONT_MONO_12PX_ASCII;


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
extern uint32 COLOR16_SAMPLE_IMAGE;

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
 * system32/library/data.s
 ********************************/

extern uint32 DATA_COLOR32_SAMPLE_IMAGE0;
extern uint32 DATA_COLOR32_SAMPLE_IMAGE0_SIZE;
extern uint32 DATA_COLOR32_SAMPLE_IMAGE1;
extern uint32 DATA_COLOR32_SAMPLE_IMAGE1_SIZE;
