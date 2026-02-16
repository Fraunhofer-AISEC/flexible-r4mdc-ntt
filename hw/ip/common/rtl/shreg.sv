// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0   
   
`timescale 1ns/10ps

module shreg
#(
    parameter int unsigned DATA_WIDTH = 32,
    parameter int unsigned SHREG_SIZE = 16
)
(
    input   logic                       clk_i,
    input   logic [DATA_WIDTH-1:0]      shreg_i,
    input   logic                       shreg_en_i,
    output  logic [DATA_WIDTH-1:0]      shreg_o 
);

    logic [DATA_WIDTH*SHREG_SIZE-1:0] shreg;

    generate;
    
    if (SHREG_SIZE > 1) begin : g_shreg
      always_ff @(posedge clk_i) begin
          if (shreg_en_i) begin
              shreg <= {shreg[$left(shreg)-DATA_WIDTH:0], shreg_i};
          end
      end
      assign shreg_o = shreg[$left(shreg):$left(shreg)-DATA_WIDTH+1];
    end : g_shreg else begin : g_reg
      always_ff @(posedge clk_i) begin
          if (shreg_en_i) begin
              shreg <= shreg_i;
          end
      end
      assign shreg_o = shreg;
    end : g_reg

    endgenerate
    
endmodule