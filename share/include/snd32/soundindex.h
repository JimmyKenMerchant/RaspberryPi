/**
 * snd32/soundindex.h
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * This header file is for the convenience of using functions in ../(asterisk)/system32/library/snd32.s
 * Because of the purpose, names of constants are abbreviated and less considered of naming conventions.
 * Be careful of naming conventions with constants in other header files.
 */

/**
 * Sound Index is made of an array of 16-bit Blocks.
 * Bit[10:0]: Length of Wave, 0 to 2048.
 *             If Bit[11:0] is 0, Long (0x1F40, Decimal 8000).
 *             If Bit[11:0] is 1, Super Long (0x3E80, Decimal 16000).
 * Bit[12:11]: Volume of Wave, 0 is Large, 1 is Medium, 2 is Small, 3 is Tiny
 * Bit[15:13]: Type of Wave, 0 is Sine, 1 is Saw Tooth, 2 is Square, 3 is Noise, ordered by less edges which cause harmonics. 7 is Silence.
 *
 * Maximum number of blocks is 4096.
 * 0 means End of Sound Index
 */

/**
 * These comments about frequencies assume 3.2Khz as the sampling rate, using on PWM direct output (including from 3.5mm minijack).
 * The actual sampling rate is appx. 3.168Khz to be adjusted to fit A4 on 440hz, e.g., G4 becomes 391.1Hz.
 */
