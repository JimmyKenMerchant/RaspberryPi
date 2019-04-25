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

extern bool TUNER_FIQ_FLAG_BACK;
extern obj TUNER_FIQ_BUFFER;

char8 scale88_chromatic [] =
	"A 0\0A#0\0B 0\0C 1\0C#1\0D 1\0D#1\0E 1\0F 1\0F#1\0G 1\0G#1\0"\
	"A 1\0A#1\0B 1\0C 2\0C#2\0D 2\0D#2\0E 2\0F 2\0F#2\0G 2\0G#2\0"\
	"A 2\0A#2\0B 2\0C 3\0C#3\0D 3\0D#3\0E 3\0F 3\0F#3\0G 3\0G#3\0"\
	"A 3\0A#3\0B 3\0C 4\0C#4\0D 4\0D#1\0E 4\0F 4\0F#4\0G 4\0G#4\0"\
	"A 4\0A#4\0B 4\0C 5\0C#5\0D 5\0D#1\0E 5\0F 5\0F#5\0G 5\0G#5\0"\
	"A 5\0A#5\0B 5\0C 6\0C#6\0D 6\0D#1\0E 6\0F 6\0F#6\0G 6\0G#6\0"\
	"A 6\0A#6\0B 6\0C 7\0C#7\0D 7\0D#1\0E 7\0F 7\0F#7\0G 7\0G#7\0"\
	"A 7\0A#7\0B 7\0C 8\0";

char8 scale101_cent [] =
	"-50\0-49\0-48\0-47\0-46\0-45\0-44\0-43\0-42\0-41\0"\
	"-40\0-39\0-38\0-37\0-36\0-35\0-34\0-33\0-32\0-31\0"\
	"-30\0-29\0-28\0-27\0-26\0-25\0-24\0-23\0-22\0-21\0"\
	"-20\0-19\0-18\0-17\0-16\0-15\0-14\0-13\0-12\0-11\0"\
	"-10\0- 9\0- 8\0- 7\0- 6\0- 5\0- 4\0- 3\0- 2\0- 1\0"\
	"  0\0+ 1\0+ 2\0+ 3\0+ 4\0+ 5\0+ 6\0+ 7\0+ 8\0+ 9\0"\
	"+10\0+11\0+12\0+13\0+14\0+15\0+16\0+17\0+18\0+19\0"\
	"+20\0+21\0+22\0+23\0+24\0+25\0+26\0+27\0+28\0+29\0"\
	"+30\0+31\0+32\0+33\0+34\0+35\0+36\0+37\0+38\0+39\0"\
	"+40\0+41\0+42\0+43\0+44\0+45\0+46\0+47\0+48\0+49\0"\
	"+50\0";

/**
 * Relationship between frequencies and piano keys are defined as the formula,
 * f(n) = (2^(1/12))^(n-49) * 440
 * where f(n) is the frequency (hz) on the numberth key of a 88-scale piano,
 * and 440 is the frequency on the 49th key.
 * This formula can be transferred as follows:
 * log2^(1/12)(f(n)/440) = n - 49
 * ln(f(n)/440) / ln(2^(1/12)) + 49 = n
 */

const float32 coefficient_ln = 0.05776227; // ln(2^(1/12))
const float32 coefficient_49th = 440.0;

/**
 * Timer is 16384.48935hz, although 16384hz is correct.
 * Using the timer with 16384.48935hz causes the timing with 0.9999701 seconds per calculate.
 * So the frequency obtained is a little lower than actual one.
 */
const float32 calibration = 1.0000299;

char8 special_character_0 [] =
{
	0b00000000,
	0b00000100,
	0b00001110,
	0b00011111,
	0b00000100,
	0b00001110,
	0b00011111,
	0b00000000 // Cursor Position
};

