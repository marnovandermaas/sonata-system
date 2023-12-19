// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// The Sonata system, which instantiates and connects the following blocks:
// - TileLink Uncached Lightweight (TL-UL) bus.
// - Ibex top module.
// - RAM memory to contain code and data.
// - GPIO driving logic.
// - UART for serial communication.
// - Timer.
// - Debug module.
// - SPI for driving LCD screen
module sonata_system #(
  parameter int GpiWidth     = 8,
  parameter int GpoWidth     = 16,
  parameter int PwmWidth     = 12,
  parameter     SRAMInitFile = ""
) (
  input logic                 clk_sys_i,
  input logic                 rst_sys_ni,

  input  logic [GpiWidth-1:0] gp_i,
  output logic [GpoWidth-1:0] gp_o,
  output logic [PwmWidth-1:0] pwm_o,
  input  logic                uart_rx_i,
  output logic                uart_tx_o,
  input  logic                spi_rx_i,
  output logic                spi_tx_o,
  output logic                spi_sck_o
);

  //////////////////////////////////////////////
  // Signals, types and parameters for system //
  //////////////////////////////////////////////

  localparam logic [31:0] MEM_SIZE    = 64 * 1024; // 64 KiB
  localparam int SRAM_ADDRESS_WIDTH   = $clog2(MEM_SIZE);
  localparam logic [31:0] DEBUG_START = 32'h1a110000;
  localparam int PwmCtrSize           = 8;

  // debug functionality is disabled
  localparam int unsigned DbgHwBreakNum = 0;
  localparam bit          DbgTriggerEn  = 1'b0;

  typedef enum int {
    CoreD
  } bus_host_e;

  typedef enum int {
    Ram,
    Gpio,
    Pwm,
    Uart,
    Timer,
    Spi
  } bus_device_e;

  localparam int NrDevices = 6;
  localparam int NrHosts = 1;

  // interrupts
  logic timer_irq;
  logic uart_irq;

  // host and device signals
  logic           host_req      [NrHosts];
  logic           host_gnt      [NrHosts];
  logic [31:0]    host_addr     [NrHosts];
  logic           host_we       [NrHosts];
  logic [ 3:0]    host_be       [NrHosts];
  logic [31:0]    host_wdata    [NrHosts];
  logic           host_rvalid   [NrHosts];
  logic [31:0]    host_rdata    [NrHosts];
  logic           host_err      [NrHosts];

  // TODO remove these tie-offs once bus support CHERI tags.
  logic [32:0]    cheri_wdata;
  //cheri_wdata[32] is marked as unused at the bottom of this file.
  logic [32:0]    cheri_rdata;
  assign host_wdata[CoreD] = cheri_wdata[31:0];
  assign cheri_rdata[32]   = 1'b0;
  assign cheri_rdata[31:0] = host_rdata[CoreD];

  // devices
  logic           device_req    [NrDevices];
  logic [31:0]    device_addr   [NrDevices];
  logic           device_re     [NrDevices]; // read enable
  logic           device_we     [NrDevices]; // write enable
  logic [ 3:0]    device_be     [NrDevices];
  logic [31:0]    device_wdata  [NrDevices];
  logic           device_rvalid [NrDevices];
  logic [31:0]    device_rdata  [NrDevices];
  logic           device_err    [NrDevices];

  // Generate requests from read and write enables
  assign device_req[Gpio]  = device_re[Gpio]  | device_we[Gpio];
  assign device_req[Pwm]   = device_re[Pwm]   | device_we[Pwm];
  assign device_req[Uart]  = device_re[Uart]  | device_we[Uart];
  assign device_req[Timer] = device_re[Timer] | device_we[Timer];
  assign device_req[Spi]   = device_re[Spi]   | device_we[Spi];

  // Instruction fetch signals
  logic        core_instr_req;
  logic        core_instr_req_filtered;
  logic        core_instr_gnt;
  logic        core_instr_rvalid;
  logic [31:0] core_instr_addr;
  logic [31:0] core_instr_rdata;
  logic        core_instr_err;

  logic        mem_instr_req;
  logic        mem_instr_rvalid;
  logic [31:0] mem_instr_addr;
  logic [31:0] mem_instr_rdata;

  assign core_instr_req_filtered =
      core_instr_req & ((core_instr_addr & ~(tl_main_pkg::ADDR_MASK_SRAM)) == tl_main_pkg::ADDR_SPACE_SRAM);

  // Internally generated resets cause IMPERFECTSCH warnings
  /* verilator lint_off IMPERFECTSCH */
  logic        rst_core_n;

  // Tie-off unused error signals
  assign device_err[Ram]     = 1'b0;
  assign device_err[Gpio]    = 1'b0;
  assign device_err[Pwm]     = 1'b0;
  assign device_err[Uart]    = 1'b0;
  assign device_err[Spi]     = 1'b0;

  /////////////////////////////////////////////
  // Instantiate TL-UL crossbar and adapters //
  /////////////////////////////////////////////

  // Host interfaces
  tlul_pkg::tl_h2d_t tl_ibex_ins_h2d;
  tlul_pkg::tl_d2h_t tl_ibex_ins_d2h;

  tlul_pkg::tl_h2d_t tl_ibex_lsu_h2d_d;
  tlul_pkg::tl_d2h_t tl_ibex_lsu_d2h_d;
  tlul_pkg::tl_h2d_t tl_ibex_lsu_h2d_q;
  tlul_pkg::tl_d2h_t tl_ibex_lsu_d2h_q;

  // Device interfaces
  tlul_pkg::tl_h2d_t tl_sram_h2d;
  tlul_pkg::tl_d2h_t tl_sram_d2h;
  tlul_pkg::tl_h2d_t tl_gpio_h2d;
  tlul_pkg::tl_d2h_t tl_gpio_d2h;
  tlul_pkg::tl_h2d_t tl_uart_h2d;
  tlul_pkg::tl_d2h_t tl_uart_d2h;
  tlul_pkg::tl_h2d_t tl_timer_h2d;
  tlul_pkg::tl_d2h_t tl_timer_d2h;
  tlul_pkg::tl_h2d_t tl_pwm_h2d;
  tlul_pkg::tl_d2h_t tl_pwm_d2h;
  tlul_pkg::tl_h2d_t tl_spi_h2d;
  tlul_pkg::tl_d2h_t tl_spi_d2h;

  xbar_main xbar (
    .clk_sys_i (clk_sys_i),
    .rst_sys_ni(rst_sys_ni),

    // Host interfaces
    .tl_ibex_lsu_i(tl_ibex_lsu_h2d_q),
    .tl_ibex_lsu_o(tl_ibex_lsu_d2h_q),

    // Device interfaces
    .tl_sram_o (tl_sram_h2d),
    .tl_sram_i (tl_sram_d2h),
    .tl_gpio_o (tl_gpio_h2d),
    .tl_gpio_i (tl_gpio_d2h),
    .tl_uart_o (tl_uart_h2d),
    .tl_uart_i (tl_uart_d2h),
    .tl_timer_o(tl_timer_h2d),
    .tl_timer_i(tl_timer_d2h),
    .tl_pwm_o  (tl_pwm_h2d),
    .tl_pwm_i  (tl_pwm_d2h),
    .tl_spi_o  (tl_spi_h2d),
    .tl_spi_i  (tl_spi_d2h),

    .scanmode_i(prim_mubi_pkg::MuBi4False)
  );

  // TL-UL host adapter(s)

  tlul_adapter_host ibex_ins_host_adapter (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    .req_i       (core_instr_req_filtered),
    .gnt_o       (core_instr_gnt),
    .addr_i      (core_instr_addr),
    .we_i        ('0),
    .wdata_i     ('0),
    .wdata_intg_i('0),
    .be_i        ('0),
    .instr_type_i(prim_mubi_pkg::MuBi4True),

    .valid_o     (core_instr_rvalid),
    .rdata_o     (core_instr_rdata),
    .rdata_intg_o(),
    .err_o       (core_instr_err),
    .intg_err_o  (),

    .tl_o(tl_ibex_ins_h2d),
    .tl_i(tl_ibex_ins_d2h)
  );

  tlul_adapter_host ibex_lsu_host_adapter (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    .req_i       (host_req[CoreD]),
    .gnt_o       (host_gnt[CoreD]),
    .addr_i      (host_addr[CoreD]),
    .we_i        (host_we[CoreD]),
    .wdata_i     (host_wdata[CoreD]),
    .wdata_intg_i('0),
    .be_i        (host_be[CoreD]),
    .instr_type_i(prim_mubi_pkg::MuBi4False),

    .valid_o     (host_rvalid[CoreD]),
    .rdata_o     (host_rdata[CoreD]),
    .rdata_intg_o(),
    .err_o       (host_err[CoreD]),
    .intg_err_o  (),

    .tl_o(tl_ibex_lsu_h2d_d),
    .tl_i(tl_ibex_lsu_d2h_d)
  );

  // This latch is necessary to avoid circular logic. This shows up as an `UNOPTFLAT` warning in Verilator.
  tlul_fifo_sync #(
    .ReqPass  ( 0 ),
    .RspPass  ( 0 ),
    .ReqDepth ( 2 ),
    .RspDepth ( 2 )
  ) tl_ibex_lsu_fifo (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    .tl_h_i(tl_ibex_lsu_h2d_d),
    .tl_h_o(tl_ibex_lsu_d2h_d),
    .tl_d_o(tl_ibex_lsu_h2d_q),
    .tl_d_i(tl_ibex_lsu_d2h_q),

    .spare_req_i(1'b0),
    .spare_req_o(),
    .spare_rsp_i(1'b0),
    .spare_rsp_o()
  );

  // TL-UL device adapters

  tlul_adapter_sram #(
    .SramAw( SRAM_ADDRESS_WIDTH ),
    .EnableRspIntgGen( 1 )
  ) sram_inst_device_adapter (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    // TL-UL interface
    .tl_i(tl_ibex_ins_h2d),
    .tl_o(tl_ibex_ins_d2h),

    // Control interface
    .en_ifetch_i (prim_mubi_pkg::MuBi4True),

    // SRAM interface
    .req_o(mem_instr_req),
    .req_type_o(),
    .gnt_i(mem_instr_req),
    .we_o(),
    .addr_o(mem_instr_addr[SRAM_ADDRESS_WIDTH-1:0]),
    .wdata_o(),
    .wmask_o(),
    .intg_error_o(),
    .rdata_i(mem_instr_rdata),
    .rvalid_i(mem_instr_rvalid),
    .rerror_i(2'b00)
  );

  assign mem_instr_addr[31:SRAM_ADDRESS_WIDTH] = '0;

  logic [31:0] sram_data_bit_enable;
  logic [1:0]  sram_data_read_error;

  tlul_adapter_sram #(
    .SramAw( SRAM_ADDRESS_WIDTH ),
    .EnableRspIntgGen( 1 )
  ) sram_data_device_adapter (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    // TL-UL interface
    .tl_i(tl_sram_h2d),
    .tl_o(tl_sram_d2h),

    // Control interface
    .en_ifetch_i (prim_mubi_pkg::MuBi4False),

    // SRAM interface
    .req_o(device_req[Ram]),
    .req_type_o(),
    .gnt_i(device_req[Ram]),
    .we_o(device_we[Ram]),
    .addr_o(device_addr[Ram][SRAM_ADDRESS_WIDTH-1:0]),
    .wdata_o(device_wdata[Ram]),
    .wmask_o(sram_data_bit_enable),
    .intg_error_o(),
    .rdata_i(device_rdata[Ram]),
    .rvalid_i(device_rvalid[Ram]),
    .rerror_i(sram_data_read_error)
  );

  // Translate bit-level enable signals to Byte-level.
  assign device_be[Ram][0] = |sram_data_bit_enable[ 7: 0];
  assign device_be[Ram][1] = |sram_data_bit_enable[15: 8];
  assign device_be[Ram][2] = |sram_data_bit_enable[23:16];
  assign device_be[Ram][3] = |sram_data_bit_enable[31:24];

  assign sram_data_read_error = device_err[Ram] ? 2'b10 : 2'b00;

  tlul_adapter_reg #(
    .EnableRspIntgGen( 1 ),
    .AccessLatency   ( 1 )
  ) gpio_device_adapter (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    // TL-UL interface
    .tl_i(tl_gpio_h2d),
    .tl_o(tl_gpio_d2h),

    // Control interface
    .en_ifetch_i (prim_mubi_pkg::MuBi4False),
    .intg_error_o(),

    // Register interface
    .re_o   (device_re[Gpio]),
    .we_o   (device_we[Gpio]),
    .addr_o (device_addr[Gpio][7:0]),
    .wdata_o(device_wdata[Gpio]),
    .be_o   (device_be[Gpio]),
    .busy_i ('0),
    // The following two signals are expected
    // to be returned in AccessLatency cycles.
    .rdata_i(device_rdata[Gpio]),
    // This can be a write or read error.
    .error_i(device_err[Gpio])
  );

  tlul_adapter_reg #(
    .EnableRspIntgGen( 1 ),
    .AccessLatency   ( 1 )
  ) pwm_device_adapter (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    // TL-UL interface
    .tl_i(tl_pwm_h2d),
    .tl_o(tl_pwm_d2h),

    // Control interface
    .en_ifetch_i (prim_mubi_pkg::MuBi4False),
    .intg_error_o(),

    // Register interface
    .re_o   (device_re[Pwm]),
    .we_o   (device_we[Pwm]),
    .addr_o (device_addr[Pwm][7:0]),
    .wdata_o(device_wdata[Pwm]),
    .be_o   (device_be[Pwm]),
    .busy_i ('0),
    // The following two signals are expected
    // to be returned in AccessLatency cycles.
    .rdata_i(device_rdata[Pwm]),
    // This can be a write or read error.
    .error_i(device_err[Pwm])
  );

  tlul_adapter_reg #(
    .EnableRspIntgGen( 1 ),
    .AccessLatency   ( 1 )
  ) uart_device_adapter (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    // TL-UL interface
    .tl_i(tl_uart_h2d),
    .tl_o(tl_uart_d2h),

    // Control interface
    .en_ifetch_i (prim_mubi_pkg::MuBi4False),
    .intg_error_o(),

    // Register interface
    .re_o   (device_re[Uart]),
    .we_o   (device_we[Uart]),
    .addr_o (device_addr[Uart][7:0]),
    .wdata_o(device_wdata[Uart]),
    .be_o   (device_be[Uart]),
    .busy_i ('0),
    // The following two signals are expected
    // to be returned in AccessLatency cycles.
    .rdata_i(device_rdata[Uart]),
    // This can be a write or read error.
    .error_i(device_err[Uart])
  );

  tlul_adapter_reg #(
    .EnableRspIntgGen( 1 ),
    .AccessLatency   ( 1 )
  ) timer_device_adapter (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    // TL-UL interface
    .tl_i(tl_timer_h2d),
    .tl_o(tl_timer_d2h),

    // Control interface
    .en_ifetch_i (prim_mubi_pkg::MuBi4False),
    .intg_error_o(),

    // Register interface
    .re_o   (device_re[Timer]),
    .we_o   (device_we[Timer]),
    .addr_o (device_addr[Timer][7:0]),
    .wdata_o(device_wdata[Timer]),
    .be_o   (device_be[Timer]),
    .busy_i ('0),
    // The following two signals are expected
    // to be returned in AccessLatency cycles.
    .rdata_i(device_rdata[Timer]),
    // This can be a write or read error.
    .error_i(device_err[Timer])
  );

  tlul_adapter_reg #(
    .EnableRspIntgGen( 1 ),
    .AccessLatency   ( 1 )
  ) spi_device_adapter (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    // TL-UL interface
    .tl_i(tl_spi_h2d),
    .tl_o(tl_spi_d2h),

    // Control interface
    .en_ifetch_i (prim_mubi_pkg::MuBi4False),
    .intg_error_o(),

    // Register interface
    .re_o   (device_re[Spi]),
    .we_o   (device_we[Spi]),
    .addr_o (device_addr[Spi][7:0]),
    .wdata_o(device_wdata[Spi]),
    .be_o   (device_be[Spi]),
    .busy_i ('0),
    // The following two signals are expected
    // to be returned in AccessLatency cycles.
    .rdata_i(device_rdata[Spi]),
    // This can be a write or read error.
    .error_i(device_err[Spi])
  );

  //////////////////////////////////////////////
  // Core and Hardware IP Block Instantiation //
  //////////////////////////////////////////////

  assign rst_core_n = rst_sys_ni;

  ibexc_top #(
    .DmHaltAddr      ( DEBUG_START + dm::HaltAddress[31:0]     ),
    .DmExceptionAddr ( DEBUG_START + dm::ExceptionAddress[31:0]),
    .DbgTriggerEn    ( DbgTriggerEn                            ),
    .DbgHwBreakNum   ( DbgHwBreakNum                           ),
    .MHPMCounterNum  ( 10                                      ),
    .RV32B           ( ibex_pkg::RV32BNone                     )
  ) u_top (
    .clk_i (clk_sys_i),
    .rst_ni(rst_core_n),

    .test_en_i  ('b0),
    .scan_rst_ni(1'b1),
    .ram_cfg_i  ('b0),

    .cheri_pmode_i (1'b0), // TODO enable capability mode
    .cheri_tsafe_en_i (1'b0), // TODO enable temporal safety

    .hart_id_i(32'b0),
    // First instruction executed is at 0x0 + 0x80
    .boot_addr_i(32'h00100000),

    .instr_req_o       (core_instr_req),
    .instr_gnt_i       (core_instr_gnt),
    .instr_rvalid_i    (core_instr_rvalid),
    .instr_addr_o      (core_instr_addr),
    .instr_rdata_i     (core_instr_rdata),
    .instr_rdata_intg_i('0),
    .instr_err_i       (core_instr_err),

    .data_req_o       (host_req[CoreD]),
    .data_is_cap_o    (), // TODO connect this to memory when CHERI is enabled.
    .data_gnt_i       (host_gnt[CoreD]),
    .data_rvalid_i    (host_rvalid[CoreD]),
    .data_we_o        (host_we[CoreD]),
    .data_be_o        (host_be[CoreD]),
    .data_addr_o      (host_addr[CoreD]),
    .data_wdata_o     (cheri_wdata),
    .data_wdata_intg_o(),
    .data_rdata_i     (cheri_rdata),
    .data_rdata_intg_i('0),
    .data_err_i       (host_err[CoreD]),

    // TODO fill this in once revocation is enabled
    .tsmap_cs_o (),
    .tsmap_addr_o (),
    .tsmap_rdata_i (32'b0),

    // TODO fill this in
    .mmreg_corein_i (128'b0),
    .mmreg_coreout_o (),

    .irq_software_i(1'b0),
    .irq_timer_i   (timer_irq),
    .irq_external_i(1'b0),
    .irq_fast_i    ({14'b0, uart_irq}),
    .irq_nm_i      (1'b0),

    .scramble_key_valid_i('0),
    .scramble_key_i      ('0),
    .scramble_nonce_i    ('0),
    .scramble_req_o      (),

    .debug_req_i        (),
    .crash_dump_o       (),
    .double_fault_seen_o(),

    .fetch_enable_i        ('1),
    .alert_minor_o         (),
    .alert_major_internal_o(),
    .alert_major_bus_o     (),
    .core_sleep_o          ()
  );

  ram_2p #(
      .Depth       ( MEM_SIZE / 4 ),
      .AddrOffsetA ( 0 ),
      .AddrOffsetB ( 0 ),
      .MemInitFile ( SRAMInitFile )
  ) u_ram (
    .clk_i       (clk_sys_i),
    .rst_ni      (rst_sys_ni),

    .a_req_i     (device_req[Ram]),
    .a_we_i      (device_we[Ram]),
    .a_be_i      (device_be[Ram]),
    .a_addr_i    (device_addr[Ram]),
    .a_wdata_i   (device_wdata[Ram]),
    .a_rvalid_o  (device_rvalid[Ram]),
    .a_rdata_o   (device_rdata[Ram]),

    .b_req_i     (mem_instr_req),
    .b_we_i      (1'b0),
    .b_be_i      (4'b0),
    .b_addr_i    (mem_instr_addr),
    .b_wdata_i   (32'b0),
    .b_rvalid_o  (mem_instr_rvalid),
    .b_rdata_o   (mem_instr_rdata)
  );

  gpio #(
    .GpiWidth ( GpiWidth ),
    .GpoWidth ( GpoWidth )
  ) u_gpio (
    .clk_i          (clk_sys_i),
    .rst_ni         (rst_sys_ni),

    .device_req_i   (device_req[Gpio]),
    .device_addr_i  (device_addr[Gpio]),
    .device_we_i    (device_we[Gpio]),
    .device_be_i    (device_be[Gpio]),
    .device_wdata_i (device_wdata[Gpio]),
    .device_rvalid_o(device_rvalid[Gpio]),
    .device_rdata_o (device_rdata[Gpio]),

    .gp_i,
    .gp_o
  );

  pwm_wrapper #(
    .PwmWidth   ( PwmWidth   ),
    .PwmCtrSize ( PwmCtrSize ),
    .BusWidth   ( 32         )
  ) u_pwm (
    .clk_i          (clk_sys_i),
    .rst_ni         (rst_sys_ni),

    .device_req_i   (device_req[Pwm]),
    .device_addr_i  (device_addr[Pwm]),
    .device_we_i    (device_we[Pwm]),
    .device_be_i    (device_be[Pwm]),
    .device_wdata_i (device_wdata[Pwm]),
    .device_rvalid_o(device_rvalid[Pwm]),
    .device_rdata_o (device_rdata[Pwm]),

    .pwm_o
  );

  uart #(
    .ClockFrequency ( 50_000_000 )
  ) u_uart (
    .clk_i          (clk_sys_i),
    .rst_ni         (rst_sys_ni),

    .device_req_i   (device_req[Uart]),
    .device_addr_i  (device_addr[Uart]),
    .device_we_i    (device_we[Uart]),
    .device_be_i    (device_be[Uart]),
    .device_wdata_i (device_wdata[Uart]),
    .device_rvalid_o(device_rvalid[Uart]),
    .device_rdata_o (device_rdata[Uart]),

    .uart_rx_i,
    .uart_irq_o     (uart_irq),
    .uart_tx_o
  );

  spi_top #(
    .ClockFrequency(50_000_000),
    .CPOL(0),
    .CPHA(1)
  ) u_spi (
    .clk_i (clk_sys_i),
    .rst_ni(rst_sys_ni),

    .device_req_i   (device_req[Spi]),
    .device_addr_i  (device_addr[Spi]),
    .device_we_i    (device_we[Spi]),
    .device_be_i    (device_be[Spi]),
    .device_wdata_i (device_wdata[Spi]),
    .device_rvalid_o(device_rvalid[Spi]),
    .device_rdata_o (device_rdata[Spi]),

    .spi_rx_i(spi_rx_i), // Data received from SPI device
    .spi_tx_o(spi_tx_o), // Data transmitted to SPI device
    .sck_o(spi_sck_o), // Serial clock pin

    .byte_data_o() // unused
  );

  timer #(
    .DataWidth    ( 32 ),
    .AddressWidth ( 32 )
  ) u_timer (
    .clk_i         (clk_sys_i),
    .rst_ni        (rst_sys_ni),

    .timer_req_i   (device_req[Timer]),
    .timer_we_i    (device_we[Timer]),
    .timer_be_i    (device_be[Timer]),
    .timer_addr_i  (device_addr[Timer]),
    .timer_wdata_i (device_wdata[Timer]),
    .timer_rvalid_o(device_rvalid[Timer]),
    .timer_rdata_o (device_rdata[Timer]),
    .timer_err_o   (device_err[Timer]),
    .timer_intr_o  (timer_irq)
  );

  `ifdef VERILATOR
    export "DPI-C" function mhpmcounter_get;

    function automatic longint unsigned mhpmcounter_get(int index);
      return u_top.u_ibex_core.cs_registers_i.mhpmcounter[index];
    endfunction
  `endif

  logic _unused_ok;
  assign _unused_ok = cheri_wdata[32];

  for (genvar i = 0; i < NrDevices; i++) begin : gen_unused
    logic _unused_rvalid;
    assign _unused_rvalid = device_rvalid[i];
  end : gen_unused

  logic  _unused_read_enable;
  assign _unused_read_enable = device_re[Ram];
endmodule
