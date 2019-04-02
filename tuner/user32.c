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
