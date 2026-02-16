// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`timescale 1ns/10ps

module prim_ntt_r4bfu_uni
#(
    parameter int unsigned DATA_WIDTH = 27,
    parameter int unsigned LOG_R = 28,
   	parameter longint QINT = 134215681,
    parameter longint QDASH = 130021375,
    parameter longint QMU = 0,
    parameter int unsigned K = 54,
    parameter REDUCTION = "SOLINA27", // Choose between "MONTGOMERY", "SOLINA27" and "SOLINA64"
    parameter int unsigned DELAY_MULT = 5,
    parameter int unsigned DELAY_CONST_MULT = 5,
    parameter longint W4 = 37361560,
    parameter bit TWIDDLE1_OPT = 1'b0,
    parameter bit TWIDDLE2_OPT = 1'b0
)
(
    input   logic                       clk_i,
    input   logic                       intt_i,
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
    logic [DATA_WIDTH-1:0] bf0_op0;
    logic [DATA_WIDTH-1:0] bf0_op1;
    logic [DATA_WIDTH-1:0] bf0_res0;
    logic [DATA_WIDTH-1:0] bf0_res1;
    logic [DATA_WIDTH-1:0] bf1_op0;
    logic [DATA_WIDTH-1:0] bf1_op1;
    logic [DATA_WIDTH-1:0] bf1_res0;
    logic [DATA_WIDTH-1:0] bf1_res1;    
    logic [DATA_WIDTH-1:0] bf2_op0;
    logic [DATA_WIDTH-1:0] bf2_op1;
    logic [DATA_WIDTH-1:0] bf2_res0;
    logic [DATA_WIDTH-1:0] bf2_res1;    
    logic [DATA_WIDTH-1:0] bf3_op0;
    logic [DATA_WIDTH-1:0] bf3_op1;
    logic [DATA_WIDTH-1:0] bf3_res0;
    logic [DATA_WIDTH-1:0] bf3_res1;

    prim_ntt_r4bfu_uni_0 #(
        .DATA_WIDTH(DATA_WIDTH),
        .REDUCTION(REDUCTION),
        .LOG_R(LOG_R),
        .QINT(QINT),
        .QDASH(QDASH),
        .W4(W4),
        .DELAY_MULT(DELAY_MULT),
        .DELAY_CONST_MULT(DELAY_CONST_MULT),
        .TWIDDLE2_OPT(TWIDDLE2_OPT)
    ) u_bfu_0 (
        .clk_i(clk_i),
        .intt_i(intt_i),
        .op0_i(bf0_op0),
        .op1_i(bf0_op1),
        .twiddle_i(twiddle2_i),
        .res0_o(bf0_res0),
        .res1_o(bf0_res1)
    );

    prim_ntt_r4bfu_uni_1 #(
        .DATA_WIDTH(DATA_WIDTH),
        .REDUCTION(REDUCTION),
        .LOG_R(LOG_R),
        .QINT(QINT),
        .QDASH(QDASH),
        .W4(W4),
        .DELAY_MULT(DELAY_MULT),
        .DELAY_CONST_MULT(DELAY_CONST_MULT)
    ) u_bfu_1 (
        .clk_i(clk_i),
        .intt_i(intt_i),
        .op0_i(bf1_op0),
        .op1_i(bf1_op1),
        .res0_o(bf1_res0),
        .res1_o(bf1_res1)
    );

    prim_ntt_r4bfu_uni_2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .REDUCTION(REDUCTION),
        .LOG_R(LOG_R),
        .QINT(QINT),
        .QDASH(QDASH),
        .W4(W4),
        .DELAY_MULT(DELAY_MULT),
        .DELAY_CONST_MULT(DELAY_CONST_MULT),
        .TWIDDLE1_OPT(TWIDDLE1_OPT)
    ) u_bfu_2 (
        .clk_i(clk_i),
        .intt_i(intt_i),
        .op0_i(bf2_op0),
        .op1_i(bf2_op1),
        .twiddle0_i(twiddle1_i),
        .twiddle1_i(twiddle3_i),
        .res0_o(bf2_res0),
        .res1_o(bf2_res1)
    );

    prim_ntt_r4bfu_uni_3 #(
        .DATA_WIDTH(DATA_WIDTH),
        .REDUCTION(REDUCTION),
        .LOG_R(LOG_R),
        .QINT(QINT),
        .QDASH(QDASH),
        .W4(W4),
        .DELAY_MULT(DELAY_MULT),
        .DELAY_CONST_MULT(DELAY_CONST_MULT)
    ) u_bfu_3 (
        .clk_i(clk_i),
        .intt_i(intt_i),
        .op0_i(bf3_op0),
        .op1_i(bf3_op1),
        .twiddle_i(twiddle0_i),
        .res0_o(bf3_res0),
        .res1_o(bf3_res1)
    );

    assign bf0_op0 = intt_i ? bf1_res0 : op0_i;
    assign bf0_op1 = intt_i ? bf3_res0 : op2_i;

    assign bf1_op0 = intt_i ? op3_i : bf0_res0;
    assign bf1_op1 = intt_i ? op1_i : bf2_res0;

    assign bf2_op0 = intt_i ? bf1_res1 : op1_i;
    assign bf2_op1 = intt_i ? bf3_res1 : op3_i;

    assign bf3_op0 = intt_i ? op0_i  : bf0_res1;
    assign bf3_op1 = intt_i ? op2_i  : bf2_res1;

    assign res0_o = intt_i ? bf0_res0 : bf1_res0;
    assign res1_o = intt_i ? bf2_res0 : bf3_res0;
    assign res2_o = intt_i ? bf0_res1 : bf1_res1;
    assign res3_o = intt_i ? bf2_res1 : bf3_res1;

