SmolDVI
-------

I'm playing with direct DVI output on [iCEBreaker](https://1bitsquared.com/products/icebreaker) and [iCEstick](https://www.latticesemi.com/icestick) dev boards. The iCE40 UP5k on the iCEBreaker is challenging because it's extremely slow, and the iCE40 HX1k on the iCEstick is extremely small, so I guess this is a project to build a small, fast DVI core.

The example design currently uses 9% of an iCE40 UP5k (240 LUTs, quite a few CDC flops, 499 LCs post-pack) for a pixel-doubled RGB666 640x480p 60 Hz output. This leaves plenty of room on the UP5k to add a more interesting source of pixels!

I've displayed a 640x480p 60Hz test pattern with mild timing violations on UP5k, and a 1280x720p 30Hz (372 Mbps/lane) test pattern with much more exciting levels of timing violation. The 640x480p is something that I think could be practical, but I don't see 720p being much more than a party trick.

TMDS encode takes place in the pixel clock domain, and uses quite a nice trick to perform the encode with minimal logic (around 20 LUTs per lane), which is [described in the comments](hdl/smoldvi/smoldvi_tmds_encode.v). This trick does limit the colour depth to RGB777, and requires horizontal pixel doubling, but the resulting encoder is *far* smaller than the one given in the DVI spec, whilst exactly matching its output. Go read the source!

The example design uses the UP5k's single PLL to generate a half-rate TMDS bit clock (126 MHz in the case of 480p60), and divides this down to a 25.2 MHz pixel clock in-fabric. 

Building the Example Design
===========================

You will need to have yosys, icestorm and nextpnr-ice40 installed on your system.

```bash
git clone --recursive https://github.com/Wren6991/SmolDVI.git smoldvi
cd smoldvi
. sourceme
cd synth
make -f Icebreaker.mk prog
```

This will build a UP5k FPGA image and flash it to an iCEBreaker plugged into your system. You will need some kind of PMOD to HDMI/DVI adapter to connect this to a display. See the [pin constraints file](synth/smoldvi_icebreaker.pcf) for pinout. I am using [this adapter I knocked up in KiCad](https://github.com/Wren6991/DVI-PMOD).

In the `synth` directory, you will also find two other Makefile stubs, `Icesugar.mk` and `Icestick.mk`. These are for the [iCESugar](https://github.com/wuxx/icesugar) (a wonderful, cheaply available UP5k board) and [iCEstick](https://www.latticesemi.com/icestick) dev boards.

Reusing
=======

This repository is licensed under [CC0 1.0 Universal](LICENSE.md). You'll want to use all of the Verilog files in [hdl/smoldvi](hdl/smoldvi), with [smoldvi.v](hdl/smoldvi/smoldvi.v) being the top level file. The DVI mode timings and RGB bit depth are both configurable via top-level module parameters.

You'll also need to provide a module called `ddr_out`, which instantiates a DDR output buffer on your platform. Currently I'm using [a version of this from libfpga](https://github.com/Wren6991/libfpga/blob/master/common/ddr_out.v) (pulled in via submodule if you do a recursive clone on SmolDVI), which requires the preprocessor symbol `FPGA_ICE40` to be defined in order to instantiate a SB_IO primitive on iCE40.

The design requires two clocks:

- `clk_pix` running at DVI pixel clock
- `clk_bit` running at half the TMDS bit clock, i.e. 5x `clk_pix`

These must derive from a single root oscillator. You'll also need to provide an active-low asynchronous reset for each of these domains, with its deassertion synchronised to the rising edge of the clock. You can see an example instantiation in [the iCEBreaker top-level](hdl/fpga/smoldvi_fpga_icebreaker.v).

If you do something cool with this hardware, then please @ me on [Twitter](https://twitter.com/wren6991), I would love to see it! If you can find space in your Readme for a link to this repository, that would also be much appreciated, but it's not required.
