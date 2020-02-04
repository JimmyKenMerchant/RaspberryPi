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

synthe_precode pre_percussion_bassdrum1_mono[] = {
	_G2<<_FREQ|5000<<_MAG,_G2<<_FREQ|00000<<_MAG,300<<_BEAT,1<<_ATK|30<<_DCY|30<<_STN|69<<_RLS,
	STS32_END
};

synthe_precode* pre_percussion_bassdrum1[] = {
	pre_percussion_bassdrum1_mono
};

synthe_precode pre_percussion_bassdrum2_mono[] = {
	_B1<<_FREQ|5000<<_MAG,_B1<<_FREQ|00000<<_MAG,300<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_bassdrum2[] = {
	pre_percussion_bassdrum2_mono
};

synthe_precode pre_percussion_handcrap_mono[] = {
	_G5<<_FREQ|4000<<_MAG,_NOISE<<_FREQ|32000<<_MAG,150<<_BEAT,0<<_ATK|3<<_DCY|2<<_STN|97<<_RLS,
	_END
};

synthe_precode* pre_percussion_handcrap[] = {
	pre_percussion_handcrap_mono
};

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

synthe_precode pre_percussion_symbal1_mono[] = {
	_A4<<_FREQ|2500<<_MAG,_B4<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_symbal1[] = {
	pre_percussion_symbal1_mono
};

synthe_precode pre_percussion_symbal2_mono[] = {
	_A4<<_FREQ|60<<_MAG,_B4<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_symbal2[] = {
	pre_percussion_symbal2_mono
};

synthe_precode pre_percussion_hihat1_mono[] = {
	_D6<<_FREQ|2500<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_hihat1[] = {
	pre_percussion_hihat1_mono
};

synthe_precode pre_percussion_hihat2_mono[] = {
	_D6<<_FREQ|60<<_MAG,_D7<<_FREQ|15000<<_MAG,150<<_BEAT,1<<_RIS|100<<_STN|99<<_FAL,
	STS32_END
};

synthe_precode* pre_percussion_hihat2[] = {
	pre_percussion_hihat2_mono
};
