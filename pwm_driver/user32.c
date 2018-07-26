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
#define timer_count_multiplier_default  24
#define timer_count_multiplier_minlimit 6
#define timer_count_multiplier_maxlimit 48

/**
 * In default, there is a 25Hz synchronization clock (it's a half of 25Hz on Arm Timer beacause of toggling).
 * Arm Timer sets 120000Hz as clock.
 * 2400 is divisor (timer_count_multiplicand * timer_count_multiplier_defualt), i.e., 120000 / 2400 / 2 equals 25.
 * The Maximum beat (120000 / (timer_count_multiplicand * timer_count_multiplier_minlimit) / 2) is 100Hz.
 * The minimum beat (120000 / (timer_count_multiplicand * timer_count_multiplier_maxlimit) / 2) is 12.5Hz.
 */

pwm_sequence pwm1[] =
{
	PWM32_END
};

pwm_sequence pwm2[] =
{
	PWM32_END
};

pwm_sequence pwm3[] =
{
	PWM32_END
};

pwm_sequence pwm4[] =
{
	PWM32_END
};

pwm_sequence pwm5[] =
{
	PWM32_END
};

pwm_sequence pwm6[] =
{
	PWM32_END
};

pwm_sequence pwm7[] =
{
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
	1<<31|150,
	1<<31|100,
	1<<31|50,
	1<<31|0,
	PWM32_END
};

pwm_sequence pwm9[] =
{
	PWM32_END
};

pwm_sequence pwm10[] =
{
	PWM32_END
};

pwm_sequence pwm11[] =
{
	PWM32_END
};

pwm_sequence pwm12[] =
{
	PWM32_END
};

pwm_sequence pwm13[] =
{
	PWM32_END
};

pwm_sequence pwm14[] =
{
	PWM32_END
};

pwm_sequence pwm15[] =
{
	PWM32_END
};

pwm_sequence pwm16[] =
{
	1<<31|200,
	1<<31|150,
	1<<31|100,
	1<<31|50,
	1<<31|0,
	1<<31|200,
	1<<31|100,
	1<<31|0,
	1<<31|200,
	1<<31|0,
	PWM32_END
};

pwm_sequence pwm17[] =
{
	PWM32_END
};

int32 _user_start()
{

	uint32 timer_count_multiplier = timer_count_multiplier_default;
	uint32 detect_parallel;

	while ( true ) {
		if ( _gpio_detect( 27 ) ) {
			_pwmselect( 0 );
			_pwmplay();
			_pwmselect( 1 );
			_pwmplay();
			detect_parallel = _load_32( _gpio_base|_gpio_gpeds0 );
			_store_32( _gpio_base|_gpio_gpeds0, detect_parallel );

			/* GPIO22-26 as Bit[26:22] */
			// 0b00001 (1)
			if ( detect_parallel == 0b00001<<22 ) {
				//_pwmset( pwm1, pwm32_pwmlen( pwm1 ) , 0, -1 );
				_pwmselect( 0 );
				_pwmclear( 0 );
				_pwmselect( 1 );
				_pwmclear( 0 );

			// 0b00010 (2)
			} else if ( detect_parallel == 0b00010<<22 ) {
				//_pwmset( pwm2, pwm32_pwmlen( pwm2 ) , 0, -1 );
				/* Beat Up */
				timer_count_multiplier--;
				if ( timer_count_multiplier < timer_count_multiplier_minlimit ) timer_count_multiplier = timer_count_multiplier_minlimit;
				_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );


			// 0b00011 (3)
			} else if ( detect_parallel == 0b00011<<22 ) {
				_pwmset( pwm3, pwm32_pwmlen( pwm3 ) , 0, -1 );

			// 0b00100 (4)
			} else if ( detect_parallel == 0b00100<<22 ) {
				//_pwmset( pwm4, pwm32_pwmlen( pwm4 ) , 0, -1 );
				/* Beat Down */
				timer_count_multiplier++;
				if ( timer_count_multiplier > timer_count_multiplier_maxlimit ) timer_count_multiplier = timer_count_multiplier_maxlimit;
				_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );

			// 0b00101 (5)
			} else if ( detect_parallel == 0b00101<<22 ) {
				_pwmset( pwm5, pwm32_pwmlen( pwm5 ) , 0, -1 );

			// 0b00110 (6)
			} else if ( detect_parallel == 0b00110<<22 ) {
				_pwmset( pwm6, pwm32_pwmlen( pwm6 ) , 0, -1 );

			// 0b00111 (7)
			} else if ( detect_parallel == 0b00111<<22 ) {
				_pwmset( pwm7, pwm32_pwmlen( pwm7 ) , 0, -1 );

			// 0b01000 (8)
			} else if ( detect_parallel == 0b01000<<22 ) {
				_pwmselect( 0 );
				_pwmset( pwm8, pwm32_pwmlen( pwm8 ) , 0, -1 );

			// 0b10000 (16)
			} else if ( detect_parallel == 0b10000<<22 ) {
				_pwmselect( 1 );
				_pwmset( pwm16, pwm32_pwmlen( pwm16 ) , 0, -1 );

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
		}
	}

	return EXIT_SUCCESS;
}
