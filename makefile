PORT=/dev/ttyUSB0
DEVICE=GD32F330

CFLAGS=-mthumb -mcpu=cortex-m4 -mfloat-abi=soft -fno-builtin -fno-strict-aliasing -fdata-sections -fms-extensions -ffunction-sections -Og -Ilib/inc -D$(DEVICE)
LDFLAGS=-mthumb -mcpu=cortex-m4 -mfloat-abi=soft -Wl,--gc-sections -flto -specs=nano.specs -Tlib/gd32f3x0.ld

CC=arm-none-eabi-gcc
LD=arm-none-eabi-gcc
AR=arm-none-eabi-ar
OC=arm-none-eabi-objcopy
FL=stm32loader
MT=miniterm

SRCS=$(wildcard *.c)
LIBS=$(wildcard lib/src/*.c)

SRCOBJS=$(patsubst %.c, %.o, $(SRCS))
LIBOBJS=$(patsubst lib/src/%.c, lib/%.o, $(LIBS))

app: $(SRCOBJS)
	$(LD) $(LDFLAGS) $^ -lc -lm lib/driver.a -o output.elf
	$(OC) -O ihex output.elf output.hex
	@rm -rf *.o *.elf

flash: app
	$(FL) -p $(PORT) -s -e -w output.bin

monitor: flash
	#RTS and DTR are low active
	$(MT) --dtr 1 --rts 0 $(PORT) 115200

driver: $(LIBOBJS)
	$(AR) rcs lib/driver.a $^
	@rm -rf lib/*.o

clean:
	@rm -rf *.o *.elf *.hex *.bin

purge:
	@rm -rf lib/*.o lib/*.a *.o *.elf *.hex *.bin

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

lib/%.o: lib/src/%.c
	$(CC) $(CFLAGS) -c $< -o $@
