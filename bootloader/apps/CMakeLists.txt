if(NOT DEFINED APP_NAME)
    message(FATAL_ERROR "Undefined app. name, provide -DAPP_NAME=<app_name>")
endif()

message(STATUS "App. name = ${APP_NAME}")

add_subdirectory(${APP_NAME})
