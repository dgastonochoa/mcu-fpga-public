// Color    LED(s) PortF
// dark     ---    0
// red      R--    0x02
// blue     --B    0x04
// green    -G-    0x08
// yellow   RG-    0x0A
// sky blue -GB    0x0C
// white    RGB    0x0E
// pink     R-B    0x06

#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <errno.h>

#include "inc/hw_memmap.h"
#include "inc/hw_types.h"

#include "driverlib/sysctl.h"
#include "driverlib/uart.h"
#include "driverlib/gpio.h"
#include "driverlib/pin_map.h"
#include "driverlib/ssi.h"

#include "utils/uartstdio.h"

#include "program.h"

#define RECV_BUFF_SIZE  2048
#define BUFF_SIZE       2048

/**
 * @brief Buffer to read back the written program
 *
 */
static uint8_t recv_buff[RECV_BUFF_SIZE] = {0};

/**
 * @brief Aux. buffer to encode the write and read
 * messages.
 *
 */
static uint8_t buff[BUFF_SIZE] = {0};

/**
 * @brief Init. SPI slave. Config.: 8 bits, PHA = 0, POL = 1,
 * 4 MHz.
 *
 */
static void SPISlaveInit(void)
{
    SysCtlPeripheralEnable(SYSCTL_PERIPH_SSI1);

    SSIConfigSetExpClk(
        SSI1_BASE,
        SysCtlClockGet(),
        SSI_FRF_MOTO_MODE_2,
        SSI_MODE_SLAVE,
        1000000,
        8
    );

    SSIEnable(SSI1_BASE);
}

static void UARTInit(void)
{
    SysCtlPeripheralEnable(SYSCTL_PERIPH_UART0);
    UARTStdioConfig(0, 115200, SysCtlClockGet());
}

/**
 * @brief Init. the required GPIOs.
 *
 */
static void GPIOInit(void)
{
    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOA);
    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOD);

    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOE);
    GPIODirModeSet(GPIO_PORTE_BASE, GPIO_PIN_1, GPIO_DIR_MODE_OUT);
    GPIOPadConfigSet(GPIO_PORTE_BASE, GPIO_PIN_1,
                     GPIO_STRENGTH_8MA,
                     GPIO_PIN_TYPE_STD_WPD);

    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOF);

    // Config. PF2 and 3 as outputs to use the LED.
    GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, GPIO_PIN_2);
    GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, GPIO_PIN_3);
}

/**
 * @brief Init. GPIOs alternate functions.
 *
 */
static void GPIOPinMux(void)
{
    // UART
    GPIOPinConfigure(GPIO_PA0_U0RX);
    GPIOPinConfigure(GPIO_PA1_U0TX);
    GPIOPinTypeUART(GPIO_PORTA_BASE, GPIO_PIN_0 | GPIO_PIN_1);

    // SPI slave
    GPIOPinConfigure(GPIO_PD0_SSI1CLK);
    GPIOPinConfigure(GPIO_PD1_SSI1FSS);
    GPIOPinConfigure(GPIO_PD2_SSI1RX);
    GPIOPinConfigure(GPIO_PD3_SSI1TX);
    GPIOPinTypeSSI(GPIO_PORTD_BASE, GPIO_PIN_0 | GPIO_PIN_1 | GPIO_PIN_2 | GPIO_PIN_3);
}

#define     CMD_C       2           // command close
#define     CMD_W       3           // command open-to-write
#define     CMD_R       4           // command open-to-read
#define     CMD_J       5           // command open-to-read
#define     ESC_C       0xff        // escape byte

#define     LOG_INF     UARTprintf

int transmit(uint8_t b, uint8_t* rb)
{
    while (SSIBusy(SSI1_BASE)) {}
    SSIDataPut(SSI1_BASE, b);
    GPIOPinWrite(GPIO_PORTE_BASE, GPIO_PIN_1, GPIO_PIN_1);
    SysCtlDelay(1000);
    GPIOPinWrite(GPIO_PORTE_BASE, GPIO_PIN_1, 0);
    while (SSIBusy(SSI1_BASE)) {}

    uint32_t v = 0;
    int rc = SSIDataGetNonBlocking(SSI1_BASE, &v);
    if (rc == 0) {
        return rc;
    }
    *rb = v & 0xff;

    return 0;
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

    return rc;
}

int read_memory(uint8_t* recv, uint32_t recv_size, uint32_t nbytes)
{
    if (recv_size < nbytes) {
        LOG_INF("Buffer too small\n");
        return -EMSGSIZE;
    }

    int msg_size = read_msg_create(buff, &buff[sizeof(buff) - 1], nbytes);
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

        if (rc < 0) {
            return rc;
        }
    }
    LOG_INF("\n");
    return 0;
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

uint8_t encode(char c)
{
    switch (c) {
        case 'w': return CMD_W;
        case 'r': return CMD_R;
        case 'c': return CMD_C;
        case 'j': return CMD_J;
        case 'e': return ESC_C;
        default:  return c;
    }
}

void enter_console(void)
{
    UARTprintf("------- Console enabled -------\n");

    int rc = 0;
    char c = 0;
    uint8_t b = 0;
    uint8_t rb = 0;
    while (1) {
        c = UARTgetc();
        b = encode(c);
        rc = transmit(b, &rb);
        UARTprintf(
            "Sent byte 0x%x, recv. byte 0x%x, error %d\n", b, rb, rc);
    }
}

int upd_fwimg(const uint32_t* fwimg, uint32_t fwimg_size_words)
{
    const uint32_t fwimg_size_bytes = fwimg_size_words * sizeof(uint32_t);

    int rc = transmit_fwimg(fwimg, fwimg_size_words);
    if (rc < 0) {
        return rc;
    }

    rc = read_memory(recv_buff, sizeof(recv_buff), fwimg_size_bytes);
    if (rc < 0) {
        return rc;
    }

    int cmp_res = memcmp((const uint8_t*)fwimg, recv_buff, fwimg_size_bytes);
    if (cmp_res != 0) {
        LOG_INF("Read buffer doesn't match the data sent\n");
        print_buffer(recv_buff, sizeof(fwimg) - 1);
        return -EIO;
    } else {
        LOG_INF("Program verified\n");
    }

    return 0;
}

int run_fwimg(void) {
    uint8_t rb = 0;
    return transmit(CMD_J, &rb);
}

#define     PROGRAM_APP 1
int main(void)
{
    GPIOInit();
    GPIOPinMux();
    SPISlaveInit();
    UARTInit();

    GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_3, GPIO_PIN_3);

    // Flush any residual message
    uint32_t buff[128] = {0};
    while (SSIDataGetNonBlocking(SSI1_BASE, buff) != 0) {}

    #ifdef LED_BLINK_APP
        const uint32_t led_blink_fw[] = {
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

        const uint32_t led_blink_fw_size_words =
            sizeof(led_blink_fw) / sizeof(*led_blink_fw);

        upd_fwimg(led_blink_fw, led_blink_fw_size_words);

    #elif defined(PROGRAM_APP)
        upd_fwimg(program, program_size_words);

    #else
        #error Undefined fw.

    #endif

    // enter_console();
    run_fwimg();

    while (1) {
        uint32_t rd = 0;
        SSIDataGet(SSI1_BASE, &rd);
        UARTprintf("%x\r\n", rd);
    }
}

/**
 * Leave this symbol here for Keil uVision.
 *
 */
int __main(void) {
    return main();
}
