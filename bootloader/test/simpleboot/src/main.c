#include <stdint.h>
#include <stdbool.h>

#include "bootloader.h"

#include "qemu_io.h"
#include "bootloader_mocks.h"
#include "bootloader_test_utils.h"
#include "bootloader_test_stdlib.h"

static uint8_t buff[32] = {0};

static void test_reset(void)
{
    cpu_reset();
    mocks_reset();
}

static void mprint(const uint8_t* p1, uint8_t p1_size)
{
    for (int i = 0; i < p1_size; i++) {
        int2ansi(p1[i], buff);
        puts(buff);

        if (i < (p1_size - 1)){
            puts(", ");
        }
    }
    puts("\n");
}

int test_wns_works(void)
{
    int rc = 0;

    test_reset();
    set_machine_state(ST_W_ST);
    set_write_final_state(ST_IDLE);

    bld_wr_next_state();
    int n = get_machine_state();
    rc += TEST_ASSERT(n == ST_W_RC);

    set_last_val_read(ESC_C);
    bld_wr_next_state();
    n = get_machine_state();
    rc += TEST_ASSERT(n == ST_W_RE);

    set_last_val_read(ESC_C);
    bld_wr_next_state();
    n = get_machine_state();
    rc += TEST_ASSERT(n == ST_W_RN);

    bld_wr_next_state();
    n = get_machine_state();
    rc += TEST_ASSERT(n == ST_W_RC);

    set_last_val_read(25);
    bld_wr_next_state();
    n = get_machine_state();
    rc += TEST_ASSERT(n == ST_W_RN);

    bld_wr_next_state();
    n = get_machine_state();
    rc += TEST_ASSERT(n == ST_W_RC);

    set_last_val_read(ESC_C);
    bld_wr_next_state();
    n = get_machine_state();
    rc += TEST_ASSERT(n == ST_W_RE);

    set_last_val_read(CMD_C);
    bld_wr_next_state();
    n = get_machine_state();
    rc += TEST_ASSERT(n == ST_IDLE);


    return rc;
}

int test_rns_works(void)
{
    int rc = 0;

    test_reset();
    set_machine_state(ST_R_ST);
    set_read_final_state(ST_IDLE);

    bld_rd_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_R_WRC);

    set_last_val_read(0);
    bld_rd_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_R_WRC);

    set_last_val_read(0);
    bld_rd_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_R_WRC);

    set_last_val_read(CMD_C);
    bld_rd_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_IDLE);


    return rc;
}

int test_ns_works(void)
{
    int rc = 0;

    test_reset();
    set_machine_state(ST_IDLE);
    set_write_final_state(ST_IDLE);
    set_read_final_state(ST_IDLE);

    bld_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_CMD);

    set_last_val_read(CMD_W);
    bld_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_W_ST);

    bld_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_W_RC);

    set_last_val_read(ESC_C);
    bld_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_W_RE);

    set_last_val_read(ESC_C);
    bld_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_W_RN);

    bld_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_W_RC);

    set_last_val_read(25);
    bld_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_W_RN);

    bld_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_W_RC);

    set_last_val_read(ESC_C);
    bld_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_W_RE);

    set_last_val_read(CMD_C);
    bld_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_IDLE);

    bld_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_CMD);

    set_last_val_read(CMD_R);
    bld_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_R_ST);

    bld_rd_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_R_WRC);

    set_last_val_read(0);
    bld_rd_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_R_WRC);

    set_last_val_read(0);
    bld_rd_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_R_WRC);

    set_last_val_read(CMD_C);
    bld_rd_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_IDLE);

    return rc;
}

int test_ns_no_cmd_works(void)
{
    int rc = 0;

    test_reset();
    set_machine_state(ST_IDLE);

    bld_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_CMD);

    set_last_val_read(25);
    bld_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_IDLE);

    bld_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_CMD);

    set_last_val_read(18);
    bld_next_state();
    rc += TEST_ASSERT(get_machine_state() == ST_IDLE);

    return rc;
}

int test_write_escape_works(void)
{
    test_reset();
    set_machine_state(ST_W_ST);
    set_write_final_state(ST_END);

    const uint8_t host_send_bytes[] = {
        3, 0, 2, 4, 6, 5, 6, 8, 10, ESC_C, CMD_C};
    set_read_byte_read_buff(host_send_bytes, sizeof(host_send_bytes));


    for (int i = 0; i < 100; i++) {
        bld_wr_exec_state();
        bld_wr_next_state();
    }

    const uint8_t exp_mem[] = {3, 0, 2, 4, 6, 5, 6, 8, 10};
    int rc = TEST_ASSERT(
        mcmp(exp_mem, get_memory_ptr(), sizeof(exp_mem)) == 0);
    return rc;
}

