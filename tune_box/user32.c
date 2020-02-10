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
#include "snd32/soundindex.h"
#include "snd32/soundadjust.h"
#include "snd32/musiccode.h"
#include "pwm32/notes_le.h"

/* Function Declaration */
void makesilence();

/* Global Variables and Constants */

extern uint32 OS_RESET_MIDI_CHANNEL; // From vector32.s

/**
 * In default, there is a 480Hz synchronization clock (it's a half of 960Hz on Arm Timer beacause of toggling).
 * To set 48 beats as 60 BPM, decoding of sequence of music code (_soundplay) plays at only one clock out of ten clocks.
 * A set of 48 beats (= delta times) is 60BPM on 48HZ (one delta time is 1/48 seconds).
 * Arm Timer sets 480000Hz as clock.
 * 500 is divisor (TIMER_COUNT_MULTIPLICAND * timer_count_multiplier_defualt), i.e., 480000Hz / 250 / 2 equals 480Hz (60BPM).
 * The Maximum beat (480000 / (TIMER_COUNT_MULTIPLICAND * TIMER_COUNT_MULTIPLIER_MINLIMIT) / 2) is 2400Hz (300BPM).
 * The minimum beat (480000 / (TIMER_COUNT_MULTIPLICAND * TIMER_COUNT_MULTIPLIER_MAXLIMIT) / 2) is 240Hz (30BPM).
 *
 * If you want particular BPM for a track, use _armtimer_reload and/or _armtimer prior to _soundset.
 */

#define TIMER_COUNT_MULTIPLICAND        5
#define TIMER_COUNT_MULTIPLIER_DEFAULT  100
#define TIMER_COUNT_MULTIPLIER_MINLIMIT 20
#define TIMER_COUNT_MULTIPLIER_MAXLIMIT 200
#define LOOP_COUNTDOWN_DEFAULT          10 // one out of ten
#define GPIO_MASK                       0x000000FC // 2-7
#define GPIO_MASK_LANE0                 0x0000001C // GPIO 2-4
#define GPIO_MASK_LANE1                 0x000000E0 // GPIO 5-7

music_code music1[] =
{
	_12(_C4_SINL)
	_4(_E4_SINL) _4(_G4_SINL) _4(_C5_SINL)
	_12(_E4_SINL)
	_4(_G4_SINL) _4(_C5_SINL) _4(_E5_SINL)
	_12(_G4_SINL)
	_4(_E5_SINL) _4(_G5_SINL) _4(_C6_SINL)
	SND32_END
};

pwm_sequence music1_pulse1[] =
{
	_12(_RAP(1<<31|(_C4_LE/2),1<<31|_C4_LE))
	_12(_RAP(1<<31|0,1<<31|1))
	_12(_RAP(1<<31|(_E4_LE/2),1<<31|_E4_LE))
	_12(_RAP(1<<31|0,1<<31|1))
	_12(_RAP(1<<31|(_G4_LE/2),1<<31|_G4_LE))
	_12(_RAP(1<<31|0,1<<31|1))
	PWM32_END
};

pwm_sequence music1_pulse2[] =
{
	_12(_RAP(1<<31|(_E4_LE/2),1<<31|_E4_LE))
	_12(_RAP(1<<31|0,1<<31|1))
	_12(_RAP(1<<31|(_G4_LE/2),1<<31|_G4_LE))
	_12(_RAP(1<<31|0,1<<31|1))
	_12(_RAP(1<<31|(_C5_LE/2),1<<31|_C5_LE))
	_12(_RAP(1<<31|0,1<<31|1))
	PWM32_END
};

gpio_sequence music1_gpio[] =
{
	_6_BIG(_RAP(
		 _4(0x80000000)
		 _8(0x8000001C)
	))
	GPIO32_END
};

music_code interrupt16[] =
{
	_4_BIG(_RAP(
		_48_RYU_ARP(_D4_TRIL)
		_24_RYU_ARP(_G4_TRIL) _24_RYU_ARP(_G4_TRIL)
		_48_RYU_ARP(_D5_TRIL)
		_48_RYU_ARP(_D4_TRIL)
	))
	SND32_END
};

gpio_sequence interrupt16_gpio[] =
{
	_4_BIG(_RAP(
		_16_BIG(_RAP(
			 _4(0x80000000)
			 _8(0x800000E0)
		))
	))
	GPIO32_END
};

