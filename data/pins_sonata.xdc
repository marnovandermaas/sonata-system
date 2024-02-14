## Copyright lowRISC contributors.
## Licensed under the Apache License, Version 2.0, see LICENSE for details.
## SPDX-License-Identifier: Apache-2.0

# Using the names in the PCB design, they should match this file with a case-insensitive search:
# https://github.com/newaetech/sonata-pcb/tree/main

## Clocks
create_clock -period 40.000 -name mainClk -waveform {0.000 20.000} [get_ports mainClk]

set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports mainClk]

## Reset
set_property -dict {PACKAGE_PIN R11 IOSTANDARD LVCMOS33} [get_ports nrst]

## General purpose LEDs
set_property -dict {PACKAGE_PIN B13 IOSTANDARD LVCMOS33} [get_ports {usrLed[0]}]
set_property -dict {PACKAGE_PIN B14 IOSTANDARD LVCMOS33} [get_ports {usrLed[1]}]
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33} [get_ports {usrLed[2]}]
set_property -dict {PACKAGE_PIN B12 IOSTANDARD LVCMOS33} [get_ports {usrLed[3]}]
set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports {usrLed[4]}]
set_property -dict {PACKAGE_PIN A11 IOSTANDARD LVCMOS33} [get_ports {usrLed[5]}]
set_property -dict {PACKAGE_PIN F13 IOSTANDARD LVCMOS33} [get_ports {usrLed[6]}]
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {usrLed[7]}]

set_output_delay -clock mainClk 0.000 [get_ports usrLed]

## Switch and button input
set_property -dict {PACKAGE_PIN D12 IOSTANDARD LVCMOS33} [get_ports {usrSw[0]}]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports {usrSw[1]}]
set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports {usrSw[2]}]
set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS33} [get_ports {usrSw[3]}]
set_property -dict {PACKAGE_PIN A15 IOSTANDARD LVCMOS33} [get_ports {usrSw[4]}]
set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports {usrSw[5]}]
set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33} [get_ports {usrSw[6]}]
set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports {usrSw[7]}]
set_property -dict {PACKAGE_PIN F5 IOSTANDARD LVCMOS18} [get_ports {navSw[0]}]
set_property -dict {PACKAGE_PIN D8 IOSTANDARD LVCMOS18} [get_ports {navSw[1]}]
set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS18} [get_ports {navSw[2]}]
set_property -dict {PACKAGE_PIN E7 IOSTANDARD LVCMOS18} [get_ports {navSw[3]}]
set_property -dict {PACKAGE_PIN D7 IOSTANDARD LVCMOS18} [get_ports {navSw[4]}]

## CHERI error LEDs
set_property -dict {PACKAGE_PIN K6 IOSTANDARD LVCMOS33} [get_ports {cheriErr[0]}]
set_property -dict {PACKAGE_PIN L1 IOSTANDARD LVCMOS33} [get_ports {cheriErr[1]}]
set_property -dict {PACKAGE_PIN M1 IOSTANDARD LVCMOS33} [get_ports {cheriErr[2]}]
set_property -dict {PACKAGE_PIN K3 IOSTANDARD LVCMOS33} [get_ports {cheriErr[3]}]
set_property -dict {PACKAGE_PIN L3 IOSTANDARD LVCMOS33} [get_ports {cheriErr[4]}]
set_property -dict {PACKAGE_PIN N2 IOSTANDARD LVCMOS33} [get_ports {cheriErr[5]}]
set_property -dict {PACKAGE_PIN N1 IOSTANDARD LVCMOS33} [get_ports {cheriErr[6]}]
set_property -dict {PACKAGE_PIN M3 IOSTANDARD LVCMOS33} [get_ports {cheriErr[7]}]
set_property -dict {PACKAGE_PIN M2 IOSTANDARD LVCMOS33} [get_ports {cheriErr[8]}]

## Status LEDs
set_property -dict {PACKAGE_PIN K5 IOSTANDARD LVCMOS33} [get_ports led_legacy]
set_property -dict {PACKAGE_PIN L4 IOSTANDARD LVCMOS33} [get_ports led_cheri]
set_property -dict {PACKAGE_PIN L6 IOSTANDARD LVCMOS33} [get_ports led_halted]
set_property -dict {PACKAGE_PIN L5 IOSTANDARD LVCMOS33} [get_ports led_bootok]

