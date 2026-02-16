// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`timescale 1ns/10ps

module mod_adder
#(
    parameter int unsigned DATA_WIDTH = 64,
    parameter longint QINT = 134215681
)
(
    input   logic                       clk_i,
    input   logic   [DATA_WIDTH-1:0]    op0_i,
    input   logic   [DATA_WIDTH-1:0]    op1_i,
    output  logic   [DATA_WIDTH-1:0]    res_o
);

    logic   [DATA_WIDTH:0]    add;
    logic   [DATA_WIDTH:0]    add_q;
    logic   [DATA_WIDTH:0]    sub;

    always_ff @(posedge clk_i) begin
        // Pipeline stage 1
        add <= op0_i + op1_i;
        // Pipeline stage 2
        add_q <= add;
        sub <= add - QINT;
        // Pipeline stage 3
        res_o <= (~(~add_q[$left(add_q)] & sub[$left(sub)])) ? sub : add_q;
    end


endmodule
