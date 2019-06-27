
TARGET := hello
PREFIX := /home/yihsiuh/work/gcc-arm-none-eabi-8-2018-q4-major/bin/arm-none-eabi-

CC = $(PREFIX)gcc
OBJCOPY = $(PREFIX)objcopy

FLASH := /home/arcbbb/bin/st-flash

CFLAGS = -mcpu=cortex-m4 -mfloat-abi=hard
LDFLAGS = -mcpu=cortex-m4 -mfloat-abi=hard

CFLAGS += \
	   -I CMSIS/Device/ST/STM32F4xx/Include \
	   -I CMSIS/Include \
	   -I STM32F4xx_HAL_Driver/Inc \
	   -I STM32F4xx_Nucleo_144 \
	   -I include \
	   -DSTM32F429xx \
	   -DUSE_HAL_DRIVER \
	   -DUSE_STM32F4XX_NUCLEO_144 \

HAL_OBJ := STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr_ex.o STM32F4xx_HAL_Driver/Src/stm32f4xx_hal.o \
		   STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_cortex.o STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc.o \
		   STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_gpio.o STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_uart.o \
		   STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma.o STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_spi.o \
		   STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_adc.o STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_adc_ex.o

SRC_OBJ := src/main.o src/stm32f4xx_hal_msp.o src/stm32f4xx_it.o src/system_stm32f4xx.o

SW4STM32_OBJ := SW4STM32/syscalls.o SW4STM32/startup_stm32f429xx.o
LDSCRIPT := SW4STM32/STM32F429ZI_NUCLEO_144/STM32F429ZITx_FLASH.ld

NUCLEO144_OBJ := STM32F4xx_Nucleo_144/stm32f4xx_nucleo_144.o

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).elf: $(SW4STM32_OBJ) $(SRC_OBJ) $(HAL_OBJ) $(NUCLEO144_OBJ)
	$(CC) $(LDFLAGS) $^ -o $@ -T $(LDSCRIPT) -Wl,-Map,"$(TARGET).map"

flash: $(TARGET).bin
	sudo $(FLASH) write $< 0x8000000

backup:
	sudo $(FLASH) read backup.bin 0x8000000 0x200000

uart:
	sudo screen /dev/ttyACM0 9600

%.o: %.c
	$(CC) $< -c $(CFLAGS) -o $@

%.o: %.s
	$(CC) $< -c $(CFLAGS) -o $@

clean:
	rm -f $(TARGET).bin $(TARGET).elf $(HAL_OBJ) $(SRC_OBJ) $(SW4STM32_OBJ) $(NUCLEO144_OBJ)
