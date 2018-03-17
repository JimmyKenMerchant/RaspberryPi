/**
 * vfp64.s
 *
 * Author: Kenta Ishii
 * License: MIT
 * License URL: https://opensource.org/licenses/MIT
 *
 */


/**
 * function vfp64_f32tof64
 * Convert From Sigle Precision Float to Double Precision Float
 *
 * Parameters
 * r0: Value, Must Be Single Precision Float
 *
 * Return: r0 (Lower Half of Double Precison Float), r1 (Upper Half of Double Precision Float)
 */
.globl vfp64_f32tof64
vfp64_f32tof64:
	/* Auto (Local) Variables, but just Aliases */
	value         .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	/* VFP Registers */
	vfp_value     .req d0
	vfp_temp      .req s2

	vpush {s0-s2}

	vmov vfp_temp, value
	vcvt.f64.f32 vfp_value, vfp_temp

	vfp64_f32tof64_common:
		vmov r0, r1, vfp_value
		vpop {s0-s2}
		mov pc, lr

.unreq value
.unreq vfp_value
.unreq vfp_temp


/**
 * function vfp64_f64tof32
 * Convert From Double Precision Float to Single Precision Float
 *
 * Parameters
 * r0: Lower Half of Double Precision Float
 * r1: Upper Half of Double Precision Float
 *
 * Return: r0 (Value by Single Precision Float)
 */
.globl vfp64_f64tof32
vfp64_f64tof32:
	/* Auto (Local) Variables, but just Aliases */
	value_lower   .req r0
	value_upper   .req r1

	/* VFP Registers */
	vfp_value     .req d0
	vfp_temp      .req s2

	vpush {s0-s2}

	vmov vfp_value, value_lower, value_upper
	vcvtr.f32.f64 vfp_temp, vfp_value

	vfp64_f64tof32_common:
		vmov r0, vfp_temp
		vpop {s0-s2}
		mov pc, lr

.unreq value_lower
.unreq value_upper
.unreq vfp_value
.unreq vfp_temp


/**
 * function vfp64_s32tof64
 * Convert From Signed Integer to Double Precision Float
 *
 * Parameters
 * r0: Value, Must Be Signed Integer
 *
 * Return: r0 (Lower Half of Double Precison Float), r1 (Upper Half of Double Precision Float)
 */
.globl vfp64_s32tof64
vfp64_s32tof64:
	/* Auto (Local) Variables, but just Aliases */
	value         .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	/* VFP Registers */
	vfp_value     .req d0
	vfp_temp      .req s2

	vpush {s0-s2}

	vmov vfp_temp, value
	vcvt.f64.s32 vfp_value, vfp_temp

	vfp64_s32tof64_common:
		vmov r0, r1, vfp_value
		vpop {s0-s2}
		mov pc, lr

.unreq value
.unreq vfp_value
.unreq vfp_temp


/**
 * function vfp64_u32tof64
 * Convert From Unsigned Integer to Single Precision Float
 *
 * Parameters
 * r0: Value, Must Be Unigned Integer
 *
 * Return: r0 (Lower Half of Double Precison Float), r1 (Upper Half of Double Precision Float)
 */
.globl vfp64_u32tof64
vfp64_u32tof64:
	/* Auto (Local) Variables, but just Aliases */
	value         .req r0 @ Parameter, Register for Argument and Result, Scratch Register

	/* VFP Registers */
	vfp_value     .req d0
	vfp_temp      .req s2

	vpush {s0-s2}

	vmov vfp_temp, value
	vcvt.f64.u32 vfp_value, vfp_temp

	vfp64_u32tof64_common:
		vmov r0, r1, vfp_value
		vpop {s0-s2}
		mov pc, lr

.unreq value
.unreq vfp_value
.unreq vfp_temp


/**
 * function vfp64_f64tos32
 * Convert From Double Precision Float to Signed Integer, Rounded Off
 *
 * Parameters
 * r0: Lower Half of Double Precision Float
 * r1: Upper Half of Double Precision Float
 *
 * Return: r0 (Value by Signed Integer)
 */
.globl vfp64_f64tos32
vfp64_f64tos32:
	/* Auto (Local) Variables, but just Aliases */
	value_lower   .req r0
	value_upper   .req r1

	/* VFP Registers */
	vfp_value     .req d0
	vfp_temp      .req s2

	vpush {s0-s2}

	vmov vfp_value, value_lower, value_upper
	vcvtr.s32.f64 vfp_temp, vfp_value

	vfp64_f64tos32_common:
		vmov r0, vfp_temp
		vpop {s0-s2}
		mov pc, lr

.unreq value_lower
.unreq value_upper
.unreq vfp_value
.unreq vfp_temp


/**
 * function vfp64_f64tou32
 * Convert From Double Precision Float to Unsigned Integer, Rounded Off
 *
 * Parameters
 * r0: Lower Half of Double Precision Float
 * r1: Upper Half of Double Precision Float
 *
 * Return: r0 (Value by Unsigned Integer)
 */
.globl vfp64_f64tou32
vfp64_f64tou32:
	/* Auto (Local) Variables, but just Aliases */
	value_lower   .req r0
	value_upper   .req r1

	/* VFP Registers */
	vfp_value     .req d0
	vfp_temp      .req s2

	vpush {s0-s2}

	vmov vfp_value, value_lower, value_upper
	vcvtr.u32.f64 vfp_temp, vfp_value

	vfp64_f64tou32_common:
		vmov r0, vfp_temp
		vpop {s0-s2}
		mov pc, lr

.unreq value_lower
.unreq value_upper
.unreq vfp_value
.unreq vfp_temp

