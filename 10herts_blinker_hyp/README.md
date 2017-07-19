# 10Hz blinker on Hyp mode for Multi-core Raspberry Pi using IRQ

**This Program is tested by Raspberry Pi 2 Model B V1.1 whose CPU is BCM2836, Coretex-A7 MPCore (ARMv7-A).**

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

## Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, and is made of my experience and even my hypothesis to ARM architecture. Please don't apply the information in this project to your development DIRECTLY. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a commercial developer.

Multi-core processor is introduced From Raspberry Pi (RasPi) 2. Its CPU is BCM2836, Coretex-A7 MPCore (until V1.1), having a new feature, Hypervisor (Hyp) mode. Hyp mode is for treating its multi-core processor. If you want to name this feature as Virtualization, it's correct because multi-core is needed to handle several processors simultaneously. Hyp mode, which is called by `HVC`, is added to Non-secure state. This addition has a new processor mode, uniquely has ELR_hyp (Exception Link Registor) to use `ERET` instruction. To access ELR_hyp, use `MRS` and `MSR` just as accessing Program Status Registor (PSR). Besides, LR (Link Registor) of Hyp mode is shared with User or System mode. Before RasPi 2, single-core RasPis start these kernels with Secure SVC mode. In contrast, after RasPi 2, multi-core RasPis start these kernels with Non-secure Hyp mode. Multi-core RasPis need to wake and handle 4 cores by Interrupt Vector Table (IVT). Actually, start.elf, a RasPis' firmware, is making a procedure to stop second, third and fourth core, and wait to listen Program Counter (PC) address on each Mailbox 3. But if so, you can't make unique IVT for every core. Hyp mode can resolve this issue, because Hyp mode can have its own IVT address, called HVBAR.

Hyp mode is ONLY accessible from Non-secure state. Besides, Secure Monitor (Mon) mode CAN CONTROL its accessibility from Non-secure state. ARM1176JZ(F)-S (ARMv6KZ), which is used on BCM2835 of the first Raspberry Pi and **some milestone**, introduced TrustZone security extensions, Secure state and Non-secure state, and added Secure Monitor (Mon) mode to secure state that is called by `SMC` (Secure Monitor Call) instruction. `SMC` is THE ONLY GATE from Non-secure state to Secure state. This architecture is for treating secret information such as several unique information to identify individuals safely. Secure state and Non-secure state can have each virtual memory address by the Memory Management Unit (MMU) translation table's NS bit, and System Control Registor (SCTLR)'s banked bits in coprocessor CP15. In AArch32 (From ARMv8) or ARMv7-A, which have 32-bit system, Mon mode returns to the previous mode by setting NS bit (No.0) of SCR (Secure Configuration Registor) in CP15 to switch Non-secure state, then calling `SUBS PC, LR, #0` or `MOVS PC, LR`. There is a difference between Hyp mode and Mon mode. They also have each IVT, HVBAR and MVBAR. HVBAR is special, because this has entire IVT, but Hyp mode will be stayed, i.e., IVT of HVBAR is a branch table with `BL` instruction except recalling `HVC` without 'ERET' (check out my code). MVBAR is only used to jump to Mon mode (0x08 offset), and can be changed only in Privileged and Secure state. `HVC` and `SMC` instructions are managed by Secure Configuration Registor (SCR), which can be accessed only in Privileged and Secure state, HCE (Hyp Call Enable) bit is No.8, SCD (Secure Monitor Call Disable) bit is No.7, `MRC p15, 0, <Rd>, c1, c1, 0` to read SCR, `MCR p15, 0, <Rd>, c1, c1, 0` to write SCR.

