// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`timescale 1ns/10ps

module sparse_reduction_33550337
#(
    parameter int unsigned DATA_WIDTH = 25,
    parameter longint QINT = 33550337
)
(
    input   logic                       clk_i,
    input   logic   [2*DATA_WIDTH-1:0]  op_i,
    output  logic   [DATA_WIDTH-1:0]    res_o
);
    logic [2*DATA_WIDTH-1:0] c;
    assign c = op_i;

    logic [DATA_WIDTH-1:0] c0;
    logic [DATA_WIDTH-1:0] c1;

    assign c0 = c[DATA_WIDTH-1:0];
    assign c1 = c[2*DATA_WIDTH-1:DATA_WIDTH];

    logic [12:0] c2;
    logic [11:0] c3;

    assign c2 = c1[12:0];
    assign c3 = c1[24:13];

    logic [DATA_WIDTH+1:0] pos_d, pos_q;
    logic [DATA_WIDTH:0] neg_d, neg_q;

    assign pos_d = (c3 << 12) + (c2 << 12) + c0;
    assign neg_d = c1 + c3;

    // Pipeline Stage 1
    always_ff @(posedge clk_i) begin
        pos_q <= pos_d;
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
    assign res_d = (mux_sel) ? (z_q+QINT) : (~(sub[DATA_WIDTH]) ? sub[DATA_WIDTH-1:0]: z_q);

    // Pipeline Stage 3
    always_ff @(posedge clk_i) begin
        res_q <= res_d;
    end

    assign res_o = res_q;  

endmodule
