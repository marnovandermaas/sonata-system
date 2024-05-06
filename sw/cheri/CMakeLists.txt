cmake_minimum_required(VERSION 3.13)

if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
  set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/cheriot_toolchain.cmake")
endif()

if(NOT DEFINED CHERIOT_RTOS_SDK)
  set(CHERIOT_RTOS_SDK "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/cheriot_rtos/sdk")
endif()

project(sonata_system_cheriot_sw LANGUAGES C CXX ASM)

set(CHERIOT_SDK_INCLUDES
  "${CHERIOT_RTOS_SDK}/include/c++-config"
  "${CHERIOT_RTOS_SDK}/include/libc++"
  "${CHERIOT_RTOS_SDK}/include"
  "${CHERIOT_RTOS_SDK}/include/platform/generic-riscv"
)

add_subdirectory(common)
add_subdirectory(tests)
