// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0   
   
`timescale 1ns/10ps

module ntt_r4mdc_dif_mdc 
#(
    parameter int unsigned DATA_WIDTH = 27,
    parameter int unsigned LOG_R = 27,
    parameter int unsigned N = 1024,
   	parameter longint QINT = 134215681,
    parameter longint QDASH = 130021375,
    parameter int unsigned NOF_BUTTERFLY_UNITS = 8,
    parameter REDUCTION = "SOLINA27", // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo: BARRETT, SOLINA32
    parameter FIFO_TYPE = "XPM",        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
    parameter BUTTERFLY_TYPE = "GS",     // Choose between "CT" and "GS" ToDo
    parameter int unsigned DELAY_MULT = 5,
    parameter int unsigned DELAY_CONST_MULT = 5,
    parameter int unsigned DELAY_BF = 11,  
    parameter longint W4 = 37361560,  
    parameter TWIDDLE_MEM_PATH = "/home/t_stelzer/projects/aisec/fhe-sv/rtl/ntt/cggi_std_128_mem_hp"
)
(
    input   logic                       clk_i,
    input   logic                       rst_i,

    input   logic   [DATA_WIDTH-1:0]    data0_i,
    input   logic   [DATA_WIDTH-1:0]    data1_i,
    input   logic   [DATA_WIDTH-1:0]    data2_i,
    input   logic   [DATA_WIDTH-1:0]    data3_i,
    input   logic                       data_valid_i,

    output  logic   [DATA_WIDTH-1:0]    data0_o,
    output  logic   [DATA_WIDTH-1:0]    data1_o,
    output  logic   [DATA_WIDTH-1:0]    data2_o,
    output  logic   [DATA_WIDTH-1:0]    data3_o,
    output  logic                       data_valid_o
);

    logic [DATA_WIDTH-1:0] mdc_stage_din_0 [$clog2(N)/2-1:0];
    logic [DATA_WIDTH-1:0] mdc_stage_din_1 [$clog2(N)/2-1:0];
    logic [DATA_WIDTH-1:0] mdc_stage_din_2 [$clog2(N)/2-1:0];
    logic [DATA_WIDTH-1:0] mdc_stage_din_3 [$clog2(N)/2-1:0];

    logic [DATA_WIDTH-1:0] mdc_stage_dout_0 [$clog2(N)/2-1:0];
    logic [DATA_WIDTH-1:0] mdc_stage_dout_1 [$clog2(N)/2-1:0];
    logic [DATA_WIDTH-1:0] mdc_stage_dout_2 [$clog2(N)/2-1:0];
    logic [DATA_WIDTH-1:0] mdc_stage_dout_3 [$clog2(N)/2-1:0];

    logic [$clog2(N)/2-1:0] mdc_stage_valin;
    logic [$clog2(N)/2-1:0] mdc_stage_valout;

    // Assign inputs to internal signals
    assign mdc_stage_din_0[$clog2(N)/2-1] = data0_i;
    assign mdc_stage_din_1[$clog2(N)/2-1] = data1_i;
    assign mdc_stage_din_2[$clog2(N)/2-1] = data2_i;
    assign mdc_stage_din_3[$clog2(N)/2-1] = data3_i;
    assign mdc_stage_valin[$clog2(N)/2-1] = data_valid_i;

    // Assign outputs 
    assign data0_o = mdc_stage_dout_0[0];
    assign data1_o = mdc_stage_dout_1[0];
    assign data2_o = mdc_stage_dout_2[0];
    assign data3_o = mdc_stage_dout_3[0];
    assign data_valid_o = mdc_stage_valout[0];

    logic [DATA_WIDTH-1:0] twiddle0_rom2mdc;
    assign twiddle0_rom2mdc = W4;
    logic [DATA_WIDTH-1:0] twiddle1_rom2mdc[$clog2(N)/2-1:0];
    logic [DATA_WIDTH-1:0] twiddle2_rom2mdc[$clog2(N)/2-1:0];
    logic [DATA_WIDTH-1:0] twiddle3_rom2mdc[$clog2(N)/2-1:0];

    generate
        for (genvar i=$clog2(N)/2-1; i>=0  ; i--) begin

            logic [$clog2(NOF_BUTTERFLY_UNITS*(4**i))-1:0] twiddle_stage_rom_raddr;

            if (i<$clog2(N)/2-1) begin

                // Assign input of each stage to output of previous stage
                assign mdc_stage_din_0[i] = mdc_stage_dout_0[i+1];
                assign mdc_stage_din_1[i] = mdc_stage_dout_1[i+1];
                assign mdc_stage_din_2[i] = mdc_stage_dout_2[i+1];
                assign mdc_stage_din_3[i] = mdc_stage_dout_3[i+1];
                assign mdc_stage_valin[i] = mdc_stage_valout[i+1];

                ntt_r4mdc_dif_stage #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .LOG_R(LOG_R),
                    .N(N),
                    .QINT(QINT),
                    .QDASH(QDASH),
                    .NOF_BUTTERFLY_UNITS(NOF_BUTTERFLY_UNITS),
                    .FIFO_DEPTH(N/(2**(i+2))),
                    .REDUCTION(REDUCTION), // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo
                    .FIFO_TYPE(FIFO_TYPE), // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
                    .BUTTERFLY_TYPE("GS"), // Choose between "CT" and "GS" ToDo
                    .DELAY_MULT(DELAY_MULT),
                    .DELAY_CONST_MULT(DELAY_CONST_MULT),
                    .DELAY_BF(DELAY_BF),
                    .W4(W4),
                    .STAGE(i) // Choose between [0,LOG2(N)-1]
                ) U_MDC_STAGE_GEN (
                    .clk_i(clk_i),
                    .rst_i(rst_i),

                    .data0_i(mdc_stage_din_0[i]),
                    .data1_i(mdc_stage_din_1[i]),
                    .data2_i(mdc_stage_din_2[i]),
                    .data3_i(mdc_stage_din_3[i]),
                    .data_valid_i(mdc_stage_valin[i]),

                    .data0_o(mdc_stage_dout_0[i]),
                    .data1_o(mdc_stage_dout_1[i]),
                    .data2_o(mdc_stage_dout_2[i]),
                    .data3_o(mdc_stage_dout_3[i]),
                    .data_valid_o(mdc_stage_valout[i]),

                    .twiddle_raddr_o(twiddle_stage_rom_raddr),

                    .twiddle0_i(twiddle0_rom2mdc),
                    .twiddle1_i(twiddle1_rom2mdc[i]),
                    .twiddle2_i(twiddle2_rom2mdc[i]),
                    .twiddle3_i(twiddle3_rom2mdc[i])
                );


            end else begin

                logic [DATA_WIDTH-1:0] gsbf_in0_d;
                logic [DATA_WIDTH-1:0] gsbf_in0_q;

                logic [DATA_WIDTH-1:0] gsbf_in1_d;
                logic [DATA_WIDTH-1:0] gsbf_in1_q;

                logic [DATA_WIDTH-1:0] gsbf_in2_d;
                logic [DATA_WIDTH-1:0] gsbf_in2_q;

                logic [DATA_WIDTH-1:0] gsbf_in3_d;
                logic [DATA_WIDTH-1:0] gsbf_in3_q;

                assign gsbf_in0_d = mdc_stage_din_0[i];
                assign gsbf_in1_d = mdc_stage_din_1[i];
                assign gsbf_in2_d = mdc_stage_din_2[i];
                assign gsbf_in3_d = mdc_stage_din_3[i];

                always_ff @(posedge clk_i) begin
                    gsbf_in0_q = gsbf_in0_d;
                    gsbf_in1_q = gsbf_in1_d;
                    gsbf_in2_q = gsbf_in2_d;
                    gsbf_in3_q = gsbf_in3_d;
                end

                prim_ntt_r4gsbfu #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .REDUCTION(REDUCTION),
                    .LOG_R(LOG_R),
                    .W4(W4),
                    .QINT(QINT),
                    .QDASH(QDASH),
                    .DELAY_MULT(DELAY_MULT),
                    .DELAY_CONST_MULT(DELAY_CONST_MULT)
                ) U_GSBF_0 (
                    .clk_i(clk_i),
                    .op0_i(gsbf_in0_q),
                    .op1_i(gsbf_in1_q),
                    .op2_i(gsbf_in2_q),
                    .op3_i(gsbf_in3_q),
                    .twiddle0_i(twiddle0_rom2mdc),
                    .twiddle1_i(twiddle1_rom2mdc[i]),
                    .twiddle2_i(twiddle2_rom2mdc[i]),
                    .twiddle3_i(twiddle3_rom2mdc[i]),
                    .res0_o(mdc_stage_dout_0[i]),
                    .res1_o(mdc_stage_dout_1[i]),
                    .res2_o(mdc_stage_dout_2[i]),
                    .res3_o(mdc_stage_dout_3[i])
                );

                // Shift register to delay valid signal
                logic [DELAY_BF:0] dataval_shreg;
                always_ff @(posedge clk_i) begin
                    if (rst_i) begin
                        dataval_shreg <= 0;
                    end else begin
                        dataval_shreg <= {dataval_shreg[$left(dataval_shreg)-1:0], mdc_stage_valin[i]};
                    end
                end

                localparam DELAY_TWIDDLE = DELAY_CONST_MULT + 3 + 3 + 2;
                logic [DELAY_TWIDDLE-1:0] twiddle_cnt_shreg;
                always_ff @(posedge clk_i) begin
                    if (rst_i) begin
                        twiddle_cnt_shreg <= 0;
                    end else begin
                    twiddle_cnt_shreg <= {twiddle_cnt_shreg[$left(twiddle_cnt_shreg)-1:0], mdc_stage_valin[i]};
                    end
                end

                //ToDo: Change when delay due to pipelining in butterfly unit:
                logic cnt_en;
                assign cnt_en = twiddle_cnt_shreg[$left(twiddle_cnt_shreg)];

                always_ff @(posedge clk_i) begin
                    if (rst_i) begin
                        twiddle_stage_rom_raddr <= 0;
                    end else if (cnt_en) begin
                        twiddle_stage_rom_raddr ++;
                    end
                end
                assign mdc_stage_valout[i] = dataval_shreg[$left(dataval_shreg)];
            end

            if (i>0 || NOF_BUTTERFLY_UNITS > 1) begin  

                localparam memfile1 = $sformatf("%s/twiddle_inv_stage_rom1_%0d.mem",TWIDDLE_MEM_PATH,i);
                localparam memfile2 = $sformatf("%s/twiddle_inv_stage_rom2_%0d.mem",TWIDDLE_MEM_PATH,i);
                localparam memfile3 = $sformatf("%s/twiddle_inv_stage_rom3_%0d.mem",TWIDDLE_MEM_PATH,i);

                // Twiddle ROM for each stage
                prim_ntt_twiddlerom #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .DEPTH(NOF_BUTTERFLY_UNITS*(4**i)),
                    .memfile(memfile1)
                ) U_TWIDDLE_STAGE_ROM1_GEN (
                    .clk_i(clk_i),
                    .raddr_i(twiddle_stage_rom_raddr),
                    .data_o(twiddle1_rom2mdc[i])
                );

                prim_ntt_twiddlerom #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .DEPTH(NOF_BUTTERFLY_UNITS*(4**i)),
                    .memfile(memfile2)
                ) U_TWIDDLE_STAGE_ROM2_GEN (
                    .clk_i(clk_i),
                    .raddr_i(twiddle_stage_rom_raddr),
                    .data_o(twiddle2_rom2mdc[i])
                );

                prim_ntt_twiddlerom #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .DEPTH(NOF_BUTTERFLY_UNITS*(4**i)),
                    .memfile(memfile3)
                ) U_TWIDDLE_STAGE_ROM3_GEN (
                    .clk_i(clk_i),
                    .raddr_i(twiddle_stage_rom_raddr),
                    .data_o(twiddle3_rom2mdc[i])
                );

            end else begin

                localparam memfile1 = $sformatf("%s/twiddle_inv_stage_rom1_%0d.mem",TWIDDLE_MEM_PATH,i);
                localparam memfile2 = $sformatf("%s/twiddle_inv_stage_rom2_%0d.mem",TWIDDLE_MEM_PATH,i);
                localparam memfile3 = $sformatf("%s/twiddle_inv_stage_rom3_%0d.mem",TWIDDLE_MEM_PATH,i);
                
                logic [DATA_WIDTH-1:0] twiddle_const1 [0:0];
                logic [DATA_WIDTH-1:0] twiddle_const2 [0:0];
                logic [DATA_WIDTH-1:0] twiddle_const3 [0:0];

                initial begin
                    $readmemh(memfile1,twiddle_const1);
                    $readmemh(memfile2,twiddle_const2);
                    $readmemh(memfile3,twiddle_const3);
                end
                
                assign twiddle1_rom2mdc[i] = twiddle_const1[0];
                assign twiddle2_rom2mdc[i] = twiddle_const2[0];
                assign twiddle3_rom2mdc[i] = twiddle_const3[0];
                
            end
            
        end
        
    endgenerate

endmodule