endmodule : prim_ntt_r4bfu_uni

module prim_ntt_r4bfu_uni_0
#(
    parameter int unsigned DATA_WIDTH = 27,
    parameter int unsigned LOG_R = 28,
   	parameter longint QINT = 134215681,
    parameter longint QDASH = 130021375,
    parameter longint QMU = 0,
    parameter int unsigned K = 54,
    parameter REDUCTION = "SOLINA27", // Choose between "MONTGOMERY", "SOLINA27" and "SOLINA64"
    parameter int unsigned DELAY_MULT = 5,
    parameter int unsigned DELAY_CONST_MULT = 5,
    parameter longint W4 = 37361560,
    parameter bit TWIDDLE2_OPT = 0
)
(
    input   logic                       clk_i,
    input   logic                       intt_i,
    input   logic   [DATA_WIDTH-1:0]    op0_i,
    input   logic   [DATA_WIDTH-1:0]    op1_i,
    input   logic   [DATA_WIDTH-1:0]    twiddle_i,
    output  logic   [DATA_WIDTH-1:0]    res0_o,
    output  logic   [DATA_WIDTH-1:0]    res1_o
);
    logic [DATA_WIDTH-1:0] modadd_0_op0;
    logic [DATA_WIDTH-1:0] modadd_0_op1;
    logic [DATA_WIDTH-1:0] modadd_0_res;
    logic [DATA_WIDTH-1:0] modsub_0_op0;
    logic [DATA_WIDTH-1:0] modsub_0_op1;
    logic [DATA_WIDTH-1:0] modsub_0_res;
    logic [DATA_WIDTH-1:0] modmul_0_op0;   
    logic [DATA_WIDTH-1:0] modmul_0_op1;
    logic [DATA_WIDTH-1:0] modmul_0_res;
    logic [DATA_WIDTH-1:0] moddiv_0_op;
    logic [DATA_WIDTH-1:0] moddiv_1_op;
    logic [DATA_WIDTH-1:0] moddiv_0_res;
    logic [DATA_WIDTH-1:0] moddiv_1_res;

    // Pipeline registers 
    logic [DATA_WIDTH-1:0] op0_d [DELAY_MULT-1:0];
    logic [DATA_WIDTH-1:0] op0_q [DELAY_MULT-1:0];
    always_ff @(posedge clk_i) begin
        for (int i=0; i<=$left(op0_q); ++i) begin
            op0_q[i]<= op0_d[i];
        end
    end
    always_comb begin
        op0_d[0] = op0_i;
        for (int i=1; i<=$left(op0_d); ++i) begin
            op0_d[i] = op0_q[i-1];
        end
    end  

    // Pipeline registers
    logic [DATA_WIDTH-1:0] moddiv_0_res_d [DELAY_MULT-1:0];
    logic [DATA_WIDTH-1:0] moddiv_0_res_q [DELAY_MULT-1:0];
    always_ff @(posedge clk_i) begin
        for (int i=0; i<=$left(moddiv_0_res_q); ++i) begin
            moddiv_0_res_q[i]<= moddiv_0_res_d[i];
        end
    end
    always_comb begin
        moddiv_0_res_d[0] = moddiv_0_res;
        for (int i=1; i<=$left(moddiv_0_res_d); ++i) begin
            moddiv_0_res_d[i] = moddiv_0_res_q[i-1];
        end
    end  

    // Pipeline registers 
    logic [DATA_WIDTH-1:0] modadd_0_res_d;
    logic [DATA_WIDTH-1:0] modadd_0_res_q;
    logic [DATA_WIDTH-1:0] modsub_0_res_d;
    logic [DATA_WIDTH-1:0] modsub_0_res_q;
    always_ff @(posedge clk_i) begin
        modadd_0_res_q <= modadd_0_res_d;
        modsub_0_res_q <= modsub_0_res_d;
    end
    always_comb begin
        modadd_0_res_d = modadd_0_res;
        modsub_0_res_d = modsub_0_res;
    end  

    assign modadd_0_op0 = intt_i ? op0_i : op0_q[$left(op0_q)];
    assign modadd_0_op1 = intt_i ? op1_i : modmul_0_res;
    assign moddiv_0_op = modadd_0_res_q;
    assign moddiv_1_op = modmul_0_res;
    assign modmul_0_op0 = intt_i ? modsub_0_res_q : op1_i;
    assign modmul_0_op1 = twiddle_i;
    assign modsub_0_op0 = intt_i ? op0_i : op0_q[$left(op0_q)];
    assign modsub_0_op1 = intt_i ? op1_i : modmul_0_res;
    assign res0_o = intt_i ? moddiv_0_res_q[$left(moddiv_0_res_q)] : modadd_0_res_q;
    assign res1_o = intt_i ? moddiv_1_res : modsub_0_res_q;

    mod_adder #(
          .DATA_WIDTH(DATA_WIDTH),
          .QINT(QINT)
    ) u_modadd_0 (
          .clk_i(clk_i),
          .op0_i(modadd_0_op0),
          .op1_i(modadd_0_op1),
          .res_o(modadd_0_res)
    );

    mod_div2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT+1)
    ) u_moddiv_0 (
        .op_i(moddiv_0_op),
        .res_o(moddiv_0_res)
    );

    mod_div2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT+1)
    ) u_moddiv_1 (
        .op_i(moddiv_1_op),
        .res_o(moddiv_1_res)
    );
    generate;
    if (TWIDDLE2_OPT == 1'b1) begin
        logic [DATA_WIDTH-1:0] modmul_0_res_d [DELAY_MULT-DELAY_CONST_MULT-1:0];
        logic [DATA_WIDTH-1:0] modmul_0_res_q [DELAY_MULT-DELAY_CONST_MULT-1:0];
        logic [DATA_WIDTH-1:0] modmul_0_res2ff;
        const_multiplier #(
            .DATA_WIDTH(DATA_WIDTH),
            .QINT(QINT)
        ) u_modmul_0 (
            .clk_i(clk_i),
            .op_i(modmul_0_op0),
            .res_o(modmul_0_res2ff)
        );
        always_ff @(posedge clk_i) begin
            for (int i=0; i<DELAY_MULT-DELAY_CONST_MULT; ++i) begin
                modmul_0_res_q[i] <= modmul_0_res_d[i];
            end
        end
        always_comb begin
            modmul_0_res_d[0] = modmul_0_res2ff;
            for (int i=1; i<DELAY_MULT-DELAY_CONST_MULT; ++i) begin
                modmul_0_res_d[i] = modmul_0_res_q[i-1];
            end
            modmul_0_res = modmul_0_res_q[DELAY_MULT-DELAY_CONST_MULT-1];
        end
    end else begin
        mod_multiplier #(
            .DATA_WIDTH(DATA_WIDTH),
            .LOG_R(LOG_R),
            .QINT(QINT),
            .QDASH(QDASH),
            .K(K),
            .QMU(QMU),
            .REDUCTION(REDUCTION)
        ) u_modmul_0 (
            .clk_i(clk_i),
            .op0_i(modmul_0_op0),
            .op1_i(modmul_0_op1),
            .res_o(modmul_0_res)
        );
    end
    endgenerate

    mod_subtractor #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) u_modsub_0 (
        .clk_i(clk_i),
        .op0_i(modsub_0_op0),
        .op1_i(modsub_0_op1),
        .res_o(modsub_0_res)
    );

