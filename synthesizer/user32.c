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
#include "sts32.h"

#define timer_count_multiplicand        1
#define timer_count_multiplier_default  30
#define timer_count_multiplier_minlimit 10
#define timer_count_multiplier_maxlimit 50

/**
 * In default, there is a 2000hz synchronization clock (it's a half of 2400Hz on Arm Timer beacause of toggling).
 * Arm Timer sets 120000Hz as clock.
 * 30 is divisor (timer_count_multiplicand * timer_count_multiplier_defualt), i.e., 120000 / 30 / 2 equals 2000.
 * The Maximum beat (120000 / (timer_count_multiplicand * timer_count_multiplier_minlimit) / 2) is 6000Hz.
 * The minimum beat (120000 / (timer_count_multiplicand * timer_count_multiplier_maxlimit) / 2) is 1200Hz.
 */

/**
 * Synthesizer Code is 64-bit Block (Two 32-bit Words) consists two frequencies and magnitudes to Synthesize.
 * Lower Bit[14-0] Frequency-A (Main): 0 to 32767 Hz
 * Lower Bit[15] Decimal Part of Frequency-A (Main): 0 as 0.0, 1 as 0.5
 * Lower Bit[31-16] Magnitude-A = Volume: -32768 to 32767, Minus for Inverted Wave
 * Higher Bit[14-0] Frequency-B (Sub): 0 to 32767 Hz
 * Higher Bit[15] Decimal Part of Frequency-B (Sub): 0 as 0.0, 1 as 0.5
 * Higher Bit[31-16] Magnitude-B: 0 to 65535, 1 is 2Pi/65535, 65535 is 2Pi
 * The wave is synthesized the formula:
 * Amplitude on T = Magnitude-A * sin((T * (2Pi * Frequency-A)) + Magnitude-B * sin(T * (2Pi * Frequency-B))).
 * Where T is time (seconds); one is 1/sampling-rate seconds.
 * This type of synthesizers is named as "Frequency Modulation Synthesis" developed by John Chowning, and decorated the music world in the late 20th century.
 * 0x00,0x00 (zeros on lower and higher) means End of Synthesizer Code.
 *
 * Synthesizer Code will be fetched by L/R alternatively.
 * If you line up four blocks, the first and the third block will be fetched by L, and the second and the fourth block will be fetched by R.
 */

/**
 * Synthesizer Pre-code is a series of blocks. Each block has a structure of 4 long integers (32-bit).
 * uint32 synthe_code_lower;
 * uint32 synthe_code_upper;
 * uint32 beat_length (Bit[31:0]), Reserved (Bit[63:32]) Must Be Zero;
 * uint32 rising_pitch (Bit[15:0]) and falling_pitch (Bit[31:16]); 0 - 100 Percents
 * 0x00,0x00 (zeros on lower and higher) means End of Synthesizer Code.
 *
 * Beat Length as 100 percents = Rising Pitch + Flat (Same as Volume) + Falling Pitch
 */

synthe_precode pre_synthe1_l[] = {
	4000<<STS32_MAG|262,10000<<STS32_MAG|1262,500,50|50<<STS32_FAL,
	4000<<STS32_MAG|311,10000<<STS32_MAG|1311,500,50|50<<STS32_FAL,
	4000<<STS32_MAG|349,10000<<STS32_MAG|1349,500,50|50<<STS32_FAL,
	4000<<STS32_MAG|392,10000<<STS32_MAG|1392,500,50|50<<STS32_FAL,
	STS32_END
};

synthe_precode pre_synthe1_r[] = {
	2000<<STS32_MAG|131,60000<<STS32_MAG|131,1000,20|80<<STS32_FAL,
	2000<<STS32_MAG|123,60000<<STS32_MAG|131,1000,20|80<<STS32_FAL,
	STS32_END
};

