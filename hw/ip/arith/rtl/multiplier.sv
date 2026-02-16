// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

import arith_pkg::*;

module multiplier
#(
    parameter int unsigned DATA_WIDTH = 32,
    parameter dsp_implementation_t DSP_IMPL = XILINX_ULTRASCALE_UNSIGNED
)
(
    input   logic                       clk_i,
    input   logic   [DATA_WIDTH-1:0]    op0_i,
    input   logic   [DATA_WIDTH-1:0]    op1_i,
    output  logic   [2*DATA_WIDTH-1:0]  res_o   
);
    localparam DSP_W = DSP_IMPL.DspWidth;
    localparam DSP_H = DSP_IMPL.DspHeight;
    
    logic [DATA_WIDTH-1:0] op0_q;
    logic [DATA_WIDTH-1:0] op1_q;

    // Input Register
    always_ff @(posedge clk_i) begin
        op0_q <= op0_i;
        op1_q <= op1_i;
    end

    // Splitt op0_q into NOF_DSP_W chunks of width DSP_W
    localparam NOF_DSP_W = $rtoi($ceil($itor(DATA_WIDTH)/$itor(DSP_W)));
    logic [DSP_W-1:0] in2dsp0 [NOF_DSP_W-1:0];

    generate 
        for (genvar i=0; i<NOF_DSP_W-1; ++i) begin 
            assign in2dsp0[i] = op0_q[(DSP_W*(i+1))-1:(DSP_W*i)];
        end
        assign in2dsp0[NOF_DSP_W-1] = op0_q[$left(op0_q):(DSP_W*(NOF_DSP_W-1))];
    endgenerate


    // Splitt op1_q into NOF_DSP_H chunks of width DSP_H
    localparam NOF_DSP_H = $rtoi($ceil($itor(DATA_WIDTH)/$itor(DSP_H)));
    logic [DSP_H-1:0] in2dsp1 [NOF_DSP_H-1:0];

    generate    
        for (genvar i=0; i<NOF_DSP_H-1; ++i) begin 
            assign in2dsp1[i] = op1_q[(DSP_H*(i+1))-1:(DSP_H*i)];
        end
        assign in2dsp1[NOF_DSP_H-1] = op1_q[$left(op0_q):(DSP_H*(NOF_DSP_H-1))];
    endgenerate


    // Partial Product Generation
    logic [DSP_W+DSP_H-1:0] dsp_mul [NOF_DSP_W*NOF_DSP_H-1:0];
    logic [2*DATA_WIDTH-1:0] mul2csa [NOF_DSP_W*NOF_DSP_H-1:0];

    generate
        for (genvar i=0; i<NOF_DSP_H; ++i) begin
            for (genvar j=0; j<NOF_DSP_W; ++j) begin
                always @(posedge clk_i) begin
                    dsp_mul[i*NOF_DSP_W + j] <= (in2dsp0[j] * in2dsp1[i]);
                end
                assign mul2csa[i*NOF_DSP_W + j]  = dsp_mul[i*NOF_DSP_W + j] << (DSP_W*j + DSP_H*i);
            end
        end
    endgenerate

    // Partial Product Combination

    localparam NOF_PARTIALPROD = NOF_DSP_W*NOF_DSP_H;
    localparam NOF_CSASTAGES = NOF_PARTIALPROD-2;

    logic [2*DATA_WIDTH-1:0] carry [NOF_CSASTAGES-1:0];
    logic [2*DATA_WIDTH-1:0] sum [NOF_CSASTAGES-1:0];


    // Build CSA tree for addition of (NOF_DSP_W x NOF_DSP_H) operands
    localparam USE_CSA = "FALSE";
    logic [2*DATA_WIDTH-1:0] res_d;

    generate;

    if (USE_CSA == "TRUE") begin
        for (genvar i=0; i<NOF_CSASTAGES; ++i) begin
            if (i == 0) begin : g_inital_stage
                csa #(
                    .DATA_WIDTH(2*DATA_WIDTH)
                ) U_CSA_INIT (
                    .op0_i(mul2csa[0]),
                    .op1_i(mul2csa[1]),
                    .op2_i(mul2csa[2]),
                    .sum_o(sum[i]),
                    .carry_o(carry[i])
                );
            end : g_inital_stage else begin : g_intermediate_stage
                csa #(
                    .DATA_WIDTH(2*DATA_WIDTH)
                ) U_CSA_STAGE (
                    .op0_i(sum[i-1]),
                    .op1_i(carry[i-1]),
                    .op2_i(mul2csa[2+i]),
                    .sum_o(sum[i]),
                    .carry_o(carry[i])
                );        
            end : g_intermediate_stage
        end
        // Compute final result
        if (NOF_CSASTAGES == 0) begin
            assign res_d = mul2csa[0] + mul2csa[1];
        end else begin
            assign res_d = sum[$left(sum)] + carry[$left(carry)];
        end
    end else begin
        // Registered adder tree to improve timing
        if (NOF_PARTIALPROD == 4) begin
            logic [2*DATA_WIDTH-1:0] add_tree0;
            logic [2*DATA_WIDTH-1:0] add_tree1;
            always_ff @(posedge clk_i) begin
              add_tree0 <= mul2csa[0] + mul2csa[1];
              add_tree1 <= mul2csa[2] + mul2csa[3];
            end
            assign res_d = add_tree0 + add_tree1;

        end else if (NOF_PARTIALPROD == 5) begin
            logic [2*DATA_WIDTH-1:0] add_tree0;
            logic [2*DATA_WIDTH-1:0] add_tree1;
            always_ff @(posedge clk_i) begin
              add_tree0 <= mul2csa[0] + mul2csa[1];
              add_tree1 <= mul2csa[2] + mul2csa[3] + mul2csa[4];
            end
            assign res_d = add_tree0 + add_tree1;

        end else if (NOF_PARTIALPROD == 6) begin
            logic [2*DATA_WIDTH-1:0] add_tree0;
            logic [2*DATA_WIDTH-1:0] add_tree1;
            always_ff @(posedge clk_i) begin
              add_tree0 <= mul2csa[0] + mul2csa[1] + mul2csa[2];
              add_tree1 <= mul2csa[3] + mul2csa[4] + mul2csa[5];
            end
            assign res_d = add_tree0 + add_tree1;
            
        end else if (NOF_PARTIALPROD == 7) begin
            logic [2*DATA_WIDTH-1:0] add_tree0;
            logic [2*DATA_WIDTH-1:0] add_tree1;
            logic [2*DATA_WIDTH-1:0] add_tree2;
            always_ff @(posedge clk_i) begin
              add_tree0 <= mul2csa[0] + mul2csa[1];
              add_tree1 <= mul2csa[2] + mul2csa[3];
              add_tree2 <= mul2csa[4] + mul2csa[5] + mul2csa[6];
            end
            assign res_d = add_tree0 + add_tree1 + add_tree2;
            
        end else if (NOF_PARTIALPROD == 8) begin
            logic [2*DATA_WIDTH-1:0] add_tree0;
            logic [2*DATA_WIDTH-1:0] add_tree1;
            logic [2*DATA_WIDTH-1:0] add_tree2;
            always_ff @(posedge clk_i) begin
              add_tree0 <= mul2csa[0] + mul2csa[1] + mul2csa[2];
              add_tree1 <= mul2csa[3] + mul2csa[4];
              add_tree2 <= mul2csa[5] + mul2csa[6] + mul2csa[7];
            end
            assign res_d = add_tree0 + add_tree1 + add_tree2;
            
        end else if (NOF_PARTIALPROD == 9) begin
            logic [2*DATA_WIDTH-1:0] add_tree0;
            logic [2*DATA_WIDTH-1:0] add_tree1;
            logic [2*DATA_WIDTH-1:0] add_tree2;
            always_ff @(posedge clk_i) begin
              add_tree0 <= mul2csa[0] + mul2csa[1] + mul2csa[2];
              add_tree1 <= mul2csa[3] + mul2csa[4] + mul2csa[8];
              add_tree2 <= mul2csa[5] + mul2csa[6] + mul2csa[7];
            end
            assign res_d = add_tree0 + add_tree1 + add_tree2;

        end else if (NOF_PARTIALPROD == 10) begin
            logic [2*DATA_WIDTH-1:0] add_tree0;
            logic [2*DATA_WIDTH-1:0] add_tree1;
            logic [2*DATA_WIDTH-1:0] add_tree2;
            logic [2*DATA_WIDTH-1:0] add_tree3;
            logic [2*DATA_WIDTH-1:0] add_tree4;
            logic [2*DATA_WIDTH-1:0] add_tree5;
            always_ff @(posedge clk_i) begin
              add_tree0 <= mul2csa[0] + mul2csa[1] + mul2csa[8];
              add_tree1 <= mul2csa[2] + mul2csa[3] + mul2csa[9];
              add_tree2 <= mul2csa[4] + mul2csa[5];
              add_tree3 <= mul2csa[6] + mul2csa[7];
              add_tree4 <= add_tree0 + add_tree1;
              add_tree5 <= add_tree2 + add_tree3;
            end
            assign res_d = add_tree4 + add_tree5;

        end else if (NOF_PARTIALPROD == 11) begin
            logic [2*DATA_WIDTH-1:0] add_tree0;
            logic [2*DATA_WIDTH-1:0] add_tree1;
            logic [2*DATA_WIDTH-1:0] add_tree2;
            logic [2*DATA_WIDTH-1:0] add_tree3;
            logic [2*DATA_WIDTH-1:0] add_tree4;
            logic [2*DATA_WIDTH-1:0] add_tree5;
            always_ff @(posedge clk_i) begin
              add_tree0 <= mul2csa[0] + mul2csa[1] + mul2csa[8];
              add_tree1 <= mul2csa[2] + mul2csa[3] + mul2csa[9];
              add_tree2 <= mul2csa[4] + mul2csa[5] + mul2csa[10];
              add_tree3 <= mul2csa[6] + mul2csa[7];
              add_tree4 <= add_tree0 + add_tree1;
              add_tree5 <= add_tree2 + add_tree3;
            end
            assign res_d = add_tree4 + add_tree5;

        end else if (NOF_PARTIALPROD == 12) begin
            logic [2*DATA_WIDTH-1:0] add_tree0;
            logic [2*DATA_WIDTH-1:0] add_tree1;
            logic [2*DATA_WIDTH-1:0] add_tree2;
            logic [2*DATA_WIDTH-1:0] add_tree3;
            logic [2*DATA_WIDTH-1:0] add_tree4;
            logic [2*DATA_WIDTH-1:0] add_tree5;
            always_ff @(posedge clk_i) begin
              add_tree0 <= mul2csa[0] + mul2csa[1] + mul2csa[8];
              add_tree1 <= mul2csa[2] + mul2csa[3] + mul2csa[9];
              add_tree2 <= mul2csa[4] + mul2csa[5] + mul2csa[10];
              add_tree3 <= mul2csa[6] + mul2csa[7] + mul2csa[11];
              add_tree4 <= add_tree0 + add_tree1;
              add_tree5 <= add_tree2 + add_tree3;
            end
            assign res_d = add_tree4 + add_tree5;
        // For NOF_PARTIALPROD < 3 no pipeline registers required
        end else begin
            always_comb begin
              res_d = '0;
              for (int i=0; i<NOF_PARTIALPROD; ++i) begin
                res_d = res_d + mul2csa[i];
              end
            end
        end
    end
    endgenerate

    // Register stage after CSA tree
    logic [2*DATA_WIDTH-1:0] res_q;
    always @(posedge clk_i) begin
        res_q <= res_d;
    end   

    // Assignment of result to output port
    assign res_o = res_q;

endmodule