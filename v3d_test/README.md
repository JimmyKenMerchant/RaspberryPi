# V3D Test

* Author: Kenta Ishii
* License: MIT
* License URL: https://opensource.org/licenses/MIT

## Information of this README and comments in this project may be incorrect. This project is not an official document of ARM, Broadcom Ltd., Raspberry Pi Foundation and other holders of any Intellectual Property (IP), and is made of my experience, and even my hypothesis to the architecture of Raspberry Pi. Please don't apply these information in this project to your development. `TEST IT BY YOURSELF AND CONFIRM IT BY AUTHORITY FOR SAFETY` is an important value as a developer.

**Output/Input**

* GPIO 47 (ACT LED) as Output

* HDMI as VIDEO Output

**Compatibility**

* Raspberry Pi Zero V.1.3 (BCM2835), `make type=zero`

* Raspberry Pi Zero W V.1.1 (BCM2835), `make type=zerow`

* Raspberry Pi 2 B V.1.1 (BCM2836), `make type=2b`

* Raspberry Pi 3 B V.1.2 (BCM2837), `make type=3b`

**About V3D**

* V3D is the hardware acceleration for 3D graphics. V3D is based on QPU, a special processing unit. Read [the official GPU documentation](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2835/README.md). The documentation describes QPU. Note that GPU has several units including QPU. The firmware of the SoC, which is communicating with ARM via Mailbox, has be run by another processing unit, VPU. About VPU, check [Herman H Hermitage's Repository](https://github.com/hermanhermitage/videocoreiv).

* BCM2835, BCM2836, and BCM2837 have 12 QPUs. The control registers reserve up to 16 QPUs. However, the implementation contains 3 slices and 4 QPUs per slice. In default, if you set multiple user programs, the programs start from 12th QPU in decremental order.

* A QPU has 16 elements, which are logical blocks for parallel execution. So, the QPU runs the assigned code in 16 ways. There are 4 physical blocks in a QPU and these can be multiplied by 4 through 4 clocks, i.e., 4 ways per clock. The technology seems to be similar to hardware threading. However, elements in a QPU run the same codes on the same program counter, so it's the unique system of conditional branches, any of elements or all of elements; whereas each QPU can run different codes: Note that the element number can be obtained in codes. An allotment of attributes for each vertex or pixel in VPM is served to each element if you control shaders. An allotment of the data array in VPM you set is served to each element if you execute the user program.

* An element has two types of arithmetic logic units (ALUs), adder and multiplier. You can command both addition and multiplication in an instruction, i.e, an explicit type of superscaling. Plus, a control signal (thread end, etc.) can be included in an instruction, which length is 64-bit. Up to single precision floating point and 32-bit unsigned/signed integer can be handled.

* Note that the concept of threading is for the shading process, binning and rendering. However, several contexts of the documents seem to mention a thread as an alias of the element. In the computer world, threads are typically referred to as logical cores in a physical core, which can run different codes.

* I referenced PeterLemon's [Raspberry Pi Bare Metal Assembly Programming](https://github.com/PeterLemon/RaspberryPi) for V3D programming. The examples are very nice to know the practical usage of V3D.

* To use V3D with the environment which enables data cache of ARM and/or QPU, all of the code and the data are needed to be stored at the GPU memory space. Make sure that the GPU memory space is not flagged as cacheable by ARM to communicate the data smoothly between ARM and QPU. Caution that the V3D block recognize the bus address (check the beginning of the BCM2835 peripheral manual), and the address should be at the point of coherency (PoC). PoC seems to be the 0x40000000 address space on BCM2835 and the 0x80000000 address space on BCM2835 and BCM2837.

* FLOPS (floating point operations per second) is calculated as described below.
	* V3D's clock is 250Mhz: 2 (instructions per clock) * 4 (ways per clock) * 12 (QPUs) * 250Mhz = 24GFLOPS
	* V3D's clock is 300Mhz: 2 * 4 * 12 * 300Mhz = 28.8GFLOPS

* I'd like to thank Broadcom for publicly opening details of the QPU because it dedicates to the reliability. Have you ever heard "GPU War"? It implies the difficulty of the business on GPU, typically high-end graphic chips. GPU has been regarded as a commodity depending on the semiconductor cycle, i.e., the chip needs to be the newest one with the developing cost and the cost for inventory adjustment. However, GPU is becoming an electrical part for industrial usage, and that means the need of validity and reliability rather than high-specification.

**About User Program**

* QPU can run a user program which is not included in shader controls.

* The user program will be executed via two ways. The first way is the Mailbox command. Another way is to set in V3D registers. So far, I'm using V3D registers to execute a user program. The mailbox command is conditioned by the firmware, which seems to use IRQ with an interrupt issued by QPU.

**About 3D Pipeline, Z/Alpha Blending (In My Experience So Far)**

* I determined that the 3D pipeline should be simple. A process of shading means a pair of executing binning and rendering control lists. A process shades a 3D object. Note that the rendering control list can store color to the framebuffer.

* Tile Buffer (TLB) seems to be implemented buffers for color, z, and stencil in V3D. Tiled rendering saves the size of buffer smaller than basic rendering. V3D only holds TLB for up to 64 * 64 pixels.

* The z/alpha blending are considered external processes. To get a depth buffer, you can code another fragment shader to store the z value as color in TLB, i.e., it means another shading is needed. The z/alpha blending of two 3D objects needs two sets of color shading, depth shading, and z/alpha blending. To execute z/alpha blending, you may need a user program. The user program may be good if you utilize multiple QPUs. Available color formats are different among display drivers, so the user program can convert the color format to fit with a display driver. For example, you want to display a TFT LCD, it would be needed to convert 32-bit ARGB8888 color to 16-bit RGB565 color.

* I use the ARBG8888 format (the alpha channel is MSB). It is useful to display a monitor through HDMI and RCA outputs.

* In my testing, rendering control lists can load and store color in TLB to a user-defined buffer by item No. 27 or No. 29 for loading, item. No. 26 or No. 28 for storing. Make sure to place item No. 115 after No. 27 or No. 29. Place item No. 115 before No. 26 and No. 28. To reflect loaded color, disable color buffer clear. The color data is stored with tile order (32 * 32 pixels or 64 * 64 pixels depending on the setting). Multisample mode stores color for a pixel 4 times, so Multisample mode needs data bytes 4 times as many as Non-multisample mode for a buffer. However I don't use these items to simplify the pipeline.

**About 2D Pipeline**

* V3D can also use as the pipeline for 2D rendering. You can use a texture, maximum 2048 * 2048 pixels, for multiple 2D images by offsetting S and T coordinates. For example, if you use the 64 * 64 pixels images, (2048/64)^2 = 1024 images can be used in a shading. However, as well as the 3D pipeline, the alpha blending is needed multiple shading. However, V3D allows to shade a geometry, which is similar to a sprite. I think it's possible that you utilize one shading per frame. As well as loading a pixel color of texture, you can load a color in an assigned memory space using TMU. Note that in my testing, the uniforms address (the pointer for the assigned texture) can't be changed on the fragment shader with control lists.

* If you implement double-buffer using DMA, dynamic images will be slightly shaking on the monitor (I confirmed this issue on the HDMI output). Using the 2D rendering with V3D resolves this issue, i.e., draw the buffer as a texture. I think V3D has proper timing to output images.

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
