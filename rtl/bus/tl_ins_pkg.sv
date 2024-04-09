// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// tl_ins package generated by `tlgen.py` tool

package tl_ins_pkg;

  localparam logic [31:0] ADDR_SPACE_SRAM_INS = 32'h 00100000;
  localparam logic [31:0] ADDR_SPACE_DBG_DEV  = 32'h b0000000;

  localparam logic [31:0] ADDR_MASK_SRAM_INS = 32'h 0001ffff;
  localparam logic [31:0] ADDR_MASK_DBG_DEV  = 32'h 0000ffff;

  localparam int N_HOST   = 1;
  localparam int N_DEVICE = 2;

  typedef enum int {
    TlSramIns = 0,
    TlDbgDev = 1
  } tl_device_e;

  typedef enum int {
    TlIbexIns = 0
  } tl_host_e;

endpackage
