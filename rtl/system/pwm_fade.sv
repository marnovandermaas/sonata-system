// Copyright lowRISC contributors.
// SPDX-License-Identifier: Apache-2.0

/**
 * This module will assert it's output, `modulated_o`,
 * when `impulse_i` is asserted. When `impulse_i` is dropped,
 * it will fade it's output by decreasing it's pulse width.
 *
 * Total fade time = (1 << CounterSize) * NumTicks * the clock period
 * The default fade time is 1.68 second, when the clock is 30MHz
 */
module pwm_fade #(
  parameter CounterSize = 7,
  parameter NumTicks = (1 << 18) - 1
)(
  input logic clk_i,
  input logic rst_ni,
  input logic impulse_i,

  output logic modulated_o
);
  localparam CounterMax = (1 << CounterSize) - 1;

  logic [$clog2(NumTicks+1):0] tick_counter;
  logic [CounterSize-1:0] pulse_width;

  pwm #(
    .CtrSize ( CounterSize )
  ) u_pwm (
    .clk_i,
    .rst_ni,
    .pulse_width_i (pulse_width),
    .max_counter_i (CounterMax),
    .modulated_o
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin : main
    if (!rst_ni) begin
      pulse_width <= 0;
      tick_counter <= 0;
    end else if (impulse_i != 0) begin
      pulse_width <= CounterMax;
      tick_counter <= NumTicks;
    end else if (pulse_width != 0) begin
      if (tick_counter == 0) begin
        pulse_width <= pulse_width - 1;
        tick_counter <= NumTicks;
      end else begin
        tick_counter <= tick_counter - 1;
      end
    end
  end : main
endmodule : pwm_fade
