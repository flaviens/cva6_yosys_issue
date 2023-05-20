// Copyright Flavien Solt, ETH Zurich.
// Licensed under the General Public License, Version 3.0, see LICENSE for details.
// SPDX-License-Identifier: GPL-3.0-only

// Toplevel module without taints.

module ariane_tiny_soc #(
    parameter int unsigned NumTaints = 1,

    parameter int unsigned NumWords = 1 << 20,
    parameter int unsigned AddrWidth = 64,
    parameter int unsigned DataWidth = 64,

    parameter int unsigned StrbWidth = DataWidth >> 3,
    localparam type addr_t = logic [AddrWidth-1:0],
    localparam type data_t = logic [DataWidth-1:0],
    localparam type strb_t = logic [StrbWidth-1:0]
) (
  input logic clk_i,
  input logic rst_ni,

  output logic  mem_req_o,
  output addr_t mem_addr_o,
  output data_t mem_wdata_o,
  output strb_t mem_strb_o,
  output logic  mem_we_o,
  output data_t mem_rdata_o
);

  logic  mem_gnt   /* verilator public */;
  // data_t mem_rdata;

  ariane_mem_top #(
    // ariane_mem_top is pre-parametrized
    // .AXI_USER_WIDTH(1),
    // .AXI_ADDRESS_WIDTH(AddrWidth),
    // .AXI_DATA_WIDTH(DataWidth)
  ) i_ariane_mem_top (
    .clk_i,
    .rst_ni,
    .mem_req_o(mem_req_o),
    .mem_gnt_i(mem_gnt),
    .mem_addr_o(mem_addr_o),
    .mem_wdata_o(mem_wdata_o),
    .mem_strb_o(mem_strb_o),
    .mem_we_o(mem_we_o),
    .mem_rdata_i(mem_rdata_o),

    .boot_addr_i(64'h80000000),
    .hart_id_i('0),
    .irq_i('0),
    .ipi_i('0),
    .time_irq_i('0),
    .debug_req_i('0)
  );

  ///////////////////////////////
  // Instruction SRAM instance //
  ///////////////////////////////

  mem #(
    .Width(DataWidth),
    .Depth(NumWords),
    .RelocateRequestUp(64'h10000000) // 80000000 >> 3
  ) i_sram (
    .clk_i,
    .rst_ni,

    .req_i(mem_req_o),
    .write_i(mem_we_o),
    .addr_i(mem_addr_o >> 3), // 64-bit words
    .wdata_i(mem_wdata_o),
    .wmask_i({{8{mem_strb_o[7]}}, {8{mem_strb_o[6]}}, {8{mem_strb_o[5]}}, {8{mem_strb_o[4]}}, {8{mem_strb_o[3]}}, {8{mem_strb_o[2]}}, {8{mem_strb_o[1]}}, {8{mem_strb_o[0]}}}),
    .rdata_o(mem_rdata_o)
  );

  assign mem_gnt = 1'b1;

endmodule
