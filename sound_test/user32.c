/**
 * user32.c
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * Usage
 * 1. Place `snd32_soundplay` on FIQ/IRQ Handler which will be triggered with any timer.
 * 2. Place `_sounddecode` with Sound Index as an argument in `user32.c` before `snd32_soundset`.
 * 3. Place `_soundset` with needed arguments in `user32.c`.
 * 4. Music code automatically plays the sound with the assigned values.
 * 5. If you want to interrupt the playing sound to play another, use '_soundinterrupt'.
 * 6. If you want to stop the playing sound, use '_soundclear'.
 */

/**
 * Sound Index is made of an array of 16-bit Blocks.
 * Bit[11:0]: Length of Wave, 0 to 4095.
 *             If Bit[11:0] is 0, Long (0x1F40, Decimal 8000).
 *             If Bit[11:0] is 1, Super Long (0x3E80, Decimal 16000).
 * Bit[13:12]: Volume of Wave, 0 is Max., 1 is Bigger, 2 is Smaller, 3 is Zero (In Noise, Least).
 * Bit[15:14]: Type of Wave, 0 is Sin, 1 is Triangle, 2 is Square, 3 is Noise, ordered by less edges which cause harmonics.
 *
 * Maximum number of blocks is 4096.
 * 0 means End of Sound Index
 */

/**
 * Music Code is 16-bit Blocks. Select up to 4096 sounds indexed by Sound Index.
 * Index is 0-4096.
 * 0xFFFF(65535) means End of Music Code.
 */

#include "system32.h"
#include "system32.c"

