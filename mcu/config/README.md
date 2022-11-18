This directory contains default configurations to build different targets.

Each file is named as following:

    ${BOARD|SOC}-${APP_NAME}_defconfig

Where
 * ${BOARD|SOC} is the target board or soc. Some applications are board-specific,
    such as `spi_reader`, which requires the board tm4c123g. However, others are
    soc-specific, therefore they are more general. `led_blink` or `test_program`
    are examples of this: they would work for any board as long as it contains
    the expected soc.

    TODO It makes no sense that simpleriscv soc has LEDs, they should be just
    GPIOs which happen to be connected to LEDs in a particular board (in this
    case, Basys3)

    TODO The fact of mixing soc and boards is not good.

 * ${APP_NAME} is the application name.


The only supported configurations are those in this directory.
