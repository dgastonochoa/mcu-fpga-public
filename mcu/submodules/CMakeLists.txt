
# TODO Should all the tiva stuff be in a subdir?
if(TIVA_SDK)
    set(TIVA_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/SW-TM4C/TivaWare_C_Series-2.1.4.178)

    add_custom_target(tm4c123_lib ALL
        COMMAND make -j 4
        WORKING_DIRECTORY ${TIVA_ROOT}/driverlib
        BYPRODUCTS ${TIVA_ROOT}/driverlib/gcc/libdriver.a
    )

    add_custom_target(lm4tools ALL
        COMMAND make -j 4
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/lm4tools
        BYPRODUCTS ${CMAKE_CURRENT_SOURCE_DIR}/lm4tools/lm4flash/lm4flash
    )

    target_sources(${CMAKE_PROJECT_NAME}.elf
        PRIVATE
            ${TIVA_ROOT}/utils/uartstdio.c
    )

    add_custom_target(flash
        DEPENDS ${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}.bin
        COMMAND ${SUBMODULES_ROOT}/lm4tools/lm4flash/lm4flash ${CMAKE_BINARY_DIR}/${CMAKE_PROJECT_NAME}.bin
    )
endif()
