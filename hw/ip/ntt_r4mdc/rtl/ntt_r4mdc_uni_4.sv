// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0   
   
`timescale 1ns/10ps

module ntt_r4mdc_uni_4
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

    logic [DATA_WIDTH-1:0] mdc_din_0 [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] mdc_din_1 [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] mdc_din_2 [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] mdc_din_3 [NOF_BUTTERFLY_UNITS-1:0];
    logic data_mdc_din_valid;

    logic [DATA_WIDTH-1:0] mdc_dout_0 [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] mdc_dout_1 [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] mdc_dout_2 [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] mdc_dout_3 [NOF_BUTTERFLY_UNITS-1:0];
    logic [NOF_BUTTERFLY_UNITS-1:0] data_mdc_dout_valid;

    logic [DATA_WIDTH-1:0] unrolled_stage_din_0 [$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] unrolled_stage_din_1 [$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] unrolled_stage_din_2 [$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] unrolled_stage_din_3 [$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];
    logic [$clog2(NOF_BUTTERFLY_UNITS)/2-1:0] unrolled_stage_data_valid_in;

    logic [DATA_WIDTH-1:0] unrolled_stage_dout_0 [$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] unrolled_stage_dout_1 [$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] unrolled_stage_dout_2 [$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] unrolled_stage_dout_3 [$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];
    logic [$clog2(NOF_BUTTERFLY_UNITS)/2-1:0] unrolled_stage_data_valid_out; 

    // Assign inputs to internal signals
    generate;
    if ($clog2(NOF_BUTTERFLY_UNITS)/2 > 1) begin
        assign unrolled_stage_din_0[0] = intt_i ? unrolled_stage_dout_0[1] : data0_i;
        assign unrolled_stage_din_1[0] = intt_i ? unrolled_stage_dout_1[1] : data1_i;
        assign unrolled_stage_din_2[0] = intt_i ? unrolled_stage_dout_2[1] : data2_i;
        assign unrolled_stage_din_3[0] = intt_i ? unrolled_stage_dout_3[1] : data3_i;
        assign unrolled_stage_data_valid_in[0] = intt_i ? unrolled_stage_data_valid_out[1] : data_valid_i;

        assign unrolled_stage_din_0[$clog2(NOF_BUTTERFLY_UNITS)/2-1] = intt_i ? mdc_dout_0 : unrolled_stage_dout_0[$clog2(NOF_BUTTERFLY_UNITS)/2-2];
        assign unrolled_stage_din_1[$clog2(NOF_BUTTERFLY_UNITS)/2-1] = intt_i ? mdc_dout_1 : unrolled_stage_dout_1[$clog2(NOF_BUTTERFLY_UNITS)/2-2];
        assign unrolled_stage_din_2[$clog2(NOF_BUTTERFLY_UNITS)/2-1] = intt_i ? mdc_dout_2 : unrolled_stage_dout_2[$clog2(NOF_BUTTERFLY_UNITS)/2-2];
        assign unrolled_stage_din_3[$clog2(NOF_BUTTERFLY_UNITS)/2-1] = intt_i ? mdc_dout_3 : unrolled_stage_dout_3[$clog2(NOF_BUTTERFLY_UNITS)/2-2];
        assign unrolled_stage_data_valid_in[$clog2(NOF_BUTTERFLY_UNITS)/2-1] = intt_i ? data_mdc_dout_valid[0] : unrolled_stage_data_valid_out[$clog2(NOF_BUTTERFLY_UNITS)/2-2];

    end else begin
        assign unrolled_stage_din_0[0] = intt_i ? mdc_dout_0 : data0_i;
        assign unrolled_stage_din_1[0] = intt_i ? mdc_dout_1 : data1_i;
        assign unrolled_stage_din_2[0] = intt_i ? mdc_dout_2 : data2_i;
        assign unrolled_stage_din_3[0] = intt_i ? mdc_dout_3 : data3_i;
        assign unrolled_stage_data_valid_in[0] = intt_i ? data_mdc_dout_valid[0] : data_valid_i;
    end
    endgenerate

    
    assign mdc_din_0 = intt_i ? data0_i : unrolled_stage_dout_0[$clog2(NOF_BUTTERFLY_UNITS)/2-1];
    assign mdc_din_1 = intt_i ? data1_i : unrolled_stage_dout_1[$clog2(NOF_BUTTERFLY_UNITS)/2-1];
    assign mdc_din_2 = intt_i ? data2_i : unrolled_stage_dout_2[$clog2(NOF_BUTTERFLY_UNITS)/2-1];
    assign mdc_din_3 = intt_i ? data3_i : unrolled_stage_dout_3[$clog2(NOF_BUTTERFLY_UNITS)/2-1];
    assign data_mdc_din_valid = intt_i ? data_valid_i : unrolled_stage_data_valid_out[$clog2(NOF_BUTTERFLY_UNITS)/2-1];

    // Assign outputs 
    assign data0_o = intt_i ? unrolled_stage_dout_0[0] : mdc_dout_0;
    assign data1_o = intt_i ? unrolled_stage_dout_1[0] : mdc_dout_1;
    assign data2_o = intt_i ? unrolled_stage_dout_2[0] : mdc_dout_2;
    assign data3_o = intt_i ? unrolled_stage_dout_3[0] : mdc_dout_3;
    assign data_valid_o = intt_i ? unrolled_stage_data_valid_out[0] : data_mdc_dout_valid[0];

    logic [DATA_WIDTH-1:0] twiddle1_rom2mdc[$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] twiddle2_rom2mdc[$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] twiddle3_rom2mdc[$clog2(NOF_BUTTERFLY_UNITS)/2-1:0][NOF_BUTTERFLY_UNITS-1:0];

    for (genvar i=0; i<$clog2(NOF_BUTTERFLY_UNITS)/2; ++i) begin : g_unrolled

        // Read twiddle factors for stage 0
        localparam memfile1_ntt = $sformatf("%s/twiddle_stage_rom1_%0d.mem",TWIDDLE_MEM_PATH,i);
        localparam memfile2_ntt = $sformatf("%s/twiddle_stage_rom2_%0d.mem",TWIDDLE_MEM_PATH,i);
        localparam memfile3_ntt = $sformatf("%s/twiddle_stage_rom3_%0d.mem",TWIDDLE_MEM_PATH,i);
        localparam memfile1_intt = $sformatf("%s/twiddle_inv_stage_rom1_%0d.mem",TWIDDLE_MEM_PATH,i);
        localparam memfile2_intt = $sformatf("%s/twiddle_inv_stage_rom2_%0d.mem",TWIDDLE_MEM_PATH,i);
        localparam memfile3_intt = $sformatf("%s/twiddle_inv_stage_rom3_%0d.mem",TWIDDLE_MEM_PATH,i);
        
        logic [DATA_WIDTH-1:0] twiddle_const1_ntt [NOF_BUTTERFLY_UNITS-1:0];
        logic [DATA_WIDTH-1:0] twiddle_const2_ntt [NOF_BUTTERFLY_UNITS-1:0];
        logic [DATA_WIDTH-1:0] twiddle_const3_ntt [NOF_BUTTERFLY_UNITS-1:0];
        logic [DATA_WIDTH-1:0] twiddle_const1_intt [NOF_BUTTERFLY_UNITS-1:0];
        logic [DATA_WIDTH-1:0] twiddle_const2_intt [NOF_BUTTERFLY_UNITS-1:0];
        logic [DATA_WIDTH-1:0] twiddle_const3_intt [NOF_BUTTERFLY_UNITS-1:0];

        initial begin
            $readmemh(memfile1_ntt,twiddle_const1_ntt);
            $readmemh(memfile2_ntt,twiddle_const2_ntt);
            $readmemh(memfile3_ntt,twiddle_const3_ntt);
            $readmemh(memfile1_intt,twiddle_const1_intt);
            $readmemh(memfile2_intt,twiddle_const2_intt);
            $readmemh(memfile3_intt,twiddle_const3_intt);
        end

        logic [DATA_WIDTH-1:0] twiddle0 [NOF_BUTTERFLY_UNITS-1:0];

        for (genvar j=0; j<NOF_BUTTERFLY_UNITS; ++j) begin
            assign twiddle1_rom2mdc[i][j] = intt_i ? twiddle_const1_intt[j] : twiddle_const1_ntt[j];
            assign twiddle2_rom2mdc[i][j] = intt_i ? twiddle_const2_intt[j] : twiddle_const2_ntt[j];
            assign twiddle3_rom2mdc[i][j] = intt_i ? twiddle_const3_intt[j] : twiddle_const3_ntt[j];

            assign twiddle0[j] = W4;      
        end
        
        prim_ntt_r4uni_stage_unrolled #(
            .DATA_WIDTH(DATA_WIDTH),
            .N(N),
            .QINT(QINT),
            .QDASH(QDASH),
            .NOF_BUTTERFLY_UNITS(NOF_BUTTERFLY_UNITS),
            .FIFO_DEPTH(N/(4**2)),
            .REDUCTION(REDUCTION), // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo
            .FIFO_TYPE(FIFO_TYPE),        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
            .DELAY_MULT(DELAY_MULT),
            .DELAY_CONST_MULT(DELAY_CONST_MULT),
            .DELAY_BF(DELAY_BF),
            .W4(W4),
            .TWIDDLE1_OPT(TWIDDLE1_OPT),
            .TWIDDLE2_OPT(TWIDDLE2_OPT),
            .STAGE(i)             // Choose between [0,LOG2(N)-1]
        ) u_ntt_r4uni_stage_unrolled_i (
            .clk_i(clk_i),
            .rst_i(rst_i),
            .intt_i(intt_i),
            .data0_i(unrolled_stage_din_0[i]),
            .data1_i(unrolled_stage_din_1[i]),
            .data2_i(unrolled_stage_din_2[i]),
            .data3_i(unrolled_stage_din_3[i]),
            .data_valid_i(unrolled_stage_data_valid_in[i]),

            .data0_o(unrolled_stage_dout_0[i]),
            .data1_o(unrolled_stage_dout_1[i]),
            .data2_o(unrolled_stage_dout_2[i]),
            .data3_o(unrolled_stage_dout_3[i]),
            .data_valid_o(unrolled_stage_data_valid_out[i]),

            .twiddle_raddr_o(twiddle_raddr),
            .twiddle0_i(twiddle0),
            .twiddle1_i(twiddle1_rom2mdc[i]),
            .twiddle2_i(twiddle2_rom2mdc[i]),
            .twiddle3_i(twiddle3_rom2mdc[i])
        );

    end

    for (genvar i=1; i<$clog2(NOF_BUTTERFLY_UNITS)/2-1; ++i) begin

        assign unrolled_stage_din_0[i] = intt_i ? unrolled_stage_dout_0[i-1] : unrolled_stage_dout_0[i+1];
        assign unrolled_stage_din_1[i] = intt_i ? unrolled_stage_dout_1[i-1] : unrolled_stage_dout_1[i+1];
        assign unrolled_stage_din_2[i] = intt_i ? unrolled_stage_dout_2[i-1] : unrolled_stage_dout_2[i+1];
        assign unrolled_stage_din_3[i] = intt_i ? unrolled_stage_dout_3[i-1] : unrolled_stage_dout_3[i+1];
        assign unrolled_stage_data_valid_in[i] = intt_i ? unrolled_stage_data_valid_out[i-1] : unrolled_stage_data_valid_out[i+1];

    end
    logic [DATA_WIDTH-1:0] twiddle1_mux2mdc[NOF_BUTTERFLY_UNITS-1:0][$clog2(N/NOF_BUTTERFLY_UNITS)/2-1:0];
    logic [DATA_WIDTH-1:0] twiddle2_mux2mdc[NOF_BUTTERFLY_UNITS-1:0][$clog2(N/NOF_BUTTERFLY_UNITS)/2-1:0];
    logic [DATA_WIDTH-1:0] twiddle3_mux2mdc[NOF_BUTTERFLY_UNITS-1:0][$clog2(N/NOF_BUTTERFLY_UNITS)/2-1:0];
    logic [DATA_WIDTH-1:0] twiddle1_rom2mux[NOF_BUTTERFLY_UNITS-1:0][$clog2(N/NOF_BUTTERFLY_UNITS)/2-1:0];
    logic [DATA_WIDTH-1:0] twiddle2_rom2mux[NOF_BUTTERFLY_UNITS-1:0][$clog2(N/NOF_BUTTERFLY_UNITS)/2-1:0];
    logic [DATA_WIDTH-1:0] twiddle3_rom2mux[NOF_BUTTERFLY_UNITS-1:0][$clog2(N/NOF_BUTTERFLY_UNITS)/2-1:0];
    logic [$clog2(4**($clog2(N/NOF_BUTTERFLY_UNITS)/2))-1:0] twiddle_stage_rom_raddr [NOF_BUTTERFLY_UNITS-1:0][$clog2(N/NOF_BUTTERFLY_UNITS)/2-1:0];
    for (genvar i=0; i<(NOF_BUTTERFLY_UNITS); ++i) begin : g_mdc_par
        localparam mdc_mem_path = $sformatf("%s/%0d",TWIDDLE_MEM_PATH,i);
        ntt_r4mdc_uni_mdc #(
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
            .TWIDDLE_MEM_PATH(mdc_mem_path),
            .TWIDDLE2_OPT(1'b0)
        ) U_NTT_R4MDC (
            .clk_i(clk_i),
            .rst_i(rst_i),
            .intt_i(intt_i),
            .data0_i(mdc_din_0[i]),
            .data1_i(mdc_din_1[i]),
            .data2_i(mdc_din_2[i]),
            .data3_i(mdc_din_3[i]),
            .data_valid_i(data_mdc_din_valid),
            .twiddle_raddr_o(twiddle_stage_rom_raddr[i]),
            .twiddle0_i(twiddle1_mux2mdc[i]),
            .twiddle1_i(twiddle1_mux2mdc[i]),
            .twiddle2_i(twiddle2_mux2mdc[i]),
            .twiddle3_i(twiddle3_mux2mdc[i]),
            .data0_o(mdc_dout_0[i]),
            .data1_o(mdc_dout_1[i]),
            .data2_o(mdc_dout_2[i]),
            .data3_o(mdc_dout_3[i]),
            .data_valid_o(data_mdc_dout_valid[i])
        );
        for (genvar j=0; j < $clog2(N/NOF_BUTTERFLY_UNITS)/2; j++) begin
            localparam memfile_ntt1 = $sformatf("%s/twiddle_stage_rom1_%0d.mem",mdc_mem_path,j);
            localparam memfile_ntt2 = $sformatf("%s/twiddle_stage_rom2_%0d.mem",mdc_mem_path,j);
            localparam memfile_ntt3 = $sformatf("%s/twiddle_stage_rom3_%0d.mem",mdc_mem_path,j);

            // Twiddle ROM for each stage
            logic [$clog2((4**j))-1:0] twiddle_stage_rom_raddr_final;
            logic [$clog2((4**j))-1:0] twiddle_stage_rom_raddr_intt;
            assign twiddle_stage_rom_raddr_intt = (4**j-1) - twiddle_stage_rom_raddr[i][j];
            assign twiddle_stage_rom_raddr_final = intt_i ? twiddle_stage_rom_raddr_intt : twiddle_stage_rom_raddr[i][j];
            assign twiddle1_mux2mdc[i][j] = intt_i ? twiddle1_rom2mux[NOF_BUTTERFLY_UNITS-1-i][j] : twiddle1_rom2mux[i][j];
            assign twiddle2_mux2mdc[i][j] = intt_i ? twiddle2_rom2mux[NOF_BUTTERFLY_UNITS-1-i][j] : twiddle2_rom2mux[i][j];
            assign twiddle3_mux2mdc[i][j] = intt_i ? twiddle3_rom2mux[NOF_BUTTERFLY_UNITS-1-i][j] : twiddle3_rom2mux[i][j];
            prim_ntt_twiddlerom #(
                .DATA_WIDTH(DATA_WIDTH),
                .DEPTH((4**j)),
                .memfile(memfile_ntt1)
            ) U_TWIDDLE_STAGE_ROM1_GEN (
                .clk_i(clk_i),
                .raddr_i(twiddle_stage_rom_raddr_final),
                .data_o(twiddle1_rom2mux[i][j])
            );

            prim_ntt_twiddlerom #(
                .DATA_WIDTH(DATA_WIDTH),
                .DEPTH((4**j)),
                .memfile(memfile_ntt2)
            ) U_TWIDDLE_STAGE_ROM2_GEN (
                .clk_i(clk_i),
                .raddr_i(twiddle_stage_rom_raddr_final),
                .data_o(twiddle2_rom2mux[i][j])
            );

            prim_ntt_twiddlerom #(
                .DATA_WIDTH(DATA_WIDTH),
                .DEPTH((4**j)),
                .memfile(memfile_ntt3)
            ) U_TWIDDLE_STAGE_ROM3_GEN (
                .clk_i(clk_i),
                .raddr_i(twiddle_stage_rom_raddr_final),
                .data_o(twiddle3_rom2mux[i][j])
            );
        end   
    end : g_mdc_par

endmodule