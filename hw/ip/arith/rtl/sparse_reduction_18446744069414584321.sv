// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`timescale 1ns/10ps

module sparse_reduction_18446744069414584321
#(
    parameter int unsigned DATA_WIDTH = 64,
    parameter longint QINT = 64'd18446744069414584321
)
(
    input   logic                       clk_i,
    input   logic   [2*DATA_WIDTH-1:0]  op_i,
    output  logic   [DATA_WIDTH-1:0]    res_o
);
    logic [2*DATA_WIDTH-1:0] c;
    assign c = op_i;

    logic [DATA_WIDTH-1:0] clsb;
    logic [DATA_WIDTH/2-1:0] cmsb,cisb;
    assign clsb = c[63:0];
    assign cmsb = c[127:96];
    assign cisb = c[95:64];

    logic [64:0] pos_d, pos_q;
    logic [32:0] neg_d, neg_q;

    assign pos_d = clsb + (cisb << 32);
    assign neg_d = cmsb + cisb;

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
