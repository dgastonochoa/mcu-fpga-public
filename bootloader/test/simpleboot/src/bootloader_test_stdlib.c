#include "bootloader_test_stdlib.h"

void int2ansi(int n, char* res)
{
    if (n == 0) {
        *res = '0';
        res++;
    } else {
        while (n != 0) {
            *res = ((n % 10) + 48);
            n /= 10;
            res++;
        }
    }
    *res = 0;
}

int mcmp(const uint8_t* p1, const uint8_t* p2, uint32_t p1_size)
{
    if (p1_size > 64) {
        return -1;
    }

    for (int i = 0; i < p1_size; i++) {
        if (p1[i] != p2[i]) {
            return -1;
        }
    }

    return 0;
}

int mcpy(const uint8_t* p1, uint8_t* p2, uint32_t p1_size)
{
    for (int i = 0; i < p1_size; i++) {
        p2[i] = p1[i];
    }

    return 0;
}
