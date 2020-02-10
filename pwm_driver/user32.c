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
 * 1. Place `pwm32_pwmplay` on FIQ/IRQ Handler which will be triggered with any timer.
 * 2. Select Channel by `_pwmselect`.
 * 3. Place `_pwmset` with needed arguments in `user32.c`.
 * 4. PWM sequence automatically runs with the assigned values.
 * 5. If you want to stop the PWM sequence, use `_pwmclear`. Constant 1 of its argument will stay current status of PWM.
 */

/**
 * PWM sequence is made of 32-bit Blocks. One Block means one beat.
 * Bit[30:0]: Data 0 to 2,147,483,647
 * Bit[31]: Always One
 * Note that if a beat is all zero, this beat means the end of sequence.
 */

#include "system32.h"
#include "system32.c"

/**
 * Global Variables and Constants
 * to Prevent Incorrect Compilation in optimization,
 * Variables (except these which have only one value) used over the iteration of the loop are defined as global variables.
 */

#define TIMER_COUNT_MULTIPLICAND        100
#define TIMER_COUNT_MULTIPLIER_DEFAULT  48
#define TIMER_COUNT_MULTIPLIER_MINLIMIT 12
#define TIMER_COUNT_MULTIPLIER_MAXLIMIT 96

/**
 * In default, there is a 25Hz synchronization clock (it's a half of 50Hz on Arm Timer beacause of toggling).
 * Arm Timer sets 240000Hz as clock.
 * 4800 is divisor (TIMER_COUNT_MULTIPLICAND * TIMER_COUNT_MULTIPLIER_DEFAULT), i.e., 240000Hz / 4800 / 2 equals 25Hz.
 * The Maximum beat (240000 / (TIMER_COUNT_MULTIPLICAND * TIMER_COUNT_MULTIPLIER_MINLIMIT) / 2) is 100Hz.
 * The minimum beat (240000 / (TIMER_COUNT_MULTIPLICAND * TIMER_COUNT_MULTIPLIER_MAXLIMIT) / 2) is 12.5Hz.
 *
 * If you want particular BPM for a track, use _armtimer_reload and/or _armtimer prior to _soundset.
 */

pwm_sequence pwm1[] =
{
	1<<31|0,
	PWM32_END
};

pwm_sequence pwm2[] =
{
	1<<31|16,
	PWM32_END
};

pwm_sequence pwm3[] =
{
	1<<31|1,
	PWM32_END
};

pwm_sequence pwm4[] =
{
	1<<31|8,
	PWM32_END
};

pwm_sequence pwm5[] =
{
	1<<31|2,
	PWM32_END
};

pwm_sequence pwm6[] =
{
	1<<31|3,
	PWM32_END
};

pwm_sequence pwm7[] =
{
	1<<31|4,
	PWM32_END
};

pwm_sequence pwm8[] =
{
	_50(1<<31|20)
	_50(1<<31|21)
	_50(1<<31|22)
	_50(1<<31|23)
	_50(1<<31|24)
	_50(1<<31|25)
	_50(1<<31|26)
	_50(1<<31|27)
	_50(1<<31|28)
	_50(1<<31|29)
	_50(1<<31|30)
	_50(1<<31|31)
	_50(1<<31|32)
	PWM32_END
};

pwm_sequence pwm9[] =
{
	1<<31|1,
	PWM32_END
};

pwm_sequence pwm10[] =
{
	1<<31|2,
	PWM32_END
};

pwm_sequence pwm11[] =
{
	1<<31|2,
	PWM32_END
};

pwm_sequence pwm12[] =
{
	1<<31|2,
	PWM32_END
};

pwm_sequence pwm13[] =
{
	1<<31|2,
	PWM32_END
};

pwm_sequence pwm14[] =
{
	1<<31|2,
	PWM32_END
};

pwm_sequence pwm15[] =
{
	_50(1<<31|0)
	_50(1<<31|0)
	_50(1<<31|31)
	_50(1<<31|31)
	_50(1<<31|0)
	_50(1<<31|0)
	_50(1<<31|31)
	_50(1<<31|31)
	_50(1<<31|0)
	_50(1<<31|0)
	_50(1<<31|0)
	_50(1<<31|0)
	PWM32_END
};

pwm_sequence pwm16[] =
{
	1<<31|32,
	PWM32_END
};

#define PWM_SEQUENCE_PRE_NUMBER 7

/* Register for PWM Sequences */
pwm_sequence* pwm_sequence_pre_table[PWM_SEQUENCE_PRE_NUMBER] = {
	pwm3,
	pwm5,
	pwm6,
	pwm7,
	pwm8,
	pwm15,
	pwm16
};

/* Register for Index of Tables */
uint32 pwm_sequence_pre_table_index[PWM_SEQUENCE_PRE_NUMBER] = {
	3,
	5,
	6,
	7,
	8,
	15,
	16
};

pwm_sequence** pwm_sequence_table;
uint32* pwmlen_table;
uint32 timer_count_multiplier;

int32 _user_start() {
	/* Local Variables */
	uint32 detect_parallel = 0;
	uint32 table_index;
	uchar8 result;
	uchar8 playing_signal;

	/* Initialization of Global Variables */
	pwm_sequence_table = (pwm_sequence**)heap32_malloc( 128 ); // 128 Words = 512 Bytes
	pwmlen_table = (uint32*)heap32_malloc( 128 ); // 128 Words = 512 Bytes
	for ( uint32 i = 0; i < PWM_SEQUENCE_PRE_NUMBER; i++ ) {
		table_index = pwm_sequence_pre_table_index[i];
		// To Get Proper Latency, Get Lengths in Advance
		pwm_sequence_table[table_index] = pwm_sequence_pre_table[i];
		pwmlen_table[table_index] = pwm32_pwmlen( pwm_sequence_pre_table[i] );
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
			_gpiotoggle( 14, _GPIOTOGGLE_SWAP ); // Busy Toggle
			detect_parallel &= 0x7F; // 0-127
			if ( detect_parallel == 0b11111 ) { // 0b11111 (31)
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );
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
			} else if ( detect_parallel > 15 ) { // 16-28
				// PWM 1 Loop
				_pwmselect( 1 );
				_pwmset( pwm_sequence_table[detect_parallel], pwmlen_table[detect_parallel], 0, -1 );
			} else if ( detect_parallel > 0 ) { // 1-15
				// PWM 0 Loop
				_pwmselect( 0 );
				_pwmset( pwm_sequence_table[detect_parallel], pwmlen_table[detect_parallel], 0, -1 );
			} // Do Nothing at 0 for Preventing Chattering
			detect_parallel = 0;
		}

		/* Detect Rising Edge of GPIO */
		if ( _gpio_detect( 17 ) ) {
			_pwmselect( 0 );
			result = _pwmplay( False, False );
			if ( result == 0 ) { // Playing
				playing_signal = _GPIOTOGGLE_HIGH;
			} else { // Not Playing
				playing_signal = _GPIOTOGGLE_LOW;
			}
			_gpiotoggle( 16, playing_signal );

			_pwmselect( 1 );
			result =_pwmplay( False, False );
			if ( result == 0 ) { // Playing
				playing_signal = _GPIOTOGGLE_HIGH;
			} else { // Not Playing
				playing_signal = _GPIOTOGGLE_LOW;
			}
			_gpiotoggle( 21, playing_signal );
		}
	}
	return EXIT_SUCCESS;
}
