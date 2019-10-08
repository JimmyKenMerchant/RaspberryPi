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
 * 4. If you want to stop the GPIO sequence, use `_gpioclear`. Constant 1 of its argument will stay current status of GPIO.
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

#define timer_count_multiplicand        10
#define timer_count_multiplier_default  12
#define timer_count_multiplier_minlimit 6
#define timer_count_multiplier_maxlimit 12000

/**
 * In default, there is a 1000Hz synchronization clock (it's a half of 2000Hz on Arm Timer beacause of toggling).
 * Arm Timer sets 240000Hz as clock.
 * 120 is divisor (timer_count_multiplicand * timer_count_multiplier_defualt), i.e., 240000Hz / 120 / 2 equals 1000Hz.
 * The Maximum beat (240000 / (timer_count_multiplicand * timer_count_multiplier_minlimit) / 2) is 2000Hz.
 * The minimum beat (240000 / (timer_count_multiplicand * timer_count_multiplier_maxlimit) / 2) is 1Hz.
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

int32 _user_start()
{
	uint32 timer_count_multiplier = timer_count_multiplier_default;
	uint32 detect_parallel = 0;
	uchar8 result;
	uchar8 playing_signal;

	// To Get Proper Latency, Get Lengths in Advance
	uint32 gpiolen1 = gpio32_gpiolen( gpio1 );
	uint32 gpiolen2 = gpio32_gpiolen( gpio2 );
	uint32 gpiolen3 = gpio32_gpiolen( gpio3 );
	uint32 gpiolen4 = gpio32_gpiolen( gpio4 );
	uint32 gpiolen5 = gpio32_gpiolen( gpio5 );
	uint32 gpiolen6 = gpio32_gpiolen( gpio6 );
	uint32 gpiolen7 = gpio32_gpiolen( gpio7 );
	uint32 gpiolen8 = gpio32_gpiolen( gpio8 );
	//uint32 gpiolen9 = gpio32_gpiolen( gpio9 );
	//uint32 gpiolen10 = gpio32_gpiolen( gpio10 );
	//uint32 gpiolen11 = gpio32_gpiolen( gpio11 );
	//uint32 gpiolen12 = gpio32_gpiolen( gpio12 );
	//uint32 gpiolen13 = gpio32_gpiolen( gpio13 );
	//uint32 gpiolen14 = gpio32_gpiolen( gpio14 );
	//uint32 gpiolen15 = gpio32_gpiolen( gpio15 );
	uint32 gpiolen16 = gpio32_gpiolen( gpio16 );

	while ( true ) {

		/* Detect Falling Edge of GPIO */
		if ( _gpio_detect( 27 ) ) {
			detect_parallel = _load_32( _gpio_base|_gpio_gpeds0 );
			_store_32( _gpio_base|_gpio_gpeds0, detect_parallel );
		}

		/* If Any Non Zero */
		if ( detect_parallel ) {
//print32_debug( detect_parallel, 100, 100 );

			/* GPIO22-26 as Bit[26:22] */
			// 0b00001 (1)
			if ( detect_parallel == 0b00001<<22 ) {
				_gpioset( gpio1, gpiolen1, 0, -1 );
				//_gpioclear( 0x003FFFFC, 1 );

			// 0b00010 (2)
			} else if ( detect_parallel == 0b00010<<22 ) {
				_gpioset( gpio2, gpiolen2, 0, -1 );
				/* Beat Up */
				//timer_count_multiplier--;
				//if ( timer_count_multiplier < timer_count_multiplier_minlimit ) timer_count_multiplier = timer_count_multiplier_minlimit;
				//_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );


			// 0b00011 (3)
			} else if ( detect_parallel == 0b00011<<22 ) {
				_gpioset( gpio3, gpiolen3, 0, -1 );

			// 0b00100 (4)
			} else if ( detect_parallel == 0b00100<<22 ) {
				_gpioset( gpio4, gpiolen4, 0, -1 );
				/* Beat Down */
				//timer_count_multiplier++;
				//if ( timer_count_multiplier > timer_count_multiplier_maxlimit ) timer_count_multiplier = timer_count_multiplier_maxlimit;
				//_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );

			// 0b00101 (5)
			} else if ( detect_parallel == 0b00101<<22 ) {
				_gpioset( gpio5, gpiolen5, 0, -1 );

			// 0b00110 (6)
			} else if ( detect_parallel == 0b00110<<22 ) {
				_gpioset( gpio6, gpiolen6, 0, -1 );

			// 0b00111 (7)
			} else if ( detect_parallel == 0b00111<<22 ) {
				_gpioset( gpio7, gpiolen7, 0, -1 );

			// 0b01000 (8)
			} else if ( detect_parallel == 0b01000<<22 ) {
				_gpioset( gpio8, gpiolen8, 0, -1 );

			// 0b01001 (9)
			} else if ( detect_parallel == 0b01001<<22 ) {
				_gpioclear( 0x003CFFFC, 0 );

			// 0b01010 (10)
			} else if ( detect_parallel == 0b01010<<22 ) {
				_gpioclear( 0x003CFFFC, 0 );

			// 0b01011 (11)
			} else if ( detect_parallel == 0b01011<<22 ) {
				_gpioclear( 0x003CFFFC, 0 );

			// 0b01100 (12)
			} else if ( detect_parallel == 0b01100<<22 ) {
				_gpioclear( 0x003CFFFC, 0 );

			// 0b01101 (13)
			} else if ( detect_parallel == 0b01101<<22 ) {
				_gpioclear( 0x003CFFFC, 0 );

			// 0b01110 (14)
			} else if ( detect_parallel == 0b01110<<22 ) {
				_gpioclear( 0x003CFFFC, 0 );

			// 0b01111 (15)
			} else if ( detect_parallel == 0b01111<<22 ) {
				_gpioclear( 0x003CFFFC, 0 );

			// 0b10000 (16)
			} else if ( detect_parallel == 0b10000<<22 ) {
				_gpioset( gpio16, gpiolen16, 0, -1 );

			// 0b10001 (17)
			} else if ( detect_parallel == 0b10001<<22 ) {
				_gpioclear( 0x003CFFFC, 0 );

			// 0b10010 (18)
			} else if ( detect_parallel == 0b10010<<22 ) {
				_gpioclear( 0x003CFFFC, 0 );

			// 0b10011 (19)
			} else if ( detect_parallel == 0b10011<<22 ) {
				_gpioclear( 0x003CFFFC, 0 );

			// 0b10100 (20)
			} else if ( detect_parallel == 0b10100<<22 ) {
				_gpioclear( 0x003CFFFC, 0 );

			// 0b10101 (21)
			} else if ( detect_parallel == 0b10101<<22 ) {
				_gpioclear( 0x003CFFFC, 0 );

			// 0b10110 (22)
			} else if ( detect_parallel == 0b10110<<22 ) {
				_gpioclear( 0x003CFFFC, 0 );

			// 0b10111 (23)
			} else if ( detect_parallel == 0b10111<<22 ) {
				_gpioclear( 0x003CFFFC, 0 );

			// 0b11000 (24)
			} else if ( detect_parallel == 0b11000<<22 ) {
				_gpioclear( 0x003CFFFC, 0 );

			// 0b11001 (25)
			} else if ( detect_parallel == 0b11001<<22 ) {
				_gpioclear( 0x003CFFFC, 0 );

			// 0b11010 (26)
			} else if ( detect_parallel == 0b11010<<22 ) {
				_gpioclear( 0x003CFFFC, 0 );

			// 0b11011 (27)
			} else if ( detect_parallel == 0b11011<<22 ) {
				_gpioclear( 0x003CFFFC, 0 );

			// 0b11100 (28)
			} else if ( detect_parallel == 0b11100<<22 ) {
				_gpioclear( 0x003CFFFC, 0 );

			// 0b11101 (29)
			} else if ( detect_parallel == 0b11101<<22 ) {
				/* Beat Up */
				timer_count_multiplier--;
				if ( timer_count_multiplier < timer_count_multiplier_minlimit ) timer_count_multiplier = timer_count_multiplier_minlimit;
				_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );

			// 0b11110 (30)
			} else if ( detect_parallel == 0b11110<<22 ) {
				/* Beat Down */
				timer_count_multiplier++;
				if ( timer_count_multiplier > timer_count_multiplier_maxlimit ) timer_count_multiplier = timer_count_multiplier_maxlimit;
				_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );

			// 0b11111 (31)
			} else if ( detect_parallel == 0b11111<<22 ) {
				_gpioclear( 0x003CFFFC, 0 );

			}
			detect_parallel = 0;
		}

		/* Detect Rising Edge of GPIO */
		if ( _gpio_detect( 17 ) ) {
			result = _gpioplay( 0x003CFFFC );
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
