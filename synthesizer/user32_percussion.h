/**
 * user32_percussion.h
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */

/**
 * If numbered, 1 is the standard volume and 2 is for ghost notes.
 */

/* Bass Drum */

synthe_precode pre_percussion_bassdrum1_mono[] = {
	_A1<<_FREQ|5000<<_MAG,_A1<<_FREQ|00000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_bassdrum1[] = {
	pre_percussion_bassdrum1_mono
};

synthe_precode pre_percussion_bassdrum2_mono[] = {
	_A1<<_FREQ|500<<_MAG,_A1<<_FREQ|00000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_bassdrum2[] = {
	pre_percussion_bassdrum2_mono
};

/* Hand Clap */

synthe_precode pre_percussion_handclap_mono[] = {
	_G5<<_FREQ|4000<<_MAG,_NOISE<<_FREQ|32000<<_MAG,150<<_BEAT,0<<_ATK|3<<_DCY|2<<_STN|97<<_RLS,
	_END
};

synthe_precode* pre_percussion_handclap[] = {
	pre_percussion_handclap_mono
};

/* Stick */

synthe_precode pre_percussion_sidestick_mono[] = {
	_G6<<_FREQ|4000<<_MAG,_NOISE<<_FREQ|32000<<_MAG,300<<_BEAT,0<<_ATK|3<<_DCY|2<<_STN|97<<_RLS,
	_END
};

synthe_precode* pre_percussion_sidestick[] = {
	pre_percussion_sidestick_mono
};

/* Snare */

synthe_precode pre_percussion_snare1_mono[] = {
	_A4<<_FREQ|2500<<_MAG,_NOISE<<_FREQ|8000<<_MAG,150<<_BEAT,1<<_ATK|20<<_DCY|30<<_STN|79<<_RLS,
	STS32_END
};

synthe_precode* pre_percussion_snare1[] = {
	pre_percussion_snare1_mono
};

synthe_precode pre_percussion_snare2_mono[] = {
	_A4<<_FREQ|60<<_MAG,_NOISE<<_FREQ|8000<<_MAG,150<<_BEAT,1<<_ATK|20<<_DCY|30<<_STN|79<<_RLS,
	STS32_END
};

synthe_precode* pre_percussion_snare2[] = {
	pre_percussion_snare2_mono
};

/* Tom */

synthe_precode pre_percussion_lowtom1_mono[] = {
	_A2<<_FREQ|4000<<_MAG,_A2<<_FREQ|00000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_lowtom1[] = {
	pre_percussion_lowtom1_mono
};

synthe_precode pre_percussion_lowtom2_mono[] = {
	_A2<<_FREQ|240<<_MAG,_A2<<_FREQ|00000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_lowtom2[] = {
	pre_percussion_lowtom2_mono
};

synthe_precode pre_percussion_midtom1_mono[] = {
	_B3<<_FREQ|3000<<_MAG,_B3<<_FREQ|00000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_midtom1[] = {
	pre_percussion_midtom1_mono
};

synthe_precode pre_percussion_midtom2_mono[] = {
	_B3<<_FREQ|180<<_MAG,_B3<<_FREQ|00000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_midtom2[] = {
	pre_percussion_midtom2_mono
};

synthe_precode pre_percussion_hightom1_mono[] = {
	_C5<<_FREQ|2500<<_MAG,_C5<<_FREQ|00000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_hightom1[] = {
	pre_percussion_hightom1_mono
};

synthe_precode pre_percussion_hightom2_mono[] = {
	_C5<<_FREQ|60<<_MAG,_C5<<_FREQ|00000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_hightom2[] = {
	pre_percussion_hightom2_mono
};

/* Symbal */

synthe_precode pre_percussion_symbal1_mono[] = {
	_NOISE<<_FREQ|2500<<_MAG,_NOISE<<_FREQ|32000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_symbal1[] = {
	pre_percussion_symbal1_mono
};

synthe_precode pre_percussion_symbal2_mono[] = {
	_NOISE<<_FREQ|60<<_MAG,_NOISE<<_FREQ|32000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_symbal2[] = {
	pre_percussion_symbal2_mono
};

synthe_precode pre_percussion_elsymbal1_mono[] = {
	_A4<<_FREQ|2500<<_MAG,_B4<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_elsymbal1[] = {
	pre_percussion_elsymbal1_mono
};

synthe_precode pre_percussion_elsymbal2_mono[] = {
	_A4<<_FREQ|60<<_MAG,_B4<<_FREQ|15000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_elsymbal2[] = {
	pre_percussion_elsymbal2_mono
};

/* Hi-hat */

synthe_precode pre_percussion_hihat1_mono[] = {
	_NOISE<<_FREQ|2500<<_MAG,_NOISE<<_FREQ|32000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_hihat1[] = {
	pre_percussion_hihat1_mono
};

synthe_precode pre_percussion_hihat2_mono[] = {
	_NOISE<<_FREQ|60<<_MAG,_NOISE<<_FREQ|32000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_hihat2[] = {
	pre_percussion_hihat2_mono
};

/* Triangle */

synthe_precode pre_percussion_triangle1_mono[] = {
	_D6<<_FREQ|2500<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_triangle1[] = {
	pre_percussion_triangle1_mono
};

synthe_precode pre_percussion_triangle2_mono[] = {
	_D6<<_FREQ|60<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_triangle2[] = {
	pre_percussion_triangle2_mono
};
