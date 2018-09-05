/**
 * sound32.h
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
 * Bit[11:0]: Length of Wave, 0 to 4095.
 *             If Bit[11:0] is 0, Long (0x1F40, Decimal 8000).
 *             If Bit[11:0] is 1, Super Long (0x3E80, Decimal 16000).
 * Bit[13:12]: Volume of Wave, 0 is Max., 1 is Bigger, 2 is Smaller, 3 is Zero (In Noise, Least).
 * Bit[15:14]: Type of Wave, 0 is Sin, 1 is Saw Tooth, 2 is Square, 3 is Noise, ordered by less edges which cause harmonics.
 *
 * Maximum number of blocks is 4096.
 * 0 means End of Sound Index
 */

/**
 * Music Code is 16-bit Blocks. Select up to 4096 sounds indexed by Sound Index.
 * Index is 0-4096.
 * 0xFFFF(65535) means End of Music Code.
 */

/**
 * These comments about frequencies assume 3.2Khz as the sampling rate, using on PWM direct output (including from 3.5mm minijack).
 * The actual sampling rate is appx. 3.168Khz to be adjusted to fit A4 on 440hz, e.g., G4 becomes 391.1Hz.
 */
sound_index _SOUND_INDEX[] =
{
	/* Volume Big */

	0<<14|0<<12|581, // 0x00  55.08hz Appx. A1  Sin
	0<<14|0<<12|548, // 0x01  58.39hz Appx. A#1 Sin
	0<<14|0<<12|518, // 0x02  61.78hz Appx. B1  Sin
	0<<14|0<<12|489, // 0x03  65.44hz Appx. C2  Sin
	0<<14|0<<12|461, // 0x04  69.41hz Appx. C#2 Sin
	0<<14|0<<12|435, // 0x05  73.56hz Appx. D2  Sin
	0<<14|0<<12|411, // 0x06  77.86hz Appx. D#2 Sin
	0<<14|0<<12|388, // 0x07  82.47hz Appx. E2  Sin
	0<<14|0<<12|366, // 0x08  87.43hz Appx. F2  Sin
	0<<14|0<<12|345, // 0x09  92.75hz Appx. F#2 Sin
	0<<14|0<<12|326, // 0x0A  98.16hz Appx. G2  Sin
	0<<14|0<<12|308, // 0x0B  103.9hz Appx. G#2 Sin
	0<<14|0<<12|288, // 0x0C  111.1hz Appx. A2  Sin
	0<<14|0<<12|272, // 0x0D  117.6hz Appx. A#2 Sin
	0<<14|0<<12|257, // 0x0E  124.5hz Appx. B2  Sin
	0<<14|0<<12|242, // 0x0F  132.2hz Appx. C3  Sin
	0<<14|0<<12|229, // 0x10  139.7hz Appx. C#3 Sin
	0<<14|0<<12|216, // 0x11  148.1hz Appx. D3  Sin
	0<<14|0<<12|204, // 0x12  156.9hz Appx. D#3 Sin
	0<<14|0<<12|192, // 0x13  166.7hz Appx. E3  Sin
	0<<14|0<<12|181, // 0x14  176.8hz Appx. F3  Sin
	0<<14|0<<12|171, // 0x15  187.1hz Appx. F#3 Sin
	0<<14|0<<12|162, // 0x16  197.5hz Appx. G3  Sin
	0<<14|0<<12|153, // 0x17  209.2hz Appx. G#3 Sin
	0<<14|0<<12|144, // 0x18  222.2hz Appx. A3  Sin
	0<<14|0<<12|136, // 0x19  235.3hz Appx. A#3 Sin
	0<<14|0<<12|129, // 0x1A  248.1hz Appx. B3  Sin
	0<<14|0<<12|121, // 0x1B  264.5hz Appx. C4  Sin
	0<<14|0<<12|114, // 0x1C  280.7hz Appx. C#4 Sin
	0<<14|0<<12|108, // 0x1D  296.3hz Appx. D4  Sin
	0<<14|0<<12|102, // 0x1E  313.7hz Appx. D#4 Sin
	0<<14|0<<12|96,  // 0x1F  333.3hz Appx. E4  Sin
	0<<14|0<<12|91,  // 0x20  351.6hz Appx. F4  Sin
	0<<14|0<<12|86,  // 0x21  372.1hz Appx. F#4 Sin
	0<<14|0<<12|81,  // 0x22  395.1hz Appx. G4  Sin
	0<<14|0<<12|76,  // 0x23  421.1hz Appx. G#4 Sin
	0<<14|0<<12|72,  // 0x24  444.4hz Appx. A4  Sin
	0<<14|0<<12|68,  // 0x25  470.6hz Appx. A#4 Sin
	0<<14|0<<12|64,  // 0x26  500.0hz Appx. B4  Sin
	0<<14|0<<12|61,  // 0x27  524.6hz Appx. C5  Sin
	0<<14|0<<12|57,  // 0x28  561.4hz Appx. C#5 Sin
	0<<14|0<<12|54,  // 0x29  592.6hz Appx. D5  Sin
	0<<14|0<<12|51,  // 0x2A  627.5hz Appx. D#5 Sin
	0<<14|0<<12|48,  // 0x2B  666.7hz Appx. E5  Sin
	0<<14|0<<12|46,  // 0x2C  695.7hz Appx. F5  Sin
	0<<14|0<<12|43,  // 0x2D  744.2hz Appx. F#5 Sin
	0<<14|0<<12|41,  // 0x2E  780.5hz Appx. G5  Sin
	0<<14|0<<12|38,  // 0x2F  842.1hz Appx. G#5 Sin
	0<<14|0<<12|36,  // 0x30  888.9hz Appx. A5  Sin
	0<<14|0<<12|34,  // 0x31  941.2hz Appx. A#5 Sin
	0<<14|0<<12|32,  // 0x32 1000.0hz Appx. B5  Sin
	0<<14|0<<12|30,  // 0x33 1066.7hz Appx. C6  Sin
	0<<14|0<<12|29,  // 0x34 1103.4hz Appx. C#6 Sin
	0<<14|0<<12|27,  // 0x35 1185.2hz Appx. D6  Sin
	0<<14|0<<12|26,  // 0x36 1230.8hz Appx. D#6 Sin
	0<<14|0<<12|24,  // 0x37 1333.3hz Appx. E6  Sin
	0<<14|0<<12|23,  // 0x38 1391.3hz Appx. F6  Sin
	0<<14|0<<12|22,  // 0x39 1454.5hz Appx. F#6 Sin
	0<<14|0<<12|20,  // 0x3A 1600.0hz Appx. G6  Sin
	0<<14|0<<12|19,  // 0x3B 1684.2hz Appx. G#6 Sin
	0<<14|0<<12|18,  // 0x3C 1777.8hz Appx. A6  Sin
	0<<14|0<<12|17,  // 0x3D 1882.4hz Appx. A#6 Sin
	0<<14|0<<12|16,  // 0x3E 2000.0hz Appx. B6  Sin
	0<<14|0<<12|15,  // 0x3F 2133.3hz Appx. C7  Sin

	1<<14|0<<12|581, // 0x40  55.08hz Appx. A1  Saw Tooth
	1<<14|0<<12|548, // 0x41  58.39hz Appx. A#1 Saw Tooth
	1<<14|0<<12|518, // 0x42  61.78hz Appx. B1  Saw Tooth
	1<<14|0<<12|489, // 0x43  65.44hz Appx. C2  Saw Tooth
	1<<14|0<<12|461, // 0x44  69.41hz Appx. C#2 Saw Tooth
	1<<14|0<<12|435, // 0x45  73.56hz Appx. D2  Saw Tooth
	1<<14|0<<12|411, // 0x46  77.86hz Appx. D#2 Saw Tooth
	1<<14|0<<12|388, // 0x47  82.47hz Appx. E2  Saw Tooth
	1<<14|0<<12|366, // 0x48  87.43hz Appx. F2  Saw Tooth
	1<<14|0<<12|345, // 0x49  92.75hz Appx. F#2 Saw Tooth
	1<<14|0<<12|326, // 0x4A  98.16hz Appx. G2  Saw Tooth
	1<<14|0<<12|308, // 0x4B  103.9hz Appx. G#2 Saw Tooth
	1<<14|0<<12|288, // 0x4C  111.1hz Appx. A2  Saw Tooth
	1<<14|0<<12|272, // 0x4D  117.6hz Appx. A#2 Saw Tooth
	1<<14|0<<12|257, // 0x4E  124.5hz Appx. B2  Saw Tooth
	1<<14|0<<12|242, // 0x4F  132.2hz Appx. C3  Saw Tooth
	1<<14|0<<12|229, // 0x50  139.7hz Appx. C#3 Saw Tooth
	1<<14|0<<12|216, // 0x51  148.1hz Appx. D3  Saw Tooth
	1<<14|0<<12|204, // 0x52  156.9hz Appx. D#3 Saw Tooth
	1<<14|0<<12|192, // 0x53  166.7hz Appx. E3  Saw Tooth
	1<<14|0<<12|181, // 0x54  176.8hz Appx. F3  Saw Tooth
	1<<14|0<<12|171, // 0x55  187.1hz Appx. F#3 Saw Tooth
	1<<14|0<<12|162, // 0x56  197.5hz Appx. G3  Saw Tooth
	1<<14|0<<12|153, // 0x57  209.2hz Appx. G#3 Saw Tooth
	1<<14|0<<12|144, // 0x58  222.2hz Appx. A3  Saw Tooth
	1<<14|0<<12|136, // 0x59  235.3hz Appx. A#3 Saw Tooth
	1<<14|0<<12|129, // 0x5A  248.1hz Appx. B3  Saw Tooth
	1<<14|0<<12|121, // 0x5B  264.5hz Appx. C4  Saw Tooth
	1<<14|0<<12|114, // 0x5C  280.7hz Appx. C#4 Saw Tooth
	1<<14|0<<12|108, // 0x5D  296.3hz Appx. D4  Saw Tooth
	1<<14|0<<12|102, // 0x5E  313.7hz Appx. D#4 Saw Tooth
	1<<14|0<<12|96,  // 0x5F  333.3hz Appx. E4  Saw Tooth
	1<<14|0<<12|91,  // 0x60  351.6hz Appx. F4  Saw Tooth
	1<<14|0<<12|86,  // 0x61  372.1hz Appx. F#4 Saw Tooth
	1<<14|0<<12|81,  // 0x62  395.1hz Appx. G4  Saw Tooth
	1<<14|0<<12|76,  // 0x63  421.1hz Appx. G#4 Saw Tooth
	1<<14|0<<12|72,  // 0x64  444.4hz Appx. A4  Saw Tooth
	1<<14|0<<12|68,  // 0x65  470.6hz Appx. A#4 Saw Tooth
	1<<14|0<<12|64,  // 0x66  500.0hz Appx. B4  Saw Tooth
	1<<14|0<<12|61,  // 0x67  524.6hz Appx. C5  Saw Tooth
	1<<14|0<<12|57,  // 0x68  561.4hz Appx. C#5 Saw Tooth
	1<<14|0<<12|54,  // 0x69  592.6hz Appx. D5  Saw Tooth
	1<<14|0<<12|51,  // 0x6A  627.5hz Appx. D#5 Saw Tooth
	1<<14|0<<12|48,  // 0x6B  666.7hz Appx. E5  Saw Tooth
	1<<14|0<<12|46,  // 0x6C  695.7hz Appx. F5  Saw Tooth
	1<<14|0<<12|43,  // 0x6D  744.2hz Appx. F#5 Saw Tooth
	1<<14|0<<12|41,  // 0x6E  780.5hz Appx. G5  Saw Tooth
	1<<14|0<<12|38,  // 0x6F  842.1hz Appx. G#5 Saw Tooth
	1<<14|0<<12|36,  // 0x70  888.9hz Appx. A5  Saw Tooth
	1<<14|0<<12|34,  // 0x71  941.2hz Appx. A#5 Saw Tooth
	1<<14|0<<12|32,  // 0x72 1000.0hz Appx. B5  Saw Tooth
	1<<14|0<<12|30,  // 0x73 1066.7hz Appx. C6  Saw Tooth
	1<<14|0<<12|29,  // 0x74 1103.4hz Appx. C#6 Saw Tooth
	1<<14|0<<12|27,  // 0x75 1185.2hz Appx. D6  Saw Tooth
	1<<14|0<<12|26,  // 0x76 1230.8hz Appx. D#6 Saw Tooth
	1<<14|0<<12|24,  // 0x77 1333.3hz Appx. E6  Saw Tooth
	1<<14|0<<12|23,  // 0x78 1391.3hz Appx. F6  Saw Tooth
	1<<14|0<<12|22,  // 0x79 1454.5hz Appx. F#6 Saw Tooth
	1<<14|0<<12|20,  // 0x7A 1600.0hz Appx. G6  Saw Tooth
	1<<14|0<<12|19,  // 0x7B 1684.2hz Appx. G#6 Saw Tooth
	1<<14|0<<12|18,  // 0x7C 1777.8hz Appx. A6  Saw Tooth
	1<<14|0<<12|17,  // 0x7D 1882.4hz Appx. A#6 Saw Tooth
	1<<14|0<<12|16,  // 0x7E 2000.0hz Appx. B6  Saw Tooth
	1<<14|0<<12|15,  // 0x7F 2133.3hz Appx. C7  Saw Tooth

	2<<14|0<<12|581, // 0x80  55.08hz Appx. A1  Square
	2<<14|0<<12|548, // 0x81  58.39hz Appx. A#1 Square
	2<<14|0<<12|518, // 0x82  61.78hz Appx. B1  Square
	2<<14|0<<12|489, // 0x83  65.44hz Appx. C2  Square
	2<<14|0<<12|461, // 0x84  69.41hz Appx. C#2 Square
	2<<14|0<<12|435, // 0x85  73.56hz Appx. D2  Square
	2<<14|0<<12|411, // 0x86  77.86hz Appx. D#2 Square
	2<<14|0<<12|388, // 0x87  82.47hz Appx. E2  Square
	2<<14|0<<12|366, // 0x88  87.43hz Appx. F2  Square
	2<<14|0<<12|345, // 0x89  92.75hz Appx. F#2 Square
	2<<14|0<<12|326, // 0x8A  98.16hz Appx. G2  Square
	2<<14|0<<12|308, // 0x8B  103.9hz Appx. G#2 Square
	2<<14|0<<12|288, // 0x8C  111.1hz Appx. A2  Square
	2<<14|0<<12|272, // 0x8D  117.6hz Appx. A#2 Square
	2<<14|0<<12|257, // 0x8E  124.5hz Appx. B2  Square
	2<<14|0<<12|242, // 0x8F  132.2hz Appx. C3  Square
	2<<14|0<<12|229, // 0x90  139.7hz Appx. C#3 Square
	2<<14|0<<12|216, // 0x91  148.1hz Appx. D3  Square
	2<<14|0<<12|204, // 0x92  156.9hz Appx. D#3 Square
	2<<14|0<<12|192, // 0x93  166.7hz Appx. E3  Square
	2<<14|0<<12|181, // 0x94  176.8hz Appx. F3  Square
	2<<14|0<<12|171, // 0x95  187.1hz Appx. F#3 Square
	2<<14|0<<12|162, // 0x96  197.5hz Appx. G3  Square
	2<<14|0<<12|153, // 0x97  209.2hz Appx. G#3 Square
	2<<14|0<<12|144, // 0x98  222.2hz Appx. A3  Square
	2<<14|0<<12|136, // 0x99  235.3hz Appx. A#3 Square
	2<<14|0<<12|129, // 0x9A  248.1hz Appx. B3  Square
	2<<14|0<<12|121, // 0x9B  264.5hz Appx. C4  Square
	2<<14|0<<12|114, // 0x9C  280.7hz Appx. C#4 Square
	2<<14|0<<12|108, // 0x9D  296.3hz Appx. D4  Square
	2<<14|0<<12|102, // 0x9E  313.7hz Appx. D#4 Square
	2<<14|0<<12|96,  // 0x9F  333.3hz Appx. E4  Square
	2<<14|0<<12|91,  // 0xA0  351.6hz Appx. F4  Square
	2<<14|0<<12|86,  // 0xA1  372.1hz Appx. F#4 Square
	2<<14|0<<12|81,  // 0xA2  395.1hz Appx. G4  Square
	2<<14|0<<12|76,  // 0xA3  421.1hz Appx. G#4 Square
	2<<14|0<<12|72,  // 0xA4  444.4hz Appx. A4  Square
	2<<14|0<<12|68,  // 0xA5  470.6hz Appx. A#4 Square
	2<<14|0<<12|64,  // 0xA6  500.0hz Appx. B4  Square
	2<<14|0<<12|61,  // 0xA7  524.6hz Appx. C5  Square
	2<<14|0<<12|57,  // 0xA8  561.4hz Appx. C#5 Square
	2<<14|0<<12|54,  // 0xA9  592.6hz Appx. D5  Square
	2<<14|0<<12|51,  // 0xAA  627.5hz Appx. D#5 Square
	2<<14|0<<12|48,  // 0xAB  666.7hz Appx. E5  Square
	2<<14|0<<12|46,  // 0xAC  695.7hz Appx. F5  Square
	2<<14|0<<12|43,  // 0xAD  744.2hz Appx. F#5 Square
	2<<14|0<<12|41,  // 0xAE  780.5hz Appx. G5  Square
	2<<14|0<<12|38,  // 0xAF  842.1hz Appx. G#5 Square
	2<<14|0<<12|36,  // 0xB0  888.9hz Appx. A5  Square
	2<<14|0<<12|34,  // 0xB1  941.2hz Appx. A#5 Square
	2<<14|0<<12|32,  // 0xB2 1000.0hz Appx. B5  Square
	2<<14|0<<12|30,  // 0xB3 1066.7hz Appx. C6  Square
	2<<14|0<<12|29,  // 0xB4 1103.4hz Appx. C#6 Square
	2<<14|0<<12|27,  // 0xB5 1185.2hz Appx. D6  Square
	2<<14|0<<12|26,  // 0xB6 1230.8hz Appx. D#6 Square
	2<<14|0<<12|24,  // 0xB7 1333.3hz Appx. E6  Square
	2<<14|0<<12|23,  // 0xB8 1391.3hz Appx. F6  Square
	2<<14|0<<12|22,  // 0xB9 1454.5hz Appx. F#6 Square
	2<<14|0<<12|20,  // 0xBA 1600.0hz Appx. G6  Square
	2<<14|0<<12|19,  // 0xBB 1684.2hz Appx. G#6 Square
	2<<14|0<<12|18,  // 0xBC 1777.8hz Appx. A6  Square
	2<<14|0<<12|17,  // 0xBD 1882.4hz Appx. A#6 Square
	2<<14|0<<12|16,  // 0xBE 2000.0hz Appx. B6  Square
	2<<14|0<<12|15,  // 0xBF 2133.3hz Appx. C7  Square

	/* Assume Fixed Length as 3960, Sample Rate 31680Hz Divided by 8 */
	3<<14|0<<12|440, // Noise Stride 440
	3<<14|0<<12|396, // Noise Stride 396
	3<<14|0<<12|330, // Noise Stride 330
	3<<14|0<<12|220, // Noise Stride 220
	3<<14|0<<12|165, // Noise Stride 165
	3<<14|0<<12|132, // Noise Stride 132
	3<<14|0<<12|120, // Noise Stride 120
	3<<14|0<<12|110, // Noise Stride 110
	3<<14|0<<12|99,  // Noise Stride 99
	3<<14|0<<12|90,  // Noise Stride 90
	3<<14|0<<12|88,  // Noise Stride 88
	3<<14|0<<12|72,  // Noise Stride 72
	3<<14|0<<12|66,  // Noise Stride 66
	3<<14|0<<12|60,  // Noise Stride 60
	3<<14|0<<12|55,  // Noise Stride 55
	3<<14|0<<12|45,  // Noise Stride 45
	3<<14|0<<12|44,  // Noise Stride 44
	3<<14|0<<12|40,  // Noise Stride 40
	3<<14|0<<12|36,  // Noise Stride 36
	3<<14|0<<12|30,  // Noise Stride 30
	3<<14|0<<12|24,  // Noise Stride 24
	3<<14|0<<12|22,  // Noise Stride 22
	3<<14|0<<12|20,  // Noise Stride 20
	3<<14|0<<12|18,  // Noise Stride 18
	3<<14|0<<12|15,  // Noise Stride 15
	3<<14|0<<12|12,  // Noise Stride 12
	3<<14|0<<12|10,  // Noise Stride 10
	3<<14|0<<12|9,   // Noise Stride 9
	3<<14|0<<12|8,   // Noise Stride 8
	3<<14|0<<12|6,   // Noise Stride 6
	3<<14|0<<12|5,   // Noise Stride 5
	3<<14|0<<12|4,   // Noise Stride 4
	_32(0<<14|0<<12|32)  // For Offset

	/* Volume Middle */

	0<<14|1<<12|581, // 0x100  55.08hz Appx. A1  Sin
	0<<14|1<<12|548, // 0x101  58.39hz Appx. A#1 Sin
	0<<14|1<<12|518, // 0x102  61.78hz Appx. B1  Sin
	0<<14|1<<12|489, // 0x103  65.44hz Appx. C2  Sin
	0<<14|1<<12|461, // 0x104  69.41hz Appx. C#2 Sin
	0<<14|1<<12|435, // 0x105  73.56hz Appx. D2  Sin
	0<<14|1<<12|411, // 0x106  77.86hz Appx. D#2 Sin
	0<<14|1<<12|388, // 0x107  82.47hz Appx. E2  Sin
	0<<14|1<<12|366, // 0x108  87.43hz Appx. F2  Sin
	0<<14|1<<12|345, // 0x109  92.75hz Appx. F#2 Sin
	0<<14|1<<12|326, // 0x10A  98.16hz Appx. G2  Sin
	0<<14|1<<12|308, // 0x10B  103.9hz Appx. G#2 Sin
	0<<14|1<<12|288, // 0x10C  111.1hz Appx. A2  Sin
	0<<14|1<<12|272, // 0x10D  117.6hz Appx. A#2 Sin
	0<<14|1<<12|257, // 0x10E  124.5hz Appx. B2  Sin
	0<<14|1<<12|242, // 0x10F  132.2hz Appx. C3  Sin
	0<<14|1<<12|229, // 0x110  139.7hz Appx. C#3 Sin
	0<<14|1<<12|216, // 0x111  148.1hz Appx. D3  Sin
	0<<14|1<<12|204, // 0x112  156.9hz Appx. D#3 Sin
	0<<14|1<<12|192, // 0x113  166.7hz Appx. E3  Sin
	0<<14|1<<12|181, // 0x114  176.8hz Appx. F3  Sin
	0<<14|1<<12|171, // 0x115  187.1hz Appx. F#3 Sin
	0<<14|1<<12|162, // 0x116  197.5hz Appx. G3  Sin
	0<<14|1<<12|153, // 0x117  209.2hz Appx. G#3 Sin
	0<<14|1<<12|144, // 0x118  222.2hz Appx. A3  Sin
	0<<14|1<<12|136, // 0x119  235.3hz Appx. A#3 Sin
	0<<14|1<<12|129, // 0x11A  248.1hz Appx. B3  Sin
	0<<14|1<<12|121, // 0x11B  264.5hz Appx. C4  Sin
	0<<14|1<<12|114, // 0x11C  280.7hz Appx. C#4 Sin
	0<<14|1<<12|108, // 0x11D  296.3hz Appx. D4  Sin
	0<<14|1<<12|102, // 0x11E  313.7hz Appx. D#4 Sin
	0<<14|1<<12|96,  // 0x11F  333.3hz Appx. E4  Sin
	0<<14|1<<12|91,  // 0x120  351.6hz Appx. F4  Sin
	0<<14|1<<12|86,  // 0x121  372.1hz Appx. F#4 Sin
	0<<14|1<<12|81,  // 0x122  395.1hz Appx. G4  Sin
	0<<14|1<<12|76,  // 0x123  421.1hz Appx. G#4 Sin
	0<<14|1<<12|72,  // 0x124  444.4hz Appx. A4  Sin
	0<<14|1<<12|68,  // 0x125  470.6hz Appx. A#4 Sin
	0<<14|1<<12|64,  // 0x126  500.0hz Appx. B4  Sin
	0<<14|1<<12|61,  // 0x127  524.6hz Appx. C5  Sin
	0<<14|1<<12|57,  // 0x128  561.4hz Appx. C#5 Sin
	0<<14|1<<12|54,  // 0x129  592.6hz Appx. D5  Sin
	0<<14|1<<12|51,  // 0x12A  627.5hz Appx. D#5 Sin
	0<<14|1<<12|48,  // 0x12B  666.7hz Appx. E5  Sin
	0<<14|1<<12|46,  // 0x12C  695.7hz Appx. F5  Sin
	0<<14|1<<12|43,  // 0x12D  744.2hz Appx. F#5 Sin
	0<<14|1<<12|41,  // 0x12E  780.5hz Appx. G5  Sin
	0<<14|1<<12|38,  // 0x12F  842.1hz Appx. G#5 Sin
	0<<14|1<<12|36,  // 0x130  888.9hz Appx. A5  Sin
	0<<14|1<<12|34,  // 0x131  941.2hz Appx. A#5 Sin
	0<<14|1<<12|32,  // 0x132 1000.0hz Appx. B5  Sin
	0<<14|1<<12|30,  // 0x133 1066.7hz Appx. C6  Sin
	0<<14|1<<12|29,  // 0x134 1103.4hz Appx. C#6 Sin
	0<<14|1<<12|27,  // 0x135 1185.2hz Appx. D6  Sin
	0<<14|1<<12|26,  // 0x136 1230.8hz Appx. D#6 Sin
	0<<14|1<<12|24,  // 0x137 1333.3hz Appx. E6  Sin
	0<<14|1<<12|23,  // 0x138 1391.3hz Appx. F6  Sin
	0<<14|1<<12|22,  // 0x139 1454.5hz Appx. F#6 Sin
	0<<14|1<<12|20,  // 0x13A 1600.0hz Appx. G6  Sin
	0<<14|1<<12|19,  // 0x13B 1684.2hz Appx. G#6 Sin
	0<<14|1<<12|18,  // 0x13C 1777.8hz Appx. A6  Sin
	0<<14|1<<12|17,  // 0x13D 1882.4hz Appx. A#6 Sin
	0<<14|1<<12|16,  // 0x13E 2000.0hz Appx. B6  Sin
	0<<14|1<<12|15,  // 0x13F 2133.3hz Appx. C7  Sin

	1<<14|1<<12|581, // 0x140  55.08hz Appx. A1  Saw Tooth
	1<<14|1<<12|548, // 0x141  58.39hz Appx. A#1 Saw Tooth
	1<<14|1<<12|518, // 0x142  61.78hz Appx. B1  Saw Tooth
	1<<14|1<<12|489, // 0x143  65.44hz Appx. C2  Saw Tooth
	1<<14|1<<12|461, // 0x144  69.41hz Appx. C#2 Saw Tooth
	1<<14|1<<12|435, // 0x145  73.56hz Appx. D2  Saw Tooth
	1<<14|1<<12|411, // 0x146  77.86hz Appx. D#2 Saw Tooth
	1<<14|1<<12|388, // 0x147  82.47hz Appx. E2  Saw Tooth
	1<<14|1<<12|366, // 0x148  87.43hz Appx. F2  Saw Tooth
	1<<14|1<<12|345, // 0x149  92.75hz Appx. F#2 Saw Tooth
	1<<14|1<<12|326, // 0x14A  98.16hz Appx. G2  Saw Tooth
	1<<14|1<<12|308, // 0x14B  103.9hz Appx. G#2 Saw Tooth
	1<<14|1<<12|288, // 0x14C  111.1hz Appx. A2  Saw Tooth
	1<<14|1<<12|272, // 0x14D  117.6hz Appx. A#2 Saw Tooth
	1<<14|1<<12|257, // 0x14E  124.5hz Appx. B2  Saw Tooth
	1<<14|1<<12|242, // 0x14F  132.2hz Appx. C3  Saw Tooth
	1<<14|1<<12|229, // 0x150  139.7hz Appx. C#3 Saw Tooth
	1<<14|1<<12|216, // 0x151  148.1hz Appx. D3  Saw Tooth
	1<<14|1<<12|204, // 0x152  156.9hz Appx. D#3 Saw Tooth
	1<<14|1<<12|192, // 0x153  166.7hz Appx. E3  Saw Tooth
	1<<14|1<<12|181, // 0x154  176.8hz Appx. F3  Saw Tooth
	1<<14|1<<12|171, // 0x155  187.1hz Appx. F#3 Saw Tooth
	1<<14|1<<12|162, // 0x156  197.5hz Appx. G3  Saw Tooth
	1<<14|1<<12|153, // 0x157  209.2hz Appx. G#3 Saw Tooth
	1<<14|1<<12|144, // 0x158  222.2hz Appx. A3  Saw Tooth
	1<<14|1<<12|136, // 0x159  235.3hz Appx. A#3 Saw Tooth
	1<<14|1<<12|129, // 0x15A  248.1hz Appx. B3  Saw Tooth
	1<<14|1<<12|121, // 0x15B  264.5hz Appx. C4  Saw Tooth
	1<<14|1<<12|114, // 0x15C  280.7hz Appx. C#4 Saw Tooth
	1<<14|1<<12|108, // 0x15D  296.3hz Appx. D4  Saw Tooth
	1<<14|1<<12|102, // 0x15E  313.7hz Appx. D#4 Saw Tooth
	1<<14|1<<12|96,  // 0x15F  333.3hz Appx. E4  Saw Tooth
	1<<14|1<<12|91,  // 0x160  351.6hz Appx. F4  Saw Tooth
	1<<14|1<<12|86,  // 0x161  372.1hz Appx. F#4 Saw Tooth
	1<<14|1<<12|81,  // 0x162  395.1hz Appx. G4  Saw Tooth
	1<<14|1<<12|76,  // 0x163  421.1hz Appx. G#4 Saw Tooth
	1<<14|1<<12|72,  // 0x164  444.4hz Appx. A4  Saw Tooth
	1<<14|1<<12|68,  // 0x165  470.6hz Appx. A#4 Saw Tooth
	1<<14|1<<12|64,  // 0x166  500.0hz Appx. B4  Saw Tooth
	1<<14|1<<12|61,  // 0x167  524.6hz Appx. C5  Saw Tooth
	1<<14|1<<12|57,  // 0x168  561.4hz Appx. C#5 Saw Tooth
	1<<14|1<<12|54,  // 0x169  592.6hz Appx. D5  Saw Tooth
	1<<14|1<<12|51,  // 0x16A  627.5hz Appx. D#5 Saw Tooth
	1<<14|1<<12|48,  // 0x16B  666.7hz Appx. E5  Saw Tooth
	1<<14|1<<12|46,  // 0x16C  695.7hz Appx. F5  Saw Tooth
	1<<14|1<<12|43,  // 0x16D  744.2hz Appx. F#5 Saw Tooth
	1<<14|1<<12|41,  // 0x16E  780.5hz Appx. G5  Saw Tooth
	1<<14|1<<12|38,  // 0x16F  842.1hz Appx. G#5 Saw Tooth
	1<<14|1<<12|36,  // 0x170  888.9hz Appx. A5  Saw Tooth
	1<<14|1<<12|34,  // 0x171  941.2hz Appx. A#5 Saw Tooth
	1<<14|1<<12|32,  // 0x172 1000.0hz Appx. B5  Saw Tooth
	1<<14|1<<12|30,  // 0x173 1066.7hz Appx. C6  Saw Tooth
	1<<14|1<<12|29,  // 0x174 1103.4hz Appx. C#6 Saw Tooth
	1<<14|1<<12|27,  // 0x175 1185.2hz Appx. D6  Saw Tooth
	1<<14|1<<12|26,  // 0x176 1230.8hz Appx. D#6 Saw Tooth
	1<<14|1<<12|24,  // 0x177 1333.3hz Appx. E6  Saw Tooth
	1<<14|1<<12|23,  // 0x178 1391.3hz Appx. F6  Saw Tooth
	1<<14|1<<12|22,  // 0x179 1454.5hz Appx. F#6 Saw Tooth
	1<<14|1<<12|20,  // 0x17A 1600.0hz Appx. G6  Saw Tooth
	1<<14|1<<12|19,  // 0x17B 1684.2hz Appx. G#6 Saw Tooth
	1<<14|1<<12|18,  // 0x17C 1777.8hz Appx. A6  Saw Tooth
	1<<14|1<<12|17,  // 0x17D 1882.4hz Appx. A#6 Saw Tooth
	1<<14|1<<12|16,  // 0x17E 2000.0hz Appx. B6  Saw Tooth
	1<<14|1<<12|15,  // 0x17F 2133.3hz Appx. C7  Saw Tooth

	2<<14|1<<12|581, // 0x180  55.08hz Appx. A1  Square
	2<<14|1<<12|548, // 0x181  58.39hz Appx. A#1 Square
	2<<14|1<<12|518, // 0x182  61.78hz Appx. B1  Square
	2<<14|1<<12|489, // 0x183  65.44hz Appx. C2  Square
	2<<14|1<<12|461, // 0x184  69.41hz Appx. C#2 Square
	2<<14|1<<12|435, // 0x185  73.56hz Appx. D2  Square
	2<<14|1<<12|411, // 0x186  77.86hz Appx. D#2 Square
	2<<14|1<<12|388, // 0x187  82.47hz Appx. E2  Square
	2<<14|1<<12|366, // 0x188  87.43hz Appx. F2  Square
	2<<14|1<<12|345, // 0x189  92.75hz Appx. F#2 Square
	2<<14|1<<12|326, // 0x18A  98.16hz Appx. G2  Square
	2<<14|1<<12|308, // 0x18B  103.9hz Appx. G#2 Square
	2<<14|1<<12|288, // 0x18C  111.1hz Appx. A2  Square
	2<<14|1<<12|272, // 0x18D  117.6hz Appx. A#2 Square
	2<<14|1<<12|257, // 0x18E  124.5hz Appx. B2  Square
	2<<14|1<<12|242, // 0x18F  132.2hz Appx. C3  Square
	2<<14|1<<12|229, // 0x190  139.7hz Appx. C#3 Square
	2<<14|1<<12|216, // 0x191  148.1hz Appx. D3  Square
	2<<14|1<<12|204, // 0x192  156.9hz Appx. D#3 Square
	2<<14|1<<12|192, // 0x193  166.7hz Appx. E3  Square
	2<<14|1<<12|181, // 0x194  176.8hz Appx. F3  Square
	2<<14|1<<12|171, // 0x195  187.1hz Appx. F#3 Square
	2<<14|1<<12|162, // 0x196  197.5hz Appx. G3  Square
	2<<14|1<<12|153, // 0x197  209.2hz Appx. G#3 Square
	2<<14|1<<12|144, // 0x198  222.2hz Appx. A3  Square
	2<<14|1<<12|136, // 0x199  235.3hz Appx. A#3 Square
	2<<14|1<<12|129, // 0x19A  248.1hz Appx. B3  Square
	2<<14|1<<12|121, // 0x19B  264.5hz Appx. C4  Square
	2<<14|1<<12|114, // 0x19C  280.7hz Appx. C#4 Square
	2<<14|1<<12|108, // 0x19D  296.3hz Appx. D4  Square
	2<<14|1<<12|102, // 0x19E  313.7hz Appx. D#4 Square
	2<<14|1<<12|96,  // 0x19F  333.3hz Appx. E4  Square
	2<<14|1<<12|91,  // 0x1A0  351.6hz Appx. F4  Square
	2<<14|1<<12|86,  // 0x1A1  372.1hz Appx. F#4 Square
	2<<14|1<<12|81,  // 0x1A2  395.1hz Appx. G4  Square
	2<<14|1<<12|76,  // 0x1A3  421.1hz Appx. G#4 Square
	2<<14|1<<12|72,  // 0x1A4  444.4hz Appx. A4  Square
	2<<14|1<<12|68,  // 0x1A5  470.6hz Appx. A#4 Square
	2<<14|1<<12|64,  // 0x1A6  500.0hz Appx. B4  Square
	2<<14|1<<12|61,  // 0x1A7  524.6hz Appx. C5  Square
	2<<14|1<<12|57,  // 0x1A8  561.4hz Appx. C#5 Square
	2<<14|1<<12|54,  // 0x1A9  592.6hz Appx. D5  Square
	2<<14|1<<12|51,  // 0x1AA  627.5hz Appx. D#5 Square
	2<<14|1<<12|48,  // 0x1AB  666.7hz Appx. E5  Square
	2<<14|1<<12|46,  // 0x1AC  695.7hz Appx. F5  Square
	2<<14|1<<12|43,  // 0x1AD  744.2hz Appx. F#5 Square
	2<<14|1<<12|41,  // 0x1AE  780.5hz Appx. G5  Square
	2<<14|1<<12|38,  // 0x1AF  842.1hz Appx. G#5 Square
	2<<14|1<<12|36,  // 0x1B0  888.9hz Appx. A5  Square
	2<<14|1<<12|34,  // 0x1B1  941.2hz Appx. A#5 Square
	2<<14|1<<12|32,  // 0x1B2 1000.0hz Appx. B5  Square
	2<<14|1<<12|30,  // 0x1B3 1066.7hz Appx. C6  Square
	2<<14|1<<12|29,  // 0x1B4 1103.4hz Appx. C#6 Square
	2<<14|1<<12|27,  // 0x1B5 1185.2hz Appx. D6  Square
	2<<14|1<<12|26,  // 0x1B6 1230.8hz Appx. D#6 Square
	2<<14|1<<12|24,  // 0x1B7 1333.3hz Appx. E6  Square
	2<<14|1<<12|23,  // 0x1B8 1391.3hz Appx. F6  Square
	2<<14|1<<12|22,  // 0x1B9 1454.5hz Appx. F#6 Square
	2<<14|1<<12|20,  // 0x1BA 1600.0hz Appx. G6  Square
	2<<14|1<<12|19,  // 0x1BB 1684.2hz Appx. G#6 Square
	2<<14|1<<12|18,  // 0x1BC 1777.8hz Appx. A6  Square
	2<<14|1<<12|17,  // 0x1BD 1882.4hz Appx. A#6 Square
	2<<14|1<<12|16,  // 0x1BE 2000.0hz Appx. B6  Square
	2<<14|1<<12|15,  // 0x1BF 2133.3hz Appx. C7  Square

	/* Assume Fixed Length as 3960, Sample Rate 31680Hz Divided by 8 */
	3<<14|1<<12|440, // Noise Stride 440
	3<<14|1<<12|396, // Noise Stride 396
	3<<14|1<<12|330, // Noise Stride 330
	3<<14|1<<12|220, // Noise Stride 220
	3<<14|1<<12|165, // Noise Stride 165
	3<<14|1<<12|132, // Noise Stride 132
	3<<14|1<<12|120, // Noise Stride 120
	3<<14|1<<12|110, // Noise Stride 110
	3<<14|1<<12|99,  // Noise Stride 99
	3<<14|1<<12|90,  // Noise Stride 90
	3<<14|1<<12|88,  // Noise Stride 88
	3<<14|1<<12|72,  // Noise Stride 72
	3<<14|1<<12|66,  // Noise Stride 66
	3<<14|1<<12|60,  // Noise Stride 60
	3<<14|1<<12|55,  // Noise Stride 55
	3<<14|1<<12|45,  // Noise Stride 45
	3<<14|1<<12|44,  // Noise Stride 44
	3<<14|1<<12|40,  // Noise Stride 40
	3<<14|1<<12|36,  // Noise Stride 36
	3<<14|1<<12|30,  // Noise Stride 30
	3<<14|1<<12|24,  // Noise Stride 24
	3<<14|1<<12|22,  // Noise Stride 22
	3<<14|1<<12|20,  // Noise Stride 20
	3<<14|1<<12|18,  // Noise Stride 18
	3<<14|1<<12|15,  // Noise Stride 15
	3<<14|1<<12|12,  // Noise Stride 12
	3<<14|1<<12|10,  // Noise Stride 10
	3<<14|1<<12|9,   // Noise Stride 9
	3<<14|1<<12|8,   // Noise Stride 8
	3<<14|1<<12|6,   // Noise Stride 6
	3<<14|1<<12|5,   // Noise Stride 5
	3<<14|1<<12|4,   // Noise Stride 4
	_32(0<<14|1<<12|32)  // For Offset

	/* Volume Small */

	0<<14|2<<12|581, // 0x200  55.08hz Appx. A1  Sin
	0<<14|2<<12|548, // 0x201  58.39hz Appx. A#1 Sin
	0<<14|2<<12|518, // 0x202  61.78hz Appx. B1  Sin
	0<<14|2<<12|489, // 0x203  65.44hz Appx. C2  Sin
	0<<14|2<<12|461, // 0x204  69.41hz Appx. C#2 Sin
	0<<14|2<<12|435, // 0x205  73.56hz Appx. D2  Sin
	0<<14|2<<12|411, // 0x206  77.86hz Appx. D#2 Sin
	0<<14|2<<12|388, // 0x207  82.47hz Appx. E2  Sin
	0<<14|2<<12|366, // 0x208  87.43hz Appx. F2  Sin
	0<<14|2<<12|345, // 0x209  92.75hz Appx. F#2 Sin
	0<<14|2<<12|326, // 0x20A  98.16hz Appx. G2  Sin
	0<<14|2<<12|308, // 0x20B  103.9hz Appx. G#2 Sin
	0<<14|2<<12|288, // 0x20C  111.1hz Appx. A2  Sin
	0<<14|2<<12|272, // 0x20D  117.6hz Appx. A#2 Sin
	0<<14|2<<12|257, // 0x20E  124.5hz Appx. B2  Sin
	0<<14|2<<12|242, // 0x20F  132.2hz Appx. C3  Sin
	0<<14|2<<12|229, // 0x210  139.7hz Appx. C#3 Sin
	0<<14|2<<12|216, // 0x211  148.1hz Appx. D3  Sin
	0<<14|2<<12|204, // 0x212  156.9hz Appx. D#3 Sin
	0<<14|2<<12|192, // 0x213  166.7hz Appx. E3  Sin
	0<<14|2<<12|181, // 0x214  176.8hz Appx. F3  Sin
	0<<14|2<<12|171, // 0x215  187.1hz Appx. F#3 Sin
	0<<14|2<<12|162, // 0x216  197.5hz Appx. G3  Sin
	0<<14|2<<12|153, // 0x217  209.2hz Appx. G#3 Sin
	0<<14|2<<12|144, // 0x218  222.2hz Appx. A3  Sin
	0<<14|2<<12|136, // 0x219  235.3hz Appx. A#3 Sin
	0<<14|2<<12|129, // 0x21A  248.1hz Appx. B3  Sin
	0<<14|2<<12|121, // 0x21B  264.5hz Appx. C4  Sin
	0<<14|2<<12|114, // 0x21C  280.7hz Appx. C#4 Sin
	0<<14|2<<12|108, // 0x21D  296.3hz Appx. D4  Sin
	0<<14|2<<12|102, // 0x21E  313.7hz Appx. D#4 Sin
	0<<14|2<<12|96,  // 0x21F  333.3hz Appx. E4  Sin
	0<<14|2<<12|91,  // 0x220  351.6hz Appx. F4  Sin
	0<<14|2<<12|86,  // 0x221  372.1hz Appx. F#4 Sin
	0<<14|2<<12|81,  // 0x222  395.1hz Appx. G4  Sin
	0<<14|2<<12|76,  // 0x223  421.1hz Appx. G#4 Sin
	0<<14|2<<12|72,  // 0x224  444.4hz Appx. A4  Sin
	0<<14|2<<12|68,  // 0x225  470.6hz Appx. A#4 Sin
	0<<14|2<<12|64,  // 0x226  500.0hz Appx. B4  Sin
	0<<14|2<<12|61,  // 0x227  524.6hz Appx. C5  Sin
	0<<14|2<<12|57,  // 0x228  561.4hz Appx. C#5 Sin
	0<<14|2<<12|54,  // 0x229  592.6hz Appx. D5  Sin
	0<<14|2<<12|51,  // 0x22A  627.5hz Appx. D#5 Sin
	0<<14|2<<12|48,  // 0x22B  666.7hz Appx. E5  Sin
	0<<14|2<<12|46,  // 0x22C  695.7hz Appx. F5  Sin
	0<<14|2<<12|43,  // 0x22D  744.2hz Appx. F#5 Sin
	0<<14|2<<12|41,  // 0x22E  780.5hz Appx. G5  Sin
	0<<14|2<<12|38,  // 0x22F  842.1hz Appx. G#5 Sin
	0<<14|2<<12|36,  // 0x230  888.9hz Appx. A5  Sin
	0<<14|2<<12|34,  // 0x231  941.2hz Appx. A#5 Sin
	0<<14|2<<12|32,  // 0x232 1000.0hz Appx. B5  Sin
	0<<14|2<<12|30,  // 0x233 1066.7hz Appx. C6  Sin
	0<<14|2<<12|29,  // 0x234 1103.4hz Appx. C#6 Sin
	0<<14|2<<12|27,  // 0x235 1185.2hz Appx. D6  Sin
	0<<14|2<<12|26,  // 0x236 1230.8hz Appx. D#6 Sin
	0<<14|2<<12|24,  // 0x237 1333.3hz Appx. E6  Sin
	0<<14|2<<12|23,  // 0x238 1391.3hz Appx. F6  Sin
	0<<14|2<<12|22,  // 0x239 1454.5hz Appx. F#6 Sin
	0<<14|2<<12|20,  // 0x23A 1600.0hz Appx. G6  Sin
	0<<14|2<<12|19,  // 0x23B 1684.2hz Appx. G#6 Sin
	0<<14|2<<12|18,  // 0x23C 1777.8hz Appx. A6  Sin
	0<<14|2<<12|17,  // 0x23D 1882.4hz Appx. A#6 Sin
	0<<14|2<<12|16,  // 0x23E 2000.0hz Appx. B6  Sin
	0<<14|2<<12|15,  // 0x23F 2133.3hz Appx. C7  Sin

	1<<14|2<<12|581, // 0x240  55.08hz Appx. A1  Saw Tooth
	1<<14|2<<12|548, // 0x241  58.39hz Appx. A#1 Saw Tooth
	1<<14|2<<12|518, // 0x242  61.78hz Appx. B1  Saw Tooth
	1<<14|2<<12|489, // 0x243  65.44hz Appx. C2  Saw Tooth
	1<<14|2<<12|461, // 0x244  69.41hz Appx. C#2 Saw Tooth
	1<<14|2<<12|435, // 0x245  73.56hz Appx. D2  Saw Tooth
	1<<14|2<<12|411, // 0x246  77.86hz Appx. D#2 Saw Tooth
	1<<14|2<<12|388, // 0x247  82.47hz Appx. E2  Saw Tooth
	1<<14|2<<12|366, // 0x248  87.43hz Appx. F2  Saw Tooth
	1<<14|2<<12|345, // 0x249  92.75hz Appx. F#2 Saw Tooth
	1<<14|2<<12|326, // 0x24A  98.16hz Appx. G2  Saw Tooth
	1<<14|2<<12|308, // 0x24B  103.9hz Appx. G#2 Saw Tooth
	1<<14|2<<12|288, // 0x24C  111.1hz Appx. A2  Saw Tooth
	1<<14|2<<12|272, // 0x24D  117.6hz Appx. A#2 Saw Tooth
	1<<14|2<<12|257, // 0x24E  124.5hz Appx. B2  Saw Tooth
	1<<14|2<<12|242, // 0x24F  132.2hz Appx. C3  Saw Tooth
	1<<14|2<<12|229, // 0x250  139.7hz Appx. C#3 Saw Tooth
	1<<14|2<<12|216, // 0x251  148.1hz Appx. D3  Saw Tooth
	1<<14|2<<12|204, // 0x252  156.9hz Appx. D#3 Saw Tooth
	1<<14|2<<12|192, // 0x253  166.7hz Appx. E3  Saw Tooth
	1<<14|2<<12|181, // 0x254  176.8hz Appx. F3  Saw Tooth
	1<<14|2<<12|171, // 0x255  187.1hz Appx. F#3 Saw Tooth
	1<<14|2<<12|162, // 0x256  197.5hz Appx. G3  Saw Tooth
	1<<14|2<<12|153, // 0x257  209.2hz Appx. G#3 Saw Tooth
	1<<14|2<<12|144, // 0x258  222.2hz Appx. A3  Saw Tooth
	1<<14|2<<12|136, // 0x259  235.3hz Appx. A#3 Saw Tooth
	1<<14|2<<12|129, // 0x25A  248.1hz Appx. B3  Saw Tooth
	1<<14|2<<12|121, // 0x25B  264.5hz Appx. C4  Saw Tooth
	1<<14|2<<12|114, // 0x25C  280.7hz Appx. C#4 Saw Tooth
	1<<14|2<<12|108, // 0x25D  296.3hz Appx. D4  Saw Tooth
	1<<14|2<<12|102, // 0x25E  313.7hz Appx. D#4 Saw Tooth
	1<<14|2<<12|96,  // 0x25F  333.3hz Appx. E4  Saw Tooth
	1<<14|2<<12|91,  // 0x260  351.6hz Appx. F4  Saw Tooth
	1<<14|2<<12|86,  // 0x261  372.1hz Appx. F#4 Saw Tooth
	1<<14|2<<12|81,  // 0x262  395.1hz Appx. G4  Saw Tooth
	1<<14|2<<12|76,  // 0x263  421.1hz Appx. G#4 Saw Tooth
	1<<14|2<<12|72,  // 0x264  444.4hz Appx. A4  Saw Tooth
	1<<14|2<<12|68,  // 0x265  470.6hz Appx. A#4 Saw Tooth
	1<<14|2<<12|64,  // 0x266  500.0hz Appx. B4  Saw Tooth
	1<<14|2<<12|61,  // 0x267  524.6hz Appx. C5  Saw Tooth
	1<<14|2<<12|57,  // 0x268  561.4hz Appx. C#5 Saw Tooth
	1<<14|2<<12|54,  // 0x269  592.6hz Appx. D5  Saw Tooth
	1<<14|2<<12|51,  // 0x26A  627.5hz Appx. D#5 Saw Tooth
	1<<14|2<<12|48,  // 0x26B  666.7hz Appx. E5  Saw Tooth
	1<<14|2<<12|46,  // 0x26C  695.7hz Appx. F5  Saw Tooth
	1<<14|2<<12|43,  // 0x26D  744.2hz Appx. F#5 Saw Tooth
	1<<14|2<<12|41,  // 0x26E  780.5hz Appx. G5  Saw Tooth
	1<<14|2<<12|38,  // 0x26F  842.1hz Appx. G#5 Saw Tooth
	1<<14|2<<12|36,  // 0x270  888.9hz Appx. A5  Saw Tooth
	1<<14|2<<12|34,  // 0x271  941.2hz Appx. A#5 Saw Tooth
	1<<14|2<<12|32,  // 0x272 1000.0hz Appx. B5  Saw Tooth
	1<<14|2<<12|30,  // 0x273 1066.7hz Appx. C6  Saw Tooth
	1<<14|2<<12|29,  // 0x274 1103.4hz Appx. C#6 Saw Tooth
	1<<14|2<<12|27,  // 0x275 1185.2hz Appx. D6  Saw Tooth
	1<<14|2<<12|26,  // 0x276 1230.8hz Appx. D#6 Saw Tooth
	1<<14|2<<12|24,  // 0x277 1333.3hz Appx. E6  Saw Tooth
	1<<14|2<<12|23,  // 0x278 1391.3hz Appx. F6  Saw Tooth
	1<<14|2<<12|22,  // 0x279 1454.5hz Appx. F#6 Saw Tooth
	1<<14|2<<12|20,  // 0x27A 1600.0hz Appx. G6  Saw Tooth
	1<<14|2<<12|19,  // 0x27B 1684.2hz Appx. G#6 Saw Tooth
	1<<14|2<<12|18,  // 0x27C 1777.8hz Appx. A6  Saw Tooth
	1<<14|2<<12|17,  // 0x27D 1882.4hz Appx. A#6 Saw Tooth
	1<<14|2<<12|16,  // 0x27E 2000.0hz Appx. B6  Saw Tooth
	1<<14|2<<12|15,  // 0x27F 2133.3hz Appx. C7  Saw Tooth

	2<<14|2<<12|581, // 0x280  55.08hz Appx. A1  Square
	2<<14|2<<12|548, // 0x281  58.39hz Appx. A#1 Square
	2<<14|2<<12|518, // 0x282  61.78hz Appx. B1  Square
	2<<14|2<<12|489, // 0x283  65.44hz Appx. C2  Square
	2<<14|2<<12|461, // 0x284  69.41hz Appx. C#2 Square
	2<<14|2<<12|435, // 0x285  73.56hz Appx. D2  Square
	2<<14|2<<12|411, // 0x286  77.86hz Appx. D#2 Square
	2<<14|2<<12|388, // 0x287  82.47hz Appx. E2  Square
	2<<14|2<<12|366, // 0x288  87.43hz Appx. F2  Square
	2<<14|2<<12|345, // 0x289  92.75hz Appx. F#2 Square
	2<<14|2<<12|326, // 0x28A  98.16hz Appx. G2  Square
	2<<14|2<<12|308, // 0x28B  103.9hz Appx. G#2 Square
	2<<14|2<<12|288, // 0x28C  111.1hz Appx. A2  Square
	2<<14|2<<12|272, // 0x28D  117.6hz Appx. A#2 Square
	2<<14|2<<12|257, // 0x28E  124.5hz Appx. B2  Square
	2<<14|2<<12|242, // 0x28F  132.2hz Appx. C3  Square
	2<<14|2<<12|229, // 0x290  139.7hz Appx. C#3 Square
	2<<14|2<<12|216, // 0x291  148.1hz Appx. D3  Square
	2<<14|2<<12|204, // 0x292  156.9hz Appx. D#3 Square
	2<<14|2<<12|192, // 0x293  166.7hz Appx. E3  Square
	2<<14|2<<12|181, // 0x294  176.8hz Appx. F3  Square
	2<<14|2<<12|171, // 0x295  187.1hz Appx. F#3 Square
	2<<14|2<<12|162, // 0x296  197.5hz Appx. G3  Square
	2<<14|2<<12|153, // 0x297  209.2hz Appx. G#3 Square
	2<<14|2<<12|144, // 0x298  222.2hz Appx. A3  Square
	2<<14|2<<12|136, // 0x299  235.3hz Appx. A#3 Square
	2<<14|2<<12|129, // 0x29A  248.1hz Appx. B3  Square
	2<<14|2<<12|121, // 0x29B  264.5hz Appx. C4  Square
	2<<14|2<<12|114, // 0x29C  280.7hz Appx. C#4 Square
	2<<14|2<<12|108, // 0x29D  296.3hz Appx. D4  Square
	2<<14|2<<12|102, // 0x29E  313.7hz Appx. D#4 Square
	2<<14|2<<12|96,  // 0x29F  333.3hz Appx. E4  Square
	2<<14|2<<12|91,  // 0x2A0  351.6hz Appx. F4  Square
	2<<14|2<<12|86,  // 0x2A1  372.1hz Appx. F#4 Square
	2<<14|2<<12|81,  // 0x2A2  395.1hz Appx. G4  Square
	2<<14|2<<12|76,  // 0x2A3  421.1hz Appx. G#4 Square
	2<<14|2<<12|72,  // 0x2A4  444.4hz Appx. A4  Square
	2<<14|2<<12|68,  // 0x2A5  470.6hz Appx. A#4 Square
	2<<14|2<<12|64,  // 0x2A6  500.0hz Appx. B4  Square
	2<<14|2<<12|61,  // 0x2A7  524.6hz Appx. C5  Square
	2<<14|2<<12|57,  // 0x2A8  561.4hz Appx. C#5 Square
	2<<14|2<<12|54,  // 0x2A9  592.6hz Appx. D5  Square
	2<<14|2<<12|51,  // 0x2AA  627.5hz Appx. D#5 Square
	2<<14|2<<12|48,  // 0x2AB  666.7hz Appx. E5  Square
	2<<14|2<<12|46,  // 0x2AC  695.7hz Appx. F5  Square
	2<<14|2<<12|43,  // 0x2AD  744.2hz Appx. F#5 Square
	2<<14|2<<12|41,  // 0x2AE  780.5hz Appx. G5  Square
	2<<14|2<<12|38,  // 0x2AF  842.1hz Appx. G#5 Square
	2<<14|2<<12|36,  // 0x2B0  888.9hz Appx. A5  Square
	2<<14|2<<12|34,  // 0x2B1  941.2hz Appx. A#5 Square
	2<<14|2<<12|32,  // 0x2B2 1000.0hz Appx. B5  Square
	2<<14|2<<12|30,  // 0x2B3 1066.7hz Appx. C6  Square
	2<<14|2<<12|29,  // 0x2B4 1103.4hz Appx. C#6 Square
	2<<14|2<<12|27,  // 0x2B5 1185.2hz Appx. D6  Square
	2<<14|2<<12|26,  // 0x2B6 1230.8hz Appx. D#6 Square
	2<<14|2<<12|24,  // 0x2B7 1333.3hz Appx. E6  Square
	2<<14|2<<12|23,  // 0x2B8 1391.3hz Appx. F6  Square
	2<<14|2<<12|22,  // 0x2B9 1454.5hz Appx. F#6 Square
	2<<14|2<<12|20,  // 0x2BA 1600.0hz Appx. G6  Square
	2<<14|2<<12|19,  // 0x2BB 1684.2hz Appx. G#6 Square
	2<<14|2<<12|18,  // 0x2BC 1777.8hz Appx. A6  Square
	2<<14|2<<12|17,  // 0x2BD 1882.4hz Appx. A#6 Square
	2<<14|2<<12|16,  // 0x2BE 2000.0hz Appx. B6  Square
	2<<14|2<<12|15,  // 0x2BF 2133.3hz Appx. C7  Square

	/* Assume Fixed Length as 3960, Sample Rate 31680Hz Divided by 8 */
	3<<14|2<<12|440, // Noise Stride 440
	3<<14|2<<12|396, // Noise Stride 396
	3<<14|2<<12|330, // Noise Stride 330
	3<<14|2<<12|220, // Noise Stride 220
	3<<14|2<<12|165, // Noise Stride 165
	3<<14|2<<12|132, // Noise Stride 132
	3<<14|2<<12|120, // Noise Stride 120
	3<<14|2<<12|110, // Noise Stride 110
	3<<14|2<<12|99,  // Noise Stride 99
	3<<14|2<<12|90,  // Noise Stride 90
	3<<14|2<<12|88,  // Noise Stride 88
	3<<14|2<<12|72,  // Noise Stride 72
	3<<14|2<<12|66,  // Noise Stride 66
	3<<14|2<<12|60,  // Noise Stride 60
	3<<14|2<<12|55,  // Noise Stride 55
	3<<14|2<<12|45,  // Noise Stride 45
	3<<14|2<<12|44,  // Noise Stride 44
	3<<14|2<<12|40,  // Noise Stride 40
	3<<14|2<<12|36,  // Noise Stride 36
	3<<14|2<<12|30,  // Noise Stride 30
	3<<14|2<<12|24,  // Noise Stride 24
	3<<14|2<<12|22,  // Noise Stride 22
	3<<14|2<<12|20,  // Noise Stride 20
	3<<14|2<<12|18,  // Noise Stride 18
	3<<14|2<<12|15,  // Noise Stride 15
	3<<14|2<<12|12,  // Noise Stride 12
	3<<14|2<<12|10,  // Noise Stride 10
	3<<14|2<<12|9,   // Noise Stride 9
	3<<14|2<<12|8,   // Noise Stride 8
	3<<14|2<<12|6,   // Noise Stride 6
	3<<14|2<<12|5,   // Noise Stride 5
	3<<14|2<<12|4,   // Noise Stride 4
	_32(0<<14|2<<12|32)  // For Offset

	/* High Tones Big */

	2<<14|0<<12|14,  // 0x300 2285.7hz Appx. C#7 Square
	2<<14|0<<12|13,  // 0x301 2461.5hz Appx. D#7 Square
	2<<14|0<<12|12,  // 0x302 2666.6hz Appx. E7  Square
	2<<14|0<<12|11,  // 0x303 2909.1hz Appx. F7  Square
	2<<14|0<<12|10,  // 0x304 3200,0hz Appx. G7  Square
	2<<14|0<<12|9,   // 0x305 3555.6hz Appx. A7  Square
	2<<14|0<<12|8,   // 0x306 4000.0hz Appx. B7  Square
	2<<14|0<<12|7,   // 0x307 4571.4hz Appx. C#8 Square
	2<<14|0<<12|6,   // 0x308 5333.3hz Appx. E8  Square
	2<<14|0<<12|5,   // 0x309 6400.0hz Appx. G8  Square
	2<<14|0<<12|4,   // 0x30A 8000.0hz Appx. B8  Square
	2<<14|0<<12|3,   // 0x30B 10666.7hz Square

	/* High Tones Middle */

	2<<14|1<<12|14,  // 0x30C 2285.7hz Appx. C#7 Square
	2<<14|1<<12|13,  // 0x30D 2461.5hz Appx. D#7 Square
	2<<14|1<<12|12,  // 0x30E 2666.6hz Appx. E7  Square
	2<<14|1<<12|11,  // 0x30F 2909.1hz Appx. F7  Square
	2<<14|1<<12|10,  // 0x310 3200,0hz Appx. G7  Square
	2<<14|1<<12|9,   // 0x311 3555.6hz Appx. A7  Square
	2<<14|1<<12|8,   // 0x312 4000.0hz Appx. B7  Square
	2<<14|1<<12|7,   // 0x313 4571.4hz Appx. C#8 Square
	2<<14|1<<12|6,   // 0x314 5333.3hz Appx. E8  Square
	2<<14|1<<12|5,   // 0x315 6400.0hz Appx. G8  Square
	2<<14|1<<12|4,   // 0x316 8000.0hz Appx. B8  Square
	2<<14|1<<12|3,   // 0x317 10666.7hz Square

	/* High Tones Small */

	2<<14|2<<12|14,  // 0x318 2285.7hz Appx. C#7 Square
	2<<14|2<<12|13,  // 0x319 2461.5hz Appx. D#7 Square
	2<<14|2<<12|12,  // 0x31A 2666.6hz Appx. E7  Square
	2<<14|2<<12|11,  // 0x31B 2909.1hz Appx. F7  Square
	2<<14|2<<12|10,  // 0x31C 3200,0hz Appx. G7  Square
	2<<14|2<<12|9,   // 0x31D 3555.6hz Appx. A7  Square
	2<<14|2<<12|8,   // 0x31E 4000.0hz Appx. B7  Square
	2<<14|2<<12|7,   // 0x31F 4571.4hz Appx. C#8 Square
	2<<14|2<<12|6,   // 0x320 5333.3hz Appx. E8  Square
	2<<14|2<<12|5,   // 0x321 6400.0hz Appx. G8  Square
	2<<14|2<<12|4,   // 0x322 8000.0hz Appx. B8  Square
	2<<14|2<<12|3,   // 0x323 10666.7hz Square

	/* Special Sounds */

	2<<14|3<<12|36,  // 0x324 Silence
	2<<14|3<<12|36,  // 0x325 Silence

	0                // End of Index
};
 

