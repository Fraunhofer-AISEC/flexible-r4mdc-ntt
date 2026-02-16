// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0   
   
`timescale 1ns/10ps

module ntt_r4mdc_dit_4
#(
    parameter int unsigned DATA_WIDTH = 27,
    parameter int unsigned LOG_R = 27,
    parameter int unsigned N = 1024,
   	parameter longint QINT = 134215681,
    parameter longint QDASH = 130021375,
    parameter int unsigned NOF_BUTTERFLY_UNITS = 16,
    parameter REDUCTION = "SOLINA27", // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo: BARRETT, SOLINA32
    parameter FIFO_TYPE = "XPM",        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
    parameter BUTTERFLY_TYPE = "CT",     // Choose between "CT" and "GS" ToDo
    parameter int unsigned DELAY_MULT = 11,  
    parameter int unsigned DELAY_CONST_MULT = 5,
    parameter int unsigned DELAY_BF = 11,  
    parameter longint W4 = 37361560,
    parameter TWIDDLE_MEM_PATH = "/home/t_stelzer/projects/aisec/fhe-sv/rtl/ntt/cggi_std_128_mem_hp"
)
(
    input   logic                       clk_i,
    input   logic                       rst_i,

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

    logic [DATA_WIDTH-1:0] data2mdc0 [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] data2mdc1 [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] data2mdc2 [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] data2mdc3 [NOF_BUTTERFLY_UNITS-1:0];
    logic data_valid2mdc;

    logic [DATA_WIDTH-1:0] pre_mdc_stage_din_0 [$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] pre_mdc_stage_din_1 [$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] pre_mdc_stage_din_2 [$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] pre_mdc_stage_din_3 [$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];
    logic [$clog2(NOF_BUTTERFLY_UNITS)/2-1:0] pre_mdc_stage_data_valid_in;

    // Assign inputs to internal signals
    assign pre_mdc_stage_din_0[0] = data0_i;
    assign pre_mdc_stage_din_1[0] = data1_i;
    assign pre_mdc_stage_din_2[0] = data2_i;
    assign pre_mdc_stage_din_3[0] = data3_i;
    assign pre_mdc_stage_data_valid_in[0] = data_valid_i;

    logic [DATA_WIDTH-1:0] pre_mdc_stage_dout_0 [$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] pre_mdc_stage_dout_1 [$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] pre_mdc_stage_dout_2 [$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] pre_mdc_stage_dout_3 [$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];
    logic [$clog2(NOF_BUTTERFLY_UNITS)/2-1:0] pre_mdc_stage_data_valid_out;    

    logic [DATA_WIDTH-1:0] twiddle1_rom2mdc[$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] twiddle2_rom2mdc[$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] twiddle3_rom2mdc[$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];

    logic [NOF_BUTTERFLY_UNITS-1:0] data_valid_mdc2out;

    assign data_valid_o = data_valid_mdc2out[0];

    assign data2mdc0 = pre_mdc_stage_dout_0[$clog2(NOF_BUTTERFLY_UNITS)/2-1];
    assign data2mdc1 = pre_mdc_stage_dout_1[$clog2(NOF_BUTTERFLY_UNITS)/2-1];
    assign data2mdc2 = pre_mdc_stage_dout_2[$clog2(NOF_BUTTERFLY_UNITS)/2-1];
    assign data2mdc3 = pre_mdc_stage_dout_3[$clog2(NOF_BUTTERFLY_UNITS)/2-1];

    assign data_valid2mdc = pre_mdc_stage_data_valid_out[$clog2(NOF_BUTTERFLY_UNITS)/2-1];

    for (genvar i=0; i<$clog2(NOF_BUTTERFLY_UNITS)/2; ++i) begin : g_pre_mdc
        // Read twiddle factors for stage 0
        localparam memfile1 = $sformatf("%s/twiddle_stage_rom1_%0d.mem",TWIDDLE_MEM_PATH,i);
        localparam memfile2 = $sformatf("%s/twiddle_stage_rom2_%0d.mem",TWIDDLE_MEM_PATH,i);
        localparam memfile3 = $sformatf("%s/twiddle_stage_rom3_%0d.mem",TWIDDLE_MEM_PATH,i);
        
        logic [DATA_WIDTH-1:0] twiddle_const1 [NOF_BUTTERFLY_UNITS-1:0];
        logic [DATA_WIDTH-1:0] twiddle_const2 [NOF_BUTTERFLY_UNITS-1:0];
        logic [DATA_WIDTH-1:0] twiddle_const3 [NOF_BUTTERFLY_UNITS-1:0];

        initial begin
            $readmemh(memfile1,twiddle_const1);
            $readmemh(memfile2,twiddle_const2);
            $readmemh(memfile3,twiddle_const3);
        end

        logic [DATA_WIDTH-1:0] twiddle0 [NOF_BUTTERFLY_UNITS-1:0];

        for (genvar j=0; j<NOF_BUTTERFLY_UNITS; ++j) begin
            assign twiddle1_rom2mdc[i][j] = twiddle_const1[j];
            assign twiddle2_rom2mdc[i][j] = twiddle_const2[j];
            assign twiddle3_rom2mdc[i][j] = twiddle_const3[j]; 

            assign twiddle0[j] = W4;      
        end
        
        prim_ntt_r4ctbfu_stage_unrolled #(
            .DATA_WIDTH(DATA_WIDTH),
            .N(N),
            .QINT(QINT),
            .QDASH(QDASH),
            .NOF_BUTTERFLY_UNITS(NOF_BUTTERFLY_UNITS),
            .FIFO_DEPTH(N/(4**2)),
            .REDUCTION(REDUCTION), // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo
            .FIFO_TYPE(FIFO_TYPE),        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
            .BUTTERFLY_TYPE("CT"),    // Choose between "CT" and "GS" ToDo
            .DELAY_MULT(DELAY_MULT),
            .DELAY_CONST_MULT(DELAY_CONST_MULT),
            .DELAY_BF(DELAY_BF),
            .W4(W4),
            .STAGE(i)             // Choose between [0,LOG2(N)-1]
        ) U_R4_MDC_STAGE_4BFUS (
            .clk_i(clk_i),
            .rst_i(rst_i),

            .data0_i(pre_mdc_stage_din_0[i]),
            .data1_i(pre_mdc_stage_din_1[i]),
            .data2_i(pre_mdc_stage_din_2[i]),
            .data3_i(pre_mdc_stage_din_3[i]),
            .data_valid_i(pre_mdc_stage_data_valid_in[i]),

            .data0_o(pre_mdc_stage_dout_0[i]),
            .data1_o(pre_mdc_stage_dout_1[i]),
            .data2_o(pre_mdc_stage_dout_2[i]),
            .data3_o(pre_mdc_stage_dout_3[i]),
            .data_valid_o(pre_mdc_stage_data_valid_out[i]),

            .twiddle_raddr_o(twiddle_raddr),
            .twiddle0_i(twiddle0),
            .twiddle1_i(twiddle1_rom2mdc[i]),
            .twiddle2_i(twiddle2_rom2mdc[i]),
            .twiddle3_i(twiddle3_rom2mdc[i])
        );

    end

    for (genvar i=1; i<$clog2(NOF_BUTTERFLY_UNITS)/2; ++i) begin
        assign pre_mdc_stage_din_0[i] = pre_mdc_stage_dout_0[i-1];
        assign pre_mdc_stage_din_1[i] = pre_mdc_stage_dout_1[i-1];
        assign pre_mdc_stage_din_2[i] = pre_mdc_stage_dout_2[i-1];
        assign pre_mdc_stage_din_3[i] = pre_mdc_stage_dout_3[i-1];
        assign pre_mdc_stage_data_valid_in[i] = pre_mdc_stage_data_valid_out[i-1];
    end

    for (genvar i=0; i<(NOF_BUTTERFLY_UNITS); ++i) begin : g_mdc_par
        localparam mdc_mem_path = $sformatf("%s/%0d",TWIDDLE_MEM_PATH,i);
        ntt_r4mdc_dit_mdc #(
            .DATA_WIDTH(DATA_WIDTH),
            .LOG_R(LOG_R),
            .N(N/NOF_BUTTERFLY_UNITS),
            .QINT(QINT),
            .QDASH(QDASH),
            .NOF_BUTTERFLY_UNITS(1),
            .REDUCTION(REDUCTION), 
            .FIFO_TYPE(FIFO_TYPE),
            .BUTTERFLY_TYPE(BUTTERFLY_TYPE),
            .DELAY_MULT(DELAY_MULT),
            .DELAY_CONST_MULT(DELAY_CONST_MULT),
            .DELAY_BF(DELAY_BF),
            .W4(W4),
            .TWIDDLE_MEM_PATH(mdc_mem_path)
        ) U_NTT_R4MDC (
            .clk_i(clk_i),
            .rst_i(rst_i),

            .data0_i(data2mdc0[i]),
            .data1_i(data2mdc1[i]),
            .data2_i(data2mdc2[i]),
            .data3_i(data2mdc3[i]),
            .data_valid_i(data_valid2mdc),

            .data0_o(data0_o[i]),
            .data1_o(data1_o[i]),
            .data2_o(data2_o[i]),
            .data3_o(data3_o[i]),
            .data_valid_o(data_valid_mdc2out[i])
        );       

    end : g_mdc_par

endmodule