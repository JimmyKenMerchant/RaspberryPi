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
#include "library/segment_lcd.h"
#include "library/segment_lcd.c"

/* Declare Global Variables Exported from vector32.s */
extern bool OS_FIQ_ONEFRAME;

/* Declare Unique Definitions */
#define MAXCOUNT_UPDATE 6  // 2Hz
#define MAXCOUNT_BUTTON 12
#define GPIO_BUTTON1    5  // GPIO Number
#define GPIO_BUTTON2    6  // GPIO Number
#define GPIO_BUTTON3    20 // GPIO Number
#define GPIO_BUTTON4    21 // GPIO Number
#define GPIO_SWITCH1    22 // GPIO Number
#define GPIO_CS         10 // GPIO Number
#define GPIO_WR         9  // GPIO Number
#define GPIO_DATA       11 // GPIO Number

/* Declare Unique Functions */
void print_time();
void print_alarm();
void clear_digit( uint32 digit );

/* Declare Unique Global Variables, Zero Can't Be Stored If You Want to Define with Declaration */
uint32 count_update;
uint32 count_button1;
uint32 count_button2;
uint32 count_button3;
uint32 count_button4;
uint32 alarm_hour;
uint32 alarm_minute;
bool display_blinkon;
bool alarm_musicon;

typedef enum _mode_list {
	display_time,
	change_time_hour,
	change_time_minute,
	display_alarm,
	change_alarm_hour,
	change_alarm_minute
} mode_list;
mode_list current_mode;

/**
 * "Auld Lang Syne", Scottish Folk Song
 * Melody With Arpeggio
 */
