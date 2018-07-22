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
#include "snd32.h"

#define timer_count_multiplicand        125
#define timer_count_multiplier_default  10
#define timer_count_multiplier_minlimit 5
#define timer_count_multiplier_maxlimit 40

/**
 * In default, there is a 48Hz synchronization clock (it's a half of 96Hz on Arm Timer beacause of toggling).
 * Arm Timer sets 120000Hz as clock.
 * 1250 is divisor (timer_count_multiplicand * timer_count_multiplier_defualt), i.e., 120000 / 1250 / 2 equals 48.
 * The Maximum beat (120000 / (timer_count_multiplicand * timer_count_multiplier_minlimit) / 2) is 96Hz.
 * The minimum beat (120000 / (timer_count_multiplicand * timer_count_multiplier_maxlimit) / 2) is 12Hz.
 */

music_code music1[] =
{
	_12(B5_SINL)
	SND32_END
};

music_code music2[] =
{
	_12(E4_TRIL)
	SND32_END
};

music_code music3[] =
{
	_12(C4_SINL)
	_4(E4_SINL) _4(G4_SINL) _4(C5_SINL)
	_12(E4_SINL)
	_4(G4_SINL) _4(C5_SINL) _4(E5_SINL)
	_12(G4_SINL)
	_4(E5_SINL) _4(G5_SINL) _4(C6_SINL)
	SND32_END
};

music_code music4[] =
{
	_12_MAJ(C4_SINL) _12_MAJ(E4_SINL) _12_MAJ(G4_SINL) _12_MAJ(B4_SINL)
	_12_MAJ(E4_SINL) _12_MAJ(G4_SINL) _12_MAJ(B4_SINL) _12_MAJ(D5_SINL)
	_12_MAJ(G4_SINL) _12_MAJ(B4_SINL) _12_MAJ(D5_SINL) _12_MAJ(F5_SINL)
	SND32_END
};

music_code music5[] =
{
	_24_DEC(A4_TRIL) _24_DEC(B4_TRIL)
	_24_DEC(C5_TRIL) _24_DEC(B4_TRIL)
	_24_DEC(A4_TRIL) _24(A4_TRIS)
	_48(SND32_SILENCE)
	SND32_END
};

music_code music6[] =
{
	_24_M(C3_SINL) _24_M(B2_SINL)
	_24_M(A2_SINL) _24_M(B2_SINL)
	SND32_END
};

music_code music7[] =
{
	_48_9TH(F4_TRIL)
	SND32_END
};

music_code music8[] =
{
	_48_ROC_ARP(D4_TRIL)
	_24_ROC_ARP(G4_TRIL) _24_ROC_ARP(G4_TRIL)
	_48_ROC_ARP(D5_TRIL)
	_48_ROC_ARP(D4_TRIL)
	SND32_END
};

music_code interrupt16[] =
{
	_48_RYU_ARP(D4_TRIL)
	_24_MEN_ARP(G4_TRIL) _24_MEN_ARP(G4_TRIL)
	_48_ENK_ARP(D5_TRIL)
	_48_ENK_ARP(D4_TRIL)
	SND32_END
};

int32 _user_start()
{

	uint32 timer_count_multiplier = timer_count_multiplier_default;
	uint32 detect_parallel;

#ifdef __SOUND_I2S
	_sounddecode( sound, SND32_I2S );
#endif
#ifdef __SOUND_I2S_BALANCED
	_sounddecode( sound, SND32_I2S_BALANCED );
#endif
#ifdef __SOUND_PWM
	_sounddecode( sound, SND32_PWM );
#endif
#ifdef __SOUND_PWM_BALANCED
	_sounddecode( sound, SND32_PWM_BALANCED );
#endif
#ifdef __SOUND_JACK
	_sounddecode( sound, SND32_PWM );
#endif
#ifdef __SOUND_JACK_BALANCED
	_sounddecode( sound, SND32_PWM_BALANCED );
#endif

	while ( true ) {
		if ( _gpio_detect( 27 ) ) {
			_soundplay();
			detect_parallel = _load_32( _gpio_base|_gpio_gpeds0 );
			_store_32( _gpio_base|_gpio_gpeds0, detect_parallel );

//print32_debug( detect_parallel, 100, 100 );

			/* GPIO22-26 as Bit[26:22] */
			// 0b00001 (1)
			if ( detect_parallel == 0b00001<<22 ) {
				_soundset( music1, snd32_musiclen( music1 ) , 0, -1 );
				//_soundclear();

			// 0b00010 (2)
			} else if ( detect_parallel == 0b00010<<22 ) {
				_soundset( music2, snd32_musiclen( music2 ) , 0, -1 );
				/* Beat Up */
				//timer_count_multiplier--;
				//if ( timer_count_multiplier < timer_count_multiplier_minlimit ) timer_count_multiplier = timer_count_multiplier_minlimit;
				//_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );


			// 0b00011 (3)
			} else if ( detect_parallel == 0b00011<<22 ) {
				_soundset( music3, snd32_musiclen( music3 ) , 0, -1 );

			// 0b00100 (4)
			} else if ( detect_parallel == 0b00100<<22 ) {
				_soundset( music4, snd32_musiclen( music4 ) , 0, -1 );
				/* Beat Down */
				//timer_count_multiplier++;
				//if ( timer_count_multiplier > timer_count_multiplier_maxlimit ) timer_count_multiplier = timer_count_multiplier_maxlimit;
				//_armtimer_reload( (timer_count_multiplicand * timer_count_multiplier) - 1 );

			// 0b00101 (5)
			} else if ( detect_parallel == 0b00101<<22 ) {
				_soundset( music5, snd32_musiclen( music5 ) , 0, -1 );

			// 0b00110 (6)
			} else if ( detect_parallel == 0b00110<<22 ) {
				_soundset( music6, snd32_musiclen( music6 ) , 0, -1 );

			// 0b00111 (7)
			} else if ( detect_parallel == 0b00111<<22 ) {
				_soundset( music7, snd32_musiclen( music7 ) , 0, -1 );

			// 0b01000 (8)
			} else if ( detect_parallel == 0b01000<<22 ) {
				_soundset( music8, snd32_musiclen( music8 ) , 0, -1 );

			// 0b10000 (16)
			} else if ( detect_parallel == 0b10000<<22 ) {
				_soundinterrupt( interrupt16, snd32_musiclen( interrupt16 ) , 0, 1 );

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
				_soundclear();

			}
		}
	}

	return EXIT_SUCCESS;
}
