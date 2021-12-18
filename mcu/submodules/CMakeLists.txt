add_custom_target(tm4c123_lib ALL
    COMMAND make -j 4
    WORKING_DIRECTORY ${TIVA_DRIVERLIB_ROOT}
    BYPRODUCTS ${TIVA_DRIVERLIB_ROOT}/gcc/libdriver.a
)

add_custom_target(lm4tools ALL
    COMMAND make -j 4
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/lm4tools
    BYPRODUCTS ${CMAKE_CURRENT_SOURCE_DIR}/lm4tools/lm4flash/lm4flash
)

target_sources(${CMAKE_PROJECT_NAME}.axf
    PRIVATE
        ${TIVA_ROOT}/utils/uartstdio.c
)
