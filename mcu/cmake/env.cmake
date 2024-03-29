message(STATUS "Architecture = ${ARCH}")

if(ARCH STREQUAL "arm")
    include(${CMAKE_SOURCE_DIR}/cmake/toolchain-arm.cmake)
elseif(ARCH STREQUAL "riscv")
    include(${CMAKE_SOURCE_DIR}/cmake/toolchain-riscv.cmake)
else()
    message(FATAL_ERROR "Undefined architecure")
endif()
