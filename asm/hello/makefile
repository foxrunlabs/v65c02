SHELL = /bin/sh

prefix      = .
exec_prefix = $(prefix)
bin_dir     = $(exec_prefix)

PROGRAM  = helloworld.bin
OBJECTS  = helloworld.o

AS       = ca65
ASFLAGS  = --cpu 65C02 -l $(basename $@).lst -t none -I ../include/

LD       = ld65
LDCONFIG = memory.conf
LDFLAGS  = -C $(LDCONFIG) -L ../lib/ -m $(basename $@).map -o $(PROGRAM)

.PHONY: all clean

all : helloworld.bin

%.o : %.a65
	$(AS) $(ASFLAGS) -o $@ $<

helloworld.o : helloworld.a65

$(PROGRAM) : $(OBJECTS)
	$(LD) $(LDFLAGS) $^ v65C02.lib

clean :
	@rm -fv *.lst
	@rm -fv *.map
	@rm -fv *.o
