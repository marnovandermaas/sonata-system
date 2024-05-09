add_executable(pan_tilt_hat pan_tilt_hat.c)

# pull in core dependencies and additional i2c hardware support
target_link_libraries(pan_tilt_hat common)

add_custom_command(
  TARGET pan_tilt_hat POST_BUILD
  COMMAND ${CMAKE_OBJCOPY} -O binary "$<TARGET_FILE:pan_tilt_hat>" "$<TARGET_FILE:pan_tilt_hat>.bin"
  COMMAND srec_cat "$<TARGET_FILE:pan_tilt_hat>.bin" -binary -offset 0x0000 -byte-swap 4 -o "$<TARGET_FILE:pan_tilt_hat>.vmem" -vmem
  VERBATIM)
