// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// xbar_main module generated by `tlgen.py` tool
// all reset signals should be generated from one reset signal to not make any deadlock
//
// Interconnect
// ibex_lsu
//   -> s1n_7
//     -> sram
//     -> gpio
//     -> uart
//     -> timer
//     -> pwm
//     -> spi

module xbar_main (
  input clk_sys_i,
  input rst_sys_ni,

  // Host interfaces
  input  tlul_pkg::tl_h2d_t tl_ibex_lsu_i,
  output tlul_pkg::tl_d2h_t tl_ibex_lsu_o,

  // Device interfaces
  output tlul_pkg::tl_h2d_t tl_sram_o,
  input  tlul_pkg::tl_d2h_t tl_sram_i,
  output tlul_pkg::tl_h2d_t tl_gpio_o,
  input  tlul_pkg::tl_d2h_t tl_gpio_i,
  output tlul_pkg::tl_h2d_t tl_pwm_o,
  input  tlul_pkg::tl_d2h_t tl_pwm_i,
  output tlul_pkg::tl_h2d_t tl_timer_o,
  input  tlul_pkg::tl_d2h_t tl_timer_i,
  output tlul_pkg::tl_h2d_t tl_uart_o,
  input  tlul_pkg::tl_d2h_t tl_uart_i,
  output tlul_pkg::tl_h2d_t tl_spi_o,
  input  tlul_pkg::tl_d2h_t tl_spi_i,

  input prim_mubi_pkg::mubi4_t scanmode_i
);

  import tlul_pkg::*;
  import tl_main_pkg::*;

  // scanmode_i is currently not used, but provisioned for future use
  // this assignment prevents lint warnings
  logic unused_scanmode;
  assign unused_scanmode = ^scanmode_i;

  tl_h2d_t tl_s1n_7_us_h2d ;
  tl_d2h_t tl_s1n_7_us_d2h ;


  tl_h2d_t tl_s1n_7_ds_h2d [6];
  tl_d2h_t tl_s1n_7_ds_d2h [6];

  // Create steering signal
  logic [2:0] dev_sel_s1n_7;



  assign tl_sram_o = tl_s1n_7_ds_h2d[0];
  assign tl_s1n_7_ds_d2h[0] = tl_sram_i;

  assign tl_gpio_o = tl_s1n_7_ds_h2d[1];
  assign tl_s1n_7_ds_d2h[1] = tl_gpio_i;

  assign tl_uart_o = tl_s1n_7_ds_h2d[2];
  assign tl_s1n_7_ds_d2h[2] = tl_uart_i;

  assign tl_timer_o = tl_s1n_7_ds_h2d[3];
  assign tl_s1n_7_ds_d2h[3] = tl_timer_i;

  assign tl_pwm_o = tl_s1n_7_ds_h2d[4];
  assign tl_s1n_7_ds_d2h[4] = tl_pwm_i;

  assign tl_spi_o = tl_s1n_7_ds_h2d[5];
  assign tl_s1n_7_ds_d2h[5] = tl_spi_i;

  assign tl_s1n_7_us_h2d = tl_ibex_lsu_i;
  assign tl_ibex_lsu_o = tl_s1n_7_us_d2h;

  always_comb begin
    // default steering to generate error response if address is not within the range
    dev_sel_s1n_7 = 3'd6;
    if ((tl_s1n_7_us_h2d.a_address &
         ~(ADDR_MASK_SRAM)) == ADDR_SPACE_SRAM) begin
      dev_sel_s1n_7 = 3'd0;

    end else if ((tl_s1n_7_us_h2d.a_address &
                  ~(ADDR_MASK_GPIO)) == ADDR_SPACE_GPIO) begin
      dev_sel_s1n_7 = 3'd1;

    end else if ((tl_s1n_7_us_h2d.a_address &
                  ~(ADDR_MASK_UART)) == ADDR_SPACE_UART) begin
      dev_sel_s1n_7 = 3'd2;

    end else if ((tl_s1n_7_us_h2d.a_address &
                  ~(ADDR_MASK_TIMER)) == ADDR_SPACE_TIMER) begin
      dev_sel_s1n_7 = 3'd3;

    end else if ((tl_s1n_7_us_h2d.a_address &
                  ~(ADDR_MASK_PWM)) == ADDR_SPACE_PWM) begin
      dev_sel_s1n_7 = 3'd4;

    end else if ((tl_s1n_7_us_h2d.a_address &
                  ~(ADDR_MASK_SPI)) == ADDR_SPACE_SPI) begin
      dev_sel_s1n_7 = 3'd5;
end
  end


  // Instantiation phase
  tlul_socket_1n #(
    .HReqDepth (4'h0),
    .HRspDepth (4'h0),
    .DReqDepth (24'h0),
    .DRspDepth (24'h0),
    .N         (6)
  ) u_s1n_7 (
    .clk_i        (clk_sys_i),
    .rst_ni       (rst_sys_ni),
    .tl_h_i       (tl_s1n_7_us_h2d),
    .tl_h_o       (tl_s1n_7_us_d2h),
    .tl_d_o       (tl_s1n_7_ds_h2d),
    .tl_d_i       (tl_s1n_7_ds_d2h),
    .dev_select_i (dev_sel_s1n_7)
  );

endmodule