int test_write_escape_escape_works(void)
{
    test_reset();
    set_machine_state(ST_W_ST);
    set_write_final_state(ST_END);

    const uint8_t host_send_bytes[] = {
        30, 0, 2, 4, 6, ESC_C, ESC_C, 8, 10, ESC_C, CMD_C};
    set_read_byte_read_buff(host_send_bytes, sizeof(host_send_bytes));


    for (int i = 0; i < 100; i++) {
        bld_wr_exec_state();
        bld_wr_next_state();
    }

    const uint8_t exp_mem[] = {30, 0, 2, 4, 6, ESC_C, 8, 10};
    int rc = TEST_ASSERT(
        mcmp(exp_mem, get_memory_ptr(), sizeof(exp_mem)) == 0);
    return rc;
}

int test_write_addr_not_zero_works(void)
{
    test_reset();
    set_machine_state(ST_W_ST);
    set_write_final_state(ST_END);

    const uint8_t host_send_bytes[] = {
        3, 0, 5, 6, 8, 10, ESC_C, CMD_C};
    set_read_byte_read_buff(host_send_bytes, sizeof(host_send_bytes));

    set_mem_offset(2);

    for (int i = 0; i < 100; i++) {
        bld_wr_exec_state();
        bld_wr_next_state();
    }

    const uint8_t exp_mem[] = {0, 0, 3, 0, 5, 6, 8, 10};
    int rc = TEST_ASSERT(
        mcmp(exp_mem, get_memory_ptr(), sizeof(exp_mem)) == 0);
    return rc;
}

int test_cpu_write(void)
{
    int rc = test_write_escape_works();
    rc += test_write_escape_escape_works();
    rc += test_write_addr_not_zero_works();
    return rc;
}

int test_read_close_works(void)
{
    int rc = 0;

    test_reset();
    set_machine_state(ST_R_ST);
    set_read_final_state(ST_END);

    const uint8_t host_send_bytes[] = {0, 0, 0, 0, 0, 0, CMD_C};
    set_read_byte_read_buff(host_send_bytes, sizeof(host_send_bytes));

    const uint8_t memory[] = {5, 1, 2, 3, 4, 7, 1};
    set_memory(memory, sizeof(memory));


    for (int i = 0; i < 100; i++) {
        bld_rd_exec_state();
        bld_rd_next_state();
    }

    const uint8_t exp_sent_b[] = {5, 1, 2, 3, 4, 7, 1};
    rc = TEST_ASSERT(mcmp(exp_sent_b,
                          get_send_byte_write_buff(),
                          sizeof(exp_sent_b)) == 0);
    return rc;
}

int test_read_escape_offset_nonzero_works(void)
{
    int rc = 0;

    test_reset();
    set_machine_state(ST_R_ST);
    set_read_final_state(ST_END);
    set_mem_offset(2);

    const uint8_t host_send_bytes[] = {0, 0, 0, 0, CMD_C};
    set_read_byte_read_buff(host_send_bytes, sizeof(host_send_bytes));

    const uint8_t memory[] = {5, 1, 2, 3, 4, 7, 1, 9, 8};
    set_memory(memory, sizeof(memory));


    for (int i = 0; i < 100; i++) {
        bld_rd_exec_state();
        bld_rd_next_state();
    }

    const uint8_t exp_sent_b[] = {2, 3, 4, 7, 1};
    rc = TEST_ASSERT(mcmp(exp_sent_b,
                          get_send_byte_write_buff(),
                         sizeof(exp_sent_b)) == 0);
    return rc;
}

int test_cpu_read(void)
{
    int rc = test_read_close_works();
    rc += test_read_escape_offset_nonzero_works();
    return rc;
}

int test_cpu_gen_read_only(void)
{
    test_reset();
    set_machine_state(ST_IDLE);
    set_read_final_state(ST_END);

    const uint8_t host_send_bytes[] = {CMD_R, 0, 0, 0, 0, 0, 0, CMD_C};
    set_read_byte_read_buff(host_send_bytes, sizeof(host_send_bytes));

    const uint8_t memory[] = {5, 1, 2, 3, 4, 7, 1};
    set_memory(memory, sizeof(memory));


    for (int i = 0; i < 100; i++) {
        bld_exec_state();
        bld_next_state();
    }

    const uint8_t exp_sent_b[] = {
        0 /* dummy byte to read CMD_R */, 5, 1, 2, 3, 4, 7, 1};
    int rc = TEST_ASSERT(mcmp(exp_sent_b,
                              get_send_byte_write_buff(),
                              sizeof(exp_sent_b)) == 0);
    return rc;
}

