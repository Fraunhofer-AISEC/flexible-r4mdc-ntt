// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

import arith_pkg::*;

module sparse_multiplier
#(
    parameter int unsigned DATA_WIDTH = 27, // Only 64-bit supported for now 
    parameter longint QINT
)
(
    input   logic                       clk_i,
    input   logic   [DATA_WIDTH-1:0]    op0_i,
    input   logic   [DATA_WIDTH-1:0]    op1_i,

    output  logic   [DATA_WIDTH-1:0]    res_o   
);
         
    logic [2*DATA_WIDTH-1:0] c;

    // Parallel multipliers to multiply different chunks of input data
    multiplier#(
        .DATA_WIDTH(DATA_WIDTH),
        .DSP_IMPL(arith_pkg::GLOBAL_DSP_IMPL)
    ) U_MULT (
        .clk_i(clk_i),
        .op0_i(op0_i),
        .op1_i(op1_i),
        .res_o(c)
    );

    sparse_reduction #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) U_RED (
        .clk_i(clk_i),
        .op_i(c),
        .res_o(res_o)
    );

endmodule