#define _A1_SINL  0x00
#define _AS1_SINL 0x01
#define _B1_SINL  0x02
#define _C2_SINL  0x03
#define _CS2_SINL 0x04
#define _D2_SINL  0x05
#define _DS2_SINL 0x06
#define _E2_SINL  0x07
#define _F2_SINL  0x08
#define _FS2_SINL 0x09
#define _G2_SINL  0x0A
#define _GS2_SINL 0x0B
#define _A2_SINL  0x0C
#define _AS2_SINL 0x0D
#define _B2_SINL  0x0E
#define _C3_SINL  0x0F
#define _CS3_SINL 0x10
#define _D3_SINL  0x11
#define _DS3_SINL 0x12
#define _E3_SINL  0x13
#define _F3_SINL  0x14
#define _FS3_SINL 0x15
#define _G3_SINL  0x16
#define _GS3_SINL 0x17
#define _A3_SINL  0x18
#define _AS3_SINL 0x19
#define _B3_SINL  0x1A
#define _C4_SINL  0x1B
#define _CS4_SINL 0x1C
#define _D4_SINL  0x1D
#define _DS4_SINL 0x1E
#define _E4_SINL  0x1F
#define _F4_SINL  0x20
#define _FS4_SINL 0x21
#define _G4_SINL  0x22
#define _GS4_SINL 0x23
#define _A4_SINL  0x24
#define _AS4_SINL 0x25
#define _B4_SINL  0x26
#define _C5_SINL  0x27
#define _CS5_SINL 0x28
#define _D5_SINL  0x29
#define _DS5_SINL 0x2A
#define _E5_SINL  0x2B
#define _F5_SINL  0x2C
#define _FS5_SINL 0x2D
#define _G5_SINL  0x2E
#define _GS5_SINL 0x2F
#define _A5_SINL  0x30
#define _AS5_SINL 0x31
#define _B5_SINL  0x32
#define _C6_SINL  0x33
#define _CS6_SINL 0x34
#define _D6_SINL  0x35
#define _DS6_SINL 0x36
#define _E6_SINL  0x37
#define _F6_SINL  0x38
#define _FS6_SINL 0x39
#define _G6_SINL  0x3A
#define _GS6_SINL 0x3B
#define _A6_SINL  0x3C
#define _AS6_SINL 0x3D
#define _B6_SINL  0x3E
#define _C7_SINL  0x3F

