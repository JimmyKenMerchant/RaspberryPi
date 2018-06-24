/**
 * user32.c
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

#include "system32.h"
#include "system32.c"

#define timer_count_multiply        125
#define timer_count_factor_default  10
#define timer_count_factor_minlimit 5
#define timer_count_factor_maxlimit 40

/**
 * In Default, 48Hz Synchronization Clock
 * Max Beat is 96Hz, Min Beat is 12Hz
 */

synthe_code synthe1[] =
{
	0x00
};

synthe_code synthe2[] =
{
	0x00
};

synthe_code synthe3[] =
{
	0x00
};

synthe_code synthe4[] =
{
	0x00
};

synthe_code synthe5[] =
{
	0x00
};

synthe_code synthe6[] =
{
	0x00
};

synthe_code synthe7[] =
{
	0x00
};

synthe_code synthe8[] =
{
	_20LR(3ull<<48|60ull<<32|300ull<<16|2000ull,3ull<<48|60ull<<32|300ull<<16|2000ull)
	_20LR(3ull<<48|60ull<<32|300ull<<16|1000ull,3ull<<48|60ull<<32|300ull<<16|2000ull)
	_20LR(3ull<<48|60ull<<32|300ull<<16|500ull,3ull<<48|60ull<<32|300ull<<16|2000ull)
	_20LR(3ull<<48|60ull<<32|300ull<<16|250ull,3ull<<48|60ull<<32|300ull<<16|2000ull)
	_40LR(0ull<<48|1000ull<<32|300ull<<16|440ull,0ull<<48|2000ull<<32|300ull<<16|880ull)
	0x00
};

synthe_code synthe9[] =
{
	0x00
};

synthe_code synthe10[] =
{
	0x00
};

synthe_code synthe11[] =
{
	0x00
};

synthe_code synthe12[] =
{
	0x00
};

synthe_code synthe13[] =
{
	0x00
};

synthe_code synthe14[] =
{
	0x00
};

synthe_code synthe15[] =
{
	0x00
};

int32 _user_start()
{

	uchar8 timer_count_factor = timer_count_factor_default;
	uint32 detect_parallel;
	uint32 result;

	while ( true ) {
#ifdef __SOUND_I2S
		result = _synthewave_i2s();
#endif
#ifdef __SOUND_PWM
		result = _synthewave_pwm();
#endif
#ifdef __SOUND_JACK
		result = _synthewave_pwm();
#endif
print32_debug( result, 100, 100 );
		if ( _gpio_detect( 27 ) ) {
			_syntheplay();
			detect_parallel = _load_32( _gpio_base|_gpio_gpeds0 );
			_store_32( _gpio_base|_gpio_gpeds0, detect_parallel );

//print32_debug( detect_parallel, 100, 100 );

			/* GPIO22-26 as Bit[26:22] */
			// 0b00001 (1)
			if ( detect_parallel == 0b00001<<22 ) {
				//_syntheset( synthe1, sts32_synthelen( synthe1 )/2, 0, -1 );
				_syntheclear();

			// 0b00010 (2)
			} else if ( detect_parallel == 0b00010<<22 ) {
				//_syntheset( synthe2, sts32_synthelen( synthe2 )/2, 0, -1 );
				/* Beat Up */
				timer_count_factor--;
				if ( timer_count_factor < timer_count_factor_minlimit ) timer_count_factor = timer_count_factor_minlimit;
				_armtimer_reload( (timer_count_multiply * timer_count_factor) - 1 );


			// 0b00011 (3)
			} else if ( detect_parallel == 0b00011<<22 ) {
				_syntheset( synthe3, sts32_synthelen( synthe3 )/2, 0, -1 );

			// 0b00100 (4)
			} else if ( detect_parallel == 0b00100<<22 ) {
				//_syntheset( synthe4, sts32_synthelen( synthe4 )/2, 0, -1 );
				/* Beat Down */
				timer_count_factor++;
				if ( timer_count_factor > timer_count_factor_maxlimit ) timer_count_factor = timer_count_factor_maxlimit;
				_armtimer_reload( (timer_count_multiply * timer_count_factor) - 1 );

			// 0b00101 (5)
			} else if ( detect_parallel == 0b00101<<22 ) {
				_syntheset( synthe5, sts32_synthelen( synthe5 )/2, 0, -1 );

			// 0b00110 (6)
			} else if ( detect_parallel == 0b00110<<22 ) {
				_syntheset( synthe6, sts32_synthelen( synthe6 )/2, 0, -1 );

			// 0b00111 (7)
			} else if ( detect_parallel == 0b00111<<22 ) {
				_syntheset( synthe7, sts32_synthelen( synthe7 )/2, 0, -1 );

			// 0b01000 (8)
			} else if ( detect_parallel == 0b01000<<22 ) {
				_syntheset( synthe8, sts32_synthelen( synthe8 )/2, 0, -1 );

			// 0b10000 (16)
			} else if ( detect_parallel == 0b10000<<22 ) {

			// 0b11101 (29)
			} else if ( detect_parallel == 0b11101<<22 ) {
				/* Beat Up */
				timer_count_factor--;
				if ( timer_count_factor < timer_count_factor_minlimit ) timer_count_factor = timer_count_factor_minlimit;
				_armtimer_reload( (timer_count_multiply * timer_count_factor) - 1 );

			// 0b11110 (30)
			} else if ( detect_parallel == 0b11110<<22 ) {
				/* Beat Down */
				timer_count_factor++;
				if ( timer_count_factor > timer_count_factor_maxlimit ) timer_count_factor = timer_count_factor_maxlimit;
				_armtimer_reload( (timer_count_multiply * timer_count_factor) - 1 );

			// 0b11111 (31)
			} else if ( detect_parallel == 0b11111<<22 ) {
				_syntheclear();

			}
		}
	}

	return EXIT_SUCCESS;
}
