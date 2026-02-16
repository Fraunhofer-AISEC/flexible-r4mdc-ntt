// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0   
   
`timescale 1ns/10ps

module ntt_r4mdc_synth_wrapper
#(
    parameter int unsigned DATA_WIDTH = 27,
    parameter int unsigned LOG_R = 28,
    parameter int unsigned N = 1024,
   	parameter int QINT = 134215681,
   	parameter int QINT_64 = 0,
    parameter int QDASH = 130021375,
    parameter int QDASH_64 = 0,
    parameter REDUCTION = "MONTGOMERY", // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo: BARRETT, SOLINA32
    parameter FIFO_TYPE = "XPM",        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
    parameter BUTTERFLY_TYPE = "CT",     // Choose between "CT" and "GS" ToDo
    parameter NOF_BUTTERFLY_UNITS = 1,  // Choose between 2, 4 and 8
    parameter int unsigned DELAY_MULT = 5,
    parameter int unsigned DELAY_CONST_MULT = 5,
    parameter int unsigned DELAY_BF = 11,    
    parameter int W4 = 37361560,
    parameter int W4_64 = 0,
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
    // Parameters for length > 32-bit
    localparam [DATA_WIDTH-1:0] ACT_QINT = (DATA_WIDTH > 32) ? {QINT_64, {32{1'b0}}} | QINT : QINT;
    localparam [DATA_WIDTH-1:0] ACT_QDASH = (DATA_WIDTH > 32) ? {QDASH_64, {32{1'b0}}} | QDASH : QDASH; 
    localparam [DATA_WIDTH-1:0] ACT_W4 = (DATA_WIDTH > 32) ? {W4_64, {32{1'b0}}} | W4 : W4;

    ntt_r4mdc #(
        .DATA_WIDTH(DATA_WIDTH),
        .N(N),
        .LOG_R(LOG_R),
        .QINT(ACT_QINT),
        .QDASH(ACT_QDASH),
        .REDUCTION(REDUCTION), // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo
        .FIFO_TYPE(FIFO_TYPE),        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
        .BUTTERFLY_TYPE(BUTTERFLY_TYPE),    // Choose between "CT" and "GS" ToDo
        .NOF_BUTTERFLY_UNITS(NOF_BUTTERFLY_UNITS),
        .DELAY_MULT(DELAY_MULT),
        .DELAY_CONST_MULT(DELAY_CONST_MULT),
        .DELAY_BF(DELAY_BF),
        .W4(ACT_W4),
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

endmodule