#define _A1_TRIL  0x40
#define _AS1_TRIL 0x41
#define _B1_TRIL  0x42
#define _C2_TRIL  0x43
#define _CS2_TRIL 0x44
#define _D2_TRIL  0x45
#define _DS2_TRIL 0x46
#define _E2_TRIL  0x47
#define _F2_TRIL  0x48
#define _FS2_TRIL 0x49
#define _G2_TRIL  0x4A
#define _GS2_TRIL 0x4B
#define _A2_TRIL  0x4C
#define _AS2_TRIL 0x4D
#define _B2_TRIL  0x4E
#define _C3_TRIL  0x4F
#define _CS3_TRIL 0x50
#define _D3_TRIL  0x51
#define _DS3_TRIL 0x52
#define _E3_TRIL  0x53
#define _F3_TRIL  0x54
#define _FS3_TRIL 0x55
#define _G3_TRIL  0x56
#define _GS3_TRIL 0x57
#define _A3_TRIL  0x58
#define _AS3_TRIL 0x59
#define _B3_TRIL  0x5A
#define _C4_TRIL  0x5B
#define _CS4_TRIL 0x5C
#define _D4_TRIL  0x5D
#define _DS4_TRIL 0x5E
#define _E4_TRIL  0x5F
#define _F4_TRIL  0x60
#define _FS4_TRIL 0x61
#define _G4_TRIL  0x62
#define _GS4_TRIL 0x63
#define _A4_TRIL  0x64
#define _AS4_TRIL 0x65
#define _B4_TRIL  0x66
#define _C5_TRIL  0x67
#define _CS5_TRIL 0x68
#define _D5_TRIL  0x69
#define _DS5_TRIL 0x6A
#define _E5_TRIL  0x6B
#define _F5_TRIL  0x6C
#define _FS5_TRIL 0x6D
#define _G5_TRIL  0x6E
#define _GS5_TRIL 0x6F
#define _A5_TRIL  0x70
#define _AS5_TRIL 0x71
#define _B5_TRIL  0x72
#define _C6_TRIL  0x73
#define _CS6_TRIL 0x74
#define _D6_TRIL  0x75
#define _DS6_TRIL 0x76
#define _E6_TRIL  0x77
#define _F6_TRIL  0x78
#define _FS6_TRIL 0x79
#define _G6_TRIL  0x7A
#define _GS6_TRIL 0x7B
#define _A6_TRIL  0x7C
#define _AS6_TRIL 0x7D
#define _B6_TRIL  0x7E
#define _C7_TRIL  0x7F

