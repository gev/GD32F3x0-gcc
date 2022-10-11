PORT=/dev/ttyUSB0
DEVICE=GD32F330

INCS= \
-Ilib/CMSIS/inc \
-Ilib/device/gd32f3x0/inc \
-Ilib/device/gd32f3x0/peripherals/inc

CFLAGS=-mthumb -mcpu=cortex-m4 -mfloat-abi=soft -fno-builtin -fno-strict-aliasing -fdata-sections -fms-extensions -ffunction-sections -Og $(INCS) -D$(DEVICE)
LDFLAGS=-mthumb -mcpu=cortex-m4 -mfloat-abi=soft -Wl,--gc-sections -flto -specs=nano.specs -Tlib/device/gd32f3x0/gd32f3x0.ld

CC=arm-none-eabi-gcc
LD=arm-none-eabi-gcc
AR=arm-none-eabi-ar
OC=arm-none-eabi-objcopy
FL=stm32loader
MT=miniterm

SRCS=$(wildcard *.c)
LIBS=$(wildcard lib/device/gd32f3x0/src/*.c lib/device/gd32f3x0/peripherals/src/*.c)

SRCOBJS=$(patsubst %.c, build/%.o, $(SRCS))
LIBOBJS=$(patsubst %.c, build/%.o, $(LIBS))

app: $(SRCOBJS)
	$(LD) $(LDFLAGS) $^ -lc -lm build/driver.a -o build/output.elf
	$(OC) -O binary build/output.elf build/output.bin
	$(OC) -O ihex build/output.elf build/output.hex

flash: app
	$(FL) -p $(PORT) -s -e -w output.bin

monitor: flash
	#RTS and DTR are low active
	$(MT) --dtr 1 --rts 0 $(PORT) 115200

driver: $(LIBOBJS)
	$(AR) rcs build/driver.a $^

clean:
	@rm -rf build

build/%.o: %.c
	@mkdir -p $(shell dirname $@)
	$(CC) $(CFLAGS) -c $< -o $@
