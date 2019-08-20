# V3D Test

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

## Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**Output/Input**

* GPIO 47 (ACT LED) as Output

* HDMI as VIDEO Output

**Compatibility**

* Under Construction

**About V3D**

* V3D is the hardware acceleration for 3D graphics. V3D is based on QPU, a special processing unit. Read [the official GPU documentation](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2835/README.md). The documentation describes QPU. Note that GPU has several units including QPU. The firmware of the SoC, which is communicating with ARM via Mailbox, has be run by another processing unit, VPU. About VPU, check [Herman H Hermitage's Repository](https://github.com/hermanhermitage/videocoreiv).

* BCM2835, BCM2836, and BCM2837 have 16 QPUs. A QPU has 16 elements, so the QPU runs the assigned code in 16 ways parallelly. The element number can be obtained in codes. An allotment of vertex attribute is served to each element if you control shaders. Elements in a QPU run the same codes on the same program counter, so it's the unique system of conditional branches, any of elements or all of elements; whereas each QPU can run different codes.

**About User Program**

* QPU can run a user program which is not included in shader controls.

* The user program will be executed via two ways. The first way is the Mailbox command. Another way is to set in V3D registers. So far, I'm using V3D registers to execute a user program. The mailbox command is conditioned by the firmware, which seems to use IRQ with an interrupt issued by QPU.

**About VC4ASM**

* There is [an assembler for QPU](http://maazl.de/project/vc4asm/doc/index.html). Files named with ".qasm" in this project are assembled by this assembler. This project uses VC4ASM in Makefile.

* Installation of V 0.2.3 in Raspbian

```bash
cd ~/Desktop
wget http://maazl.de/project/vc4asm/vc4asm.tar.bz2
mkdir vc4asm
tar -xvjf vc4asm.tar.bz2 -C vc4asm
cd vc4asm
make -C src
sudo cp bin/vc4asm /usr/local/bin/vc4asm
sudo cp bin/vc4dis /usr/local/bin/vc4dis
sudo mkdir /usr/local/share/vc4inc
sudo cp share/vc4.qinc /usr/local/share/vc4inc/vc4.qinc
```

* Usage

```bash
# Assemble to Binary
vc4asm -V -o v3d.bin -e v3d.o -I /usr/local/share/vc4inc/ -i vc4.qinc v3d.qasm
# Disassemble to Assembler Codes in Text
vc4dis -V -o v3d.qasm.dis -v v3d.bin
```

* Uninstallation

```bash
sudo rm /usr/local/bin/vc4asm
sudo rm /usr/local/bin/vc4dis
sudo rm -r /usr/local/share/vc4inc
```
