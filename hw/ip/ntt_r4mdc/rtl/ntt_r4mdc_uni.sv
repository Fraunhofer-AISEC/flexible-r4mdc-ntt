// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0   
   
`timescale 1ns/10ps

module ntt_r4mdc_uni
#(
    parameter int unsigned DATA_WIDTH = 27,
    parameter int unsigned LOG_R = 28,
    parameter int unsigned N = 1024,
   	parameter longint QINT = 134215681,
    parameter longint QDASH = 130021375,
    parameter REDUCTION = "MONTGOMERY", // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo: BARRETT, SOLINA32
    parameter FIFO_TYPE = "XPM",        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
    parameter BUTTERFLY_TYPE = "CT",     // Choose between "CT" and "GS" ToDo
    parameter int unsigned NOF_BUTTERFLY_UNITS = 1,  // Choose between 2, 4 and 8
    parameter int unsigned DELAY_MULT = 5,
    parameter int unsigned DELAY_CONST_MULT = 5,
    parameter int unsigned DELAY_BF = 12,    
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

  generate
    if (NOF_BUTTERFLY_UNITS == 1) begin

      logic [DATA_WIDTH-1:0] twiddle1_rom2mdc[$clog2(N)/2-1:0];
      logic [DATA_WIDTH-1:0] twiddle2_rom2mdc[$clog2(N)/2-1:0];
      logic [DATA_WIDTH-1:0] twiddle3_rom2mdc[$clog2(N)/2-1:0];
      logic [$clog2(4**($clog2(N)/2))-1:0] twiddle_stage_rom_raddr [$clog2(N)/2-1:0];
      ntt_r4mdc_uni_mdc #(
        .DATA_WIDTH(DATA_WIDTH),
        .LOG_R(LOG_R),
        .N(N),
        .QINT(QINT),
        .QDASH(QDASH),
        .NOF_BUTTERFLY_UNITS(NOF_BUTTERFLY_UNITS),
        .REDUCTION(REDUCTION), // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo
        .FIFO_TYPE("XPM"),        // Choose between "SHREG" and "XPM" ToDo
        .BUTTERFLY_TYPE("CT"),    // Choose between "CT" and "GS" ToDo
        .DELAY_MULT(DELAY_MULT),
        .DELAY_CONST_MULT(DELAY_CONST_MULT),
        .DELAY_BF(DELAY_BF),
        .W4(W4),
        .TWIDDLE_MEM_PATH(TWIDDLE_MEM_PATH),
        .TWIDDLE2_OPT(TWIDDLE2_OPT)
      ) U_NTT (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .intt_i(intt_i),
        .data0_i(data0_i[0]),
        .data1_i(data1_i[0]),
        .data2_i(data2_i[0]),
        .data3_i(data3_i[0]),
        .data_valid_i(data_valid_i),
        .twiddle_raddr_o(twiddle_stage_rom_raddr),
        .twiddle0_i(twiddle1_rom2mdc),
        .twiddle1_i(twiddle1_rom2mdc),
        .twiddle2_i(twiddle2_rom2mdc),
        .twiddle3_i(twiddle3_rom2mdc),
        .data0_o(data0_o[0]),
        .data1_o(data1_o[0]),
        .data2_o(data2_o[0]),
        .data3_o(data3_o[0]),
        .data_valid_o(data_valid_o)
      );

      for (genvar i=0; i < $clog2(N)/2; i++) begin
          localparam memfile_ntt1 = $sformatf("%s/twiddle_stage_rom1_%0d.mem",TWIDDLE_MEM_PATH,i);
          localparam memfile_ntt2 = $sformatf("%s/twiddle_stage_rom2_%0d.mem",TWIDDLE_MEM_PATH,i);
          localparam memfile_ntt3 = $sformatf("%s/twiddle_stage_rom3_%0d.mem",TWIDDLE_MEM_PATH,i);

          // Twiddle ROM for each stage
          logic [$clog2((4**i))-1:0] twiddle_stage_rom_raddr_final;
          logic [$clog2((4**i))-1:0] twiddle_stage_rom_raddr_intt;
          assign twiddle_stage_rom_raddr_intt = (4**i-1) - twiddle_stage_rom_raddr[i];
          assign twiddle_stage_rom_raddr_final = intt_i ? twiddle_stage_rom_raddr_intt : twiddle_stage_rom_raddr[i];
          prim_ntt_twiddlerom #(
              .DATA_WIDTH(DATA_WIDTH),
              .DEPTH((4**i)),
              .memfile(memfile_ntt1)
          ) U_TWIDDLE_STAGE_ROM1_GEN (
              .clk_i(clk_i),
              .raddr_i(twiddle_stage_rom_raddr_final),
              .data_o(twiddle1_rom2mdc[i])
          );

          prim_ntt_twiddlerom #(
              .DATA_WIDTH(DATA_WIDTH),
              .DEPTH((4**i)),
              .memfile(memfile_ntt2)
          ) U_TWIDDLE_STAGE_ROM2_GEN (
              .clk_i(clk_i),
              .raddr_i(twiddle_stage_rom_raddr_final),
              .data_o(twiddle2_rom2mdc[i])
          );

          prim_ntt_twiddlerom #(
              .DATA_WIDTH(DATA_WIDTH),
              .DEPTH((4**i)),
              .memfile(memfile_ntt3)
          ) U_TWIDDLE_STAGE_ROM3_GEN (
              .clk_i(clk_i),
              .raddr_i(twiddle_stage_rom_raddr_final),
              .data_o(twiddle3_rom2mdc[i])
          );
      end

    end else if ((NOF_BUTTERFLY_UNITS == 4) ||  (NOF_BUTTERFLY_UNITS == 16) || (NOF_BUTTERFLY_UNITS == 64)) begin
      ntt_r4mdc_uni_4 #(
        .DATA_WIDTH(DATA_WIDTH),
        .N(N),
        .QINT(QINT),
        .QDASH(QDASH),
        .REDUCTION(REDUCTION), // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo
        .FIFO_TYPE("XPM"),        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
        .TWIDDLE_MEM_PATH(TWIDDLE_MEM_PATH),
        .NOF_BUTTERFLY_UNITS(NOF_BUTTERFLY_UNITS),
        .W4(W4),
        .DELAY_MULT(DELAY_MULT),
        .DELAY_CONST_MULT(DELAY_CONST_MULT),
        .DELAY_BF(DELAY_BF),
        .TWIDDLE2_OPT(TWIDDLE2_OPT)
      ) U_NTT (
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
    end else if ((NOF_BUTTERFLY_UNITS == 2) ||  (NOF_BUTTERFLY_UNITS == 8) || (NOF_BUTTERFLY_UNITS == 32)) begin
      ntt_r4mdc_uni_2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .N(N),
        .QINT(QINT),
        .QDASH(QDASH),
        .NOF_BUTTERFLY_UNITS(NOF_BUTTERFLY_UNITS),
        .REDUCTION(REDUCTION), // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo
        .FIFO_TYPE("XPM"),        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
        .TWIDDLE_MEM_PATH(TWIDDLE_MEM_PATH),
        .DELAY_BF(DELAY_BF),
        .DELAY_MULT(DELAY_MULT),
        .DELAY_CONST_MULT(DELAY_CONST_MULT),
        .W4(W4),
        .TWIDDLE2_OPT(TWIDDLE2_OPT)
      ) U_NTT (
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

  endgenerate


endmodule