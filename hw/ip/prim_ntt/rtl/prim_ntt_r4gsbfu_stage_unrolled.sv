// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0   
   
`timescale 1ns/10ps

module prim_ntt_r4gsbfu_stage_unrolled
#(
    parameter int unsigned DATA_WIDTH = 27,
    parameter int unsigned LOG_R = 27,
    parameter int unsigned N = 1024,
   	parameter longint QINT = 134215681,
    parameter longint QDASH = 130021375,
    parameter int unsigned FIFO_DEPTH = 64,
    parameter REDUCTION = "SOLINA27", // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo
    parameter FIFO_TYPE = "XPM",        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
    parameter BUTTERFLY_TYPE = "GS",    // Choose between "CT" and "GS" ToDo
    parameter int unsigned DELAY_MULT = 11,
    parameter int unsigned DELAY_CONST_MULT = 8,
    parameter int unsigned DELAY_BF = 10,
    parameter longint W4 = 37361560,
    parameter int unsigned NOF_BUTTERFLY_UNITS = 4,
    parameter int unsigned STAGE = 0                 // Choose between [0,LOG2(N)-1]
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
    output  logic                       data_valid_o,

    output  logic   [$clog2(4**STAGE)-1:0]     twiddle_raddr_o,
    input   logic   [DATA_WIDTH-1:0]    twiddle0_i[NOF_BUTTERFLY_UNITS-1:0],
    input   logic   [DATA_WIDTH-1:0]    twiddle1_i[NOF_BUTTERFLY_UNITS-1:0],
    input   logic   [DATA_WIDTH-1:0]    twiddle2_i[NOF_BUTTERFLY_UNITS-1:0],
    input   logic   [DATA_WIDTH-1:0]    twiddle3_i[NOF_BUTTERFLY_UNITS-1:0]
);

    // Input registers
    logic [DATA_WIDTH-1:0] data0_d[NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] data0_q[NOF_BUTTERFLY_UNITS-1:0];
    assign data0_d = data0_i;
    always_ff @(posedge clk_i) begin
        data0_q <= data0_d;
    end

    logic [DATA_WIDTH-1:0] data1_d[NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] data1_q[NOF_BUTTERFLY_UNITS-1:0];
    assign data1_d = data1_i;
    always_ff @(posedge clk_i) begin
        data1_q <= data1_d;
    end

    logic [DATA_WIDTH-1:0] data2_d[NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] data2_q[NOF_BUTTERFLY_UNITS-1:0];
    assign data2_d = data2_i;
    always_ff @(posedge clk_i) begin
        data2_q <= data2_d;
    end

    logic [DATA_WIDTH-1:0] data3_d[NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] data3_q[NOF_BUTTERFLY_UNITS-1:0];
    assign data3_d = data3_i;
    always_ff @(posedge clk_i) begin
        data3_q <= data3_d;
    end

    logic data_valid_d;
    logic data_valid_q;
    assign data_valid_d = data_valid_i;
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            data_valid_q <= '0;
        end else begin
            data_valid_q <= data_valid_d;
        end
    end

    // Switch implementation
    logic [DATA_WIDTH-1:0] in2sw [4*NOF_BUTTERFLY_UNITS-1:0];

    for (genvar i=0; i<NOF_BUTTERFLY_UNITS; ++i) begin
        assign in2sw[4*i]   = data0_q[i];
        assign in2sw[4*i+1] = data1_q[i];
        assign in2sw[4*i+2] = data2_q[i];
        assign in2sw[4*i+3] = data3_q[i];
    end

    logic [DATA_WIDTH-1:0] sw2bf0 [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] sw2bf1 [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] sw2bf2 [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] sw2bf3 [NOF_BUTTERFLY_UNITS-1:0];

    always_comb begin

        unique case (STAGE)

            0 : begin

                unique case (NOF_BUTTERFLY_UNITS)
                    4: begin
                        for (int i=0; i<NOF_BUTTERFLY_UNITS; ++i) begin
                            sw2bf0[i] = in2sw[i];
                            sw2bf1[i] = in2sw[4+i];
                            sw2bf2[i] = in2sw[8+i];
                            sw2bf3[i] = in2sw[12+i];                            
                        end

                    end

                    8: begin
                        for (int i=0; i<NOF_BUTTERFLY_UNITS/2; ++i) begin
                            for(int j=0; j<2; ++j) begin
                                sw2bf0[2*i+j] = in2sw[i+j*4];
                                sw2bf1[2*i+j] = in2sw[8+i+j*4];
                                sw2bf2[2*i+j] = in2sw[16+i+j*4];
                                sw2bf3[2*i+j] = in2sw[24+i+j*4];   

                            end                         
                        end

                    end

                    16: begin
                        for(int j=0; j<4; ++j) begin
                            for (int i=0; i<NOF_BUTTERFLY_UNITS/4; ++i) begin
                                sw2bf0[4*j+i] = in2sw[4*i+j];
                                sw2bf1[4*j+i] = in2sw[16+4*i+j];
                                sw2bf2[4*j+i] = in2sw[32+4*i+j];
                                sw2bf3[4*j+i] = in2sw[48+4*i+j];   
                            end               
                        end
                    end 
                    32: begin
                        for(int j=0; j<4; ++j) begin
                            for (int i=0; i<NOF_BUTTERFLY_UNITS/4; ++i) begin
                                sw2bf0[8*j+i] = in2sw[4*i+j];
                                sw2bf1[8*j+i] = in2sw[32+4*i+j];
                                sw2bf2[8*j+i] = in2sw[64+4*i+j];
                                sw2bf3[8*j+i] = in2sw[96+4*i+j];   
                            end               
                        end                        
                    end

                endcase
            end

            1 : begin
                unique case (NOF_BUTTERFLY_UNITS)
                    16: begin
                        for(int j=0; j<4; ++j) begin
                            for (int i=0; i<4; ++i) begin
                                sw2bf0[4*j+i] = in2sw[i+16*j];
                                sw2bf1[4*j+i] = in2sw[4+i+16*j];
                                sw2bf2[4*j+i] = in2sw[8+i+16*j];
                                sw2bf3[4*j+i] = in2sw[12+i+16*j];   
                            end               
                        end
                    end
                    32: begin 
                        for (int k=0; k<4; ++k) begin
                            for(int j=0; j<4; ++j) begin
                                for (int i=0; i<2; ++i) begin
                                    sw2bf0[2*j+i+8*k] = in2sw[4*i+j+k*32];
                                    sw2bf1[2*j+i+8*k] = in2sw[8+4*i+j+k*32];
                                    sw2bf2[2*j+i+8*k] = in2sw[16+4*i+j+k*32];
                                    sw2bf3[2*j+i+8*k] = in2sw[24+4*i+j+k*32];   
                                end               
                            end
                        end
                    end
                endcase
            end
        endcase
    end

    generate
        for (genvar i=0; i<NOF_BUTTERFLY_UNITS; ++i) begin
            // Gentleman-Sande Butterfly for INTT
            prim_ntt_r4gsbfu #(
                .DATA_WIDTH(DATA_WIDTH),
                .REDUCTION(REDUCTION),
                .LOG_R(LOG_R),
                .QINT(QINT),
                .QDASH(QDASH),
                .DELAY_MULT(DELAY_MULT),
                .DELAY_CONST_MULT(DELAY_CONST_MULT),
                .W4(W4)
            ) U_GSBF_0 (
                .clk_i(clk_i),
                .op0_i(sw2bf0[i]),
                .op1_i(sw2bf1[i]),
                .op2_i(sw2bf2[i]),
                .op3_i(sw2bf3[i]),
                .twiddle0_i(twiddle0_i[i]),
                .twiddle1_i(twiddle1_i[i]),
                .twiddle2_i(twiddle2_i[i]),
                .twiddle3_i(twiddle3_i[i]),
                .res0_o(data0_o[i]),
                .res1_o(data1_o[i]),
                .res2_o(data2_o[i]),
                .res3_o(data3_o[i])
            );         
        end

    endgenerate

    // Shift register to delay valid signal to write to FIFOs before switch
    logic [DELAY_BF-1:0] dataval_shreg;
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            dataval_shreg <= 0;
        end else begin
            dataval_shreg <= {dataval_shreg[$left(dataval_shreg)-1:0], data_valid_q};
        end
    end

    // Read twiddle factors from dedicated memory
    // ToDo: Check for other stages and investiagte On-The-Fly Computation
    // Count samples for switch control
    logic twiddle_cnt_en;
    logic [$clog2(N/(2*(NOF_BUTTERFLY_UNITS)))-1:0] twiddle_cnt;
    localparam DELAY_TWIDDLE = DELAY_MULT + 1;
    logic [DELAY_TWIDDLE-1:0] twiddle_cnt_shreg;
    
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            twiddle_cnt <= 0;
        end else if (twiddle_cnt_en) begin
            twiddle_cnt ++;
        end
    end
    
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            twiddle_cnt_shreg <= 0;
        end else begin
           twiddle_cnt_shreg <= {twiddle_cnt_shreg[$left(twiddle_cnt_shreg)-1:0], data_valid_q};
        end
    end

    assign twiddle_cnt_en = twiddle_cnt_shreg[$left(twiddle_cnt_shreg)];

    generate
        if (STAGE == 0) begin
            assign twiddle_raddr_o = '0;
        end else begin
            assign twiddle_raddr_o = twiddle_cnt[$left(twiddle_cnt):$left(twiddle_cnt)-2*STAGE+1];
        end
    endgenerate

    assign data_valid_o = dataval_shreg[$left(dataval_shreg)];

endmodule