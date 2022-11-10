if(NOT DEFINED SOC OR SOC STREQUAL "")
    message(FATAL_ERROR "Undefined board")
endif()

message(STATUS "SOC = ${SOC}")

add_subdirectory(${SOC})
