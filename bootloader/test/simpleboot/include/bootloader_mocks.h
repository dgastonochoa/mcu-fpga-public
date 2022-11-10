#ifndef BOOTLOADER_MOCKS_H
#define BOOTLOADER_MOCKS_H

#include <stdint.h>

/**
 * @brief Bootloader mocks. The bootloader is expected
 * to wait for a GPIO signal, to read/write from/to an
 * SSI interface, and to read/write from/to memory.
 *
 * This module provides functions to simulate the GPIO,
 * the SSI and the memory. This is done by providing
 * several buffers to/from which the above elements
 * will read/write, so the results can be checked later
 *
 */

/**
 * @brief Reset all mocks and related buffers etc.
 *
 */
void mocks_reset(void);

/**
 * @brief Set the amount of times the wait for GPIO
 * mock is expected to be called.
 *
 */
void set_wfg_expected_calls(int nc);

/**
 * @brief Get the current remaining calls of the
 * wait for GPIO mock.
 *
 */
int get_wfg_num_calls(void);

/**
 * @brief Get a pointer to the buffer to which the
 * SSI mock will write.
 *
 * This simulates the values that the bootloader would
 * send to a device.
 *
 */
const uint8_t* get_send_byte_write_buff(void);

/**
 * @brief Set the values of the buffer from which the
 * SSI mock will read.
 *
 * This simulates the values a device would send to the
 * bootloader.
 *
 */
void set_read_byte_read_buff(const uint8_t* vals, uint32_t vals_size);

/**
 * @brief Set the values of the buffer from which the
 * memory mock will read.
 *
 * This simulates the bootloader device memory.
 *
 */
void set_memory(const uint8_t* vals, uint32_t vals_size);

/**
 * @brief Get a pointer to the buffer to which the
 * memory mock will write.
 *
 * This simulates the bootloader device memory.
 *
 */
const uint8_t* get_memory_ptr(void);

#endif
