// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`timescale 1ns/10ps

module prim_ntt_r4gsbfu
#(
    parameter int unsigned DATA_WIDTH = 64,
    parameter int unsigned LOG_R = 28,
   	parameter longint QINT = 134215681,
    parameter longint QDASH = 130021375,
    parameter longint QMU = 0,
    parameter int unsigned K = 54,
    parameter REDUCTION = "SOLINA27", // Choose between "MONTGOMERY", "SOLINA27" and "SOLINA64"
    parameter int unsigned DELAY_MULT = 8,
    parameter int unsigned DELAY_CONST_MULT = 8,
    parameter longint W4 = 37361560
)
(
    input   logic                       clk_i,
    input   logic   [DATA_WIDTH-1:0]    op0_i,
    input   logic   [DATA_WIDTH-1:0]    op1_i,
    input   logic   [DATA_WIDTH-1:0]    op2_i,
    input   logic   [DATA_WIDTH-1:0]    op3_i,
    input   logic   [DATA_WIDTH-1:0]    twiddle0_i,
    input   logic   [DATA_WIDTH-1:0]    twiddle1_i,
    input   logic   [DATA_WIDTH-1:0]    twiddle2_i,
    input   logic   [DATA_WIDTH-1:0]    twiddle3_i,
    output  logic   [DATA_WIDTH-1:0]    res0_o,
    output  logic   [DATA_WIDTH-1:0]    res1_o,
    output  logic   [DATA_WIDTH-1:0]    res2_o,
    output  logic   [DATA_WIDTH-1:0]    res3_o
);

    logic [DATA_WIDTH-1:0] t0, t1, t2, t3;
    logic [DATA_WIDTH-1:0] t0_d, t1_d, t2_d, t3_d;
    logic [DATA_WIDTH-1:0] t0_q, t1_q, t2_q, t3_q;
    
    mod_adder #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) U_GS_ADDER_T0 (
        .clk_i(clk_i),
        .op0_i(op0_i),
        .op1_i(op2_i),
        .res_o(t0)
    );

    mod_subtractor #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) U_GS_SUBTRACTOR_T1 (
        .clk_i(clk_i),
        .op0_i(op2_i),
        .op1_i(op0_i),
        .res_o(t1)
    );

    mod_adder #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) U_GS_ADDER_T2 (
        .clk_i(clk_i),
        .op0_i(op1_i),
        .op1_i(op3_i),
        .res_o(t2)
    );

    mod_subtractor #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) U_GS_SUBTRACTOR_T3 (
        .clk_i(clk_i),
        .op0_i(op3_i),
        .op1_i(op1_i),
        .res_o(t3)
    );

    mod_div2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT+1)
    ) U_DIV2_T0 (
        .op_i(t0),
        .res_o(t0_d)
    );

    mod_div2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT+1)
    ) U_DIV2_T1 (
        .op_i(t1),
        .res_o(t1_d)
    );

    mod_div2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT+1)
    ) U_DIV2_T2 (
        .op_i(t2),
        .res_o(t2_d)
    );

    mod_div2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT+1)
    ) U_DIV2_T3 (
        .op_i(t3),
        .res_o(t3_d)
    );

    // Pipeline Register
    always_ff @(posedge clk_i) begin
        t0_q <= t0_d;
        t1_q <= t1_d;
        t2_q <= t2_d;
        t3_q <= t3_d;

        //twiddle
    end

    logic [DATA_WIDTH-1:0] t1w4;
    const_multiplier #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) U_MULTIPLIER_0 (
        .clk_i(clk_i),
        .op_i(t1_q),
        .res_o(t1w4)
    );

    logic [DATA_WIDTH-1:0] t0arith_d [DELAY_CONST_MULT-1:0];
    logic [DATA_WIDTH-1:0] t0arith_q [DELAY_CONST_MULT-1:0];

    logic [DATA_WIDTH-1:0] t3arith_d [DELAY_CONST_MULT-1:0];
    logic [DATA_WIDTH-1:0] t3arith_q [DELAY_CONST_MULT-1:0];

    logic [DATA_WIDTH-1:0] t2arith_d [DELAY_CONST_MULT-1:0];
    logic [DATA_WIDTH-1:0] t2arith_q [DELAY_CONST_MULT-1:0];

    assign t0arith_d[0] = t0_q;
    assign t3arith_d[0] = t3_q;
    assign t2arith_d[0] = t2_q;

    always_ff @(posedge clk_i) begin
        for (int i=0; i<DELAY_MULT; ++i) begin
            t0arith_q[i] <= t0arith_d[i];
            t3arith_q[i] <= t3arith_d[i];    
            t2arith_q[i] <= t2arith_d[i];                
        end
    end
    generate;
        for (genvar i=1; i<DELAY_MULT; ++i) begin
            assign t0arith_d[i] = t0arith_q[i-1];
            assign t3arith_d[i] = t3arith_q[i-1];
            assign t2arith_d[i] = t2arith_q[i-1];
        end
    endgenerate

    logic [DATA_WIDTH-1:0] add_t0t2, sub_t0t2, add_t1t3, sub_t1t3;

    mod_adder #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) U_GS_ADDER_T0T2 (
        .clk_i(clk_i),
        .op0_i(t0arith_q[$left(t0arith_q)]),
        .op1_i(t2arith_q[$left(t2arith_q)]),
        .res_o(add_t0t2)
    );

    mod_adder #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) U_GS_ADDER_T1T3 (
        .clk_i(clk_i),
        .op0_i(t3arith_q[$left(t3arith_q)]),
        .op1_i(t1w4),
        .res_o(add_t1t3)
    );

    mod_subtractor #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) U_GS_SUBTRACTOR_T0T2 (
        .clk_i(clk_i),
        .op0_i(t2arith_q[$left(t0arith_q)]),
        .op1_i(t0arith_q[$left(t2arith_q)]),
        .res_o(sub_t0t2)
    );

    mod_subtractor #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) U_GS_SUBTRACTOR_T1T3 (
        .clk_i(clk_i),
        .op0_i(t3arith_q[$left(t3arith_q)]),
        .op1_i(t1w4),
        .res_o(sub_t1t3)
    );

    logic [DATA_WIDTH-1:0] add_t0t2_div, sub_t0t2_div, add_t1t3_div, sub_t1t3_div;

    mod_div2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT+1)
    ) U_DIV2_ADD_T0T2 (
        .op_i(add_t0t2),
        .res_o(add_t0t2_div)
    );

    mod_div2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT+1)
    ) U_DIV2_SUB_T0T2 (
        .op_i(sub_t0t2),
        .res_o(sub_t0t2_div)
    );

    mod_div2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT+1)
    ) U_DIV2_ADD_T1T3 (
        .op_i(add_t1t3),
        .res_o(add_t1t3_div)
    );

    mod_div2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT+1)
    ) U_DIV2_SUB_T1T3 (
        .op_i(sub_t1t3),
        .res_o(sub_t1t3_div)
    );

    logic [DATA_WIDTH-1:0] add_t0t2_div_d, sub_t0t2_div_d, add_t1t3_div_d, sub_t1t3_div_d;
    logic [DATA_WIDTH-1:0] add_t0t2_div_q, sub_t0t2_div_q, add_t1t3_div_q, sub_t1t3_div_q;

    assign add_t0t2_div_d = add_t0t2_div;
    assign sub_t0t2_div_d = sub_t0t2_div;
    assign add_t1t3_div_d = add_t1t3_div;
    assign sub_t1t3_div_d = sub_t1t3_div;

    always_ff @(posedge clk_i) begin
        add_t0t2_div_q <= add_t0t2_div_d;
        add_t1t3_div_q <= add_t1t3_div_d;           
        sub_t0t2_div_q <= sub_t0t2_div_d;    
        sub_t1t3_div_q <= sub_t1t3_div_d;    
    end

    logic [DATA_WIDTH-1:0] mult2out1;
    logic [DATA_WIDTH-1:0] mult2out2;
    logic [DATA_WIDTH-1:0] mult2out3;

    mod_multiplier #(
        .DATA_WIDTH(DATA_WIDTH),
        .LOG_R(LOG_R),
        .QINT(QINT),
        .QDASH(QDASH),
        .K(K),
        .QMU(QMU),
        .REDUCTION(REDUCTION)
    ) U_MULTIPLIER_1 (
        .clk_i(clk_i),
        .op0_i(add_t1t3_div_q),
        .op1_i(twiddle1_i),
        .res_o(mult2out1)
    );

    mod_multiplier #(
        .DATA_WIDTH(DATA_WIDTH),
        .LOG_R(LOG_R),
        .QINT(QINT),
        .QDASH(QDASH),
        .K(K),
        .QMU(QMU),
        .REDUCTION(REDUCTION)
    ) U_MULTIPLIER_2 (
        .clk_i(clk_i),
        .op0_i(sub_t0t2_div_q),
        .op1_i(twiddle2_i),
        .res_o(mult2out2)
    );

    mod_multiplier #(
        .DATA_WIDTH(DATA_WIDTH),
        .LOG_R(LOG_R),
        .QINT(QINT),
        .QDASH(QDASH),
        .K(K),
        .QMU(QMU),
        .REDUCTION(REDUCTION)
    ) U_MULTIPLIER_3 (
        .clk_i(clk_i),
        .op0_i(sub_t1t3_div_q),
        .op1_i(twiddle3_i),
        .res_o(mult2out3)
    );


    logic [DATA_WIDTH-1:0] arith2out0_d [DELAY_MULT-1:0];
    logic [DATA_WIDTH-1:0] arith2out0_q [DELAY_MULT-1:0];

    // Pipeline registers
    always_ff @(posedge clk_i) begin
        arith2out0_q[0] <= add_t0t2_div_q;
        for (int i=1; i<=$left(arith2out0_q); ++i) begin
            arith2out0_q[i]<= arith2out0_d[i];
        end
    end
    always_comb begin
        for (int i=1; i<=$left(arith2out0_d); ++i) begin
            arith2out0_d[i] = arith2out0_q[i-1];
        end
    end  

    assign res0_o = arith2out0_q[$left(arith2out0_q)];
    assign res1_o = mult2out1;
    assign res2_o = mult2out2;
    assign res3_o = mult2out3;

endmodule
