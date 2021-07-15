CHIPNAME=smoldvi_tinyfpga_bx
DOTF=$(HDL)/fpga/smoldvi_fpga_tinyfpga_bx.f

DEVICE=lp8k
PACKAGE=cm81
SYNTH_OPT=-retime
PNR_OPT=--pre-pack smoldvi_icebreaker_prepack.py --timing-allow-fail

include $(SCRIPTS)/synth_ice40.mk

prog: bit
	tinyprog -p $(CHIPNAME).bin
