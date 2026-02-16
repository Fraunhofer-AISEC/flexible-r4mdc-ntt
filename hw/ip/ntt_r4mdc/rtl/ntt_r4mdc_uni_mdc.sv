// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0   
   
`timescale 1ns/10ps

module ntt_r4mdc_uni_mdc
#(
    parameter int unsigned DATA_WIDTH = 27,
    parameter int unsigned LOG_R = 27,
    parameter int unsigned N = 1024,
   	parameter longint QINT = 134215681,
    parameter longint QDASH = 130021375,
    parameter int unsigned NOF_BUTTERFLY_UNITS = 1,
    parameter REDUCTION = "MONTGOMERY", // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo
    parameter FIFO_TYPE = "XPM",        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
    parameter BUTTERFLY_TYPE = "CT",     // Choose between "CT" and "GS" ToDo
    parameter int unsigned DELAY_MULT = 5,
    parameter int unsigned DELAY_CONST_MULT = 5,
    parameter int unsigned DELAY_BF = 11,
    parameter longint W4 = 37361560,
    parameter TWIDDLE_MEM_PATH = "/home/t_stelzer/projects/aisec/fhe-sv/rtl/ntt/cggi_std_128_mem",
    parameter bit TWIDDLE2_OPT = 1'b0
)
(
    input   logic                       clk_i,
    input   logic                       rst_i,

    input   logic                       intt_i,

    output  logic   [$clog2(NOF_BUTTERFLY_UNITS*(4**($clog2(N)/2)))-1:0] twiddle_raddr_o [$clog2(N)/2-1:0],
    input   logic   [DATA_WIDTH-1:0]    twiddle0_i[$clog2(N)/2-1:0],
    input   logic   [DATA_WIDTH-1:0]    twiddle1_i[$clog2(N)/2-1:0],
    input   logic   [DATA_WIDTH-1:0]    twiddle2_i[$clog2(N)/2-1:0],
    input   logic   [DATA_WIDTH-1:0]    twiddle3_i[$clog2(N)/2-1:0],

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
    assign mdc_stage_din_0[0] = intt_i ? mdc_stage_dout_0[1] : data0_i;
    assign mdc_stage_din_1[0] = intt_i ? mdc_stage_dout_1[1] : data1_i;
    assign mdc_stage_din_2[0] = intt_i ? mdc_stage_dout_2[1] : data2_i;
    assign mdc_stage_din_3[0] = intt_i ? mdc_stage_dout_3[1] : data3_i;
    assign mdc_stage_valin[0] = intt_i ? mdc_stage_valout[1] : data_valid_i;

    assign mdc_stage_din_0[$clog2(N)/2-1] = intt_i ? data0_i : mdc_stage_dout_0[$clog2(N)/2-2];
    assign mdc_stage_din_1[$clog2(N)/2-1] = intt_i ? data1_i : mdc_stage_dout_1[$clog2(N)/2-2];
    assign mdc_stage_din_2[$clog2(N)/2-1] = intt_i ? data2_i : mdc_stage_dout_2[$clog2(N)/2-2];
    assign mdc_stage_din_3[$clog2(N)/2-1] = intt_i ? data3_i : mdc_stage_dout_3[$clog2(N)/2-2];
    assign mdc_stage_valin[$clog2(N)/2-1] = intt_i ? data_valid_i : mdc_stage_valout[$clog2(N)/2-2];

    // Assign outputs 
    assign data0_o = intt_i ? mdc_stage_dout_0[0] : mdc_stage_dout_0[$clog2(N)/2-1];
    assign data1_o = intt_i ? mdc_stage_dout_1[0] : mdc_stage_dout_1[$clog2(N)/2-1];
    assign data2_o = intt_i ? mdc_stage_dout_2[0] : mdc_stage_dout_2[$clog2(N)/2-1];
    assign data3_o = intt_i ? mdc_stage_dout_3[0] : mdc_stage_dout_3[$clog2(N)/2-1];
    assign data_valid_o = intt_i ? mdc_stage_valout[0] : mdc_stage_valout[$clog2(N)/2-1];

    logic [DATA_WIDTH-1:0] twiddle0_rom2mdc;
    assign twiddle0_rom2mdc = W4;
    logic [DATA_WIDTH-1:0] twiddle1_rom2mdc[$clog2(N)/2-1:0];
    logic [DATA_WIDTH-1:0] twiddle2_rom2mdc[$clog2(N)/2-1:0];
    logic [DATA_WIDTH-1:0] twiddle3_rom2mdc[$clog2(N)/2-1:0];
    logic [DATA_WIDTH-1:0] twiddle1_rom2mdc_ntt[$clog2(N)/2-1:0];
    logic [DATA_WIDTH-1:0] twiddle2_rom2mdc_ntt[$clog2(N)/2-1:0];
    logic [DATA_WIDTH-1:0] twiddle3_rom2mdc_ntt[$clog2(N)/2-1:0];    
    logic [DATA_WIDTH-1:0] twiddle1_rom2mdc_intt[$clog2(N)/2-1:0];
    logic [DATA_WIDTH-1:0] twiddle2_rom2mdc_intt[$clog2(N)/2-1:0];
    logic [DATA_WIDTH-1:0] twiddle3_rom2mdc_intt[$clog2(N)/2-1:0];
    

    generate
    for (genvar i=0; i < $clog2(N)/2; i++) begin

        logic [$clog2(NOF_BUTTERFLY_UNITS*(4**i))-1:0] twiddle_stage_rom_raddr;
        logic [$clog2(NOF_BUTTERFLY_UNITS*(4**i))-1:0] twiddle_stage_rom_raddr_intt;
        assign twiddle_stage_rom_raddr_intt = (4**i-1) - twiddle_stage_rom_raddr;
        assign twiddle_raddr_o[i] = twiddle_stage_rom_raddr;
        if (i<$clog2(N)/2-1) begin
            localparam TWIDDLE2_OPT_LOCAL = (TWIDDLE2_OPT == 1'b1) && (i == 0);
            ntt_r4mdc_uni_stage #(
                .DATA_WIDTH(DATA_WIDTH),
                .LOG_R(LOG_R),
                .N(N),
                .QINT(QINT),
                .QDASH(QDASH),
                .NOF_BUTTERFLY_UNITS(NOF_BUTTERFLY_UNITS),
                .FIFO_DEPTH(N/(2**(i+2))),
                .REDUCTION(REDUCTION), // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo
                .FIFO_TYPE(FIFO_TYPE), // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
                .DELAY_MULT(DELAY_MULT),
                .DELAY_CONST_MULT(DELAY_CONST_MULT),
                .DELAY_BF(DELAY_BF),
                .W4(W4),
                .TWIDDLE2_OPT(TWIDDLE2_OPT_LOCAL),
                .STAGE(i) // Choose between [0,LOG2(N)-1]
            ) U_MDC_STAGE_GEN (
                .clk_i(clk_i),
                .rst_i(rst_i),

                .intt_i(intt_i),

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

            logic [DATA_WIDTH-1:0] bf_in0_d;
            logic [DATA_WIDTH-1:0] bf_in0_q;
            logic [DATA_WIDTH-1:0] bf_in1_d;
            logic [DATA_WIDTH-1:0] bf_in1_q;
            logic [DATA_WIDTH-1:0] bf_in2_d;
            logic [DATA_WIDTH-1:0] bf_in2_q;
            logic [DATA_WIDTH-1:0] bf_in3_d;
            logic [DATA_WIDTH-1:0] bf_in3_q;


            logic [DATA_WIDTH-1:0] bf0_out;
            logic [DATA_WIDTH-1:0] bf1_out;
            logic [DATA_WIDTH-1:0] bf2_out;
            logic [DATA_WIDTH-1:0] bf3_out;

            assign bf_in0_d = mdc_stage_din_0[i];
            assign bf_in1_d = mdc_stage_din_1[i];
            assign bf_in2_d = mdc_stage_din_2[i];
            assign bf_in3_d = mdc_stage_din_3[i];

            always_ff @(posedge clk_i) begin
                bf_in0_q = bf_in0_d;
                bf_in1_q = bf_in1_d;
                bf_in2_q = bf_in2_d;
                bf_in3_q = bf_in3_d;
            end


            // Unified Butterfly for NTT/INTT
            prim_ntt_r4bfu_uni #(
                .DATA_WIDTH(DATA_WIDTH),
                .REDUCTION(REDUCTION),
                .LOG_R(LOG_R),
                .QINT(QINT),
                .QDASH(QDASH),
                .DELAY_MULT(DELAY_MULT),
                .DELAY_CONST_MULT(DELAY_CONST_MULT),
                .W4(W4),
                .TWIDDLE1_OPT(0'b0),
                .TWIDDLE2_OPT(0'b0)
            ) u_ubfu_0 (
                .clk_i(clk_i),
                .intt_i(intt_i),
                .op0_i(bf_in0_q),
                .op1_i(bf_in1_q),
                .op2_i(bf_in2_q),
                .op3_i(bf_in3_q),
                .twiddle0_i(twiddle0_rom2mdc),
                .twiddle1_i(twiddle1_rom2mdc[i]),
                .twiddle2_i(twiddle2_rom2mdc[i]),
                .twiddle3_i(twiddle3_rom2mdc[i]),
                .res0_o(bf0_out),
                .res1_o(bf1_out),
                .res2_o(bf2_out),
                .res3_o(bf3_out)
            );     

            assign mdc_stage_dout_0[i] = bf0_out;
            assign mdc_stage_dout_1[i] = bf1_out;
            assign mdc_stage_dout_2[i] = bf2_out;
            assign mdc_stage_dout_3[i] = bf3_out;

            // Shift register to delay valid signal
            //localparam DELAY_BF = 2;
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
            assign cnt_en = intt_i ? twiddle_cnt_shreg[$left(twiddle_cnt_shreg)] : mdc_stage_valin[i];

            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    twiddle_stage_rom_raddr <= 0;
                end else if (cnt_en) begin
                    twiddle_stage_rom_raddr ++;
                end
            end
            assign mdc_stage_valout[i] = dataval_shreg[$left(dataval_shreg)];
        end
        
        if ((i>0) && (i<$clog2(N)/2-1)) begin
            // Assign input of each stage to output of previous stage
            assign mdc_stage_din_0[i] = intt_i ? mdc_stage_dout_0[i+1] : mdc_stage_dout_0[i-1];
            assign mdc_stage_din_1[i] = intt_i ? mdc_stage_dout_1[i+1] : mdc_stage_dout_1[i-1];
            assign mdc_stage_din_2[i] = intt_i ? mdc_stage_dout_2[i+1] : mdc_stage_dout_2[i-1];
            assign mdc_stage_din_3[i] = intt_i ? mdc_stage_dout_3[i+1] : mdc_stage_dout_3[i-1];
            assign mdc_stage_valin[i] = intt_i ? mdc_stage_valout[i+1] : mdc_stage_valout[i-1];
        end

        if (i>0 || NOF_BUTTERFLY_UNITS > 1) begin

            assign twiddle1_rom2mdc[i] = twiddle1_i[i];
            assign twiddle2_rom2mdc[i] = twiddle2_i[i];
            assign twiddle3_rom2mdc[i] = twiddle3_i[i];

        end else begin
            
            localparam memfile1_ntt = $sformatf("%s/twiddle_stage_rom1_%0d.mem",TWIDDLE_MEM_PATH,i);
            localparam memfile2_ntt = $sformatf("%s/twiddle_stage_rom2_%0d.mem",TWIDDLE_MEM_PATH,i);
            localparam memfile3_ntt = $sformatf("%s/twiddle_stage_rom3_%0d.mem",TWIDDLE_MEM_PATH,i);
            localparam memfile1_intt = $sformatf("%s/twiddle_inv_stage_rom1_%0d.mem",TWIDDLE_MEM_PATH,i);
            localparam memfile2_intt = $sformatf("%s/twiddle_inv_stage_rom2_%0d.mem",TWIDDLE_MEM_PATH,i);
            localparam memfile3_intt = $sformatf("%s/twiddle_inv_stage_rom3_%0d.mem",TWIDDLE_MEM_PATH,i);
            
            logic [DATA_WIDTH-1:0] twiddle_const1_ntt [0:0];
            logic [DATA_WIDTH-1:0] twiddle_const2_ntt [0:0];
            logic [DATA_WIDTH-1:0] twiddle_const3_ntt [0:0];
            logic [DATA_WIDTH-1:0] twiddle_const1_intt [0:0];
            logic [DATA_WIDTH-1:0] twiddle_const2_intt [0:0];
            logic [DATA_WIDTH-1:0] twiddle_const3_intt [0:0];

            initial begin
                $readmemh(memfile1_ntt,twiddle_const1_ntt);
                $readmemh(memfile2_ntt,twiddle_const2_ntt);
                $readmemh(memfile3_ntt,twiddle_const3_ntt);
                $readmemh(memfile1_intt,twiddle_const1_intt);
                $readmemh(memfile2_intt,twiddle_const2_intt);
                $readmemh(memfile3_intt,twiddle_const3_intt);
            end

            assign twiddle1_rom2mdc[i] = intt_i ? twiddle_const1_intt[0] : twiddle_const1_ntt[0];
            assign twiddle2_rom2mdc[i] = intt_i ? twiddle_const2_intt[0] : twiddle_const2_ntt[0];
            assign twiddle3_rom2mdc[i] = intt_i ? twiddle_const3_intt[0] : twiddle_const3_ntt[0];

        end
        
    end
        
    endgenerate

endmodule