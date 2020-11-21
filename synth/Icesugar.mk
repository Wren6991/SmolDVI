CHIPNAME=smoldvi_icesugar
DOTF=$(HDL)/fpga/smoldvi_fpga_icesugar.f

DEVICE=up5k
PACKAGE=sg48
SYNTH_OPT=-retime
PNR_OPT=--pre-pack smoldvi_icebreaker_prepack.py --timing-allow-fail

include $(SCRIPTS)/synth_ice40.mk

prog: bit
	cp $(CHIPNAME).bin /media/$(USER)/iCELink/