#define _A1_SQUL  0x80
#define _AS1_SQUL 0x81
#define _B1_SQUL  0x82
#define _C2_SQUL  0x83
#define _CS2_SQUL 0x84
#define _D2_SQUL  0x85
#define _DS2_SQUL 0x86
#define _E2_SQUL  0x87
#define _F2_SQUL  0x88
#define _FS2_SQUL 0x89
#define _G2_SQUL  0x8A
#define _GS2_SQUL 0x8B
#define _A2_SQUL  0x8C
#define _AS2_SQUL 0x8D
#define _B2_SQUL  0x8E
#define _C3_SQUL  0x8F
#define _CS3_SQUL 0x90
#define _D3_SQUL  0x91
#define _DS3_SQUL 0x92
#define _E3_SQUL  0x93
#define _F3_SQUL  0x94
#define _FS3_SQUL 0x95
#define _G3_SQUL  0x96
#define _GS3_SQUL 0x97
#define _A3_SQUL  0x98
#define _AS3_SQUL 0x99
#define _B3_SQUL  0x9A
#define _C4_SQUL  0x9B
#define _CS4_SQUL 0x9C
#define _D4_SQUL  0x9D
#define _DS4_SQUL 0x9E
#define _E4_SQUL  0x9F
#define _F4_SQUL  0xA0
#define _FS4_SQUL 0xA1
#define _G4_SQUL  0xA2
#define _GS4_SQUL 0xA3
#define _A4_SQUL  0xA4
#define _AS4_SQUL 0xA5
#define _B4_SQUL  0xA6
#define _C5_SQUL  0xA7
#define _CS5_SQUL 0xA8
#define _D5_SQUL  0xA9
#define _DS5_SQUL 0xAA
#define _E5_SQUL  0xAB
#define _F5_SQUL  0xAC
#define _FS5_SQUL 0xAD
#define _G5_SQUL  0xAE
#define _GS5_SQUL 0xAF
#define _A5_SQUL  0xB0
#define _AS5_SQUL 0xB1
#define _B5_SQUL  0xB2
#define _C6_SQUL  0xB3
#define _CS6_SQUL 0xB4
#define _D6_SQUL  0xB5
#define _DS6_SQUL 0xB6
#define _E6_SQUL  0xB7
#define _F6_SQUL  0xB8
#define _FS6_SQUL 0xB9
#define _G6_SQUL  0xBA
#define _GS6_SQUL 0xBB
#define _A6_SQUL  0xBC
#define _AS6_SQUL 0xBD
#define _B6_SQUL  0xBE
#define _C7_SQUL  0xBF

