# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

add_executable(demo main.c)
target_link_libraries(demo common)

install(TARGETS demo)

add_custom_command(
  TARGET demo POST_BUILD
  COMMAND ${CMAKE_OBJCOPY} -O binary "$<TARGET_FILE:demo>" "$<TARGET_FILE:demo>.bin"
  COMMAND srec_cat "$<TARGET_FILE:demo>.bin" -binary -offset 0x0000 -byte-swap 4 -o "$<TARGET_FILE:demo>.vmem" -vmem
  VERBATIM)
