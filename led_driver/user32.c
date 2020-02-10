/**
 * user32.c
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * Usage
 * 1. Place `gpio32_gpioplay` on FIQ/IRQ Handler which will be triggered with any timer.
 * 2. Place `_gpioset` with needed arguments in `user32.c`.
 * 3. GPIO sequence automatically runs with the assigned values.
 * 4. If you want to stop the GPIO sequence, use `_gpioclear`.
 */

/**
 * GPIO sequence is made of 32-bit Blocks. One Block means one beat.
 * Bit[0]: GPIO 0 Output Low(0)/High(1)
 * Bit[1]: GPIO 1 Output Low(0)/High(1)
 * ...
 * Bit[29]: GPIO 29 Output Low(0)/High(1)
 * Bit[30]: Stay Prior Status of GPIO Which Are Assigned as Zero in the Block
 * Bit[31]: Always Need of Set(1)
 * Note that if a beat is all zero, this beat means the end of sequence.
 */

#include "system32.h"
#include "system32.c"

/**
 * Global Variables and Constants
 * to Prevent Incorrect Compilation in optimization,
 * Variables (except these which have only one value) used over the iteration of the loop are defined as global variables.
 */

#define TIMER_COUNT_MULTIPLICAND        10
#define TIMER_COUNT_MULTIPLIER_DEFAULT  12
#define TIMER_COUNT_MULTIPLIER_MINLIMIT 6
#define TIMER_COUNT_MULTIPLIER_MAXLIMIT 12000
#define GPIO_MASK                       0x003C7FFC // GPIO 2-14, 18-21
#define GPIO_MASK_LANE0                 0x003C7FFC // GPIO 2-14, 18-21

/**
 * In default, there is a 1000Hz synchronization clock (it's a half of 2000Hz on Arm Timer beacause of toggling).
 * Arm Timer sets 240000Hz as clock.
 * 120 is divisor (TIMER_COUNT_MULTIPLICAND * TIMER_COUNT_MULTIPLIER_DEFAULT), i.e., 240000Hz / 120 / 2 equals 1000Hz.
 * The Maximum beat (240000 / (TIMER_COUNT_MULTIPLICAND * TIMER_COUNT_MULTIPLIER_MINLIMIT) / 2) is 2000Hz.
 * The minimum beat (240000 / (TIMER_COUNT_MULTIPLICAND * TIMER_COUNT_MULTIPLIER_MAXLIMIT) / 2) is 1Hz.
 *
 * If you want particular BPM for a track, use _armtimer_reload and/or _armtimer prior to _syntheset.
 */

gpio_sequence gpio1[] =
{
	0b10000000000000000000000000000100,
	GPIO32_END
};

gpio_sequence gpio2[] =
{
	0b10000000000000000000000000001000,
	GPIO32_END
};

gpio_sequence gpio3[] =
{
	0b10000000000000000000000000001000,
	GPIO32_END
};

gpio_sequence gpio4[] =
{
	0b10000000000000000000000000010000,
	GPIO32_END
};

gpio_sequence gpio5[] =
{
	0b10000000000000000000000000001000,
	GPIO32_END
};

gpio_sequence gpio6[] =
{
	0b10000000000000000000000000001000,
	GPIO32_END
};

gpio_sequence gpio7[] =
{
	0b10000000000000000000000000001000,
	GPIO32_END
};

gpio_sequence gpio8[] =
{
	0b10000000000000000000000000111100,
	0b10000000000000000000000000111100,
	0b10000000000000000000000000111100,
	0b10000000000000000000000000111100,
	0b10000000000000000000000000111100,
	0b10000000000000000000000000000100,
	0b10000000000000000000000000001000,
	0b10000000000000000000000000010000,
	0b10000000000000000000000000100000,
	0b10000000000000000000000000010000,
	0b10000000000000000000000000001000,
	0b10000000000000000000000000000100,
	0b10000000000000000000000000001100,
	0b10000000000000000000000000110000,
	0b10000000000000000000000000000000,
	0b10000000000000000000000000000000,
	0b10000000000000000000000000000000,
	0b10000000000000000000000000000000,
	0b10000000000000000000000000000000,
	0b10000000000000000000000000000000,
	0b11000000000000000000000000000100,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000001000,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000010000,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000100000,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000000000,
	0b10000000000000000000000000000000,
	0b10000000000000000000000000000000,
	0b10000000000000000000000000111100,
	0b10000000000000000000000000000000,
	0b10000000000000000000000000111100,
	0b10000000000000000000000000000000,
	0b10000000000000000000000000111100,
	0b10000000000000000000000000000000,
	0b10000000000000000000000000111100,
	0b10000000000000000000000000000000,
	0b11000000000000000000000000111100,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000000000,
	0b01000000000000000000000000100000,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000000000,
	0b01000000000000000000000000010000,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000000000,
	0b01000000000000000000000000001000,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000000000,
	0b01000000000000000000000000000100,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000000000,
	0b11000000000000000000000000000000,
	0
};

gpio_sequence gpio9[] =
{
	0b10000000000000000000000000001000,
	GPIO32_END
};

gpio_sequence gpio10[] =
{
	0b10000000000000000000000000001000,
	GPIO32_END
};

gpio_sequence gpio11[] =
{
	0b10000000000000000000000000001000,
	GPIO32_END
};

gpio_sequence gpio12[] =
{
	0b10000000000000000000000000001000,
	GPIO32_END
};

gpio_sequence gpio13[] =
{
	0b10000000000000000000000000001000,
	GPIO32_END
};

gpio_sequence gpio14[] =
{
	0b10000000000000000000000000001000,
	GPIO32_END
};

gpio_sequence gpio15[] =
{
	0b10000000000000000000000000001000,
	GPIO32_END
};

