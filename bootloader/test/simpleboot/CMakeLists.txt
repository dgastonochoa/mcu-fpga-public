add_subdirectory(src)

target_include_directories(${CMAKE_PROJECT_NAME}.elf
    PRIVATE
        include
)

target_link_options(${CMAKE_PROJECT_NAME}.elf
    PRIVATE
        -T${CMAKE_CURRENT_SOURCE_DIR}/sifive_e_modif.ld
)

target_sources(${CMAKE_PROJECT_NAME}.elf
    PRIVATE
        ${CMAKE_SOURCE_DIR}/../apps/simpleboot/src/bootloader.s
)
