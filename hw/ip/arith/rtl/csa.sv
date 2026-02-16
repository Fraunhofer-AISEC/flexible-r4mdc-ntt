// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0


module csa
#(
    parameter int unsigned DATA_WIDTH = 32
)
(
    input   logic   [DATA_WIDTH-1:0]    op0_i,
    input   logic   [DATA_WIDTH-1:0]    op1_i,
    input   logic   [DATA_WIDTH-1:0]    op2_i,
    output  logic   [DATA_WIDTH-1:0]    sum_o,
    output  logic   [DATA_WIDTH-1:0]    carry_o
);

    logic [DATA_WIDTH:0] c;
    logic [DATA_WIDTH-1:0] s;


    always_comb begin
        c[0] = '0;
        for (int i=0; i<DATA_WIDTH; ++i) begin
            {c[i+1],s[i]} = op0_i[i] + op1_i[i] + op2_i[i];
        end

    end

    assign carry_o = c[DATA_WIDTH-1:0];
    assign sum_o = s;

endmodule