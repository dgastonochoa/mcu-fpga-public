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

// Wire PD2 and PD3 together for this test
#define LOOPBACK_TEST 0

#if LOOPBACK_TEST != 0
    #define SPI_TYPE SSI_MODE_MASTER
#else
    #define SPI_TYPE SSI_MODE_SLAVE
#endif

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
        SPI_TYPE,
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

#if LOOPBACK_TEST != 0
static void delay(uint32_t ticks)
{
    // SysCtlDelay consumes 3 cycles approx. for the wait loop,
    // so divided by 3.
    SysCtlDelay(ticks / 3);
}
#endif /* LOOPBACK_TEST */

int main(void)
{
    GPIOInit();
    GPIOPinMux();
    SPISlaveInit();
    UARTInit();

    
    uint32_t led_val = GPIO_PIN_3;

    GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_3, led_val);

#if LOOPBACK_TEST != 0
    SSIDataPutNonBlocking(SSI1_BASE, 11);
#endif /* LOOPBACK_TEST */

    while (1) {
        uint32_t rd = 0;

        int rc = SSIDataGetNonBlocking(SSI1_BASE, &rd);

        rd++;

        if (rc != 0) {
            SSIDataPutNonBlocking(SSI1_BASE, rd);
        }

#if LOOPBACK_TEST != 0
        UARTprintf("%x\r\n", rd);

        uint32_t ticks_per_second = SysCtlClockGet(); 
        delay(ticks_per_second);

        led_val = led_val == 0 ? GPIO_PIN_3 : 0;
        GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_3, led_val);
#endif /* LOOPBACK_TEST */
    }
}

/**
 * Leave this symbol here for Keil uVision.
 *
 */
int __main(void) {
    return main();
}