synthe_precode pre_synthe2_l[] = {
	3000<<STS32_MAG|_C5,30000<<STS32_MAG|2000,250,50|50<<STS32_FAL,
	3000<<STS32_MAG|_D5,30000<<STS32_MAG|2000,250,50|50<<STS32_FAL,
	3000<<STS32_MAG|_E5,30000<<STS32_MAG|2000,250,50|50<<STS32_FAL,
	3000<<STS32_MAG|_F5,30000<<STS32_MAG|2000,250,50|50<<STS32_FAL,
	3000<<STS32_MAG|_G5,30000<<STS32_MAG|2000,250,50|50<<STS32_FAL,
	3000<<STS32_MAG|_A5,30000<<STS32_MAG|2000,250,50|50<<STS32_FAL,
	3000<<STS32_MAG|_B5,30000<<STS32_MAG|2000,250,50|50<<STS32_FAL,
	3000<<STS32_MAG|_C6,30000<<STS32_MAG|2000,250,50|50<<STS32_FAL,
	STS32_END
};

synthe_precode pre_synthe2_r[] = {
	3000<<STS32_MAG|_C6,30000<<STS32_MAG|2000,250,50|50<<STS32_FAL,
	3000<<STS32_MAG|_B5,30000<<STS32_MAG|2000,250,50|50<<STS32_FAL,
	3000<<STS32_MAG|_A5,30000<<STS32_MAG|2000,250,50|50<<STS32_FAL,
	3000<<STS32_MAG|_G5,30000<<STS32_MAG|2000,250,50|50<<STS32_FAL,
	3000<<STS32_MAG|_F5,30000<<STS32_MAG|2000,250,50|50<<STS32_FAL,
	3000<<STS32_MAG|_E5,30000<<STS32_MAG|2000,250,50|50<<STS32_FAL,
	3000<<STS32_MAG|_D5,30000<<STS32_MAG|2000,250,50|50<<STS32_FAL,
	3000<<STS32_MAG|_C5,30000<<STS32_MAG|2000,250,50|50<<STS32_FAL,
	STS32_END
};

synthe_precode pre_synthe8_l[] = {
	3000<<STS32_MAG|_D4,30000<<STS32_MAG|_D4,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_G5,30000<<STS32_MAG|_G5,250,2|98<<STS32_FAL,
	0000<<STS32_MAG|_D4,30000<<STS32_MAG|_D4,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_G5,30000<<STS32_MAG|_G5,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_D4,30000<<STS32_MAG|_D4,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_G5,30000<<STS32_MAG|_G5,250,2|98<<STS32_FAL,
	0000<<STS32_MAG|_D4,30000<<STS32_MAG|_D4,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_G5,30000<<STS32_MAG|_G5,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_D4,30000<<STS32_MAG|_D4,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_G5,30000<<STS32_MAG|_G5,250,2|98<<STS32_FAL,
	0000<<STS32_MAG|_D4,30000<<STS32_MAG|_D4,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_G5,30000<<STS32_MAG|_G5,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_D4,30000<<STS32_MAG|_D4,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_G5,30000<<STS32_MAG|_G5,250,2|98<<STS32_FAL,
	0000<<STS32_MAG|_D4,30000<<STS32_MAG|_D4,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_G5,30000<<STS32_MAG|_G5,250,2|98<<STS32_FAL,

	3000<<STS32_MAG|_C4,30000<<STS32_MAG|_C4,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_F5,30000<<STS32_MAG|_F5,250,2|98<<STS32_FAL,
	0000<<STS32_MAG|_C4,30000<<STS32_MAG|_C4,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_F5,30000<<STS32_MAG|_F5,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_C4,30000<<STS32_MAG|_C4,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_F5,30000<<STS32_MAG|_F5,250,2|98<<STS32_FAL,
	0000<<STS32_MAG|_C4,30000<<STS32_MAG|_C4,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_F5,30000<<STS32_MAG|_F5,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_C4,30000<<STS32_MAG|_C4,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_F5,30000<<STS32_MAG|_F5,250,2|98<<STS32_FAL,
	0000<<STS32_MAG|_C4,30000<<STS32_MAG|_C4,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_F5,30000<<STS32_MAG|_F5,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_C4,30000<<STS32_MAG|_C4,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_F5,30000<<STS32_MAG|_F5,250,2|98<<STS32_FAL,
	0000<<STS32_MAG|_C4,30000<<STS32_MAG|_C4,250,2|98<<STS32_FAL,
	3000<<STS32_MAG|_F5,30000<<STS32_MAG|_F5,250,2|98<<STS32_FAL,
	STS32_END
};

