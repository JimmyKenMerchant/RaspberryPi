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

#define timer_count_multiplicand        100
#define timer_count_multiplier_default  48
#define timer_count_multiplier_minlimit 12
#define timer_count_multiplier_maxlimit 96

/**
 * In default, there is a 25Hz synchronization clock (it's a half of 50Hz on Arm Timer beacause of toggling).
 * Arm Timer sets 240000Hz as clock.
 * 4800 is divisor (timer_count_multiplicand * timer_count_multiplier_defualt), i.e., 240000Hz / 4800 / 2 equals 25Hz.
 * The Maximum beat (240000 / (timer_count_multiplicand * timer_count_multiplier_minlimit) / 2) is 100Hz.
 * The minimum beat (240000 / (timer_count_multiplicand * timer_count_multiplier_maxlimit) / 2) is 12.5Hz.
 *
 * If you want particular BPM for a track, use _armtimer_reload and/or _armtimer prior to _soundset.
 */

pwm_sequence pwm1[] =
{
	1<<31|200,
	PWM32_END
};

pwm_sequence pwm2[] =
{
	1<<31|200,
	PWM32_END
};

pwm_sequence pwm3[] =
{
	1<<31|200,
	PWM32_END
};

pwm_sequence pwm4[] =
{
	1<<31|200,
	PWM32_END
};

pwm_sequence pwm5[] =
{
	1<<31|200,
	PWM32_END
};

pwm_sequence pwm6[] =
{
	1<<31|200,
	PWM32_END
};

pwm_sequence pwm7[] =
{
	1<<31|200,
	PWM32_END
};

pwm_sequence pwm8[] =
{
	1<<31|200,
	1<<31|0,
	1<<31|200,
	1<<31|100,
	1<<31|0,
	1<<31|200,
	1<<31|190,
	1<<31|180,
	1<<31|170,
	1<<31|160,
	1<<31|150,
	1<<31|140,
	1<<31|130,
	1<<31|120,
	1<<31|110,
	1<<31|100,
	1<<31|90,
	1<<31|80,
	1<<31|0,
	PWM32_END
};

pwm_sequence pwm9[] =
{
	1<<31|200,
	PWM32_END
};

pwm_sequence pwm10[] =
{
	1<<31|200,
	PWM32_END
};

pwm_sequence pwm11[] =
{
	1<<31|200,
	PWM32_END
};

pwm_sequence pwm12[] =
{
	1<<31|200,
	PWM32_END
};

pwm_sequence pwm13[] =
{
	1<<31|200,
	PWM32_END
};

pwm_sequence pwm14[] =
{
	1<<31|200,
	PWM32_END
};

pwm_sequence pwm15[] =
{
	1<<31|200,
	PWM32_END
};

pwm_sequence pwm16[] =
{
	1<<31|200,
	1<<31|190,
	1<<31|180,
	1<<31|170,
	1<<31|160,
	1<<31|150,
	1<<31|140,
	1<<31|130,
	1<<31|120,
	1<<31|110,
	1<<31|100,
	1<<31|110,
	1<<31|120,
	1<<31|130,
	1<<31|140,
	1<<31|150,
	1<<31|160,
	1<<31|170,
	1<<31|180,
	1<<31|190,
	1<<31|200,
	1<<31|200,
	1<<31|100,
	1<<31|0,
	1<<31|200,
	1<<31|0,
	PWM32_END
};

