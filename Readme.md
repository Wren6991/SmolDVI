SmolDVI
-------

I'm playing with direct DVI output on [iCEBreaker](https://1bitsquared.com/products/icebreaker) and [iCEstick](https://www.latticesemi.com/icestick) dev boards. The iCE40 UP5k on the iCEBreaker is challenging because it's extremely slow, and the iCE40 HX1k on the iCEstick is extremely small, so I guess this is a project to build a small, fast DVI core.

Currently I've spent a few hours playing with this project, using some existing DVI gateware I wrote, plus a new serialiser design to improve timing on the UP5k. I've displayed a 640x480p 60Hz test pattern with mild timing violations, and a 1280x720p 30Hz (372 Mbps/lane) test pattern with much more exciting levels of timing violation. The 640x480p is something that I think could be practical, but I don't see 720p being much more than a party trick.

This design performs TMDS encode in the pixel clock domain, and then crosses the TMDS data to a x5 clock domain, where it is then fed to DDR output registers in the IO cells. The logic in the x5 clock domain is necessarily quite lean, because the timing is so tight on UP5k, but there is plenty of area to be squeezed out of the pixel clock side -- the example design is currently around 600 LUTs. In particular I want to try some stateless pixel-doubled TMDS encode tricks.

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
