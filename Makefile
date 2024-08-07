ARCH = armv7-a
MCPU = cortex-a8

CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
LD = arm-none-eabi-ld
OC = arm-none-eabi-objcopy

LINKER_SCRIPT = ./spos.ld
MAP_FILE = build/spos.map

ASM_SRCS = $(wildcard boot/*.S)
ASM_OBJS = $(patsubst boot/%.S, build/%.os, $(ASM_SRCS))

C_SRCS = $(wildcard boot/*.c)
C_OBJS = $(patsubst boot/%.c, build/%.o, $(C_SRCS))

INC_DIRS = include

spos = build/spos.axf
spos_bin = build/spos.bin

.PHONY: all clean run debug gdb

all: $(spos)

clean:
	@rm -rf build

run: $(spos)
	qemu-system-arm -M realview-pb-a8 -kernel $(spos)

debug: $(spos)
	qemu-system-arm -M realview-pb-a8 -kernel $(spos) -S -gdb tcp::1234,ipv4

gdb:
	arm-none-eabi-gdb

$(spos): $(ASM_OBJS) $(C_OBJS) $(LINKER_SCRIPT)
	$(LD) -n -T $(LINKER_SCRIPT) -o $(spos) $(ASM_OBJS) $(C_OBJS) -Map=$(MAP_FILE)
	$(OC) -O binary $(spos) $(spos_bin)

build/%.os: $(ASM_SRCS)
	mkdir -p $(shell dirname $@)
	$(CC) -march=$(ARCH) -mcpu=$(MCPU) -I $(INC_DIRS) -c -g -o $@ $<

build/%.o: $(C_SRCS)
	mkdir -p $(shell dirname $@)
	$(CC) -march=$(ARCH) -mcpu=$(MCPU) -I -$(INC_DIRS) -c -g -o $@ $<