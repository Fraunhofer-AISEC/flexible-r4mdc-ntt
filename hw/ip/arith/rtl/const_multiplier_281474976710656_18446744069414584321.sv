// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module const_multiplier_281474976710656_18446744069414584321
#(
    parameter int unsigned DATA_WIDTH = 64
)
(
    input   logic                       clk_i,
    input   logic   [DATA_WIDTH-1:0]    op_i,
    output  logic   [DATA_WIDTH-1:0]    res_o   
);


  // Compute final result
  //logic [2*DATA_WIDTH] res_csa_d;
  logic [2*DATA_WIDTH-1:0] res_csa_q;

  // Register stage after CSA tree
  always @(posedge clk_i) begin
    res_csa_q <= op_i << 48;
  end   

  sparse_reduction_18446744069414584321
  #(
    .DATA_WIDTH(DATA_WIDTH),
    .QINT(64'd18446744069414584321)
  ) u_red (
    .clk_i(clk_i),
    .op_i(res_csa_q),
    .res_o(res_o)   
  );
  
endmodule
