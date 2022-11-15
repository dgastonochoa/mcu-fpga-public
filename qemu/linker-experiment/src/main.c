#include <stdint.h>
#include <stdbool.h>

static volatile uint32_t* const LED_BASE = (volatile uint32_t* const)0x80000040;

static const uint32_t TIMEOUT = 1;

static __attribute__((section(".tss"))) volatile uint32_t state = 0xDEADC0DE;

static void set_leds(uint8_t v)
{
    // *LED_BASE = v;
    ((void)v);
}

static void busy_wait(uint32_t t)
{
    // Make sure @param{t} is in $a0
    register int res asm("a0") = t;

    asm volatile (
        "busy_wait_loop:\n"
        "       addi   a0, a0, -1\n"
        "       bne    a0, x0, busy_wait_loop\n"
    );
}

void main(void)
{
    while (true) {
        busy_wait(TIMEOUT);
        set_leds(0);
        busy_wait(TIMEOUT);
        set_leds(1);

        state++;
    }
}