If you want Mon mode in baremetal Raspberry Pi with default firmware, start.elf, you may meet an issue of MVBAR setting. It's because of start.elf starts kernel with Non-secure Hyp mode in default, and MVBAR and its IVT is unknown. To get Mon mode, add `kernel_old=1 disable_commandline_tags=1` in config.txt to start its kernel.img with Secure state, but all 4 cores will run simultaneously for the same instructions from address 0x0000_0000! (kernel_old=0 seems to be the same as default). To hide multi-core running, use Multiprocessor Affinity Registor (MPIDR), `MRC p15, 0, <Rd>, c0, c0, 5` (Bit No.8 to No.11) to check core ID, then jump to a loop (except first core). Plus, you may need to write IVT on VBAR to treat cores. The new kernel is entering from Non-secure Hyp mode, because IVT on VBAR is already written for multi-core treating, e.g., cores, except first core, are waiting for interrupts from Mailbox 3 for starting instructions from the instructed addresses. Not evidence yet, but if use `ERET` instruction with the default setting in config.txt, the core returns to waiting point for interrupts from Mailbox 3 on Privilege Level (PL) 1. PL 0 is for User mode, PL 2 is for Hyp mode in AArch32/ARMv7-A. To develop a baremetal gadget by multi-core RasPis, I recommend to use the default setting, i.e., entering Non-secure Hyp mode for treating each core easily. Cores have each MMU, and System Coprocessor Registors (but not all).

In AArch64 (From ARMv8), which has 64-bit system, processor modes are deprecated, and switch exception levels by SVC (EL1), HVC (EL2), SMC (EL3).To return from any exception level, use `ERET` with filling any ELR to PC and banked several registors (SPSR, SP, etc.). And coprocessors is deprecated and changed to System Registers (SPR). Use `MRS` and `MSR` for several definition just as accessing Program Status Registor (PSR). AArch32/ARMv7-A seem to have tricky handling to switch processor modes. ELR is used in Aarch64 mainly, but in AArch32/ARMv7-A, ELR is only used in HYP mode, the final addition to processor modes. Because AArch32/ARMv7-A is the bridge to Aarch64, it has several difficulties more than older versions of 32-bit system ARM. But DON'T YOU REMEMBER, AArch32 is the de facto final of 32-bit system ARM. This fact is truly important to us, developers, because we no longer bother of new features in 32-bit system ARM.

**System Coprocessor Registors**

This term is used in AArch32/ARMv7-A. Besides, in AArch64, this term is deprecated and integrated to System Registers including SPSR_EL1-3 (CPSR is deprecated, and accessible to each program status through individual registors), ELR_EL1-3, SP_EL0-3 (SP in General Purpose Registors becomes Zero Registor in AArch64). Loading/Storing process with General Purpose Registers is integrated to MRS/MSR. Plus, in AArch64, Program Counter (PC) restricts its accessibility directly. But, in AArch32/ARMv7-A, MRC/MCR instructions are still alive and we should know these magic numbers to treat system related configurations such as Multi-core, Cache, MMU and IVT processes (by the way, the clock of cores is managed by VideoCore of Broadcom through Mailbox).

Basically, we need to indicate Coprocessor CP15. CP14 is for debugging.

The list below is just a tiny part of whole System Coprocessor Registors.

* System Control Registor (SCTLR)

`MRC p15, 0, <Rd>, c1, c0, 0`: Load a word to General Purpose Registors from System Coprocessor Registors

`MCR p15, 0, <Rd>, c1, c0, 0`: Store a word to System Coprocessor Registors from General Purpose Registors

* Secure Configuration Registor (SCR): Added for TrustZone security extensions

`MRC p15, 0, <Rd>, c1, c1, 0`

`MCR p15, 0, <Rd>, c1, c1, 0`
 
* Multiprocessor Affinity Registor (MPIDR): Added for Multi-core (Read Only)

`MRC p15, 0, <Rd>, c0, c0, 5`

* Vector Base Address Registor (VBAR)

`MRC p15, 0, <Rd>, c12, c0, 0`

`MCR p15, 0, <Rd>, c12, c0, 0`

* Monitor Vector Base Address Registor (MVBAR)

`MRC p15, 0, <Rd>, c12, c0, 1`: only accessible in Secure state

`MCR p15, 0, <Rd>, c12, c0, 1`

* Hypervisor Vector Base Address Registor (HVBAR): Added from Armv7-A

`MRC p15, 4, <Rd>, c12, c0, 0`

`MCR p15, 4, <Rd>, c12, c0, 0`
