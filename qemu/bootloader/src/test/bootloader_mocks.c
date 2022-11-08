#include <stdint.h>
#include <stdbool.h>

#include "bootloader.h"

#include "test/qemu_io.h"
#include "test/bootloader_mocks.h"
#include "test/bootloader_test_utils.h"

static uint32_t wfg_nc = 0;

static __attribute__((section(".fwimg"))) uint8_t memory[64] = {[0 ... 63] = 0xaa};

static uint8_t ssi_rd_buff[64] = {0};
static uint32_t ssi_rd_idx = 0;

static uint8_t ssi_wd_buff[64] = {0};
static uint32_t ssi_wd_idx = 0;

static int gpio_ctrl_reg = 0;
static int gpio_last_val = 0;
static int gpio_wait_cnt = 0;

static int ssi_ctrl_reg = 0;
static int ssi_wait_cnt = 0;
static uint8_t ssi_wd_buff_cache = 0;
static uint8_t ssi_rd_buff_cache = 0;

void mocks_reset(void)
{
    for (int i = 0; i < 64; i++) {
        ssi_rd_buff[i] = 0;
        ssi_wd_buff[i] = 0;
        memory[i] = 0;
    }
    ssi_rd_idx = 0;
    ssi_wd_idx = 0;
    wfg_nc = 0;

    gpio_ctrl_reg = 0;
    gpio_last_val = 0;
    gpio_wait_cnt = 0;

    ssi_ctrl_reg = 0;
    ssi_wait_cnt = 0;
    ssi_wd_buff_cache = 0;
    ssi_rd_buff_cache = 0;
}

void set_read_byte_read_buff(const uint8_t* vals, uint32_t vals_size)
{
    TEST_ASSERT(vals_size <= 64);
    if (vals_size > 64) {
        return;
    }

    for (int i = 0; i < vals_size; i++) {
        ssi_rd_buff[i] = vals[i];
    }
}

void set_memory(const uint8_t* vals, uint32_t vals_size)
{
    TEST_ASSERT(vals_size <= 64);
    if (vals_size > 64) {
        return;
    }

    for (int i = 0; i < vals_size; i++) {
        memory[i] = vals[i];
    }
}

const uint8_t* get_memory_ptr(void)
{
    return memory;
}

const uint8_t* get_send_byte_write_buff(void)
{
    return ssi_wd_buff;
}

///////// Bootloader mocks for the assembly side
///////// The bootloader will call these functions.



int rd_periph(const uint32_t* base_addr, uint8_t* val_read)
{
    uint32_t ba = (uint32_t)base_addr;

    if (ba == SSI_BASE) {
        register int res asm("a1") = ssi_rd_buff_cache;
    } else if (ba == GPIO_BASE) {
        if (gpio_wait_cnt < 3) {
            gpio_wait_cnt++;
        } else {
            gpio_last_val = gpio_last_val == 0 ? 1 : 0;
            gpio_wait_cnt = 0;
        }
        register int res asm("a1") = gpio_last_val;
    } else {
        TEST_ASSERT(false);
    }

    return 0;
}

int rd_per_ctrl(const uint32_t* base_addr, uint8_t* val_read)
{
    uint32_t ba = (uint32_t)base_addr;

    if (ba == SSI_BASE) {
        if ((ssi_ctrl_reg & 0x02) != 0) {
            if (ssi_wait_cnt < 3) {
                ssi_wait_cnt++;
            } else {
                // Perform actual transmission
                ssi_wd_buff[ssi_wd_idx] = ssi_wd_buff_cache;
                ssi_wd_idx++;

                ssi_rd_buff_cache = ssi_rd_buff[ssi_rd_idx];
                ssi_rd_idx++;

                ssi_wait_cnt = 0;
                ssi_ctrl_reg &= ~0x02;  // no lonber busy
                ssi_ctrl_reg |= 0x01;   // ready
            }
        }
        register int res asm("a1") = ssi_ctrl_reg;
    } else {
        TEST_ASSERT(false);
    }

    return 0;
}

int wr_periph(const uint32_t* base_addr, uint8_t val)
{
    uint32_t ba = (uint32_t)base_addr;

    if (ba == SSI_BASE) {
        ssi_wd_buff_cache = val;
    } else {
        TEST_ASSERT(false);
    }

    return 0;
}

int wr_per_ctrl(const uint32_t* base_addr, uint8_t val)
{
    uint32_t ba = (uint32_t)base_addr;

    if (ba == SSI_BASE) {
        if ((val & 0x04) != 0) {    // If send
            ssi_ctrl_reg |= 0x02;   // busy
        }
    } else {
        TEST_ASSERT(false);
    }

    return 0;
}
