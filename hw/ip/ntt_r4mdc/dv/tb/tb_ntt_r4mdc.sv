// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`resetall
`timescale 1ns/10ps

`define PERIOD 5 // 100 MHz

module tb_ntt_r4mdc #(
    parameter LOG_FILE = "../sim_results.log",
    parameter TEX_FILE = "../sim_results.tex",
    parameter int unsigned DATA_WIDTH = 27,
    parameter int unsigned LOG_R = 28,
    parameter int unsigned N = 1024,
   	parameter int QINT = 134215681,
   	parameter int QINT_64 = 0,
    parameter int QDASH = 130021375,
    parameter int QDASH_64 = 0,
    parameter int QMU = 134219775,
    parameter int QMU_64 = 0,
    parameter REDUCTION = "SOLINA27",
    parameter FIFO_TYPE = "XPM",
    parameter BUTTERFLY_TYPE = "CT",
    parameter int unsigned NOF_BUTTERFLY_UNITS = 1,
    parameter int unsigned DELAY_BF = 9,   
    parameter int unsigned DELAY_MULT = 1, 
    parameter int unsigned DELAY_CONST_MULT = 1, 
    parameter int W4 = 37361560,
    parameter int W4_64 = 0,
    parameter TESTCASE_PATH = "STD128",
    parameter TEST_NAME = "STD128",
    parameter TWIDDLE_MEM_PATH = "/home/t_stelzer/projects/aisec/fhe-sv/rtl/ntt/cggi_std_128_mem_hp",
    parameter bit TWIDDLE1_OPT = 1'b0,
    parameter bit TWIDDLE2_OPT = 1'b0
)(

);
    // Parameters for length > 32-bit
    localparam [DATA_WIDTH-1:0] ACT_QINT = (DATA_WIDTH > 32) ? {QINT_64, {32{1'b0}}} | QINT : QINT;
    localparam [DATA_WIDTH-1:0] ACT_QDASH = (DATA_WIDTH > 32) ? {QDASH_64, {32{1'b0}}} | QDASH : QDASH; 
    localparam [DATA_WIDTH-1:0] ACT_QMU = (DATA_WIDTH > 32) ? {QMU_64, {32{1'b0}}} |QMU : QMU;
    localparam [DATA_WIDTH-1:0] ACT_W4 = (DATA_WIDTH > 32) ? {W4_64, {32{1'b0}}} | W4 : W4;

    logic clk, rst, intt;

    logic [DATA_WIDTH-1:0] din0[NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] din1[NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] din2[NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] din3[NOF_BUTTERFLY_UNITS-1:0];
    logic din_valid;

    logic [DATA_WIDTH-1:0] dout0[NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] dout1[NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] dout2[NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] dout3[NOF_BUTTERFLY_UNITS-1:0];
    logic dout_valid;

  // Unit under Test
  ntt_r4mdc #(
      .DATA_WIDTH(DATA_WIDTH),
      .LOG_R(LOG_R),
      .N(N),
      .QINT(ACT_QINT),
      .QDASH(ACT_QDASH),
      .REDUCTION(REDUCTION), // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo
      .FIFO_TYPE("XPM"),        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
      .BUTTERFLY_TYPE(BUTTERFLY_TYPE),    // Choose between "CT" and "GS" ToDo
      .NOF_BUTTERFLY_UNITS(NOF_BUTTERFLY_UNITS),
      .DELAY_MULT(DELAY_MULT),
      .DELAY_CONST_MULT(DELAY_CONST_MULT),
      .DELAY_BF(DELAY_BF),
      .W4(ACT_W4),
      .TWIDDLE1_OPT(TWIDDLE1_OPT),
      .TWIDDLE2_OPT(TWIDDLE2_OPT),
      .TWIDDLE_MEM_PATH(TWIDDLE_MEM_PATH)
  ) uut (
      .clk_i(clk),
      .rst_i(rst),
      .intt_i(intt),
      .data0_i(din0),
      .data1_i(din1),
      .data2_i(din2),
      .data3_i(din3),
      .data_valid_i(din_valid),

      .data0_o(dout0),
      .data1_o(dout1),
      .data2_o(dout2),
      .data3_o(dout3),
      .data_valid_o(dout_valid)
  );

    // Global stimuli
    initial begin
        clk <= 0;
        forever #(`PERIOD) clk = ~clk;
    end

    initial begin
        rst <= 1;
        for (int i = 0; i<10;i++)
        @(posedge clk);
        @(negedge clk) rst <= 0;
    end

  // Tester 
  tester_ntt_r4mdc #(
      .DATA_WIDTH(DATA_WIDTH),
      .N(N),
      .NOF_BUTTERFLY_UNITS(NOF_BUTTERFLY_UNITS),
      .BUTTERFLY_TYPE(BUTTERFLY_TYPE),
      .LOG_FILE(LOG_FILE),
      .TEX_FILE(TEX_FILE),
      .TESTCASE_PATH(TESTCASE_PATH),
      .TEST_NAME(TEST_NAME)
  ) U_TESTER (
      .clk_i(clk),
      .rst_i(rst),
      .intt_o(intt),
      .data0_i(dout0),
      .data1_i(dout1),
      .data2_i(dout2),
      .data3_i(dout3),
      .data_valid_i(dout_valid),

      .data0_o(din0),
      .data1_o(din1),
      .data2_o(din2),
      .data3_o(din3),
      .data_valid_o(din_valid)
  );

endmodule