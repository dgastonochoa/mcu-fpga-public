add_subdirectory(src)

target_include_directories(${CMAKE_PROJECT_NAME}.elf
    PRIVATE
        include
)
