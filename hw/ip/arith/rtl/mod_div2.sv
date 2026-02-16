// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`timescale 1ns/10ps

module mod_div2
#(
    parameter int unsigned DATA_WIDTH = 64,
    parameter longint QINT = 134215681
)
(
    input   logic   [DATA_WIDTH-1:0]    op_i,
    output  logic   [DATA_WIDTH-1:0]    res_o
);
    logic   [DATA_WIDTH-1:0]    q;
    logic   [DATA_WIDTH-2:0]    qdiv2;
    logic   [DATA_WIDTH-2:0]    op2add;
    logic   [DATA_WIDTH-2:0]    and2add;
    logic   [DATA_WIDTH-1:0]    add2out;

    assign q = QINT;

    always_comb
    begin    
        qdiv2 = q[$left(q):1]; // (q+1)/2
        op2add = op_i[$left(op_i):1]; // x>>1
        and2add = qdiv2 & {($left(qdiv2)+1){op_i[0]}}; // if x is odd, add (q+1)/2
        add2out = and2add + op2add;
    end

    assign res_o = add2out;
    
endmodule
