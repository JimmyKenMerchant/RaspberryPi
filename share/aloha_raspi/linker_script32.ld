/**
 * linker_script32.ld
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
		vector32.o(.el01_vector32)
		. = 0x1000;
	}
	. = 0x1000;
	.el2_vector32 : {
		vector32.o(.el2_vector32)
		. = 0x1000;
	}
	. = 0x2000;
	.el3_vector32 : {
		vector32.o(.el3_vector32)
		. = 0x1000;
	}
	. = 0x8000;
	.os_vector32 : {
		vector32.o(.os_vector32)
		. = 0x2000;
	}
	. = 0xA000;
	.vendor_system32 : {
		system32.o(.vendor_system32)
		. = 0x2000;
	}
	. = 0xC000;
	.arm_system32 : {
		system32.o(.arm_system32)
		. = 0x8000;
	}
	. = 0x14000;
	.library_system32 : {
		system32.o(.library_system32)
		. = 0x00100000;
	}
	. = 0x114000;
	.text : {
		*(.text)
	}
	.rodata : {
		*(.rodata)
	}
	. = ALIGN(0x00100000);
	.data : {
		system32.o(.data)
		*(.data)
	}
	. = ALIGN(0x00100000);
	.bss : {
		*(.bss)
	}
	. = ALIGN(0x00100000);
	.va_system32 : {
		system32.o(.va_system32)
	}
	. = ALIGN(0x00100000);
	.noncache_system32 : {
		system32.o(.noncache_system32)
	}
}