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

  if ($clog2(NumTicks) < CounterSize) begin : check_counter_width
    $fatal("There are too few ticks, either lower the counter size or raise the number of ticks.");
  end

  logic [$clog2(NumTicks+1):0] tick_counter;
  logic [CounterSize-1:0] counter, pulse_width;

  // The bottom `CounterSize` bits of the tick_counter
  // are used as the pwm counter.
  assign counter = tick_counter[CounterSize-1:0];

  assign modulated_o = counter < pulse_width;

  always_ff @(posedge clk_i or negedge rst_ni) begin : main
    if (!rst_ni) begin
      pulse_width <= 0;
      tick_counter <= 0;
    end else if (impulse_i != 0) begin
      pulse_width <= CounterMax;
      tick_counter <= 0;
    end else if (pulse_width != 0) begin
      if (tick_counter == NumTicks) begin
        pulse_width <= pulse_width - 1;
        tick_counter <= 0;
      end else begin
        tick_counter <= tick_counter + 1;
      end
    end
  end : main
endmodule : pwm_fade
