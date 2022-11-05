#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>

#define     CMD_C       2           // command close
#define     CMD_W       3           // command open-to-write
#define     CMD_R       4           // command open-to-read
#define     ESC_C       0xff        // escape byte

#define     LOG_INF     printf

static int state = 0;

static uint8_t mem[256] = {0};
static int idx = 0;

int transmit(uint8_t b, uint8_t* rb)
{
    if (state == 0) {
        switch (b) {
            case CMD_W:
                *rb = 0;
                state = 1;
                idx = 0;
                return 0;

            case CMD_R:
                *rb = 0;
                state = 2;
                idx = 0;
                return 0;

            default:
                return -EINVAL;
        }
    } else {
        switch (state) {
            case 1:
                if (b == ESC_C) {
                    state = 3;
                    *rb = 0;
                } else {
                    *rb = 0;
                    mem[idx] = b;
                    idx++;
                }
                return 0;

            case 2:
                *rb = mem[idx];
                idx++;
                if (b == CMD_C) {
                    state = 0;
                }
                return 0;

            case 3:
                if (b == ESC_C) {
                    *rb = 0;
                    mem[idx] = b;
                    idx++;
                    state = 1;
                } else if (b == CMD_C) {
                    *rb = 0;
                    state = 0;
                } else {
                    *rb = -EINVAL;
                    return -EINVAL;
                }
                return 0;

            default:
                return -EINVAL;
        }
    }
}

uint8_t* encode_data(const uint8_t* d_ptr,
                     const uint8_t* d_end,
                     uint8_t* ed_ptr,
                     uint8_t* ed_end)
{
    do {
        if (*d_ptr == ESC_C) {
            *ed_ptr = ESC_C;
            ed_ptr++;
        }

        *(ed_ptr++) = *(d_ptr++);

        if (ed_ptr > ed_end) {
            return NULL;
        }

    } while (d_ptr <= d_end);

    return ed_ptr;
}

int write_msg_encode(const uint8_t* d_ptr,
                     const uint8_t* d_end,
                     uint8_t* ed_ptr,
                     uint8_t* ed_end)
{
    uint8_t* aux = ed_ptr;

    if (ed_ptr > ed_end) {
        return -EMSGSIZE;
    }
    *(ed_ptr++) = CMD_W;

    ed_ptr = encode_data(d_ptr, d_end, ed_ptr, ed_end);
    if (ed_ptr == NULL) {
        return -EMSGSIZE;
    }

    *(ed_ptr++) = ESC_C;

    if (ed_ptr > ed_end) {
        return -EMSGSIZE;
    }
    *ed_ptr = CMD_C;

    return (int)(ed_ptr - aux + 1);
}

int read_msg_create(uint8_t* ed_ptr,
                    uint8_t* ed_end,
                    uint32_t n_bytes)
{
    uint8_t* aux = ed_ptr;

    if ((ed_ptr + 1 + n_bytes) > ed_end) {
        return -EMSGSIZE;
    }

    *(ed_ptr++) = CMD_R;
    memset(ed_ptr, 0, n_bytes - 1);
    ed_ptr += n_bytes - 1;
    *ed_ptr = CMD_C;

    return (int)(ed_ptr - aux + 1);
}