#define _1_NOIL   0xC0
#define _2_NOIL   0xC1
#define _3_NOIL   0xC2
#define _4_NOIL   0xC3
#define _5_NOIL   0xC4
#define _6_NOIL   0xC5
#define _7_NOIL   0xC6
#define _8_NOIL   0xC7
#define _9_NOIL   0xC8
#define _10_NOIL  0xC9
#define _11_NOIL  0xCA
#define _12_NOIL  0xCB
#define _13_NOIL  0xCC
#define _14_NOIL  0xCD
#define _15_NOIL  0xCE
#define _16_NOIL  0xCF
#define _17_NOIL  0xD0
#define _18_NOIL  0xD1
#define _19_NOIL  0xD2
#define _20_NOIL  0xD3
#define _21_NOIL  0xD4
#define _22_NOIL  0xD5
#define _23_NOIL  0xD6
#define _24_NOIL  0xD7
#define _25_NOIL  0xD8
#define _26_NOIL  0xD9
#define _27_NOIL  0xDA
#define _28_NOIL  0xDB
#define _29_NOIL  0xDC
#define _30_NOIL  0xDD
#define _31_NOIL  0xDE
#define _32_NOIL  0xDF

#define _A1_SINM  0x100
#define _AS1_SINM 0x101
#define _B1_SINM  0x102
#define _C2_SINM  0x103
#define _CS2_SINM 0x104
#define _D2_SINM  0x105
#define _DS2_SINM 0x106
#define _E2_SINM  0x107
#define _F2_SINM  0x108
#define _FS2_SINM 0x109
#define _G2_SINM  0x10A
#define _GS2_SINM 0x10B
#define _A2_SINM  0x10C
#define _AS2_SINM 0x10D
#define _B2_SINM  0x10E
#define _C3_SINM  0x10F
#define _CS3_SINM 0x110
#define _D3_SINM  0x111
#define _DS3_SINM 0x112
#define _E3_SINM  0x113
#define _F3_SINM  0x114
#define _FS3_SINM 0x115
#define _G3_SINM  0x116
#define _GS3_SINM 0x117
#define _A3_SINM  0x118
#define _AS3_SINM 0x119
#define _B3_SINM  0x11A
#define _C4_SINM  0x11B
#define _CS4_SINM 0x11C
#define _D4_SINM  0x11D
#define _DS4_SINM 0x11E
#define _E4_SINM  0x11F
#define _F4_SINM  0x120
#define _FS4_SINM 0x121
#define _G4_SINM  0x122
#define _GS4_SINM 0x123
#define _A4_SINM  0x124
#define _AS4_SINM 0x125
#define _B4_SINM  0x126
#define _C5_SINM  0x127
#define _CS5_SINM 0x128
#define _D5_SINM  0x129
#define _DS5_SINM 0x12A
#define _E5_SINM  0x12B
#define _F5_SINM  0x12C
#define _FS5_SINM 0x12D
#define _G5_SINM  0x12E
#define _GS5_SINM 0x12F
#define _A5_SINM  0x130
#define _AS5_SINM 0x131
#define _B5_SINM  0x132
#define _C6_SINM  0x133
#define _CS6_SINM 0x134
#define _D6_SINM  0x135
#define _DS6_SINM 0x136
#define _E6_SINM  0x137
#define _F6_SINM  0x138
#define _FS6_SINM 0x139
#define _G6_SINM  0x13A
#define _GS6_SINM 0x13B
#define _A6_SINM  0x13C
#define _AS6_SINM 0x13D
#define _B6_SINM  0x13E
#define _C7_SINM  0x13F

