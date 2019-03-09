SHELL = /bin/sh

prefix      = .
exec_prefix = $(prefix)
lib_dir     = $(prefix)

LIBRARY = v65C02.lib
OBJECTS = v65C02.o

AS      = ca65
ASFLAGS = --cpu 65C02 -l $(basename $@).lst -t none -I ../include/

AR      = ar65
ARFLAGS = r $(LIBRARY)

.PHONY: all clean

all : $(LIBRARY)

%.o : %.a65
	$(AS) $(ASFLAGS) -o $@ $<

v65C02.o : v65C02.a65 ../include/v65C02.inc

$(LIBRARY) : $(OBJECTS)
	$(AR) $(ARFLAGS) $^

clean :
	@rm -fv *.lst
	@rm -fv *.map
	@rm -fv *.o
