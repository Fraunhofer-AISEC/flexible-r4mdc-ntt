// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`timescale 1ns/10ps

module mod_subtractor
#(
    parameter int unsigned DATA_WIDTH = 32,
    parameter longint QINT = 134215681
)
(
    input   logic                       clk_i,
    input   logic   [DATA_WIDTH-1:0]    op0_i,
    input   logic   [DATA_WIDTH-1:0]    op1_i,
    output  logic   [DATA_WIDTH-1:0]    res_o
);

    logic   [DATA_WIDTH-1:0]  adds;
    logic   [DATA_WIDTH:0]    sub;
    logic   [DATA_WIDTH:0]    sub_q;

    always_ff @(posedge clk_i) begin
        // Pipeline stage 1
        sub <= (op0_i - op1_i);
        // Pipeline stage 2
        adds <= sub + QINT;
        sub_q <= sub;
        // Pipeline stage 3
        res_o <= (sub_q[$left(sub_q)]) ? adds : sub_q;
    end


endmodule