## LCD display
set_property -dict {PACKAGE_PIN R6 IOSTANDARD LVCMOS33} [get_ports lcd_rst]
set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVCMOS33} [get_ports lcd_dc]
set_property -dict {PACKAGE_PIN R3 IOSTANDARD LVCMOS33} [get_ports lcd_copi]
set_property -dict {PACKAGE_PIN R5 IOSTANDARD LVCMOS33} [get_ports lcd_clk]
set_property -dict {PACKAGE_PIN P5 IOSTANDARD LVCMOS33} [get_ports lcd_cs]

## UART
set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports ser0_tx]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports ser0_rx]

## Switches
set_property PULLTYPE PULLUP [get_ports {usrSw[7]}]
set_property PULLTYPE PULLUP [get_ports {usrSw[6]}]
set_property PULLTYPE PULLUP [get_ports {usrSw[5]}]
set_property PULLTYPE PULLUP [get_ports {usrSw[4]}]
set_property PULLTYPE PULLUP [get_ports {usrSw[3]}]
set_property PULLTYPE PULLUP [get_ports {usrSw[2]}]
set_property PULLTYPE PULLUP [get_ports {usrSw[1]}]
set_property PULLTYPE PULLUP [get_ports {usrSw[0]}]
set_property PULLTYPE PULLUP [get_ports {navSw[4]}]
set_property PULLTYPE PULLUP [get_ports {navSw[3]}]
set_property PULLTYPE PULLUP [get_ports {navSw[2]}]
set_property PULLTYPE PULLUP [get_ports {navSw[1]}]
set_property PULLTYPE PULLUP [get_ports {navSw[0]}]

## Voltage
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]



