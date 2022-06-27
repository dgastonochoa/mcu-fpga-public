# Summary
This is an SPI reader. It just reads all SPI bytes it receives, and sends them
to the UART0 (which in TM4C123GXL goes to the MCU virtual COM port).

# Tiva C-series virtual COM port
When connecting and flashing the MCU to the laptop, a device like
`/dev/ttyACM0` will appear. It can be read with either of the
following commands:

    minicom -D /dev/tty<dev_name>
    microcom -s 115200 -p /dev/tty<dev_name>

where <dev_name> is ACM0 or similar.