gpio_sequence gpio16[] =
{
	1<<31|1<<13|1<<12|1<<11|1<<10|1<<9|1<<8|1<<3|1<<2,
	1<<31|1<<13|1<<12|1<<11|1<<10|1<<9|1<<7|1<<4|1<<3,
	1<<31|1<<13|1<<12|1<<11|1<<10|1<<8|1<<7|1<<6|1<<4, // !?
	1<<31|1<<13|1<<12|1<<11|1<<9|1<<8|1<<7|1<<6|1<<5,
	1<<31|1<<13|1<<12|1<<10|1<<9|1<<8|1<<7|1<<6|1<<4, // !?
	1<<31|1<<13|1<<11|1<<10|1<<9|1<<8|1<<7|1<<4|1<<3,
	1<<31|1<<12|1<<11|1<<10|1<<9|1<<8|1<<7|1<<3|1<<2,
	GPIO32_END
};

#define GPIO_SEQUENCE_PRE_NUMBER 16

/* Register for GPIO Sequences */
gpio_sequence* gpio_sequence_pre_table[GPIO_SEQUENCE_PRE_NUMBER] = {
	gpio1,
	gpio2,
	gpio3,
	gpio4,
	gpio5,
	gpio6,
	gpio7,
	gpio8,
	gpio9,
	gpio10,
	gpio11,
	gpio12,
	gpio13,
	gpio14,
	gpio15,
	gpio16
};

/* Register for Index of Tables */
uint32 gpio_sequence_pre_table_index[GPIO_SEQUENCE_PRE_NUMBER] = {
	1,
	2,
	3,
	4,
	5,
	6,
	7,
	8,
	9,
	10,
	11,
	12,
	13,
	14,
	15,
	16
};

gpio_sequence** gpio_sequence_table;
uint32* gpiolen_table;
uint32 timer_count_multiplier;

int32 _user_start()
{
	/* Local Variables */
	uint32 detect_parallel = 0;
	uint32 table_index;
	uchar8 result;
	uchar8 playing_signal;

	/* Initialization of Global Variables */
	gpio_sequence_table = (gpio_sequence**)heap32_malloc( 128 ); // 128 Words = 512 Bytes
	gpiolen_table = (uint32*)heap32_malloc( 128 ); // 128 Words = 512 Bytes
	for ( uint32 i = 0; i < GPIO_SEQUENCE_PRE_NUMBER; i++ ) {
		table_index = gpio_sequence_pre_table_index[i];
		// To Get Proper Latency, Get Lengths in Advance
		gpio_sequence_table[table_index] = gpio_sequence_pre_table[i];
		gpiolen_table[table_index] = pwm32_pwmlen( gpio_sequence_pre_table[i] );
	}
	timer_count_multiplier = TIMER_COUNT_MULTIPLIER_DEFAULT;

	while ( true ) {
		/* Detect Falling Edge of GPIO */
		if ( _gpio_detect( 27 ) ) {
			detect_parallel = _load_32( _gpio_base|_gpio_gpeds0 );
			_store_32( _gpio_base|_gpio_gpeds0, detect_parallel );
			detect_parallel = ((detect_parallel >> 22) & 0b11111) | 0x80000000; // Set Outstanding Flag
		}

		/**
		 * Detecting rising edge of gpio is sticky, and is cleared by falling edge of GPIO 27.
		 * So, physical all high is needed to act as doing nothing or its equivalent.
		 * 0x1F = 0b11111 (31) is physical all high in default. Command 31 is used as stopping sound.
		 */
		if ( detect_parallel ) { // If Any Non Zero Including Outstanding Flag
			_gpiotoggle( 15, _GPIOTOGGLE_SWAP ); // Busy Toggle
			detect_parallel &= 0x7F; // 0-127
			if ( detect_parallel == 0b11111 ) { // 0b11111 (31)
				GPIO32_LANE = 0;
				_gpioclear( GPIO_MASK_LANE0, 0 );
			} else if ( detect_parallel == 0b11110 ) { // 0b11110 (30)
				/* Beat Down */
				timer_count_multiplier++;
				if ( timer_count_multiplier > TIMER_COUNT_MULTIPLIER_MAXLIMIT ) timer_count_multiplier = TIMER_COUNT_MULTIPLIER_MAXLIMIT;
				_armtimer_reload( (TIMER_COUNT_MULTIPLICAND * timer_count_multiplier) - 1 );
			} else if ( detect_parallel == 0b11101 ) { // 0b11101 (29)
				/* Beat Up */
				timer_count_multiplier--;
				if ( timer_count_multiplier < TIMER_COUNT_MULTIPLIER_MINLIMIT ) timer_count_multiplier = TIMER_COUNT_MULTIPLIER_MINLIMIT;
				_armtimer_reload( (TIMER_COUNT_MULTIPLICAND * timer_count_multiplier) - 1 );
			} else if ( detect_parallel > 0 ) { // 1-15
				// PWM 0 Loop
				GPIO32_LANE = 0;
				_gpioset( gpio_sequence_table[detect_parallel], gpiolen_table[detect_parallel], 0, -1 );
			} // Do Nothing at 0 for Preventing Chattering
			detect_parallel = 0;
		}

		/* Detect Rising Edge of GPIO */
		if ( _gpio_detect( 17 ) ) {
			GPIO32_LANE = 0;
			result = _gpioplay( GPIO_MASK_LANE0 );
			if ( result == 0 ) { // Playing
				playing_signal = _GPIOTOGGLE_HIGH;
			} else { // Not Playing
				playing_signal = _GPIOTOGGLE_LOW;
			}
			_gpiotoggle( 16, playing_signal );
		}
	}
	return EXIT_SUCCESS;
}
