// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0   
   
`timescale 1ns/10ps

module prim_ntt_r4uni_stage_unrolled
#(
    parameter int unsigned DATA_WIDTH = 27,
    parameter int unsigned LOG_R = 27,
    parameter int unsigned N = 1024,
   	parameter longint QINT = 134215681,
    parameter longint QDASH = 130021375,
    parameter int unsigned FIFO_DEPTH = 64,
    parameter REDUCTION = "SOLINA27", // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo
    parameter FIFO_TYPE = "XPM",        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
    parameter BUTTERFLY_TYPE = "CT",    // Choose between "CT" and "GS" ToDo
    parameter int unsigned DELAY_MULT = 5,
    parameter int unsigned DELAY_CONST_MULT = 5,
    parameter int unsigned DELAY_BF = 10,
    parameter longint W4 = 37361560,
    parameter int unsigned NOF_BUTTERFLY_UNITS = 4,
    parameter int unsigned STAGE = 0,                 // Choose between [0,LOG2(N)-1]
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
    output  logic                       data_valid_o,

    output  logic   [$clog2(4**STAGE)-1:0]     twiddle_raddr_o,
    input   logic   [DATA_WIDTH-1:0]    twiddle0_i[NOF_BUTTERFLY_UNITS-1:0],
    input   logic   [DATA_WIDTH-1:0]    twiddle1_i[NOF_BUTTERFLY_UNITS-1:0],
    input   logic   [DATA_WIDTH-1:0]    twiddle2_i[NOF_BUTTERFLY_UNITS-1:0],
    input   logic   [DATA_WIDTH-1:0]    twiddle3_i[NOF_BUTTERFLY_UNITS-1:0]
);
    // Check if twiddle factor optimization can be applied in current unrolled stage
    localparam TWIDDLE1_OPT_LOCAL = (TWIDDLE1_OPT == 1'b1) && (STAGE == 0);
    localparam TWIDDLE2_OPT_LOCAL = (TWIDDLE2_OPT == 1'b1) && (STAGE == 0);

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

    // Butterfly unit
    logic [DATA_WIDTH-1:0] bf0_in [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] bf1_in [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] bf2_in [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] bf3_in [NOF_BUTTERFLY_UNITS-1:0];

    logic [DATA_WIDTH-1:0] bf0_out [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] bf1_out [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] bf2_out [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] bf3_out [NOF_BUTTERFLY_UNITS-1:0];

    // Reorder Switch     
    logic [DATA_WIDTH-1:0] sw0_in [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] sw1_in [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] sw2_in [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] sw3_in [NOF_BUTTERFLY_UNITS-1:0];

    logic [DATA_WIDTH-1:0] sw_in [4*NOF_BUTTERFLY_UNITS-1:0];

    logic [DATA_WIDTH-1:0] sw0_out [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] sw1_out [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] sw2_out [NOF_BUTTERFLY_UNITS-1:0];
    logic [DATA_WIDTH-1:0] sw3_out [NOF_BUTTERFLY_UNITS-1:0];
    

    // Logic for NTT <-> INTT switching
    generate
        for (genvar i=0; i<NOF_BUTTERFLY_UNITS; ++i) begin

            assign bf0_in[i] = intt_i ? sw0_out[i] : data0_q[i];
            assign bf1_in[i] = intt_i ? sw1_out[i] : data1_q[i];
            assign bf2_in[i] = intt_i ? sw2_out[i] : data2_q[i];
            assign bf3_in[i] = intt_i ? sw3_out[i] : data3_q[i];

            assign sw0_in[i] = intt_i ? data0_q[i] : bf0_out[i];
            assign sw1_in[i] = intt_i ? data1_q[i] : bf1_out[i];
            assign sw2_in[i] = intt_i ? data2_q[i] : bf2_out[i];
            assign sw3_in[i] = intt_i ? data3_q[i] : bf3_out[i];

            assign data0_o[i] = intt_i ? bf0_out[i] : sw0_out[i];
            assign data1_o[i] = intt_i ? bf1_out[i] : sw1_out[i];
            assign data2_o[i] = intt_i ? bf2_out[i] : sw2_out[i];
            assign data3_o[i] = intt_i ? bf3_out[i] : sw3_out[i];

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
                .TWIDDLE1_OPT(TWIDDLE1_OPT_LOCAL),
                .TWIDDLE2_OPT(TWIDDLE2_OPT_LOCAL)
            ) u_ubfu_0 (
                .clk_i(clk_i),
                .intt_i(intt_i),
                .op0_i(bf0_in[i]),
                .op1_i(bf1_in[i]),
                .op2_i(bf2_in[i]),
                .op3_i(bf3_in[i]),
                .twiddle0_i(twiddle0_i[i]),
                .twiddle1_i(twiddle1_i[i]),
                .twiddle2_i(twiddle2_i[i]),
                .twiddle3_i(twiddle3_i[i]),
                .res0_o(bf0_out[i]),
                .res1_o(bf1_out[i]),
                .res2_o(bf2_out[i]),
                .res3_o(bf3_out[i])
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
    // Count samples for switch control
    logic twiddle_cnt_en;
    logic [$clog2(N/(2*(NOF_BUTTERFLY_UNITS)))-1:0] twiddle_cnt;
    // ToDo: Per Parameter
    localparam DELAY_TWIDDLE = DELAY_MULT + 8;
    //localparam DELAY_MUL = 5;
    logic [DELAY_TWIDDLE-1:0] twiddle_cnt_shreg;

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            twiddle_cnt_shreg <= 0;
        end else begin
           twiddle_cnt_shreg <= {twiddle_cnt_shreg[$left(twiddle_cnt_shreg)-1:0], data_valid_q};
        end
    end

    assign twiddle_cnt_en = intt_i ? twiddle_cnt_shreg[$left(twiddle_cnt_shreg)] : data_valid_i;

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            twiddle_cnt <= 0;
        end else if (twiddle_cnt_en) begin
            twiddle_cnt ++;
        end
    end

    generate
        if (STAGE == 0) begin
            assign twiddle_raddr_o = '0;
        end else begin
            assign twiddle_raddr_o = twiddle_cnt[$left(twiddle_cnt):$left(twiddle_cnt)-2*STAGE+1];
        end
    endgenerate

    // Reorder Switch
    always_comb begin
        for (int i=0; i<NOF_BUTTERFLY_UNITS; ++i) begin
            sw_in[4*i] = sw0_in[i];
            sw_in[4*i+1] = sw1_in[i];
            sw_in[4*i+2] = sw2_in[i];
            sw_in[4*i+3] = sw3_in[i];
        end
        unique case (STAGE)
            0 : begin
                unique case (NOF_BUTTERFLY_UNITS)
                    4: begin
                        for (int i=0; i<NOF_BUTTERFLY_UNITS; ++i) begin
                            sw0_out[i] = sw_in[i];
                            sw1_out[i] = sw_in[4+i];
                            sw2_out[i] = sw_in[8+i];
                            sw3_out[i] = sw_in[12+i];                            
                        end
                    end
                    8: begin
                        for (int i=0; i<NOF_BUTTERFLY_UNITS/2; ++i) begin
                            for(int j=0; j<2; ++j) begin
                                sw0_out[2*i+j] = sw_in[i+j*4];
                                sw1_out[2*i+j] = sw_in[8+i+j*4];
                                sw2_out[2*i+j] = sw_in[16+i+j*4];
                                sw3_out[2*i+j] = sw_in[24+i+j*4];   

                            end                         
                        end
                    end
                    16: begin
                        for(int j=0; j<4; ++j) begin
                            for (int i=0; i<NOF_BUTTERFLY_UNITS/4; ++i) begin
                                sw0_out[4*j+i] = sw_in[4*i+j];
                                sw1_out[4*j+i] = sw_in[16+4*i+j];
                                sw2_out[4*j+i] = sw_in[32+4*i+j];
                                sw3_out[4*j+i] = sw_in[48+4*i+j];   
                            end               
                        end
                    end 
                    32: begin
                        for(int j=0; j<4; ++j) begin
                            for (int i=0; i<NOF_BUTTERFLY_UNITS/4; ++i) begin
                                sw0_out[8*j+i] = sw_in[4*i+j];
                                sw1_out[8*j+i] = sw_in[32+4*i+j];
                                sw2_out[8*j+i] = sw_in[64+4*i+j];
                                sw3_out[8*j+i] = sw_in[96+4*i+j];   
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
                                sw0_out[4*j+i] = sw_in[i+16*j];
                                sw1_out[4*j+i] = sw_in[4+i+16*j];
                                sw2_out[4*j+i] = sw_in[8+i+16*j];
                                sw3_out[4*j+i] = sw_in[12+i+16*j];   
                            end               
                        end
                    end
                    32: begin 
                        for (int k=0; k<4; ++k) begin
                            for(int j=0; j<4; ++j) begin
                                for (int i=0; i<2; ++i) begin
                                    sw0_out[2*j+i+8*k] = sw_in[4*i+j+k*32];
                                    sw1_out[2*j+i+8*k] = sw_in[8+4*i+j+k*32];
                                    sw2_out[2*j+i+8*k] = sw_in[16+4*i+j+k*32];
                                    sw3_out[2*j+i+8*k] = sw_in[24+4*i+j+k*32];   
                                end               
                            end
                        end
                    end
                endcase
            end
        endcase
    end

    assign data_valid_o = dataval_shreg[$left(dataval_shreg)];

endmodule