cmake_minimum_required(VERSION 3.13.1)

project(bootloader)

enable_language(ASM)
enable_language(C)

# Set cross compilation information
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR riscv)

# GCC toolchain prefix
set(TOOLCHAIN_PREFIX "riscv64-unknown-elf")

set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}-gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}-g++)

# TODO this should be the assembler, but ${CMAKE_ASM_FLAGS} are
# actually gcc flags, therefore they won't work with as
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_PREFIX}-gcc)

set(CMAKE_AR ${TOOLCHAIN_PREFIX}-ar)
set(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}-objcopy)
set(CMAKE_OBJDUMP ${TOOLCHAIN_PREFIX}-objdump)


set(ARCH "-march=rv32g -mabi=ilp32")

# TODO These are actually gcc flags. The assembler should be
# used and these flags replaced
set(CMAKE_ASM_FLAGS "${CMAKE_C_FLAGS} ${ARCH} -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles")


set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "")
set(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS "")

set(CMAKE_EXPORT_COMPILE_COMMANDS true)


################################################

add_executable(${CMAKE_PROJECT_NAME}.elf)

add_custom_target(fw-img ALL
    DEPENDS ${CMAKE_PROJECT_NAME}.elf
    COMMAND ${CMAKE_OBJCOPY} -O binary ${CMAKE_PROJECT_NAME}.elf ${CMAKE_PROJECT_NAME}.bin
    BYPRODUCTS ${CMAKE_PROJECT_NAME}.bin
)

add_custom_target(dissas-txt ALL
    DEPENDS ${CMAKE_PROJECT_NAME}.bin
    COMMAND xxd -e -c 4 ${CMAKE_PROJECT_NAME}.bin | cut -d ' ' -f 2 > ${CMAKE_PROJECT_NAME}.txt
    BYPRODUCTS ${CMAKE_PROJECT_NAME}.txt
)

################################################

target_sources(${CMAKE_PROJECT_NAME}.elf
    PRIVATE
        src/startup.s
)

target_link_options(${CMAKE_PROJECT_NAME}.elf
    PRIVATE
        -T${CMAKE_CURRENT_SOURCE_DIR}/include/my_riscv_bootloader.ld
)

###############################################

target_sources(${CMAKE_PROJECT_NAME}.elf
    PRIVATE
        src/bootloader.s
        src/drivers.s
)

target_include_directories(${CMAKE_PROJECT_NAME}.elf
    PRIVATE
        include
)
