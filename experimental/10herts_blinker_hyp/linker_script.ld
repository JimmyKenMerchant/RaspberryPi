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
	. = 0x8000;
	.vector : {
		*(.vector)

		/* Assign Size, 65,536 bytes */
		. = 0x1000;
	}

	.text : {
		*(.text)
	}

	.data : {
		*(.data)
	}

	.bss : {
		*(.bss)
	}

}