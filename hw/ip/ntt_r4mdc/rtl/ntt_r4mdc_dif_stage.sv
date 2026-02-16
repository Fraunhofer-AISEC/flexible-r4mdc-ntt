// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0   
   
`timescale 1ns/10ps

module ntt_r4mdc_dif_stage
#(
    parameter int unsigned DATA_WIDTH = 27,
    parameter int unsigned LOG_R = 27,
    parameter int unsigned N = 1024,
   	parameter longint QINT = 134215681,
    parameter longint QDASH = 130021375,
    parameter int unsigned FIFO_DEPTH = 512,
    parameter REDUCTION = "SOLINA27", // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo
    parameter FIFO_TYPE = "XPM",        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
    parameter BUTTERFLY_TYPE = "GS",    // Choose between "CT" and "GS" ToDo
    parameter int unsigned DELAY_BF = 11,
    parameter int unsigned DELAY_MULT = 5,
    parameter int unsigned DELAY_CONST_MULT = 5,
    parameter longint W4 = 37361560,
    parameter int unsigned NOF_BUTTERFLY_UNITS = 1,
    parameter int unsigned STAGE = 0                 // Choose between [0,LOG2(N)-1]
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
    output  logic                       data_valid_o,

    output  logic   [$clog2((4**STAGE)*NOF_BUTTERFLY_UNITS)-1:0]     twiddle_raddr_o,
    input   logic   [DATA_WIDTH-1:0]    twiddle0_i,
    input   logic   [DATA_WIDTH-1:0]    twiddle1_i,
    input   logic   [DATA_WIDTH-1:0]    twiddle2_i,
    input   logic   [DATA_WIDTH-1:0]    twiddle3_i
);
    // FIFO Depths
    localparam FIFO_DEPTH_0_1 = 1*N/(4**(2+STAGE));
    localparam FIFO_DEPTH_0_2 = 2*N/(4**(2+STAGE));
    localparam FIFO_DEPTH_0_3 = 3*N/(4**(2+STAGE));

    localparam FIFO_DEPTH_1_0 = 3*N/(4**(2+STAGE));
    localparam FIFO_DEPTH_1_1 = 2*N/(4**(2+STAGE));
    localparam FIFO_DEPTH_1_2 = 1*N/(4**(2+STAGE));

    // Input registers
    logic [DATA_WIDTH-1:0] data0_d;
    logic [DATA_WIDTH-1:0] data0_q;
    assign data0_d = data0_i;
    always_ff @(posedge clk_i) begin
        data0_q <= data0_d;
    end

    logic [DATA_WIDTH-1:0] data1_d;
    logic [DATA_WIDTH-1:0] data1_q;
    assign data1_d = data1_i;
    always_ff @(posedge clk_i) begin
        data1_q <= data1_d;
    end

    logic [DATA_WIDTH-1:0] data2_d;
    logic [DATA_WIDTH-1:0] data2_q;
    assign data2_d = data2_i;
    always_ff @(posedge clk_i) begin
        data2_q <= data2_d;
    end

    logic [DATA_WIDTH-1:0] data3_d;
    logic [DATA_WIDTH-1:0] data3_q;
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

    // Data valid register
    logic dataval2out;

    logic [DATA_WIDTH-1:0] in2sw;
    logic [DATA_WIDTH-1:0] fifo2sw1;
    logic [DATA_WIDTH-1:0] fifo2sw2;
    logic [DATA_WIDTH-1:0] fifo2sw3;

    assign in2sw = data0_q;

    logic rd_en_fifo0_1;
    logic rd_en_fifo0_2;
    logic rd_en_fifo0_3;
    logic wr_en_fifo0;

    assign wr_en_fifo0 = data_valid_q; 

    fifo_wrapper #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH_0_1),
        .FIFO_TYPE(FIFO_TYPE)
    ) U_FIFO_0_1 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .data_i(data1_q),
        .data_o(fifo2sw1),    
        .wr_en_fifo_i(wr_en_fifo0),
        .rd_en_fifo_i(rd_en_fifo0_1)
    );

    fifo_wrapper #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH_0_2),
        .FIFO_TYPE(FIFO_TYPE)
    ) U_FIFO_0_2 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .data_i(data2_q),
        .data_o(fifo2sw2),    
        .wr_en_fifo_i(wr_en_fifo0),
        .rd_en_fifo_i(rd_en_fifo0_2)
    );

    fifo_wrapper #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH_0_3),
        .FIFO_TYPE(FIFO_TYPE)
    ) U_FIFO_0_3 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .data_i(data3_q),
        .data_o(fifo2sw3),    
        .wr_en_fifo_i(wr_en_fifo0),
        .rd_en_fifo_i(rd_en_fifo0_3)
    );


    // Shift register to delay rd_en_fifo0_1
    generate 
        if (FIFO_DEPTH_0_1 > 1) begin
            logic [FIFO_DEPTH_0_1-1:0] rd_en_fifo0_1_shreg;
            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    rd_en_fifo0_1_shreg <= 0;
                end else begin
                    rd_en_fifo0_1_shreg <= {rd_en_fifo0_1_shreg[$left(rd_en_fifo0_1_shreg)-1:0], data_valid_q};
                end
            end
            assign rd_en_fifo0_1 = rd_en_fifo0_1_shreg[$left(rd_en_fifo0_1_shreg)];

        end else begin

            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    rd_en_fifo0_1 <= 0;
                end else begin
                    rd_en_fifo0_1 <= data_valid_q;
                end
            end
           
        end

    endgenerate


    // Shift register to delay rd_en_fifo0_2
    generate 
        if (FIFO_DEPTH_0_2 > 1) begin
            logic [FIFO_DEPTH_0_2-1:0] rd_en_fifo0_2_shreg;
            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    rd_en_fifo0_2_shreg <= 0;
                end else begin
                    rd_en_fifo0_2_shreg <= {rd_en_fifo0_2_shreg[$left(rd_en_fifo0_2_shreg)-1:0], data_valid_q};
                end
            end
            assign rd_en_fifo0_2 = rd_en_fifo0_2_shreg[$left(rd_en_fifo0_2_shreg)];

        end else begin

            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    rd_en_fifo0_2 <= 0;
                end else begin
                    rd_en_fifo0_2 <= data_valid_q;
                end
            end
           
        end

    endgenerate

    // Shift register to delay rd_en_fifo0_3
    generate 
        if (FIFO_DEPTH_0_3 > 1) begin
            logic [FIFO_DEPTH_0_3-1:0] rd_en_fifo0_3_shreg;
            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    rd_en_fifo0_3_shreg <= 0;
                end else begin
                    rd_en_fifo0_3_shreg <= {rd_en_fifo0_3_shreg[$left(rd_en_fifo0_3_shreg)-1:0], data_valid_q};
                end
            end
            assign rd_en_fifo0_3 = rd_en_fifo0_3_shreg[$left(rd_en_fifo0_3_shreg)];

        end else begin

            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    rd_en_fifo0_3 <= 0;
                end else begin
                    rd_en_fifo0_3 <= data_valid_q;
                end
            end
           
        end

    endgenerate


    // Switch logic
    logic [1:0] sw_sel;
    logic sw_cnt_en;
    logic [$clog2(N/4)-1:0] sw_cnt;

    // Count samples for switch control
    assign sw_cnt_en = data_valid_q | rd_en_fifo0_3 | dataval2out;
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            sw_cnt <= 0;
        end else if (sw_cnt_en) begin
            sw_cnt ++;
        end else begin
            sw_cnt <= 0;
        end
    end

    assign sw_sel = sw_cnt[$left(sw_cnt)-2*STAGE:$left(sw_cnt)-2*STAGE-1];


    // Switch mux for reordering data
    logic [DATA_WIDTH-1:0] sw2fifo0;
    logic sw2fifo_wen_fifo_0;

    logic [DATA_WIDTH-1:0] sw2fifo1;
    logic sw2fifo_wen_fifo_1;

    logic [DATA_WIDTH-1:0] sw2fifo2;
    logic sw2fifo_wen_fifo_2;

    logic [DATA_WIDTH-1:0] sw2bf;
    logic sw2bf_valid;

    always_comb begin
        case (sw_sel)
            2'b00: begin
                sw2fifo0 = in2sw;
                sw2fifo1 = fifo2sw3;
                sw2fifo2 = fifo2sw2;
                sw2bf = fifo2sw1;

                sw2fifo_wen_fifo_0 = data_valid_q;
                sw2fifo_wen_fifo_1 = rd_en_fifo0_3;
                sw2fifo_wen_fifo_2 = rd_en_fifo0_2;
                sw2bf_valid = rd_en_fifo0_1;
            end 

            2'b01: begin
                sw2fifo0 = fifo2sw1;
                sw2fifo1 = in2sw;
                sw2fifo2 = fifo2sw3;
                sw2bf = fifo2sw2;

                sw2fifo_wen_fifo_0 = rd_en_fifo0_1;
                sw2fifo_wen_fifo_1 = data_valid_q;
                sw2fifo_wen_fifo_2 = rd_en_fifo0_3;
                sw2bf_valid = rd_en_fifo0_2;
            end 

            2'b10: begin
                sw2fifo0 = fifo2sw2;
                sw2fifo1 = fifo2sw1;
                sw2fifo2 = in2sw;
                sw2bf = fifo2sw3;

                sw2fifo_wen_fifo_0 = rd_en_fifo0_2;
                sw2fifo_wen_fifo_1 = rd_en_fifo0_1; 
                sw2fifo_wen_fifo_2 = data_valid_q;
                sw2bf_valid = rd_en_fifo0_3;
            end 

            2'b11: begin
                sw2fifo0 = fifo2sw3;
                sw2fifo1 = fifo2sw2;
                sw2fifo2 = fifo2sw1;
                sw2bf = in2sw;

                sw2fifo_wen_fifo_0 = rd_en_fifo0_3;
                sw2fifo_wen_fifo_1 = rd_en_fifo0_2; 
                sw2fifo_wen_fifo_2 = rd_en_fifo0_1;
                sw2bf_valid = data_valid_q;
            end 

            default: begin
                sw2fifo0 = in2sw;
                sw2fifo1 = fifo2sw3;
                sw2fifo2 = fifo2sw2;
                sw2bf = fifo2sw1;

                sw2fifo_wen_fifo_0 = data_valid_q;
                sw2fifo_wen_fifo_1 = rd_en_fifo0_3;
                sw2fifo_wen_fifo_2 = rd_en_fifo0_2;
                sw2bf_valid = rd_en_fifo0_1;
            end
        endcase
    end

    logic rd_en_fifo1_0;
    logic rd_en_fifo1_1;
    logic rd_en_fifo1_2;

    logic [DATA_WIDTH-1:0] fifo2bf0;
    logic [DATA_WIDTH-1:0] fifo2bf1;
    logic [DATA_WIDTH-1:0] fifo2bf2;

    fifo_wrapper #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH_1_0),
        .FIFO_TYPE(FIFO_TYPE)
    ) U_FIFO_1_0 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .data_i(sw2fifo0),
        .data_o(fifo2bf0),    
        .wr_en_fifo_i(sw2fifo_wen_fifo_0),
        .rd_en_fifo_i(rd_en_fifo1_0)
    );

    fifo_wrapper #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH_1_1),
        .FIFO_TYPE(FIFO_TYPE)
    ) U_FIFO_1_1 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .data_i(sw2fifo1),
        .data_o(fifo2bf1),    
        .wr_en_fifo_i(sw2fifo_wen_fifo_1),
        .rd_en_fifo_i(rd_en_fifo1_0)
    );

    fifo_wrapper #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH_1_2),
        .FIFO_TYPE(FIFO_TYPE)
    ) U_FIFO_1_2 (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .data_i(sw2fifo2),
        .data_o(fifo2bf2),    
        .wr_en_fifo_i(sw2fifo_wen_fifo_2),
        .rd_en_fifo_i(rd_en_fifo1_0)
    );



    // Shift register to delay rd_en_fifo0_0
    generate 
        if (FIFO_DEPTH_1_0 > 1) begin
            logic [FIFO_DEPTH_1_0-1:0] rd_en_fifo1_0_shreg;
            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    rd_en_fifo1_0_shreg <= 0;
                end else begin
                    rd_en_fifo1_0_shreg <= {rd_en_fifo1_0_shreg[$left(rd_en_fifo1_0_shreg)-1:0], data_valid_q};
                end
            end
            assign rd_en_fifo1_0 = rd_en_fifo1_0_shreg[$left(rd_en_fifo1_0_shreg)];

        end else begin

            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    rd_en_fifo1_0 <= 0;
                end else begin
                    rd_en_fifo1_0 <= data_valid_q;
                end
            end
           
        end

    endgenerate

    // Shift register to delay rd_en_fifo1_1
    generate 
        if (FIFO_DEPTH_1_1 > 1) begin
            logic [FIFO_DEPTH_1_1-1:0] rd_en_fifo1_1_shreg;
            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    rd_en_fifo1_1_shreg <= 0;
                end else begin
                    rd_en_fifo1_1_shreg <= {rd_en_fifo1_1_shreg[$left(rd_en_fifo1_1_shreg)-1:0], data_valid_q};
                end
            end
            assign rd_en_fifo1_1 = rd_en_fifo1_1_shreg[$left(rd_en_fifo1_1_shreg)];

        end else begin

            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    rd_en_fifo1_1 <= 0;
                end else begin
                    rd_en_fifo1_1 <= data_valid_q;
                end
            end
           
        end
        
    endgenerate

    // Shift register to delay rd_en_fifo1_2
    generate 
        if (FIFO_DEPTH_1_2 > 1) begin
            logic [FIFO_DEPTH_1_2-1:0] rd_en_fifo1_2_shreg;
            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    rd_en_fifo1_2_shreg <= 0;
                end else begin
                    rd_en_fifo1_2_shreg <= {rd_en_fifo1_2_shreg[$left(rd_en_fifo1_2_shreg)-1:0], data_valid_q};
                end
            end
            assign rd_en_fifo1_2 = rd_en_fifo1_2_shreg[$left(rd_en_fifo1_2_shreg)];

        end else begin

            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    rd_en_fifo1_2 <= 0;
                end else begin
                    rd_en_fifo1_2 <= data_valid_q;
                end
            end
           
        end
        
    endgenerate

    logic [DATA_WIDTH-1:0] bf2out0;
    logic [DATA_WIDTH-1:0] bf2out1;
    logic [DATA_WIDTH-1:0] bf2out2;
    logic [DATA_WIDTH-1:0] bf2out3;

    generate

        // Gentleman-Sande Butterfly for inverse NTT
        prim_ntt_r4gsbfu #(
            .DATA_WIDTH(DATA_WIDTH),
            .REDUCTION(REDUCTION),
            .LOG_R(LOG_R),
            .QINT(QINT),
            .QDASH(QDASH),
            .W4(W4),
            .DELAY_MULT(DELAY_MULT),
            .DELAY_CONST_MULT(DELAY_CONST_MULT)
        ) U_GSBF_0 (
            .clk_i(clk_i),
            .op0_i(fifo2bf0),
            .op1_i(fifo2bf1),
            .op2_i(fifo2bf2),
            .op3_i(sw2bf),
            .twiddle0_i(twiddle0_i),
            .twiddle1_i(twiddle1_i),
            .twiddle2_i(twiddle2_i),
            .twiddle3_i(twiddle3_i),
            .res0_o(bf2out0),
            .res1_o(bf2out1),
            .res2_o(bf2out2),
            .res3_o(bf2out3)
        );            

    endgenerate

    // Shift register to delay valid signal 
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
    logic [$clog2((N/4))+(NOF_BUTTERFLY_UNITS-1)-1:0] twiddle_cnt;

    localparam DELAY_TWIDDLE = DELAY_CONST_MULT + 3 + 3 + 2 - 1;;
    logic [DELAY_TWIDDLE-1:0] twiddle_cnt_shreg;
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            twiddle_cnt_shreg <= 0;
        end else begin
           twiddle_cnt_shreg <= {twiddle_cnt_shreg[$left(twiddle_cnt_shreg)-1:0], sw2bf_valid};
        end
    end

    assign twiddle_cnt_en = twiddle_cnt_shreg[$left(twiddle_cnt_shreg)];

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            twiddle_cnt <= 0;
        end else if (twiddle_cnt_en) begin
            twiddle_cnt ++;
        end
    end

    generate
        if (STAGE == 0 && NOF_BUTTERFLY_UNITS == 1) begin
            assign twiddle_raddr_o = '0;
        end else if (STAGE == 0 && NOF_BUTTERFLY_UNITS == 2) begin
            assign twiddle_raddr_o = twiddle_cnt[$left(twiddle_cnt)];
        end else begin
            assign twiddle_raddr_o = twiddle_cnt[$left(twiddle_cnt):$left(twiddle_cnt)-2*STAGE+1-($clog2(NOF_BUTTERFLY_UNITS))];
        end
    endgenerate


    // Shift register to delay valid signal
    generate 
        if (FIFO_DEPTH_1_0 > 1) begin

            logic [FIFO_DEPTH_1_0-1:0] dataval2out_shreg;
            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    dataval2out_shreg <= 0;
                end else begin
                    dataval2out_shreg <= {dataval2out_shreg[$left(dataval2out_shreg)-1:0], dataval_shreg[$left(dataval_shreg)]};
                end
            end
            assign dataval2out = dataval2out_shreg[$left(dataval2out_shreg)];

        end else begin

            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    dataval2out <= 0;
                end else begin
                    dataval2out <= dataval_shreg[$left(dataval_shreg)];
                end
            end
           
        end

    endgenerate


    // Assignment of outputs
    assign data0_o = bf2out0;
    assign data1_o = bf2out1;
    assign data2_o = bf2out2;
    assign data3_o = bf2out3;
    assign data_valid_o = dataval2out;

endmodule