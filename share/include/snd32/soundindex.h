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
 * Bit[15:13]: Type of Wave, 0 is Sine, 1 is Saw Tooth, 2 is Square, 3 is Triangle, 4 is Distortion
 *              6 is Noise, 7 is Silence.
 *
 * Maximum number of blocks is 4096.
 * 0 means End of Sound Index
 */

/**
 * Sampling rate is appx. 3.168Khz to be adjusted to fit A4 on 440hz.
 * For Example, if you want 440hz, the value on the right side should be 72.
 * 31680 divided by 72 equals 440.
 */
sound_index _SOUND_INDEX[] =
{
	/* Volume Large */

	0<<13|0<<11|576, // 0x00 Sine
	0<<13|0<<11|543, // 0x01 Sine
	0<<13|0<<11|513, // 0x02 Sine
	0<<13|0<<11|484, // 0x03 Sine
	0<<13|0<<11|457, // 0x04 Sine
	0<<13|0<<11|431, // 0x05 Sine
	0<<13|0<<11|407, // 0x06 Sine
	0<<13|0<<11|384, // 0x07 Sine
	0<<13|0<<11|362, // 0x08 Sine
	0<<13|0<<11|342, // 0x09 Sine
	0<<13|0<<11|323, // 0x0A Sine
	0<<13|0<<11|305, // 0x0B Sine
	0<<13|0<<11|288, // 0x0C Sine
	0<<13|0<<11|272, // 0x0D Sine
	0<<13|0<<11|256, // 0x0E Sine
	0<<13|0<<11|242, // 0x0F Sine
	0<<13|0<<11|228, // 0x10 Sine
	0<<13|0<<11|215, // 0x11 Sine
	0<<13|0<<11|203, // 0x12 Sine
	0<<13|0<<11|192, // 0x13 Sine
	0<<13|0<<11|181, // 0x14 Sine
	0<<13|0<<11|171, // 0x15 Sine
	0<<13|0<<11|161, // 0x16 Sine
	0<<13|0<<11|152, // 0x17 Sine
	0<<13|0<<11|144, // 0x18 Sine
	0<<13|0<<11|135, // 0x19 Sine
	0<<13|0<<11|128, // 0x1A Sine
	0<<13|0<<11|121, // 0x1B Sine
	0<<13|0<<11|114, // 0x1C Sine
	0<<13|0<<11|107, // 0x1D Sine
	0<<13|0<<11|101, // 0x1E Sine
	0<<13|0<<11|96,  // 0x1F Sine
	0<<13|0<<11|90,  // 0x20 Sine
	0<<13|0<<11|85,  // 0x21 Sine
	0<<13|0<<11|80,  // 0x22 Sine
	0<<13|0<<11|76,  // 0x23 Sine
	0<<13|0<<11|72,  // 0x24 Sine
	0<<13|0<<11|68,  // 0x25 Sine
	0<<13|0<<11|64,  // 0x26 Sine
	0<<13|0<<11|60,  // 0x27 Sine
	0<<13|0<<11|57,  // 0x28 Sine
	0<<13|0<<11|53,  // 0x29 Sine
	0<<13|0<<11|50,  // 0x2A Sine
	0<<13|0<<11|48,  // 0x2B Sine
	0<<13|0<<11|45,  // 0x2C Sine
	0<<13|0<<11|42,  // 0x2D Sine
	0<<13|0<<11|40,  // 0x2E Sine
	0<<13|0<<11|38,  // 0x2F Sine
	0<<13|0<<11|36,  // 0x30 Sine
	0<<13|0<<11|34,  // 0x31 Sine
	0<<13|0<<11|32,  // 0x32 Sine
	0<<13|0<<11|30,  // 0x33 Sine
	0<<13|0<<11|28,  // 0x34 Sine
	0<<13|0<<11|26,  // 0x35 Sine
	0<<13|0<<11|25,  // 0x36 Sine
	0<<13|0<<11|24,  // 0x37 Sine
	0<<13|0<<11|22,  // 0x38 Sine
	0<<13|0<<11|21,  // 0x39 Sine
	0<<13|0<<11|20,  // 0x3A Sine
	0<<13|0<<11|19,  // 0x3B Sine
	0<<13|0<<11|18,  // 0x3C Sine
	0<<13|0<<11|17,  // 0x3D Sine
	0<<13|0<<11|16,  // 0x3E Sine
	0<<13|0<<11|15,  // 0x3F Sine

	1<<13|0<<11|576, // 0x40 Saw Tooth
	1<<13|0<<11|543, // 0x41 Saw Tooth
	1<<13|0<<11|513, // 0x42 Saw Tooth
	1<<13|0<<11|484, // 0x43 Saw Tooth
	1<<13|0<<11|457, // 0x44 Saw Tooth
	1<<13|0<<11|431, // 0x45 Saw Tooth
	1<<13|0<<11|407, // 0x46 Saw Tooth
	1<<13|0<<11|384, // 0x47 Saw Tooth
	1<<13|0<<11|362, // 0x48 Saw Tooth
	1<<13|0<<11|342, // 0x49 Saw Tooth
	1<<13|0<<11|323, // 0x4A Saw Tooth
	1<<13|0<<11|305, // 0x4B Saw Tooth
	1<<13|0<<11|288, // 0x4C Saw Tooth
	1<<13|0<<11|272, // 0x4D Saw Tooth
	1<<13|0<<11|256, // 0x4E Saw Tooth
	1<<13|0<<11|242, // 0x4F Saw Tooth
	1<<13|0<<11|228, // 0x50 Saw Tooth
	1<<13|0<<11|215, // 0x51 Saw Tooth
	1<<13|0<<11|203, // 0x52 Saw Tooth
	1<<13|0<<11|192, // 0x53 Saw Tooth
	1<<13|0<<11|181, // 0x54 Saw Tooth
	1<<13|0<<11|171, // 0x55 Saw Tooth
	1<<13|0<<11|161, // 0x56 Saw Tooth
	1<<13|0<<11|152, // 0x57 Saw Tooth
	1<<13|0<<11|144, // 0x58 Saw Tooth
	1<<13|0<<11|135, // 0x59 Saw Tooth
	1<<13|0<<11|128, // 0x5A Saw Tooth
	1<<13|0<<11|121, // 0x5B Saw Tooth
	1<<13|0<<11|114, // 0x5C Saw Tooth
	1<<13|0<<11|107, // 0x5D Saw Tooth
	1<<13|0<<11|101, // 0x5E Saw Tooth
	1<<13|0<<11|96,  // 0x5F Saw Tooth
	1<<13|0<<11|90,  // 0x60 Saw Tooth
	1<<13|0<<11|85,  // 0x61 Saw Tooth
	1<<13|0<<11|80,  // 0x62 Saw Tooth
	1<<13|0<<11|76,  // 0x63 Saw Tooth
	1<<13|0<<11|72,  // 0x64 Saw Tooth
	1<<13|0<<11|68,  // 0x65 Saw Tooth
	1<<13|0<<11|64,  // 0x66 Saw Tooth
	1<<13|0<<11|60,  // 0x67 Saw Tooth
	1<<13|0<<11|57,  // 0x68 Saw Tooth
	1<<13|0<<11|53,  // 0x69 Saw Tooth
	1<<13|0<<11|50,  // 0x6A Saw Tooth
	1<<13|0<<11|48,  // 0x6B Saw Tooth
	1<<13|0<<11|45,  // 0x6C Saw Tooth
	1<<13|0<<11|42,  // 0x6D Saw Tooth
	1<<13|0<<11|40,  // 0x6E Saw Tooth
	1<<13|0<<11|38,  // 0x6F Saw Tooth
	1<<13|0<<11|36,  // 0x70 Saw Tooth
	1<<13|0<<11|34,  // 0x71 Saw Tooth
	1<<13|0<<11|32,  // 0x72 Saw Tooth
	1<<13|0<<11|30,  // 0x73 Saw Tooth
	1<<13|0<<11|28,  // 0x74 Saw Tooth
	1<<13|0<<11|26,  // 0x75 Saw Tooth
	1<<13|0<<11|25,  // 0x76 Saw Tooth
	1<<13|0<<11|24,  // 0x77 Saw Tooth
	1<<13|0<<11|22,  // 0x78 Saw Tooth
	1<<13|0<<11|21,  // 0x79 Saw Tooth
	1<<13|0<<11|20,  // 0x7A Saw Tooth
	1<<13|0<<11|19,  // 0x7B Saw Tooth
	1<<13|0<<11|18,  // 0x7C Saw Tooth
	1<<13|0<<11|17,  // 0x7D Saw Tooth
	1<<13|0<<11|16,  // 0x7E Saw Tooth
	1<<13|0<<11|15,  // 0x7F Saw Tooth

	2<<13|0<<11|576, // 0x80 Square
	2<<13|0<<11|543, // 0x81 Square
	2<<13|0<<11|513, // 0x82 Square
	2<<13|0<<11|484, // 0x83 Square
	2<<13|0<<11|457, // 0x84 Square
	2<<13|0<<11|431, // 0x85 Square
	2<<13|0<<11|407, // 0x86 Square
	2<<13|0<<11|384, // 0x87 Square
	2<<13|0<<11|362, // 0x88 Square
	2<<13|0<<11|342, // 0x89 Square
	2<<13|0<<11|323, // 0x8A Square
	2<<13|0<<11|305, // 0x8B Square
	2<<13|0<<11|288, // 0x8C Square
	2<<13|0<<11|272, // 0x8D Square
	2<<13|0<<11|256, // 0x8E Square
	2<<13|0<<11|242, // 0x8F Square
	2<<13|0<<11|228, // 0x90 Square
	2<<13|0<<11|215, // 0x91 Square
	2<<13|0<<11|203, // 0x92 Square
	2<<13|0<<11|192, // 0x93 Square
	2<<13|0<<11|181, // 0x94 Square
	2<<13|0<<11|171, // 0x95 Square
	2<<13|0<<11|161, // 0x96 Square
	2<<13|0<<11|152, // 0x97 Square
	2<<13|0<<11|144, // 0x98 Square
	2<<13|0<<11|135, // 0x99 Square
	2<<13|0<<11|128, // 0x9A Square
	2<<13|0<<11|121, // 0x9B Square
	2<<13|0<<11|114, // 0x9C Square
	2<<13|0<<11|107, // 0x9D Square
	2<<13|0<<11|101, // 0x9E Square
	2<<13|0<<11|96,  // 0x9F Square
	2<<13|0<<11|90,  // 0xA0 Square
	2<<13|0<<11|85,  // 0xA1 Square
	2<<13|0<<11|80,  // 0xA2 Square
	2<<13|0<<11|76,  // 0xA3 Square
	2<<13|0<<11|72,  // 0xA4 Square
	2<<13|0<<11|68,  // 0xA5 Square
	2<<13|0<<11|64,  // 0xA6 Square
	2<<13|0<<11|60,  // 0xA7 Square
	2<<13|0<<11|57,  // 0xA8 Square
	2<<13|0<<11|53,  // 0xA9 Square
	2<<13|0<<11|50,  // 0xAA Square
	2<<13|0<<11|48,  // 0xAB Square
	2<<13|0<<11|45,  // 0xAC Square
	2<<13|0<<11|42,  // 0xAD Square
	2<<13|0<<11|40,  // 0xAE Square
	2<<13|0<<11|38,  // 0xAF Square
	2<<13|0<<11|36,  // 0xB0 Square
	2<<13|0<<11|34,  // 0xB1 Square
	2<<13|0<<11|32,  // 0xB2 Square
	2<<13|0<<11|30,  // 0xB3 Square
	2<<13|0<<11|28,  // 0xB4 Square
	2<<13|0<<11|26,  // 0xB5 Square
	2<<13|0<<11|25,  // 0xB6 Square
	2<<13|0<<11|24,  // 0xB7 Square
	2<<13|0<<11|22,  // 0xB8 Square
	2<<13|0<<11|21,  // 0xB9 Square
	2<<13|0<<11|20,  // 0xBA Square
	2<<13|0<<11|19,  // 0xBB Square
	2<<13|0<<11|18,  // 0xBC Square
	2<<13|0<<11|17,  // 0xBD Square
	2<<13|0<<11|16,  // 0xBE Square
	2<<13|0<<11|15,  // 0xBF Square

	/* High Tones Large */

	2<<13|0<<11|14,  // 0xC0 Square
	2<<13|0<<11|13,  // 0xC1 Square
	2<<13|0<<11|12,  // 0xC2 Square
	2<<13|0<<11|12,  // 0xC3 Square
	2<<13|0<<11|11,  // 0xC4 Square
	2<<13|0<<11|10,  // 0xC5 Square
	2<<13|0<<11|10,  // 0xC6 Square
	2<<13|0<<11|9,   // 0xC7 Square
	2<<13|0<<11|9,   // 0xC8 Square
	2<<13|0<<11|8,   // 0xC9 Square
	2<<13|0<<11|8,   // 0xCA Square
	2<<13|0<<11|7,   // 0xCB Square

	/**
	 * Assume Fixed Length as 640, Sample Rate 31680Hz Divided by 48 and Minus 20, Not to Slide Beat by DMA Process
	 * The value on the right side is stride.
	 */
	6<<13|0<<11|108, // 0xCC Noise
	6<<13|0<<11|106, // 0xCD Noise
	6<<13|0<<11|104, // 0xCE Noise
	6<<13|0<<11|102, // 0xCF Noise
	6<<13|0<<11|100, // 0xD0 Noise
	6<<13|0<<11|98,  // 0xD1 Noise
	6<<13|0<<11|96,  // 0xD2 Noise
	6<<13|0<<11|94,  // 0xD3 Noise
	6<<13|0<<11|92,  // 0xD4 Noise
	6<<13|0<<11|90,  // 0xD5 Noise
	6<<13|0<<11|88,  // 0xD6 Noise
	6<<13|0<<11|86,  // 0xD7 Noise
	6<<13|0<<11|84,  // 0xD8 Noise
	6<<13|0<<11|82,  // 0xD9 Noise
	6<<13|0<<11|80,  // 0xDA Noise
	6<<13|0<<11|78,  // 0xDB Noise
	6<<13|0<<11|76,  // 0xDC Noise
	6<<13|0<<11|74,  // 0xDD Noise
	6<<13|0<<11|72,  // 0xDE Noise
	6<<13|0<<11|70,  // 0xDF Noise
	6<<13|0<<11|68,  // 0xE0 Noise
	6<<13|0<<11|66,  // 0xE1 Noise
	6<<13|0<<11|64,  // 0xE2 Noise
	6<<13|0<<11|62,  // 0xE3 Noise
	6<<13|0<<11|60,  // 0xE4 Noise
	6<<13|0<<11|58,  // 0xE5 Noise
	6<<13|0<<11|56,  // 0xE6 Noise
	6<<13|0<<11|54,  // 0xE7 Noise
	6<<13|0<<11|52,  // 0xE8 Noise
	6<<13|0<<11|50,  // 0xE9 Noise
	6<<13|0<<11|48,  // 0xEA Noise
	6<<13|0<<11|46,  // 0xEB Noise
	6<<13|0<<11|44,  // 0xEC Noise
	6<<13|0<<11|42,  // 0xED Noise
	6<<13|0<<11|40,  // 0xEE Noise
	6<<13|0<<11|38,  // 0xEF Noise
	6<<13|0<<11|36,  // 0xF0 Noise
	6<<13|0<<11|34,  // 0xF1 Noise
	6<<13|0<<11|32,  // 0xF2 Noise
	6<<13|0<<11|30,  // 0xF3 Noise
	6<<13|0<<11|28,  // 0xF4 Noise
	6<<13|0<<11|26,  // 0xF5 Noise
	6<<13|0<<11|24,  // 0xF6 Noise
	6<<13|0<<11|22,  // 0xF7 Noise
	6<<13|0<<11|20,  // 0xF8 Noise
	6<<13|0<<11|18,  // 0xF9 Noise
	6<<13|0<<11|16,  // 0xFA Noise
	6<<13|0<<11|14,  // 0xFB Noise
	6<<13|0<<11|12,  // 0xFC Noise
	6<<13|0<<11|10,  // 0xFD Noise
	6<<13|0<<11|8,   // 0xFE Noise
	6<<13|0<<11|6,   // 0xFF Noise

	3<<13|0<<11|576, // 0x100 Triangle
	3<<13|0<<11|543, // 0x101 Triangle
	3<<13|0<<11|513, // 0x102 Triangle
	3<<13|0<<11|484, // 0x103 Triangle
	3<<13|0<<11|457, // 0x104 Triangle
	3<<13|0<<11|431, // 0x105 Triangle
	3<<13|0<<11|407, // 0x106 Triangle
	3<<13|0<<11|384, // 0x107 Triangle
	3<<13|0<<11|362, // 0x108 Triangle
	3<<13|0<<11|342, // 0x109 Triangle
	3<<13|0<<11|323, // 0x10A Triangle
	3<<13|0<<11|305, // 0x10B Triangle
	3<<13|0<<11|288, // 0x10C Triangle
	3<<13|0<<11|272, // 0x10D Triangle
	3<<13|0<<11|256, // 0x10E Triangle
	3<<13|0<<11|242, // 0x10F Triangle
	3<<13|0<<11|228, // 0x110 Triangle
	3<<13|0<<11|215, // 0x111 Triangle
	3<<13|0<<11|203, // 0x112 Triangle
	3<<13|0<<11|192, // 0x113 Triangle
	3<<13|0<<11|181, // 0x114 Triangle
	3<<13|0<<11|171, // 0x115 Triangle
	3<<13|0<<11|161, // 0x116 Triangle
	3<<13|0<<11|152, // 0x117 Triangle
	3<<13|0<<11|144, // 0x118 Triangle
	3<<13|0<<11|135, // 0x119 Triangle
	3<<13|0<<11|128, // 0x11A Triangle
	3<<13|0<<11|121, // 0x11B Triangle
	3<<13|0<<11|114, // 0x11C Triangle
	3<<13|0<<11|107, // 0x11D Triangle
	3<<13|0<<11|101, // 0x11E Triangle
	3<<13|0<<11|96,  // 0x11F Triangle
	3<<13|0<<11|90,  // 0x120 Triangle
	3<<13|0<<11|85,  // 0x121 Triangle
	3<<13|0<<11|80,  // 0x122 Triangle
	3<<13|0<<11|76,  // 0x123 Triangle
	3<<13|0<<11|72,  // 0x124 Triangle
	3<<13|0<<11|68,  // 0x125 Triangle
	3<<13|0<<11|64,  // 0x126 Triangle
	3<<13|0<<11|60,  // 0x127 Triangle
	3<<13|0<<11|57,  // 0x128 Triangle
	3<<13|0<<11|53,  // 0x129 Triangle
	3<<13|0<<11|50,  // 0x12A Triangle
	3<<13|0<<11|48,  // 0x12B Triangle
	3<<13|0<<11|45,  // 0x12C Triangle
	3<<13|0<<11|42,  // 0x12D Triangle
	3<<13|0<<11|40,  // 0x12E Triangle
	3<<13|0<<11|38,  // 0x12F Triangle
	3<<13|0<<11|36,  // 0x130 Triangle
	3<<13|0<<11|34,  // 0x131 Triangle
	3<<13|0<<11|32,  // 0x132 Triangle
	3<<13|0<<11|30,  // 0x133 Triangle
	3<<13|0<<11|28,  // 0x134 Triangle
	3<<13|0<<11|26,  // 0x135 Triangle
	3<<13|0<<11|25,  // 0x136 Triangle
	3<<13|0<<11|24,  // 0x137 Triangle
	3<<13|0<<11|22,  // 0x138 Triangle
	3<<13|0<<11|21,  // 0x139 Triangle
	3<<13|0<<11|20,  // 0x13A Triangle
	3<<13|0<<11|19,  // 0x13B Triangle
	3<<13|0<<11|18,  // 0x13C Triangle
	3<<13|0<<11|17,  // 0x13D Triangle
	3<<13|0<<11|16,  // 0x13E Triangle
	3<<13|0<<11|15,  // 0x13F Triangle

	4<<13|0<<11|576, // 0x140 Distortion
	4<<13|0<<11|543, // 0x141 Distortion
	4<<13|0<<11|513, // 0x142 Distortion
	4<<13|0<<11|484, // 0x143 Distortion
	4<<13|0<<11|457, // 0x144 Distortion
	4<<13|0<<11|431, // 0x145 Distortion
	4<<13|0<<11|407, // 0x146 Distortion
	4<<13|0<<11|384, // 0x147 Distortion
	4<<13|0<<11|362, // 0x148 Distortion
	4<<13|0<<11|342, // 0x149 Distortion
	4<<13|0<<11|323, // 0x14A Distortion
	4<<13|0<<11|305, // 0x14B Distortion
	4<<13|0<<11|288, // 0x14C Distortion
	4<<13|0<<11|272, // 0x14D Distortion
	4<<13|0<<11|256, // 0x14E Distortion
	4<<13|0<<11|242, // 0x14F Distortion
	4<<13|0<<11|228, // 0x150 Distortion
	4<<13|0<<11|215, // 0x151 Distortion
	4<<13|0<<11|203, // 0x152 Distortion
	4<<13|0<<11|192, // 0x153 Distortion
	4<<13|0<<11|181, // 0x154 Distortion
	4<<13|0<<11|171, // 0x155 Distortion
	4<<13|0<<11|161, // 0x156 Distortion
	4<<13|0<<11|152, // 0x157 Distortion
	4<<13|0<<11|144, // 0x158 Distortion
	4<<13|0<<11|135, // 0x159 Distortion
	4<<13|0<<11|128, // 0x15A Distortion
	4<<13|0<<11|121, // 0x15B Distortion
	4<<13|0<<11|114, // 0x15C Distortion
	4<<13|0<<11|107, // 0x15D Distortion
	4<<13|0<<11|101, // 0x15E Distortion
	4<<13|0<<11|96,  // 0x15F Distortion
	4<<13|0<<11|90,  // 0x160 Distortion
	4<<13|0<<11|85,  // 0x161 Distortion
	4<<13|0<<11|80,  // 0x162 Distortion
	4<<13|0<<11|76,  // 0x163 Distortion
	4<<13|0<<11|72,  // 0x164 Distortion
	4<<13|0<<11|68,  // 0x165 Distortion
	4<<13|0<<11|64,  // 0x166 Distortion
	4<<13|0<<11|60,  // 0x167 Distortion
	4<<13|0<<11|57,  // 0x168 Distortion
	4<<13|0<<11|53,  // 0x169 Distortion
	4<<13|0<<11|50,  // 0x16A Distortion
	4<<13|0<<11|48,  // 0x16B Distortion
	4<<13|0<<11|45,  // 0x16C Distortion
	4<<13|0<<11|42,  // 0x16D Distortion
	4<<13|0<<11|40,  // 0x16E Distortion
	4<<13|0<<11|38,  // 0x16F Distortion
	4<<13|0<<11|36,  // 0x170 Distortion
	4<<13|0<<11|34,  // 0x171 Distortion
	4<<13|0<<11|32,  // 0x172 Distortion
	4<<13|0<<11|30,  // 0x173 Distortion
	4<<13|0<<11|28,  // 0x174 Distortion
	4<<13|0<<11|26,  // 0x175 Distortion
	4<<13|0<<11|25,  // 0x176 Distortion
	4<<13|0<<11|24,  // 0x177 Distortion
	4<<13|0<<11|22,  // 0x178 Distortion
	4<<13|0<<11|21,  // 0x179 Distortion
	4<<13|0<<11|20,  // 0x17A Distortion
	4<<13|0<<11|19,  // 0x17B Distortion
	4<<13|0<<11|18,  // 0x17C Distortion
	4<<13|0<<11|17,  // 0x17D Distortion
	4<<13|0<<11|16,  // 0x17E Distortion
	4<<13|0<<11|15,  // 0x17F Distortion

	_64(7<<13|0<<11|2)
	_64(7<<13|0<<11|2)

	/* Volume Medium */

	0<<13|1<<11|576, // 0x200 Sine
	0<<13|1<<11|543, // 0x201 Sine
	0<<13|1<<11|513, // 0x202 Sine
	0<<13|1<<11|484, // 0x203 Sine
	0<<13|1<<11|457, // 0x204 Sine
	0<<13|1<<11|431, // 0x205 Sine
	0<<13|1<<11|407, // 0x206 Sine
	0<<13|1<<11|384, // 0x207 Sine
	0<<13|1<<11|362, // 0x208 Sine
	0<<13|1<<11|342, // 0x209 Sine
	0<<13|1<<11|323, // 0x20A Sine
	0<<13|1<<11|305, // 0x20B Sine
	0<<13|1<<11|288, // 0x20C Sine
	0<<13|1<<11|272, // 0x20D Sine
	0<<13|1<<11|256, // 0x20E Sine
	0<<13|1<<11|242, // 0x20F Sine
	0<<13|1<<11|228, // 0x210 Sine
	0<<13|1<<11|215, // 0x211 Sine
	0<<13|1<<11|203, // 0x212 Sine
	0<<13|1<<11|192, // 0x213 Sine
	0<<13|1<<11|181, // 0x214 Sine
	0<<13|1<<11|171, // 0x215 Sine
	0<<13|1<<11|161, // 0x216 Sine
	0<<13|1<<11|152, // 0x217 Sine
	0<<13|1<<11|144, // 0x218 Sine
	0<<13|1<<11|135, // 0x219 Sine
	0<<13|1<<11|128, // 0x21A Sine
	0<<13|1<<11|121, // 0x21B Sine
	0<<13|1<<11|114, // 0x21C Sine
	0<<13|1<<11|107, // 0x21D Sine
	0<<13|1<<11|101, // 0x21E Sine
	0<<13|1<<11|96,  // 0x21F Sine
	0<<13|1<<11|90,  // 0x220 Sine
	0<<13|1<<11|85,  // 0x221 Sine
	0<<13|1<<11|80,  // 0x222 Sine
	0<<13|1<<11|76,  // 0x223 Sine
	0<<13|1<<11|72,  // 0x224 Sine
	0<<13|1<<11|68,  // 0x225 Sine
	0<<13|1<<11|64,  // 0x226 Sine
	0<<13|1<<11|60,  // 0x227 Sine
	0<<13|1<<11|57,  // 0x228 Sine
	0<<13|1<<11|53,  // 0x229 Sine
	0<<13|1<<11|50,  // 0x22A Sine
	0<<13|1<<11|48,  // 0x22B Sine
	0<<13|1<<11|45,  // 0x22C Sine
	0<<13|1<<11|42,  // 0x22D Sine
	0<<13|1<<11|40,  // 0x22E Sine
	0<<13|1<<11|38,  // 0x22F Sine
	0<<13|1<<11|36,  // 0x230 Sine
	0<<13|1<<11|34,  // 0x231 Sine
	0<<13|1<<11|32,  // 0x232 Sine
	0<<13|1<<11|30,  // 0x233 Sine
	0<<13|1<<11|28,  // 0x234 Sine
	0<<13|1<<11|26,  // 0x235 Sine
	0<<13|1<<11|25,  // 0x236 Sine
	0<<13|1<<11|24,  // 0x237 Sine
	0<<13|1<<11|22,  // 0x238 Sine
	0<<13|1<<11|21,  // 0x239 Sine
	0<<13|1<<11|20,  // 0x23A Sine
	0<<13|1<<11|19,  // 0x23B Sine
	0<<13|1<<11|18,  // 0x23C Sine
	0<<13|1<<11|17,  // 0x23D Sine
	0<<13|1<<11|16,  // 0x23E Sine
	0<<13|1<<11|15,  // 0x23F Sine

	1<<13|1<<11|576, // 0x240 Saw Tooth
	1<<13|1<<11|543, // 0x241 Saw Tooth
	1<<13|1<<11|513, // 0x242 Saw Tooth
	1<<13|1<<11|484, // 0x243 Saw Tooth
	1<<13|1<<11|457, // 0x244 Saw Tooth
	1<<13|1<<11|431, // 0x245 Saw Tooth
	1<<13|1<<11|407, // 0x246 Saw Tooth
	1<<13|1<<11|384, // 0x247 Saw Tooth
	1<<13|1<<11|362, // 0x248 Saw Tooth
	1<<13|1<<11|342, // 0x249 Saw Tooth
	1<<13|1<<11|323, // 0x24A Saw Tooth
	1<<13|1<<11|305, // 0x24B Saw Tooth
	1<<13|1<<11|288, // 0x24C Saw Tooth
	1<<13|1<<11|272, // 0x24D Saw Tooth
	1<<13|1<<11|256, // 0x24E Saw Tooth
	1<<13|1<<11|242, // 0x24F Saw Tooth
	1<<13|1<<11|228, // 0x250 Saw Tooth
	1<<13|1<<11|215, // 0x251 Saw Tooth
	1<<13|1<<11|203, // 0x252 Saw Tooth
	1<<13|1<<11|192, // 0x253 Saw Tooth
	1<<13|1<<11|181, // 0x254 Saw Tooth
	1<<13|1<<11|171, // 0x255 Saw Tooth
	1<<13|1<<11|161, // 0x256 Saw Tooth
	1<<13|1<<11|152, // 0x257 Saw Tooth
	1<<13|1<<11|144, // 0x258 Saw Tooth
	1<<13|1<<11|135, // 0x259 Saw Tooth
	1<<13|1<<11|128, // 0x25A Saw Tooth
	1<<13|1<<11|121, // 0x25B Saw Tooth
	1<<13|1<<11|114, // 0x25C Saw Tooth
	1<<13|1<<11|107, // 0x25D Saw Tooth
	1<<13|1<<11|101, // 0x25E Saw Tooth
	1<<13|1<<11|96,  // 0x25F Saw Tooth
	1<<13|1<<11|90,  // 0x260 Saw Tooth
	1<<13|1<<11|85,  // 0x261 Saw Tooth
	1<<13|1<<11|80,  // 0x262 Saw Tooth
	1<<13|1<<11|76,  // 0x263 Saw Tooth
	1<<13|1<<11|72,  // 0x264 Saw Tooth
	1<<13|1<<11|68,  // 0x265 Saw Tooth
	1<<13|1<<11|64,  // 0x266 Saw Tooth
	1<<13|1<<11|60,  // 0x267 Saw Tooth
	1<<13|1<<11|57,  // 0x268 Saw Tooth
	1<<13|1<<11|53,  // 0x269 Saw Tooth
	1<<13|1<<11|50,  // 0x26A Saw Tooth
	1<<13|1<<11|48,  // 0x26B Saw Tooth
	1<<13|1<<11|45,  // 0x26C Saw Tooth
	1<<13|1<<11|42,  // 0x26D Saw Tooth
	1<<13|1<<11|40,  // 0x26E Saw Tooth
	1<<13|1<<11|38,  // 0x26F Saw Tooth
	1<<13|1<<11|36,  // 0x270 Saw Tooth
	1<<13|1<<11|34,  // 0x271 Saw Tooth
	1<<13|1<<11|32,  // 0x272 Saw Tooth
	1<<13|1<<11|30,  // 0x273 Saw Tooth
	1<<13|1<<11|28,  // 0x274 Saw Tooth
	1<<13|1<<11|26,  // 0x275 Saw Tooth
	1<<13|1<<11|25,  // 0x276 Saw Tooth
	1<<13|1<<11|24,  // 0x277 Saw Tooth
	1<<13|1<<11|22,  // 0x278 Saw Tooth
	1<<13|1<<11|21,  // 0x279 Saw Tooth
	1<<13|1<<11|20,  // 0x27A Saw Tooth
	1<<13|1<<11|19,  // 0x27B Saw Tooth
	1<<13|1<<11|18,  // 0x27C Saw Tooth
	1<<13|1<<11|17,  // 0x27D Saw Tooth
	1<<13|1<<11|16,  // 0x27E Saw Tooth
	1<<13|1<<11|15,  // 0x27F Saw Tooth

	2<<13|1<<11|576, // 0x280 Square
	2<<13|1<<11|543, // 0x281 Square
	2<<13|1<<11|513, // 0x282 Square
	2<<13|1<<11|484, // 0x283 Square
	2<<13|1<<11|457, // 0x284 Square
	2<<13|1<<11|431, // 0x285 Square
	2<<13|1<<11|407, // 0x286 Square
	2<<13|1<<11|384, // 0x287 Square
	2<<13|1<<11|362, // 0x288 Square
	2<<13|1<<11|342, // 0x289 Square
	2<<13|1<<11|323, // 0x28A Square
	2<<13|1<<11|305, // 0x28B Square
	2<<13|1<<11|288, // 0x28C Square
	2<<13|1<<11|272, // 0x28D Square
	2<<13|1<<11|256, // 0x28E Square
	2<<13|1<<11|242, // 0x28F Square
	2<<13|1<<11|228, // 0x290 Square
	2<<13|1<<11|215, // 0x291 Square
	2<<13|1<<11|203, // 0x292 Square
	2<<13|1<<11|192, // 0x293 Square
	2<<13|1<<11|181, // 0x294 Square
	2<<13|1<<11|171, // 0x295 Square
	2<<13|1<<11|161, // 0x296 Square
	2<<13|1<<11|152, // 0x297 Square
	2<<13|1<<11|144, // 0x298 Square
	2<<13|1<<11|135, // 0x299 Square
	2<<13|1<<11|128, // 0x29A Square
	2<<13|1<<11|121, // 0x29B Square
	2<<13|1<<11|114, // 0x29C Square
	2<<13|1<<11|107, // 0x29D Square
	2<<13|1<<11|101, // 0x29E Square
	2<<13|1<<11|96,  // 0x29F Square
	2<<13|1<<11|90,  // 0x2A0 Square
	2<<13|1<<11|85,  // 0x2A1 Square
	2<<13|1<<11|80,  // 0x2A2 Square
	2<<13|1<<11|76,  // 0x2A3 Square
	2<<13|1<<11|72,  // 0x2A4 Square
	2<<13|1<<11|68,  // 0x2A5 Square
	2<<13|1<<11|64,  // 0x2A6 Square
	2<<13|1<<11|60,  // 0x2A7 Square
	2<<13|1<<11|57,  // 0x2A8 Square
	2<<13|1<<11|53,  // 0x2A9 Square
	2<<13|1<<11|50,  // 0x2AA Square
	2<<13|1<<11|48,  // 0x2AB Square
	2<<13|1<<11|45,  // 0x2AC Square
	2<<13|1<<11|42,  // 0x2AD Square
	2<<13|1<<11|40,  // 0x2AE Square
	2<<13|1<<11|38,  // 0x2AF Square
	2<<13|1<<11|36,  // 0x2B0 Square
	2<<13|1<<11|34,  // 0x2B1 Square
	2<<13|1<<11|32,  // 0x2B2 Square
	2<<13|1<<11|30,  // 0x2B3 Square
	2<<13|1<<11|28,  // 0x2B4 Square
	2<<13|1<<11|26,  // 0x2B5 Square
	2<<13|1<<11|25,  // 0x2B6 Square
	2<<13|1<<11|24,  // 0x2B7 Square
	2<<13|1<<11|22,  // 0x2B8 Square
	2<<13|1<<11|21,  // 0x2B9 Square
	2<<13|1<<11|20,  // 0x2BA Square
	2<<13|1<<11|19,  // 0x2BB Square
	2<<13|1<<11|18,  // 0x2BC Square
	2<<13|1<<11|17,  // 0x2BD Square
	2<<13|1<<11|16,  // 0x2BE Square
	2<<13|1<<11|15,  // 0x2BF Square

	/* High Tones Medium */

	2<<13|1<<11|14,  // 0x2C0 Square
	2<<13|1<<11|13,  // 0x2C1 Square
	2<<13|1<<11|12,  // 0x2C2 Square
	2<<13|1<<11|12,  // 0x2C3 Square
	2<<13|1<<11|11,  // 0x2C4 Square
	2<<13|1<<11|10,  // 0x2C5 Square
	2<<13|1<<11|10,  // 0x2C6 Square
	2<<13|1<<11|9,   // 0x2C7 Square
	2<<13|1<<11|9,   // 0x2C8 Square
	2<<13|1<<11|8,   // 0x2C9 Square
	2<<13|1<<11|8,   // 0x2CA Square
	2<<13|1<<11|7,   // 0x2CB Square

	/**
	 * Assume Fixed Length as 640, Sample Rate 31680Hz Divided by 48 and Minus 20, Not to Slide Beat by DMA Process
	 * The value on the right side is stride.
	 */
	6<<13|1<<11|108, // 0x2CC Noise
	6<<13|1<<11|106, // 0x2CD Noise
	6<<13|1<<11|104, // 0x2CE Noise
	6<<13|1<<11|102, // 0x2CF Noise
	6<<13|1<<11|100, // 0x2D0 Noise
	6<<13|1<<11|98,  // 0x2D1 Noise
	6<<13|1<<11|96,  // 0x2D2 Noise
	6<<13|1<<11|94,  // 0x2D3 Noise
	6<<13|1<<11|92,  // 0x2D4 Noise
	6<<13|1<<11|90,  // 0x2D5 Noise
	6<<13|1<<11|88,  // 0x2D6 Noise
	6<<13|1<<11|86,  // 0x2D7 Noise
	6<<13|1<<11|84,  // 0x2D8 Noise
	6<<13|1<<11|82,  // 0x2D9 Noise
	6<<13|1<<11|80,  // 0x2DA Noise
	6<<13|1<<11|78,  // 0x2DB Noise
	6<<13|1<<11|76,  // 0x2DC Noise
	6<<13|1<<11|74,  // 0x2DD Noise
	6<<13|1<<11|72,  // 0x2DE Noise
	6<<13|1<<11|70,  // 0x2DF Noise
	6<<13|1<<11|68,  // 0x2E0 Noise
	6<<13|1<<11|66,  // 0x2E1 Noise
	6<<13|1<<11|64,  // 0x2E2 Noise
	6<<13|1<<11|62,  // 0x2E3 Noise
	6<<13|1<<11|60,  // 0x2E4 Noise
	6<<13|1<<11|58,  // 0x2E5 Noise
	6<<13|1<<11|56,  // 0x2E6 Noise
	6<<13|1<<11|54,  // 0x2E7 Noise
	6<<13|1<<11|52,  // 0x2E8 Noise
	6<<13|1<<11|50,  // 0x2E9 Noise
	6<<13|1<<11|48,  // 0x2EA Noise
	6<<13|1<<11|46,  // 0x2EB Noise
	6<<13|1<<11|44,  // 0x2EC Noise
	6<<13|1<<11|42,  // 0x2ED Noise
	6<<13|1<<11|40,  // 0x2EE Noise
	6<<13|1<<11|38,  // 0x2EF Noise
	6<<13|1<<11|36,  // 0x2F0 Noise
	6<<13|1<<11|34,  // 0x2F1 Noise
	6<<13|1<<11|32,  // 0x2F2 Noise
	6<<13|1<<11|30,  // 0x2F3 Noise
	6<<13|1<<11|28,  // 0x2F4 Noise
	6<<13|1<<11|26,  // 0x2F5 Noise
	6<<13|1<<11|24,  // 0x2F6 Noise
	6<<13|1<<11|22,  // 0x2F7 Noise
	6<<13|1<<11|20,  // 0x2F8 Noise
	6<<13|1<<11|18,  // 0x2F9 Noise
	6<<13|1<<11|16,  // 0x2FA Noise
	6<<13|1<<11|14,  // 0x2FB Noise
	6<<13|1<<11|12,  // 0x2FC Noise
	6<<13|1<<11|10,  // 0x2FD Noise
	6<<13|1<<11|8,   // 0x2FE Noise
	6<<13|1<<11|6,   // 0x2FF Noise

	3<<13|1<<11|576, // 0x300 Triangle
	3<<13|1<<11|543, // 0x301 Triangle
	3<<13|1<<11|513, // 0x302 Triangle
	3<<13|1<<11|484, // 0x303 Triangle
	3<<13|1<<11|457, // 0x304 Triangle
	3<<13|1<<11|431, // 0x305 Triangle
	3<<13|1<<11|407, // 0x306 Triangle
	3<<13|1<<11|384, // 0x307 Triangle
	3<<13|1<<11|362, // 0x308 Triangle
	3<<13|1<<11|342, // 0x309 Triangle
	3<<13|1<<11|323, // 0x30A Triangle
	3<<13|1<<11|305, // 0x30B Triangle
	3<<13|1<<11|288, // 0x30C Triangle
	3<<13|1<<11|272, // 0x30D Triangle
	3<<13|1<<11|256, // 0x30E Triangle
	3<<13|1<<11|242, // 0x30F Triangle
	3<<13|1<<11|228, // 0x310 Triangle
	3<<13|1<<11|215, // 0x311 Triangle
	3<<13|1<<11|203, // 0x312 Triangle
	3<<13|1<<11|192, // 0x313 Triangle
	3<<13|1<<11|181, // 0x314 Triangle
	3<<13|1<<11|171, // 0x315 Triangle
	3<<13|1<<11|161, // 0x316 Triangle
	3<<13|1<<11|152, // 0x317 Triangle
	3<<13|1<<11|144, // 0x318 Triangle
	3<<13|1<<11|135, // 0x319 Triangle
	3<<13|1<<11|128, // 0x31A Triangle
	3<<13|1<<11|121, // 0x31B Triangle
	3<<13|1<<11|114, // 0x31C Triangle
	3<<13|1<<11|107, // 0x31D Triangle
	3<<13|1<<11|101, // 0x31E Triangle
	3<<13|1<<11|96,  // 0x31F Triangle
	3<<13|1<<11|90,  // 0x320 Triangle
	3<<13|1<<11|85,  // 0x321 Triangle
	3<<13|1<<11|80,  // 0x322 Triangle
	3<<13|1<<11|76,  // 0x323 Triangle
	3<<13|1<<11|72,  // 0x324 Triangle
	3<<13|1<<11|68,  // 0x325 Triangle
	3<<13|1<<11|64,  // 0x326 Triangle
	3<<13|1<<11|60,  // 0x327 Triangle
	3<<13|1<<11|57,  // 0x328 Triangle
	3<<13|1<<11|53,  // 0x329 Triangle
	3<<13|1<<11|50,  // 0x32A Triangle
	3<<13|1<<11|48,  // 0x32B Triangle
	3<<13|1<<11|45,  // 0x32C Triangle
	3<<13|1<<11|42,  // 0x32D Triangle
	3<<13|1<<11|40,  // 0x32E Triangle
	3<<13|1<<11|38,  // 0x32F Triangle
	3<<13|1<<11|36,  // 0x330 Triangle
	3<<13|1<<11|34,  // 0x331 Triangle
	3<<13|1<<11|32,  // 0x332 Triangle
	3<<13|1<<11|30,  // 0x333 Triangle
	3<<13|1<<11|28,  // 0x334 Triangle
	3<<13|1<<11|26,  // 0x335 Triangle
	3<<13|1<<11|25,  // 0x336 Triangle
	3<<13|1<<11|24,  // 0x337 Triangle
	3<<13|1<<11|22,  // 0x338 Triangle
	3<<13|1<<11|21,  // 0x339 Triangle
	3<<13|1<<11|20,  // 0x33A Triangle
	3<<13|1<<11|19,  // 0x33B Triangle
	3<<13|1<<11|18,  // 0x33C Triangle
	3<<13|1<<11|17,  // 0x33D Triangle
	3<<13|1<<11|16,  // 0x33E Triangle
	3<<13|1<<11|15,  // 0x33F Triangle

	4<<13|1<<11|576, // 0x340 Distortion
	4<<13|1<<11|543, // 0x341 Distortion
	4<<13|1<<11|513, // 0x342 Distortion
	4<<13|1<<11|484, // 0x343 Distortion
	4<<13|1<<11|457, // 0x344 Distortion
	4<<13|1<<11|431, // 0x345 Distortion
	4<<13|1<<11|407, // 0x346 Distortion
	4<<13|1<<11|384, // 0x347 Distortion
	4<<13|1<<11|362, // 0x348 Distortion
	4<<13|1<<11|342, // 0x349 Distortion
	4<<13|1<<11|323, // 0x34A Distortion
	4<<13|1<<11|305, // 0x34B Distortion
	4<<13|1<<11|288, // 0x34C Distortion
	4<<13|1<<11|272, // 0x34D Distortion
	4<<13|1<<11|256, // 0x34E Distortion
	4<<13|1<<11|242, // 0x34F Distortion
	4<<13|1<<11|228, // 0x350 Distortion
	4<<13|1<<11|215, // 0x351 Distortion
	4<<13|1<<11|203, // 0x352 Distortion
	4<<13|1<<11|192, // 0x353 Distortion
	4<<13|1<<11|181, // 0x354 Distortion
	4<<13|1<<11|171, // 0x355 Distortion
	4<<13|1<<11|161, // 0x356 Distortion
	4<<13|1<<11|152, // 0x357 Distortion
	4<<13|1<<11|144, // 0x358 Distortion
	4<<13|1<<11|135, // 0x359 Distortion
	4<<13|1<<11|128, // 0x35A Distortion
	4<<13|1<<11|121, // 0x35B Distortion
	4<<13|1<<11|114, // 0x35C Distortion
	4<<13|1<<11|107, // 0x35D Distortion
	4<<13|1<<11|101, // 0x35E Distortion
	4<<13|1<<11|96,  // 0x35F Distortion
	4<<13|1<<11|90,  // 0x360 Distortion
	4<<13|1<<11|85,  // 0x361 Distortion
	4<<13|1<<11|80,  // 0x362 Distortion
	4<<13|1<<11|76,  // 0x363 Distortion
	4<<13|1<<11|72,  // 0x364 Distortion
	4<<13|1<<11|68,  // 0x365 Distortion
	4<<13|1<<11|64,  // 0x366 Distortion
	4<<13|1<<11|60,  // 0x367 Distortion
	4<<13|1<<11|57,  // 0x368 Distortion
	4<<13|1<<11|53,  // 0x369 Distortion
	4<<13|1<<11|50,  // 0x36A Distortion
	4<<13|1<<11|48,  // 0x36B Distortion
	4<<13|1<<11|45,  // 0x36C Distortion
	4<<13|1<<11|42,  // 0x36D Distortion
	4<<13|1<<11|40,  // 0x36E Distortion
	4<<13|1<<11|38,  // 0x36F Distortion
	4<<13|1<<11|36,  // 0x370 Distortion
	4<<13|1<<11|34,  // 0x371 Distortion
	4<<13|1<<11|32,  // 0x372 Distortion
	4<<13|1<<11|30,  // 0x373 Distortion
	4<<13|1<<11|28,  // 0x374 Distortion
	4<<13|1<<11|26,  // 0x375 Distortion
	4<<13|1<<11|25,  // 0x376 Distortion
	4<<13|1<<11|24,  // 0x377 Distortion
	4<<13|1<<11|22,  // 0x378 Distortion
	4<<13|1<<11|21,  // 0x379 Distortion
	4<<13|1<<11|20,  // 0x37A Distortion
	4<<13|1<<11|19,  // 0x37B Distortion
	4<<13|1<<11|18,  // 0x37C Distortion
	4<<13|1<<11|17,  // 0x37D Distortion
	4<<13|1<<11|16,  // 0x37E Distortion
	4<<13|1<<11|15,  // 0x37F Distortion

	_64(7<<13|1<<11|2)
	_64(7<<13|1<<11|2)

	/* Volume Small */

	0<<13|2<<11|576, // 0x400 Sine
	0<<13|2<<11|543, // 0x401 Sine
	0<<13|2<<11|513, // 0x402 Sine
	0<<13|2<<11|484, // 0x403 Sine
	0<<13|2<<11|457, // 0x404 Sine
	0<<13|2<<11|431, // 0x405 Sine
	0<<13|2<<11|407, // 0x406 Sine
	0<<13|2<<11|384, // 0x407 Sine
	0<<13|2<<11|362, // 0x408 Sine
	0<<13|2<<11|342, // 0x409 Sine
	0<<13|2<<11|323, // 0x40A Sine
	0<<13|2<<11|305, // 0x40B Sine
	0<<13|2<<11|288, // 0x40C Sine
	0<<13|2<<11|272, // 0x40D Sine
	0<<13|2<<11|256, // 0x40E Sine
	0<<13|2<<11|242, // 0x40F Sine
	0<<13|2<<11|228, // 0x410 Sine
	0<<13|2<<11|215, // 0x411 Sine
	0<<13|2<<11|203, // 0x412 Sine
	0<<13|2<<11|192, // 0x413 Sine
	0<<13|2<<11|181, // 0x414 Sine
	0<<13|2<<11|171, // 0x415 Sine
	0<<13|2<<11|161, // 0x416 Sine
	0<<13|2<<11|152, // 0x417 Sine
	0<<13|2<<11|144, // 0x418 Sine
	0<<13|2<<11|135, // 0x419 Sine
	0<<13|2<<11|128, // 0x41A Sine
	0<<13|2<<11|121, // 0x41B Sine
	0<<13|2<<11|114, // 0x41C Sine
	0<<13|2<<11|107, // 0x41D Sine
	0<<13|2<<11|101, // 0x41E Sine
	0<<13|2<<11|96,  // 0x41F Sine
	0<<13|2<<11|90,  // 0x420 Sine
	0<<13|2<<11|85,  // 0x421 Sine
	0<<13|2<<11|80,  // 0x422 Sine
	0<<13|2<<11|76,  // 0x423 Sine
	0<<13|2<<11|72,  // 0x424 Sine
	0<<13|2<<11|68,  // 0x425 Sine
	0<<13|2<<11|64,  // 0x426 Sine
	0<<13|2<<11|60,  // 0x427 Sine
	0<<13|2<<11|57,  // 0x428 Sine
	0<<13|2<<11|53,  // 0x429 Sine
	0<<13|2<<11|50,  // 0x42A Sine
	0<<13|2<<11|48,  // 0x42B Sine
	0<<13|2<<11|45,  // 0x42C Sine
	0<<13|2<<11|42,  // 0x42D Sine
	0<<13|2<<11|40,  // 0x42E Sine
	0<<13|2<<11|38,  // 0x42F Sine
	0<<13|2<<11|36,  // 0x430 Sine
	0<<13|2<<11|34,  // 0x431 Sine
	0<<13|2<<11|32,  // 0x432 Sine
	0<<13|2<<11|30,  // 0x433 Sine
	0<<13|2<<11|28,  // 0x434 Sine
	0<<13|2<<11|26,  // 0x435 Sine
	0<<13|2<<11|25,  // 0x436 Sine
	0<<13|2<<11|24,  // 0x437 Sine
	0<<13|2<<11|22,  // 0x438 Sine
	0<<13|2<<11|21,  // 0x439 Sine
	0<<13|2<<11|20,  // 0x43A Sine
	0<<13|2<<11|19,  // 0x43B Sine
	0<<13|2<<11|18,  // 0x43C Sine
	0<<13|2<<11|17,  // 0x43D Sine
	0<<13|2<<11|16,  // 0x43E Sine
	0<<13|2<<11|15,  // 0x43F Sine

	1<<13|2<<11|576, // 0x440 Saw Tooth
	1<<13|2<<11|543, // 0x441 Saw Tooth
	1<<13|2<<11|513, // 0x442 Saw Tooth
	1<<13|2<<11|484, // 0x443 Saw Tooth
	1<<13|2<<11|457, // 0x444 Saw Tooth
	1<<13|2<<11|431, // 0x445 Saw Tooth
	1<<13|2<<11|407, // 0x446 Saw Tooth
	1<<13|2<<11|384, // 0x447 Saw Tooth
	1<<13|2<<11|362, // 0x448 Saw Tooth
	1<<13|2<<11|342, // 0x449 Saw Tooth
	1<<13|2<<11|323, // 0x44A Saw Tooth
	1<<13|2<<11|305, // 0x44B Saw Tooth
	1<<13|2<<11|288, // 0x44C Saw Tooth
	1<<13|2<<11|272, // 0x44D Saw Tooth
	1<<13|2<<11|256, // 0x44E Saw Tooth
	1<<13|2<<11|242, // 0x44F Saw Tooth
	1<<13|2<<11|228, // 0x450 Saw Tooth
	1<<13|2<<11|215, // 0x451 Saw Tooth
	1<<13|2<<11|203, // 0x452 Saw Tooth
	1<<13|2<<11|192, // 0x453 Saw Tooth
	1<<13|2<<11|181, // 0x454 Saw Tooth
	1<<13|2<<11|171, // 0x455 Saw Tooth
	1<<13|2<<11|161, // 0x456 Saw Tooth
	1<<13|2<<11|152, // 0x457 Saw Tooth
	1<<13|2<<11|144, // 0x458 Saw Tooth
	1<<13|2<<11|135, // 0x459 Saw Tooth
	1<<13|2<<11|128, // 0x45A Saw Tooth
	1<<13|2<<11|121, // 0x45B Saw Tooth
	1<<13|2<<11|114, // 0x45C Saw Tooth
	1<<13|2<<11|107, // 0x45D Saw Tooth
	1<<13|2<<11|101, // 0x45E Saw Tooth
	1<<13|2<<11|96,  // 0x45F Saw Tooth
	1<<13|2<<11|90,  // 0x460 Saw Tooth
	1<<13|2<<11|85,  // 0x461 Saw Tooth
	1<<13|2<<11|80,  // 0x462 Saw Tooth
	1<<13|2<<11|76,  // 0x463 Saw Tooth
	1<<13|2<<11|72,  // 0x464 Saw Tooth
	1<<13|2<<11|68,  // 0x465 Saw Tooth
	1<<13|2<<11|64,  // 0x466 Saw Tooth
	1<<13|2<<11|60,  // 0x467 Saw Tooth
	1<<13|2<<11|57,  // 0x468 Saw Tooth
	1<<13|2<<11|53,  // 0x469 Saw Tooth
	1<<13|2<<11|50,  // 0x46A Saw Tooth
	1<<13|2<<11|48,  // 0x46B Saw Tooth
	1<<13|2<<11|45,  // 0x46C Saw Tooth
	1<<13|2<<11|42,  // 0x46D Saw Tooth
	1<<13|2<<11|40,  // 0x46E Saw Tooth
	1<<13|2<<11|38,  // 0x46F Saw Tooth
	1<<13|2<<11|36,  // 0x470 Saw Tooth
	1<<13|2<<11|34,  // 0x471 Saw Tooth
	1<<13|2<<11|32,  // 0x472 Saw Tooth
	1<<13|2<<11|30,  // 0x473 Saw Tooth
	1<<13|2<<11|28,  // 0x474 Saw Tooth
	1<<13|2<<11|26,  // 0x475 Saw Tooth
	1<<13|2<<11|25,  // 0x476 Saw Tooth
	1<<13|2<<11|24,  // 0x477 Saw Tooth
	1<<13|2<<11|22,  // 0x478 Saw Tooth
	1<<13|2<<11|21,  // 0x479 Saw Tooth
	1<<13|2<<11|20,  // 0x47A Saw Tooth
	1<<13|2<<11|19,  // 0x47B Saw Tooth
	1<<13|2<<11|18,  // 0x47C Saw Tooth
	1<<13|2<<11|17,  // 0x47D Saw Tooth
	1<<13|2<<11|16,  // 0x47E Saw Tooth
	1<<13|2<<11|15,  // 0x47F Saw Tooth

	2<<13|2<<11|576, // 0x480 Square
	2<<13|2<<11|543, // 0x481 Square
	2<<13|2<<11|513, // 0x482 Square
	2<<13|2<<11|484, // 0x483 Square
	2<<13|2<<11|457, // 0x484 Square
	2<<13|2<<11|431, // 0x485 Square
	2<<13|2<<11|407, // 0x486 Square
	2<<13|2<<11|384, // 0x487 Square
	2<<13|2<<11|362, // 0x488 Square
	2<<13|2<<11|342, // 0x489 Square
	2<<13|2<<11|323, // 0x48A Square
	2<<13|2<<11|305, // 0x48B Square
	2<<13|2<<11|288, // 0x48C Square
	2<<13|2<<11|272, // 0x48D Square
	2<<13|2<<11|256, // 0x48E Square
	2<<13|2<<11|242, // 0x48F Square
	2<<13|2<<11|228, // 0x490 Square
	2<<13|2<<11|215, // 0x491 Square
	2<<13|2<<11|203, // 0x492 Square
	2<<13|2<<11|192, // 0x493 Square
	2<<13|2<<11|181, // 0x494 Square
	2<<13|2<<11|171, // 0x495 Square
	2<<13|2<<11|161, // 0x496 Square
	2<<13|2<<11|152, // 0x497 Square
	2<<13|2<<11|144, // 0x498 Square
	2<<13|2<<11|135, // 0x499 Square
	2<<13|2<<11|128, // 0x49A Square
	2<<13|2<<11|121, // 0x49B Square
	2<<13|2<<11|114, // 0x49C Square
	2<<13|2<<11|107, // 0x49D Square
	2<<13|2<<11|101, // 0x49E Square
	2<<13|2<<11|96,  // 0x49F Square
	2<<13|2<<11|90,  // 0x4A0 Square
	2<<13|2<<11|85,  // 0x4A1 Square
	2<<13|2<<11|80,  // 0x4A2 Square
	2<<13|2<<11|76,  // 0x4A3 Square
	2<<13|2<<11|72,  // 0x4A4 Square
	2<<13|2<<11|68,  // 0x4A5 Square
	2<<13|2<<11|64,  // 0x4A6 Square
	2<<13|2<<11|60,  // 0x4A7 Square
	2<<13|2<<11|57,  // 0x4A8 Square
	2<<13|2<<11|53,  // 0x4A9 Square
	2<<13|2<<11|50,  // 0x4AA Square
	2<<13|2<<11|48,  // 0x4AB Square
	2<<13|2<<11|45,  // 0x4AC Square
	2<<13|2<<11|42,  // 0x4AD Square
	2<<13|2<<11|40,  // 0x4AE Square
	2<<13|2<<11|38,  // 0x4AF Square
	2<<13|2<<11|36,  // 0x4B0 Square
	2<<13|2<<11|34,  // 0x4B1 Square
	2<<13|2<<11|32,  // 0x4B2 Square
	2<<13|2<<11|30,  // 0x4B3 Square
	2<<13|2<<11|28,  // 0x4B4 Square
	2<<13|2<<11|26,  // 0x4B5 Square
	2<<13|2<<11|25,  // 0x4B6 Square
	2<<13|2<<11|24,  // 0x4B7 Square
	2<<13|2<<11|22,  // 0x4B8 Square
	2<<13|2<<11|21,  // 0x4B9 Square
	2<<13|2<<11|20,  // 0x4BA Square
	2<<13|2<<11|19,  // 0x4BB Square
	2<<13|2<<11|18,  // 0x4BC Square
	2<<13|2<<11|17,  // 0x4BD Square
	2<<13|2<<11|16,  // 0x4BE Square
	2<<13|2<<11|15,  // 0x4BF Square

	/* High Tones Small */

	2<<13|2<<11|14,  // 0x4C0 Square
	2<<13|2<<11|13,  // 0x4C1 Square
	2<<13|2<<11|12,  // 0x4C2 Square
	2<<13|2<<11|12,  // 0x4C3 Square
	2<<13|2<<11|11,  // 0x4C4 Square
	2<<13|2<<11|10,  // 0x4C5 Square
	2<<13|2<<11|10,  // 0x4C6 Square
	2<<13|2<<11|9,   // 0x4C7 Square
	2<<13|2<<11|9,   // 0x4C8 Square
	2<<13|2<<11|8,   // 0x4C9 Square
	2<<13|2<<11|8,   // 0x4CA Square
	2<<13|2<<11|7,   // 0x4CB Square

	/**
	 * Assume Fixed Length as 640, Sample Rate 31680Hz Divided by 48 and Minus 20, Not to Slide Beat by DMA Process
	 * The value on the right side is stride.
	 */
	6<<13|2<<11|108, // 0x4CC Noise
	6<<13|2<<11|106, // 0x4CD Noise
	6<<13|2<<11|104, // 0x4CE Noise
	6<<13|2<<11|102, // 0x4CF Noise
	6<<13|2<<11|100, // 0x4D0 Noise
	6<<13|2<<11|98,  // 0x4D1 Noise
	6<<13|2<<11|96,  // 0x4D2 Noise
	6<<13|2<<11|94,  // 0x4D3 Noise
	6<<13|2<<11|92,  // 0x4D4 Noise
	6<<13|2<<11|90,  // 0x4D5 Noise
	6<<13|2<<11|88,  // 0x4D6 Noise
	6<<13|2<<11|86,  // 0x4D7 Noise
	6<<13|2<<11|84,  // 0x4D8 Noise
	6<<13|2<<11|82,  // 0x4D9 Noise
	6<<13|2<<11|80,  // 0x4DA Noise
	6<<13|2<<11|78,  // 0x4DB Noise
	6<<13|2<<11|76,  // 0x4DC Noise
	6<<13|2<<11|74,  // 0x4DD Noise
	6<<13|2<<11|72,  // 0x4DE Noise
	6<<13|2<<11|70,  // 0x4DF Noise
	6<<13|2<<11|68,  // 0x4E0 Noise
	6<<13|2<<11|66,  // 0x4E1 Noise
	6<<13|2<<11|64,  // 0x4E2 Noise
	6<<13|2<<11|62,  // 0x4E3 Noise
	6<<13|2<<11|60,  // 0x4E4 Noise
	6<<13|2<<11|58,  // 0x4E5 Noise
	6<<13|2<<11|56,  // 0x4E6 Noise
	6<<13|2<<11|54,  // 0x4E7 Noise
	6<<13|2<<11|52,  // 0x4E8 Noise
	6<<13|2<<11|50,  // 0x4E9 Noise
	6<<13|2<<11|48,  // 0x4EA Noise
	6<<13|2<<11|46,  // 0x4EB Noise
	6<<13|2<<11|44,  // 0x4EC Noise
	6<<13|2<<11|42,  // 0x4ED Noise
	6<<13|2<<11|40,  // 0x4EE Noise
	6<<13|2<<11|38,  // 0x4EF Noise
	6<<13|2<<11|36,  // 0x4F0 Noise
	6<<13|2<<11|34,  // 0x4F1 Noise
	6<<13|2<<11|32,  // 0x4F2 Noise
	6<<13|2<<11|30,  // 0x4F3 Noise
	6<<13|2<<11|28,  // 0x4F4 Noise
	6<<13|2<<11|26,  // 0x4F5 Noise
	6<<13|2<<11|24,  // 0x4F6 Noise
	6<<13|2<<11|22,  // 0x4F7 Noise
	6<<13|2<<11|20,  // 0x4F8 Noise
	6<<13|2<<11|18,  // 0x4F9 Noise
	6<<13|2<<11|16,  // 0x4FA Noise
	6<<13|2<<11|14,  // 0x4FB Noise
	6<<13|2<<11|12,  // 0x4FC Noise
	6<<13|2<<11|10,  // 0x4FD Noise
	6<<13|2<<11|8,   // 0x4FE Noise
	6<<13|2<<11|6,   // 0x4FF Noise

	3<<13|2<<11|576, // 0x500 Triangle
	3<<13|2<<11|543, // 0x501 Triangle
	3<<13|2<<11|513, // 0x502 Triangle
	3<<13|2<<11|484, // 0x503 Triangle
	3<<13|2<<11|457, // 0x504 Triangle
	3<<13|2<<11|431, // 0x505 Triangle
	3<<13|2<<11|407, // 0x506 Triangle
	3<<13|2<<11|384, // 0x507 Triangle
	3<<13|2<<11|362, // 0x508 Triangle
	3<<13|2<<11|342, // 0x509 Triangle
	3<<13|2<<11|323, // 0x50A Triangle
	3<<13|2<<11|305, // 0x50B Triangle
	3<<13|2<<11|288, // 0x50C Triangle
	3<<13|2<<11|272, // 0x50D Triangle
	3<<13|2<<11|256, // 0x50E Triangle
	3<<13|2<<11|242, // 0x50F Triangle
	3<<13|2<<11|228, // 0x510 Triangle
	3<<13|2<<11|215, // 0x511 Triangle
	3<<13|2<<11|203, // 0x512 Triangle
	3<<13|2<<11|192, // 0x513 Triangle
	3<<13|2<<11|181, // 0x514 Triangle
	3<<13|2<<11|171, // 0x515 Triangle
	3<<13|2<<11|161, // 0x516 Triangle
	3<<13|2<<11|152, // 0x517 Triangle
	3<<13|2<<11|144, // 0x518 Triangle
	3<<13|2<<11|135, // 0x519 Triangle
	3<<13|2<<11|128, // 0x51A Triangle
	3<<13|2<<11|121, // 0x51B Triangle
	3<<13|2<<11|114, // 0x51C Triangle
	3<<13|2<<11|107, // 0x51D Triangle
	3<<13|2<<11|101, // 0x51E Triangle
	3<<13|2<<11|96,  // 0x51F Triangle
	3<<13|2<<11|90,  // 0x520 Triangle
	3<<13|2<<11|85,  // 0x521 Triangle
	3<<13|2<<11|80,  // 0x522 Triangle
	3<<13|2<<11|76,  // 0x523 Triangle
	3<<13|2<<11|72,  // 0x524 Triangle
	3<<13|2<<11|68,  // 0x525 Triangle
	3<<13|2<<11|64,  // 0x526 Triangle
	3<<13|2<<11|60,  // 0x527 Triangle
	3<<13|2<<11|57,  // 0x528 Triangle
	3<<13|2<<11|53,  // 0x529 Triangle
	3<<13|2<<11|50,  // 0x52A Triangle
	3<<13|2<<11|48,  // 0x52B Triangle
	3<<13|2<<11|45,  // 0x52C Triangle
	3<<13|2<<11|42,  // 0x52D Triangle
	3<<13|2<<11|40,  // 0x52E Triangle
	3<<13|2<<11|38,  // 0x52F Triangle
	3<<13|2<<11|36,  // 0x530 Triangle
	3<<13|2<<11|34,  // 0x531 Triangle
	3<<13|2<<11|32,  // 0x532 Triangle
	3<<13|2<<11|30,  // 0x533 Triangle
	3<<13|2<<11|28,  // 0x534 Triangle
	3<<13|2<<11|26,  // 0x535 Triangle
	3<<13|2<<11|25,  // 0x536 Triangle
	3<<13|2<<11|24,  // 0x537 Triangle
	3<<13|2<<11|22,  // 0x538 Triangle
	3<<13|2<<11|21,  // 0x539 Triangle
	3<<13|2<<11|20,  // 0x53A Triangle
	3<<13|2<<11|19,  // 0x53B Triangle
	3<<13|2<<11|18,  // 0x53C Triangle
	3<<13|2<<11|17,  // 0x53D Triangle
	3<<13|2<<11|16,  // 0x53E Triangle
	3<<13|2<<11|15,  // 0x53F Triangle

	4<<13|2<<11|576, // 0x540 Distortion
	4<<13|2<<11|543, // 0x541 Distortion
	4<<13|2<<11|513, // 0x542 Distortion
	4<<13|2<<11|484, // 0x543 Distortion
	4<<13|2<<11|457, // 0x544 Distortion
	4<<13|2<<11|431, // 0x545 Distortion
	4<<13|2<<11|407, // 0x546 Distortion
	4<<13|2<<11|384, // 0x547 Distortion
	4<<13|2<<11|362, // 0x548 Distortion
	4<<13|2<<11|342, // 0x549 Distortion
	4<<13|2<<11|323, // 0x54A Distortion
	4<<13|2<<11|305, // 0x54B Distortion
	4<<13|2<<11|288, // 0x54C Distortion
	4<<13|2<<11|272, // 0x54D Distortion
	4<<13|2<<11|256, // 0x54E Distortion
	4<<13|2<<11|242, // 0x54F Distortion
	4<<13|2<<11|228, // 0x550 Distortion
	4<<13|2<<11|215, // 0x551 Distortion
	4<<13|2<<11|203, // 0x552 Distortion
	4<<13|2<<11|192, // 0x553 Distortion
	4<<13|2<<11|181, // 0x554 Distortion
	4<<13|2<<11|171, // 0x555 Distortion
	4<<13|2<<11|161, // 0x556 Distortion
	4<<13|2<<11|152, // 0x557 Distortion
	4<<13|2<<11|144, // 0x558 Distortion
	4<<13|2<<11|135, // 0x559 Distortion
	4<<13|2<<11|128, // 0x55A Distortion
	4<<13|2<<11|121, // 0x55B Distortion
	4<<13|2<<11|114, // 0x55C Distortion
	4<<13|2<<11|107, // 0x55D Distortion
	4<<13|2<<11|101, // 0x55E Distortion
	4<<13|2<<11|96,  // 0x55F Distortion
	4<<13|2<<11|90,  // 0x560 Distortion
	4<<13|2<<11|85,  // 0x561 Distortion
	4<<13|2<<11|80,  // 0x562 Distortion
	4<<13|2<<11|76,  // 0x563 Distortion
	4<<13|2<<11|72,  // 0x564 Distortion
	4<<13|2<<11|68,  // 0x565 Distortion
	4<<13|2<<11|64,  // 0x566 Distortion
	4<<13|2<<11|60,  // 0x567 Distortion
	4<<13|2<<11|57,  // 0x568 Distortion
	4<<13|2<<11|53,  // 0x569 Distortion
	4<<13|2<<11|50,  // 0x56A Distortion
	4<<13|2<<11|48,  // 0x56B Distortion
	4<<13|2<<11|45,  // 0x56C Distortion
	4<<13|2<<11|42,  // 0x56D Distortion
	4<<13|2<<11|40,  // 0x56E Distortion
	4<<13|2<<11|38,  // 0x56F Distortion
	4<<13|2<<11|36,  // 0x570 Distortion
	4<<13|2<<11|34,  // 0x571 Distortion
	4<<13|2<<11|32,  // 0x572 Distortion
	4<<13|2<<11|30,  // 0x573 Distortion
	4<<13|2<<11|28,  // 0x574 Distortion
	4<<13|2<<11|26,  // 0x575 Distortion
	4<<13|2<<11|25,  // 0x576 Distortion
	4<<13|2<<11|24,  // 0x577 Distortion
	4<<13|2<<11|22,  // 0x578 Distortion
	4<<13|2<<11|21,  // 0x579 Distortion
	4<<13|2<<11|20,  // 0x57A Distortion
	4<<13|2<<11|19,  // 0x57B Distortion
	4<<13|2<<11|18,  // 0x57C Distortion
	4<<13|2<<11|17,  // 0x57D Distortion
	4<<13|2<<11|16,  // 0x57E Distortion
	4<<13|2<<11|15,  // 0x57F Distortion

	_64(7<<13|2<<11|2)
	_64(7<<13|2<<11|2)

	/* Volume Tiny */

	0<<13|3<<11|576, // 0x600 Sine
	0<<13|3<<11|543, // 0x601 Sine
	0<<13|3<<11|513, // 0x602 Sine
	0<<13|3<<11|484, // 0x603 Sine
	0<<13|3<<11|457, // 0x604 Sine
	0<<13|3<<11|431, // 0x605 Sine
	0<<13|3<<11|407, // 0x606 Sine
	0<<13|3<<11|384, // 0x607 Sine
	0<<13|3<<11|362, // 0x608 Sine
	0<<13|3<<11|342, // 0x609 Sine
	0<<13|3<<11|323, // 0x60A Sine
	0<<13|3<<11|305, // 0x60B Sine
	0<<13|3<<11|288, // 0x60C Sine
	0<<13|3<<11|272, // 0x60D Sine
	0<<13|3<<11|256, // 0x60E Sine
	0<<13|3<<11|242, // 0x60F Sine
	0<<13|3<<11|228, // 0x610 Sine
	0<<13|3<<11|215, // 0x611 Sine
	0<<13|3<<11|203, // 0x612 Sine
	0<<13|3<<11|192, // 0x613 Sine
	0<<13|3<<11|181, // 0x614 Sine
	0<<13|3<<11|171, // 0x615 Sine
	0<<13|3<<11|161, // 0x616 Sine
	0<<13|3<<11|152, // 0x617 Sine
	0<<13|3<<11|144, // 0x618 Sine
	0<<13|3<<11|135, // 0x619 Sine
	0<<13|3<<11|128, // 0x61A Sine
	0<<13|3<<11|121, // 0x61B Sine
	0<<13|3<<11|114, // 0x61C Sine
	0<<13|3<<11|107, // 0x61D Sine
	0<<13|3<<11|101, // 0x61E Sine
	0<<13|3<<11|96,  // 0x61F Sine
	0<<13|3<<11|90,  // 0x620 Sine
	0<<13|3<<11|85,  // 0x621 Sine
	0<<13|3<<11|80,  // 0x622 Sine
	0<<13|3<<11|76,  // 0x623 Sine
	0<<13|3<<11|72,  // 0x624 Sine
	0<<13|3<<11|68,  // 0x625 Sine
	0<<13|3<<11|64,  // 0x626 Sine
	0<<13|3<<11|60,  // 0x627 Sine
	0<<13|3<<11|57,  // 0x628 Sine
	0<<13|3<<11|53,  // 0x629 Sine
	0<<13|3<<11|50,  // 0x62A Sine
	0<<13|3<<11|48,  // 0x62B Sine
	0<<13|3<<11|45,  // 0x62C Sine
	0<<13|3<<11|42,  // 0x62D Sine
	0<<13|3<<11|40,  // 0x62E Sine
	0<<13|3<<11|38,  // 0x62F Sine
	0<<13|3<<11|36,  // 0x630 Sine
	0<<13|3<<11|34,  // 0x631 Sine
	0<<13|3<<11|32,  // 0x632 Sine
	0<<13|3<<11|30,  // 0x633 Sine
	0<<13|3<<11|28,  // 0x634 Sine
	0<<13|3<<11|26,  // 0x635 Sine
	0<<13|3<<11|25,  // 0x636 Sine
	0<<13|3<<11|24,  // 0x637 Sine
	0<<13|3<<11|22,  // 0x638 Sine
	0<<13|3<<11|21,  // 0x639 Sine
	0<<13|3<<11|20,  // 0x63A Sine
	0<<13|3<<11|19,  // 0x63B Sine
	0<<13|3<<11|18,  // 0x63C Sine
	0<<13|3<<11|17,  // 0x63D Sine
	0<<13|3<<11|16,  // 0x63E Sine
	0<<13|3<<11|15,  // 0x63F Sine

	1<<13|3<<11|576, // 0x640 Saw Tooth
	1<<13|3<<11|543, // 0x641 Saw Tooth
	1<<13|3<<11|513, // 0x642 Saw Tooth
	1<<13|3<<11|484, // 0x643 Saw Tooth
	1<<13|3<<11|457, // 0x644 Saw Tooth
	1<<13|3<<11|431, // 0x645 Saw Tooth
	1<<13|3<<11|407, // 0x646 Saw Tooth
	1<<13|3<<11|384, // 0x647 Saw Tooth
	1<<13|3<<11|362, // 0x648 Saw Tooth
	1<<13|3<<11|342, // 0x649 Saw Tooth
	1<<13|3<<11|323, // 0x64A Saw Tooth
	1<<13|3<<11|305, // 0x64B Saw Tooth
	1<<13|3<<11|288, // 0x64C Saw Tooth
	1<<13|3<<11|272, // 0x64D Saw Tooth
	1<<13|3<<11|256, // 0x64E Saw Tooth
	1<<13|3<<11|242, // 0x64F Saw Tooth
	1<<13|3<<11|228, // 0x650 Saw Tooth
	1<<13|3<<11|215, // 0x651 Saw Tooth
	1<<13|3<<11|203, // 0x652 Saw Tooth
	1<<13|3<<11|192, // 0x653 Saw Tooth
	1<<13|3<<11|181, // 0x654 Saw Tooth
	1<<13|3<<11|171, // 0x655 Saw Tooth
	1<<13|3<<11|161, // 0x656 Saw Tooth
	1<<13|3<<11|152, // 0x657 Saw Tooth
	1<<13|3<<11|144, // 0x658 Saw Tooth
	1<<13|3<<11|135, // 0x659 Saw Tooth
	1<<13|3<<11|128, // 0x65A Saw Tooth
	1<<13|3<<11|121, // 0x65B Saw Tooth
	1<<13|3<<11|114, // 0x65C Saw Tooth
	1<<13|3<<11|107, // 0x65D Saw Tooth
	1<<13|3<<11|101, // 0x65E Saw Tooth
	1<<13|3<<11|96,  // 0x65F Saw Tooth
	1<<13|3<<11|90,  // 0x660 Saw Tooth
	1<<13|3<<11|85,  // 0x661 Saw Tooth
	1<<13|3<<11|80,  // 0x662 Saw Tooth
	1<<13|3<<11|76,  // 0x663 Saw Tooth
	1<<13|3<<11|72,  // 0x664 Saw Tooth
	1<<13|3<<11|68,  // 0x665 Saw Tooth
	1<<13|3<<11|64,  // 0x666 Saw Tooth
	1<<13|3<<11|60,  // 0x667 Saw Tooth
	1<<13|3<<11|57,  // 0x668 Saw Tooth
	1<<13|3<<11|53,  // 0x669 Saw Tooth
	1<<13|3<<11|50,  // 0x66A Saw Tooth
	1<<13|3<<11|48,  // 0x66B Saw Tooth
	1<<13|3<<11|45,  // 0x66C Saw Tooth
	1<<13|3<<11|42,  // 0x66D Saw Tooth
	1<<13|3<<11|40,  // 0x66E Saw Tooth
	1<<13|3<<11|38,  // 0x66F Saw Tooth
	1<<13|3<<11|36,  // 0x670 Saw Tooth
	1<<13|3<<11|34,  // 0x671 Saw Tooth
	1<<13|3<<11|32,  // 0x672 Saw Tooth
	1<<13|3<<11|30,  // 0x673 Saw Tooth
	1<<13|3<<11|28,  // 0x674 Saw Tooth
	1<<13|3<<11|26,  // 0x675 Saw Tooth
	1<<13|3<<11|25,  // 0x676 Saw Tooth
	1<<13|3<<11|24,  // 0x677 Saw Tooth
	1<<13|3<<11|22,  // 0x678 Saw Tooth
	1<<13|3<<11|21,  // 0x679 Saw Tooth
	1<<13|3<<11|20,  // 0x67A Saw Tooth
	1<<13|3<<11|19,  // 0x67B Saw Tooth
	1<<13|3<<11|18,  // 0x67C Saw Tooth
	1<<13|3<<11|17,  // 0x67D Saw Tooth
	1<<13|3<<11|16,  // 0x67E Saw Tooth
	1<<13|3<<11|15,  // 0x67F Saw Tooth

	2<<13|3<<11|576, // 0x680 Square
	2<<13|3<<11|543, // 0x681 Square
	2<<13|3<<11|513, // 0x682 Square
	2<<13|3<<11|484, // 0x683 Square
	2<<13|3<<11|457, // 0x684 Square
	2<<13|3<<11|431, // 0x685 Square
	2<<13|3<<11|407, // 0x686 Square
	2<<13|3<<11|384, // 0x687 Square
	2<<13|3<<11|362, // 0x688 Square
	2<<13|3<<11|342, // 0x689 Square
	2<<13|3<<11|323, // 0x68A Square
	2<<13|3<<11|305, // 0x68B Square
	2<<13|3<<11|288, // 0x68C Square
	2<<13|3<<11|272, // 0x68D Square
	2<<13|3<<11|256, // 0x68E Square
	2<<13|3<<11|242, // 0x68F Square
	2<<13|3<<11|228, // 0x690 Square
	2<<13|3<<11|215, // 0x691 Square
	2<<13|3<<11|203, // 0x692 Square
	2<<13|3<<11|192, // 0x693 Square
	2<<13|3<<11|181, // 0x694 Square
	2<<13|3<<11|171, // 0x695 Square
	2<<13|3<<11|161, // 0x696 Square
	2<<13|3<<11|152, // 0x697 Square
	2<<13|3<<11|144, // 0x698 Square
	2<<13|3<<11|135, // 0x699 Square
	2<<13|3<<11|128, // 0x69A Square
	2<<13|3<<11|121, // 0x69B Square
	2<<13|3<<11|114, // 0x69C Square
	2<<13|3<<11|107, // 0x69D Square
	2<<13|3<<11|101, // 0x69E Square
	2<<13|3<<11|96,  // 0x69F Square
	2<<13|3<<11|90,  // 0x6A0 Square
	2<<13|3<<11|85,  // 0x6A1 Square
	2<<13|3<<11|80,  // 0x6A2 Square
	2<<13|3<<11|76,  // 0x6A3 Square
	2<<13|3<<11|72,  // 0x6A4 Square
	2<<13|3<<11|68,  // 0x6A5 Square
	2<<13|3<<11|64,  // 0x6A6 Square
	2<<13|3<<11|60,  // 0x6A7 Square
	2<<13|3<<11|57,  // 0x6A8 Square
	2<<13|3<<11|53,  // 0x6A9 Square
	2<<13|3<<11|50,  // 0x6AA Square
	2<<13|3<<11|48,  // 0x6AB Square
	2<<13|3<<11|45,  // 0x6AC Square
	2<<13|3<<11|42,  // 0x6AD Square
	2<<13|3<<11|40,  // 0x6AE Square
	2<<13|3<<11|38,  // 0x6AF Square
	2<<13|3<<11|36,  // 0x6B0 Square
	2<<13|3<<11|34,  // 0x6B1 Square
	2<<13|3<<11|32,  // 0x6B2 Square
	2<<13|3<<11|30,  // 0x6B3 Square
	2<<13|3<<11|28,  // 0x6B4 Square
	2<<13|3<<11|26,  // 0x6B5 Square
	2<<13|3<<11|25,  // 0x6B6 Square
	2<<13|3<<11|24,  // 0x6B7 Square
	2<<13|3<<11|22,  // 0x6B8 Square
	2<<13|3<<11|21,  // 0x6B9 Square
	2<<13|3<<11|20,  // 0x6BA Square
	2<<13|3<<11|19,  // 0x6BB Square
	2<<13|3<<11|18,  // 0x6BC Square
	2<<13|3<<11|17,  // 0x6BD Square
	2<<13|3<<11|16,  // 0x6BE Square
	2<<13|3<<11|15,  // 0x6BF Square

	/* High Tones Tiny */

	2<<13|3<<11|14,  // 0x6C0 Square
	2<<13|3<<11|13,  // 0x6C1 Square
	2<<13|3<<11|12,  // 0x6C2 Square
	2<<13|3<<11|12,  // 0x6C3 Square
	2<<13|3<<11|11,  // 0x6C4 Square
	2<<13|3<<11|10,  // 0x6C5 Square
	2<<13|3<<11|10,  // 0x6C6 Square
	2<<13|3<<11|9,   // 0x6C7 Square
	2<<13|3<<11|9,   // 0x6C8 Square
	2<<13|3<<11|8,   // 0x6C9 Square
	2<<13|3<<11|8,   // 0x6CA Square
	2<<13|3<<11|7,   // 0x6CB Square

	/**
	 * Assume Fixed Length as 640, Sample Rate 31680Hz Divided by 48 and Minus 20, Not to Slide Beat by DMA Process
	 * The value on the right side is stride.
	 */
	6<<13|3<<11|108, // 0x6CC Noise
	6<<13|3<<11|106, // 0x6CD Noise
	6<<13|3<<11|104, // 0x6CE Noise
	6<<13|3<<11|102, // 0x6CF Noise
	6<<13|3<<11|100, // 0x6D0 Noise
	6<<13|3<<11|98,  // 0x6D1 Noise
	6<<13|3<<11|96,  // 0x6D2 Noise
	6<<13|3<<11|94,  // 0x6D3 Noise
	6<<13|3<<11|92,  // 0x6D4 Noise
	6<<13|3<<11|90,  // 0x6D5 Noise
	6<<13|3<<11|88,  // 0x6D6 Noise
	6<<13|3<<11|86,  // 0x6D7 Noise
	6<<13|3<<11|84,  // 0x6D8 Noise
	6<<13|3<<11|82,  // 0x6D9 Noise
	6<<13|3<<11|80,  // 0x6DA Noise
	6<<13|3<<11|78,  // 0x6DB Noise
	6<<13|3<<11|76,  // 0x6DC Noise
	6<<13|3<<11|74,  // 0x6DD Noise
	6<<13|3<<11|72,  // 0x6DE Noise
	6<<13|3<<11|70,  // 0x6DF Noise
	6<<13|3<<11|68,  // 0x6E0 Noise
	6<<13|3<<11|66,  // 0x6E1 Noise
	6<<13|3<<11|64,  // 0x6E2 Noise
	6<<13|3<<11|62,  // 0x6E3 Noise
	6<<13|3<<11|60,  // 0x6E4 Noise
	6<<13|3<<11|58,  // 0x6E5 Noise
	6<<13|3<<11|56,  // 0x6E6 Noise
	6<<13|3<<11|54,  // 0x6E7 Noise
	6<<13|3<<11|52,  // 0x6E8 Noise
	6<<13|3<<11|50,  // 0x6E9 Noise
	6<<13|3<<11|48,  // 0x6EA Noise
	6<<13|3<<11|46,  // 0x6EB Noise
	6<<13|3<<11|44,  // 0x6EC Noise
	6<<13|3<<11|42,  // 0x6ED Noise
	6<<13|3<<11|40,  // 0x6EE Noise
	6<<13|3<<11|38,  // 0x6EF Noise
	6<<13|3<<11|36,  // 0x6F0 Noise
	6<<13|3<<11|34,  // 0x6F1 Noise
	6<<13|3<<11|32,  // 0x6F2 Noise
	6<<13|3<<11|30,  // 0x6F3 Noise
	6<<13|3<<11|28,  // 0x6F4 Noise
	6<<13|3<<11|26,  // 0x6F5 Noise
	6<<13|3<<11|24,  // 0x6F6 Noise
	6<<13|3<<11|22,  // 0x6F7 Noise
	6<<13|3<<11|20,  // 0x6F8 Noise
	6<<13|3<<11|18,  // 0x6F9 Noise
	6<<13|3<<11|16,  // 0x6FA Noise
	6<<13|3<<11|14,  // 0x6FB Noise
	6<<13|3<<11|12,  // 0x6FC Noise
	6<<13|3<<11|10,  // 0x6FD Noise
	6<<13|3<<11|8,   // 0x6FE Noise
	6<<13|3<<11|6,   // 0x6FF Noise

	3<<13|3<<11|576, // 0x700 Triangle
	3<<13|3<<11|543, // 0x701 Triangle
	3<<13|3<<11|513, // 0x702 Triangle
	3<<13|3<<11|484, // 0x703 Triangle
	3<<13|3<<11|457, // 0x704 Triangle
	3<<13|3<<11|431, // 0x705 Triangle
	3<<13|3<<11|407, // 0x706 Triangle
	3<<13|3<<11|384, // 0x707 Triangle
	3<<13|3<<11|362, // 0x708 Triangle
	3<<13|3<<11|342, // 0x709 Triangle
	3<<13|3<<11|323, // 0x70A Triangle
	3<<13|3<<11|305, // 0x70B Triangle
	3<<13|3<<11|288, // 0x70C Triangle
	3<<13|3<<11|272, // 0x70D Triangle
	3<<13|3<<11|256, // 0x70E Triangle
	3<<13|3<<11|242, // 0x70F Triangle
	3<<13|3<<11|228, // 0x710 Triangle
	3<<13|3<<11|215, // 0x711 Triangle
	3<<13|3<<11|203, // 0x712 Triangle
	3<<13|3<<11|192, // 0x713 Triangle
	3<<13|3<<11|181, // 0x714 Triangle
	3<<13|3<<11|171, // 0x715 Triangle
	3<<13|3<<11|161, // 0x716 Triangle
	3<<13|3<<11|152, // 0x717 Triangle
	3<<13|3<<11|144, // 0x718 Triangle
	3<<13|3<<11|135, // 0x719 Triangle
	3<<13|3<<11|128, // 0x71A Triangle
	3<<13|3<<11|121, // 0x71B Triangle
	3<<13|3<<11|114, // 0x71C Triangle
	3<<13|3<<11|107, // 0x71D Triangle
	3<<13|3<<11|101, // 0x71E Triangle
	3<<13|3<<11|96,  // 0x71F Triangle
	3<<13|3<<11|90,  // 0x720 Triangle
	3<<13|3<<11|85,  // 0x721 Triangle
	3<<13|3<<11|80,  // 0x722 Triangle
	3<<13|3<<11|76,  // 0x723 Triangle
	3<<13|3<<11|72,  // 0x724 Triangle
	3<<13|3<<11|68,  // 0x725 Triangle
	3<<13|3<<11|64,  // 0x726 Triangle
	3<<13|3<<11|60,  // 0x727 Triangle
	3<<13|3<<11|57,  // 0x728 Triangle
	3<<13|3<<11|53,  // 0x729 Triangle
	3<<13|3<<11|50,  // 0x72A Triangle
	3<<13|3<<11|48,  // 0x72B Triangle
	3<<13|3<<11|45,  // 0x72C Triangle
	3<<13|3<<11|42,  // 0x72D Triangle
	3<<13|3<<11|40,  // 0x72E Triangle
	3<<13|3<<11|38,  // 0x72F Triangle
	3<<13|3<<11|36,  // 0x730 Triangle
	3<<13|3<<11|34,  // 0x731 Triangle
	3<<13|3<<11|32,  // 0x732 Triangle
	3<<13|3<<11|30,  // 0x733 Triangle
	3<<13|3<<11|28,  // 0x734 Triangle
	3<<13|3<<11|26,  // 0x735 Triangle
	3<<13|3<<11|25,  // 0x736 Triangle
	3<<13|3<<11|24,  // 0x737 Triangle
	3<<13|3<<11|22,  // 0x738 Triangle
	3<<13|3<<11|21,  // 0x739 Triangle
	3<<13|3<<11|20,  // 0x73A Triangle
	3<<13|3<<11|19,  // 0x73B Triangle
	3<<13|3<<11|18,  // 0x73C Triangle
	3<<13|3<<11|17,  // 0x73D Triangle
	3<<13|3<<11|16,  // 0x73E Triangle
	3<<13|3<<11|15,  // 0x73F Triangle

	4<<13|3<<11|576, // 0x740 Distortion
	4<<13|3<<11|543, // 0x741 Distortion
	4<<13|3<<11|513, // 0x742 Distortion
	4<<13|3<<11|484, // 0x743 Distortion
	4<<13|3<<11|457, // 0x744 Distortion
	4<<13|3<<11|431, // 0x745 Distortion
	4<<13|3<<11|407, // 0x746 Distortion
	4<<13|3<<11|384, // 0x747 Distortion
	4<<13|3<<11|362, // 0x748 Distortion
	4<<13|3<<11|342, // 0x749 Distortion
	4<<13|3<<11|323, // 0x74A Distortion
	4<<13|3<<11|305, // 0x74B Distortion
	4<<13|3<<11|288, // 0x74C Distortion
	4<<13|3<<11|272, // 0x74D Distortion
	4<<13|3<<11|256, // 0x74E Distortion
	4<<13|3<<11|242, // 0x74F Distortion
	4<<13|3<<11|228, // 0x750 Distortion
	4<<13|3<<11|215, // 0x751 Distortion
	4<<13|3<<11|203, // 0x752 Distortion
	4<<13|3<<11|192, // 0x753 Distortion
	4<<13|3<<11|181, // 0x754 Distortion
	4<<13|3<<11|171, // 0x755 Distortion
	4<<13|3<<11|161, // 0x756 Distortion
	4<<13|3<<11|152, // 0x757 Distortion
	4<<13|3<<11|144, // 0x758 Distortion
	4<<13|3<<11|135, // 0x759 Distortion
	4<<13|3<<11|128, // 0x75A Distortion
	4<<13|3<<11|121, // 0x75B Distortion
	4<<13|3<<11|114, // 0x75C Distortion
	4<<13|3<<11|107, // 0x75D Distortion
	4<<13|3<<11|101, // 0x75E Distortion
	4<<13|3<<11|96,  // 0x75F Distortion
	4<<13|3<<11|90,  // 0x760 Distortion
	4<<13|3<<11|85,  // 0x761 Distortion
	4<<13|3<<11|80,  // 0x762 Distortion
	4<<13|3<<11|76,  // 0x763 Distortion
	4<<13|3<<11|72,  // 0x764 Distortion
	4<<13|3<<11|68,  // 0x765 Distortion
	4<<13|3<<11|64,  // 0x766 Distortion
	4<<13|3<<11|60,  // 0x767 Distortion
	4<<13|3<<11|57,  // 0x768 Distortion
	4<<13|3<<11|53,  // 0x769 Distortion
	4<<13|3<<11|50,  // 0x76A Distortion
	4<<13|3<<11|48,  // 0x76B Distortion
	4<<13|3<<11|45,  // 0x76C Distortion
	4<<13|3<<11|42,  // 0x76D Distortion
	4<<13|3<<11|40,  // 0x76E Distortion
	4<<13|3<<11|38,  // 0x76F Distortion
	4<<13|3<<11|36,  // 0x770 Distortion
	4<<13|3<<11|34,  // 0x771 Distortion
	4<<13|3<<11|32,  // 0x772 Distortion
	4<<13|3<<11|30,  // 0x773 Distortion
	4<<13|3<<11|28,  // 0x774 Distortion
	4<<13|3<<11|26,  // 0x775 Distortion
	4<<13|3<<11|25,  // 0x776 Distortion
	4<<13|3<<11|24,  // 0x777 Distortion
	4<<13|3<<11|22,  // 0x778 Distortion
	4<<13|3<<11|21,  // 0x779 Distortion
	4<<13|3<<11|20,  // 0x77A Distortion
	4<<13|3<<11|19,  // 0x77B Distortion
	4<<13|3<<11|18,  // 0x77C Distortion
	4<<13|3<<11|17,  // 0x77D Distortion
	4<<13|3<<11|16,  // 0x77E Distortion
	4<<13|3<<11|15,  // 0x77F Distortion

	_64(7<<13|3<<11|2)
	_64(7<<13|3<<11|2)

	/* Special Sounds */

	7<<13|0<<11|72,  // 0x800 Silence

	0                // End of Index
};
