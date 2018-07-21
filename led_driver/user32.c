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
#define timer_count_multiplier_default  6
#define timer_count_multiplier_minlimit 3
#define timer_count_multiplier_maxlimit 6000

/**
 * In default, there is a 1000Hz synchronization clock (it's a half of 2000Hz on Arm Timer beacause of toggling).
 * Arm Timer sets 120000Hz as clock.
 * 60 is divisor (timer_count_multiplicand * timer_count_multiplier_defualt), i.e., 120000 / 60 / 2 equals 1000.
 * The Maximum beat (120000 / (timer_count_multiplicand * timer_count_multiplier_minlimit) / 2) is 2000Hz.
 * The minimum beat (120000 / (timer_count_multiplicand * timer_count_multiplier_maxlimit) / 2) is 1Hz.
 */

gpio_sequence gpio1[] =
{
	GPIO32_END
};

gpio_sequence gpio2[] =
{
	GPIO32_END
};

gpio_sequence gpio3[] =
{
	GPIO32_END
};

gpio_sequence gpio4[] =
{
	GPIO32_END
};

gpio_sequence gpio5[] =
{
	GPIO32_END
};

gpio_sequence gpio6[] =
{
	GPIO32_END
};

gpio_sequence gpio7[] =
{
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
	GPIO32_END
};

gpio_sequence gpio10[] =
{
	GPIO32_END
};

gpio_sequence gpio11[] =
{
	GPIO32_END
};

gpio_sequence gpio12[] =
{
	GPIO32_END
};

gpio_sequence gpio13[] =
{
	GPIO32_END
};

gpio_sequence gpio14[] =
{
	GPIO32_END
};

gpio_sequence gpio15[] =
{
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

gpio_sequence gpio17[] =
{
	GPIO32_END
};

int32 _user_start()
{

	uint32 timer_count_multiplier = timer_count_multiplier_default;
	uint32 detect_parallel;

	while ( true ) {
		if ( _gpio_detect( 27 ) ) {
			_gpioplay( 0x003FFFFC );
			detect_parallel = _load_32( _gpio_base|_gpio_gpeds0 );
			_store_32( _gpio_base|_gpio_gpeds0, detect_parallel );

//print32_debug( detect_parallel, 100, 100 );

			/* GPIO22-26 as Bit[26:22] */
			// 0b00001 (1)
			if ( detect_parallel == 0b00001<<22 ) {
				//_gpioset( gpio1, gpio32_gpiolen( gpio1 ) , 0, -1 );
				_gpioclear( 0x003FFFFC, 1 );

			// 0b00010 (2)
			} else if ( detect_parallel == 0b00010<<22 ) {
				//_gpioset( gpio2, gpio32_gpiolen( gpio2 ) , 0, -1 );
				/* Beat Up */
				timer_count_multiplier--;
				if ( timer_count_multiplier < timer_count_multiplier_minlimit ) timer_count_multiplier = timer_count_multiplier_minlimit;
				_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );


			// 0b00011 (3)
			} else if ( detect_parallel == 0b00011<<22 ) {
				_gpioset( gpio3, gpio32_gpiolen( gpio3 ) , 0, -1 );

			// 0b00100 (4)
			} else if ( detect_parallel == 0b00100<<22 ) {
				//_gpioset( gpio4, gpio32_gpiolen( gpio4 ) , 0, -1 );
				/* Beat Down */
				timer_count_multiplier++;
				if ( timer_count_multiplier > timer_count_multiplier_maxlimit ) timer_count_multiplier = timer_count_multiplier_maxlimit;
				_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );

			// 0b00101 (5)
			} else if ( detect_parallel == 0b00101<<22 ) {
				_gpioset( gpio5, gpio32_gpiolen( gpio5 ) , 0, -1 );

			// 0b00110 (6)
			} else if ( detect_parallel == 0b00110<<22 ) {
				_gpioset( gpio6, gpio32_gpiolen( gpio6 ) , 0, -1 );

			// 0b00111 (7)
			} else if ( detect_parallel == 0b00111<<22 ) {
				_gpioset( gpio7, gpio32_gpiolen( gpio7 ) , 0, -1 );

			// 0b01000 (8)
			} else if ( detect_parallel == 0b01000<<22 ) {
				_gpioset( gpio8, gpio32_gpiolen( gpio8 ) , 0, -1 );

			// 0b10000 (16)
			} else if ( detect_parallel == 0b10000<<22 ) {
				_gpioset( gpio16, gpio32_gpiolen( gpio16 ) , 0, -1 );

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
				_gpioclear( 0x003FFFFC, 0 );

			}
		}
	}

	return EXIT_SUCCESS;
}