int32 _user_start()
{
	bool flag_flip = true;

	obj zeros = (obj)heap32_malloc( 32768 );
	ObjArray tables_sin = fft32_make_table2d( 32768, false );
	ObjArray tables_cos = fft32_make_table2d( 32768, true );

	_lcdconfig( 22 );
	_lcdinit( false, true );
	_lcddisplay( LCD32_DISPLAY_ON|LCD32_DISPLAY_CURSOR_ON|LCD32_DISPLAY_BLINK_ON );
	_lcdentry( LCD32_ENTRY_INCREMENT|LCD32_ENTRY_SHIFT_CURSOR );
	_lcdposition( 0x40 );
	_lcdstring( "ALOHA!", 6 );
	_lcdhome();
	_lcdchargenerator( 0x08 ); // CGRAM2
	_lcdstring( special_character_0, 8 );
	_lcdposition( 0x04 );
	_lcdstring( "\x1", 1 );
	
	while(True) {
		if ( TUNER_FIQ_FLAG_BACK == flag_flip ) {

			_stopwatch_start();

			flag_flip = flag_flip ^ true;

//print32_debug( flag_flip, 0, 0 );
//print32_debug( TUNER_FIQ_BUFFER, 0, 12 );
//print32_debug_hexa( TUNER_FIQ_BUFFER, 0, 24, 8 );

			// One Set of FFT
			fft32_fft( TUNER_FIQ_BUFFER, zeros, 15, tables_sin, tables_cos );

//print32_debug_hexa( TUNER_FIQ_BUFFER, 0, 48, 8 );

			fft32_change_order( TUNER_FIQ_BUFFER, 32768 );
			fft32_coefficient( TUNER_FIQ_BUFFER, 32768 );
			arm32_dsb();

			// Make Power Spectrum
			fft32_powerspectrum( TUNER_FIQ_BUFFER, 32768 );
			arm32_dsb();

			uint32 index = fft32_index_highest( TUNER_FIQ_BUFFER + 1 * 4, 16384 - 1 ); // Offset 4 Bytes to Omit n=0
print32_debug( index + 1, 100, 100 );

			// Calculate Frequency
			float32 frequency = vfp32_u32tof32( index + 1 );
			frequency = vfp32_fdiv( frequency, 2.0 );
			frequency = vfp32_fmul( frequency, calibration );

			// Calculate Key Number
			float32 keynumber = vfp32_fdiv( frequency, coefficient_49th );
			keynumber = math32_ln( keynumber );
			keynumber = vfp32_fdiv( keynumber, coefficient_ln );
			keynumber = vfp32_fadd( keynumber, 49.0 );
			int32 keynumber_int = vfp32_f32tos32( keynumber );
			if ( keynumber_int > 88 ) keynumber_int = 88;
			if ( keynumber_int < 0) keynumber_int = 0;

			// Get Cent
			float32 cent = vfp32_s32tof32( keynumber_int );
			cent = vfp32_fsub( keynumber, cent );
			cent = vfp32_fmul( cent, 100.0 );
			int32 cent_int = vfp32_f32tos32( cent );
			if ( cent_int > 50 ) cent_int = 50;
			if ( cent_int < -50) cent_int = -50;

print32_debug( keynumber_int, 100, 112 );
print32_debug( cent_int, 100, 124 );
print32_string( scale88_chromatic + ( ( keynumber_int - 1 ) << 2 ), 100, 136, 3 );
print32_string( scale101_cent + ( ( cent_int + 50 ) << 2 ), 100, 148, 3 );

			heap32_mfill( TUNER_FIQ_BUFFER, 0 );
			heap32_mfill( zeros, 0 );

			uint32 time = _stopwatch_end();
print32_debug( time, 0, 36 );
//print32_debug_hexa( TUNER_FIQ_BUFFER, 0, 48, 8 );
//print32_debug_hexa( TUNER_FIQ_BUFFER + 16320 * 4, 0, 72, 260 );
		}
		arm32_dsb();
	}

	return EXIT_SUCCESS;
}
