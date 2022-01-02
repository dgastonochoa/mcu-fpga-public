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

#define PART_TM4C1230C3PM 1

#include "inc/hw_memmap.h"
#include "inc/hw_types.h"
#include "inc/hw_i2c.h"

#include "driverlib/sysctl.h"
#include "driverlib/uart.h"
#include "driverlib/gpio.h"
#include "driverlib/pin_map.h"
#include "driverlib/ssi.h"
#include "driverlib/i2c.h"

#include "utils/uartstdio.h"

#define LED_COLOR_DARK  0x00
#define LED_COLOR_RED   0x02
#define LED_COLOR_BLUE  0x04
#define LED_COLOR_GREEN 0x08

static uint32_t I2C2_SLAVE_ADDRESS = 0x55;
static uint32_t I2C3_SLAVE_ADDRESS = 0x77;

static void delay(void)
{
    unsigned long volatile time;
    time = 145448;  // 0.1sec
    while(time){
        time--;
    }
}

static void init_gpio_ports(void)
{
    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOA);
    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOB);
    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOD);
    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOE);
    SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOF);

    delay();
}

static void init_uart(void)
{
    SysCtlPeripheralEnable(SYSCTL_PERIPH_UART0);
    delay();

    GPIOPinConfigure(GPIO_PA0_U0RX);
    GPIOPinConfigure(GPIO_PA1_U0TX);
    GPIOPinTypeUART(GPIO_PORTA_BASE, GPIO_PIN_0 | GPIO_PIN_1);
    UARTStdioConfig(0, 115200, 16000000);
}

static void init_i2c0(void)
{
    SysCtlPeripheralEnable(SYSCTL_PERIPH_I2C0);
    delay();

    GPIOPinConfigure(GPIO_PB2_I2C0SCL);
    GPIOPinConfigure(GPIO_PB3_I2C0SDA);

    GPIOPinTypeI2CSCL(GPIO_PORTB_BASE, GPIO_PIN_2);
    GPIOPinTypeI2C(GPIO_PORTB_BASE, GPIO_PIN_3);

    I2CMasterGlitchFilterConfigSet(I2C0_BASE, I2C_MASTER_GLITCH_FILTER_DISABLED);
    I2CMasterInitExpClk(I2C0_BASE, SysCtlClockGet(), false);

    // false -> master will send, not receive.
    I2CMasterSlaveAddrSet(I2C0_BASE, I2C2_SLAVE_ADDRESS, false);
}

static void init_i2c2(void)
{
    SysCtlPeripheralEnable(SYSCTL_PERIPH_I2C2);
    delay();

    GPIOPinConfigure(GPIO_PE4_I2C2SCL);
    GPIOPinConfigure(GPIO_PE5_I2C2SDA);
    GPIOPinTypeI2CSCL(GPIO_PORTE_BASE, GPIO_PIN_4);
    GPIOPinTypeI2C(GPIO_PORTE_BASE, GPIO_PIN_5);
    I2CSlaveEnable(I2C2_BASE);
    I2CSlaveInit(I2C2_BASE, I2C2_SLAVE_ADDRESS);
}

static void init_i2c3(void)
{
    SysCtlPeripheralEnable(SYSCTL_PERIPH_I2C3);
    delay();

    GPIOPinConfigure(GPIO_PD0_I2C3SCL);
    GPIOPinConfigure(GPIO_PD1_I2C3SDA);
    GPIOPinTypeI2CSCL(GPIO_PORTD_BASE, GPIO_PIN_0);
    GPIOPinTypeI2C(GPIO_PORTD_BASE, GPIO_PIN_1);
    I2CSlaveEnable(I2C3_BASE);
    I2CSlaveInit(I2C3_BASE, I2C3_SLAVE_ADDRESS);
}

static void config_gpios_init(void)
{
    // Config. PF1 to be used as reset pin for the slave SPI device.
    GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, GPIO_PIN_1);

    // Config. PF2 and 3 as outputs to use the LED.
    // TODO Move this to a different place.
    GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, GPIO_PIN_2);
    GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, GPIO_PIN_3);

    GPIOPinTypeGPIOInput(GPIO_PORTF_BASE, GPIO_PIN_4);
    GPIOPadConfigSet(GPIO_PORTF_BASE,
                     GPIO_PIN_4,
                     GPIO_STRENGTH_2MA,
                     GPIO_PIN_TYPE_STD_WPU);

    GPIOPinTypeGPIOInput(GPIO_PORTD_BASE, GPIO_PIN_2);
    GPIOPadConfigSet(GPIO_PORTD_BASE,
                     GPIO_PIN_2,
                     GPIO_STRENGTH_2MA,
                     GPIO_PIN_TYPE_STD_WPD);

    GPIOPinTypeGPIOInput(GPIO_PORTD_BASE, GPIO_PIN_3);
    GPIOPadConfigSet(GPIO_PORTD_BASE,
                     GPIO_PIN_3,
                     GPIO_STRENGTH_2MA,
                     GPIO_PIN_TYPE_STD_WPD);

    GPIOPinTypeGPIOOutput(GPIO_PORTD_BASE, GPIO_PIN_6);
}

