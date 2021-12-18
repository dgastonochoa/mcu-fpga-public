cmake_minimum_required(VERSION 3.13.1)

project(mcu)

include(cmake/environment.cmake)

add_executable(${CMAKE_PROJECT_NAME}.axf
    src/startup_gcc.c
    src/main.c
)

add_dependencies(${CMAKE_PROJECT_NAME}.axf tm4c123_lib)

target_include_directories(${CMAKE_PROJECT_NAME}.axf
    PRIVATE
        ${TIVA_INCLUDE}
)

target_link_directories(${CMAKE_PROJECT_NAME}.axf
    PRIVATE
        ${TIVA_DRIVERLIB_ROOT}/gcc
)

target_link_libraries(${CMAKE_PROJECT_NAME}.axf
    libdriver.a
)

add_custom_target(fw-img ALL
    DEPENDS ${CMAKE_PROJECT_NAME}.axf
    COMMAND ${CMAKE_OBJCOPY} -O binary ${CMAKE_PROJECT_NAME}.axf ${CMAKE_PROJECT_NAME}.bin
    BYPRODUCTS ${CMAKE_PROJECT_NAME}.bin
)

add_custom_target(flash
    DEPENDS ${CMAKE_PROJECT_NAME}.bin
    COMMAND ${FLASH_EXECUTABLE} ${CMAKE_PROJECT_NAME}.bin
)

add_subdirectory(submodules)