endmodule : prim_ntt_r4bfu_uni_0

module prim_ntt_r4bfu_uni_1
#(
    parameter int unsigned DATA_WIDTH = 27,
    parameter int unsigned LOG_R = 28,
   	parameter longint QINT = 134215681,
    parameter longint QDASH = 130021375,
    parameter longint QMU = 0,
    parameter int unsigned K = 54,
    parameter REDUCTION = "SOLINA27", // Choose between "MONTGOMERY", "SOLINA27" and "SOLINA64"
    parameter int unsigned DELAY_MULT = 5,
    parameter int unsigned DELAY_CONST_MULT = 5,
    parameter longint W4 = 37361560
)
(
    input   logic                       clk_i,
    input   logic                       intt_i,
    input   logic   [DATA_WIDTH-1:0]    op0_i,
    input   logic   [DATA_WIDTH-1:0]    op1_i,
    output  logic   [DATA_WIDTH-1:0]    res0_o,
    output  logic   [DATA_WIDTH-1:0]    res1_o
);
    logic [DATA_WIDTH-1:0] modadd_0_op0;
    logic [DATA_WIDTH-1:0] modadd_0_op1;
    logic [DATA_WIDTH-1:0] modadd_0_res;
    logic [DATA_WIDTH-1:0] modsub_0_op0;
    logic [DATA_WIDTH-1:0] modsub_0_op1;
    logic [DATA_WIDTH-1:0] modsub_0_res;
    logic [DATA_WIDTH-1:0] moddiv_0_op;
    logic [DATA_WIDTH-1:0] moddiv_1_op;
    logic [DATA_WIDTH-1:0] moddiv_0_res;
    logic [DATA_WIDTH-1:0] moddiv_1_res;

    // Pipeline registers 
    logic [DATA_WIDTH-1:0] modadd_0_res_d;
    logic [DATA_WIDTH-1:0] modadd_0_res_q;
    logic [DATA_WIDTH-1:0] modsub_0_res_d;
    logic [DATA_WIDTH-1:0] modsub_0_res_q;
    always_ff @(posedge clk_i) begin
        modadd_0_res_q <= modadd_0_res_d;
        modsub_0_res_q <= modsub_0_res_d;
    end
    always_comb begin
        modadd_0_res_d = modadd_0_res;
        modsub_0_res_d = modsub_0_res;
    end 
    // Pipeline registers
    logic [DATA_WIDTH-1:0] op0_d [DELAY_CONST_MULT-1:0];
    logic [DATA_WIDTH-1:0] op0_q [DELAY_CONST_MULT-1:0];
    logic [DATA_WIDTH-1:0] op1_d [DELAY_CONST_MULT-1:0];
    logic [DATA_WIDTH-1:0] op1_q [DELAY_CONST_MULT-1:0];
    always_ff @(posedge clk_i) begin
        for (int i=0; i<=$left(op0_q); ++i) begin
            op0_q[i]<= op0_d[i];
            op1_q[i]<= op1_d[i];
        end
    end
    always_comb begin
        op0_d[0] = op0_i;
        op1_d[0] = op1_i;
        for (int i=1; i<=$left(op0_d); ++i) begin
            op0_d[i] = op0_q[i-1];
            op1_d[i] = op1_q[i-1];
        end
    end 

    assign modadd_0_op0 = op0_q[$left(op0_q)];
    assign modadd_0_op1 = op1_q[$left(op1_q)];
    assign moddiv_0_op = modadd_0_res_q;
    assign moddiv_1_op = modsub_0_res_q;
    assign modsub_0_op0 = op0_q[$left(op0_q)];
    assign modsub_0_op1 = op1_q[$left(op1_q)];
    assign res0_o = intt_i ? moddiv_0_res : modadd_0_res_q;
    assign res1_o = intt_i ? moddiv_1_res : modsub_0_res_q;
    
    mod_adder #(
          .DATA_WIDTH(DATA_WIDTH),
          .QINT(QINT)
    ) u_modadd_0 (
          .clk_i(clk_i),
          .op0_i(modadd_0_op0),
          .op1_i(modadd_0_op1),
          .res_o(modadd_0_res)
    );

    mod_div2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT+1)
    ) u_moddiv_0 (
        .op_i(moddiv_0_op),
        .res_o(moddiv_0_res)
    );

    mod_div2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT+1)
    ) u_moddiv_1 (
        .op_i(moddiv_1_op),
        .res_o(moddiv_1_res)
    );
    
    mod_subtractor #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) u_modsub_0 (
        .clk_i(clk_i),
        .op0_i(modsub_0_op0),
        .op1_i(modsub_0_op1),
        .res_o(modsub_0_res)
    );