static void send_reset(void)
{
    GPIOPinWrite(GPIO_PORTD_BASE, GPIO_PIN_6, 0);
    delay();
    GPIOPinWrite(GPIO_PORTD_BASE, GPIO_PIN_6, GPIO_PIN_6);
    delay();
    GPIOPinWrite(GPIO_PORTD_BASE, GPIO_PIN_6, 0);
}

static void ndelay(uint32_t n)
{
    for (uint32_t i = 0; i < n; i++) {
        delay();
    }
}

int main(void)
{
    init_gpio_ports();
    init_uart();
    init_i2c0();
    init_i2c2();
    init_i2c3();
    config_gpios_init();

    send_reset();

    UARTprintf("clk freq.: %u\r\n", SysCtlClockGet());

    uint8_t i2c_slave2_data = 0;
    uint8_t i2c_slave3_data = 0;
    uint8_t sl2_data = 0;
    uint8_t sl3_data = 0;
    uint8_t i2c_master_write_data = 0;

    uint8_t sw2_last_val = 1;
    int sw2 = 0, pd2 = 0, pd3 = 0;
    bool is_master_read_op = 0, is_slave_3 = 0;
    while(1) {

        sw2 = GPIOPinRead(GPIO_PORTF_BASE, GPIO_PIN_4);

        if (!sw2 && sw2_last_val) {
            if (!I2CMasterBusy(I2C0_BASE)) {
                pd2 = GPIOPinRead(GPIO_PORTD_BASE, GPIO_PIN_2);
                pd3 = GPIOPinRead(GPIO_PORTD_BASE, GPIO_PIN_3);

                if (pd2 != is_master_read_op || pd3 != is_slave_3) {
                    is_master_read_op = (pd2 != 0);
                    is_slave_3 = (pd3 != 0);

                    uint8_t addr = (is_slave_3 ? I2C3_SLAVE_ADDRESS : I2C2_SLAVE_ADDRESS);
                    I2CMasterSlaveAddrSet(I2C0_BASE,
                                          addr,
                                          is_master_read_op);

                    UARTprintf("master addr, read = %x, %d\r\n", addr, is_master_read_op, i2c_master_write_data);
                }

                if (!is_master_read_op) {
                    UARTprintf("master sending data %x\r\n", i2c_master_write_data);

                    I2CMasterDataPut(I2C0_BASE, i2c_master_write_data);
                    I2CMasterControl(I2C0_BASE, I2C_MASTER_CMD_SINGLE_SEND);
                    i2c_master_write_data++;
                } else {
                    I2CMasterControl(I2C0_BASE, I2C_MASTER_CMD_SINGLE_RECEIVE);
                    uint8_t master_read_data = I2CMasterDataGet(I2C0_BASE);

                    UARTprintf("master read data %x\r\n", master_read_data);
                }

            }
        }

        if ((I2CSlaveStatus(I2C2_BASE) & I2C_SLAVE_ACT_RREQ)) {
            sl2_data = I2CSlaveDataGet(I2C2_BASE);
            UARTprintf("sl2_data: %x\r\n", sl2_data);
        }

        if ((I2CSlaveStatus(I2C2_BASE) & I2C_SLAVE_ACT_TREQ)) {
            I2CSlaveDataPut(I2C2_BASE, 2*i2c_slave2_data);
            UARTprintf("i2c2 slave 2 rts, data written: %x\r\n", 2*i2c_slave2_data);
            i2c_slave2_data++;
        }

        if ((I2CSlaveStatus(I2C3_BASE) & I2C_SLAVE_ACT_RREQ)) {
            sl3_data = I2CSlaveDataGet(I2C3_BASE);
            UARTprintf("sl3_data: %x\r\n", sl3_data);
        }

        if ((I2CSlaveStatus(I2C3_BASE) & I2C_SLAVE_ACT_TREQ)) {
            I2CSlaveDataPut(I2C3_BASE, 2*i2c_slave3_data + 1);
            UARTprintf("i2c2 slave 3 rts, data written: %x\r\n", 2*i2c_slave3_data + 1);
            i2c_slave3_data++;
        }

        sw2_last_val = sw2;

        ndelay(1);
    }
}

/**
 * Leave this symbol here for Keil uVision.
 *
 */
int __main(void)
{
    return main();
}