#define MUSIC_CODE_PRE_NUMBER 2

/* Register for Music Codes */
music_code* music_code_pre_table[MUSIC_CODE_PRE_NUMBER] = {
	music1,
	interrupt16
};

/* Register for Modulation Parameters, 1st Delta (Signed -256 to 256), 2nd Range (Mid-Peak, Unsigned Up to 4096) */
uint16 modulation_pre_table[MUSIC_CODE_PRE_NUMBER*2] = {
	 0x0000, 0x0000,
	-0x0010, 0x1000
};

/* Register for Wide PWM Sequence (1) */
pwm_sequence* pulse1_pre_table[MUSIC_CODE_PRE_NUMBER] = {
	music1_pulse1,
	0
};

/* Register for Wide PWM Sequence (2) */
pwm_sequence* pulse2_pre_table[MUSIC_CODE_PRE_NUMBER] = {
	music1_pulse2,
	0
};

/* Register for GPIO Sequence */
gpio_sequence* gpio_pre_table[MUSIC_CODE_PRE_NUMBER] = {
	music1_gpio,
	interrupt16_gpio
};

/* Register for Index of Tables */
uint32 music_code_pre_table_index[MUSIC_CODE_PRE_NUMBER] = {
	1,
	16
};

music_code** music_code_table;
pwm_sequence** pulse1_table;
pwm_sequence** pulse2_table;
gpio_sequence** gpio_table;
int16* modulation_table;
uint32* musiclen_table;
uint32 timer_count_multiplier;
int32 loop_countdown; // Use Signed Integer (Using Comparison in IF Statement)
uint32 tempo_index;
bool flag_midi_noteon;

void makesilence() {
	_soundclear( True );
	_pwmselect( 0 );
	_pwmclear( False );
	_pwmselect( 1 );
	_pwmclear( False );
	GPIO32_LANE = 0;
	_gpioclear( GPIO_MASK_LANE0, _GPIOCLEAR_HIGH );
	GPIO32_LANE = 1;
	_gpioclear( GPIO_MASK_LANE1, _GPIOCLEAR_HIGH );
}