create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clkgen/clk_sys]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 31 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {u_sonata_system/u_top/u_ibex_core/pc_wb[1]} {u_sonata_system/u_top/u_ibex_core/pc_wb[2]} {u_sonata_system/u_top/u_ibex_core/pc_wb[3]} {u_sonata_system/u_top/u_ibex_core/pc_wb[4]} {u_sonata_system/u_top/u_ibex_core/pc_wb[5]} {u_sonata_system/u_top/u_ibex_core/pc_wb[6]} {u_sonata_system/u_top/u_ibex_core/pc_wb[7]} {u_sonata_system/u_top/u_ibex_core/pc_wb[8]} {u_sonata_system/u_top/u_ibex_core/pc_wb[9]} {u_sonata_system/u_top/u_ibex_core/pc_wb[10]} {u_sonata_system/u_top/u_ibex_core/pc_wb[11]} {u_sonata_system/u_top/u_ibex_core/pc_wb[12]} {u_sonata_system/u_top/u_ibex_core/pc_wb[13]} {u_sonata_system/u_top/u_ibex_core/pc_wb[14]} {u_sonata_system/u_top/u_ibex_core/pc_wb[15]} {u_sonata_system/u_top/u_ibex_core/pc_wb[16]} {u_sonata_system/u_top/u_ibex_core/pc_wb[17]} {u_sonata_system/u_top/u_ibex_core/pc_wb[18]} {u_sonata_system/u_top/u_ibex_core/pc_wb[19]} {u_sonata_system/u_top/u_ibex_core/pc_wb[20]} {u_sonata_system/u_top/u_ibex_core/pc_wb[21]} {u_sonata_system/u_top/u_ibex_core/pc_wb[22]} {u_sonata_system/u_top/u_ibex_core/pc_wb[23]} {u_sonata_system/u_top/u_ibex_core/pc_wb[24]} {u_sonata_system/u_top/u_ibex_core/pc_wb[25]} {u_sonata_system/u_top/u_ibex_core/pc_wb[26]} {u_sonata_system/u_top/u_ibex_core/pc_wb[27]} {u_sonata_system/u_top/u_ibex_core/pc_wb[28]} {u_sonata_system/u_top/u_ibex_core/pc_wb[29]} {u_sonata_system/u_top/u_ibex_core/pc_wb[30]} {u_sonata_system/u_top/u_ibex_core/pc_wb[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 32 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[0]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[1]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[2]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[3]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[4]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[5]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[6]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[7]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[8]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[9]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[10]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[11]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[12]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[13]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[14]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[15]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[16]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[17]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[18]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[19]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[20]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[21]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[22]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[23]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[24]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[25]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[26]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[27]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[28]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[29]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[30]} {u_sonata_system/u_top/u_ibex_core/mepc_d_combi[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 6 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {u_sonata_system/u_top/u_ibex_core/mcause_d[0]} {u_sonata_system/u_top/u_ibex_core/mcause_d[1]} {u_sonata_system/u_top/u_ibex_core/mcause_d[2]} {u_sonata_system/u_top/u_ibex_core/mcause_d[3]} {u_sonata_system/u_top/u_ibex_core/mcause_d[4]} {u_sonata_system/u_top/u_ibex_core/mcause_d[5]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 30 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {u_sonata_system/host_addr[0]_8[2]} {u_sonata_system/host_addr[0]_8[3]} {u_sonata_system/host_addr[0]_8[4]} {u_sonata_system/host_addr[0]_8[5]} {u_sonata_system/host_addr[0]_8[6]} {u_sonata_system/host_addr[0]_8[7]} {u_sonata_system/host_addr[0]_8[8]} {u_sonata_system/host_addr[0]_8[9]} {u_sonata_system/host_addr[0]_8[10]} {u_sonata_system/host_addr[0]_8[11]} {u_sonata_system/host_addr[0]_8[12]} {u_sonata_system/host_addr[0]_8[13]} {u_sonata_system/host_addr[0]_8[14]} {u_sonata_system/host_addr[0]_8[15]} {u_sonata_system/host_addr[0]_8[16]} {u_sonata_system/host_addr[0]_8[17]} {u_sonata_system/host_addr[0]_8[18]} {u_sonata_system/host_addr[0]_8[19]} {u_sonata_system/host_addr[0]_8[20]} {u_sonata_system/host_addr[0]_8[21]} {u_sonata_system/host_addr[0]_8[22]} {u_sonata_system/host_addr[0]_8[23]} {u_sonata_system/host_addr[0]_8[24]} {u_sonata_system/host_addr[0]_8[25]} {u_sonata_system/host_addr[0]_8[26]} {u_sonata_system/host_addr[0]_8[27]} {u_sonata_system/host_addr[0]_8[28]} {u_sonata_system/host_addr[0]_8[29]} {u_sonata_system/host_addr[0]_8[30]} {u_sonata_system/host_addr[0]_8[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 10 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {u_sonata_system/pwm_o[0]} {u_sonata_system/pwm_o[1]} {u_sonata_system/pwm_o[2]} {u_sonata_system/pwm_o[3]} {u_sonata_system/pwm_o[4]} {u_sonata_system/pwm_o[5]} {u_sonata_system/pwm_o[6]} {u_sonata_system/pwm_o[7]} {u_sonata_system/pwm_o[8]} {u_sonata_system/pwm_o[9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 32 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {u_sonata_system/core_instr_rdata[0]} {u_sonata_system/core_instr_rdata[1]} {u_sonata_system/core_instr_rdata[2]} {u_sonata_system/core_instr_rdata[3]} {u_sonata_system/core_instr_rdata[4]} {u_sonata_system/core_instr_rdata[5]} {u_sonata_system/core_instr_rdata[6]} {u_sonata_system/core_instr_rdata[7]} {u_sonata_system/core_instr_rdata[8]} {u_sonata_system/core_instr_rdata[9]} {u_sonata_system/core_instr_rdata[10]} {u_sonata_system/core_instr_rdata[11]} {u_sonata_system/core_instr_rdata[12]} {u_sonata_system/core_instr_rdata[13]} {u_sonata_system/core_instr_rdata[14]} {u_sonata_system/core_instr_rdata[15]} {u_sonata_system/core_instr_rdata[16]} {u_sonata_system/core_instr_rdata[17]} {u_sonata_system/core_instr_rdata[18]} {u_sonata_system/core_instr_rdata[19]} {u_sonata_system/core_instr_rdata[20]} {u_sonata_system/core_instr_rdata[21]} {u_sonata_system/core_instr_rdata[22]} {u_sonata_system/core_instr_rdata[23]} {u_sonata_system/core_instr_rdata[24]} {u_sonata_system/core_instr_rdata[25]} {u_sonata_system/core_instr_rdata[26]} {u_sonata_system/core_instr_rdata[27]} {u_sonata_system/core_instr_rdata[28]} {u_sonata_system/core_instr_rdata[29]} {u_sonata_system/core_instr_rdata[30]} {u_sonata_system/core_instr_rdata[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 11 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {u_sonata_system/gp_o[0]} {u_sonata_system/gp_o[1]} {u_sonata_system/gp_o[2]} {u_sonata_system/gp_o[3]} {u_sonata_system/gp_o[4]} {u_sonata_system/gp_o[5]} {u_sonata_system/gp_o[6]} {u_sonata_system/gp_o[7]} {u_sonata_system/gp_o[8]} {u_sonata_system/gp_o[9]} {u_sonata_system/gp_o[10]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 33 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {u_sonata_system/cheri_wdata[0]} {u_sonata_system/cheri_wdata[1]} {u_sonata_system/cheri_wdata[2]} {u_sonata_system/cheri_wdata[3]} {u_sonata_system/cheri_wdata[4]} {u_sonata_system/cheri_wdata[5]} {u_sonata_system/cheri_wdata[6]} {u_sonata_system/cheri_wdata[7]} {u_sonata_system/cheri_wdata[8]} {u_sonata_system/cheri_wdata[9]} {u_sonata_system/cheri_wdata[10]} {u_sonata_system/cheri_wdata[11]} {u_sonata_system/cheri_wdata[12]} {u_sonata_system/cheri_wdata[13]} {u_sonata_system/cheri_wdata[14]} {u_sonata_system/cheri_wdata[15]} {u_sonata_system/cheri_wdata[16]} {u_sonata_system/cheri_wdata[17]} {u_sonata_system/cheri_wdata[18]} {u_sonata_system/cheri_wdata[19]} {u_sonata_system/cheri_wdata[20]} {u_sonata_system/cheri_wdata[21]} {u_sonata_system/cheri_wdata[22]} {u_sonata_system/cheri_wdata[23]} {u_sonata_system/cheri_wdata[24]} {u_sonata_system/cheri_wdata[25]} {u_sonata_system/cheri_wdata[26]} {u_sonata_system/cheri_wdata[27]} {u_sonata_system/cheri_wdata[28]} {u_sonata_system/cheri_wdata[29]} {u_sonata_system/cheri_wdata[30]} {u_sonata_system/cheri_wdata[31]} {u_sonata_system/cheri_wdata[32]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 32 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {u_sonata_system/device_wdata[0]_51[0]} {u_sonata_system/device_wdata[0]_51[1]} {u_sonata_system/device_wdata[0]_51[2]} {u_sonata_system/device_wdata[0]_51[3]} {u_sonata_system/device_wdata[0]_51[4]} {u_sonata_system/device_wdata[0]_51[5]} {u_sonata_system/device_wdata[0]_51[6]} {u_sonata_system/device_wdata[0]_51[7]} {u_sonata_system/device_wdata[0]_51[8]} {u_sonata_system/device_wdata[0]_51[9]} {u_sonata_system/device_wdata[0]_51[10]} {u_sonata_system/device_wdata[0]_51[11]} {u_sonata_system/device_wdata[0]_51[12]} {u_sonata_system/device_wdata[0]_51[13]} {u_sonata_system/device_wdata[0]_51[14]} {u_sonata_system/device_wdata[0]_51[15]} {u_sonata_system/device_wdata[0]_51[16]} {u_sonata_system/device_wdata[0]_51[17]} {u_sonata_system/device_wdata[0]_51[18]} {u_sonata_system/device_wdata[0]_51[19]} {u_sonata_system/device_wdata[0]_51[20]} {u_sonata_system/device_wdata[0]_51[21]} {u_sonata_system/device_wdata[0]_51[22]} {u_sonata_system/device_wdata[0]_51[23]} {u_sonata_system/device_wdata[0]_51[24]} {u_sonata_system/device_wdata[0]_51[25]} {u_sonata_system/device_wdata[0]_51[26]} {u_sonata_system/device_wdata[0]_51[27]} {u_sonata_system/device_wdata[0]_51[28]} {u_sonata_system/device_wdata[0]_51[29]} {u_sonata_system/device_wdata[0]_51[30]} {u_sonata_system/device_wdata[0]_51[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list u_sonata_system/u_top/u_ibex_core/controller_i/illegal_insn_q]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {u_sonata_system/u_top/u_ibex_core/cpuctrl_q[double_fault_seen]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {u_sonata_system/host_req[0]_49}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list u_sonata_system/u_top/u_ibex_core/csr_mstatus_mie]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list u_sonata_system/u_top/u_ibex_core/csr_mstatus_tw]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list u_sonata_system/u_top/u_ibex_core/mstatus_en_combi]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {u_sonata_system/u_top/u_ibex_core/mstatus_q[mprv]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_sys]