int transmit_fwimg(const uint32_t* fwimg, uint32_t size)
{
    const uint8_t* fwimg_b = (const uint8_t*)fwimg;
    uint32_t size_bytes = size * sizeof(uint32_t);

    // Encode write message
    uint8_t buff[128] = {0};
    int msg_size = write_msg_encode(fwimg_b,
                                    &fwimg_b[size_bytes - 1],
                                    buff,
                                    &buff[sizeof(buff) - 1]);
    if (msg_size < 0) {
        return msg_size;
    }


    // Send header
    int rc = 0;
    uint8_t rb = 0;
    rc = transmit(buff[0], &rb);
    LOG_INF(
        "Sent byte 0x%x, recv. byte 0x%x, error %d\n", buff[0], rb, rc);
    if (rc < 0) {
        return rc;
    }


    // Send payload
    const uint8_t* payload = &buff[1];
    const uint32_t payload_size = msg_size - 1 - 2;

    LOG_INF("Sending payload:\n");
    for (int i = 0; i < payload_size; i++) {
        rc = transmit(payload[i], &rb);

        if (i % 10 == 0) {
            LOG_INF("%02d: ", i);
        }

        LOG_INF("%02x ", payload[i]);

        if ((i+1) % 10 == 0) {
            LOG_INF("\n");
        }

        if (rc < 0) {
            return rc;
        }
    }
    LOG_INF("\n");


    // Send footer
    uint8_t* footer = &buff[msg_size - 2];
    rc = transmit(footer[0], &rb);
    LOG_INF(
        "Sent byte 0x%x, recv. byte 0x%x, error %d\n", buff[msg_size - 2], rb, rc);
    if (rc < 0) {
        return rc;
    }

    rc = transmit(footer[1], &rb);
    LOG_INF(
        "Sent byte 0x%x, recv. byte 0x%x, error %d\n", buff[msg_size - 1], rb, rc);
    if (rc < 0) {
        return rc;
    }
}

int read_memory(uint8_t* recv, uint32_t recv_size, uint32_t nbytes)
{
    if (recv_size < nbytes) {
        LOG_INF("Buffer too small\n");
        return -EMSGSIZE;
    }

    uint8_t buff[128] = {0};
    int msg_size = read_msg_create(buff, &buff[127], nbytes);
    if (msg_size < 0) {
        LOG_INF("Error creating read message\n");
        return -1;
    }

    if ((msg_size - 1) != nbytes) {
        LOG_INF("Unexpected read message size\n");
        return -EMSGSIZE;
    }

    // Send header
    int rc = 0;
    uint8_t rb = 0;
    rc = transmit(buff[0], &rb);
    if (rc < 0) {
        return rc;
    }


    // Send payload
    LOG_INF("Receiving data:\n");
    const uint8_t* payload = &buff[1];
    for (int i = 0; i < msg_size - 1; i++) {
        rc = transmit(payload[i], &recv[i]);

        if (i % 10 == 0) {
            LOG_INF("%02d: ", i);
        }

        LOG_INF("%02x ", recv[i]);

        if ((i+1) % 10 == 0) {
            LOG_INF("\n");
        }
    }
    LOG_INF("\n");
}

void print_buffer(const uint8_t* d, int d_size)
{
    for (int i = 0; i < d_size; i++) {
        if (i > 9 && (i % 10 == 0)) {
            LOG_INF("\n");
        }

        LOG_INF("%02x ", d[i]);
    }

    LOG_INF("\n");
}

void main(void)
{
    const uint32_t fwimg[] = {
        0x800005b7,
        0x04058593,
        0x007f29b7,
        0x00100293,
        0x00b29293,
        0x005989b3,
        0x01598993,
        0x00000a13,
        0x01300533,
        0x01c000ef,
        0x0145a023,
        0x000a0663,
        0x00000a13,
        0xfedff06f,
        0x00100a13,
        0xfe5ff06f,
        0xfff50513,
        0xfe051ee3,
        0x00008067
    };

    int rc = transmit_fwimg(fwimg, sizeof(fwimg) / sizeof(*fwimg));
    if (rc < 0) {
        return;
    }

    uint8_t recv_buff[128] = {0};
    rc = read_memory(recv_buff, sizeof(recv_buff), sizeof(fwimg));
    if (rc < 0) {
        return;
    }


    const uint8_t* fwimg_b = (const uint8_t*)fwimg;
    int cmp_res = memcmp(fwimg_b, recv_buff, sizeof(fwimg));
    if (cmp_res != 0) {
        LOG_INF("Read buffer doesn't match the data sent\n");
        print_buffer(recv_buff, sizeof(fwimg) - 1);
    }
}