int32 _user_start()
{

	uint32 timer_count_multiplier = timer_count_multiplier_default;
	uint32 detect_parallel;
	uchar8 result;
	uchar8 playing_signal;

	// To Get Proper Latency, Get Lengths in Advance
	//uint32 pwmlen1 = pwm32_pwmlen( pwm1 );
	//uint32 pwmlen2 = pwm32_pwmlen( pwm2 );
	uint32 pwmlen3 = pwm32_pwmlen( pwm3 );
	//uint32 pwmlen4 = pwm32_pwmlen( pwm4 );
	uint32 pwmlen5 = pwm32_pwmlen( pwm5 );
	uint32 pwmlen6 = pwm32_pwmlen( pwm6 );
	uint32 pwmlen7 = pwm32_pwmlen( pwm7 );
	uint32 pwmlen8 = pwm32_pwmlen( pwm8 );
	//uint32 pwmlen9 = pwm32_pwmlen( pwm9 );
	//uint32 pwmlen10 = pwm32_pwmlen( pwm10 );
	//uint32 pwmlen11 = pwm32_pwmlen( pwm11 );
	//uint32 pwmlen12 = pwm32_pwmlen( pwm12 );
	//uint32 pwmlen13 = pwm32_pwmlen( pwm13 );
	//uint32 pwmlen14 = pwm32_pwmlen( pwm14 );
	//uint32 pwmlen15 = pwm32_pwmlen( pwm15 );
	uint32 pwmlen16 = pwm32_pwmlen( pwm16 );

	while ( true ) {
		if ( _gpio_detect( 27 ) ) {

			detect_parallel = _load_32( _gpio_base|_gpio_gpeds0 );
			_store_32( _gpio_base|_gpio_gpeds0, detect_parallel );

			/* GPIO22-26 as Bit[26:22] */
			// 0b00001 (1)
			if ( detect_parallel == 0b00001<<22 ) {
				//_pwmselect( 0 );
				//_pwmset( pwm1, pwmlen1, 0, -1 );
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

			// 0b00010 (2)
			} else if ( detect_parallel == 0b00010<<22 ) {
				//_pwmselect( 0 );
				//_pwmset( pwm2, pwmlen2, 0, -1 );
				/* Beat Up */
				timer_count_multiplier--;
				if ( timer_count_multiplier < timer_count_multiplier_minlimit ) timer_count_multiplier = timer_count_multiplier_minlimit;
				_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );


			// 0b00011 (3)
			} else if ( detect_parallel == 0b00011<<22 ) {
				_pwmselect( 0 );
				_pwmset( pwm3, pwmlen3, 0, -1 );

			// 0b00100 (4)
			} else if ( detect_parallel == 0b00100<<22 ) {
				//_pwmselect( 0 );
				//_pwmset( pwm4, pwmlen4, 0, -1 );
				/* Beat Down */
				timer_count_multiplier++;
				if ( timer_count_multiplier > timer_count_multiplier_maxlimit ) timer_count_multiplier = timer_count_multiplier_maxlimit;
				_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );

			// 0b00101 (5)
			} else if ( detect_parallel == 0b00101<<22 ) {
				_pwmselect( 0 );
				_pwmset( pwm5, pwmlen5, 0, -1 );

			// 0b00110 (6)
			} else if ( detect_parallel == 0b00110<<22 ) {
				_pwmselect( 0 );
				_pwmset( pwm6, pwmlen6, 0, -1 );

			// 0b00111 (7)
			} else if ( detect_parallel == 0b00111<<22 ) {
				_pwmselect( 0 );
				_pwmset( pwm7, pwmlen7, 0, -1 );

			// 0b01000 (8)
			} else if ( detect_parallel == 0b01000<<22 ) {
				_pwmselect( 0 );
				_pwmset( pwm8, pwmlen8, 0, -1 );

			// 0b01001 (9)
			} else if ( detect_parallel == 0b01001<<22 ) {
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

			// 0b01010 (10)
			} else if ( detect_parallel == 0b01010<<22 ) {
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

			// 0b01011 (11)
			} else if ( detect_parallel == 0b01011<<22 ) {
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

			// 0b01100 (12)
			} else if ( detect_parallel == 0b01100<<22 ) {
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

			// 0b01101 (13)
			} else if ( detect_parallel == 0b01101<<22 ) {
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

			// 0b01110 (14)
			} else if ( detect_parallel == 0b01110<<22 ) {
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

			// 0b01111 (15)
			} else if ( detect_parallel == 0b01111<<22 ) {
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

			// 0b10000 (16)
			} else if ( detect_parallel == 0b10000<<22 ) {
				_pwmselect( 1 );
				_pwmset( pwm16, pwmlen16, 0, -1 );

			// 0b10001 (17)
			} else if ( detect_parallel == 0b10001<<22 ) {
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

			// 0b10010 (18)
			} else if ( detect_parallel == 0b10010<<22 ) {
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

			// 0b10011 (19)
			} else if ( detect_parallel == 0b10011<<22 ) {
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

			// 0b10100 (20)
			} else if ( detect_parallel == 0b10100<<22 ) {
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

			// 0b10101 (21)
			} else if ( detect_parallel == 0b10101<<22 ) {
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

			// 0b10110 (22)
			} else if ( detect_parallel == 0b10110<<22 ) {
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

			// 0b10111 (23)
			} else if ( detect_parallel == 0b10111<<22 ) {
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

			// 0b11000 (24)
			} else if ( detect_parallel == 0b11000<<22 ) {
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

			// 0b11001 (25)
			} else if ( detect_parallel == 0b11001<<22 ) {
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );
			// 0b11010 (26)
			} else if ( detect_parallel == 0b11010<<22 ) {
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

			// 0b11011 (27)
			} else if ( detect_parallel == 0b11011<<22 ) {
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

			// 0b11100 (28)
			} else if ( detect_parallel == 0b11100<<22 ) {
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

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
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

			}

			_pwmselect( 0 );
			result = _pwmplay();
			if ( result == 0 ) { // Playing
				playing_signal = _GPIOTOGGLE_HIGH;
			} else { // Not Playing
				playing_signal = _GPIOTOGGLE_LOW;
			}
			_gpiotoggle( 16, playing_signal );

			_pwmselect( 1 );
			result =_pwmplay();
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
