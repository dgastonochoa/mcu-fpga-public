#ifndef BLD_TEST_STDLIB_H
#define BLD_TEST_STDLIB_H

#include <stdint.h>

void int2ansi(int n, char* res);

int mcmp(const uint8_t* p1, const uint8_t* p2, uint32_t p1_size);

int mcpy(const uint8_t* p1, uint8_t* p2, uint32_t p1_size);

#endif // BLD_TEST_STDLIB_H
