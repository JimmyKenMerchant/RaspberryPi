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

#define COUNT_BUTTONS 8
#define BUTTON1       20 // GPIO Number

void print_time();

extern bool OS_FIQ_ONESECOND;
extern bool OS_FIQ_ONEFRAME;

int32 count_button1 = COUNT_BUTTONS;

int32 _user_start()
{

	segment_lcd_init( 13, 19, 26 ); // CS GPIO 13, WR GPIO 19, DATA GPIO 26
	segment_lcd_command( 0x01 ); // Oscillator ON
	segment_lcd_command( 0x29 ); // Bias and Common Setting, Bias 1/3, Duty 1/4
	segment_lcd_command( 0x03 ); // LCD ON
	segment_lcd_clear( 0x0 );

	_calender_init( 2018, 1, 1 );
	_clock_init( 21, 59, 30, 0 );
	_correct_utc( -9 );
	_correct_utc( 0 );

	while( True ) {
		if ( OS_FIQ_ONESECOND ) {
			print_time();
			OS_FIQ_ONESECOND = false; // Clear Flag
		}
		if ( OS_FIQ_ONEFRAME ) {
			/**
			 * Push a button takes increment of a value.
			 * Holding a button counts the constant value to zero.
			 * If the count reaches zero, continuous increment will start.
			 */
			if ( _gpio_in( BUTTON1 ) ) {
				if ( count_button1 == COUNT_BUTTONS || count_button1 == 0 ) {
					_clock_init( CLK32_HOUR, CLK32_MINUTE + 1, CLK32_SECOND, 0 );
					print_time();
				}
				if ( --count_button1 < 0 ) count_button1 = 0; // Decrement Count Before, Then Compare with 0
			} else {
				count_button1 = COUNT_BUTTONS;
			}
			OS_FIQ_ONEFRAME = false;
		}
		arm32_dsb();
	}

	return EXIT_SUCCESS;
}

void print_time() {
	_get_time();

	uint64 hour_deci = cvt32_hexa_to_deci( CLK32_HOUR );
	segment_lcd_printn( 0, (hour_deci >> 4) & 0xF, 0x00 );
	segment_lcd_printn( 1, hour_deci & 0xF, 0x00 );

	uint64 minute_deci = cvt32_hexa_to_deci( CLK32_MINUTE );
	segment_lcd_printn( 2, (minute_deci >> 4) & 0xF, 0x00 );
	segment_lcd_printn( 3, minute_deci & 0xF, 0x00 );

	uint64 second_deci = cvt32_hexa_to_deci( CLK32_SECOND );
	segment_lcd_printn( 4, (second_deci >> 4) & 0xF, 0x00 );
	segment_lcd_printn( 5, second_deci & 0xF, 0x00 );
}
