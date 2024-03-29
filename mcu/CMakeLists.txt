cmake_minimum_required(VERSION 3.13.1)

include(cmake/env.cmake)

project(mcu)

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

if(GEN_DISSAS_TXT)
    if(UNIX)
        add_custom_target(dissas-txt ALL
            DEPENDS ${CMAKE_PROJECT_NAME}.bin
            COMMAND xxd -e -c 4 ${CMAKE_PROJECT_NAME}.bin | cut -d ' ' -f 2 > ${CMAKE_PROJECT_NAME}.txt
            BYPRODUCTS ${CMAKE_PROJECT_NAME}.txt
        )
    else()
        message(FATAL_ERROR "Text dissaembly file not supported on this OS")
    endif()
endif()
