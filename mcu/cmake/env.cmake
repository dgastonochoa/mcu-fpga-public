message(STATUS "Architecture = ${ARCH}")

# TODO arm4 should be just arm
if(ARCH STREQUAL "arm")
    include(${PROJECT_SOURCE_DIR}/cmake/toolchain-arm.cmake)
elseif(ARCH STREQUAL "riscv")
    include(${PROJECT_SOURCE_DIR}/cmake/toolchain-riscv.cmake)
else()
    message(FATAL_ERROR "Undefined architecure")
endif()