music_code music1[] =
{
	_24_DEC(_C4_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_F4_SINL) _24_MAJ_ARP(_F4_SINT) _24_MAJ_ARP(_F4_SINT) _12_DEC(_F4_SINL) _12(_SILENCE) _24_DEC(_F4_SINL) _24_MAJ_ARP(_F4_SINT)
	_24_DEC(_A4_SINL) _24_MAJ_ARP(_C4_SINT) _24_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _12_DEC(_F4_SINL) _12(_SILENCE) _24_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT)
	_24_DEC(_A4_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_F4_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_F4_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_A4_SINL) _24_MAJ_ARP(_F4_SINT)
	_24_DEC(_C5_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_D5_SINL) _24_MAJ_ARP(_AS4_SINT) _24(_D5_SINT) _24_MAJ_ARP(_AS4_SINT) _24(_D5_SINT) _24_MAJ_ARP(_AS4_SINT)

	_24_DEC(_D5_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_C5_SINL) _24_MAJ_ARP(_F4_SINT) _24_MAJ_ARP(_F4_SINT) _12_DEC(_A4_SINL) _12(_SILENCE) _24_DEC(_A4_SINL) _24_MAJ_ARP(_F4_SINT)
	_24_DEC(_F4_SINL) _24_MAJ_ARP(_C4_SINT) _24_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _12_DEC(_F4_SINL) _12(_SILENCE) _24_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT)
	_24_DEC(_A4_SINL) _24_MAJ_ARP(_AS4_SINT) _24_DEC(_F4_SINL) _24_MAJ_ARP(_AS4_SINT) _24_MAJ_ARP(_AS4_SINT) _12_DEC(_D4_SINL) _12(_SILENCE) _24_DEC(_D4_SINL) _24_MAJ_ARP(_AS4_SINT)
	_24_DEC(_C4_SINL) _24_MAJ_ARP(_AS4_SINT) _24_DEC(_F4_SINL) _24_MAJ_ARP(_F4_SINT) _24(_F4_SINT) _24_MAJ_ARP(_F4_SINT) _24(_F4_SINT) _24_MAJ_ARP(_F4_SINT)

	_24_DEC(_D5_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_C5_SINL) _24_MAJ_ARP(_F4_SINT) _24_MAJ_ARP(_F4_SINT) _12_DEC(_A4_SINL) _12(_SILENCE) _24_DEC(_A4_SINL) _24_MAJ_ARP(_F4_SINT)
	_24_DEC(_F4_SINL) _24_MAJ_ARP(_C4_SINT) _24_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _12_DEC(_F4_SINL) _12(_SILENCE) _24_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT)
	_24_DEC(_D5_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_C5_SINL) _24_MAJ_ARP(_F4_SINT) _24_MAJ_ARP(_F4_SINT) _12_DEC(_A4_SINL) _12(_SILENCE) _24_DEC(_A4_SINL) _24_MAJ_ARP(_F4_SINT)
	_24_DEC(_C5_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_D5_SINL) _24_MAJ_ARP(_AS4_SINT) _24(_D5_SINT) _24_MAJ_ARP(_AS4_SINT) _24(_D5_SINT) _24_MAJ_ARP(_AS4_SINT)

	_24_DEC(_D5_SINL) _24_MAJ_ARP(_F4_SINT) _24_DEC(_C5_SINL) _24_MAJ_ARP(_F4_SINT) _24_MAJ_ARP(_F4_SINT) _12_DEC(_A4_SINL) _12(_SILENCE) _24_DEC(_A4_SINL) _24_MAJ_ARP(_F4_SINT)
	_24_DEC(_F4_SINL) _24_MAJ_ARP(_C4_SINT) _24_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT) _24_MAJ_ARP(_C4_SINT) _12_DEC(_F4_SINL) _12(_SILENCE) _24_DEC(_G4_SINL) _24_MAJ_ARP(_C4_SINT)
	_24_DEC(_A4_SINL) _24_MAJ_ARP(_AS4_SINT) _24_DEC(_F4_SINL) _24_MAJ_ARP(_AS4_SINT) _24_MAJ_ARP(_AS4_SINT) _12_DEC(_D4_SINL) _12(_SILENCE) _24_DEC(_D4_SINL) _24_MAJ_ARP(_AS4_SINT)
	_24_DEC(_C4_SINL) _24_MAJ_ARP(_AS4_SINT) _24_DEC(_F4_SINL) _24_MAJ_ARP(_F4_SINT) _24(_F4_SINT) _24_MAJ_ARP(_F4_SINT) _24(_F4_SINT) _24_MAJ_ARP(_F4_SINT)

	_END
};

