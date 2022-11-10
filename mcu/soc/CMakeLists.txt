if(NOT DEFINED ARCH OR ARCH STREQUAL "")
    message(FATAL_ERROR "Undefined architecture")
endif()

message(STATUS "ARCH = ${ARCH}")

add_subdirectory(${ARCH})
