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
#include "library/segment_lcd.h"
#include "library/segment_lcd.c"

int32 _user_start()
{
	_gpiomode( 20, _GPIOMODE_IN );
	//_gpiomode( 21, _GPIOMODE_OUT ); // Already Set in vector32.s

	segment_lcd_init( 13, 19, 26 ); // CS GPIO 13, WR GPIO 19, DATA GPIO 26
	segment_lcd_command( 0x01 ); // Oscillator ON
	segment_lcd_command( 0x29 ); // Bias and Common Setting, Bias 1/3, Duty 1/4
	segment_lcd_command( 0x03 ); // LCD ON
	segment_lcd_clear( 0x0 );

	_calender_init( 2018, 1, 1 );
	_clock_init( 22, 59, 30, 0 );
	_correct_utc( -9 );
	_correct_utc( 0 );

	while( True ) {
		_get_time();

		uint64 hour_deci = cvt32_hexa_to_deci( CLK32_HOUR );
		segment_lcd_printn( 0, (hour_deci >> 4) & 0xF );
		segment_lcd_printn( 1, hour_deci & 0xF );

		uint64 minute_deci = cvt32_hexa_to_deci( CLK32_MINUTE );
		segment_lcd_printn( 2, (minute_deci >> 4) & 0xF );
		segment_lcd_printn( 3, minute_deci & 0xF );

		uint64 second_deci = cvt32_hexa_to_deci( CLK32_SECOND );
		segment_lcd_printn( 4, (second_deci >> 4) & 0xF );
		segment_lcd_printn( 5, second_deci & 0xF );

		// If GPIO 20 Detects Voltage, GPIO 21 Keeps Lighting
		if ( _gpio_in( 20 ) ) _gpiotoggle( 21, _GPIOTOGGLE_HIGH );

		_sleep( 1000000 ); // Wait for 1000 Microseconds
	}

	return EXIT_SUCCESS;
}
