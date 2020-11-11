SmolDVI
-------

I'm playing with direct DVI output on [iCEBreaker](https://1bitsquared.com/products/icebreaker) and [iCEstick](https://www.latticesemi.com/icestick) dev boards. The iCE40 UP5k on the iCEBreaker is challenging because it's extremely slow, and the iCE40 HX1k on the iCEstick is extremely small, so I guess this is a project to build a small, fast DVI core.

Currently the example design uses around 9% of an iCE40 UP5k (\~240 LUTs, quite a few flops, \~500 LCs packed) for a pixel-doubled RGB666 640x480p 60 Hz output. This leaves plenty of room on the UP5k to add a more interesting source of pixels!

The example design uses the UP5k's single PLL to generate a half-rate TMDS bit clock (126 MHz in the case of 480p60), and divides this down to a 25.2 MHz pixel clock in-fabric. TMDS encode takes place in the pixel clock domain, and uses quite a nice trick to perform the encode with minimal logic (around 20 LUTs per lane), which is [described in the comments](hdl/smoldvi/smoldvi.v).

Currently there are some mild timing violations (but reliably working on my iCEBreaker) in the bit clock domain at 480p60 (252 Mbps), and much more exciting levels of timing violation at 720p30 reduced blanking (372 Mbps). At VGA resolution, this is already a fairly practical component you could build into your iCE40UP5k-based design, but the 720p30 mode is more of a party trick.

Building
========

You will need to have yosys, icestorm and nextpnr-ice40 installed on your system.

```bash
git clone --recursive https://github.com/Wren6991/SmolDVI.git smoldvi
cd smoldvi
. sourceme
cd synth
make -f Icebreaker.mk prog
```

This will build a UP5k FPGA image and flash it to an iCEBreaker plugged into your system. You will need some kind of PMOD to HDMI/DVI adapter to connect this to a display. See the [pin constraints file](synth/smoldvi_icebreaker.pcf) for pinout.
