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

synth_code synth1[] =
{
	0x00
};

synth_code synth2[] =
{
	0x00
};

synth_code synth3[] =
{
	0x00
};

synth_code synth4[] =
{
	0x00
};

synth_code synth5[] =
{
	0x00
};

synth_code synth6[] =
{
	0x00
};

synth_code synth7[] =
{
	0x00
};

synth_code synth8[] =
{
	_20(3ull<<48|60ull<<32|300ull<<16|2000ull)
	_20(3ull<<48|60ull<<32|300ull<<16|1000ull)
	_20(3ull<<48|60ull<<32|300ull<<16|500ull)
	_20(3ull<<48|60ull<<32|300ull<<16|250ull)
	0x00
};

synth_code synth9[] =
{
	0x00
};

synth_code synth10[] =
{
	0x00
};

synth_code synth11[] =
{
	0x00
};

synth_code synth12[] =
{
	0x00
};

synth_code synth13[] =
{
	0x00
};

synth_code synth14[] =
{
	0x00
};

synth_code synth15[] =
{
	0x00
};

int32 _user_start()
{

	uchar8 timer_count_factor = timer_count_factor_default;
	uint32 detect_parallel;

	while ( true ) {
		_synthwave();
		if ( _gpio_detect( 27 ) ) {
			_synthplay();
			detect_parallel = _load_32( _gpio_base|_gpio_gpeds0 );
			_store_32( _gpio_base|_gpio_gpeds0, detect_parallel );

//print32_debug( detect_parallel, 100, 100 );

			/* GPIO22-26 as Bit[26:22] */
			// 0b00001 (1)
			if ( detect_parallel == 0b00001<<22 ) {
				//_synthset( synth1, sts32_synthlen( synth1 ) , 0, -1 );
				_synthclear();

			// 0b00010 (2)
			} else if ( detect_parallel == 0b00010<<22 ) {
				//_synthset( synth2, sts32_synthlen( synth2 ) , 0, -1 );
				/* Beat Up */
				timer_count_factor--;
				if ( timer_count_factor < timer_count_factor_minlimit ) timer_count_factor = timer_count_factor_minlimit;
				_armtimer_reload( (timer_count_multiply * timer_count_factor) - 1 );


			// 0b00011 (3)
			} else if ( detect_parallel == 0b00011<<22 ) {
				_synthset( synth3, sts32_synthlen( synth3 ) , 0, -1 );

			// 0b00100 (4)
			} else if ( detect_parallel == 0b00100<<22 ) {
				//_synthset( synth4, sts32_synthlen( synth4 ) , 0, -1 );
				/* Beat Down */
				timer_count_factor++;
				if ( timer_count_factor > timer_count_factor_maxlimit ) timer_count_factor = timer_count_factor_maxlimit;
				_armtimer_reload( (timer_count_multiply * timer_count_factor) - 1 );

			// 0b00101 (5)
			} else if ( detect_parallel == 0b00101<<22 ) {
				_synthset( synth5, sts32_synthlen( synth5 ) , 0, -1 );

			// 0b00110 (6)
			} else if ( detect_parallel == 0b00110<<22 ) {
				_synthset( synth6, sts32_synthlen( synth6 ) , 0, -1 );

			// 0b00111 (7)
			} else if ( detect_parallel == 0b00111<<22 ) {
				_synthset( synth7, sts32_synthlen( synth7 ) , 0, -1 );

			// 0b01000 (8)
			} else if ( detect_parallel == 0b01000<<22 ) {
				_synthset( synth8, sts32_synthlen( synth8 ) , 0, -1 );

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
				_synthclear();

			}
		}
	}

	return EXIT_SUCCESS;
}