endmodule : prim_ntt_r4bfu_uni_1

module prim_ntt_r4bfu_uni_2
#(
    parameter int unsigned DATA_WIDTH = 27,
    parameter int unsigned LOG_R = 28,
   	parameter longint QINT = 134215681,
    parameter longint QDASH = 130021375,
    parameter longint QMU = 0,
    parameter int unsigned K = 54,
    parameter REDUCTION = "SOLINA27", // Choose between "MONTGOMERY", "SOLINA27" and "SOLINA64"
    parameter int unsigned DELAY_MULT = 5,
    parameter int unsigned DELAY_CONST_MULT = 5,
    parameter longint W4 = 37361560,
    parameter bit TWIDDLE1_OPT = 0
)
(
    input   logic                       clk_i,
    input   logic                       intt_i,
    input   logic   [DATA_WIDTH-1:0]    op0_i,
    input   logic   [DATA_WIDTH-1:0]    op1_i,
    input   logic   [DATA_WIDTH-1:0]    twiddle0_i,
    input   logic   [DATA_WIDTH-1:0]    twiddle1_i,
    output  logic   [DATA_WIDTH-1:0]    res0_o,
    output  logic   [DATA_WIDTH-1:0]    res1_o
);

    logic [DATA_WIDTH-1:0] modadd_0_op0;
    logic [DATA_WIDTH-1:0] modadd_0_op1;
    logic [DATA_WIDTH-1:0] modadd_0_res;
    logic [DATA_WIDTH-1:0] modsub_0_op0;
    logic [DATA_WIDTH-1:0] modsub_0_op1;
    logic [DATA_WIDTH-1:0] modsub_0_res;
    logic [DATA_WIDTH-1:0] modmul_0_op0;   
    logic [DATA_WIDTH-1:0] modmul_0_op1;
    logic [DATA_WIDTH-1:0] modmul_0_res;
    logic [DATA_WIDTH-1:0] modmul_1_op0;   
    logic [DATA_WIDTH-1:0] modmul_1_op1;
    logic [DATA_WIDTH-1:0] modmul_1_res;
    logic [DATA_WIDTH-1:0] moddiv_0_op;
    logic [DATA_WIDTH-1:0] moddiv_1_op;
    logic [DATA_WIDTH-1:0] moddiv_0_res;
    logic [DATA_WIDTH-1:0] moddiv_1_res;

    // Pipeline registers 
    logic [DATA_WIDTH-1:0] modadd_0_res_d;
    logic [DATA_WIDTH-1:0] modadd_0_res_q;
    logic [DATA_WIDTH-1:0] modsub_0_res_d;
    logic [DATA_WIDTH-1:0] modsub_0_res_q;
    always_ff @(posedge clk_i) begin
        modadd_0_res_q <= modadd_0_res_d;
        modsub_0_res_q <= modsub_0_res_d;
    end
    always_comb begin
        modadd_0_res_d = modadd_0_res;
        modsub_0_res_d = modsub_0_res;
    end 

    assign modadd_0_op0 = intt_i ? op0_i : modmul_0_res;
    assign modadd_0_op1 = intt_i ? op1_i : modmul_1_res;
    assign moddiv_0_op = modmul_0_res;
    assign moddiv_1_op = modmul_1_res;
    assign modmul_0_op0 = intt_i ? modadd_0_res_q : op0_i;
    assign modmul_0_op1 = twiddle0_i;
    assign modmul_1_op0 = intt_i ? modsub_0_res_q : op1_i;
    assign modmul_1_op1 = twiddle1_i;
    assign modsub_0_op0 = intt_i ? op0_i : modmul_0_res;
    assign modsub_0_op1 = intt_i ? op1_i : modmul_1_res;
    assign res0_o = intt_i ? moddiv_0_res : modadd_0_res_q;
    assign res1_o = intt_i ? moddiv_1_res : modsub_0_res_q;

    mod_adder #(
          .DATA_WIDTH(DATA_WIDTH),
          .QINT(QINT)
    ) u_modadd_0 (
          .clk_i(clk_i),
          .op0_i(modadd_0_op0),
          .op1_i(modadd_0_op1),
          .res_o(modadd_0_res)
    );

    mod_div2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT+1)
    ) u_moddiv_0 (
        .op_i(moddiv_0_op),
        .res_o(moddiv_0_res)
    );

    mod_div2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT+1)
    ) u_moddiv_1 (
        .op_i(moddiv_1_op),
        .res_o(moddiv_1_res)
    );
    generate;
    if (TWIDDLE1_OPT == 1'b1) begin
        logic [DATA_WIDTH-1:0] modmul_0_res_d [DELAY_MULT-DELAY_CONST_MULT-1:0];
        logic [DATA_WIDTH-1:0] modmul_0_res_q [DELAY_MULT-DELAY_CONST_MULT-1:0];
        logic [DATA_WIDTH-1:0] modmul_0_res2ff;
        const_multiplier #(
            .DATA_WIDTH(DATA_WIDTH),
            .QINT(QINT)
        ) u_modmul_0 (
            .clk_i(clk_i),
            .op_i(modmul_0_op0),
            .res_o(modmul_0_res2ff)
        );
        always_ff @(posedge clk_i) begin
            for (int i=0; i<DELAY_MULT-DELAY_CONST_MULT; ++i) begin
                modmul_0_res_q[i] <= modmul_0_res_d[i];
            end
        end
        always_comb begin
            modmul_0_res_d[0] = modmul_0_res2ff;
            for (int i=1; i<DELAY_MULT-DELAY_CONST_MULT; ++i) begin
                modmul_0_res_d[i] = modmul_0_res_q[i-1];
            end
            modmul_0_res = modmul_0_res_q[DELAY_MULT-DELAY_CONST_MULT-1];
        end

    end else begin
        mod_multiplier #(
            .DATA_WIDTH(DATA_WIDTH),
            .LOG_R(LOG_R),
            .QINT(QINT),
            .QDASH(QDASH),
            .K(K),
            .QMU(QMU),
            .REDUCTION(REDUCTION)
        ) u_modmul_0 (
            .clk_i(clk_i),
            .op0_i(modmul_0_op0),
            .op1_i(modmul_0_op1),
            .res_o(modmul_0_res)
        );
    end
    endgenerate

    mod_multiplier #(
        .DATA_WIDTH(DATA_WIDTH),
        .LOG_R(LOG_R),
        .QINT(QINT),
        .QDASH(QDASH),
        .K(K),
        .QMU(QMU),
        .REDUCTION(REDUCTION)
    ) u_modmul_1 (
        .clk_i(clk_i),
        .op0_i(modmul_1_op0),
        .op1_i(modmul_1_op1),
        .res_o(modmul_1_res)
    );

    mod_subtractor #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) u_modsub_0 (
        .clk_i(clk_i),
        .op0_i(modsub_0_op0),
        .op1_i(modsub_0_op1),
        .res_o(modsub_0_res)
    );

