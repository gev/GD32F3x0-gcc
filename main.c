#include "gd32f3x0.h"
#include "gd32f3x0_gpio.h"
#include "gd32f3x0_rcu.h"
#include <stdint.h>

int main()
{
	rcu_periph_clock_enable(RCU_GPIOA);
	gpio_mode_set(GPIOA, GPIO_MODE_OUTPUT, GPIO_PUPD_NONE, GPIO_PIN_15);
	gpio_output_options_set(GPIOA, GPIO_OTYPE_PP, GPIO_OSPEED_50MHZ, GPIO_PIN_15);
	while (1)
	{
		gpio_bit_set(GPIOA, GPIO_PIN_15);
		for (uint32_t x = 0; x < 10000000; x++)
			;
		gpio_bit_reset(GPIOA, GPIO_PIN_15);
		for (uint32_t x = 0; x < 10000000; x++)
			;
	}
}