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

	segment_lcd_init( 6, 13, 19, 26 );
	segment_lcd_command( 0x01 ); // Oscillator ON
	segment_lcd_command( 0x29 ); // Bias and Common Setting, Bias 1/3, Duty 1/4
	segment_lcd_command( 0x03 ); // LCD ON
	segment_lcd_data( 0, 0xF );
	segment_lcd_data( 1, 0xF );
	//segment_lcd_reset();

	while( True ) {
		// If GPIO 20 Detects Voltage, GPIO 21 Keeps Lighting
		if ( _gpio_in( 20 ) ) _gpiotoggle( 21, _GPIOTOGGLE_HIGH );

		_sleep( 1000 ); // Wait for 1000 Microseconds
	}

	return EXIT_SUCCESS;
}