endmodule : prim_ntt_r4bfu_uni_2

module prim_ntt_r4bfu_uni_3
#(
    parameter int unsigned DATA_WIDTH = 27,
    parameter int unsigned LOG_R = 28,
   	parameter longint QINT = 134215681,
    parameter longint QDASH = 130021375,
    parameter longint QMU = 0,
    parameter int unsigned K = 54,
    parameter REDUCTION = "SOLINA27", // Choose between "MONTGOMERY", "SOLINA27" and "SOLINA64"
    parameter int unsigned DELAY_MULT = 5,
    parameter int unsigned DELAY_CONST_MULT = 5,
    parameter longint W4 = 37361560
)
(
    input   logic                       clk_i,
    input   logic                       intt_i,
    input   logic   [DATA_WIDTH-1:0]    op0_i,
    input   logic   [DATA_WIDTH-1:0]    op1_i,
    input   logic   [DATA_WIDTH-1:0]    twiddle_i,
    output  logic   [DATA_WIDTH-1:0]    res0_o,
    output  logic   [DATA_WIDTH-1:0]    res1_o
);

    logic [DATA_WIDTH-1:0] modadd_0_op0;
    logic [DATA_WIDTH-1:0] modadd_0_op1;
    logic [DATA_WIDTH-1:0] modadd_0_res;
    logic [DATA_WIDTH-1:0] modsub_0_op0;
    logic [DATA_WIDTH-1:0] modsub_0_op1;
    logic [DATA_WIDTH-1:0] modsub_0_res;
    logic [DATA_WIDTH-1:0] modmul_0_op0;   
    logic [DATA_WIDTH-1:0] modmul_0_op1;
    logic [DATA_WIDTH-1:0] modmul_0_res;
    logic [DATA_WIDTH-1:0] moddiv_0_op;
    logic [DATA_WIDTH-1:0] moddiv_1_op;
    logic [DATA_WIDTH-1:0] moddiv_0_res;
    logic [DATA_WIDTH-1:0] moddiv_1_res;

    // Pipeline registers
    logic [DATA_WIDTH-1:0] op0_d [DELAY_CONST_MULT-1:0];
    logic [DATA_WIDTH-1:0] op0_q [DELAY_CONST_MULT-1:0];
    always_ff @(posedge clk_i) begin
        for (int i=0; i<=$left(op0_q); ++i) begin
            op0_q[i]<= op0_d[i];
        end
    end
    always_comb begin
        op0_d[0] = op0_i;
        for (int i=1; i<=$left(op0_d); ++i) begin
            op0_d[i] = op0_q[i-1];
        end
    end  

    // Pipeline registers
    logic [DATA_WIDTH-1:0] moddiv_0_res_d [DELAY_CONST_MULT-1:0];
    logic [DATA_WIDTH-1:0] moddiv_0_res_q [DELAY_CONST_MULT-1:0];
    always_ff @(posedge clk_i) begin
        for (int i=0; i<=$left(moddiv_0_res_q); ++i) begin
            moddiv_0_res_q[i]<= moddiv_0_res_d[i];
        end
    end
    always_comb begin
        moddiv_0_res_d[0] = moddiv_0_res;
        for (int i=1; i<=$left(moddiv_0_res_d); ++i) begin
            moddiv_0_res_d[i] = moddiv_0_res_q[i-1];
        end
    end  

    // Pipeline registers 
    logic [DATA_WIDTH-1:0] modadd_0_res_d;
    logic [DATA_WIDTH-1:0] modadd_0_res_q;
    logic [DATA_WIDTH-1:0] modsub_0_res_d;
    logic [DATA_WIDTH-1:0] modsub_0_res_q;
    logic [DATA_WIDTH-1:0] modmul_0_res_d;
    always_ff @(posedge clk_i) begin
        modadd_0_res_q <= modadd_0_res_d;
        modsub_0_res_q <= modsub_0_res_d;
    end
    always_comb begin
        modadd_0_res_d = modadd_0_res;
        modsub_0_res_d = modsub_0_res;
        modmul_0_res_d = modmul_0_res;
    end 

    assign modadd_0_op0 = intt_i ? op0_i : op0_q[$left(op0_q)];
    assign modadd_0_op1 = intt_i ? op1_i : modmul_0_res;
    assign moddiv_0_op = modadd_0_res_q;
    assign moddiv_1_op = modmul_0_res;
    assign modmul_0_op0 = intt_i ? modsub_0_res_q : op1_i;
    assign modmul_0_op1 = twiddle_i;
    assign modsub_0_op0 = intt_i ? op1_i : op0_q[$left(op0_q)];
    assign modsub_0_op1 = intt_i ? op0_i : modmul_0_res;
    assign res0_o = intt_i ? moddiv_0_res_q[$left(moddiv_0_res_q)] : modadd_0_res_q;
    assign res1_o = intt_i ? moddiv_1_res : modsub_0_res_q;

    mod_adder #(
          .DATA_WIDTH(DATA_WIDTH),
          .QINT(QINT)
    ) u_modadd_0 (
          .clk_i(clk_i),
          .op0_i(modadd_0_op0),
          .op1_i(modadd_0_op1),
          .res_o(modadd_0_res)
    );

    mod_div2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT+1)
    ) u_moddiv_0 (
        .op_i(moddiv_0_op),
        .res_o(moddiv_0_res)
    );

    mod_div2 #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT+1)
    ) u_moddiv_1 (
        .op_i(moddiv_1_op),
        .res_o(moddiv_1_res)
    );

    const_multiplier #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) u_modmul_0 (
        .clk_i(clk_i),
        .op_i(modmul_0_op0),
        .res_o(modmul_0_res)
    );

    mod_subtractor #(
        .DATA_WIDTH(DATA_WIDTH),
        .QINT(QINT)
    ) u_modsub_0 (
        .clk_i(clk_i),
        .op0_i(modsub_0_op0),
        .op1_i(modsub_0_op1),
        .res_o(modsub_0_res)
    );

endmodule : prim_ntt_r4bfu_uni_3