synthe_precode pre_synthe8_r[] = {
	-3000<<STS32_MAG|_D4,30000<<STS32_MAG|_D4,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_G5,30000<<STS32_MAG|_G5,250,2|98<<STS32_FAL,
	-0000<<STS32_MAG|_D4,30000<<STS32_MAG|_D4,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_G5,30000<<STS32_MAG|_G5,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_D4,30000<<STS32_MAG|_D4,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_G5,30000<<STS32_MAG|_G5,250,2|98<<STS32_FAL,
	-0000<<STS32_MAG|_D4,30000<<STS32_MAG|_D4,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_G5,30000<<STS32_MAG|_G5,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_D4,30000<<STS32_MAG|_D4,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_G5,30000<<STS32_MAG|_G5,250,2|98<<STS32_FAL,
	-0000<<STS32_MAG|_D4,30000<<STS32_MAG|_D4,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_G5,30000<<STS32_MAG|_G5,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_D4,30000<<STS32_MAG|_D4,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_G5,30000<<STS32_MAG|_G5,250,2|98<<STS32_FAL,
	-0000<<STS32_MAG|_D4,30000<<STS32_MAG|_D4,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_G5,30000<<STS32_MAG|_G5,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_C4,30000<<STS32_MAG|_C4,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_F5,30000<<STS32_MAG|_F5,250,2|98<<STS32_FAL,
	-0000<<STS32_MAG|_C4,30000<<STS32_MAG|_C4,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_F5,30000<<STS32_MAG|_F5,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_C4,30000<<STS32_MAG|_C4,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_F5,30000<<STS32_MAG|_F5,250,2|98<<STS32_FAL,
	-0000<<STS32_MAG|_C4,30000<<STS32_MAG|_C4,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_F5,30000<<STS32_MAG|_F5,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_C4,30000<<STS32_MAG|_C4,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_F5,30000<<STS32_MAG|_F5,250,2|98<<STS32_FAL,
	-0000<<STS32_MAG|_C4,30000<<STS32_MAG|_C4,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_F5,30000<<STS32_MAG|_F5,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_C4,30000<<STS32_MAG|_C4,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_F5,30000<<STS32_MAG|_F5,250,2|98<<STS32_FAL,
	-0000<<STS32_MAG|_C4,30000<<STS32_MAG|_C4,250,2|98<<STS32_FAL,
	-3000<<STS32_MAG|_F5,30000<<STS32_MAG|_F5,250,2|98<<STS32_FAL,
	STS32_END
};

// "Himawari"
synthe_precode pre_synthe16_l[] = {
	3000<<STS32_MAG|_D5,30000<<STS32_MAG|(_D5+2000),750,20|80<<STS32_FAL,
	3000<<STS32_MAG|_G5,30000<<STS32_MAG|(_G5+2000),1250,20|80<<STS32_FAL,
	3000<<STS32_MAG|_D5,30000<<STS32_MAG|(_D5+2000),750,20|80<<STS32_FAL,
	3000<<STS32_MAG|_G5,30000<<STS32_MAG|(_G5+2000),1250,20|80<<STS32_FAL,
	3000<<STS32_MAG|_F5,30000<<STS32_MAG|(_F5+2000),750,20|80<<STS32_FAL,
	3000<<STS32_MAG|_C6,30000<<STS32_MAG|(_C6+2000),1250,20|80<<STS32_FAL,
	STS32_END
};

