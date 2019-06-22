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

/* Global Variables from Included Libraries */
extern bool OS_FIQ_ONEFRAME;

/* Unique Definitions */
#define MAXCOUNT_UPDATE 12 // 1Hz
#define MAXCOUNT_BUTTON 12
#define GPIO_BUTTON1    20 // GPIO Number
#define GPIO_BUTTON2    21 // GPIO Number
#define GPIO_BUTTON3    16 // GPIO Number
#define GPIO_SWITCH1    22 // GPIO Number
#define GPIO_CS         13 // GPIO Number
#define GPIO_WR         19 // GPIO Number
#define GPIO_DATA       26 // GPIO Number

/* Unique Functions */
void print_time();
void print_alarm();

/* Unique Global Variables, Zero Can't Be Stored on Declaration */
uint32 count_update;
uint32 count_button1;
uint32 count_button2;
uint32 count_button3;
uint32 alarm_hour;
uint32 alarm_minute;
bool mode_time;

int32 _user_start()
{
	/**
	 * Initialize Global Variables
	 */
	count_update = 0;
	count_button1 = 0;
	count_button2 = 0;
	count_button3 = 0;
	alarm_hour = 0;
	alarm_minute = 0;
	mode_time = true;

	/**
	 * I/O Settings
	 */
	_gpiomode( GPIO_BUTTON1, _GPIOMODE_IN );
	_gpiomode( GPIO_BUTTON2, _GPIOMODE_IN );
	_gpiomode( GPIO_BUTTON3, _GPIOMODE_IN );
	_gpiomode( GPIO_SWITCH1, _GPIOMODE_IN );

	/**
	 * Initialize Segment LCD
	 */
	segment_lcd_init( GPIO_CS, GPIO_WR, GPIO_DATA ); // CS GPIO 13, WR GPIO 19, DATA GPIO 26
	segment_lcd_command( 0x01 ); // Oscillator ON
	segment_lcd_command( 0x29 ); // Bias and Common Setting, Bias 1/3, Duty 1/4
	segment_lcd_command( 0x03 ); // LCD ON
	segment_lcd_clear( 0x0 );

	/**
	 * Initialize Clock
	 */
	_calender_init( 2018, 1, 1 );
	_clock_init( 21, 59, 30, 0 );
	_correct_utc( -9 );
	_correct_utc( 0 );

	/**
	 * Main Loop
	 */
	while( True ) {
		if ( OS_FIQ_ONEFRAME ) {
			/**
			 * If the count reaches the number, update the display.
			 */
			if ( ++count_update >= MAXCOUNT_UPDATE ) { // Increment Count Before, Then Compare with Number
				if ( mode_time ) { 
					print_time();
				} else {
					print_alarm();
				}
				count_update = 0;
			}
			/**
			 * Button No.1 (Minute) and Button No.2 (Hour):
			 * Pushing a button takes increment of a value.
			 * Holding a button counts the constant value to zero.
			 * If the count reaches zero, continuous increment will start.
			 */
			if ( _gpio_in( GPIO_BUTTON1 ) ) {
				if ( count_button1 == MAXCOUNT_BUTTON || count_button1 == 0 ) {
					if ( mode_time ) {
						uint32 increment = CLK32_MINUTE + 1;
						if ( increment >= 60 ) increment = 0; // Not to Increase Hours
						_clock_init( CLK32_HOUR, increment, 0, 0 );
						print_time();
					} else {
						if ( ++alarm_minute >= 60 ) alarm_minute = 0;
						print_alarm();
					}

				}
				if ( count_button1 != 0 ) count_button1--;
			} else {
				count_button1 = MAXCOUNT_BUTTON;
			}
			if ( _gpio_in( GPIO_BUTTON2 ) ) {
				if ( count_button2 == MAXCOUNT_BUTTON || count_button2 == 0 ) {
					if ( mode_time ) {
						uint32 increment = CLK32_HOUR + 1;
						if ( increment >= 24 ) increment = 0; // Not to Increase Days
						_clock_init( increment, CLK32_MINUTE, 0, 0 );
						print_time();
					} else {
						if ( ++alarm_hour >= 24 ) alarm_hour = 0;
						print_alarm();
					}
				}
				if ( count_button2 != 0 ) count_button2--;
			} else {
				count_button2 = MAXCOUNT_BUTTON;
			}
			/**
			 * Button No.3:
			 * Toggle Display Mode Between Actual Time and Alarm Time
			 */
			if ( _gpio_in( GPIO_BUTTON3 ) ) {
				if ( count_button3 == MAXCOUNT_BUTTON ) {
					if ( mode_time ) {
						mode_time = false;
						print_alarm();
					} else {
						mode_time = true;
						print_time();
					}
				}
				if ( count_button3 != 0 ) count_button3--;
			} else {
				count_button3 = MAXCOUNT_BUTTON;
			}
			OS_FIQ_ONEFRAME = false;
		}
		arm32_dsb();
	}
	return EXIT_SUCCESS;
}

void print_time() {
	/* Update TIme */
	_get_time();
	/* Display Hour */
	uint64 hour_deci = cvt32_hexa_to_deci( CLK32_HOUR );
	segment_lcd_printn( 0, (hour_deci >> 4) & 0xF, 0x00 );
	segment_lcd_printn( 1, hour_deci & 0xF, 0x00 );
	/* Display Minute */
	uint64 minute_deci = cvt32_hexa_to_deci( CLK32_MINUTE );
	segment_lcd_printn( 2, (minute_deci >> 4) & 0xF, 0x00 );
	segment_lcd_printn( 3, minute_deci & 0xF, 0x00 );
	/* Display Second */
	uint64 second_deci = cvt32_hexa_to_deci( CLK32_SECOND );
	segment_lcd_printn( 4, (second_deci >> 4) & 0xF, 0x00 );
	segment_lcd_printn( 5, second_deci & 0xF, 0x00 );
}

void print_alarm() {
	/* Display Hour to Alarm */
	uint64 hour_deci = cvt32_hexa_to_deci( alarm_hour );
	segment_lcd_printn( 0, (hour_deci >> 4) & 0xF, 0x00 );
	segment_lcd_printn( 1, hour_deci & 0xF, 0x00 );
	/* Display Minute to Alarm */
	uint64 minute_deci = cvt32_hexa_to_deci( alarm_minute );
	segment_lcd_printn( 2, (minute_deci >> 4) & 0xF, 0x00 );
	segment_lcd_printn( 3, minute_deci & 0xF, 0x00 );
	/* Clear Digit for Second */
	segment_lcd_data( 8, 0x0 );
	segment_lcd_data( 9, 0x0 );
	segment_lcd_data( 10, 0x0 );
	segment_lcd_data( 11, 0x0 );
}
