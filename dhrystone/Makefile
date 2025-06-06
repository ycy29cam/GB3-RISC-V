include /f-of-e-tools/tools/sunflower/conf/setup.conf

TREEROOT = $(SUNFLOWERROOT)
GB3_ROOT = /gb3-resources
UTIL_DIR = ../../riscv-tests/benchmarks/common
TARGET-ARCH     = riscv32-elf
TARGET          = riscv

PROGRAM         = dhrystone
INIT            = init

INCLUDE_DIR = ../include
UTIL_DIR = ../../riscv-tests/benchmarks/common
INCLUDES = -I$(INCLUED_DIR) -I$(UTIL_DIR)

OPTFLAGS        = -O0
CFLAGS          = -march=rv32i -mabi=ilp32 $(TARGET-ARCH-FLAGS) -Wall
ASFLAGS         = --march=rv32i --mabi=ilp32
INCLUDES        = -I$(INCLUDE_DIR)
LDFLAGS         = -L$(TOOLSLIB)/$(TARGET) -Map program.map -Tsail.ld
SREC2HEX        = srec2hex

OBJS = \
	$(INIT).o \
	$(PROGRAM).o \
	dhrystone_main.o\
	$(UTIL_DIR)/util.o

all: program.hex

$(INIT).o: $(INIT).S
	$(AS) $(ASFLAGS) $(INIT).S -o $@

$(PROGRAM).o: $(PROGRAM).c dhrystone.h
	$(CC) $(CFLAGS) $(OPTFLAGS) $(INCLUDES) -c $< -o $@

dhrystone_main.o: dhrystone_main.c dhrystone.h
	$(CC) $(CFLAGS) $(OPTFLAGS) $(INCLUDES) -c $< -o $@

dhrystone.elf: $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@ -lc -lm -lgcc

program.hex: dhrystone.elf
	$(OBJCOPY) -O verilog dhrystone.elf program.hex

install: all
	mkdir -p $(GB3_ROOT)/processor/programs/
	$(SREC2HEX) -b 4096 program.hex
	cp program.hex $(GB3_ROOT)/processor/programs/

clean:
	$(RM) *.o *.elf *.map program.hex data.hex