sound_index _SOUND_INDEX[] =
{
	/* Volume Large */

	0<<13|0<<11|581, // 0x00  55.08hz Appx. A1  Sin
	0<<13|0<<11|548, // 0x01  58.39hz Appx. A#1 Sin
	0<<13|0<<11|518, // 0x02  61.78hz Appx. B1  Sin
	0<<13|0<<11|489, // 0x03  65.44hz Appx. C2  Sin
	0<<13|0<<11|461, // 0x04  69.41hz Appx. C#2 Sin
	0<<13|0<<11|435, // 0x05  73.56hz Appx. D2  Sin
	0<<13|0<<11|411, // 0x06  77.86hz Appx. D#2 Sin
	0<<13|0<<11|388, // 0x07  82.47hz Appx. E2  Sin
	0<<13|0<<11|366, // 0x08  87.43hz Appx. F2  Sin
	0<<13|0<<11|345, // 0x09  92.75hz Appx. F#2 Sin
	0<<13|0<<11|326, // 0x0A  98.16hz Appx. G2  Sin
	0<<13|0<<11|308, // 0x0B  103.9hz Appx. G#2 Sin
	0<<13|0<<11|288, // 0x0C  111.1hz Appx. A2  Sin
	0<<13|0<<11|272, // 0x0D  117.6hz Appx. A#2 Sin
	0<<13|0<<11|257, // 0x0E  124.5hz Appx. B2  Sin
	0<<13|0<<11|242, // 0x0F  132.2hz Appx. C3  Sin
	0<<13|0<<11|229, // 0x10  139.7hz Appx. C#3 Sin
	0<<13|0<<11|216, // 0x11  148.1hz Appx. D3  Sin
	0<<13|0<<11|204, // 0x12  156.9hz Appx. D#3 Sin
	0<<13|0<<11|192, // 0x13  166.7hz Appx. E3  Sin
	0<<13|0<<11|181, // 0x14  176.8hz Appx. F3  Sin
	0<<13|0<<11|171, // 0x15  187.1hz Appx. F#3 Sin
	0<<13|0<<11|162, // 0x16  197.5hz Appx. G3  Sin
	0<<13|0<<11|153, // 0x17  209.2hz Appx. G#3 Sin
	0<<13|0<<11|144, // 0x18  222.2hz Appx. A3  Sin
	0<<13|0<<11|136, // 0x19  235.3hz Appx. A#3 Sin
	0<<13|0<<11|129, // 0x1A  248.1hz Appx. B3  Sin
	0<<13|0<<11|121, // 0x1B  264.5hz Appx. C4  Sin
	0<<13|0<<11|114, // 0x1C  280.7hz Appx. C#4 Sin
	0<<13|0<<11|108, // 0x1D  296.3hz Appx. D4  Sin
	0<<13|0<<11|102, // 0x1E  313.7hz Appx. D#4 Sin
	0<<13|0<<11|96,  // 0x1F  333.3hz Appx. E4  Sin
	0<<13|0<<11|91,  // 0x20  351.6hz Appx. F4  Sin
	0<<13|0<<11|86,  // 0x21  372.1hz Appx. F#4 Sin
	0<<13|0<<11|81,  // 0x22  395.1hz Appx. G4  Sin
	0<<13|0<<11|76,  // 0x23  421.1hz Appx. G#4 Sin
	0<<13|0<<11|72,  // 0x24  444.4hz Appx. A4  Sin
	0<<13|0<<11|68,  // 0x25  470.6hz Appx. A#4 Sin
	0<<13|0<<11|64,  // 0x26  500.0hz Appx. B4  Sin
	0<<13|0<<11|61,  // 0x27  524.6hz Appx. C5  Sin
	0<<13|0<<11|57,  // 0x28  561.4hz Appx. C#5 Sin
	0<<13|0<<11|54,  // 0x29  592.6hz Appx. D5  Sin
	0<<13|0<<11|51,  // 0x2A  627.5hz Appx. D#5 Sin
	0<<13|0<<11|48,  // 0x2B  666.7hz Appx. E5  Sin
	0<<13|0<<11|46,  // 0x2C  695.7hz Appx. F5  Sin
	0<<13|0<<11|43,  // 0x2D  744.2hz Appx. F#5 Sin
	0<<13|0<<11|41,  // 0x2E  780.5hz Appx. G5  Sin
	0<<13|0<<11|38,  // 0x2F  842.1hz Appx. G#5 Sin
	0<<13|0<<11|36,  // 0x30  888.9hz Appx. A5  Sin
	0<<13|0<<11|34,  // 0x31  941.2hz Appx. A#5 Sin
	0<<13|0<<11|32,  // 0x32 1000.0hz Appx. B5  Sin
	0<<13|0<<11|30,  // 0x33 1066.7hz Appx. C6  Sin
	0<<13|0<<11|29,  // 0x34 1103.4hz Appx. C#6 Sin
	0<<13|0<<11|27,  // 0x35 1185.2hz Appx. D6  Sin
	0<<13|0<<11|26,  // 0x36 1230.8hz Appx. D#6 Sin
	0<<13|0<<11|24,  // 0x37 1333.3hz Appx. E6  Sin
	0<<13|0<<11|23,  // 0x38 1391.3hz Appx. F6  Sin
	0<<13|0<<11|22,  // 0x39 1454.5hz Appx. F#6 Sin
	0<<13|0<<11|20,  // 0x3A 1600.0hz Appx. G6  Sin
	0<<13|0<<11|19,  // 0x3B 1684.2hz Appx. G#6 Sin
	0<<13|0<<11|18,  // 0x3C 1777.8hz Appx. A6  Sin
	0<<13|0<<11|17,  // 0x3D 1882.4hz Appx. A#6 Sin
	0<<13|0<<11|16,  // 0x3E 2000.0hz Appx. B6  Sin
	0<<13|0<<11|15,  // 0x3F 2133.3hz Appx. C7  Sin

	1<<13|0<<11|581, // 0x40  55.08hz Appx. A1  Saw Tooth
	1<<13|0<<11|548, // 0x41  58.39hz Appx. A#1 Saw Tooth
	1<<13|0<<11|518, // 0x42  61.78hz Appx. B1  Saw Tooth
	1<<13|0<<11|489, // 0x43  65.44hz Appx. C2  Saw Tooth
	1<<13|0<<11|461, // 0x44  69.41hz Appx. C#2 Saw Tooth
	1<<13|0<<11|435, // 0x45  73.56hz Appx. D2  Saw Tooth
	1<<13|0<<11|411, // 0x46  77.86hz Appx. D#2 Saw Tooth
	1<<13|0<<11|388, // 0x47  82.47hz Appx. E2  Saw Tooth
	1<<13|0<<11|366, // 0x48  87.43hz Appx. F2  Saw Tooth
	1<<13|0<<11|345, // 0x49  92.75hz Appx. F#2 Saw Tooth
	1<<13|0<<11|326, // 0x4A  98.16hz Appx. G2  Saw Tooth
	1<<13|0<<11|308, // 0x4B  103.9hz Appx. G#2 Saw Tooth
	1<<13|0<<11|288, // 0x4C  111.1hz Appx. A2  Saw Tooth
	1<<13|0<<11|272, // 0x4D  117.6hz Appx. A#2 Saw Tooth
	1<<13|0<<11|257, // 0x4E  124.5hz Appx. B2  Saw Tooth
	1<<13|0<<11|242, // 0x4F  132.2hz Appx. C3  Saw Tooth
	1<<13|0<<11|229, // 0x50  139.7hz Appx. C#3 Saw Tooth
	1<<13|0<<11|216, // 0x51  148.1hz Appx. D3  Saw Tooth
	1<<13|0<<11|204, // 0x52  156.9hz Appx. D#3 Saw Tooth
	1<<13|0<<11|192, // 0x53  166.7hz Appx. E3  Saw Tooth
	1<<13|0<<11|181, // 0x54  176.8hz Appx. F3  Saw Tooth
	1<<13|0<<11|171, // 0x55  187.1hz Appx. F#3 Saw Tooth
	1<<13|0<<11|162, // 0x56  197.5hz Appx. G3  Saw Tooth
	1<<13|0<<11|153, // 0x57  209.2hz Appx. G#3 Saw Tooth
	1<<13|0<<11|144, // 0x58  222.2hz Appx. A3  Saw Tooth
	1<<13|0<<11|136, // 0x59  235.3hz Appx. A#3 Saw Tooth
	1<<13|0<<11|129, // 0x5A  248.1hz Appx. B3  Saw Tooth
	1<<13|0<<11|121, // 0x5B  264.5hz Appx. C4  Saw Tooth
	1<<13|0<<11|114, // 0x5C  280.7hz Appx. C#4 Saw Tooth
	1<<13|0<<11|108, // 0x5D  296.3hz Appx. D4  Saw Tooth
	1<<13|0<<11|102, // 0x5E  313.7hz Appx. D#4 Saw Tooth
	1<<13|0<<11|96,  // 0x5F  333.3hz Appx. E4  Saw Tooth
	1<<13|0<<11|91,  // 0x60  351.6hz Appx. F4  Saw Tooth
	1<<13|0<<11|86,  // 0x61  372.1hz Appx. F#4 Saw Tooth
	1<<13|0<<11|81,  // 0x62  395.1hz Appx. G4  Saw Tooth
	1<<13|0<<11|76,  // 0x63  421.1hz Appx. G#4 Saw Tooth
	1<<13|0<<11|72,  // 0x64  444.4hz Appx. A4  Saw Tooth
	1<<13|0<<11|68,  // 0x65  470.6hz Appx. A#4 Saw Tooth
	1<<13|0<<11|64,  // 0x66  500.0hz Appx. B4  Saw Tooth
	1<<13|0<<11|61,  // 0x67  524.6hz Appx. C5  Saw Tooth
	1<<13|0<<11|57,  // 0x68  561.4hz Appx. C#5 Saw Tooth
	1<<13|0<<11|54,  // 0x69  592.6hz Appx. D5  Saw Tooth
	1<<13|0<<11|51,  // 0x6A  627.5hz Appx. D#5 Saw Tooth
	1<<13|0<<11|48,  // 0x6B  666.7hz Appx. E5  Saw Tooth
	1<<13|0<<11|46,  // 0x6C  695.7hz Appx. F5  Saw Tooth
	1<<13|0<<11|43,  // 0x6D  744.2hz Appx. F#5 Saw Tooth
	1<<13|0<<11|41,  // 0x6E  780.5hz Appx. G5  Saw Tooth
	1<<13|0<<11|38,  // 0x6F  842.1hz Appx. G#5 Saw Tooth
	1<<13|0<<11|36,  // 0x70  888.9hz Appx. A5  Saw Tooth
	1<<13|0<<11|34,  // 0x71  941.2hz Appx. A#5 Saw Tooth
	1<<13|0<<11|32,  // 0x72 1000.0hz Appx. B5  Saw Tooth
	1<<13|0<<11|30,  // 0x73 1066.7hz Appx. C6  Saw Tooth
	1<<13|0<<11|29,  // 0x74 1103.4hz Appx. C#6 Saw Tooth
	1<<13|0<<11|27,  // 0x75 1185.2hz Appx. D6  Saw Tooth
	1<<13|0<<11|26,  // 0x76 1230.8hz Appx. D#6 Saw Tooth
	1<<13|0<<11|24,  // 0x77 1333.3hz Appx. E6  Saw Tooth
	1<<13|0<<11|23,  // 0x78 1391.3hz Appx. F6  Saw Tooth
	1<<13|0<<11|22,  // 0x79 1454.5hz Appx. F#6 Saw Tooth
	1<<13|0<<11|20,  // 0x7A 1600.0hz Appx. G6  Saw Tooth
	1<<13|0<<11|19,  // 0x7B 1684.2hz Appx. G#6 Saw Tooth
	1<<13|0<<11|18,  // 0x7C 1777.8hz Appx. A6  Saw Tooth
	1<<13|0<<11|17,  // 0x7D 1882.4hz Appx. A#6 Saw Tooth
	1<<13|0<<11|16,  // 0x7E 2000.0hz Appx. B6  Saw Tooth
	1<<13|0<<11|15,  // 0x7F 2133.3hz Appx. C7  Saw Tooth

	2<<13|0<<11|581, // 0x80  55.08hz Appx. A1  Square
	2<<13|0<<11|548, // 0x81  58.39hz Appx. A#1 Square
	2<<13|0<<11|518, // 0x82  61.78hz Appx. B1  Square
	2<<13|0<<11|489, // 0x83  65.44hz Appx. C2  Square
	2<<13|0<<11|461, // 0x84  69.41hz Appx. C#2 Square
	2<<13|0<<11|435, // 0x85  73.56hz Appx. D2  Square
	2<<13|0<<11|411, // 0x86  77.86hz Appx. D#2 Square
	2<<13|0<<11|388, // 0x87  82.47hz Appx. E2  Square
	2<<13|0<<11|366, // 0x88  87.43hz Appx. F2  Square
	2<<13|0<<11|345, // 0x89  92.75hz Appx. F#2 Square
	2<<13|0<<11|326, // 0x8A  98.16hz Appx. G2  Square
	2<<13|0<<11|308, // 0x8B  103.9hz Appx. G#2 Square
	2<<13|0<<11|288, // 0x8C  111.1hz Appx. A2  Square
	2<<13|0<<11|272, // 0x8D  117.6hz Appx. A#2 Square
	2<<13|0<<11|257, // 0x8E  124.5hz Appx. B2  Square
	2<<13|0<<11|242, // 0x8F  132.2hz Appx. C3  Square
	2<<13|0<<11|229, // 0x90  139.7hz Appx. C#3 Square
	2<<13|0<<11|216, // 0x91  148.1hz Appx. D3  Square
	2<<13|0<<11|204, // 0x92  156.9hz Appx. D#3 Square
	2<<13|0<<11|192, // 0x93  166.7hz Appx. E3  Square
	2<<13|0<<11|181, // 0x94  176.8hz Appx. F3  Square
	2<<13|0<<11|171, // 0x95  187.1hz Appx. F#3 Square
	2<<13|0<<11|162, // 0x96  197.5hz Appx. G3  Square
	2<<13|0<<11|153, // 0x97  209.2hz Appx. G#3 Square
	2<<13|0<<11|144, // 0x98  222.2hz Appx. A3  Square
	2<<13|0<<11|136, // 0x99  235.3hz Appx. A#3 Square
	2<<13|0<<11|129, // 0x9A  248.1hz Appx. B3  Square
	2<<13|0<<11|121, // 0x9B  264.5hz Appx. C4  Square
	2<<13|0<<11|114, // 0x9C  280.7hz Appx. C#4 Square
	2<<13|0<<11|108, // 0x9D  296.3hz Appx. D4  Square
	2<<13|0<<11|102, // 0x9E  313.7hz Appx. D#4 Square
	2<<13|0<<11|96,  // 0x9F  333.3hz Appx. E4  Square
	2<<13|0<<11|91,  // 0xA0  351.6hz Appx. F4  Square
	2<<13|0<<11|86,  // 0xA1  372.1hz Appx. F#4 Square
	2<<13|0<<11|81,  // 0xA2  395.1hz Appx. G4  Square
	2<<13|0<<11|76,  // 0xA3  421.1hz Appx. G#4 Square
	2<<13|0<<11|72,  // 0xA4  444.4hz Appx. A4  Square
	2<<13|0<<11|68,  // 0xA5  470.6hz Appx. A#4 Square
	2<<13|0<<11|64,  // 0xA6  500.0hz Appx. B4  Square
	2<<13|0<<11|61,  // 0xA7  524.6hz Appx. C5  Square
	2<<13|0<<11|57,  // 0xA8  561.4hz Appx. C#5 Square
	2<<13|0<<11|54,  // 0xA9  592.6hz Appx. D5  Square
	2<<13|0<<11|51,  // 0xAA  627.5hz Appx. D#5 Square
	2<<13|0<<11|48,  // 0xAB  666.7hz Appx. E5  Square
	2<<13|0<<11|46,  // 0xAC  695.7hz Appx. F5  Square
	2<<13|0<<11|43,  // 0xAD  744.2hz Appx. F#5 Square
	2<<13|0<<11|41,  // 0xAE  780.5hz Appx. G5  Square
	2<<13|0<<11|38,  // 0xAF  842.1hz Appx. G#5 Square
	2<<13|0<<11|36,  // 0xB0  888.9hz Appx. A5  Square
	2<<13|0<<11|34,  // 0xB1  941.2hz Appx. A#5 Square
	2<<13|0<<11|32,  // 0xB2 1000.0hz Appx. B5  Square
	2<<13|0<<11|30,  // 0xB3 1066.7hz Appx. C6  Square
	2<<13|0<<11|29,  // 0xB4 1103.4hz Appx. C#6 Square
	2<<13|0<<11|27,  // 0xB5 1185.2hz Appx. D6  Square
	2<<13|0<<11|26,  // 0xB6 1230.8hz Appx. D#6 Square
	2<<13|0<<11|24,  // 0xB7 1333.3hz Appx. E6  Square
	2<<13|0<<11|23,  // 0xB8 1391.3hz Appx. F6  Square
	2<<13|0<<11|22,  // 0xB9 1454.5hz Appx. F#6 Square
	2<<13|0<<11|20,  // 0xBA 1600.0hz Appx. G6  Square
	2<<13|0<<11|19,  // 0xBB 1684.2hz Appx. G#6 Square
	2<<13|0<<11|18,  // 0xBC 1777.8hz Appx. A6  Square
	2<<13|0<<11|17,  // 0xBD 1882.4hz Appx. A#6 Square
	2<<13|0<<11|16,  // 0xBE 2000.0hz Appx. B6  Square
	2<<13|0<<11|15,  // 0xBF 2133.3hz Appx. C7  Square

	/* High Tones Large */

	2<<13|0<<11|14,  // 0xC0 2285.7hz Appx. C#7 Square
	2<<13|0<<11|13,  // 0xC1 2461.5hz Appx. D#7 Square
	2<<13|0<<11|12,  // 0xC2 2666.6hz Appx. E7  Square
	2<<13|0<<11|11,  // 0xC3 2909.1hz Appx. F7  Square
	2<<13|0<<11|10,  // 0xC4 3200,0hz Appx. G7  Square
	2<<13|0<<11|9,   // 0xC5 3555.6hz Appx. A7  Square
	2<<13|0<<11|8,   // 0xC6 4000.0hz Appx. B7  Square
	2<<13|0<<11|7,   // 0xC7 4571.4hz Appx. C#8 Square
	2<<13|0<<11|6,   // 0xC8 5333.3hz Appx. E8  Square
	2<<13|0<<11|5,   // 0xC9 6400.0hz Appx. G8  Square
	2<<13|0<<11|4,   // 0xCA 8000.0hz Appx. B8  Square
	2<<13|0<<11|3,   // 0xCB 10666.7hz Square

	_20(2<<13|0<<11|20)  // For Offset

	/* Assume Fixed Length as 3960, Sample Rate 31680Hz Divided by 8 */
	3<<13|0<<11|440, // 0xE0 Noise Stride 440
	3<<13|0<<11|396, // 0xE1 Noise Stride 396
	3<<13|0<<11|330, // 0xE2 Noise Stride 330
	3<<13|0<<11|220, // 0xE3 Noise Stride 220
	3<<13|0<<11|165, // 0xE4 Noise Stride 165
	3<<13|0<<11|132, // 0xE5 Noise Stride 132
	3<<13|0<<11|120, // 0xE6 Noise Stride 120
	3<<13|0<<11|110, // 0xE7 Noise Stride 110
	3<<13|0<<11|99,  // 0xE8 Noise Stride 99
	3<<13|0<<11|90,  // 0xE9 Noise Stride 90
	3<<13|0<<11|88,  // 0xEA Noise Stride 88
	3<<13|0<<11|72,  // 0xEB Noise Stride 72
	3<<13|0<<11|66,  // 0xEC Noise Stride 66
	3<<13|0<<11|60,  // 0xED Noise Stride 60
	3<<13|0<<11|55,  // 0xEE Noise Stride 55
	3<<13|0<<11|45,  // 0xEF Noise Stride 45
	3<<13|0<<11|44,  // 0xF0 Noise Stride 44
	3<<13|0<<11|40,  // 0xF1 Noise Stride 40
	3<<13|0<<11|36,  // 0xF2 Noise Stride 36
	3<<13|0<<11|30,  // 0xF3 Noise Stride 30
	3<<13|0<<11|24,  // 0xF4 Noise Stride 24
	3<<13|0<<11|22,  // 0xF5 Noise Stride 22
	3<<13|0<<11|20,  // 0xF6 Noise Stride 20
	3<<13|0<<11|18,  // 0xF7 Noise Stride 18
	3<<13|0<<11|15,  // 0xF8 Noise Stride 15
	3<<13|0<<11|12,  // 0xF9 Noise Stride 12
	3<<13|0<<11|10,  // 0xFA Noise Stride 10
	3<<13|0<<11|9,   // 0xFB Noise Stride 9
	3<<13|0<<11|8,   // 0xFC Noise Stride 8
	3<<13|0<<11|6,   // 0xFD Noise Stride 6
	3<<13|0<<11|5,   // 0xFE Noise Stride 5
	3<<13|0<<11|4,   // 0xFF Noise Stride 4

	/* Volume Medium */

	0<<13|1<<11|581, // 0x100  55.08hz Appx. A1  Sin
	0<<13|1<<11|548, // 0x101  58.39hz Appx. A#1 Sin
	0<<13|1<<11|518, // 0x102  61.78hz Appx. B1  Sin
	0<<13|1<<11|489, // 0x103  65.44hz Appx. C2  Sin
	0<<13|1<<11|461, // 0x104  69.41hz Appx. C#2 Sin
	0<<13|1<<11|435, // 0x105  73.56hz Appx. D2  Sin
	0<<13|1<<11|411, // 0x106  77.86hz Appx. D#2 Sin
	0<<13|1<<11|388, // 0x107  82.47hz Appx. E2  Sin
	0<<13|1<<11|366, // 0x108  87.43hz Appx. F2  Sin
	0<<13|1<<11|345, // 0x109  92.75hz Appx. F#2 Sin
	0<<13|1<<11|326, // 0x10A  98.16hz Appx. G2  Sin
	0<<13|1<<11|308, // 0x10B  103.9hz Appx. G#2 Sin
	0<<13|1<<11|288, // 0x10C  111.1hz Appx. A2  Sin
	0<<13|1<<11|272, // 0x10D  117.6hz Appx. A#2 Sin
	0<<13|1<<11|257, // 0x10E  124.5hz Appx. B2  Sin
	0<<13|1<<11|242, // 0x10F  132.2hz Appx. C3  Sin
	0<<13|1<<11|229, // 0x110  139.7hz Appx. C#3 Sin
	0<<13|1<<11|216, // 0x111  148.1hz Appx. D3  Sin
	0<<13|1<<11|204, // 0x112  156.9hz Appx. D#3 Sin
	0<<13|1<<11|192, // 0x113  166.7hz Appx. E3  Sin
	0<<13|1<<11|181, // 0x114  176.8hz Appx. F3  Sin
	0<<13|1<<11|171, // 0x115  187.1hz Appx. F#3 Sin
	0<<13|1<<11|162, // 0x116  197.5hz Appx. G3  Sin
	0<<13|1<<11|153, // 0x117  209.2hz Appx. G#3 Sin
	0<<13|1<<11|144, // 0x118  222.2hz Appx. A3  Sin
	0<<13|1<<11|136, // 0x119  235.3hz Appx. A#3 Sin
	0<<13|1<<11|129, // 0x11A  248.1hz Appx. B3  Sin
	0<<13|1<<11|121, // 0x11B  264.5hz Appx. C4  Sin
	0<<13|1<<11|114, // 0x11C  280.7hz Appx. C#4 Sin
	0<<13|1<<11|108, // 0x11D  296.3hz Appx. D4  Sin
	0<<13|1<<11|102, // 0x11E  313.7hz Appx. D#4 Sin
	0<<13|1<<11|96,  // 0x11F  333.3hz Appx. E4  Sin
	0<<13|1<<11|91,  // 0x120  351.6hz Appx. F4  Sin
	0<<13|1<<11|86,  // 0x121  372.1hz Appx. F#4 Sin
	0<<13|1<<11|81,  // 0x122  395.1hz Appx. G4  Sin
	0<<13|1<<11|76,  // 0x123  421.1hz Appx. G#4 Sin
	0<<13|1<<11|72,  // 0x124  444.4hz Appx. A4  Sin
	0<<13|1<<11|68,  // 0x125  470.6hz Appx. A#4 Sin
	0<<13|1<<11|64,  // 0x126  500.0hz Appx. B4  Sin
	0<<13|1<<11|61,  // 0x127  524.6hz Appx. C5  Sin
	0<<13|1<<11|57,  // 0x128  561.4hz Appx. C#5 Sin
	0<<13|1<<11|54,  // 0x129  592.6hz Appx. D5  Sin
	0<<13|1<<11|51,  // 0x12A  627.5hz Appx. D#5 Sin
	0<<13|1<<11|48,  // 0x12B  666.7hz Appx. E5  Sin
	0<<13|1<<11|46,  // 0x12C  695.7hz Appx. F5  Sin
	0<<13|1<<11|43,  // 0x12D  744.2hz Appx. F#5 Sin
	0<<13|1<<11|41,  // 0x12E  780.5hz Appx. G5  Sin
	0<<13|1<<11|38,  // 0x12F  842.1hz Appx. G#5 Sin
	0<<13|1<<11|36,  // 0x130  888.9hz Appx. A5  Sin
	0<<13|1<<11|34,  // 0x131  941.2hz Appx. A#5 Sin
	0<<13|1<<11|32,  // 0x132 1000.0hz Appx. B5  Sin
	0<<13|1<<11|30,  // 0x133 1066.7hz Appx. C6  Sin
	0<<13|1<<11|29,  // 0x134 1103.4hz Appx. C#6 Sin
	0<<13|1<<11|27,  // 0x135 1185.2hz Appx. D6  Sin
	0<<13|1<<11|26,  // 0x136 1230.8hz Appx. D#6 Sin
	0<<13|1<<11|24,  // 0x137 1333.3hz Appx. E6  Sin
	0<<13|1<<11|23,  // 0x138 1391.3hz Appx. F6  Sin
	0<<13|1<<11|22,  // 0x139 1454.5hz Appx. F#6 Sin
	0<<13|1<<11|20,  // 0x13A 1600.0hz Appx. G6  Sin
	0<<13|1<<11|19,  // 0x13B 1684.2hz Appx. G#6 Sin
	0<<13|1<<11|18,  // 0x13C 1777.8hz Appx. A6  Sin
	0<<13|1<<11|17,  // 0x13D 1882.4hz Appx. A#6 Sin
	0<<13|1<<11|16,  // 0x13E 2000.0hz Appx. B6  Sin
	0<<13|1<<11|15,  // 0x13F 2133.3hz Appx. C7  Sin

	1<<13|1<<11|581, // 0x140  55.08hz Appx. A1  Saw Tooth
	1<<13|1<<11|548, // 0x141  58.39hz Appx. A#1 Saw Tooth
	1<<13|1<<11|518, // 0x142  61.78hz Appx. B1  Saw Tooth
	1<<13|1<<11|489, // 0x143  65.44hz Appx. C2  Saw Tooth
	1<<13|1<<11|461, // 0x144  69.41hz Appx. C#2 Saw Tooth
	1<<13|1<<11|435, // 0x145  73.56hz Appx. D2  Saw Tooth
	1<<13|1<<11|411, // 0x146  77.86hz Appx. D#2 Saw Tooth
	1<<13|1<<11|388, // 0x147  82.47hz Appx. E2  Saw Tooth
	1<<13|1<<11|366, // 0x148  87.43hz Appx. F2  Saw Tooth
	1<<13|1<<11|345, // 0x149  92.75hz Appx. F#2 Saw Tooth
	1<<13|1<<11|326, // 0x14A  98.16hz Appx. G2  Saw Tooth
	1<<13|1<<11|308, // 0x14B  103.9hz Appx. G#2 Saw Tooth
	1<<13|1<<11|288, // 0x14C  111.1hz Appx. A2  Saw Tooth
	1<<13|1<<11|272, // 0x14D  117.6hz Appx. A#2 Saw Tooth
	1<<13|1<<11|257, // 0x14E  124.5hz Appx. B2  Saw Tooth
	1<<13|1<<11|242, // 0x14F  132.2hz Appx. C3  Saw Tooth
	1<<13|1<<11|229, // 0x150  139.7hz Appx. C#3 Saw Tooth
	1<<13|1<<11|216, // 0x151  148.1hz Appx. D3  Saw Tooth
	1<<13|1<<11|204, // 0x152  156.9hz Appx. D#3 Saw Tooth
	1<<13|1<<11|192, // 0x153  166.7hz Appx. E3  Saw Tooth
	1<<13|1<<11|181, // 0x154  176.8hz Appx. F3  Saw Tooth
	1<<13|1<<11|171, // 0x155  187.1hz Appx. F#3 Saw Tooth
	1<<13|1<<11|162, // 0x156  197.5hz Appx. G3  Saw Tooth
	1<<13|1<<11|153, // 0x157  209.2hz Appx. G#3 Saw Tooth
	1<<13|1<<11|144, // 0x158  222.2hz Appx. A3  Saw Tooth
	1<<13|1<<11|136, // 0x159  235.3hz Appx. A#3 Saw Tooth
	1<<13|1<<11|129, // 0x15A  248.1hz Appx. B3  Saw Tooth
	1<<13|1<<11|121, // 0x15B  264.5hz Appx. C4  Saw Tooth
	1<<13|1<<11|114, // 0x15C  280.7hz Appx. C#4 Saw Tooth
	1<<13|1<<11|108, // 0x15D  296.3hz Appx. D4  Saw Tooth
	1<<13|1<<11|102, // 0x15E  313.7hz Appx. D#4 Saw Tooth
	1<<13|1<<11|96,  // 0x15F  333.3hz Appx. E4  Saw Tooth
	1<<13|1<<11|91,  // 0x160  351.6hz Appx. F4  Saw Tooth
	1<<13|1<<11|86,  // 0x161  372.1hz Appx. F#4 Saw Tooth
	1<<13|1<<11|81,  // 0x162  395.1hz Appx. G4  Saw Tooth
	1<<13|1<<11|76,  // 0x163  421.1hz Appx. G#4 Saw Tooth
	1<<13|1<<11|72,  // 0x164  444.4hz Appx. A4  Saw Tooth
	1<<13|1<<11|68,  // 0x165  470.6hz Appx. A#4 Saw Tooth
	1<<13|1<<11|64,  // 0x166  500.0hz Appx. B4  Saw Tooth
	1<<13|1<<11|61,  // 0x167  524.6hz Appx. C5  Saw Tooth
	1<<13|1<<11|57,  // 0x168  561.4hz Appx. C#5 Saw Tooth
	1<<13|1<<11|54,  // 0x169  592.6hz Appx. D5  Saw Tooth
	1<<13|1<<11|51,  // 0x16A  627.5hz Appx. D#5 Saw Tooth
	1<<13|1<<11|48,  // 0x16B  666.7hz Appx. E5  Saw Tooth
	1<<13|1<<11|46,  // 0x16C  695.7hz Appx. F5  Saw Tooth
	1<<13|1<<11|43,  // 0x16D  744.2hz Appx. F#5 Saw Tooth
	1<<13|1<<11|41,  // 0x16E  780.5hz Appx. G5  Saw Tooth
	1<<13|1<<11|38,  // 0x16F  842.1hz Appx. G#5 Saw Tooth
	1<<13|1<<11|36,  // 0x170  888.9hz Appx. A5  Saw Tooth
	1<<13|1<<11|34,  // 0x171  941.2hz Appx. A#5 Saw Tooth
	1<<13|1<<11|32,  // 0x172 1000.0hz Appx. B5  Saw Tooth
	1<<13|1<<11|30,  // 0x173 1066.7hz Appx. C6  Saw Tooth
	1<<13|1<<11|29,  // 0x174 1103.4hz Appx. C#6 Saw Tooth
	1<<13|1<<11|27,  // 0x175 1185.2hz Appx. D6  Saw Tooth
	1<<13|1<<11|26,  // 0x176 1230.8hz Appx. D#6 Saw Tooth
	1<<13|1<<11|24,  // 0x177 1333.3hz Appx. E6  Saw Tooth
	1<<13|1<<11|23,  // 0x178 1391.3hz Appx. F6  Saw Tooth
	1<<13|1<<11|22,  // 0x179 1454.5hz Appx. F#6 Saw Tooth
	1<<13|1<<11|20,  // 0x17A 1600.0hz Appx. G6  Saw Tooth
	1<<13|1<<11|19,  // 0x17B 1684.2hz Appx. G#6 Saw Tooth
	1<<13|1<<11|18,  // 0x17C 1777.8hz Appx. A6  Saw Tooth
	1<<13|1<<11|17,  // 0x17D 1882.4hz Appx. A#6 Saw Tooth
	1<<13|1<<11|16,  // 0x17E 2000.0hz Appx. B6  Saw Tooth
	1<<13|1<<11|15,  // 0x17F 2133.3hz Appx. C7  Saw Tooth

	2<<13|1<<11|581, // 0x180  55.08hz Appx. A1  Square
	2<<13|1<<11|548, // 0x181  58.39hz Appx. A#1 Square
	2<<13|1<<11|518, // 0x182  61.78hz Appx. B1  Square
	2<<13|1<<11|489, // 0x183  65.44hz Appx. C2  Square
	2<<13|1<<11|461, // 0x184  69.41hz Appx. C#2 Square
	2<<13|1<<11|435, // 0x185  73.56hz Appx. D2  Square
	2<<13|1<<11|411, // 0x186  77.86hz Appx. D#2 Square
	2<<13|1<<11|388, // 0x187  82.47hz Appx. E2  Square
	2<<13|1<<11|366, // 0x188  87.43hz Appx. F2  Square
	2<<13|1<<11|345, // 0x189  92.75hz Appx. F#2 Square
	2<<13|1<<11|326, // 0x18A  98.16hz Appx. G2  Square
	2<<13|1<<11|308, // 0x18B  103.9hz Appx. G#2 Square
	2<<13|1<<11|288, // 0x18C  111.1hz Appx. A2  Square
	2<<13|1<<11|272, // 0x18D  117.6hz Appx. A#2 Square
	2<<13|1<<11|257, // 0x18E  124.5hz Appx. B2  Square
	2<<13|1<<11|242, // 0x18F  132.2hz Appx. C3  Square
	2<<13|1<<11|229, // 0x190  139.7hz Appx. C#3 Square
	2<<13|1<<11|216, // 0x191  148.1hz Appx. D3  Square
	2<<13|1<<11|204, // 0x192  156.9hz Appx. D#3 Square
	2<<13|1<<11|192, // 0x193  166.7hz Appx. E3  Square
	2<<13|1<<11|181, // 0x194  176.8hz Appx. F3  Square
	2<<13|1<<11|171, // 0x195  187.1hz Appx. F#3 Square
	2<<13|1<<11|162, // 0x196  197.5hz Appx. G3  Square
	2<<13|1<<11|153, // 0x197  209.2hz Appx. G#3 Square
	2<<13|1<<11|144, // 0x198  222.2hz Appx. A3  Square
	2<<13|1<<11|136, // 0x199  235.3hz Appx. A#3 Square
	2<<13|1<<11|129, // 0x19A  248.1hz Appx. B3  Square
	2<<13|1<<11|121, // 0x19B  264.5hz Appx. C4  Square
	2<<13|1<<11|114, // 0x19C  280.7hz Appx. C#4 Square
	2<<13|1<<11|108, // 0x19D  296.3hz Appx. D4  Square
	2<<13|1<<11|102, // 0x19E  313.7hz Appx. D#4 Square
	2<<13|1<<11|96,  // 0x19F  333.3hz Appx. E4  Square
	2<<13|1<<11|91,  // 0x1A0  351.6hz Appx. F4  Square
	2<<13|1<<11|86,  // 0x1A1  372.1hz Appx. F#4 Square
	2<<13|1<<11|81,  // 0x1A2  395.1hz Appx. G4  Square
	2<<13|1<<11|76,  // 0x1A3  421.1hz Appx. G#4 Square
	2<<13|1<<11|72,  // 0x1A4  444.4hz Appx. A4  Square
	2<<13|1<<11|68,  // 0x1A5  470.6hz Appx. A#4 Square
	2<<13|1<<11|64,  // 0x1A6  500.0hz Appx. B4  Square
	2<<13|1<<11|61,  // 0x1A7  524.6hz Appx. C5  Square
	2<<13|1<<11|57,  // 0x1A8  561.4hz Appx. C#5 Square
	2<<13|1<<11|54,  // 0x1A9  592.6hz Appx. D5  Square
	2<<13|1<<11|51,  // 0x1AA  627.5hz Appx. D#5 Square
	2<<13|1<<11|48,  // 0x1AB  666.7hz Appx. E5  Square
	2<<13|1<<11|46,  // 0x1AC  695.7hz Appx. F5  Square
	2<<13|1<<11|43,  // 0x1AD  744.2hz Appx. F#5 Square
	2<<13|1<<11|41,  // 0x1AE  780.5hz Appx. G5  Square
	2<<13|1<<11|38,  // 0x1AF  842.1hz Appx. G#5 Square
	2<<13|1<<11|36,  // 0x1B0  888.9hz Appx. A5  Square
	2<<13|1<<11|34,  // 0x1B1  941.2hz Appx. A#5 Square
	2<<13|1<<11|32,  // 0x1B2 1000.0hz Appx. B5  Square
	2<<13|1<<11|30,  // 0x1B3 1066.7hz Appx. C6  Square
	2<<13|1<<11|29,  // 0x1B4 1103.4hz Appx. C#6 Square
	2<<13|1<<11|27,  // 0x1B5 1185.2hz Appx. D6  Square
	2<<13|1<<11|26,  // 0x1B6 1230.8hz Appx. D#6 Square
	2<<13|1<<11|24,  // 0x1B7 1333.3hz Appx. E6  Square
	2<<13|1<<11|23,  // 0x1B8 1391.3hz Appx. F6  Square
	2<<13|1<<11|22,  // 0x1B9 1454.5hz Appx. F#6 Square
	2<<13|1<<11|20,  // 0x1BA 1600.0hz Appx. G6  Square
	2<<13|1<<11|19,  // 0x1BB 1684.2hz Appx. G#6 Square
	2<<13|1<<11|18,  // 0x1BC 1777.8hz Appx. A6  Square
	2<<13|1<<11|17,  // 0x1BD 1882.4hz Appx. A#6 Square
	2<<13|1<<11|16,  // 0x1BE 2000.0hz Appx. B6  Square
	2<<13|1<<11|15,  // 0x1BF 2133.3hz Appx. C7  Square

	/* High Tones Medium */

	2<<13|1<<11|14,  // 0x1C0 2285.7hz Appx. C#7 Square
	2<<13|1<<11|13,  // 0x1C1 2461.5hz Appx. D#7 Square
	2<<13|1<<11|12,  // 0x1C2 2666.6hz Appx. E7  Square
	2<<13|1<<11|11,  // 0x1C3 2909.1hz Appx. F7  Square
	2<<13|1<<11|10,  // 0x1C4 3200,0hz Appx. G7  Square
	2<<13|1<<11|9,   // 0x1C5 3555.6hz Appx. A7  Square
	2<<13|1<<11|8,   // 0x1C6 4000.0hz Appx. B7  Square
	2<<13|1<<11|7,   // 0x1C7 4571.4hz Appx. C#8 Square
	2<<13|1<<11|6,   // 0x1C8 5333.3hz Appx. E8  Square
	2<<13|1<<11|5,   // 0x1C9 6400.0hz Appx. G8  Square
	2<<13|1<<11|4,   // 0x1CA 8000.0hz Appx. B8  Square
	2<<13|1<<11|3,   // 0x1CB 10666.7hz Square

	_20(2<<13|1<<11|20)  // For Offset

	/* Assume Fixed Length as 3960, Sample Rate 31680Hz Divided by 8 */
	3<<13|1<<11|440, // 0x1E0 Noise Stride 440
	3<<13|1<<11|396, // 0x1E1 Noise Stride 396
	3<<13|1<<11|330, // 0x1E2 Noise Stride 330
	3<<13|1<<11|220, // 0x1E3 Noise Stride 220
	3<<13|1<<11|165, // 0x1E4 Noise Stride 165
	3<<13|1<<11|132, // 0x1E5 Noise Stride 132
	3<<13|1<<11|120, // 0x1E6 Noise Stride 120
	3<<13|1<<11|110, // 0x1E7 Noise Stride 110
	3<<13|1<<11|99,  // 0x1E8 Noise Stride 99
	3<<13|1<<11|90,  // 0x1E9 Noise Stride 90
	3<<13|1<<11|88,  // 0x1EA Noise Stride 88
	3<<13|1<<11|72,  // 0x1EB Noise Stride 72
	3<<13|1<<11|66,  // 0x1EC Noise Stride 66
	3<<13|1<<11|60,  // 0x1ED Noise Stride 60
	3<<13|1<<11|55,  // 0x1EE Noise Stride 55
	3<<13|1<<11|45,  // 0x1EF Noise Stride 45
	3<<13|1<<11|44,  // 0x1F0 Noise Stride 44
	3<<13|1<<11|40,  // 0x1F1 Noise Stride 40
	3<<13|1<<11|36,  // 0x1F2 Noise Stride 36
	3<<13|1<<11|30,  // 0x1F3 Noise Stride 30
	3<<13|1<<11|24,  // 0x1F4 Noise Stride 24
	3<<13|1<<11|22,  // 0x1F5 Noise Stride 22
	3<<13|1<<11|20,  // 0x1F6 Noise Stride 20
	3<<13|1<<11|18,  // 0x1F7 Noise Stride 18
	3<<13|1<<11|15,  // 0x1F8 Noise Stride 15
	3<<13|1<<11|12,  // 0x1F9 Noise Stride 12
	3<<13|1<<11|10,  // 0x1FA Noise Stride 10
	3<<13|1<<11|9,   // 0x1FB Noise Stride 9
	3<<13|1<<11|8,   // 0x1FC Noise Stride 8
	3<<13|1<<11|6,   // 0x1FD Noise Stride 6
	3<<13|1<<11|5,   // 0x1FE Noise Stride 5
	3<<13|1<<11|4,   // 0x1FF Noise Stride 4

	/* Volume Small */

	0<<13|2<<11|581, // 0x200  55.08hz Appx. A1  Sin
	0<<13|2<<11|548, // 0x201  58.39hz Appx. A#1 Sin
	0<<13|2<<11|518, // 0x202  61.78hz Appx. B1  Sin
	0<<13|2<<11|489, // 0x203  65.44hz Appx. C2  Sin
	0<<13|2<<11|461, // 0x204  69.41hz Appx. C#2 Sin
	0<<13|2<<11|435, // 0x205  73.56hz Appx. D2  Sin
	0<<13|2<<11|411, // 0x206  77.86hz Appx. D#2 Sin
	0<<13|2<<11|388, // 0x207  82.47hz Appx. E2  Sin
	0<<13|2<<11|366, // 0x208  87.43hz Appx. F2  Sin
	0<<13|2<<11|345, // 0x209  92.75hz Appx. F#2 Sin
	0<<13|2<<11|326, // 0x20A  98.16hz Appx. G2  Sin
	0<<13|2<<11|308, // 0x20B  103.9hz Appx. G#2 Sin
	0<<13|2<<11|288, // 0x20C  111.1hz Appx. A2  Sin
	0<<13|2<<11|272, // 0x20D  117.6hz Appx. A#2 Sin
	0<<13|2<<11|257, // 0x20E  124.5hz Appx. B2  Sin
	0<<13|2<<11|242, // 0x20F  132.2hz Appx. C3  Sin
	0<<13|2<<11|229, // 0x210  139.7hz Appx. C#3 Sin
	0<<13|2<<11|216, // 0x211  148.1hz Appx. D3  Sin
	0<<13|2<<11|204, // 0x212  156.9hz Appx. D#3 Sin
	0<<13|2<<11|192, // 0x213  166.7hz Appx. E3  Sin
	0<<13|2<<11|181, // 0x214  176.8hz Appx. F3  Sin
	0<<13|2<<11|171, // 0x215  187.1hz Appx. F#3 Sin
	0<<13|2<<11|162, // 0x216  197.5hz Appx. G3  Sin
	0<<13|2<<11|153, // 0x217  209.2hz Appx. G#3 Sin
	0<<13|2<<11|144, // 0x218  222.2hz Appx. A3  Sin
	0<<13|2<<11|136, // 0x219  235.3hz Appx. A#3 Sin
	0<<13|2<<11|129, // 0x21A  248.1hz Appx. B3  Sin
	0<<13|2<<11|121, // 0x21B  264.5hz Appx. C4  Sin
	0<<13|2<<11|114, // 0x21C  280.7hz Appx. C#4 Sin
	0<<13|2<<11|108, // 0x21D  296.3hz Appx. D4  Sin
	0<<13|2<<11|102, // 0x21E  313.7hz Appx. D#4 Sin
	0<<13|2<<11|96,  // 0x21F  333.3hz Appx. E4  Sin
	0<<13|2<<11|91,  // 0x220  351.6hz Appx. F4  Sin
	0<<13|2<<11|86,  // 0x221  372.1hz Appx. F#4 Sin
	0<<13|2<<11|81,  // 0x222  395.1hz Appx. G4  Sin
	0<<13|2<<11|76,  // 0x223  421.1hz Appx. G#4 Sin
	0<<13|2<<11|72,  // 0x224  444.4hz Appx. A4  Sin
	0<<13|2<<11|68,  // 0x225  470.6hz Appx. A#4 Sin
	0<<13|2<<11|64,  // 0x226  500.0hz Appx. B4  Sin
	0<<13|2<<11|61,  // 0x227  524.6hz Appx. C5  Sin
	0<<13|2<<11|57,  // 0x228  561.4hz Appx. C#5 Sin
	0<<13|2<<11|54,  // 0x229  592.6hz Appx. D5  Sin
	0<<13|2<<11|51,  // 0x22A  627.5hz Appx. D#5 Sin
	0<<13|2<<11|48,  // 0x22B  666.7hz Appx. E5  Sin
	0<<13|2<<11|46,  // 0x22C  695.7hz Appx. F5  Sin
	0<<13|2<<11|43,  // 0x22D  744.2hz Appx. F#5 Sin
	0<<13|2<<11|41,  // 0x22E  780.5hz Appx. G5  Sin
	0<<13|2<<11|38,  // 0x22F  842.1hz Appx. G#5 Sin
	0<<13|2<<11|36,  // 0x230  888.9hz Appx. A5  Sin
	0<<13|2<<11|34,  // 0x231  941.2hz Appx. A#5 Sin
	0<<13|2<<11|32,  // 0x232 1000.0hz Appx. B5  Sin
	0<<13|2<<11|30,  // 0x233 1066.7hz Appx. C6  Sin
	0<<13|2<<11|29,  // 0x234 1103.4hz Appx. C#6 Sin
	0<<13|2<<11|27,  // 0x235 1185.2hz Appx. D6  Sin
	0<<13|2<<11|26,  // 0x236 1230.8hz Appx. D#6 Sin
	0<<13|2<<11|24,  // 0x237 1333.3hz Appx. E6  Sin
	0<<13|2<<11|23,  // 0x238 1391.3hz Appx. F6  Sin
	0<<13|2<<11|22,  // 0x239 1454.5hz Appx. F#6 Sin
	0<<13|2<<11|20,  // 0x23A 1600.0hz Appx. G6  Sin
	0<<13|2<<11|19,  // 0x23B 1684.2hz Appx. G#6 Sin
	0<<13|2<<11|18,  // 0x23C 1777.8hz Appx. A6  Sin
	0<<13|2<<11|17,  // 0x23D 1882.4hz Appx. A#6 Sin
	0<<13|2<<11|16,  // 0x23E 2000.0hz Appx. B6  Sin
	0<<13|2<<11|15,  // 0x23F 2133.3hz Appx. C7  Sin

	1<<13|2<<11|581, // 0x240  55.08hz Appx. A1  Saw Tooth
	1<<13|2<<11|548, // 0x241  58.39hz Appx. A#1 Saw Tooth
	1<<13|2<<11|518, // 0x242  61.78hz Appx. B1  Saw Tooth
	1<<13|2<<11|489, // 0x243  65.44hz Appx. C2  Saw Tooth
	1<<13|2<<11|461, // 0x244  69.41hz Appx. C#2 Saw Tooth
	1<<13|2<<11|435, // 0x245  73.56hz Appx. D2  Saw Tooth
	1<<13|2<<11|411, // 0x246  77.86hz Appx. D#2 Saw Tooth
	1<<13|2<<11|388, // 0x247  82.47hz Appx. E2  Saw Tooth
	1<<13|2<<11|366, // 0x248  87.43hz Appx. F2  Saw Tooth
	1<<13|2<<11|345, // 0x249  92.75hz Appx. F#2 Saw Tooth
	1<<13|2<<11|326, // 0x24A  98.16hz Appx. G2  Saw Tooth
	1<<13|2<<11|308, // 0x24B  103.9hz Appx. G#2 Saw Tooth
	1<<13|2<<11|288, // 0x24C  111.1hz Appx. A2  Saw Tooth
	1<<13|2<<11|272, // 0x24D  117.6hz Appx. A#2 Saw Tooth
	1<<13|2<<11|257, // 0x24E  124.5hz Appx. B2  Saw Tooth
	1<<13|2<<11|242, // 0x24F  132.2hz Appx. C3  Saw Tooth
	1<<13|2<<11|229, // 0x250  139.7hz Appx. C#3 Saw Tooth
	1<<13|2<<11|216, // 0x251  148.1hz Appx. D3  Saw Tooth
	1<<13|2<<11|204, // 0x252  156.9hz Appx. D#3 Saw Tooth
	1<<13|2<<11|192, // 0x253  166.7hz Appx. E3  Saw Tooth
	1<<13|2<<11|181, // 0x254  176.8hz Appx. F3  Saw Tooth
	1<<13|2<<11|171, // 0x255  187.1hz Appx. F#3 Saw Tooth
	1<<13|2<<11|162, // 0x256  197.5hz Appx. G3  Saw Tooth
	1<<13|2<<11|153, // 0x257  209.2hz Appx. G#3 Saw Tooth
	1<<13|2<<11|144, // 0x258  222.2hz Appx. A3  Saw Tooth
	1<<13|2<<11|136, // 0x259  235.3hz Appx. A#3 Saw Tooth
	1<<13|2<<11|129, // 0x25A  248.1hz Appx. B3  Saw Tooth
	1<<13|2<<11|121, // 0x25B  264.5hz Appx. C4  Saw Tooth
	1<<13|2<<11|114, // 0x25C  280.7hz Appx. C#4 Saw Tooth
	1<<13|2<<11|108, // 0x25D  296.3hz Appx. D4  Saw Tooth
	1<<13|2<<11|102, // 0x25E  313.7hz Appx. D#4 Saw Tooth
	1<<13|2<<11|96,  // 0x25F  333.3hz Appx. E4  Saw Tooth
	1<<13|2<<11|91,  // 0x260  351.6hz Appx. F4  Saw Tooth
	1<<13|2<<11|86,  // 0x261  372.1hz Appx. F#4 Saw Tooth
	1<<13|2<<11|81,  // 0x262  395.1hz Appx. G4  Saw Tooth
	1<<13|2<<11|76,  // 0x263  421.1hz Appx. G#4 Saw Tooth
	1<<13|2<<11|72,  // 0x264  444.4hz Appx. A4  Saw Tooth
	1<<13|2<<11|68,  // 0x265  470.6hz Appx. A#4 Saw Tooth
	1<<13|2<<11|64,  // 0x266  500.0hz Appx. B4  Saw Tooth
	1<<13|2<<11|61,  // 0x267  524.6hz Appx. C5  Saw Tooth
	1<<13|2<<11|57,  // 0x268  561.4hz Appx. C#5 Saw Tooth
	1<<13|2<<11|54,  // 0x269  592.6hz Appx. D5  Saw Tooth
	1<<13|2<<11|51,  // 0x26A  627.5hz Appx. D#5 Saw Tooth
	1<<13|2<<11|48,  // 0x26B  666.7hz Appx. E5  Saw Tooth
	1<<13|2<<11|46,  // 0x26C  695.7hz Appx. F5  Saw Tooth
	1<<13|2<<11|43,  // 0x26D  744.2hz Appx. F#5 Saw Tooth
	1<<13|2<<11|41,  // 0x26E  780.5hz Appx. G5  Saw Tooth
	1<<13|2<<11|38,  // 0x26F  842.1hz Appx. G#5 Saw Tooth
	1<<13|2<<11|36,  // 0x270  888.9hz Appx. A5  Saw Tooth
	1<<13|2<<11|34,  // 0x271  941.2hz Appx. A#5 Saw Tooth
	1<<13|2<<11|32,  // 0x272 1000.0hz Appx. B5  Saw Tooth
	1<<13|2<<11|30,  // 0x273 1066.7hz Appx. C6  Saw Tooth
	1<<13|2<<11|29,  // 0x274 1103.4hz Appx. C#6 Saw Tooth
	1<<13|2<<11|27,  // 0x275 1185.2hz Appx. D6  Saw Tooth
	1<<13|2<<11|26,  // 0x276 1230.8hz Appx. D#6 Saw Tooth
	1<<13|2<<11|24,  // 0x277 1333.3hz Appx. E6  Saw Tooth
	1<<13|2<<11|23,  // 0x278 1391.3hz Appx. F6  Saw Tooth
	1<<13|2<<11|22,  // 0x279 1454.5hz Appx. F#6 Saw Tooth
	1<<13|2<<11|20,  // 0x27A 1600.0hz Appx. G6  Saw Tooth
	1<<13|2<<11|19,  // 0x27B 1684.2hz Appx. G#6 Saw Tooth
	1<<13|2<<11|18,  // 0x27C 1777.8hz Appx. A6  Saw Tooth
	1<<13|2<<11|17,  // 0x27D 1882.4hz Appx. A#6 Saw Tooth
	1<<13|2<<11|16,  // 0x27E 2000.0hz Appx. B6  Saw Tooth
	1<<13|2<<11|15,  // 0x27F 2133.3hz Appx. C7  Saw Tooth

	2<<13|2<<11|581, // 0x280  55.08hz Appx. A1  Square
	2<<13|2<<11|548, // 0x281  58.39hz Appx. A#1 Square
	2<<13|2<<11|518, // 0x282  61.78hz Appx. B1  Square
	2<<13|2<<11|489, // 0x283  65.44hz Appx. C2  Square
	2<<13|2<<11|461, // 0x284  69.41hz Appx. C#2 Square
	2<<13|2<<11|435, // 0x285  73.56hz Appx. D2  Square
	2<<13|2<<11|411, // 0x286  77.86hz Appx. D#2 Square
	2<<13|2<<11|388, // 0x287  82.47hz Appx. E2  Square
	2<<13|2<<11|366, // 0x288  87.43hz Appx. F2  Square
	2<<13|2<<11|345, // 0x289  92.75hz Appx. F#2 Square
	2<<13|2<<11|326, // 0x28A  98.16hz Appx. G2  Square
	2<<13|2<<11|308, // 0x28B  103.9hz Appx. G#2 Square
	2<<13|2<<11|288, // 0x28C  111.1hz Appx. A2  Square
	2<<13|2<<11|272, // 0x28D  117.6hz Appx. A#2 Square
	2<<13|2<<11|257, // 0x28E  124.5hz Appx. B2  Square
	2<<13|2<<11|242, // 0x28F  132.2hz Appx. C3  Square
	2<<13|2<<11|229, // 0x290  139.7hz Appx. C#3 Square
	2<<13|2<<11|216, // 0x291  148.1hz Appx. D3  Square
	2<<13|2<<11|204, // 0x292  156.9hz Appx. D#3 Square
	2<<13|2<<11|192, // 0x293  166.7hz Appx. E3  Square
	2<<13|2<<11|181, // 0x294  176.8hz Appx. F3  Square
	2<<13|2<<11|171, // 0x295  187.1hz Appx. F#3 Square
	2<<13|2<<11|162, // 0x296  197.5hz Appx. G3  Square
	2<<13|2<<11|153, // 0x297  209.2hz Appx. G#3 Square
	2<<13|2<<11|144, // 0x298  222.2hz Appx. A3  Square
	2<<13|2<<11|136, // 0x299  235.3hz Appx. A#3 Square
	2<<13|2<<11|129, // 0x29A  248.1hz Appx. B3  Square
	2<<13|2<<11|121, // 0x29B  264.5hz Appx. C4  Square
	2<<13|2<<11|114, // 0x29C  280.7hz Appx. C#4 Square
	2<<13|2<<11|108, // 0x29D  296.3hz Appx. D4  Square
	2<<13|2<<11|102, // 0x29E  313.7hz Appx. D#4 Square
	2<<13|2<<11|96,  // 0x29F  333.3hz Appx. E4  Square
	2<<13|2<<11|91,  // 0x2A0  351.6hz Appx. F4  Square
	2<<13|2<<11|86,  // 0x2A1  372.1hz Appx. F#4 Square
	2<<13|2<<11|81,  // 0x2A2  395.1hz Appx. G4  Square
	2<<13|2<<11|76,  // 0x2A3  421.1hz Appx. G#4 Square
	2<<13|2<<11|72,  // 0x2A4  444.4hz Appx. A4  Square
	2<<13|2<<11|68,  // 0x2A5  470.6hz Appx. A#4 Square
	2<<13|2<<11|64,  // 0x2A6  500.0hz Appx. B4  Square
	2<<13|2<<11|61,  // 0x2A7  524.6hz Appx. C5  Square
	2<<13|2<<11|57,  // 0x2A8  561.4hz Appx. C#5 Square
	2<<13|2<<11|54,  // 0x2A9  592.6hz Appx. D5  Square
	2<<13|2<<11|51,  // 0x2AA  627.5hz Appx. D#5 Square
	2<<13|2<<11|48,  // 0x2AB  666.7hz Appx. E5  Square
	2<<13|2<<11|46,  // 0x2AC  695.7hz Appx. F5  Square
	2<<13|2<<11|43,  // 0x2AD  744.2hz Appx. F#5 Square
	2<<13|2<<11|41,  // 0x2AE  780.5hz Appx. G5  Square
	2<<13|2<<11|38,  // 0x2AF  842.1hz Appx. G#5 Square
	2<<13|2<<11|36,  // 0x2B0  888.9hz Appx. A5  Square
	2<<13|2<<11|34,  // 0x2B1  941.2hz Appx. A#5 Square
	2<<13|2<<11|32,  // 0x2B2 1000.0hz Appx. B5  Square
	2<<13|2<<11|30,  // 0x2B3 1066.7hz Appx. C6  Square
	2<<13|2<<11|29,  // 0x2B4 1103.4hz Appx. C#6 Square
	2<<13|2<<11|27,  // 0x2B5 1185.2hz Appx. D6  Square
	2<<13|2<<11|26,  // 0x2B6 1230.8hz Appx. D#6 Square
	2<<13|2<<11|24,  // 0x2B7 1333.3hz Appx. E6  Square
	2<<13|2<<11|23,  // 0x2B8 1391.3hz Appx. F6  Square
	2<<13|2<<11|22,  // 0x2B9 1454.5hz Appx. F#6 Square
	2<<13|2<<11|20,  // 0x2BA 1600.0hz Appx. G6  Square
	2<<13|2<<11|19,  // 0x2BB 1684.2hz Appx. G#6 Square
	2<<13|2<<11|18,  // 0x2BC 1777.8hz Appx. A6  Square
	2<<13|2<<11|17,  // 0x2BD 1882.4hz Appx. A#6 Square
	2<<13|2<<11|16,  // 0x2BE 2000.0hz Appx. B6  Square
	2<<13|2<<11|15,  // 0x2BF 2133.3hz Appx. C7  Square

	/* High Tones Small */

	2<<13|2<<11|14,  // 0x2C0 2285.7hz Appx. C#7 Square
	2<<13|2<<11|13,  // 0x2C1 2461.5hz Appx. D#7 Square
	2<<13|2<<11|12,  // 0x2C2 2666.6hz Appx. E7  Square
	2<<13|2<<11|11,  // 0x2C3 2909.1hz Appx. F7  Square
	2<<13|2<<11|10,  // 0x2C4 3200,0hz Appx. G7  Square
	2<<13|2<<11|9,   // 0x2C5 3555.6hz Appx. A7  Square
	2<<13|2<<11|8,   // 0x2C6 4000.0hz Appx. B7  Square
	2<<13|2<<11|7,   // 0x2C7 4571.4hz Appx. C#8 Square
	2<<13|2<<11|6,   // 0x2C8 5333.3hz Appx. E8  Square
	2<<13|2<<11|5,   // 0x2C9 6400.0hz Appx. G8  Square
	2<<13|2<<11|4,   // 0x2CA 8000.0hz Appx. B8  Square
	2<<13|2<<11|3,   // 0x2CB 10666.7hz Square

	_20(2<<13|2<<11|20)  // For Offset

	/* Assume Fixed Length as 3960, Sample Rate 31680Hz Divided by 8 */
	3<<13|2<<11|440, // 0x2E0 Noise Stride 440
	3<<13|2<<11|396, // 0x2E1 Noise Stride 396
	3<<13|2<<11|330, // 0x2E2 Noise Stride 330
	3<<13|2<<11|220, // 0x2E3 Noise Stride 220
	3<<13|2<<11|165, // 0x2E4 Noise Stride 165
	3<<13|2<<11|132, // 0x2E5 Noise Stride 132
	3<<13|2<<11|120, // 0x2E6 Noise Stride 120
	3<<13|2<<11|110, // 0x2E7 Noise Stride 110
	3<<13|2<<11|99,  // 0x2E8 Noise Stride 99
	3<<13|2<<11|90,  // 0x2E9 Noise Stride 90
	3<<13|2<<11|88,  // 0x2EA Noise Stride 88
	3<<13|2<<11|72,  // 0x2EB Noise Stride 72
	3<<13|2<<11|66,  // 0x2EC Noise Stride 66
	3<<13|2<<11|60,  // 0x2ED Noise Stride 60
	3<<13|2<<11|55,  // 0x2EE Noise Stride 55
	3<<13|2<<11|45,  // 0x2EF Noise Stride 45
	3<<13|2<<11|44,  // 0x2F0 Noise Stride 44
	3<<13|2<<11|40,  // 0x2F1 Noise Stride 40
	3<<13|2<<11|36,  // 0x2F2 Noise Stride 36
	3<<13|2<<11|30,  // 0x2F3 Noise Stride 30
	3<<13|2<<11|24,  // 0x2F4 Noise Stride 24
	3<<13|2<<11|22,  // 0x2F5 Noise Stride 22
	3<<13|2<<11|20,  // 0x2F6 Noise Stride 20
	3<<13|2<<11|18,  // 0x2F7 Noise Stride 18
	3<<13|2<<11|15,  // 0x2F8 Noise Stride 15
	3<<13|2<<11|12,  // 0x2F9 Noise Stride 12
	3<<13|2<<11|10,  // 0x2FA Noise Stride 10
	3<<13|2<<11|9,   // 0x2FB Noise Stride 9
	3<<13|2<<11|8,   // 0x2FC Noise Stride 8
	3<<13|2<<11|6,   // 0x2FD Noise Stride 6
	3<<13|2<<11|5,   // 0x2FE Noise Stride 5
	3<<13|2<<11|4,   // 0x2FF Noise Stride 4

	/* Volume Tiny */

	0<<13|3<<11|581, // 0x300  55.08hz Appx. A1  Sin
	0<<13|3<<11|548, // 0x301  58.39hz Appx. A#1 Sin
	0<<13|3<<11|518, // 0x302  61.78hz Appx. B1  Sin
	0<<13|3<<11|489, // 0x303  65.44hz Appx. C2  Sin
	0<<13|3<<11|461, // 0x304  69.41hz Appx. C#2 Sin
	0<<13|3<<11|435, // 0x305  73.56hz Appx. D2  Sin
	0<<13|3<<11|411, // 0x306  77.86hz Appx. D#2 Sin
	0<<13|3<<11|388, // 0x307  82.47hz Appx. E2  Sin
	0<<13|3<<11|366, // 0x308  87.43hz Appx. F2  Sin
	0<<13|3<<11|345, // 0x309  92.75hz Appx. F#2 Sin
	0<<13|3<<11|326, // 0x30A  98.16hz Appx. G2  Sin
	0<<13|3<<11|308, // 0x30B  103.9hz Appx. G#2 Sin
	0<<13|3<<11|288, // 0x30C  111.1hz Appx. A2  Sin
	0<<13|3<<11|272, // 0x30D  117.6hz Appx. A#2 Sin
	0<<13|3<<11|257, // 0x30E  124.5hz Appx. B2  Sin
	0<<13|3<<11|242, // 0x30F  132.2hz Appx. C3  Sin
	0<<13|3<<11|229, // 0x310  139.7hz Appx. C#3 Sin
	0<<13|3<<11|216, // 0x311  148.1hz Appx. D3  Sin
	0<<13|3<<11|204, // 0x312  156.9hz Appx. D#3 Sin
	0<<13|3<<11|192, // 0x313  166.7hz Appx. E3  Sin
	0<<13|3<<11|181, // 0x314  176.8hz Appx. F3  Sin
	0<<13|3<<11|171, // 0x315  187.1hz Appx. F#3 Sin
	0<<13|3<<11|162, // 0x316  197.5hz Appx. G3  Sin
	0<<13|3<<11|153, // 0x317  209.2hz Appx. G#3 Sin
	0<<13|3<<11|144, // 0x318  222.2hz Appx. A3  Sin
	0<<13|3<<11|136, // 0x319  235.3hz Appx. A#3 Sin
	0<<13|3<<11|129, // 0x31A  248.1hz Appx. B3  Sin
	0<<13|3<<11|121, // 0x31B  264.5hz Appx. C4  Sin
	0<<13|3<<11|114, // 0x31C  280.7hz Appx. C#4 Sin
	0<<13|3<<11|108, // 0x31D  296.3hz Appx. D4  Sin
	0<<13|3<<11|102, // 0x31E  313.7hz Appx. D#4 Sin
	0<<13|3<<11|96,  // 0x31F  333.3hz Appx. E4  Sin
	0<<13|3<<11|91,  // 0x320  351.6hz Appx. F4  Sin
	0<<13|3<<11|86,  // 0x321  372.1hz Appx. F#4 Sin
	0<<13|3<<11|81,  // 0x322  395.1hz Appx. G4  Sin
	0<<13|3<<11|76,  // 0x323  421.1hz Appx. G#4 Sin
	0<<13|3<<11|72,  // 0x324  444.4hz Appx. A4  Sin
	0<<13|3<<11|68,  // 0x325  470.6hz Appx. A#4 Sin
	0<<13|3<<11|64,  // 0x326  500.0hz Appx. B4  Sin
	0<<13|3<<11|61,  // 0x327  524.6hz Appx. C5  Sin
	0<<13|3<<11|57,  // 0x328  561.4hz Appx. C#5 Sin
	0<<13|3<<11|54,  // 0x329  592.6hz Appx. D5  Sin
	0<<13|3<<11|51,  // 0x32A  627.5hz Appx. D#5 Sin
	0<<13|3<<11|48,  // 0x32B  666.7hz Appx. E5  Sin
	0<<13|3<<11|46,  // 0x32C  695.7hz Appx. F5  Sin
	0<<13|3<<11|43,  // 0x32D  744.2hz Appx. F#5 Sin
	0<<13|3<<11|41,  // 0x32E  780.5hz Appx. G5  Sin
	0<<13|3<<11|38,  // 0x32F  842.1hz Appx. G#5 Sin
	0<<13|3<<11|36,  // 0x330  888.9hz Appx. A5  Sin
	0<<13|3<<11|34,  // 0x331  941.2hz Appx. A#5 Sin
	0<<13|3<<11|32,  // 0x332 1000.0hz Appx. B5  Sin
	0<<13|3<<11|30,  // 0x333 1066.7hz Appx. C6  Sin
	0<<13|3<<11|29,  // 0x334 1103.4hz Appx. C#6 Sin
	0<<13|3<<11|27,  // 0x335 1185.2hz Appx. D6  Sin
	0<<13|3<<11|26,  // 0x336 1230.8hz Appx. D#6 Sin
	0<<13|3<<11|24,  // 0x337 1333.3hz Appx. E6  Sin
	0<<13|3<<11|23,  // 0x338 1391.3hz Appx. F6  Sin
	0<<13|3<<11|22,  // 0x339 1454.5hz Appx. F#6 Sin
	0<<13|3<<11|20,  // 0x33A 1600.0hz Appx. G6  Sin
	0<<13|3<<11|19,  // 0x33B 1684.2hz Appx. G#6 Sin
	0<<13|3<<11|18,  // 0x33C 1777.8hz Appx. A6  Sin
	0<<13|3<<11|17,  // 0x33D 1882.4hz Appx. A#6 Sin
	0<<13|3<<11|16,  // 0x33E 2000.0hz Appx. B6  Sin
	0<<13|3<<11|15,  // 0x33F 2133.3hz Appx. C7  Sin

	1<<13|3<<11|581, // 0x340  55.08hz Appx. A1  Saw Tooth
	1<<13|3<<11|548, // 0x341  58.39hz Appx. A#1 Saw Tooth
	1<<13|3<<11|518, // 0x342  61.78hz Appx. B1  Saw Tooth
	1<<13|3<<11|489, // 0x343  65.44hz Appx. C2  Saw Tooth
	1<<13|3<<11|461, // 0x344  69.41hz Appx. C#2 Saw Tooth
	1<<13|3<<11|435, // 0x345  73.56hz Appx. D2  Saw Tooth
	1<<13|3<<11|411, // 0x346  77.86hz Appx. D#2 Saw Tooth
	1<<13|3<<11|388, // 0x347  82.47hz Appx. E2  Saw Tooth
	1<<13|3<<11|366, // 0x348  87.43hz Appx. F2  Saw Tooth
	1<<13|3<<11|345, // 0x349  92.75hz Appx. F#2 Saw Tooth
	1<<13|3<<11|326, // 0x34A  98.16hz Appx. G2  Saw Tooth
	1<<13|3<<11|308, // 0x34B  103.9hz Appx. G#2 Saw Tooth
	1<<13|3<<11|288, // 0x34C  111.1hz Appx. A2  Saw Tooth
	1<<13|3<<11|272, // 0x34D  117.6hz Appx. A#2 Saw Tooth
	1<<13|3<<11|257, // 0x34E  124.5hz Appx. B2  Saw Tooth
	1<<13|3<<11|242, // 0x34F  132.2hz Appx. C3  Saw Tooth
	1<<13|3<<11|229, // 0x350  139.7hz Appx. C#3 Saw Tooth
	1<<13|3<<11|216, // 0x351  148.1hz Appx. D3  Saw Tooth
	1<<13|3<<11|204, // 0x352  156.9hz Appx. D#3 Saw Tooth
	1<<13|3<<11|192, // 0x353  166.7hz Appx. E3  Saw Tooth
	1<<13|3<<11|181, // 0x354  176.8hz Appx. F3  Saw Tooth
	1<<13|3<<11|171, // 0x355  187.1hz Appx. F#3 Saw Tooth
	1<<13|3<<11|162, // 0x356  197.5hz Appx. G3  Saw Tooth
	1<<13|3<<11|153, // 0x357  209.2hz Appx. G#3 Saw Tooth
	1<<13|3<<11|144, // 0x358  222.2hz Appx. A3  Saw Tooth
	1<<13|3<<11|136, // 0x359  235.3hz Appx. A#3 Saw Tooth
	1<<13|3<<11|129, // 0x35A  248.1hz Appx. B3  Saw Tooth
	1<<13|3<<11|121, // 0x35B  264.5hz Appx. C4  Saw Tooth
	1<<13|3<<11|114, // 0x35C  280.7hz Appx. C#4 Saw Tooth
	1<<13|3<<11|108, // 0x35D  296.3hz Appx. D4  Saw Tooth
	1<<13|3<<11|102, // 0x35E  313.7hz Appx. D#4 Saw Tooth
	1<<13|3<<11|96,  // 0x35F  333.3hz Appx. E4  Saw Tooth
	1<<13|3<<11|91,  // 0x360  351.6hz Appx. F4  Saw Tooth
	1<<13|3<<11|86,  // 0x361  372.1hz Appx. F#4 Saw Tooth
	1<<13|3<<11|81,  // 0x362  395.1hz Appx. G4  Saw Tooth
	1<<13|3<<11|76,  // 0x363  421.1hz Appx. G#4 Saw Tooth
	1<<13|3<<11|72,  // 0x364  444.4hz Appx. A4  Saw Tooth
	1<<13|3<<11|68,  // 0x365  470.6hz Appx. A#4 Saw Tooth
	1<<13|3<<11|64,  // 0x366  500.0hz Appx. B4  Saw Tooth
	1<<13|3<<11|61,  // 0x367  524.6hz Appx. C5  Saw Tooth
	1<<13|3<<11|57,  // 0x368  561.4hz Appx. C#5 Saw Tooth
	1<<13|3<<11|54,  // 0x369  592.6hz Appx. D5  Saw Tooth
	1<<13|3<<11|51,  // 0x36A  627.5hz Appx. D#5 Saw Tooth
	1<<13|3<<11|48,  // 0x36B  666.7hz Appx. E5  Saw Tooth
	1<<13|3<<11|46,  // 0x36C  695.7hz Appx. F5  Saw Tooth
	1<<13|3<<11|43,  // 0x36D  744.2hz Appx. F#5 Saw Tooth
	1<<13|3<<11|41,  // 0x36E  780.5hz Appx. G5  Saw Tooth
	1<<13|3<<11|38,  // 0x36F  842.1hz Appx. G#5 Saw Tooth
	1<<13|3<<11|36,  // 0x370  888.9hz Appx. A5  Saw Tooth
	1<<13|3<<11|34,  // 0x371  941.2hz Appx. A#5 Saw Tooth
	1<<13|3<<11|32,  // 0x372 1000.0hz Appx. B5  Saw Tooth
	1<<13|3<<11|30,  // 0x373 1066.7hz Appx. C6  Saw Tooth
	1<<13|3<<11|29,  // 0x374 1103.4hz Appx. C#6 Saw Tooth
	1<<13|3<<11|27,  // 0x375 1185.2hz Appx. D6  Saw Tooth
	1<<13|3<<11|26,  // 0x376 1230.8hz Appx. D#6 Saw Tooth
	1<<13|3<<11|24,  // 0x377 1333.3hz Appx. E6  Saw Tooth
	1<<13|3<<11|23,  // 0x378 1391.3hz Appx. F6  Saw Tooth
	1<<13|3<<11|22,  // 0x379 1454.5hz Appx. F#6 Saw Tooth
	1<<13|3<<11|20,  // 0x37A 1600.0hz Appx. G6  Saw Tooth
	1<<13|3<<11|19,  // 0x37B 1684.2hz Appx. G#6 Saw Tooth
	1<<13|3<<11|18,  // 0x37C 1777.8hz Appx. A6  Saw Tooth
	1<<13|3<<11|17,  // 0x37D 1882.4hz Appx. A#6 Saw Tooth
	1<<13|3<<11|16,  // 0x37E 2000.0hz Appx. B6  Saw Tooth
	1<<13|3<<11|15,  // 0x37F 2133.3hz Appx. C7  Saw Tooth

	2<<13|3<<11|581, // 0x380  55.08hz Appx. A1  Square
	2<<13|3<<11|548, // 0x381  58.39hz Appx. A#1 Square
	2<<13|3<<11|518, // 0x382  61.78hz Appx. B1  Square
	2<<13|3<<11|489, // 0x383  65.44hz Appx. C2  Square
	2<<13|3<<11|461, // 0x384  69.41hz Appx. C#2 Square
	2<<13|3<<11|435, // 0x385  73.56hz Appx. D2  Square
	2<<13|3<<11|411, // 0x386  77.86hz Appx. D#2 Square
	2<<13|3<<11|388, // 0x387  82.47hz Appx. E2  Square
	2<<13|3<<11|366, // 0x388  87.43hz Appx. F2  Square
	2<<13|3<<11|345, // 0x389  92.75hz Appx. F#2 Square
	2<<13|3<<11|326, // 0x38A  98.16hz Appx. G2  Square
	2<<13|3<<11|308, // 0x38B  103.9hz Appx. G#2 Square
	2<<13|3<<11|288, // 0x38C  111.1hz Appx. A2  Square
	2<<13|3<<11|272, // 0x38D  117.6hz Appx. A#2 Square
	2<<13|3<<11|257, // 0x38E  124.5hz Appx. B2  Square
	2<<13|3<<11|242, // 0x38F  132.2hz Appx. C3  Square
	2<<13|3<<11|229, // 0x390  139.7hz Appx. C#3 Square
	2<<13|3<<11|216, // 0x391  148.1hz Appx. D3  Square
	2<<13|3<<11|204, // 0x392  156.9hz Appx. D#3 Square
	2<<13|3<<11|192, // 0x393  166.7hz Appx. E3  Square
	2<<13|3<<11|181, // 0x394  176.8hz Appx. F3  Square
	2<<13|3<<11|171, // 0x395  187.1hz Appx. F#3 Square
	2<<13|3<<11|162, // 0x396  197.5hz Appx. G3  Square
	2<<13|3<<11|153, // 0x397  209.2hz Appx. G#3 Square
	2<<13|3<<11|144, // 0x398  222.2hz Appx. A3  Square
	2<<13|3<<11|136, // 0x399  235.3hz Appx. A#3 Square
	2<<13|3<<11|129, // 0x39A  248.1hz Appx. B3  Square
	2<<13|3<<11|121, // 0x39B  264.5hz Appx. C4  Square
	2<<13|3<<11|114, // 0x39C  280.7hz Appx. C#4 Square
	2<<13|3<<11|108, // 0x39D  296.3hz Appx. D4  Square
	2<<13|3<<11|102, // 0x39E  313.7hz Appx. D#4 Square
	2<<13|3<<11|96,  // 0x39F  333.3hz Appx. E4  Square
	2<<13|3<<11|91,  // 0x3A0  351.6hz Appx. F4  Square
	2<<13|3<<11|86,  // 0x3A1  372.1hz Appx. F#4 Square
	2<<13|3<<11|81,  // 0x3A2  395.1hz Appx. G4  Square
	2<<13|3<<11|76,  // 0x3A3  421.1hz Appx. G#4 Square
	2<<13|3<<11|72,  // 0x3A4  444.4hz Appx. A4  Square
	2<<13|3<<11|68,  // 0x3A5  470.6hz Appx. A#4 Square
	2<<13|3<<11|64,  // 0x3A6  500.0hz Appx. B4  Square
	2<<13|3<<11|61,  // 0x3A7  524.6hz Appx. C5  Square
	2<<13|3<<11|57,  // 0x3A8  561.4hz Appx. C#5 Square
	2<<13|3<<11|54,  // 0x3A9  592.6hz Appx. D5  Square
	2<<13|3<<11|51,  // 0x3AA  627.5hz Appx. D#5 Square
	2<<13|3<<11|48,  // 0x3AB  666.7hz Appx. E5  Square
	2<<13|3<<11|46,  // 0x3AC  695.7hz Appx. F5  Square
	2<<13|3<<11|43,  // 0x3AD  744.2hz Appx. F#5 Square
	2<<13|3<<11|41,  // 0x3AE  780.5hz Appx. G5  Square
	2<<13|3<<11|38,  // 0x3AF  842.1hz Appx. G#5 Square
	2<<13|3<<11|36,  // 0x3B0  888.9hz Appx. A5  Square
	2<<13|3<<11|34,  // 0x3B1  941.2hz Appx. A#5 Square
	2<<13|3<<11|32,  // 0x3B2 1000.0hz Appx. B5  Square
	2<<13|3<<11|30,  // 0x3B3 1066.7hz Appx. C6  Square
	2<<13|3<<11|29,  // 0x3B4 1103.4hz Appx. C#6 Square
	2<<13|3<<11|27,  // 0x3B5 1185.2hz Appx. D6  Square
	2<<13|3<<11|26,  // 0x3B6 1230.8hz Appx. D#6 Square
	2<<13|3<<11|24,  // 0x3B7 1333.3hz Appx. E6  Square
	2<<13|3<<11|23,  // 0x3B8 1391.3hz Appx. F6  Square
	2<<13|3<<11|22,  // 0x3B9 1454.5hz Appx. F#6 Square
	2<<13|3<<11|20,  // 0x3BA 1600.0hz Appx. G6  Square
	2<<13|3<<11|19,  // 0x3BB 1684.2hz Appx. G#6 Square
	2<<13|3<<11|18,  // 0x3BC 1777.8hz Appx. A6  Square
	2<<13|3<<11|17,  // 0x3BD 1882.4hz Appx. A#6 Square
	2<<13|3<<11|16,  // 0x3BE 2000.0hz Appx. B6  Square
	2<<13|3<<11|15,  // 0x3BF 2133.3hz Appx. C7  Square

	/* High Tones Tiny */

	2<<13|3<<11|14,  // 0x3C0 2285.7hz Appx. C#7 Square
	2<<13|3<<11|13,  // 0x3C1 2461.5hz Appx. D#7 Square
	2<<13|3<<11|12,  // 0x3C2 2666.6hz Appx. E7  Square
	2<<13|3<<11|11,  // 0x3C3 2909.1hz Appx. F7  Square
	2<<13|3<<11|10,  // 0x3C4 3200,0hz Appx. G7  Square
	2<<13|3<<11|9,   // 0x3C5 3555.6hz Appx. A7  Square
	2<<13|3<<11|8,   // 0x3C6 4000.0hz Appx. B7  Square
	2<<13|3<<11|7,   // 0x3C7 4571.4hz Appx. C#8 Square
	2<<13|3<<11|6,   // 0x3C8 5333.3hz Appx. E8  Square
	2<<13|3<<11|5,   // 0x3C9 6400.0hz Appx. G8  Square
	2<<13|3<<11|4,   // 0x3CA 8000.0hz Appx. B8  Square
	2<<13|3<<11|3,   // 0x3CB 10666.7hz Square

	_20(2<<13|3<<11|20)  // For Offset

	/* Assume Fixed Length as 3960, Sample Rate 31680Hz Divided by 8 */
	3<<13|3<<11|440, // 0x3E0 Noise Stride 440
	3<<13|3<<11|396, // 0x3E1 Noise Stride 396
	3<<13|3<<11|330, // 0x3E2 Noise Stride 330
	3<<13|3<<11|220, // 0x3E3 Noise Stride 220
	3<<13|3<<11|165, // 0x3E4 Noise Stride 165
	3<<13|3<<11|132, // 0x3E5 Noise Stride 132
	3<<13|3<<11|120, // 0x3E6 Noise Stride 120
	3<<13|3<<11|110, // 0x3E7 Noise Stride 110
	3<<13|3<<11|99,  // 0x3E8 Noise Stride 99
	3<<13|3<<11|90,  // 0x3E9 Noise Stride 90
	3<<13|3<<11|88,  // 0x3EA Noise Stride 88
	3<<13|3<<11|72,  // 0x3EB Noise Stride 72
	3<<13|3<<11|66,  // 0x3EC Noise Stride 66
	3<<13|3<<11|60,  // 0x3ED Noise Stride 60
	3<<13|3<<11|55,  // 0x3EE Noise Stride 55
	3<<13|3<<11|45,  // 0x3EF Noise Stride 45
	3<<13|3<<11|44,  // 0x3F0 Noise Stride 44
	3<<13|3<<11|40,  // 0x3F1 Noise Stride 40
	3<<13|3<<11|36,  // 0x3F2 Noise Stride 36
	3<<13|3<<11|30,  // 0x3F3 Noise Stride 30
	3<<13|3<<11|24,  // 0x3F4 Noise Stride 24
	3<<13|3<<11|22,  // 0x3F5 Noise Stride 22
	3<<13|3<<11|20,  // 0x3F6 Noise Stride 20
	3<<13|3<<11|18,  // 0x3F7 Noise Stride 18
	3<<13|3<<11|15,  // 0x3F8 Noise Stride 15
	3<<13|3<<11|12,  // 0x3F9 Noise Stride 12
	3<<13|3<<11|10,  // 0x3FA Noise Stride 10
	3<<13|3<<11|9,   // 0x3FB Noise Stride 9
	3<<13|3<<11|8,   // 0x3FC Noise Stride 8
	3<<13|3<<11|6,   // 0x3FD Noise Stride 6
	3<<13|3<<11|5,   // 0x3FE Noise Stride 5
	3<<13|3<<11|4,   // 0x3FF Noise Stride 4

	/* Special Sounds */

	7<<13|0<<11|72,  // 0x400 Silence

	0                // End of Index
};
