target_sources(${CMAKE_PROJECT_NAME}.elf
    PRIVATE
        startup.s
)

target_link_options(${CMAKE_PROJECT_NAME}.elf
    PRIVATE
        -T${CMAKE_CURRENT_SOURCE_DIR}/linker.ld
)
