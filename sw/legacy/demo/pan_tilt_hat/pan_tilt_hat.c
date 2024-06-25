// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include <string.h>
#include <ctype.h>

#include "sonata_system.h"
#include "i2c.h"
#include "rv_plic.h"
#include "dev_access.h"
#include "timer.h"

// A timeout of 1 second should be plenty; reading at 100kbps.
const uint32_t timeout_usecs = 1000 * 1000;

int get_id(uint8_t* data) {
  const uint8_t kIdAddr = 0x50u;
  const uint8_t addr[] = { 0, 0 };

  i2c_t i2c = DEFAULT_I2C;

  // Select I2C host mode
  i2c_set_host_mode(i2c);
  // Program timing parameters
  i2c_set_speed(i2c, 100);

  // Send two byte address (0x0000) and skip the STOP condition
  if (i2c_write(i2c, kIdAddr, addr, 2u, true)) {
    puts("Failed to set up address");
    return -1;
  }

  // Read a 256 byte page from the ID EEPROM
  if (i2c_read(i2c, kIdAddr, data, 0x80u, timeout_usecs)) {
    puts("Failed to read EEPROM ID contents from Pi HAT");
    return -2;
  }

  unsigned idx = 0u;
  while (idx < 0x80u) {
    unsigned eidx = idx + 0x10u;
    unsigned i;
    // Offset within page
    puthex(idx);
    putchar(' ');
    putchar(':');
    putchar(' ');
    // Each byte as hexadecimal
    for (i = idx; i < eidx; i++) {
      puthexn(data[i], 2u);
      putchar(' ');
    }
    putchar(':');
    putchar(' ');
    // Each byte as printable character
    for (i = idx; i < eidx; i++) {
      char ch = (char)data[i];
      ch = isprint(ch) ? ch : '.';
      putchar(ch);
    }
    putchar('\n');
    idx = eidx;
  }

  return 0;
}

int servo_test(uint8_t* data) {
  const uint8_t kIdAddr = 0x15u;

  i2c_t i2c = SECONDARY_I2C;

  // Select I2C host mode
  i2c_set_host_mode(i2c);
  // Program timing parameters
  i2c_set_speed(i2c, 100);

  data[0] = 0x00; // Config register
  data[1] = 0x01; // Enable servo 1

  puts("Enabling servo 1.");
  if(i2c_write(i2c, kIdAddr, data, 2, timeout_usecs)) {
    puts("Failed to set config register.");
    return -3;
  }

  data[0] = 0x01; // Servo 1 register
  data[1] = 0x00; // Least significant byte of microseconds
  data[2] = 0x03; // Most significant byte of microseconds

  puts("Turning servo 1 first.");
  if(i2c_write(i2c, kIdAddr, data, 3, timeout_usecs)) {
    puts("Failed to turn servo 1, first time.");
    return -4;
  }

  arch_local_irq_enable();
  asm volatile("wfi");
  asm volatile("wfi");
  arch_local_irq_disable();

  puts("Turning servo 1 second time.");
  data[0] = 0x01; // Servo 1 register
  data[1] = 0x00; // Least significant byte of microseconds
  data[2] = 0x04; // Most significant byte of microseconds

  if(i2c_write(i2c, kIdAddr, data, 3, timeout_usecs)) {
    puts("Failed to turn servo 1, second time.");
    return -5;
  }

  arch_local_irq_enable();
  asm volatile("wfi");
  asm volatile("wfi");
  arch_local_irq_disable();

  data[0] = 0x00; // Config register
  data[1] = 0x02; // Enable servo 2

  puts("Enabling servo 2.");
  if(i2c_write(i2c, kIdAddr, data, 2, timeout_usecs)) {
    puts("Failed to set config register.");
    return -6;
  }

  data[0] = 0x03; // Servo 2 register
  data[1] = 0x00; // Least significant byte of microseconds
  data[2] = 0x03; // Most significant byte of microseconds

  puts("Turning servo 2 first time.");
  if(i2c_write(i2c, kIdAddr, data, 3, timeout_usecs)) {
    puts("Failed to turn servo 2, first time.");
    return -7;
  }

  arch_local_irq_enable();
  asm volatile("wfi");
  asm volatile("wfi");
  arch_local_irq_disable();

  data[0] = 0x03; // Servo 2 register
  data[1] = 0x00; // Least significant byte of microseconds
  data[2] = 0x04; // Most significant byte of microseconds

  puts("Turning servo 2 second time.");
  if(i2c_write(i2c, kIdAddr, data, 3, timeout_usecs)) {
    puts("Failed to turn servo 2, second time.");
    return -8;
  }

  arch_local_irq_enable();
  asm volatile("wfi");
  asm volatile("wfi");
  arch_local_irq_disable();

  data[0] = 0x00; // Config register
  data[1] = 0x00; // Disable both servos

  puts("Disabling both servos.");
  if(i2c_write(i2c, kIdAddr, data, 2, timeout_usecs)) {
    puts("Failed to set config register.");
    return -9;
  }

  arch_local_irq_enable();
  asm volatile("wfi");
  asm volatile("wfi");
  arch_local_irq_disable();

  return 0;
}

/**
 * Demonstration using pan-tilt hat; use I2C0 to read the ID
 * EEPROM from a compliant Raspberry Pi HAT.
 * use I2C1 to control servo motors and lights.
 */
int main(void) {
  // Data buffer is static to avoid placing a lot of data on the stack.
  static uint8_t data[0x80u];

  // Initialize the buffer to known contents in case of read issues.
  memset(data, 0xffu, sizeof(data));

  uart_init(DEFAULT_UART);
  rv_plic_init();

  puts("pant_tilt_hat demo application.");

  int ret_val = get_id(data);
  if(ret_val) return ret_val;

  puts("Initializing timer.");
  arch_local_irq_disable();
  timer_init();
  timer_enable(30*SYSCLK_FREQ);

  puts("Doing servo test.");
  ret_val = servo_test(data);
  if(ret_val != 0) {
    puts("Failed!");
    return ret_val;
  }
  puts("Success!");

  while(1){}

  return 0;
}

