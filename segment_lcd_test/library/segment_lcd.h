/**
 * segment_lcd.h
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */
 
 /**
  * This library is intended to be used with HT1621, a segment LCD driver.
  * HT1621 has 32 segments and 4 commons. I consider this library for the usage with others of HT162x and HT163x (LCD Driver).
  * If RD pin exists in your module, you need to externally pull-up this pin, i.e, connect VDD with RD through a resistor.
  */

#define SEGMENT_LCD_PULSE_WIDTH    10 // WR Clock, Microseconds
#define SEGMENT_LCD_CHARS_MAX      16 // Limiter
#define SEGMENT_LCD_START_LENGTH   3  // Bits
#define SEGMENT_LCD_COMMAND_LENGTH 8  // Bits
#define SEGMENT_LCD_ADDRESS_LENGTH 6  // GRAM Address, Bits
#define SEGMENT_LCD_DATA_LENGTH    4  // Bits
#define SEGMENT_LCD_GRAM_SIZE      32 // Available Spaces in GRAM

/**
 * It varies on each module, typical ones are shown.
 * Least significant 4 bits are for the first space, most significant 4 bits are for the second space.
 */
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
	0b01110111, // A
	0b01001111, // B
	0b00001110, // C
	0b01101110, // D
	0b00011111, // E
	0b00010111  // F
};

uchar8 segment_lcd_gpio_cs;   // Inverted
uchar8 segment_lcd_gpio_wr;   // Inverted
uchar8 segment_lcd_gpio_data;

void segment_lcd_init( uchar8 gpio_cs, uchar8 gpio_wr, uchar8 gpio_data ); // Initialization
void segment_lcd_reset();                                                  // All Pins Go to High
void segment_lcd_write( uchar8 bits, uchar8 length_bits );                 // Write Bits in Sending Procedure
void segment_lcd_command( uchar8 command );                                // Send Command
void segment_lcd_data( uchar8 address, uchar8 data );                      // Send Data to GRAM
void segment_lcd_char( uchar8 digit, uchar8 number_char );                 // Show Character Used Two Spaces in GRAM
void segment_lcd_clear( uchar8 data );                                     // Clear All Spaces in GRAM

