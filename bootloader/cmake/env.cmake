message(STATUS "Architecture = ${ARCH}")

if(ARCH STREQUAL "arm4")
    include(${PROJECT_SOURCE_DIR}/cmake/toolchain-arm4.cmake)
elseif(ARCH STREQUAL "riscv")
    include(${PROJECT_SOURCE_DIR}/cmake/toolchain-riscv.cmake)
else()
    message(FATAL_ERROR "Undefined architecure")
endif()
