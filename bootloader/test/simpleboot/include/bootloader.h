#ifndef BOOTLOADER_H
#define BOOTLOADER_H

#define    SSI_BASE    0x80000000  // SSI periph base
#define    LED_BASE    0x80000040  // LEDs periph base
#define    GPIO_BASE   0x80000080  // GPIOs peiph base

#define    CMD_C       2           // command close
#define    CMD_W       3           // command open-to-write
#define    CMD_R       4           // command open-to-read
#define    CMD_J       5           // command jump to the fwimg area
#define    ESC_C       0xff        // escape byte

#define    ST_IDLE     0           // general idle
#define    ST_CMD      1           // general cmd. received
#define    ST_W_ST     2           // write start
#define    ST_W_RC     3           // write read char.
#define    ST_W_RE     4           // write escaped char. read
#define    ST_W_RN     5           // write normal char. read
#define    ST_R_ST     6           // read start
#define    ST_R_WRC    7           // read write-read char.
#define    ST_J        8           // jump
#define    ST_END      255         // general end (debug)

// Test interface

int set_write_final_state(int s);
int set_read_final_state(int s);
int set_jump_final_state(int s);
int set_machine_state(int s);
int get_machine_state(void);
int set_last_val_read(int s);
int set_memory_ptr(int s);
int set_mem_offset(int s);
int cpu_reset(void);
int bld_wr_next_state(void);
int bld_wr_exec_state(void);
int bld_rd_next_state(void);
int bld_rd_exec_state(void);
int bld_next_state(void);
int bld_exec_state(void);

////////////////////////////

#endif // BOOTLOADER_H
