/**
 * segment_lcd.h
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

#define SEGMENT_LCD_PULSE_WIDTH    20  // RD/WR Clock, Microseconds
#define SEGMENT_LCD_CHARS_MAX      16 // Limiter
#define SEGMENT_LCD_START_LENGTH   3  // Bits
#define SEGMENT_LCD_COMMAND_LENGTH 8  // Bits
#define SEGMENT_LCD_ADDRESS_LENGTH 6  // Bits
#define SEGMENT_LCD_DATA_LENGTH    4  // Bits

const uchar8 segment_lcd_chars[] = {
	0b01111101, // 0
	0b01100000, // 1
	0b00111110, // 2
	0b01111010, // 3
	0b01100011, // 4
	0b01011011, // 5
	0b01011111, // 6
	0b01110000, // 7
	0b01111111, // 8
	0b01110011, // 9
	0b11111111, // A
	0b11111111, // B
	0b11111111, // C
	0b11111111, // D
	0b11111111, // E
	0b11111111  // F
};

uchar8 segment_lcd_gpio_cs;   // Inverted
uchar8 segment_lcd_gpio_rd;   // Inverted
uchar8 segment_lcd_gpio_wr;   // Inverted
uchar8 segment_lcd_gpio_data;

void segment_lcd_init( uchar8 gpio_cs, uchar8 gpio_rd, uchar8 gpio_wr, uchar8 gpio_data );
void segment_lcd_reset();
void segment_lcd_write( uchar8 data, uchar8 length_bits );
void segment_lcd_command( uchar8 command );
void segment_lcd_data( uchar8 address, uchar8 data );
void segment_lcd_char( uchar8 digit, uchar8 number_char );