sound_index sound[] =
{
	0<<14|0<<12|288, // 0   111.1hz Appx. A2  Sin
	0<<14|0<<12|272, // 1   117.6hz Appx. A#2 Sin
	0<<14|0<<12|257, // 2   124.5hz Appx. B2  Sin
	0<<14|0<<12|242, // 3   132.2hz Appx. C3  Sin
	0<<14|0<<12|229, // 4   139.7hz Appx. C#3 Sin
	0<<14|0<<12|216, // 5   148.1hz Appx. D3  Sin
	0<<14|0<<12|204, // 6   156.9hz Appx. D#3 Sin
	0<<14|0<<12|192, // 7   166.7hz Appx. E3  Sin
	0<<14|0<<12|181, // 8   176.8hz Appx. F3  Sin
	0<<14|0<<12|171, // 9   187.1hz Appx. F#3 Sin
	0<<14|0<<12|162, // 10  197.5hz Appx. G3  Sin
	0<<14|0<<12|153, // 11  209.2hz Appx. G#3 Sin
	0<<14|0<<12|144, // 12  222.2hz Appx. A3  Sin
	0<<14|0<<12|136, // 13  235.3hz Appx. A#3 Sin
	0<<14|0<<12|129, // 14  248.1hz Appx. B3  Sin
	0<<14|0<<12|121, // 15  264.5hz Appx. C4  Sin
	0<<14|0<<12|114, // 16  280.7hz Appx. C#4 Sin
	0<<14|0<<12|108, // 17  296.3hz Appx. D4  Sin
	0<<14|0<<12|102, // 18  313.7hz Appx. D#4 Sin
	0<<14|0<<12|96,  // 19  333.3hz Appx. E4  Sin
	0<<14|0<<12|91,  // 20  351.6hz Appx. F4  Sin
	0<<14|0<<12|86,  // 21  372.1hz Appx. F#4 Sin
	0<<14|0<<12|81,  // 22  395.1hz Appx. G4  Sin
	0<<14|0<<12|76,  // 23  421.1hz Appx. G#4 Sin
	0<<14|0<<12|72,  // 24  444.4hz Appx. A4  Sin
	0<<14|0<<12|68,  // 25  470.6hz Appx. A#4 Sin
	0<<14|0<<12|64,  // 26  500.0hz Appx. B4  Sin
	0<<14|0<<12|61,  // 27  524.6hz Appx. C5  Sin
	0<<14|0<<12|57,  // 28  561.4hz Appx. C#5 Sin
	0<<14|0<<12|54,  // 29  592.6hz Appx. D5  Sin
	0<<14|0<<12|51,  // 30  627.5hz Appx. D#5 Sin
	0<<14|0<<12|48,  // 31  666.7hz Appx. E5  Sin
	0<<14|0<<12|46,  // 32  695.7hz Appx. F5  Sin
	0<<14|0<<12|43,  // 33  744.2hz Appx. F#5 Sin
	0<<14|0<<12|41,  // 34  780.5hz Appx. G5  Sin
	0<<14|0<<12|38,  // 35  842.1hz Appx. G#5 Sin
	0<<14|0<<12|36,  // 36  888.9hz Appx. A5  Sin
	0<<14|0<<12|34,  // 37  941.2hz Appx. A#5 Sin
	0<<14|0<<12|32,  // 38 1000.0hz Appx. B5  Sin
	0<<14|0<<12|30,  // 39 1066.3hz Appx. C6  Sin

	1<<14|0<<12|288, // 40  111.1hz Appx. A2  Triangle
	1<<14|0<<12|272, // 41  117.6hz Appx. A#2 Triangle
	1<<14|0<<12|257, // 42  124.5hz Appx. B2  Triangle
	1<<14|0<<12|242, // 43  132.2hz Appx. C3  Triangle
	1<<14|0<<12|229, // 44  139.7hz Appx. C#3 Triangle
	1<<14|0<<12|216, // 45  148.1hz Appx. D3  Triangle
	1<<14|0<<12|204, // 46  156.9hz Appx. D#3 Triangle
	1<<14|0<<12|192, // 47  166.7hz Appx. E3  Triangle
	1<<14|0<<12|181, // 48  176.8hz Appx. F3  Triangle
	1<<14|0<<12|171, // 49  187.1hz Appx. F#3 Triangle
	1<<14|0<<12|162, // 50  197.5hz Appx. G3  Triangle
	1<<14|0<<12|153, // 51  209.2hz Appx. G#3 Triangle
	1<<14|0<<12|144, // 52  222.2hz Appx. A3  Triangle
	1<<14|0<<12|136, // 53  235.3hz Appx. A#3 Triangle
	1<<14|0<<12|129, // 54  248.1hz Appx. B3  Triangle
	1<<14|0<<12|121, // 55  264.5hz Appx. C4  Triangle
	1<<14|0<<12|114, // 56  280.7hz Appx. C#4 Triangle
	1<<14|0<<12|108, // 57  296.3hz Appx. D4  Triangle
	1<<14|0<<12|102, // 58  313.7hz Appx. D#4 Triangle
	1<<14|0<<12|96,  // 59  333.3hz Appx. E4  Triangle
	1<<14|0<<12|91,  // 60  351.6hz Appx. F4  Triangle
	1<<14|0<<12|86,  // 61  372.1hz Appx. F#4 Triangle
	1<<14|0<<12|81,  // 62  395.1hz Appx. G4  Triangle
	1<<14|0<<12|76,  // 63  421.1hz Appx. G#4 Triangle
	1<<14|0<<12|72,  // 64  444.4hz Appx. A4  Triangle
	1<<14|0<<12|68,  // 65  470.6hz Appx. A#4 Triangle
	1<<14|0<<12|64,  // 66  500.0hz Appx. B4  Triangle
	1<<14|0<<12|61,  // 67  524.6hz Appx. C5  Triangle
	1<<14|0<<12|57,  // 68  561.4hz Appx. C#5 Triangle
	1<<14|0<<12|54,  // 69  592.6hz Appx. D5  Triangle
	1<<14|0<<12|51,  // 70  627.5hz Appx. D#5 Triangle
	1<<14|0<<12|48,  // 71  666.7hz Appx. E5  Triangle
	1<<14|0<<12|46,  // 72  695.7hz Appx. F5  Triangle
	1<<14|0<<12|43,  // 73  744.2hz Appx. F#5 Triangle
	1<<14|0<<12|41,  // 74  780.5hz Appx. G5  Triangle
	1<<14|0<<12|38,  // 75  842.1hz Appx. G#5 Triangle
	1<<14|0<<12|36,  // 76  888.9hz Appx. A5  Triangle
	1<<14|0<<12|34,  // 77  941.2hz Appx. A#5 Triangle
	1<<14|0<<12|32,  // 78 1000.0hz Appx. B5  Triangle
	1<<14|0<<12|30,  // 79 1066.3hz Appx. C6  Triangle

	2<<14|0<<12|288, // 80   111.1hz Appx. A2  Square
	2<<14|0<<12|272, // 81   117.6hz Appx. A#2 Square
	2<<14|0<<12|257, // 82   124.5hz Appx. B2  Square
	2<<14|0<<12|242, // 83   132.2hz Appx. C3  Square
	2<<14|0<<12|229, // 84   139.7hz Appx. C#3 Square
	2<<14|0<<12|216, // 85   148.1hz Appx. D3  Square
	2<<14|0<<12|204, // 86   156.9hz Appx. D#3 Square
	2<<14|0<<12|192, // 87   166.7hz Appx. E3  Square
	2<<14|0<<12|181, // 88   176.8hz Appx. F3  Square
	2<<14|0<<12|171, // 89   187.1hz Appx. F#3 Square
	2<<14|0<<12|162, // 90   197.5hz Appx. G3  Square
	2<<14|0<<12|153, // 91   209.2hz Appx. G#3 Square
	2<<14|0<<12|144, // 92   222.2hz Appx. A3  Square
	2<<14|0<<12|136, // 93   235.3hz Appx. A#3 Square
	2<<14|0<<12|129, // 94   248.1hz Appx. B3  Square
	2<<14|0<<12|121, // 95   264.5hz Appx. C4  Square
	2<<14|0<<12|114, // 96   280.7hz Appx. C#4 Square
	2<<14|0<<12|108, // 97   296.3hz Appx. D4  Square
	2<<14|0<<12|102, // 98   313.7hz Appx. D#4 Square
	2<<14|0<<12|96,  // 99   333.3hz Appx. E4  Square
	2<<14|0<<12|91,  // 100  351.6hz Appx. F4  Square
	2<<14|0<<12|86,  // 101  372.1hz Appx. F#4 Square
	2<<14|0<<12|81,  // 102  395.1hz Appx. G4  Square
	2<<14|0<<12|76,  // 103  421.1hz Appx. G#4 Square
	2<<14|0<<12|72,  // 104  444.4hz Appx. A4  Square
	2<<14|0<<12|68,  // 105  470.6hz Appx. A#4 Square
	2<<14|0<<12|64,  // 106  500.0hz Appx. B4  Square
	2<<14|0<<12|61,  // 107  524.6hz Appx. C5  Square
	2<<14|0<<12|57,  // 108  561.4hz Appx. C#5 Square
	2<<14|0<<12|54,  // 109  592.6hz Appx. D5  Square
	2<<14|0<<12|51,  // 110  627.5hz Appx. D#5 Square
	2<<14|0<<12|48,  // 111  666.7hz Appx. E5  Square
	2<<14|0<<12|46,  // 112  695.7hz Appx. F5  Square
	2<<14|0<<12|43,  // 113  744.2hz Appx. F#5 Square
	2<<14|0<<12|41,  // 114  780.5hz Appx. G5  Square
	2<<14|0<<12|38,  // 115  842.1hz Appx. G#5 Square
	2<<14|0<<12|36,  // 116  888.9hz Appx. A5  Square
	2<<14|0<<12|34,  // 117  941.2hz Appx. A#5 Square
	2<<14|0<<12|32,  // 118 1000.0hz Appx. B5  Square
	2<<14|0<<12|30,  // 119 1066.3hz Appx. C6  Square

	3<<14|0<<12|288, // 120  111.1hz Appx. A2  Noise
	3<<14|0<<12|272, // 121  117.6hz Appx. A#2 Noise
	3<<14|0<<12|257, // 122  124.5hz Appx. B2  Noise
	3<<14|0<<12|242, // 123  132.2hz Appx. C3  Noise
	3<<14|0<<12|229, // 124  139.7hz Appx. C#3 Noise
	3<<14|0<<12|216, // 125  148.1hz Appx. D3  Noise
	3<<14|0<<12|204, // 126  156.9hz Appx. D#3 Noise
	3<<14|0<<12|192, // 127  166.7hz Appx. E3  Noise
	3<<14|0<<12|181, // 128  176.8hz Appx. F3  Noise
	3<<14|0<<12|171, // 129  187.1hz Appx. F#3 Noise
	3<<14|0<<12|162, // 130  197.5hz Appx. G3  Noise
	3<<14|0<<12|153, // 131  209.2hz Appx. G#3 Noise
	3<<14|0<<12|144, // 132  222.2hz Appx. A3  Noise
	3<<14|0<<12|136, // 133  235.3hz Appx. A#3 Noise
	3<<14|0<<12|129, // 134  248.1hz Appx. B3  Noise
	3<<14|0<<12|121, // 135  264.5hz Appx. C4  Noise
	3<<14|0<<12|114, // 136  280.7hz Appx. C#4 Noise
	3<<14|0<<12|108, // 137  296.3hz Appx. D4  Noise
	3<<14|0<<12|102, // 138  313.7hz Appx. D#4 Noise
	3<<14|0<<12|96,  // 139  333.3hz Appx. E4  Noise
	3<<14|0<<12|91,  // 140  351.6hz Appx. F4  Noise
	3<<14|0<<12|86,  // 141  372.1hz Appx. F#4 Noise
	3<<14|0<<12|81,  // 142  395.1hz Appx. G4  Noise
	3<<14|0<<12|76,  // 143  421.1hz Appx. G#4 Noise
	3<<14|0<<12|72,  // 144  444.4hz Appx. A4  Noise
	3<<14|0<<12|68,  // 145  470.6hz Appx. A#4 Noise
	3<<14|0<<12|64,  // 146  500.0hz Appx. B4  Noise
	3<<14|0<<12|61,  // 147  524.6hz Appx. C5  Noise
	3<<14|0<<12|57,  // 148  561.4hz Appx. C#5 Noise
	3<<14|0<<12|54,  // 149  592.6hz Appx. D5  Noise
	3<<14|0<<12|51,  // 150  627.5hz Appx. D#5 Noise
	3<<14|0<<12|48,  // 151  666.7hz Appx. E5  Noise
	3<<14|0<<12|46,  // 152  695.7hz Appx. F5  Noise
	3<<14|0<<12|43,  // 153  744.2hz Appx. F#5 Noise
	3<<14|0<<12|41,  // 154  780.5hz Appx. G5  Noise
	3<<14|0<<12|38,  // 155  842.1hz Appx. G#5 Noise
	3<<14|0<<12|36,  // 156  888.9hz Appx. A5  Noise
	3<<14|0<<12|34,  // 157  941.2hz Appx. A#5 Noise
	3<<14|0<<12|32,  // 158 1000.0hz Appx. B5  Noise
	3<<14|0<<12|30,  // 159 1066.3hz Appx. C6  Noise

	3<<14|2<<12|0,   // 160 Long Noise
	2<<14|3<<12|36,  // 161 Silence 
	0                // End of Index
};

