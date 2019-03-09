SHELL = /bin/sh

prefix      = ..
exec_prefix = $(prefix)
bin_dir     = $(exec_prefix)/bram_data

BIOS     = bios.rom
BIOS_COE = bios.coe
BIOS_MEM = bios.mem
OBJECTS  = bios.o monitor.o

AS       = ca65
ASFLAGS  = --cpu 65C02 -l $(basename $@).lst -t none -I ./include/

LD       = ld65
LDCONFIG = memory.conf
LDFLAGS  = -C $(LDCONFIG) -m $(basename $@).map -o $(BIOS)

BIN2COE  = ./bin2coe.sh
BIN2MEM  = ./bin2mem.sh

.PHONY: all install clean

all : $(BIOS)

%.o : %.a65
	$(AS) $(ASFLAGS) -o $@ $<

bios.o : bios.a65 include/v65C02.inc
monitor.o : monitor.a65 include/v65C02.inc

$(BIOS) : $(OBJECTS)
	$(LD) $(LDFLAGS) $^
	$(BIN2COE) $@
	$(BIN2MEM) $@

install :
	@cp -v $(BIOS_COE) $(bin_dir)
	@cp -v $(BIOS_MEM) $(bin_dir)

clean :
	@rm -fv *.lst
	@rm -fv *.map
	@rm -fv *.o
	@rm -fv $(BIOS)
	@rm -fv $(BIOS_COE)
	@rm -fv $(BIOS_MEM)
