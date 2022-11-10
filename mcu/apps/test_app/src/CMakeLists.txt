if(${SOC} STREQUAL "simpleriscv")
    set(COMPILE_OPTS -Wa,--defsym,SOC_SIMPLERISCV=1)
elseif(${SOC} STREQUAL "sifive_e")
    set(COMPILE_OPTS -Wa,--defsym,SOC_SIFIVE_E=1)
else()
    message(FATAL_ERROR "Undefined soc")
endif()

target_sources(${CMAKE_PROJECT_NAME}.elf
    PRIVATE
        main.s
)

# TODO possibly when the RISC-V assembler problem in toolchain-riscv.cmake
# is solved, this can be replaced by just target_compile_definitions
target_compile_options(${CMAKE_PROJECT_NAME}.elf
    PRIVATE
        ${COMPILE_OPTS}
)
