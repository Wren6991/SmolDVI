CHIPNAME=smoldvi_icebreaker
DOTF=$(HDL)/fpga/smoldvi_fpga_icebreaker.f

DEVICE=up5k
PACKAGE=sg48

include $(SCRIPTS)/synth_ice40.mk

prog: bit
	iceprog $(CHIPNAME).bin
