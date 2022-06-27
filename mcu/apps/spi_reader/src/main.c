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

#include "inc/hw_memmap.h"
#include "inc/hw_types.h"

#include "driverlib/sysctl.h"
#include "driverlib/uart.h"
#include "driverlib/gpio.h"
#include "driverlib/pin_map.h"
#include "driverlib/ssi.h"

#include "utils/uartstdio.h"

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

int main(void)
{
    GPIOInit();
    GPIOPinMux();
    SPISlaveInit();
    UARTInit();

    GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_3, 8);

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
