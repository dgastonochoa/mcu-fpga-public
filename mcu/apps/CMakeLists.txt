if(NOT DEFINED APP_NAME)
    message(FATAL_ERROR "Undefined app. name, provide -DAPP_NAME=<app_name>")
endif()

message(STATUS "App. name = ${APP_NAME}")

if(${APP_NAME} STREQUAL  "spi_reader")
    add_subdirectory(spi_reader)
elseif(${APP_NAME} STREQUAL  "i2c_legacy")
    add_subdirectory(i2c_legacy)
elseif(${APP_NAME} STREQUAL  "fw_updater")
    add_subdirectory(fw_updater)
endif()