int32 _user_start() {
	/* Local Variables */
	uint32 delta_multiplier;
	uint32 detect_parallel = 0;
	uint32 table_index;
	uint32 musiclen;
	uchar8 result;
	uchar8 playing_signal;
	bool mode_soundplay;
#if defined(__SOUND_I2S_BALANCED)
	_sounddecode( _SOUND_INDEX, SND32_I2S_BALANCED, _SOUND_ADJUST );
	mode_soundplay = True;
	delta_multiplier = 6;
#else
	_sounddecode( _SOUND_INDEX, SND32_I2S, _SOUND_ADJUST );
	mode_soundplay = True;
	delta_multiplier = 6;
#endif

	/* Initialization of Global Variables */
	music_code_table = (music_code**)heap32_malloc( 128 ); // 128 Words = 512 Bytes
	modulation_table = (int16*)heap32_malloc( 128 ); // 128 Words (256 Half Words) = 512 Bytes
	musiclen_table = (uint32*)heap32_malloc( 128 ); // 128 Words = 512 Bytes
	pulse1_table = (pwm_sequence**)heap32_malloc( 128 ); // 128 Words = 512 Bytes
	pulse2_table = (pwm_sequence**)heap32_malloc( 128 ); // 128 Words = 512 Bytes
	gpio_table = (gpio_sequence**)heap32_malloc( 128 ); // 128 Words = 512 Bytes
	for ( uint32 i = 0; i < MUSIC_CODE_PRE_NUMBER; i++ ) {
		table_index = music_code_pre_table_index[i];
		// To Get Proper Latency, Get Lengths in Advance
		music_code_table[table_index] = music_code_pre_table[i];
		modulation_table[table_index * 2] = modulation_pre_table[i * 2];
		modulation_table[(table_index * 2) + 1] = modulation_pre_table[(i * 2) + 1];
		musiclen_table[table_index] = snd32_musiclen( music_code_pre_table[i] );
		pulse1_table[table_index] = pulse1_pre_table[i];
		pulse2_table[table_index] = pulse2_pre_table[i];
		gpio_table[table_index] = gpio_pre_table[i];
	}
	timer_count_multiplier = TIMER_COUNT_MULTIPLIER_DEFAULT;
	loop_countdown = LOOP_COUNTDOWN_DEFAULT;
	tempo_index = TIMER_COUNT_MULTIPLIER_DEFAULT;
	flag_midi_noteon = False;

	/* Silence in Advance */
	makesilence();

	while ( true ) {
		_soundmidi( OS_RESET_MIDI_CHANNEL, SND32_MIDI_PCM );

		/* High on GPIO20 If MIDI Note On */
		if ( SND32_STATUS & 0x4 ) { // Bit[2] MIDI Note Off(0)/ Note On(1)
			if ( ! flag_midi_noteon ) {
				flag_midi_noteon = True;
				_gpiotoggle( 20, flag_midi_noteon ); // Gate On
			}
		} else {
			if ( flag_midi_noteon ) {
				flag_midi_noteon = False;
				_gpiotoggle( 20, flag_midi_noteon ); // Gate Off
			}
		}

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
		 * 0x7F = 0b1111111 (127) is virtual all high in default.
		 * If you extend physical parallel up to 0x7F, you need to use Command 127 as doing nothing or so.
		 * Command 127 is used as setting upper 8 bits of the tempo index.
		 */
		if ( detect_parallel ) { // If Any Non Zero Including Outstanding Flag
			_gpiotoggle( 14, _GPIOTOGGLE_SWAP ); // Busy Toggle
			detect_parallel &= 0x7F; // 0-127
			if ( detect_parallel > 111 ) { // 112(0x70)-127(0x7F)
				// Tempo Index Upper 8-bit
				tempo_index = (tempo_index & 0x0F) | ((detect_parallel & 0x0F) << 4);
				timer_count_multiplier = tempo_index;
				if ( timer_count_multiplier > TIMER_COUNT_MULTIPLIER_MAXLIMIT ) {
					timer_count_multiplier = TIMER_COUNT_MULTIPLIER_MAXLIMIT;
				} else if ( timer_count_multiplier < TIMER_COUNT_MULTIPLIER_MINLIMIT ) {
					timer_count_multiplier = TIMER_COUNT_MULTIPLIER_MINLIMIT;
				}
				_armtimer_reload( (TIMER_COUNT_MULTIPLICAND * timer_count_multiplier) - 1 );
			} else if ( detect_parallel > 95 ) { // 96(0x60)-111(0x6F)
				// Tempo Index Lower 8-bit
				tempo_index = (tempo_index & 0xF0) | (detect_parallel & 0x0F);
				timer_count_multiplier = tempo_index;
				if ( timer_count_multiplier > TIMER_COUNT_MULTIPLIER_MAXLIMIT ) {
					timer_count_multiplier = TIMER_COUNT_MULTIPLIER_MAXLIMIT;
				} else if ( timer_count_multiplier < TIMER_COUNT_MULTIPLIER_MINLIMIT ) {
					timer_count_multiplier = TIMER_COUNT_MULTIPLIER_MINLIMIT;
				}
				_armtimer_reload( (TIMER_COUNT_MULTIPLICAND * timer_count_multiplier) - 1 );
			} else if ( detect_parallel > 31 ) { // 32-95
				// One Time
				SND32_MODULATION_DELTA = modulation_table[detect_parallel * 2] * delta_multiplier;
				SND32_MODULATION_RANGE = modulation_table[(detect_parallel * 2) + 1] * delta_multiplier;
				musiclen = musiclen_table[detect_parallel];
				_soundset( music_code_table[detect_parallel], musiclen, 0, 1 );
				_pwmselect( 0 );
				_pwmset( pulse1_table[detect_parallel], musiclen, 0, 1 );
				_pwmselect( 1 );
				_pwmset( pulse2_table[detect_parallel], musiclen, 0, 1 );
				GPIO32_LANE = 0;
				_gpioset( gpio_table[detect_parallel], musiclen, 0, 1 );
			} else if ( detect_parallel == 0b11111 ) { // 0b11111 (31)
				makesilence();

			} else if ( detect_parallel == 0b11110 ) { // 0b11110 (30)
				/* Beat Down */
				timer_count_multiplier += 5;
				if ( timer_count_multiplier > TIMER_COUNT_MULTIPLIER_MAXLIMIT ) timer_count_multiplier = TIMER_COUNT_MULTIPLIER_MAXLIMIT;
				_armtimer_reload( (TIMER_COUNT_MULTIPLICAND * timer_count_multiplier) - 1 );
			} else if ( detect_parallel == 0b11101 ) { // 0b11101 (29)
				/* Beat Up */
				timer_count_multiplier -= 5;
				if ( timer_count_multiplier < TIMER_COUNT_MULTIPLIER_MINLIMIT ) timer_count_multiplier = TIMER_COUNT_MULTIPLIER_MINLIMIT;
				_armtimer_reload( (TIMER_COUNT_MULTIPLICAND * timer_count_multiplier) - 1 );
			} else if ( detect_parallel > 15 ) { // 16-28
				// One Time
				SND32_MODULATION_DELTA = modulation_table[detect_parallel * 2] * delta_multiplier;
				SND32_MODULATION_RANGE = modulation_table[(detect_parallel * 2) + 1] * delta_multiplier;
				musiclen = musiclen_table[detect_parallel];
				_soundinterrupt( music_code_table[detect_parallel], musiclen, 0, 1 );
				GPIO32_LANE = 1;
				_gpioset( gpio_table[detect_parallel], musiclen, 0, 1 );
			} else if ( detect_parallel > 0 ) { // 1-15
				// Loop
				SND32_MODULATION_DELTA = modulation_table[detect_parallel * 2] * delta_multiplier;
				SND32_MODULATION_RANGE = modulation_table[(detect_parallel * 2) + 1] * delta_multiplier;
				musiclen = musiclen_table[detect_parallel];
				_soundset( music_code_table[detect_parallel], musiclen, 0, -1 );
				_pwmselect( 0 );
				_pwmset( pulse1_table[detect_parallel], musiclen, 0, -1 );
				_pwmselect( 1 );
				_pwmset( pulse2_table[detect_parallel], musiclen, 0, -1 );
				GPIO32_LANE = 0;
				_gpioset( gpio_table[detect_parallel], musiclen, 0, -1 );
			} // Do Nothing at 0 for Preventing Chattering
			detect_parallel = 0;
		}

		/* Detect Rising Edge of GPIO */
		if ( _gpio_detect( 17 ) ) {
			if ( SND32_VIRTUAL_PARALLEL ) {
				detect_parallel = SND32_VIRTUAL_PARALLEL;
				SND32_VIRTUAL_PARALLEL = 0;
			}

//print32_debug( detect_parallel, 100, 100 );

			// Subtract Pitch Bend Ratio to Divisor (Upside Down)
			_clockmanager_divisor( _cm_pcm, SND32_DIVISOR - SND32_SOUNDMIDI_PITCHBEND );

/*
print32_debug( SND32_DIVISOR, 100, 100 );
print32_debug( SND32_MODULATION_DELTA, 100, 112 );
print32_debug( SND32_MODULATION_MAX, 100, 124 );
print32_debug( SND32_MODULATION_MIN, 100, 136 );
*/

			/* Triangle LFO */
			SND32_DIVISOR += SND32_MODULATION_DELTA;
			if ( SND32_DIVISOR >= SND32_MODULATION_MAX ) {
				SND32_DIVISOR = SND32_MODULATION_MAX;
				SND32_MODULATION_DELTA = -( SND32_MODULATION_DELTA );
			} else if ( SND32_DIVISOR <= SND32_MODULATION_MIN ) {
				SND32_DIVISOR = SND32_MODULATION_MIN;
				SND32_MODULATION_DELTA = -( SND32_MODULATION_DELTA );
			}
			arm32_dsb();

			loop_countdown--; // Decrement Counter
			if ( loop_countdown <= 0 ) { // If Reaches Zero
				result = _soundplay( mode_soundplay );
				if ( result == 0 ) { // Playing
					playing_signal = _GPIOTOGGLE_HIGH;
				} else { // Not Playing
					playing_signal = _GPIOTOGGLE_LOW;
				}
				_gpiotoggle( 16, playing_signal );
				/**
				 * PWM Play
				 */
				_pwmselect( 0 );
				_pwmplay( False, True ); // Wide PWM Sequence
				_pwmselect( 1 );
				_pwmplay( False, True ); // Wide PWM Sequence
				/**
				 * GPIO Play
				 */
				GPIO32_LANE = 0;
				_gpioplay( GPIO_MASK_LANE0 );
				GPIO32_LANE = 1;
				_gpioplay( GPIO_MASK_LANE1 );
				loop_countdown = LOOP_COUNTDOWN_DEFAULT; // Reset Counter
			}
		}
	}
	return EXIT_SUCCESS;
}
