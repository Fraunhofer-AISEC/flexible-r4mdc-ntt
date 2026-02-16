// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`timescale 1ns/10ps

module sparse_reduction_268369921
#(
    parameter int unsigned DATA_WIDTH = 28,
    parameter longint QINT = 268369921
)
(
    input   logic                       clk_i,
    input   logic   [2*DATA_WIDTH-1:0]  op_i,
    output  logic   [DATA_WIDTH-1:0]    res_o
);
    logic [27:0] c0;
    logic [27:0] c1;
    logic [11:0] c2; 
    logic [15:0] c3;
    logic [11:0] c4;
    logic  [3:0] c5;
    
    assign c0 = op_i[27:0];
    assign c1 = op_i[55:28];
    assign c2 = op_i[39:28];
    assign c3 = op_i[55:40];
    assign c4 = op_i[51:40];
    assign c5 = op_i[55:52];


    logic [29:0] c6;
    logic [29:0] c6_q;
    logic [27:0] c0_d;
    logic [27:0] c0_q2d;
    logic [27:0] c0_q;
    logic [27:0] c1_d;
    logic [27:0] c1_q2d;
    logic [27:0] c1_q;
    logic [15:0] c3_d;
    logic [15:0] c3_q2d;
    logic [15:0] c3_q;
    logic [3:0] c5_d;
    logic [3:0] c5_q2d;
    logic [3:0] c5_q;    

    assign c6 = c5 + c4 + c2;

    // Pipeline Stage 1
    always_ff @(posedge clk_i) begin
      c6_q <= c6;
      c0_q2d <= c0;
      c1_q2d <= c1;
      c3_q2d <= c3;
      c5_q2d <= c5;
    end

    logic [11:0] c7;
    logic  [1:0] c8;
    assign c7 = c6_q[11:0];
    assign c8 = c6_q[13:12];

    logic [12:0] e;
    assign e = c8 + c7;

    logic [28:0] f;
    logic [28:0] f_q;
    logic [13:0] e_pos;
    logic [2:0] e_neg;
    always_ff @(posedge clk_i) begin
        e_pos <= e[12] + e[11:0];
        e_neg <= e[12] + c8;
        c0_d <= c0_q2d;
        c1_d <= c1_q2d;
        c3_d <= c3_q2d;
        c5_d <= c5_q2d;
    end

    assign f = (e_pos << 16) - (e_neg);

    // Pipeline Stage 2
    always_ff @(posedge clk_i) begin
      f_q <= f;
      c0_q <= c0_d;
      c1_q <= c1_d;
      c3_q <= c3_d;
      c5_q <= c5_d;
    end

    logic [28:0] y;
    assign y = f_q + c0_q;

    logic [DATA_WIDTH+1:0] pos_d, pos_q;
    logic [DATA_WIDTH:0] neg_d, neg_q;

    assign pos_d =  y;
    assign neg_d = c5_q + c3_q + c1_q;

    logic [DATA_WIDTH:0] sub_pos;
    assign sub_pos = pos_d - QINT;

    // Pipeline Stage 1
    always_ff @(posedge clk_i) begin
        pos_q <= (~(~pos_d[$left(pos_d)] & sub_pos[$left(sub_pos)])) ? sub_pos : pos_d;
        neg_q <= neg_d;
    end

    logic [DATA_WIDTH+1:0] z_d;
    logic [DATA_WIDTH:0] z_q;

    assign z_d = pos_q-neg_q;

    logic mux_sel;

    // Pipeline Stage 2
    always_ff @(posedge clk_i) begin
        z_q <= z_d[DATA_WIDTH:0];
        mux_sel <= z_d[DATA_WIDTH+1];
    end
    logic [DATA_WIDTH-1:0] res_d, res_q;
    logic [DATA_WIDTH:0] sub;
    assign sub =  z_q-QINT;
    assign res_d = (mux_sel) ? z_q+QINT : z_q;

    // Pipeline Stage 3
    always_ff @(posedge clk_i) begin
        res_q <= res_d;
    end

    assign res_o = res_q;  

endmodule