#define _A1_TRIM  0x140
#define _AS1_TRIM 0x141
#define _B1_TRIM  0x142
#define _C2_TRIM  0x143
#define _CS2_TRIM 0x144
#define _D2_TRIM  0x145
#define _DS2_TRIM 0x146
#define _E2_TRIM  0x147
#define _F2_TRIM  0x148
#define _FS2_TRIM 0x149
#define _G2_TRIM  0x14A
#define _GS2_TRIM 0x14B
#define _A2_TRIM  0x14C
#define _AS2_TRIM 0x14D
#define _B2_TRIM  0x14E
#define _C3_TRIM  0x14F
#define _CS3_TRIM 0x150
#define _D3_TRIM  0x151
#define _DS3_TRIM 0x152
#define _E3_TRIM  0x153
#define _F3_TRIM  0x154
#define _FS3_TRIM 0x155
#define _G3_TRIM  0x156
#define _GS3_TRIM 0x157
#define _A3_TRIM  0x158
#define _AS3_TRIM 0x159
#define _B3_TRIM  0x15A
#define _C4_TRIM  0x15B
#define _CS4_TRIM 0x15C
#define _D4_TRIM  0x15D
#define _DS4_TRIM 0x15E
#define _E4_TRIM  0x15F
#define _F4_TRIM  0x160
#define _FS4_TRIM 0x161
#define _G4_TRIM  0x162
#define _GS4_TRIM 0x163
#define _A4_TRIM  0x164
#define _AS4_TRIM 0x165
#define _B4_TRIM  0x166
#define _C5_TRIM  0x167
#define _CS5_TRIM 0x168
#define _D5_TRIM  0x169
#define _DS5_TRIM 0x16A
#define _E5_TRIM  0x16B
#define _F5_TRIM  0x16C
#define _FS5_TRIM 0x16D
#define _G5_TRIM  0x16E
#define _GS5_TRIM 0x16F
#define _A5_TRIM  0x170
#define _AS5_TRIM 0x171
#define _B5_TRIM  0x172
#define _C6_TRIM  0x173
#define _CS6_TRIM 0x174
#define _D6_TRIM  0x175
#define _DS6_TRIM 0x176
#define _E6_TRIM  0x177
#define _F6_TRIM  0x178
#define _FS6_TRIM 0x179
#define _G6_TRIM  0x17A
#define _GS6_TRIM 0x17B
#define _A6_TRIM  0x17C
#define _AS6_TRIM 0x17D
#define _B6_TRIM  0x17E
#define _C7_TRIM  0x17F

#define _A1_SQUM  0x180
#define _AS1_SQUM 0x181
#define _B1_SQUM  0x182
#define _C2_SQUM  0x183
#define _CS2_SQUM 0x184
#define _D2_SQUM  0x185
#define _DS2_SQUM 0x186
#define _E2_SQUM  0x187
#define _F2_SQUM  0x188
#define _FS2_SQUM 0x189
#define _G2_SQUM  0x18A
#define _GS2_SQUM 0x18B
#define _A2_SQUM  0x18C
#define _AS2_SQUM 0x18D
#define _B2_SQUM  0x18E
#define _C3_SQUM  0x18F
#define _CS3_SQUM 0x190
#define _D3_SQUM  0x191
#define _DS3_SQUM 0x192
#define _E3_SQUM  0x193
#define _F3_SQUM  0x194
#define _FS3_SQUM 0x195
#define _G3_SQUM  0x196
#define _GS3_SQUM 0x197
#define _A3_SQUM  0x198
#define _AS3_SQUM 0x199
#define _B3_SQUM  0x19A
#define _C4_SQUM  0x19B
#define _CS4_SQUM 0x19C
#define _D4_SQUM  0x19D
#define _DS4_SQUM 0x19E
#define _E4_SQUM  0x19F
#define _F4_SQUM  0x1A0
#define _FS4_SQUM 0x1A1
#define _G4_SQUM  0x1A2
#define _GS4_SQUM 0x1A3
#define _A4_SQUM  0x1A4
#define _AS4_SQUM 0x1A5
#define _B4_SQUM  0x1A6
#define _C5_SQUM  0x1A7
#define _CS5_SQUM 0x1A8
#define _D5_SQUM  0x1A9
#define _DS5_SQUM 0x1AA
#define _E5_SQUM  0x1AB
#define _F5_SQUM  0x1AC
#define _FS5_SQUM 0x1AD
#define _G5_SQUM  0x1AE
#define _GS5_SQUM 0x1AF
#define _A5_SQUM  0x1B0
#define _AS5_SQUM 0x1B1
#define _B5_SQUM  0x1B2
#define _C6_SQUM  0x1B3
#define _CS6_SQUM 0x1B4
#define _D6_SQUM  0x1B5
#define _DS6_SQUM 0x1B6
#define _E6_SQUM  0x1B7
#define _F6_SQUM  0x1B8
#define _FS6_SQUM 0x1B9
#define _G6_SQUM  0x1BA
#define _GS6_SQUM 0x1BB
#define _A6_SQUM  0x1BC
#define _AS6_SQUM 0x1BD
#define _B6_SQUM  0x1BE
#define _C7_SQUM  0x1BF

#define _1_NOIM   0x1C0
#define _2_NOIM   0x1C1
#define _3_NOIM   0x1C2
#define _4_NOIM   0x1C3
#define _5_NOIM   0x1C4
#define _6_NOIM   0x1C5
#define _7_NOIM   0x1C6
#define _8_NOIM   0x1C7
#define _9_NOIM   0x1C8
#define _10_NOIM  0x1C9
#define _11_NOIM  0x1CA
#define _12_NOIM  0x1CB
#define _13_NOIM  0x1CC
#define _14_NOIM  0x1CD
#define _15_NOIM  0x1CE
#define _16_NOIM  0x1CF
#define _17_NOIM  0x1D0
#define _18_NOIM  0x1D1
#define _19_NOIM  0x1D2
#define _20_NOIM  0x1D3
#define _21_NOIM  0x1D4
#define _22_NOIM  0x1D5
#define _23_NOIM  0x1D6
#define _24_NOIM  0x1D7
#define _25_NOIM  0x1D8
#define _26_NOIM  0x1D9
#define _27_NOIM  0x1DA
#define _28_NOIM  0x1DB
#define _29_NOIM  0x1DC
#define _30_NOIM  0x1DD
#define _31_NOIM  0x1DE
#define _32_NOIM  0x1DF

#define _A1_SINS  0x200
#define _AS1_SINS 0x201
#define _B1_SINS  0x202
#define _C2_SINS  0x203
#define _CS2_SINS 0x204
#define _D2_SINS  0x205
#define _DS2_SINS 0x206
#define _E2_SINS  0x207
#define _F2_SINS  0x208
#define _FS2_SINS 0x209
#define _G2_SINS  0x20A
#define _GS2_SINS 0x20B
#define _A2_SINS  0x20C
#define _AS2_SINS 0x20D
#define _B2_SINS  0x20E
#define _C3_SINS  0x20F
#define _CS3_SINS 0x210
#define _D3_SINS  0x211
#define _DS3_SINS 0x212
#define _E3_SINS  0x213
#define _F3_SINS  0x214
#define _FS3_SINS 0x215
#define _G3_SINS  0x216
#define _GS3_SINS 0x217
#define _A3_SINS  0x218
#define _AS3_SINS 0x219
#define _B3_SINS  0x21A
#define _C4_SINS  0x21B
#define _CS4_SINS 0x21C
#define _D4_SINS  0x21D
#define _DS4_SINS 0x21E
#define _E4_SINS  0x21F
#define _F4_SINS  0x220
#define _FS4_SINS 0x221
#define _G4_SINS  0x222
#define _GS4_SINS 0x223
#define _A4_SINS  0x224
#define _AS4_SINS 0x225
#define _B4_SINS  0x226
#define _C5_SINS  0x227
#define _CS5_SINS 0x228
#define _D5_SINS  0x229
#define _DS5_SINS 0x22A
#define _E5_SINS  0x22B
#define _F5_SINS  0x22C
#define _FS5_SINS 0x22D
#define _G5_SINS  0x22E
#define _GS5_SINS 0x22F
#define _A5_SINS  0x230
#define _AS5_SINS 0x231
#define _B5_SINS  0x232
#define _C6_SINS  0x233
#define _CS6_SINS 0x234
#define _D6_SINS  0x235
#define _DS6_SINS 0x236
#define _E6_SINS  0x237
#define _F6_SINS  0x238
#define _FS6_SINS 0x239
#define _G6_SINS  0x23A
#define _GS6_SINS 0x23B
#define _A6_SINS  0x23C
#define _AS6_SINS 0x23D
#define _B6_SINS  0x23E
#define _C7_SINS  0x23F

