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

#include "driverlib/sysctl.h"
#include "driverlib/uart.h"
#include "driverlib/gpio.h"
#include "driverlib/pin_map.h"
#include "driverlib/ssi.h"

#include "utils/uartstdio.h"

static void Delay(void){unsigned long volatile time;
  time = 145448;  // 0.1sec
  while(time){
		time--;
  }
}

static void SPI2_Init(void)
{
	// Config. SPI port as slave. 12 bits, PHA = 1, POL = 1, 4 MHz.
	SysCtlPeripheralEnable(SYSCTL_PERIPH_SSI1);
	SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOD);
	
	GPIOPinConfigure(GPIO_PD0_SSI1CLK);
  GPIOPinConfigure(GPIO_PD1_SSI1FSS);
	GPIOPinConfigure(GPIO_PD2_SSI1RX);
  GPIOPinConfigure(GPIO_PD3_SSI1TX);
	
	GPIOPinTypeSSI(GPIO_PORTD_BASE, GPIO_PIN_0 | GPIO_PIN_1 | GPIO_PIN_2 | GPIO_PIN_3);

	SSIConfigSetExpClk(SSI1_BASE, SysCtlClockGet(), SSI_FRF_MOTO_MODE_3,
										 SSI_MODE_SLAVE, 1000000, 12);

	SSIEnable(SSI1_BASE);
}

static void SPI_Init(void)
{
	// Config. SPI port as master. 8 bits, PHA = 1, POL = 1, 4 MHz.
	SysCtlPeripheralEnable(SYSCTL_PERIPH_SSI0);
	SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOA);
	
	GPIOPinConfigure(GPIO_PA2_SSI0CLK);
  GPIOPinConfigure(GPIO_PA3_SSI0FSS);
	GPIOPinConfigure(GPIO_PA4_SSI0RX);
  GPIOPinConfigure(GPIO_PA5_SSI0TX);
	
	GPIOPinTypeSSI(GPIO_PORTA_BASE, GPIO_PIN_2 | GPIO_PIN_3 | GPIO_PIN_4 | GPIO_PIN_5);
	
	SSIConfigSetExpClk(SSI0_BASE, SysCtlClockGet(), SSI_FRF_MOTO_MODE_3,
										 SSI_MODE_MASTER, 4000000, 12);

  SSIEnable(SSI0_BASE);
	
	// Config. PF1 to be used as reset pin for the slave SPI device.
	SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOF);
	GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, GPIO_PIN_1);

	GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1, 0);
	Delay();
	GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1, GPIO_PIN_1);
	Delay();
	GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1, 0);
}

static void UART_Init(void){
  SysCtlPeripheralEnable(SYSCTL_PERIPH_UART0);
  // SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOA);
  GPIOPinConfigure(GPIO_PA0_U0RX);
  GPIOPinConfigure(GPIO_PA1_U0TX);
  GPIOPinTypeUART(GPIO_PORTA_BASE, GPIO_PIN_0 | GPIO_PIN_1);
  UARTStdioConfig(0, 115200, 16000000);
}

int main(void)
{  
	SPI_Init();
	SPI2_Init();
	UART_Init();
	UARTprintf("clk freq.: %u\r\n", SysCtlClockGet());
	uint32_t spi_data = 0x00;
	uint32_t spi_data_framed = 0xb00;
	uint32_t spi_read_data = 0;
	uint32_t cnt = 0;

  uint32_t ssi1_data = (uint32_t)0x55f;
  int rc = SSIDataPutNonBlocking(SSI1_BASE, ssi1_data);
  if (rc == 0) {
    UARTprintf("Could not write to the SSI1 fifo\r\n");
  }

  while(1) {
		if (cnt == 0) {
			SSIDataPut(SSI0_BASE, spi_data_framed);
			spi_data++;
			if (spi_data > 0xff) {
				spi_data = 0;
			}
			spi_data_framed = (spi_data << 4) | 0xb;
			
			Delay();
			
			SSIDataGet(SSI0_BASE, &spi_read_data);
			UARTprintf("SPI: %x %d %d\r\n", spi_read_data & 0xfff, spi_read_data & 0xff, (spi_read_data & 0xb00) >> 8);

			Delay();
		}
		cnt++;
		if (cnt == 3) {
			cnt = 0;
		}

		rc = SSIDataGetNonBlocking(SSI1_BASE, &spi_read_data);
    if (rc != 0) {
			UARTprintf("SPI 2: %x %d %d\r\n", spi_read_data & 0xfff, spi_read_data & 0xff, (spi_read_data & 0xb00) >> 8);

			ssi1_data = ssi1_data == 0xaaf ? 0x55f : 0xaaf;
      rc = SSIDataPutNonBlocking(SSI1_BASE, ssi1_data);
      if (rc == 0) {
        UARTprintf("*Could not write to the SSI1 fifo\r\n");
      }
    }
  }
}

int __main(void) {
	return main();
}
