#
# Authors: Matej Oblak, Iztok Jeras
# (C) Red Pitaya 2013-2015
#
# Red Pitaya FPGA/SoC Makefile 
#
# Produces:
#   3. FPGA bit file.
#   1. FSBL (First stage bootloader) ELF binary.
#   2. Memtest (stand alone memory test) ELF binary.
#   4. Linux device tree source (dts).

PRJ   ?= logic
MODEL ?= Z10
HWID  ?= ""

# build artefacts
FPGA_BIT    = ./out/red_pitaya.bit
FSBL_ELF    = ./sdk/fsbl/executable.elf
MEMTEST_ELF = ./sdk/dram_test/executable.elf
DEVICE_TREE = ./sdk/dts/system.dts

# Vivado from Xilinx provides IP handling, FPGA compilation
# hsi (hardware software interface) provides software integration
# both tools are run in batch mode with an option to avoid log/journal files
VIVADO = vivado -nojournal -mode batch
HSI    = hsi    -nolog -nojournal -mode batch

.PHONY: all clean project

all: $(FPGA_BIT) $(FSBL_ELF) $(DEVICE_TREE)

# TODO: clean should go into each project
clean:
	rm -rf out .Xil sdk project build
	rm -rf *.jou *.log

project:
ifneq ($(HWID),"")
	vivado -source red_pitaya_vivado_project_$(MODEL).tcl -tclargs HWID=$(HWID)
else
	vivado -source red_pitaya_vivado_project_$(MODEL).tcl -tclargs
endif

$(FPGA_BIT):
ifneq ($(HWID),"")
	$(VIVADO) -source red_pitaya_vivado_$(MODEL).tcl -tclargs HWID=$(HWID)
else
	$(VIVADO) -source red_pitaya_vivado_$(MODEL).tcl
endif
	./synCheck.sh

$(FSBL_ELF): $(FPGA_BIT)
	$(HSI) -source red_pitaya_hsi_fsbl.tcl

$(DEVICE_TREE): $(FPGA_BIT)
	$(HSI) -source red_pitaya_hsi_dts.tcl

