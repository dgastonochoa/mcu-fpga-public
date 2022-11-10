cmake_minimum_required(VERSION 3.13.1)

# TODO this won't be valid for the bootloader
project(mcu)

include(cmake/env.cmake)

set(SUBMODULES_ROOT ${CMAKE_SOURCE_DIR}/submodules)

add_executable(${CMAKE_PROJECT_NAME}.elf)

add_subdirectory(apps)
add_subdirectory(soc)
add_subdirectory(submodules)

add_custom_target(fw-img ALL
    DEPENDS ${CMAKE_PROJECT_NAME}.elf
    COMMAND ${CMAKE_OBJCOPY} -O binary ${CMAKE_PROJECT_NAME}.elf ${CMAKE_PROJECT_NAME}.bin
    BYPRODUCTS ${CMAKE_PROJECT_NAME}.bin
)
