/**
 * linker_script.ld
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 * Linker Script for ARM Baremetal for Raspberry Pi
 */

/* Wildcards before parenthesis in curly brackets mean any file to link */

SECTIONS {

	/* Assign Address */
	. = 0x0000;
	.el01_vector32 : {
		aloha_vector32.o(.el01_vector)
		. = 0x1000;
	}
	. = 0x1000;
	.el2_vector32 : {
		aloha_vector32.o(.el2_vector)
		. = 0x1000;
	}
	. = 0x2000;
	.el3_vector32 : {
		aloha_vector32.o(.el3_vector)
		. = 0x1000;
	}
	. = 0x8000;
	.aloha_vector32 : {
		aloha_vector32.o(.aloha_vector)
		. = 0x2000;
	}
	. = 0xA000;
	.system32 : {
		system32.o(.system)
		. = 0x4000;
	}
	. = 0xE000;
	.library32 : {
		system32.o(.library)
		. += 0x00100000;
	}
	.text : {
		*(.text)
	}

	.data : {
		*(.data)
	}

	.rodata : {
		*(.rodata)
	}
	. = 0x04000000;
	.bss : {
		*(.bss)
	}

}