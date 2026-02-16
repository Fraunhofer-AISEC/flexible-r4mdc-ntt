// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0   
   
`timescale 1ns/10ps

module ntt_r4mdc
#(
    parameter int unsigned DATA_WIDTH = 27,
    parameter int unsigned LOG_R = 28,
    parameter int unsigned N = 1024,
   	parameter longint QINT = 134215681,
    parameter longint QDASH = 130021375,
    parameter REDUCTION = "MONTGOMERY", // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo: BARRETT, SOLINA32
    parameter FIFO_TYPE = "XPM",        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
    parameter BUTTERFLY_TYPE = "CT",     // Choose between "CT" and "GS" ToDo
    parameter NOF_BUTTERFLY_UNITS = 1,  // Choose between 2, 4 and 8
    parameter int unsigned DELAY_MULT = 5,
    parameter int unsigned DELAY_CONST_MULT = 5,
    parameter int unsigned DELAY_BF = 11,    
    parameter longint W4 = 37361560,
    parameter TWIDDLE_MEM_PATH = "/home/t_stelzer/projects/aisec/fhe-sv/rtl/ntt/cggi_std_128_mem_hp",
    parameter bit TWIDDLE1_OPT = 1'b0,
    parameter bit TWIDDLE2_OPT = 1'b0
)
(
    input   logic                       clk_i,
    input   logic                       rst_i,
    input   logic                       intt_i,
    input   logic   [DATA_WIDTH-1:0]    data0_i[NOF_BUTTERFLY_UNITS-1:0],
    input   logic   [DATA_WIDTH-1:0]    data1_i[NOF_BUTTERFLY_UNITS-1:0],
    input   logic   [DATA_WIDTH-1:0]    data2_i[NOF_BUTTERFLY_UNITS-1:0],
    input   logic   [DATA_WIDTH-1:0]    data3_i[NOF_BUTTERFLY_UNITS-1:0],
    input   logic                       data_valid_i,

    output  logic   [DATA_WIDTH-1:0]    data0_o[NOF_BUTTERFLY_UNITS-1:0],
    output  logic   [DATA_WIDTH-1:0]    data1_o[NOF_BUTTERFLY_UNITS-1:0],
    output  logic   [DATA_WIDTH-1:0]    data2_o[NOF_BUTTERFLY_UNITS-1:0],
    output  logic   [DATA_WIDTH-1:0]    data3_o[NOF_BUTTERFLY_UNITS-1:0],
    output  logic                       data_valid_o

);

generate;

  case (BUTTERFLY_TYPE)
  
    "CT" : begin
      ntt_r4mdc_dit #(
          .DATA_WIDTH(DATA_WIDTH),
          .N(N),
          .LOG_R(LOG_R),
          .QINT(QINT),
          .QDASH(QDASH),
          .REDUCTION(REDUCTION), // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo
          .FIFO_TYPE(FIFO_TYPE),        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
          .BUTTERFLY_TYPE("CT"),    // Choose between "CT" and "GS" ToDo
          .NOF_BUTTERFLY_UNITS(NOF_BUTTERFLY_UNITS),
          .DELAY_MULT(DELAY_MULT),
          .DELAY_CONST_MULT(DELAY_CONST_MULT),
          .DELAY_BF(DELAY_BF),
          .W4(W4),
          .TWIDDLE_MEM_PATH(TWIDDLE_MEM_PATH)
      ) u_ntt_r4mdc (
          .clk_i(clk_i),
          .rst_i(rst_i),

          .data0_i(data0_i),
          .data1_i(data1_i),
          .data2_i(data2_i),
          .data3_i(data3_i),
          .data_valid_i(data_valid_i),

          .data0_o(data0_o),
          .data1_o(data1_o),
          .data2_o(data2_o),
          .data3_o(data3_o),
          .data_valid_o(data_valid_o)
      );
    end
    "GS" : begin
      ntt_r4mdc_dif #(
          .DATA_WIDTH(DATA_WIDTH),
          .N(N),
          .LOG_R(LOG_R),
          .QINT(QINT),
          .QDASH(QDASH),
          .REDUCTION(REDUCTION), // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo
          .FIFO_TYPE(FIFO_TYPE),        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
          .BUTTERFLY_TYPE("GS"),    // Choose between "CT" and "GS" ToDo
          .NOF_BUTTERFLY_UNITS(NOF_BUTTERFLY_UNITS),
          .DELAY_MULT(DELAY_MULT),
          .DELAY_CONST_MULT(DELAY_CONST_MULT),
          .DELAY_BF(DELAY_BF),
          .W4(W4),
          .TWIDDLE_MEM_PATH(TWIDDLE_MEM_PATH)
      ) u_ntt_r4mdc (
          .clk_i(clk_i),
          .rst_i(rst_i),

          .data0_i(data0_i),
          .data1_i(data1_i),
          .data2_i(data2_i),
          .data3_i(data3_i),
          .data_valid_i(data_valid_i),

          .data0_o(data0_o),
          .data1_o(data1_o),
          .data2_o(data2_o),
          .data3_o(data3_o),
          .data_valid_o(data_valid_o)
      );
    end    
    "UNI" : begin
      ntt_r4mdc_uni #(
          .DATA_WIDTH(DATA_WIDTH),
          .N(N),
          .LOG_R(LOG_R),
          .QINT(QINT),
          .QDASH(QDASH),
          .REDUCTION(REDUCTION), // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo
          .FIFO_TYPE(FIFO_TYPE),        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
          .NOF_BUTTERFLY_UNITS(NOF_BUTTERFLY_UNITS),
          .DELAY_MULT(DELAY_MULT),
          .DELAY_CONST_MULT(DELAY_CONST_MULT),
          .DELAY_BF(DELAY_BF),
          .W4(W4),
          .TWIDDLE_MEM_PATH(TWIDDLE_MEM_PATH),
          .TWIDDLE1_OPT(TWIDDLE1_OPT),
          .TWIDDLE2_OPT(TWIDDLE2_OPT)
      ) u_ntt_r4mdc (
          .clk_i(clk_i),
          .rst_i(rst_i),
          .intt_i(intt_i),
          .data0_i(data0_i),
          .data1_i(data1_i),
          .data2_i(data2_i),
          .data3_i(data3_i),
          .data_valid_i(data_valid_i),

          .data0_o(data0_o),
          .data1_o(data1_o),
          .data2_o(data2_o),
          .data3_o(data3_o),
          .data_valid_o(data_valid_o)
      );
    end    
    default : begin
      ntt_r4mdc_dit #(
          .DATA_WIDTH(DATA_WIDTH),
          .N(N),
          .LOG_R(LOG_R),
          .QINT(QINT),
          .QDASH(QDASH),
          .REDUCTION(REDUCTION), // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo
          .FIFO_TYPE(FIFO_TYPE),        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
          .BUTTERFLY_TYPE("CT"),    // Choose between "CT" and "GS" ToDo
          .NOF_BUTTERFLY_UNITS(NOF_BUTTERFLY_UNITS),
          .DELAY_MULT(DELAY_MULT),
          .DELAY_CONST_MULT(DELAY_CONST_MULT),
          .DELAY_BF(DELAY_BF),
          .W4(W4),
          .TWIDDLE_MEM_PATH(TWIDDLE_MEM_PATH)
      ) u_ntt_r4mdc (
          .clk_i(clk_i),
          .rst_i(rst_i),

          .data0_i(data0_i),
          .data1_i(data1_i),
          .data2_i(data2_i),
          .data3_i(data3_i),
          .data_valid_i(data_valid_i),

          .data0_o(data0_o),
          .data1_o(data1_o),
          .data2_o(data2_o),
          .data3_o(data3_o),
          .data_valid_o(data_valid_o)
      );
    end
  endcase

endgenerate

endmodule