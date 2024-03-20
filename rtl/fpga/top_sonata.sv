// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Sonata system top level for the Sonata PCB
module top_sonata (
  input  logic mainClk,
  input  logic nrst,

  output logic [7:0] usrLed,
  output logic       led_bootok,
  output logic       led_halted,
  output logic       led_cheri,
  output logic       led_legacy,
  output logic [8:0] cheriErr,

  input  logic [4:0] navSw,
  input  logic [7:0] usrSw,

  output logic lcd_rst,
  output logic lcd_dc,
  output logic lcd_copi,
  output logic lcd_clk,
  output logic lcd_cs,
  output logic lcd_backlight,

  output logic rgbled0,

  output logic ser0_tx,
  input  logic ser0_rx
);
  parameter SRAMInitFile = "";

  logic main_clk_buf;
  logic clk_sys;
  logic rst_sys_n;
  logic [7:0] reset_counter;
  logic pll_locked;
  logic rst_btn;

  logic [4:0] nav_sw_n;
  logic [7:0] user_sw_n;

  assign led_bootok = rst_sys_n;

  // Switch inputs have pull-ups and switches pull to ground when on. Invert here so CPU sees 1 for
  // on and 0 for off.
  assign nav_sw_n = ~navSw;
  assign user_sw_n = ~usrSw;

  logic cheri_en;

  sonata_system #(
    .GpiWidth     ( 13           ),
    .GpoWidth     ( 12           ),
    .PwmWidth     (  0           ),
    .CheriErrWidth(  9           ),
    .SRAMInitFile ( SRAMInitFile )
  ) u_sonata_system (
    .clk_sys_i (clk_sys),
    .rst_sys_ni(rst_sys_n),

    .gp_i({user_sw_n, nav_sw_n}),
    .gp_o({usrLed, lcd_backlight, lcd_dc, lcd_rst, lcd_cs}),

    .uart_rx_i(ser0_rx),
    .uart_tx_o(ser0_tx),

    .pwm_o(),

    .spi_rx_i (1'b0),
    .spi_tx_o (lcd_copi),
    .spi_sck_o(lcd_clk),

    .cheri_err_o(cheriErr),
    .cheri_en_o (cheri_en)
  );

  assign led_cheri = cheri_en;
  assign led_legacy = ~cheri_en;
  assign led_halted = 1'b0;

  // Produce 50 MHz system clock from 25 MHz Sonata board clock.
  clkgen_sonata u_clkgen(
    .IO_CLK    (mainClk),
    .IO_CLK_BUF(main_clk_buf),
    .clk_sys,
    .locked    (pll_locked)
  );

  // Produce reset signal at beginning of time and when button pressed.
  assign rst_btn = ~nrst;

  rst_ctrl u_rst_ctrl (
    .clk_i       (main_clk_buf),
    .pll_locked_i(pll_locked),
    .rst_btn_i   (rst_btn),
    .rst_no      (rst_sys_n)
  );

  logic [8:0] cur_rgb_index;
  logic [31:0] rgb_counter;

  always_ff @(posedge clk_sys or negedge rst_sys_n) begin
    if (!rst_sys_n) begin
      cur_rgb_index <= '0;
      rgb_counter <= '0;
    end else begin
      if (rgb_counter < 32'd2_500_000) begin
        rgb_counter <= rgb_counter + 32'd1;
      end else begin
        rgb_counter <= '0;
        if (cur_rgb_index < 9'd49) begin
          cur_rgb_index <= cur_rgb_index + 6'd1;
        end else begin
          cur_rgb_index <= '0;
        end
      end
    end
  end

  logic data_last;
  logic data_ack;

  always_ff @(posedge clk_sys or negedge rst_sys_n) begin
    if (!rst_sys_n) begin
      data_last <= 1'b0;
    end else begin
      if (data_ack) begin
        data_last <= ~data_last;
      end
    end
  end

  logic [23:0] cur_rgb;

  always_comb begin
    case (cur_rgb_index)
      0: cur_rgb = {8'd10, 8'd36, 8'd10 };
      1: cur_rgb = {8'd12, 8'd36, 8'd10 };
      2: cur_rgb = {8'd15, 8'd36, 8'd10 };
      3: cur_rgb = {8'd18, 8'd36, 8'd10 };
      4: cur_rgb = {8'd21, 8'd36, 8'd10 };
      5: cur_rgb = {8'd25, 8'd36, 8'd10 };
      6: cur_rgb = {8'd28, 8'd36, 8'd10 };
      7: cur_rgb = {8'd32, 8'd36, 8'd10 };
      8: cur_rgb = {8'd35, 8'd36, 8'd10 };
      9: cur_rgb = {8'd36, 8'd33, 8'd10 };
      10: cur_rgb = {8'd36, 8'd29, 8'd10 };
      11: cur_rgb = {8'd36, 8'd26, 8'd10 };
      12: cur_rgb = {8'd36, 8'd23, 8'd10 };
      13: cur_rgb = {8'd36, 8'd19, 8'd10 };
      14: cur_rgb = {8'd36, 8'd16, 8'd10 };
      15: cur_rgb = {8'd36, 8'd13, 8'd10 };
      16: cur_rgb = {8'd36, 8'd11, 8'd10 };
      17: cur_rgb = {8'd36, 8'd10, 8'd11 };
      18: cur_rgb = {8'd36, 8'd10, 8'd14 };
      19: cur_rgb = {8'd36, 8'd10, 8'd17 };
      20: cur_rgb = {8'd36, 8'd10, 8'd20 };
      21: cur_rgb = {8'd36, 8'd10, 8'd24 };
      22: cur_rgb = {8'd36, 8'd10, 8'd27 };
      23: cur_rgb = {8'd36, 8'd10, 8'd31 };
      24: cur_rgb = {8'd36, 8'd10, 8'd34 };
      25: cur_rgb = {8'd34, 8'd10, 8'd36 };
      26: cur_rgb = {8'd31, 8'd10, 8'd36 };
      27: cur_rgb = {8'd27, 8'd10, 8'd36 };
      28: cur_rgb = {8'd24, 8'd10, 8'd36 };
      29: cur_rgb = {8'd20, 8'd10, 8'd36 };
      30: cur_rgb = {8'd17, 8'd10, 8'd36 };
      31: cur_rgb = {8'd14, 8'd10, 8'd36 };
      32: cur_rgb = {8'd11, 8'd10, 8'd36 };
      33: cur_rgb = {8'd10, 8'd11, 8'd36 };
      34: cur_rgb = {8'd10, 8'd13, 8'd36 };
      35: cur_rgb = {8'd10, 8'd16, 8'd36 };
      36: cur_rgb = {8'd10, 8'd19, 8'd36 };
      37: cur_rgb = {8'd10, 8'd23, 8'd36 };
      38: cur_rgb = {8'd10, 8'd26, 8'd36 };
      39: cur_rgb = {8'd10, 8'd29, 8'd36 };
      40: cur_rgb = {8'd10, 8'd33, 8'd36 };
      41: cur_rgb = {8'd10, 8'd36, 8'd35 };
      42: cur_rgb = {8'd10, 8'd36, 8'd32 };
      43: cur_rgb = {8'd10, 8'd36, 8'd28 };
      44: cur_rgb = {8'd10, 8'd36, 8'd25 };
      45: cur_rgb = {8'd10, 8'd36, 8'd21 };
      46: cur_rgb = {8'd10, 8'd36, 8'd18 };
      47: cur_rgb = {8'd10, 8'd36, 8'd15 };
      48: cur_rgb = {8'd10, 8'd36, 8'd12 };
      49: cur_rgb = {8'd10, 8'd36, 8'd10 };
      default: cur_rgb = {8'd0,8'd0,8'd0};
    endcase
  end

  logic ws281x_dout;
  assign rgbled0 = ~ws281x_dout;

  ws281x_drv u_ws281x_drv (
    .clk_i(mainclk),
    .rst_ni(rst_n),

    .go_i(1'b1),
    .idle_o(),
    .data_i(cur_rgb),
    .data_valid_i(1'b1),
    .data_last_i(data_last),
    .data_ack_o(data_ack),
    .ws281x_dout_o(ws281x_dout)
  );
endmodule
