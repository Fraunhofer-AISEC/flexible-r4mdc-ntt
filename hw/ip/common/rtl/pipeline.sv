// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0   
   
`timescale 1ns/10ps

module pipeline
#(
    parameter int unsigned DATA_WIDTH = 32,
    parameter int unsigned STAGES = 7,
    parameter bit EN = 0,
    parameter bit RST = 0
)
(
    input   logic                       clk_i,
    input   logic [DATA_WIDTH-1:0]      data_i,
    input   logic                       en_i,
    input   logic                       rst_i,
    output  logic [DATA_WIDTH-1:0]      data_o 
);

    logic [DATA_WIDTH-1:0] data_d, data_q [0:STAGES-1];

    generate;
        if (EN && RST) begin
            always_ff @(posedge clk_i) begin
              if (rst_i) begin
                for (int i=0; i<STAGES; ++i) begin
                    data_q[i] <= '0; 
                end
              end else if (en_i) begin
                for (int i=0; i<STAGES; ++i) begin
                    data_q[i] <= data_d[i]; 
                end
              end
            end
        end else if (RST) begin
            always_ff @(posedge clk_i) begin
              if (rst_i) begin
                for (int i=0; i<STAGES; ++i) begin
                    data_q[i] <= '0; 
                end
              end else begin
                for (int i=0; i<STAGES; ++i) begin
                    data_q[i] <= data_d[i]; 
                end
              end
            end
        end else if (EN) begin
            always_ff @(posedge clk_i) begin
               if (en_i) begin
                  for (int i=0; i<STAGES; ++i) begin
                      data_q[i] <= data_d[i]; 
                  end
              end
            end
        end else begin
            always_ff @(posedge clk_i) begin
              for (int i=0; i<STAGES; ++i) begin
                  data_q[i] <= data_d[i]; 
              end
            end
        end
    endgenerate
    
    always_comb begin
      for (int i=1; i<STAGES; ++i) begin
        data_d[i] = data_q[i-1];
      end
      data_d[0] = data_i;
    end

    assign data_o = data_q[STAGE-1];
    
endmodule