// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`timescale 1ns/10ps

module prim_ntt_r4ctbfu
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

    logic [DATA_WIDTH-1:0] mult2arith2;
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
        .op0_i(op2_i),
        .op1_i(twiddle2_i),
        .res_o(mult2arith2)
    );

    logic [DATA_WIDTH-1:0] mult2arith1;
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
        .op0_i(op1_i),
        .op1_i(twiddle1_i),
        .res_o(mult2arith1)
    );

    logic [DATA_WIDTH-1:0] mult2arith3;
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
        .op0_i(op3_i),
        .op1_i(twiddle3_i),
        .res_o(mult2arith3)
    );
    logic [DATA_WIDTH-1:0] in2arith0_d [DELAY_MULT-1:0];
    logic [DATA_WIDTH-1:0] in2arith0_q [DELAY_MULT-1:0];

    // Pipeline registers
    always_ff @(posedge clk_i) begin
        in2arith0_q[0] <= op0_i;
        for (int i=1; i<=$left(in2arith0_q); ++i) begin
            in2arith0_q[i]<= in2arith0_d[i];
        end
    end
    always_comb begin
        for (int i=1; i<=$left(in2arith0_d); ++i) begin
            in2arith0_d[i] = in2arith0_q[i-1];
        end
    end  

    logic [DATA_WIDTH-1:0] t0,t1,t2,t3;
    logic [DATA_WIDTH-1:0] t0_d [DELAY_CONST_MULT-1:0],t1_d [DELAY_CONST_MULT-1:0],t2_d [DELAY_CONST_MULT-1:0];
    logic [DATA_WIDTH-1:0] t0_q [DELAY_CONST_MULT-1:0],t1_q [DELAY_CONST_MULT-1:0],t2_q [DELAY_CONST_MULT-1:0];

    mod_adder #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) U_CT_ADDER_T0 (
        .clk_i(clk_i),
        .op0_i(in2arith0_q[$left(in2arith0_q)]),
        .op1_i(mult2arith2),
        .res_o(t0)
    );

    mod_subtractor #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) U_CT_SUBTRACTOR_T1 (
        .clk_i(clk_i),
        .op0_i(in2arith0_q[$left(in2arith0_q)]),
        .op1_i(mult2arith2),
        .res_o(t1)
    );

    mod_adder #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) U_CT_ADDER_T2 (
        .clk_i(clk_i),
        .op0_i(mult2arith1),
        .op1_i(mult2arith3),
        .res_o(t2)
    );

    mod_subtractor #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) U_CT_SUBTRACTOR_T3 (
        .clk_i(clk_i),
        .op0_i(mult2arith1),
        .op1_i(mult2arith3),
        .res_o(t3)
    );

    logic [DATA_WIDTH-1:0] t3w4;
    const_multiplier #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) U_MULTIPLIER_W4 (
        .clk_i(clk_i),
        .op_i(t3),
        .res_o(t3w4)
    );

    // Pipeline registers
    always_ff @(posedge clk_i) begin
        t0_q[0] <= t0;
        t1_q[0] <= t1;
        t2_q[0] <= t2;
        for (int i=1; i<=$left(t0_q); ++i) begin
            t0_q[i]<= t0_d[i];
            t1_q[i]<= t1_d[i];
            t2_q[i]<= t2_d[i];
        end
    end
    always_comb begin
        for (int i=1; i<=$left(t0_d); ++i) begin
            t0_d[i] = t0_q[i-1];
            t1_d[i] = t1_q[i-1];
            t2_d[i] = t2_q[i-1];
        end
    end  

    logic [DATA_WIDTH-1:0] res0_d;
    logic [DATA_WIDTH-1:0] res1_d;
    logic [DATA_WIDTH-1:0] res2_d;
    logic [DATA_WIDTH-1:0] res3_d;

    mod_adder #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) U_CT_ADDER_T0T2 (
        .clk_i(clk_i),
        .op0_i(t0_q[$left(t0_q)]),
        .op1_i(t2_q[$left(t2_q)]),
        .res_o(res0_d)
    );
    mod_adder #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) U_CT_ADDER_T1T3 (
        .clk_i(clk_i),
        .op0_i(t1_q[$left(t1_q)]),
        .op1_i(t3w4),
        .res_o(res1_d)
    );

    mod_subtractor #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) U_CT_SUBTRACTOR_T0T2 (
        .clk_i(clk_i),
        .op0_i(t0_q[$left(t0_q)]),
        .op1_i(t2_q[$left(t2_q)]),
        .res_o(res2_d)
    );

    mod_subtractor #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) U_CT_SUBTRACTOR_T1T3 (
        .clk_i(clk_i),
        .op0_i(t1_q[$left(t1_q)]),
        .op1_i(t3w4),
        .res_o(res3_d)
    );

    logic [DATA_WIDTH-1:0] res0_q;
    logic [DATA_WIDTH-1:0] res1_q;
    logic [DATA_WIDTH-1:0] res2_q;
    logic [DATA_WIDTH-1:0] res3_q;   

    always_ff @(posedge clk_i) begin
        res0_q <= res0_d;
        res1_q <= res1_d;
        res2_q <= res2_d;
        res3_q <= res3_d;
    end

    assign res0_o = res0_q;
    assign res1_o = res1_q;
    assign res2_o = res2_q;
    assign res3_o = res3_q;

endmodule
