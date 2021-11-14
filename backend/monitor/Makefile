# Versioning system
VERSION ?= 0.00-0000
REVISION ?= devbuild
INSTALL_DIR ?= .

# Executable name
TARGET=monitor_wrapper.so

# GCC compiling & linking flags
CFLAGS  = -std=gnu99 -Wall
CFLAGS += -I$(INSTALL_DIR)/include
CFLAGS += -DVERSION=$(VERSION) -DREVISION=$(REVISION)

# Additional libraries which needs to be dynamically linked to the executable
# -lm - System math library (used by cos(), sin(), sqrt(), ... functions)
LIBS=-lm -lpthread

# Main GCC executable (used for compiling and linking)
CC=$(CROSS_COMPILE)gcc


all: build

build: $(TARGET)

$(TARGET): monitor.o wrapper.o
	$(CC) -fPIC -shared -o $@ $^ $(CFLAGS) $(LIBS)

monitor.o: monitor.c
	$(CC) -fPIC -c $(CFLAGS) $^ -o $@

wrapper.o: wrapper.c
	$(CC) -fPIC -c $(CFLAGS) $^ -o $@

.PHONY: clean
clean:
	rm *.o
	rm $(TARGET)