#define _A1_TRIS  0x240
#define _AS1_TRIS 0x241
#define _B1_TRIS  0x242
#define _C2_TRIS  0x243
#define _CS2_TRIS 0x244
#define _D2_TRIS  0x245
#define _DS2_TRIS 0x246
#define _E2_TRIS  0x247
#define _F2_TRIS  0x248
#define _FS2_TRIS 0x249
#define _G2_TRIS  0x24A
#define _GS2_TRIS 0x24B
#define _A2_TRIS  0x24C
#define _AS2_TRIS 0x24D
#define _B2_TRIS  0x24E
#define _C3_TRIS  0x24F
#define _CS3_TRIS 0x250
#define _D3_TRIS  0x251
#define _DS3_TRIS 0x252
#define _E3_TRIS  0x253
#define _F3_TRIS  0x254
#define _FS3_TRIS 0x255
#define _G3_TRIS  0x256
#define _GS3_TRIS 0x257
#define _A3_TRIS  0x258
#define _AS3_TRIS 0x259
#define _B3_TRIS  0x25A
#define _C4_TRIS  0x25B
#define _CS4_TRIS 0x25C
#define _D4_TRIS  0x25D
#define _DS4_TRIS 0x25E
#define _E4_TRIS  0x25F
#define _F4_TRIS  0x260
#define _FS4_TRIS 0x261
#define _G4_TRIS  0x262
#define _GS4_TRIS 0x263
#define _A4_TRIS  0x264
#define _AS4_TRIS 0x265
#define _B4_TRIS  0x266
#define _C5_TRIS  0x267
#define _CS5_TRIS 0x268
#define _D5_TRIS  0x269
#define _DS5_TRIS 0x26A
#define _E5_TRIS  0x26B
#define _F5_TRIS  0x26C
#define _FS5_TRIS 0x26D
#define _G5_TRIS  0x26E
#define _GS5_TRIS 0x26F
#define _A5_TRIS  0x270
#define _AS5_TRIS 0x271
#define _B5_TRIS  0x272
#define _C6_TRIS  0x273
#define _CS6_TRIS 0x274
#define _D6_TRIS  0x275
#define _DS6_TRIS 0x276
#define _E6_TRIS  0x277
#define _F6_TRIS  0x278
#define _FS6_TRIS 0x279
#define _G6_TRIS  0x27A
#define _GS6_TRIS 0x27B
#define _A6_TRIS  0x27C
#define _AS6_TRIS 0x27D
#define _B6_TRIS  0x27E
#define _C7_TRIS  0x27F

#define _A1_SQUS  0x280
#define _AS1_SQUS 0x281
#define _B1_SQUS  0x282
#define _C2_SQUS  0x283
#define _CS2_SQUS 0x284
#define _D2_SQUS  0x285
#define _DS2_SQUS 0x286
#define _E2_SQUS  0x287
#define _F2_SQUS  0x288
#define _FS2_SQUS 0x289
#define _G2_SQUS  0x28A
#define _GS2_SQUS 0x28B
#define _A2_SQUS  0x28C
#define _AS2_SQUS 0x28D
#define _B2_SQUS  0x28E
#define _C3_SQUS  0x28F
#define _CS3_SQUS 0x290
#define _D3_SQUS  0x291
#define _DS3_SQUS 0x292
#define _E3_SQUS  0x293
#define _F3_SQUS  0x294
#define _FS3_SQUS 0x295
#define _G3_SQUS  0x296
#define _GS3_SQUS 0x297
#define _A3_SQUS  0x298
#define _AS3_SQUS 0x299
#define _B3_SQUS  0x29A
#define _C4_SQUS  0x29B
#define _CS4_SQUS 0x29C
#define _D4_SQUS  0x29D
#define _DS4_SQUS 0x29E
#define _E4_SQUS  0x29F
#define _F4_SQUS  0x2A0
#define _FS4_SQUS 0x2A1
#define _G4_SQUS  0x2A2
#define _GS4_SQUS 0x2A3
#define _A4_SQUS  0x2A4
#define _AS4_SQUS 0x2A5
#define _B4_SQUS  0x2A6
#define _C5_SQUS  0x2A7
#define _CS5_SQUS 0x2A8
#define _D5_SQUS  0x2A9
#define _DS5_SQUS 0x2AA
#define _E5_SQUS  0x2AB
#define _F5_SQUS  0x2AC
#define _FS5_SQUS 0x2AD
#define _G5_SQUS  0x2AE
#define _GS5_SQUS 0x2AF
#define _A5_SQUS  0x2B0
#define _AS5_SQUS 0x2B1
#define _B5_SQUS  0x2B2
#define _C6_SQUS  0x2B3
#define _CS6_SQUS 0x2B4
#define _D6_SQUS  0x2B5
#define _DS6_SQUS 0x2B6
#define _E6_SQUS  0x2B7
#define _F6_SQUS  0x2B8
#define _FS6_SQUS 0x2B9
#define _G6_SQUS  0x2BA
#define _GS6_SQUS 0x2BB
#define _A6_SQUS  0x2BC
#define _AS6_SQUS 0x2BD
#define _B6_SQUS  0x2BE
#define _C7_SQUS  0x2BF

#define _1_NOIS   0x2C0
#define _2_NOIS   0x2C1
#define _3_NOIS   0x2C2
#define _4_NOIS   0x2C3
#define _5_NOIS   0x2C4
#define _6_NOIS   0x2C5
#define _7_NOIS   0x2C6
#define _8_NOIS   0x2C7
#define _9_NOIS   0x2C8
#define _10_NOIS  0x2C9
#define _11_NOIS  0x2CA
#define _12_NOIS  0x2CB
#define _13_NOIS  0x2CC
#define _14_NOIS  0x2CD
#define _15_NOIS  0x2CE
#define _16_NOIS  0x2CF
#define _17_NOIS  0x2D0
#define _18_NOIS  0x2D1
#define _19_NOIS  0x2D2
#define _20_NOIS  0x2D3
#define _21_NOIS  0x2D4
#define _22_NOIS  0x2D5
#define _23_NOIS  0x2D6
#define _24_NOIS  0x2D7
#define _25_NOIS  0x2D8
#define _26_NOIS  0x2D9
#define _27_NOIS  0x2DA
#define _28_NOIS  0x2DB
#define _29_NOIS  0x2DC
#define _30_NOIS  0x2DD
#define _31_NOIS  0x2DE
#define _32_NOIS  0x2DF

#define _CS7_SQUL 0x300
#define _DS7_SQUL 0x301
#define _E7_SQUL  0x302
#define _F7_SQUL  0x303
#define _G7_SQUL  0x304
#define _A7_SQUL  0x305
#define _B7_SQUL  0x306
#define _CS8_SQUL 0x307
#define _E8_SQUL  0x308
#define _G8_SQUL  0x309
#define _B8_SQUL  0x30A
#define _HI_SQUL  0x30B

#define _CS7_SQUM 0x30C
#define _DS7_SQUM 0x30D
#define _E7_SQUM  0x30E
#define _F7_SQUM  0x30F
#define _G7_SQUM  0x310
#define _A7_SQUM  0x311
#define _B7_SQUM  0x312
#define _CS8_SQUM 0x313
#define _E8_SQUM  0x314
#define _G8_SQUM  0x315
#define _B8_SQUM  0x316
#define _HI_SQUM  0x317

#define _CS7_SQUS 0x318
#define _DS7_SQUS 0x319
#define _E7_SQUS  0x31A
#define _F7_SQUS  0x31B
#define _G7_SQUS  0x31C
#define _A7_SQUS  0x31D
#define _B7_SQUS  0x31E
#define _CS8_SQUS 0x31F
#define _E8_SQUS  0x320
#define _G8_SQUS  0x321
#define _B8_SQUS  0x322
#define _HI_SQUS  0x323

#define _SILENCE  0x324
#define _END      0xFFFF

/* Chords */

/* Major */
#define _3_MAJ(x)       x,x+4,x+7,
#define _6_MAJ(x)       _3_MAJ(x) _3_MAJ(x)
#define _9_MAJ(x)       _6_MAJ(x) _3_MAJ(x)
#define _12_MAJ(x)      _9_MAJ(x) _3_MAJ(x)
#define _15_MAJ(x)      _12_MAJ(x) _3_MAJ(x)
#define _18_MAJ(x)      _15_MAJ(x) _3_MAJ(x)
#define _21_MAJ(x)      _18_MAJ(x) _3_MAJ(x)
#define _24_MAJ(x)      _21_MAJ(x) _3_MAJ(x)
#define _27_MAJ(x)      _24_MAJ(x) _3_MAJ(x)
#define _30_MAJ(x)      _27_MAJ(x) _3_MAJ(x)
#define _33_MAJ(x)      _30_MAJ(x) _3_MAJ(x)
#define _36_MAJ(x)      _33_MAJ(x) _3_MAJ(x)
#define _39_MAJ(x)      _36_MAJ(x) _3_MAJ(x)
#define _42_MAJ(x)      _39_MAJ(x) _3_MAJ(x)
#define _45_MAJ(x)      _42_MAJ(x) _3_MAJ(x)
#define _48_MAJ(x)      _45_MAJ(x) _3_MAJ(x)

/* Minor */
#define _3_M(x)         x,x+3,x+7,
#define _6_M(x)         _3_M(x) _3_M(x)
#define _9_M(x)         _6_M(x) _3_M(x)
#define _12_M(x)        _9_M(x) _3_M(x)
#define _15_M(x)        _12_M(x) _3_M(x)
#define _18_M(x)        _15_M(x) _3_M(x)
#define _21_M(x)        _18_M(x) _3_M(x)
#define _24_M(x)        _21_M(x) _3_M(x)
#define _27_M(x)        _24_M(x) _3_M(x)
#define _30_M(x)        _27_M(x) _3_M(x)
#define _33_M(x)        _30_M(x) _3_M(x)
#define _36_M(x)        _33_M(x) _3_M(x)
#define _39_M(x)        _36_M(x) _3_M(x)
#define _42_M(x)        _39_M(x) _3_M(x)
#define _45_M(x)        _42_M(x) _3_M(x)
#define _48_M(x)        _45_M(x) _3_M(x)

/* Major 7th */
#define _4_MAJ7TH(x)    x,x+4,x+7,x+11,
#define _8_MAJ7TH(x)    _4_MAJ7TH(x) _4_MAJ7TH(x)
#define _12_MAJ7TH(x)   _8_MAJ7TH(x) _4_MAJ7TH(x)
#define _16_MAJ7TH(x)   _12_MAJ7TH(x) _4_MAJ7TH(x)
#define _20_MAJ7TH(x)   _16_MAJ7TH(x) _4_MAJ7TH(x)
#define _24_MAJ7TH(x)   _20_MAJ7TH(x) _4_MAJ7TH(x)
#define _28_MAJ7TH(x)   _24_MAJ7TH(x) _4_MAJ7TH(x)
#define _32_MAJ7TH(x)   _28_MAJ7TH(x) _4_MAJ7TH(x)
#define _36_MAJ7TH(x)   _32_MAJ7TH(x) _4_MAJ7TH(x)
#define _40_MAJ7TH(x)   _36_MAJ7TH(x) _4_MAJ7TH(x)
#define _44_MAJ7TH(x)   _40_MAJ7TH(x) _4_MAJ7TH(x)
#define _48_MAJ7TH(x)   _44_MAJ7TH(x) _4_MAJ7TH(x)

/* Minor Major 7th */
#define _4_MMAJ7TH(x)   x,x+3,x+7,x+11,
#define _8_MMAJ7TH(x)   _4_MMAJ7TH(x) _4_MMAJ7TH(x)
#define _12_MMAJ7TH(x)  _8_MMAJ7TH(x) _4_MMAJ7TH(x)
#define _16_MMAJ7TH(x)  _12_MMAJ7TH(x) _4_MMAJ7TH(x)
#define _20_MMAJ7TH(x)  _16_MMAJ7TH(x) _4_MMAJ7TH(x)
#define _24_MMAJ7TH(x)  _20_MMAJ7TH(x) _4_MMAJ7TH(x)
#define _28_MMAJ7TH(x)  _24_MMAJ7TH(x) _4_MMAJ7TH(x)
#define _32_MMAJ7TH(x)  _28_MMAJ7TH(x) _4_MMAJ7TH(x)
#define _36_MMAJ7TH(x)  _32_MMAJ7TH(x) _4_MMAJ7TH(x)
#define _40_MMAJ7TH(x)  _36_MMAJ7TH(x) _4_MMAJ7TH(x)
#define _44_MMAJ7TH(x)  _40_MMAJ7TH(x) _4_MMAJ7TH(x)
#define _48_MMAJ7TH(x)  _44_MMAJ7TH(x) _4_MMAJ7TH(x)

/* 7th */
#define _4_7TH(x)       x,x+4,x+7,x+10,
#define _8_7TH(x)       _4_7TH(x) _4_7TH(x)
#define _12_7TH(x)      _8_7TH(x) _4_7TH(x)
#define _16_7TH(x)      _12_7TH(x) _4_7TH(x)
#define _20_7TH(x)      _16_7TH(x) _4_7TH(x)
#define _24_7TH(x)      _20_7TH(x) _4_7TH(x)
#define _28_7TH(x)      _24_7TH(x) _4_7TH(x)
#define _32_7TH(x)      _28_7TH(x) _4_7TH(x)
#define _36_7TH(x)      _32_7TH(x) _4_7TH(x)
#define _40_7TH(x)      _36_7TH(x) _4_7TH(x)
#define _44_7TH(x)      _40_7TH(x) _4_7TH(x)
#define _48_7TH(x)      _44_7TH(x) _4_7TH(x)

