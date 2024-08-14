// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// sonata_xbar_main module is a wrapper around the auto-generated xbar_main.

module sonata_xbar_main (
  input clk_sys_i,
  input clk_usb_i,
  input rst_sys_ni,
  input rst_usb_ni,

  // Host interfaces
  input  tlul_pkg::tl_h2d_t tl_ibex_lsu_i,
  output tlul_pkg::tl_d2h_t tl_ibex_lsu_o,
  input  tlul_pkg::tl_h2d_t tl_dbg_host_i,
  output tlul_pkg::tl_d2h_t tl_dbg_host_o,

  // Device interfaces
  output tlul_pkg::tl_h2d_t tl_sram_o,
  input  tlul_pkg::tl_d2h_t tl_sram_i,
  output tlul_pkg::tl_h2d_t tl_rev_tag_o,
  input  tlul_pkg::tl_d2h_t tl_rev_tag_i,
  output tlul_pkg::tl_h2d_t tl_gpio_o,
  input  tlul_pkg::tl_d2h_t tl_gpio_i,
  output tlul_pkg::tl_h2d_t tl_pwm_o,
  input  tlul_pkg::tl_d2h_t tl_pwm_i,
  output tlul_pkg::tl_h2d_t tl_gpio_headers_o[sonata_pkg::GPIO_NUM],
  input  tlul_pkg::tl_d2h_t tl_gpio_headers_i[sonata_pkg::GPIO_NUM],
  output tlul_pkg::tl_h2d_t tl_rgbled_ctrl_o,
  input  tlul_pkg::tl_d2h_t tl_rgbled_ctrl_i,
  output tlul_pkg::tl_h2d_t tl_hw_rev_o,
  input  tlul_pkg::tl_d2h_t tl_hw_rev_i,
  output tlul_pkg::tl_h2d_t tl_timer_o,
  input  tlul_pkg::tl_d2h_t tl_timer_i,
  output tlul_pkg::tl_h2d_t tl_uart_o[sonata_pkg::UART_NUM],
  input  tlul_pkg::tl_d2h_t tl_uart_i[sonata_pkg::UART_NUM],
  output tlul_pkg::tl_h2d_t tl_i2c_o [sonata_pkg::I2C_NUM],
  input  tlul_pkg::tl_d2h_t tl_i2c_i [sonata_pkg::I2C_NUM],
  output tlul_pkg::tl_h2d_t tl_spi_o [sonata_pkg::SPI_NUM],
  input  tlul_pkg::tl_d2h_t tl_spi_i [sonata_pkg::SPI_NUM],
  output tlul_pkg::tl_h2d_t tl_usbdev_o,
  input  tlul_pkg::tl_d2h_t tl_usbdev_i,
  output tlul_pkg::tl_h2d_t tl_rv_plic_o,
  input  tlul_pkg::tl_d2h_t tl_rv_plic_i
);

  xbar_main xbar (
        // Clock and reset.
    .clk_sys_i        (clk_sys_i),
    .rst_sys_ni       (rst_sys_ni),
    .clk_usb_i        (clk_usb_i),
    .rst_usb_ni       (rst_usb_ni),

    // Host interfaces.
    .tl_ibex_lsu_i    (tl_ibex_lsu_i),
    .tl_ibex_lsu_o    (tl_ibex_lsu_o),
    .tl_dbg_host_i    (tl_dbg_host_i),
    .tl_dbg_host_o    (tl_dbg_host_o),

    // Device interfaces.
    .tl_sram_o        (tl_sram_o),
    .tl_sram_i        (tl_sram_i),
    .tl_rev_tag_o     (tl_rev_tag_o),
    .tl_rev_tag_i     (tl_rev_tag_i),
    .tl_gpio_o        (tl_gpio_o),
    .tl_gpio_i        (tl_gpio_i),
    .tl_pwm_o         (tl_pwm_o),
    .tl_pwm_i         (tl_pwm_i),
    .tl_gpio0_o       (tl_gpio_headers_o[0]),
    .tl_gpio0_i       (tl_gpio_headers_i[0]),
    .tl_gpio1_o       (tl_gpio_headers_o[1]),
    .tl_gpio1_i       (tl_gpio_headers_i[1]),
    .tl_gpio2_o       (tl_gpio_headers_o[2]),
    .tl_gpio2_i       (tl_gpio_headers_i[2]),
    .tl_gpio3_o       (tl_gpio_headers_o[3]),
    .tl_gpio3_i       (tl_gpio_headers_i[3]),
    .tl_gpio4_o       (tl_gpio_headers_o[4]),
    .tl_gpio4_i       (tl_gpio_headers_i[4]),
    .tl_rgbled_ctrl_o (tl_rgbled_ctrl_o),
    .tl_rgbled_ctrl_i (tl_rgbled_ctrl_i),
    .tl_hw_rev_o      (tl_hw_rev_o),
    .tl_hw_rev_i      (tl_hw_rev_i),
    .tl_timer_o       (tl_timer_o),
    .tl_timer_i       (tl_timer_i),
    .tl_uart0_o       (tl_uart_o[0]),
    .tl_uart0_i       (tl_uart_i[0]),
    .tl_uart1_o       (tl_uart_o[1]),
    .tl_uart1_i       (tl_uart_i[1]),
    .tl_uart2_o       (tl_uart_o[2]),
    .tl_uart2_i       (tl_uart_i[2]),
    .tl_uart3_o       (tl_uart_o[3]),
    .tl_uart3_i       (tl_uart_i[3]),
    .tl_uart4_o       (tl_uart_o[4]),
    .tl_uart4_i       (tl_uart_i[4]),
    .tl_i2c0_o        (tl_i2c_o[0]),
    .tl_i2c0_i        (tl_i2c_i[0]),
    .tl_i2c1_o        (tl_i2c_o[1]),
    .tl_i2c1_i        (tl_i2c_i[1]),
    .tl_spi_flash_o   (tl_spi_o[0]),
    .tl_spi_flash_i   (tl_spi_i[0]),
    .tl_spi_lcd_o     (tl_spi_o[1]),
    .tl_spi_lcd_i     (tl_spi_i[1]),
    .tl_spi_eth_o     (tl_spi_o[2]),
    .tl_spi_eth_i     (tl_spi_i[2]),
    .tl_spi_rp0_o     (tl_spi_o[3]),
    .tl_spi_rp0_i     (tl_spi_i[3]),
    .tl_spi_rp1_o     (tl_spi_o[4]),
    .tl_spi_rp1_i     (tl_spi_i[4]),
    .tl_spi_ard_o     (tl_spi_o[5]),
    .tl_spi_ard_i     (tl_spi_i[5]),
    .tl_spi_mkr_o     (tl_spi_o[6]),
    .tl_spi_mkr_i     (tl_spi_i[6]),
    .tl_usbdev_o      (tl_usbdev_o),
    .tl_usbdev_i      (tl_usbdev_i),
    .tl_rv_plic_o     (tl_rv_plic_o),
    .tl_rv_plic_i     (tl_rv_plic_i),

    .scanmode_i       (prim_mubi_pkg::MuBi4False)
  );

endmodule
