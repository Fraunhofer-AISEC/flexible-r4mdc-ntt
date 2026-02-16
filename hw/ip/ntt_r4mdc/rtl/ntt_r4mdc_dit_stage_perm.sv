// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0   
   
`timescale 1ns/10ps

module ntt_r4mdc_dit_stage_perm
#(
    parameter int unsigned DATA_WIDTH = 27,
    parameter int unsigned LOG_R = 27,
    parameter int unsigned N = 1024,
   	parameter longint QINT = 134215681,
    parameter longint QDASH = 130021375,
    parameter FIFO_DEPTH = 64,
    parameter REDUCTION = "SOLINA27", // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo
    parameter FIFO_TYPE = "XPM",        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
    parameter BUTTERFLY_TYPE = "CT",    // Choose between "CT" and "GS" ToDo
    parameter int unsigned DELAY_MULT = 5,
    parameter int unsigned DELAY_CONST_MULT = 5,
    parameter int unsigned DELAY_BF = 10,
    parameter longint W4 = 37361560,
    parameter int unsigned STAGE = 0                 // Choose between [0,LOG2(N)-1]
)
(
    input   logic                       clk_i,
    input   logic                       rst_i,

    input   logic   [DATA_WIDTH-1:0]    data0_i[1:0],
    input   logic   [DATA_WIDTH-1:0]    data1_i[1:0],
    input   logic   [DATA_WIDTH-1:0]    data2_i[1:0],
    input   logic   [DATA_WIDTH-1:0]    data3_i[1:0],
    input   logic                       data_valid_i,

    output  logic   [DATA_WIDTH-1:0]    data0_o[1:0],
    output  logic   [DATA_WIDTH-1:0]    data1_o[1:0],
    output  logic   [DATA_WIDTH-1:0]    data2_o[1:0],
    output  logic   [DATA_WIDTH-1:0]    data3_o[1:0],
    output  logic                       data_valid_o,

    output  logic   [$clog2(4**STAGE)-1:0]     twiddle_raddr_o,
    input   logic   [DATA_WIDTH-1:0]    twiddle0_i[1:0],
    input   logic   [DATA_WIDTH-1:0]    twiddle1_i[1:0],
    input   logic   [DATA_WIDTH-1:0]    twiddle2_i[1:0],
    input   logic   [DATA_WIDTH-1:0]    twiddle3_i[1:0]
);
    // FIFO Depths
    localparam FIFO_DEPTH_0_1 = FIFO_DEPTH;
    localparam FIFO_DEPTH_0_3 = FIFO_DEPTH;
    localparam FIFO_DEPTH_1_0 = FIFO_DEPTH;
    localparam FIFO_DEPTH_1_2 = FIFO_DEPTH;

    // Input registers
    logic [DATA_WIDTH-1:0] data0_d[1:0];
    logic [DATA_WIDTH-1:0] data0_q[1:0];
    assign data0_d = data0_i;
    always_ff @(posedge clk_i) begin
        data0_q <= data0_d;
    end

    logic [DATA_WIDTH-1:0] data1_d[1:0];
    logic [DATA_WIDTH-1:0] data1_q[1:0];
    assign data1_d = data1_i;
    always_ff @(posedge clk_i) begin
        data1_q <= data1_d;
    end

    logic [DATA_WIDTH-1:0] data2_d[1:0];
    logic [DATA_WIDTH-1:0] data2_q[1:0];
    assign data2_d = data2_i;
    always_ff @(posedge clk_i) begin
        data2_q <= data2_d;
    end

    logic [DATA_WIDTH-1:0] data3_d[1:0];
    logic [DATA_WIDTH-1:0] data3_q[1:0];
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

    // Butterfly unit
    logic [DATA_WIDTH-1:0] bf2sw0 [1:0];
    logic [DATA_WIDTH-1:0] bf2fifo1 [1:0];
    logic [DATA_WIDTH-1:0] bf2sw2 [1:0];
    logic [DATA_WIDTH-1:0] bf2fifo3 [1:0];

    // Permutation
    logic [DATA_WIDTH-1:0] bf2per0 [1:0];
    logic [DATA_WIDTH-1:0] bf2per1 [1:0];
    logic [DATA_WIDTH-1:0] bf2per2 [1:0];
    logic [DATA_WIDTH-1:0] bf2per3 [1:0];
    // Assignment of outputs
    always_comb begin

        unique case (STAGE)
            0: begin
                bf2sw0 = bf2per0;
                bf2fifo1 = bf2per1;
                bf2sw2 = bf2per2;
                bf2fifo3 = bf2per3;
            end
            1: begin
                bf2sw0 = bf2per0;
                bf2fifo1 = bf2per2;
                bf2sw2 = bf2per1;
                bf2fifo3 = bf2per3;
            end
            2: begin
                bf2sw0 = bf2per0;
                bf2fifo1 = bf2per2;
                bf2sw2 = bf2per1;
                bf2fifo3 = bf2per3;
            end
            default: begin
                bf2sw0 = bf2per0;
                bf2fifo1 = bf2per1;
                bf2sw2 = bf2per2;
                bf2fifo3 = bf2per3;
            end
        endcase

    end

    generate
        for (genvar i=0; i<2; ++i) begin
        
            // Cooley-Tukey Butterfly for NTT
            prim_ntt_r4ctbfu #(
                .DATA_WIDTH(DATA_WIDTH),
                .REDUCTION(REDUCTION),
                .LOG_R(LOG_R),
                .W4(W4),
                .QINT(QINT),
                .QDASH(QDASH),
                .DELAY_MULT(DELAY_MULT),
                .DELAY_CONST_MULT(DELAY_CONST_MULT)
            ) U_CTBF_0 (
                .clk_i(clk_i),
                .op0_i(data0_q[i]),
                .op1_i(data1_q[i]),
                .op2_i(data2_q[i]),
                .op3_i(data3_q[i]),
                .twiddle0_i(twiddle0_i[i]),
                .twiddle1_i(twiddle1_i[i]),
                .twiddle2_i(twiddle2_i[i]),
                .twiddle3_i(twiddle3_i[i]),
                .res0_o(bf2per0[i]),
                .res1_o(bf2per1[i]),
                .res2_o(bf2per2[i]),
                .res3_o(bf2per3[i])
            );

        end
    endgenerate

    logic [DATA_WIDTH-1:0] fifo2sw1 [1:0];

    logic [DATA_WIDTH-1:0] fifo2sw3 [1:0];
    logic rd_en_fifo0_1;

    logic rd_en_fifo0_3;

    logic wr_en_fifo0;

    // Shift register to delay valid signal to write to FIFOs before switch
    logic [DELAY_BF-1:0] dataval_shreg;
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            dataval_shreg <= 0;
        end else begin
            dataval_shreg <= {dataval_shreg[$left(dataval_shreg)-1:0], data_valid_q};
        end
    end
    // After data is at output of BFU it is written to FIFOs
    assign wr_en_fifo0 = dataval_shreg[$left(dataval_shreg)];

    for (genvar i=0; i<2; ++i) begin

        fifo_wrapper #(
            .DATA_WIDTH(DATA_WIDTH),
            .FIFO_DEPTH(FIFO_DEPTH_0_1),
            .FIFO_TYPE(FIFO_TYPE)
        ) U_FIFO_0_1 (
            .clk_i(clk_i),
            .rst_i(rst_i),
            .data_i(bf2fifo1[i]),
            .data_o(fifo2sw1[i]),    
            .wr_en_fifo_i(wr_en_fifo0),
            .rd_en_fifo_i(rd_en_fifo0_1)
        );

        fifo_wrapper #(
            .DATA_WIDTH(DATA_WIDTH),
            .FIFO_DEPTH(FIFO_DEPTH_0_3),
            .FIFO_TYPE(FIFO_TYPE)
        ) U_FIFO_0_3 (
            .clk_i(clk_i),
            .rst_i(rst_i),
            .data_i(bf2fifo3[i]),
            .data_o(fifo2sw3[i]),    
            .wr_en_fifo_i(wr_en_fifo0),
            .rd_en_fifo_i(rd_en_fifo0_3)
        );    

    end


    // Switch logic
    logic sw_sel;
    logic sw_cnt_en;
    logic [$clog2(N/8)-1:0] sw_cnt;

    // Count samples for switch control
    assign sw_cnt_en = dataval_shreg[$left(dataval_shreg)] | dataval2out;
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            sw_cnt <= 0;
        end else if (sw_cnt_en) begin
            sw_cnt ++;
        end else begin
            sw_cnt <= 0;
        end
    end

    assign sw_sel = sw_cnt[$left(sw_cnt)];

    // Read twiddle factors from dedicated memory
    // ToDo: Check for other stages and investiagte On-The-Fly Computation
    // Count samples for switch control
    logic twiddle_cnt_en;
    logic [$clog2(N/8)-1:0] twiddle_cnt;
    assign twiddle_cnt_en = data_valid_i;
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
        end else if($left(twiddle_cnt)<(2*STAGE+1)) begin
            assign twiddle_raddr_o = '0;
        end else begin
            assign twiddle_raddr_o = twiddle_cnt[$left(twiddle_cnt):$left(twiddle_cnt)-2*STAGE+1];
        end
    endgenerate

    // Shift register to delay rd_en_fifo0_1
    generate 
        if (FIFO_DEPTH_0_1 > 1) begin
            logic [FIFO_DEPTH_0_1-1:0] rd_en_fifo0_1_shreg;
            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    rd_en_fifo0_1_shreg <= 0;
                end else begin
                    rd_en_fifo0_1_shreg <= {rd_en_fifo0_1_shreg[$left(rd_en_fifo0_1_shreg)-1:0], dataval_shreg[$left(dataval_shreg)]};
                end
            end
            assign rd_en_fifo0_1 = rd_en_fifo0_1_shreg[$left(rd_en_fifo0_1_shreg)];

        end else begin

            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    rd_en_fifo0_1 <= 0;
                end else begin
                    rd_en_fifo0_1 <= dataval_shreg[$left(dataval_shreg)];
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
                    rd_en_fifo0_3_shreg <= {rd_en_fifo0_3_shreg[$left(rd_en_fifo0_3_shreg)-1:0], dataval_shreg[$left(dataval_shreg)]};
                end
            end
            assign rd_en_fifo0_3 = rd_en_fifo0_3_shreg[$left(rd_en_fifo0_3_shreg)];

        end else begin

            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    rd_en_fifo0_3 <= 0;
                end else begin
                    rd_en_fifo0_3 <= dataval_shreg[$left(dataval_shreg)];
                end
            end
           
        end
        
    endgenerate

    // Switch mux for reordering data
    logic [DATA_WIDTH-1:0] sw2fifo0 [1:0];
    logic sw2fifo_wen_fifo_0;

    logic [DATA_WIDTH-1:0] sw2out1 [1:0];
    logic sw2out1_valid;

    logic [DATA_WIDTH-1:0] sw2fifo2 [1:0];
    logic sw2fifo_wen_fifo_2;

    logic [DATA_WIDTH-1:0] sw2out3 [1:0];
    logic sw2out3_valid;

    always_comb begin
        case (sw_sel)
            1'b0: begin
                sw2fifo0 = bf2sw0;
                sw2out1 = fifo2sw1;
                sw2fifo2 = bf2sw2;
                sw2out3 = fifo2sw3;

                sw2fifo_wen_fifo_0 = dataval_shreg[$left(dataval_shreg)];
                sw2out1_valid = rd_en_fifo0_1;
                sw2fifo_wen_fifo_2 = dataval_shreg[$left(dataval_shreg)];
                sw2out3_valid = rd_en_fifo0_1;
            end 

            1'b1: begin
                sw2fifo0 = fifo2sw1;
                sw2out1 = bf2sw0;
                sw2fifo2 = fifo2sw3;
                sw2out3 = bf2sw2;

                sw2fifo_wen_fifo_0 = rd_en_fifo0_1;
                sw2out1_valid = dataval_shreg[$left(dataval_shreg)];
                sw2fifo_wen_fifo_2 = rd_en_fifo0_1;
                sw2out3_valid = dataval_shreg[$left(dataval_shreg)];
            end 

            default: begin
                sw2fifo0 = bf2sw0;
                sw2out1 = fifo2sw1;
                sw2fifo2 = bf2sw2;
                sw2out3 = fifo2sw3;

                sw2fifo_wen_fifo_0 = dataval_shreg[$left(dataval_shreg)];
                sw2out1_valid = rd_en_fifo0_1;
                sw2fifo_wen_fifo_2 = dataval_shreg[$left(dataval_shreg)];
                sw2out3_valid = rd_en_fifo0_1;
            end
        endcase
    end

    logic rd_en_fifo1_0;
    logic rd_en_fifo1_1;
    logic rd_en_fifo1_2;

    logic [DATA_WIDTH-1:0] fifo2out0 [1:0];
    logic [DATA_WIDTH-1:0] fifo2out2 [1:0];

    for (genvar i=0; i<2; ++i) begin
        fifo_wrapper #(
            .DATA_WIDTH(DATA_WIDTH),
            .FIFO_DEPTH(FIFO_DEPTH_1_0),
            .FIFO_TYPE(FIFO_TYPE)
        ) U_FIFO_1_0 (
            .clk_i(clk_i),
            .rst_i(rst_i),
            .data_i(sw2fifo0[i]),
            .data_o(fifo2out0[i]),    
            .wr_en_fifo_i(sw2fifo_wen_fifo_0),
            .rd_en_fifo_i(rd_en_fifo1_0)
        );


        fifo_wrapper #(
            .DATA_WIDTH(DATA_WIDTH),
            .FIFO_DEPTH(FIFO_DEPTH_1_2),
            .FIFO_TYPE(FIFO_TYPE)
        ) U_FIFO_1_2 (
            .clk_i(clk_i),
            .rst_i(rst_i),
            .data_i(sw2fifo2[i]),
            .data_o(fifo2out2[i]),    
            .wr_en_fifo_i(sw2fifo_wen_fifo_2),
            .rd_en_fifo_i(rd_en_fifo1_0)
        );        
    end



    // Shift register to delay rd_en_fifo0_0
    generate 
        if (FIFO_DEPTH_1_0 > 1) begin
            logic [FIFO_DEPTH_1_0-1:0] rd_en_fifo1_0_shreg;
            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    rd_en_fifo1_0_shreg <= 0;
                end else begin
                    rd_en_fifo1_0_shreg <= {rd_en_fifo1_0_shreg[$left(rd_en_fifo1_0_shreg)-1:0], dataval_shreg[$left(dataval_shreg)]};
                end
            end
            assign rd_en_fifo1_0 = rd_en_fifo1_0_shreg[$left(rd_en_fifo1_0_shreg)];

        end else begin

            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    rd_en_fifo1_0 <= 0;
                end else begin
                    rd_en_fifo1_0 <= dataval_shreg[$left(dataval_shreg)];
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
                    rd_en_fifo1_2_shreg <= {rd_en_fifo1_2_shreg[$left(rd_en_fifo1_2_shreg)-1:0], dataval_shreg[$left(dataval_shreg)]};
                end
            end
            assign rd_en_fifo1_2 = rd_en_fifo1_2_shreg[$left(rd_en_fifo1_2_shreg)];

        end else begin

            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    rd_en_fifo1_2 <= 0;
                end else begin
                    rd_en_fifo1_2 <= dataval_shreg[$left(dataval_shreg)];
                end
            end
           
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
    assign data0_o[0] = fifo2out0[0];
    assign data1_o[0] = sw2out1[0];
    assign data2_o[0] = fifo2out0[1];
    assign data3_o[0] = sw2out1[1];

    assign data0_o[1] = fifo2out2[0];
    assign data1_o[1] = sw2out3[0];
    assign data2_o[1] = fifo2out2[1];
    assign data3_o[1] = sw2out3[1];

    assign data_valid_o = dataval2out;

endmodule