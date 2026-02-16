// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0   
   
`timescale 1ns/10ps

module prim_ntt_twiddlerom
#(
    parameter int unsigned DATA_WIDTH = 32,
    parameter int unsigned DEPTH = 8,
    parameter memfile = "twiddle_stage_rom_0.mem"
)
(
    input   logic                       clk_i,
    input   logic   [$clog2(DEPTH)-1:0] raddr_i,
    output  logic   [DATA_WIDTH-1:0]    data_o
);

    logic [DATA_WIDTH-1:0] rom [0:DEPTH-1];

    // initialise ROM contents
    initial begin
        $readmemh(memfile,rom);
    end

    always_ff @ (posedge clk_i) begin
        data_o <= rom[raddr_i];
    end
    
endmodule