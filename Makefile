#Add -DFORCE_PC3_IDENT to CFLAGS to force the identification of
#a Parallel Cable III
CFLAGS=-Wall -fPIC -DUSB_DRIVER_VERSION="\"$(shell stat -c '%y' usb-driver.c |cut -d\. -f1)\"" #-DFORCE_PC3_IDENT

ifeq ($(LIBVER),32)
CFLAGS += -m32
endif

FTDI := $(shell libftdi-config --libs 2>/dev/null)
ifneq ($(FTDI),)
JTAGKEYSRC = jtagkey.c
CFLAGS += -DJTAGKEY
endif

SOBJECTS=libusb-driver.so libusb-driver-DEBUG.so

all: $(SOBJECTS)
	@file libusb-driver.so | grep x86-64 >/dev/null && echo Built library is 64 bit. Run \`make lib32\' to build a 32 bit version || true

libusb-driver.so: usb-driver.c parport.c jtagkey.c config.c jtagmon.c usb-driver.h parport.h jtagkey.h config.h jtagmon.h Makefile
	$(CC) $(CFLAGS) usb-driver.c parport.c config.c jtagmon.c $(JTAGKEYSRC) -o $@ -ldl -lusb -lpthread $(FTDI) -shared

libusb-driver-DEBUG.so: usb-driver.c parport.c jtagkey.c config.c jtagmon.c usb-driver.h parport.h jtagkey.h config.h jtagmon.h Makefile
	$(CC) -DDEBUG $(CFLAGS) usb-driver.c parport.c config.c jtagmon.c $(JTAGKEYSRC) -o $@ -ldl -lusb -lpthread $(FTDI) -shared

lib32:
	$(MAKE) LIBVER=32 clean all

clean:
	rm -f $(SOBJECTS)

.PHONY: clean all