/* Minor 7th */
#define _4_M7TH(x)      x,x+3,x+7,x+10,
#define _8_M7TH(x)      _4_M7TH(x) _4_M7TH(x)
#define _12_M7TH(x)     _8_M7TH(x) _4_M7TH(x)
#define _16_M7TH(x)     _12_M7TH(x) _4_M7TH(x)
#define _20_M7TH(x)     _16_M7TH(x) _4_M7TH(x)
#define _24_M7TH(x)     _20_M7TH(x) _4_M7TH(x)
#define _28_M7TH(x)     _24_M7TH(x) _4_M7TH(x)
#define _32_M7TH(x)     _28_M7TH(x) _4_M7TH(x)
#define _36_M7TH(x)     _32_M7TH(x) _4_M7TH(x)
#define _40_M7TH(x)     _36_M7TH(x) _4_M7TH(x)
#define _44_M7TH(x)     _40_M7TH(x) _4_M7TH(x)
#define _48_M7TH(x)     _44_M7TH(x) _4_M7TH(x)

/* Add 9th */
#define _4_ADD9TH(x)    x,x+4,x+7,x+14,
#define _8_ADD9TH(x)    _4_ADD9TH(x) _4_ADD9TH(x)
#define _12_ADD9TH(x)   _8_ADD9TH(x) _4_ADD9TH(x)
#define _16_ADD9TH(x)   _12_ADD9TH(x) _4_ADD9TH(x)
#define _20_ADD9TH(x)   _16_ADD9TH(x) _4_ADD9TH(x)
#define _24_ADD9TH(x)   _20_ADD9TH(x) _4_ADD9TH(x)
#define _28_ADD9TH(x)   _24_ADD9TH(x) _4_ADD9TH(x)
#define _32_ADD9TH(x)   _28_ADD9TH(x) _4_ADD9TH(x)
#define _36_ADD9TH(x)   _32_ADD9TH(x) _4_ADD9TH(x)
#define _40_ADD9TH(x)   _36_ADD9TH(x) _4_ADD9TH(x)
#define _44_ADD9TH(x)   _40_ADD9TH(x) _4_ADD9TH(x)
#define _48_ADD9TH(x)   _44_ADD9TH(x) _4_ADD9TH(x)

/* 9th */
#define _8_9TH(x)       x,x+4,x+7,x+10,x+14,x+10,x+7,x+4,
#define _16_9TH(x)      _8_9TH(x) _8_9TH(x)
#define _24_9TH(x)      _16_9TH(x) _8_9TH(x)
#define _32_9TH(x)      _24_9TH(x) _8_9TH(x)
#define _40_9TH(x)      _32_9TH(x) _8_9TH(x)
#define _48_9TH(x)      _40_9TH(x) _8_9TH(x)

/* 5th */
#define _4_5TH(x)       x,x+7,x+14,x+21,
#define _8_5TH(x)       _4_5TH(x) _4_5TH(x)
#define _12_5TH(x)      _8_5TH(x) _4_5TH(x)
#define _16_5TH(x)      _12_5TH(x) _4_5TH(x)
#define _20_5TH(x)      _16_5TH(x) _4_5TH(x)
#define _24_5TH(x)      _20_5TH(x) _4_5TH(x)
#define _28_5TH(x)      _24_5TH(x) _4_5TH(x)
#define _32_5TH(x)      _28_5TH(x) _4_5TH(x)
#define _36_5TH(x)      _32_5TH(x) _4_5TH(x)
#define _40_5TH(x)      _36_5TH(x) _4_5TH(x)
#define _44_5TH(x)      _40_5TH(x) _4_5TH(x)
#define _48_5TH(x)      _44_5TH(x) _4_5TH(x)

/* Tritone */
#define _4_TRI(x)       x,x+6,x+12,x+18,
#define _8_TRI(x)       _4_TRI(x) _4_TRI(x)
#define _12_TRI(x)      _8_TRI(x) _4_TRI(x)
#define _16_TRI(x)      _12_TRI(x) _4_TRI(x)
#define _20_TRI(x)      _16_TRI(x) _4_TRI(x)
#define _24_TRI(x)      _20_TRI(x) _4_TRI(x)
#define _28_TRI(x)      _24_TRI(x) _4_TRI(x)
#define _32_TRI(x)      _28_TRI(x) _4_TRI(x)
#define _36_TRI(x)      _32_TRI(x) _4_TRI(x)
#define _40_TRI(x)      _36_TRI(x) _4_TRI(x)
#define _44_TRI(x)      _40_TRI(x) _4_TRI(x)
#define _48_TRI(x)      _44_TRI(x) _4_TRI(x)

/* Rock */
#define _8_ROC(x)       x,x+3,x+5,x+7,x+10,x+7,x+5,x+3,
#define _16_ROC(x)      _8_ROC(x) _8_ROC(x)
#define _24_ROC(x)      _8_ROC(x) _16_ROC(x)
#define _32_ROC(x)      _8_ROC(x) _24_ROC(x)
#define _40_ROC(x)      _8_ROC(x) _32_ROC(x)
#define _48_ROC(x)      _8_ROC(x) _40_ROC(x)

/* Ryukyu */
#define _8_RYU(x)       x,x+4,x+5,x+7,x+11,x+7,x+5,x+4,
#define _16_RYU(x)      _8_RYU(x) _8_RYU(x)
#define _24_RYU(x)      _8_RYU(x) _16_RYU(x)
#define _32_RYU(x)      _8_RYU(x) _24_RYU(x)
#define _40_RYU(x)      _8_RYU(x) _32_RYU(x)
#define _48_RYU(x)      _8_RYU(x) _40_RYU(x)

/* Major Enka/ Kyuchou/ Major Pentatnoic */
#define _8_ENK(x)       x,x+2,x+4,x+7,x+9,x+7,x+4,x+2,
#define _16_ENK(x)      _8_ENK(x) _8_ENK(x)
#define _24_ENK(x)      _8_ENK(x) _16_ENK(x)
#define _32_ENK(x)      _8_ENK(x) _24_ENK(x)
#define _40_ENK(x)      _8_ENK(x) _32_ENK(x)
#define _48_ENK(x)      _8_ENK(x) _40_ENK(x)

/* Minor Enka */
#define _8_MEN(x)       x,x+2,x+3,x+7,x+8,x+7,x+3,x+2,
#define _16_MEN(x)      _8_MEN(x) _8_MEN(x)
#define _24_MEN(x)      _8_MEN(x) _16_MEN(x)
#define _32_MEN(x)      _8_MEN(x) _24_MEN(x)
#define _40_MEN(x)      _8_MEN(x) _32_MEN(x)
#define _48_MEN(x)      _8_MEN(x) _40_MEN(x)

/* Dominant */
#define _8_DOM(x)       x,x-5,x,x-5,x,x-5,x,x-5,
#define _16_DOM(x)      _8_DOM(x) _8_DOM(x)
#define _24_DOM(x)      _8_DOM(x) _16_DOM(x)
#define _32_DOM(x)      _8_DOM(x) _24_DOM(x)
#define _40_DOM(x)      _8_DOM(x) _32_DOM(x)
#define _48_DOM(x)      _8_DOM(x) _40_DOM(x)

/* Arpeggios */
#define _24_MAJ_ARP(x)     _6(x) _6(x+4) _6(x+7) _6(x+4)
#define _24_M_ARP(x)       _6(x) _6(x+3) _6(x+7) _6(x+3)
#define _24_MAJ7TH_ARP(x)  _4(x) _4(x+4) _4(x+7) _4(x+11) _4(x+7) _4(x+4)
#define _24_MMAJ7TH_ARP(x) _4(x) _4(x+3) _4(x+7) _4(x+11) _4(x+7) _4(x+3)
#define _24_7TH_ARP(x)     _4(x) _4(x+4) _4(x+7) _4(x+10) _4(x+7) _4(x+4)
#define _24_M7TH_ARP(x)    _4(x) _4(x+3) _4(x+7) _4(x+10) _4(x+7) _4(x+3)
#define _24_ADD9TH_ARP(x)  _4(x) _4(x+4) _4(x+7) _4(x+14) _4(x+7) _4(x+4)
#define _24_9TH_ARP(x)     _3(x) _3(x+4) _3(x+7) _3(x+10) _3(x+14) _3(x+10) _3(x+7) _3(x+4)
#define _24_5TH_ARP(x)     _4(x) _4(x+7) _4(x+14) _4(x+21) _4(x+14) _4(x+7)
#define _24_TRI_ARP(x)     _4(x) _4(x+6) _4(x+12) _4(x+18) _4(x+12) _4(x+6)
#define _24_MIX_ARP(x)     _2(x) _2(x+2) _2(x+4) _2(x+5) _2(x+7) _2(x+9) _2(x+10) _2(x+9) _2(x+7) _2(x+5) _2(x+4) _2(x+2) // Mixolydian, Diatonic on G
#define _24_DOR_ARP(x)     _2(x) _2(x+1) _2(x+3) _2(x+5) _2(x+7) _2(x+8) _2(x+10) _2(x+8) _2(x+7) _2(x+5) _2(x+3) _2(x+1) // Dorian, Diatonic on E
#define _24_PHR_ARP(x)     _2(x) _2(x+2) _2(x+3) _2(x+5) _2(x+7) _2(x+9) _2(x+10) _2(x+9) _2(x+7) _2(x+5) _2(x+3) _2(x+2) // Phrygian, Diatonic on D
#define _24_BLU_ARP(x)     _2(x) _2(x+2) _2(x+3) _2(x+5) _2(x+6) _2(x+7) _2(x+10) _2(x+7) _2(x+6) _2(x+5) _2(x+3) _2(x+2) // Blue-note
#define _24_ROC_ARP(x)     _4(x) _4(x+3) _4(x+5) _4(x+7) _4(x+10) _4(x+7) _4(x+5) _4(x+3) // Rock
#define _24_RYU_ARP(x)     _4(x) _4(x+4) _4(x+5) _4(x+7) _4(x+11) _4(x+7) _4(x+5) _4(x+4) // Ryukyu
#define _24_ENK_ARP(x)     _4(x) _4(x+2) _4(x+4) _4(x+7) _4(x+9) _4(x+7) _4(x+4) _4(x+2) // Major Enka
#define _24_MEN_ARP(x)     _4(x) _4(x+2) _4(x+3) _4(x+7) _4(x+8) _4(x+7) _4(x+3) _4(x+2) // Minor Enka
#define _24_DOM_ARP(x)     _4(x) _4(x-5) _4(x) _4(x-5) _4(x) _4(x-5) _4(x) _4(x-5) // Dominant

#define _48_MAJ_ARP(x)     _12(x) _12(x+4) _12(x+7) _12(x+4)
#define _48_M_ARP(x)       _12(x) _12(x+3) _12(x+7) _12(x+3)
#define _48_MAJ7TH_ARP(x)  _8(x) _8(x+4) _8(x+7) _8(x+11) _8(x+7) _8(x+4)
#define _48_MMAJ7TH_ARP(x) _8(x) _8(x+3) _8(x+7) _8(x+11) _8(x+7) _8(x+3)
#define _48_7TH_ARP(x)     _8(x) _8(x+4) _8(x+7) _8(x+10) _8(x+7) _8(x+4)
#define _48_M7TH_ARP(x)    _8(x) _8(x+3) _8(x+7) _8(x+10) _8(x+7) _8(x+3)
#define _48_ADD9TH_ARP(x)  _8(x) _8(x+4) _8(x+7) _8(x+14) _8(x+7) _8(x+4)
#define _48_9TH_ARP(x)     _6(x) _6(x+4) _6(x+7) _6(x+10) _6(x+14) _6(x+10) _6(x+7) _6(x+4)
#define _48_5TH_ARP(x)     _8(x) _8(x+7) _8(x+14) _8(x+21) _8(x+14) _8(x+7)
#define _48_TRI_ARP(x)     _8(x) _8(x+6) _8(x+12) _8(x+18) _8(x+12) _8(x+6)
#define _48_MIX_ARP(x)     _4(x) _4(x+2) _4(x+4) _4(x+5) _4(x+7) _4(x+9) _4(x+10) _4(x+9) _4(x+7) _4(x+5) _4(x+4) _4(x+2) // Mixolydian, Diatonic on G
#define _48_DOR_ARP(x)     _4(x) _4(x+1) _4(x+3) _4(x+5) _4(x+7) _4(x+8) _4(x+10) _4(x+8) _4(x+7) _4(x+5) _4(x+3) _4(x+1) // Dorian, Diatonic on E
#define _48_PHR_ARP(x)     _4(x) _4(x+2) _4(x+3) _4(x+5) _4(x+7) _4(x+9) _4(x+10) _4(x+9) _4(x+7) _4(x+5) _4(x+3) _4(x+2) // Phrygian, Diatonic on D
#define _48_BLU_ARP(x)     _4(x) _4(x+2) _4(x+3) _4(x+5) _4(x+6) _4(x+7) _4(x+10) _4(x+7) _4(x+6) _4(x+5) _4(x+3) _4(x+2) // Blue-note
#define _48_ROC_ARP(x)     _8(x) _8(x+3) _8(x+5) _8(x+7) _8(x+10) _8(x+7) _8(x+5) _8(x+3) // Rock
#define _48_RYU_ARP(x)     _8(x) _8(x+4) _8(x+5) _8(x+7) _8(x+11) _8(x+7) _8(x+5) _8(x+4) // Ryukyu
#define _48_ENK_ARP(x)     _8(x) _8(x+2) _8(x+4) _8(x+7) _8(x+9) _8(x+7) _8(x+4) _8(x+2) // Major Enka
#define _48_MEN_ARP(x)     _8(x) _8(x+2) _8(x+3) _8(x+7) _8(x+8) _8(x+7) _8(x+3) _8(x+2) // Minor Enka
#define _48_DOM_ARP(x)     _8(x) _8(x-5) _8(x) _8(x-5) _8(x) _8(x-5) _8(x) _8(x-5) // Dominant

/* Decay, Need of Big Volume */
#define _8_DEC(x)       _4(x) _4(x+0x100)
#define _12_DEC(x)      _4(x) _4(x+0x100) _4(x+0x200)
#define _16_DEC(x)      _4(x) _4(x+0x100) _8(x+0x200)
#define _20_DEC(x)      _4(x) _4(x+0x100) _12(x+0x200)
#define _24_DEC(x)      _4(x) _4(x+0x100) _16(x+0x200)

