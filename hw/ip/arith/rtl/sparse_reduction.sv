// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`timescale 1ns/10ps

module sparse_reduction
#(
    parameter int unsigned DATA_WIDTH = 27,
    parameter longint QINT = 64'd134215681
)
(
    input   logic                       clk_i,
    input   logic   [2*DATA_WIDTH-1:0]  op_i,
    output  logic   [DATA_WIDTH-1:0]    res_o
);

generate
  case (QINT)
  
    64'd134215681 : begin
      sparse_reduction_134215681 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
      ) u_sparse_reduction(
        .clk_i(clk_i),
        .op_i(op_i),
        .res_o(res_o)
      );
    end
    64'd33550337 : begin
      sparse_reduction_33550337 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
      ) u_sparse_reduction(
        .clk_i(clk_i),
        .op_i(op_i),
        .res_o(res_o)
      );
    end
    64'd268369921 : begin
      sparse_reduction_268369921 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
      ) u_sparse_reduction(
        .clk_i(clk_i),
        .op_i(op_i),
        .res_o(res_o)
      );
    end
    64'd18446744069414584321 : begin
      sparse_reduction_18446744069414584321 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
      ) u_sparse_reduction(
        .clk_i(clk_i),
        .op_i(op_i),
        .res_o(res_o)
      );
    end
    default : begin

      sparse_reduction_268369921 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
      ) u_sparse_reduction(
        .clk_i(clk_i),
        .op_i(op_i),
        .res_o(res_o)
      );

    end
  endcase
endgenerate
    
endmodule