int test_cpu_gen_write_only(void)
{
    test_reset();
    set_machine_state(ST_IDLE);
    set_write_final_state(ST_END);

    const uint8_t host_send_bytes[] = {
        CMD_W, 3, 0, 2, 4, 6, 5, 6, 8, 10, ESC_C, CMD_C};
    set_read_byte_read_buff(host_send_bytes, sizeof(host_send_bytes));


    for (int i = 0; i < 100; i++) {
        bld_exec_state();
        bld_next_state();
    }

    const uint8_t exp_sent_b[] = {3, 0, 2, 4, 6, 5, 6, 8, 10};
    int rc = TEST_ASSERT(mcmp(exp_sent_b,
                              get_memory_ptr(),
                              sizeof(exp_sent_b)) == 0);
    return rc;
}

// This needs to be declared here to avoid memcpy etc.
static const uint8_t __host_send_bytes[] = {
    CMD_W, 3, 0, 2, 4, 6, 5, 6, 8, 10, ESC_C, CMD_C,
    CMD_R, 0, 0, 0, 0, 0, 0, 0, 0, CMD_C};

int test_cpu_gen_write_then_read(void)
{
    test_reset();
    set_write_final_state(ST_IDLE);
    set_read_final_state(ST_END);

    set_read_byte_read_buff(__host_send_bytes, sizeof(__host_send_bytes));


    for (int i = 0; i < 100; i++) {
        bld_exec_state();
        bld_next_state();
    }

    const uint8_t expec_mem[] = {3, 0, 2, 4, 6, 5, 6, 8, 10};
    int rc = TEST_ASSERT(mcmp((uint8_t*)expec_mem,
                              (uint8_t*)get_memory_ptr(),
                              sizeof(expec_mem)) == 0);

    // First row of zeros is all the zeros sent to read the CMD_W part
    // Int The second row, the first zero is the one sent to read CMD_R
    const uint8_t expec_sent_b[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                                    0, 3, 0, 2, 4, 6, 5, 6, 8, 10};
    rc = TEST_ASSERT(mcmp(expec_sent_b,
                          get_send_byte_write_buff(),
                          sizeof(expec_sent_b)) == 0);
    return rc;
}

int test_cpu_gen(void)
{
    int rc = test_cpu_gen_read_only();
    rc += test_cpu_gen_write_only();
    rc += test_cpu_gen_write_then_read();
    return rc;
}

int test_cpu_jump(void)
{
    test_reset();
    set_machine_state(ST_IDLE);
    set_write_final_state(ST_IDLE);
    set_jump_final_state(ST_END);

    const uint32_t host_send_program[] = {
        0x00400bef,     // test_program:    jal     s7, get_pc
        0xffcb8b93,     // get_pc:          addi    s7, s7, -4
        0x00008067      //                  jr      ra
    };

    const uint8_t host_send_program_b[] = {
        CMD_W,
        0xef, 0x0b, 0x40, 0x00,
        0x93, 0x8b, 0xcb, 0xff, 0xff,
        0x67, 0x80, 0x00, 0x00,
        ESC_C, CMD_C,
        CMD_J
    };

    set_read_byte_read_buff(host_send_program_b, sizeof(host_send_program_b));

    register int res asm("s7");
    TEST_ASSERT(res == 0);

    for (int i = 0; i < 100; i++) {
        bld_exec_state();
        bld_next_state();
    }

    const uint8_t* exp_sent_b = (const uint8_t*)host_send_program;
    int rc = TEST_ASSERT(mcmp(exp_sent_b,
                              get_memory_ptr(),
                              sizeof(exp_sent_b)) == 0);

    register uint32_t res2 asm("s7");
    extern uint8_t** _fwimg;
    TEST_ASSERT(res2 == (uint32_t)&_fwimg);

    return rc;
}

int test_main(void)
{
    int rc = 0;
    rc += test_wns_works();
    rc += test_rns_works();
    rc += test_ns_works();
    rc += test_ns_no_cmd_works();
    rc += test_cpu_write();
    rc += test_cpu_read();
    rc += test_cpu_gen();
    rc += test_cpu_jump();

    if (rc == 0) {
        puts("Success\n");
    }
    return 0;
}
