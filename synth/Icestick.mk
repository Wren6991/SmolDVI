CHIPNAME=smoldvi_icestick
DOTF=$(HDL)/fpga/smoldvi_fpga_icebreaker.f

DEVICE=hx1k
PACKAGE=tq144
SYNTH_OPT=-retime
PNR_OPT=--pre-pack smoldvi_icebreaker_prepack.py --timing-allow-fail

include $(SCRIPTS)/synth_ice40.mk

prog: bit
	iceprog $(CHIPNAME).bin
