set(TIVA_ROOT ${SUBMODULES_ROOT}/SW-TM4C/TivaWare_C_Series-2.1.4.178)

target_sources(${CMAKE_PROJECT_NAME}.elf
    PRIVATE
        startup_gcc.c
)

target_compile_definitions(${CMAKE_PROJECT_NAME}.elf
    PRIVATE
        -DPART_TM4C123GH6PM
        -DTARGET_IS_TM4C123_RA1
        -Dgcc
)

target_include_directories(${CMAKE_PROJECT_NAME}.elf
    PRIVATE
        ${TIVA_ROOT}
)

target_link_options(${CMAKE_PROJECT_NAME}.elf
    PRIVATE
        -T${CMAKE_CURRENT_SOURCE_DIR}/linker.ld
        -Wl,--entry=ResetISR
        -Wl,--gc-sections
)

target_link_directories(${CMAKE_PROJECT_NAME}.elf
    PRIVATE
        ${TIVA_ROOT}/driverlib/gcc
)

target_link_libraries(${CMAKE_PROJECT_NAME}.elf
    libdriver.a
)

add_dependencies(${CMAKE_PROJECT_NAME}.elf tm4c123_lib)
