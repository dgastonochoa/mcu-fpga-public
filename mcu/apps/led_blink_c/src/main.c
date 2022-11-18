#include <stdint.h>
#include <stdbool.h>

volatile uint32_t* const LED_BASE = (volatile uint32_t* const)0x80000040;

const uint32_t TIMEOUT = 8333333; // 1 second in ticks @ 25 MHz

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
        *LED_BASE = 0;
        busy_wait(TIMEOUT);
        *LED_BASE = 3;
        busy_wait(TIMEOUT);
    }
}
