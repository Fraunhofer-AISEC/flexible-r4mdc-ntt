// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module const_multiplier
#(
    parameter int unsigned DATA_WIDTH = 64,
    parameter longint QINT = 64'd18446744069414584321
)
(
    input   logic                       clk_i,
    input   logic   [DATA_WIDTH-1:0]    op_i,
    output  logic   [DATA_WIDTH-1:0]    res_o   
);

generate
  case (QINT)
  
    64'd18446744069414584321 : begin
      const_multiplier_281474976710656_18446744069414584321 #(
        .DATA_WIDTH(DATA_WIDTH)
      ) u_const_multiplier(
        .clk_i(clk_i),
        .op_i(op_i),
        .res_o(res_o)
      );
    end
    'd134215681 : begin
      const_multiplier_37361560_134215681 #(
        .DATA_WIDTH(DATA_WIDTH)
      ) u_const_multiplier(
        .clk_i(clk_i),
        .op_i(op_i),
        .res_o(res_o)
      );
    end
    'd33550337 : begin
      const_multiplier_12759331_33550337 #(
        .DATA_WIDTH(DATA_WIDTH)
      ) u_const_multiplier(
        .clk_i(clk_i),
        .op_i(op_i),
        .res_o(res_o)
      );
    end
    'd268369921 : begin
      const_multiplier_75074761_268369921 #(
        .DATA_WIDTH(DATA_WIDTH)
      ) u_const_multiplier(
        .clk_i(clk_i),
        .op_i(op_i),
        .res_o(res_o)
      );
    end
    default : begin
      const_multiplier_75074761_268369921 #(
        .DATA_WIDTH(DATA_WIDTH)
      ) u_const_multiplier(
        .clk_i(clk_i),
        .op_i(op_i),
        .res_o(res_o)
      );
    end
  endcase
endgenerate

endmodule