int32 _user_start()
{
	/**
	 * Initialize Global Variables
	 */
	count_update = 0;
	count_button1 = 0;
	count_button2 = 0;
	count_button3 = 0;
	count_button4 = 0;
	alarm_hour = 0;
	alarm_minute = 0;
	display_blinkon = True;
	alarm_musicon = False;
	current_mode = display_time;

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
	/* Reflects Times to Global Variables about Clock */
	_get_time();

	/**
	 * Initialize Sound
	 */	
	_sounddecode( _SOUND_INDEX, SND32_PWM, _SOUND_ADJUST );
	/* Prevent Popping Noise on Start to Have DC Bias on PWM Mode */
	_soundclear( False );

	// To Get Proper Latency, Get Lengths in Advance
	uint32 musiclen1 = snd32_musiclen( music1 );

	/**
	 * Main Loop
	 */
	while( True ) {
		if ( OS_FIQ_ONEFRAME ) {
			/**
			 * If the count reaches the number, update the display.
			 */
			if ( ++count_update >= MAXCOUNT_UPDATE ) { // Increment Count Before, Then Compare with Number
				if ( current_mode <= change_time_minute ) {
					print_time();
				} else {
					print_alarm();
				}
				if ( display_blinkon ) {
					if ( current_mode == change_time_hour || current_mode == change_alarm_hour ) {
						clear_digit( 0 );
						clear_digit( 1 );
					} else if ( current_mode == change_time_minute || current_mode == change_alarm_minute ) {
						clear_digit( 2 );
						clear_digit( 3 );
					}
					display_blinkon = False;
				} else {
					display_blinkon = True;
				}
				count_update = 0;
			}
			/**
			 * Button No.1:
			 * Pushing a button takes increment of a value.
			 * Holding a button counts the constant value to zero.
			 * If the count reaches zero, continuous increment will start.
			 */
			if ( _gpio_in( GPIO_BUTTON1 ) ) {
				if ( count_button1 == MAXCOUNT_BUTTON || count_button1 == 0 ) {
					if ( current_mode == change_time_hour ) {
						uint32 increment = CLK32_HOUR + 1;
						if ( increment >= 24 ) increment = 0; // Not to Increase Days
						_clock_init( increment, CLK32_MINUTE, 0, 0 );
						print_time();
					} else if ( current_mode == change_time_minute ) {
						uint32 increment = CLK32_MINUTE + 1;
						if ( increment >= 60 ) increment = 0; // Not to Increase Hours
						_clock_init( CLK32_HOUR, increment, 0, 0 );
						print_time();
					} else if ( current_mode == change_alarm_hour ) {
						if ( ++alarm_hour >= 24 ) alarm_hour = 0;
						print_alarm();
					} else if ( current_mode == change_alarm_minute ) {
						if ( ++alarm_minute >= 60 ) alarm_minute = 0;
						print_alarm();
					}
				}
				if ( count_button1 != 0 ) count_button1--;
			} else {
				count_button1 = MAXCOUNT_BUTTON;
			}
			/**
			 * Button No.2:
			 * Pushing a button takes decrement of a value.
			 * Holding a button counts the constant value to zero.
			 * If the count reaches zero, continuous decrement will start.
			 */
			if ( _gpio_in( GPIO_BUTTON2 ) ) {
				if ( count_button2 == MAXCOUNT_BUTTON || count_button2 == 0 ) {

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
					if ( current_mode == display_time ) {
						current_mode = display_alarm;
						print_alarm();
					} else {
						current_mode = display_time;
						print_time();
					}
				}
				if ( count_button3 != 0 ) count_button3--;
			} else {
				count_button3 = MAXCOUNT_BUTTON;
			}
			/**
			 * Button No.4:
			 * Change Subject to Be Incremented or Decremented
			 */
			if ( _gpio_in( GPIO_BUTTON4 ) ) {
				if ( count_button4 == MAXCOUNT_BUTTON ) {
					if ( current_mode == display_time ) { // Time
						current_mode = change_time_hour;
					} else if ( current_mode == change_time_hour ) {
						current_mode = change_time_minute;
					} else if ( current_mode == change_time_minute ) {
						current_mode = display_time;
					} else if ( current_mode == display_alarm ) { // Alarm
						current_mode = change_alarm_hour;
					} else if ( current_mode == change_alarm_hour ) {
						current_mode = change_alarm_minute;
					} else if ( current_mode == change_alarm_minute ) {
						current_mode = display_alarm;
					}
				}
				if ( count_button4 != 0 ) count_button4--;
			} else {
				count_button4 = MAXCOUNT_BUTTON;
			}
			/**
			 * Switch No.1:
			 * If switch is on, the alarm sounds when you set.
			 */
			if ( _gpio_in( GPIO_SWITCH1 ) ) {
				if ( ! alarm_musicon ) {
					if ( CLK32_HOUR == alarm_hour && CLK32_MINUTE == alarm_minute ) {
						_soundset( music1, musiclen1, 0, -1 );
						alarm_musicon = True;
					}
				}
			} else {
				if ( alarm_musicon ) {
					_soundclear( False );
					alarm_musicon = False;
				}
			}
			OS_FIQ_ONEFRAME = False;
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
	clear_digit( 4 );
	clear_digit( 5 );
}

void clear_digit( uint32 digit ) {
	digit *= 2;
	segment_lcd_data( digit, 0x0 );
	segment_lcd_data( digit + 1, 0x0 );
}

