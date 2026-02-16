// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0


module mod_multiplier
#(
    parameter int unsigned DATA_WIDTH = 27,
   	parameter longint QINT = 134215681,
    parameter longint QDASH = 130021375,
    parameter longint QMU = 0,
    parameter int unsigned LOG_R = 32,
    parameter int unsigned K = 54,
    parameter REDUCTION = "SPARSE"
)
(
    input   logic                       clk_i,
    input   logic   [DATA_WIDTH-1:0]    op0_i,
    input   logic   [DATA_WIDTH-1:0]    op1_i,
    output  logic   [DATA_WIDTH-1:0]    res_o   
);

generate;
    case (REDUCTION)
  
    "SPARSE" : begin
      sparse_multiplier #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
      ) U_MOD_MUL (
        .clk_i(clk_i),
        .op0_i(op0_i),
        .op1_i(op1_i),
        .res_o(res_o)
      );
    end
    default: begin
      sparse_multiplier #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
      ) U_MOD_MUL (
        .clk_i(clk_i),
        .op0_i(op0_i),
        .op1_i(op1_i),
        .res_o(res_o)
      );
    end
    endcase
endgenerate

endmodule