synthe_precode pre_synthe16_r[] = {
	3000<<STS32_MAG|_G1,60000<<STS32_MAG|_G1,500,10|90<<STS32_FAL,
	3000<<STS32_MAG|_D2,60000<<STS32_MAG|_D2,500,10|90<<STS32_FAL,
	3000<<STS32_MAG|_G1,60000<<STS32_MAG|_G1,500,10|90<<STS32_FAL,
	3000<<STS32_MAG|_D2,60000<<STS32_MAG|_D2,500,10|90<<STS32_FAL,
	3000<<STS32_MAG|_G1,60000<<STS32_MAG|_G1,500,10|90<<STS32_FAL,
	3000<<STS32_MAG|_D2,60000<<STS32_MAG|_D2,500,10|90<<STS32_FAL,
	3000<<STS32_MAG|_G1,60000<<STS32_MAG|_G1,500,10|90<<STS32_FAL,
	3000<<STS32_MAG|_D2,60000<<STS32_MAG|_D2,500,10|90<<STS32_FAL,
	3000<<STS32_MAG|_F1,60000<<STS32_MAG|_F1,500,10|90<<STS32_FAL,
	3000<<STS32_MAG|_C2,60000<<STS32_MAG|_C2,500,10|90<<STS32_FAL,
	3000<<STS32_MAG|_F1,60000<<STS32_MAG|_F1,500,10|90<<STS32_FAL,
	3000<<STS32_MAG|_C2,60000<<STS32_MAG|_C2,500,10|90<<STS32_FAL,
	STS32_END
};

int32 _user_start()
{

	synthe_code* synthe1 = sts32_synthedecodelr( pre_synthe1_l, pre_synthe1_r );
	synthe_code* synthe2 = sts32_synthedecodelr( pre_synthe2_l, pre_synthe2_r );
	synthe_code* synthe3 = (synthe_code*)heap32_malloc( 2 );
	synthe_code* synthe4 = (synthe_code*)heap32_malloc( 2 );
	synthe_code* synthe5 = (synthe_code*)heap32_malloc( 2 );
	synthe_code* synthe6 = (synthe_code*)heap32_malloc( 2 );
	synthe_code* synthe7 = (synthe_code*)heap32_malloc( 2 );
	synthe_code* synthe8 = sts32_synthedecodelr( pre_synthe8_l, pre_synthe8_r );
	synthe_code* synthe16 = sts32_synthedecodelr( pre_synthe16_l, pre_synthe16_r );

	uint32 timer_count_multiplier = timer_count_multiplier_default;
	uint32 detect_parallel;

//print32_debug( (uint32)synthe8, 100, 200 );
//print32_debug_hexa( (uint32)synthe8, 100, 212, 256 );

	while ( true ) {
#ifdef __SOUND_I2S
		_synthewave_i2s();
#endif
#ifdef __SOUND_PWM
		_synthewave_pwm();
#endif
#ifdef __SOUND_JACK
		_synthewave_pwm();
#endif
		if ( _gpio_detect( 27 ) ) { // Time of This Loop Around 40us in My Experience
			_syntheplay();
			detect_parallel = _load_32( _gpio_base|_gpio_gpeds0 );
			_store_32( _gpio_base|_gpio_gpeds0, detect_parallel );

//print32_debug( detect_parallel, 100, 100 );

			/* GPIO22-26 as Bit[26:22] */
			// 0b00001 (1)
			if ( detect_parallel == 0b00001<<22 ) {
				_syntheset( synthe1, sts32_synthelen( synthe1 )/2, 0, -1 );
				//_syntheclear();

			// 0b00010 (2)
			} else if ( detect_parallel == 0b00010<<22 ) {
				_syntheset( synthe2, sts32_synthelen( synthe2 )/2, 0, -1 );
				/* Beat Up */
				//timer_count_multiplier--;
				//if ( timer_count_multiplier < timer_count_multiplier_minlimit ) timer_count_multiplier = timer_count_multiplier_minlimit;
				//_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );


			// 0b00011 (3)
			} else if ( detect_parallel == 0b00011<<22 ) {
				_syntheset( synthe3, sts32_synthelen( synthe3 )/2, 0, -1 );

			// 0b00100 (4)
			} else if ( detect_parallel == 0b00100<<22 ) {
				_syntheset( synthe4, sts32_synthelen( synthe4 )/2, 0, -1 );
				/* Beat Down */
				//timer_count_multiplier++;
				//if ( timer_count_multiplier > timer_count_multiplier_maxlimit ) timer_count_multiplier = timer_count_multiplier_maxlimit;
				//_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );

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
				_syntheset( synthe16, sts32_synthelen( synthe16 )/2, 0, -1 );

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
				_syntheclear();

			}
		}
	}

	return EXIT_SUCCESS;
}