music_code music1[] =
{
	  3,  5,  7,  8, 10, 12, 14, 15, 10, 10, 10, 10,
	161,161, 10,  7,  3, 10,  7,  3,  8, 10, 12, 14,
	 15, 15, 15, 15, 10, 10, 10, 10,  7,  7,  7,  7,
	  3,  3,  3,  3,  3,  3,  3,  3,161,161,161,161,
	161,161,161,161,161,161,161,161,161,161,161,161,
	0xFFFF
};

music_code music2[] =
{
	9,8,7,6,5,4,3,4,5,6,7,8,
	9,9,9,9,9,9,8,8,8,8,8,8,
	7,7,7,7,7,7,6,6,6,6,6,6,
	5,5,4,4,3,3,3,3,4,4,5,5,
	0xFFFF
};

music_code music3[] =
{
	160,
	0xFFFF
};

music_code interrupt1[] =
{
	7,8,9,7,8,9,7,8,9,7,8,9,
	0xFFFF
};

int32 _user_start()
{
	String str_ready = "Get Ready?\0";
	String str_music1 = "Music No.1\0";
	String str_music2 = "Music No.2\0";
	String str_music3 = "Music No.3\0";

	_sounddecode( sound );

	print32_string( str_ready, 300, 300, str32_strlen( str_ready ) );

	while(true) {
		while( true ) {
			if ( _gpio_detect( 20 ) ) {
				_soundclear();
				print32_string( str_ready, 300, 300, str32_strlen( str_ready ) );
				break;
			}
			if ( _gpio_detect( 21 ) ) {
				_soundset( music1, snd32_musiclen( music1 ) , 0, -1 );
				print32_string( str_music1, 300, 300, str32_strlen( str_music1 ) );
				break;
			}
			if ( _gpio_detect( 22 ) ) {
				_soundset( music2, snd32_musiclen( music2 ) , 0, -1 );
				print32_string( str_music2, 300, 300, str32_strlen( str_music2 ) );
				break;
			}
			if ( _gpio_detect( 23 ) ) {
				_soundset( music3, snd32_musiclen( music3 ) , 0, -1 );
				print32_string( str_music3, 300, 300, str32_strlen( str_music3 ) );
				break;
			}
			if ( _gpio_detect( 24 ) ) {
				break;
			}
			if ( _gpio_detect( 25 ) ) {
				break;
			}
			if ( _gpio_detect( 26 ) ) {
				break;
			}
			if ( _gpio_detect( 27 ) ) {
				_soundinterrupt( interrupt1, snd32_musiclen( interrupt1 ) , 0, 1 );
				break;
			}
		}
	}

	return EXIT_SUCCESS;
}
