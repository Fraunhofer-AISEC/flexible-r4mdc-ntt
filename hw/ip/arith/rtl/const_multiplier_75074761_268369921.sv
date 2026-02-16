// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module const_multiplier_75074761_268369921
#(
    parameter int unsigned DATA_WIDTH = 28
)
(
    input   logic                       clk_i,
    input   logic   [DATA_WIDTH-1:0]    op_i,
    output  logic   [DATA_WIDTH-1:0]    res_o   
);
  logic [DATA_WIDTH-1:0] op_q;
  always_ff @(posedge clk_i) begin
    op_q <= op_i;
  end
  logic [29:0] op_pad;
  logic [27:0] lut2csa [5:0];

  assign op_pad = {2'b0, op_q};

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hb696d25ac718e39c) // Specify LUT Contents
  ) LUT6_2_inst_0_0 (
      .O6(lut2csa[0][0]), 
      .O5(lut2csa[0][1]), 
      .I0(op_pad[0]), 
      .I1(op_pad[1]), 
      .I2(op_pad[2]), 
      .I3(op_pad[3]), 
      .I4(op_pad[4]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hf81f03e0aab556aa) // Specify LUT Contents
  ) LUT6_2_inst_0_1 (
      .O6(lut2csa[0][2]), 
      .O5(lut2csa[0][3]), 
      .I0(op_pad[0]), 
      .I1(op_pad[1]), 
      .I2(op_pad[2]), 
      .I3(op_pad[3]), 
      .I4(op_pad[4]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h332664cc3c3878f0) // Specify LUT Contents
  ) LUT6_2_inst_0_2 (
      .O6(lut2csa[0][4]), 
      .O5(lut2csa[0][5]), 
      .I0(op_pad[0]), 
      .I1(op_pad[1]), 
      .I2(op_pad[2]), 
      .I3(op_pad[3]), 
      .I4(op_pad[4]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h956ad5aa7319cc66) // Specify LUT Contents
  ) LUT6_2_inst_0_3 (
      .O6(lut2csa[0][6]), 
      .O5(lut2csa[0][7]), 
      .I0(op_pad[0]), 
      .I1(op_pad[1]), 
      .I2(op_pad[2]), 
      .I3(op_pad[3]), 
      .I4(op_pad[4]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h5a5296b4639ce738) // Specify LUT Contents
  ) LUT6_2_inst_0_4 (
      .O6(lut2csa[0][8]), 
      .O5(lut2csa[0][9]), 
      .I0(op_pad[0]), 
      .I1(op_pad[1]), 
      .I2(op_pad[2]), 
      .I3(op_pad[3]), 
      .I4(op_pad[4]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hd6b5ad6ace739ce6) // Specify LUT Contents
  ) LUT6_2_inst_0_5 (
      .O6(lut2csa[0][10]), 
      .O5(lut2csa[0][11]), 
      .I0(op_pad[0]), 
      .I1(op_pad[1]), 
      .I2(op_pad[2]), 
      .I3(op_pad[3]), 
      .I4(op_pad[4]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h6b5ad6b4739ce738) // Specify LUT Contents
  ) LUT6_2_inst_0_6 (
      .O6(lut2csa[0][12]), 
      .O5(lut2csa[0][13]), 
      .I0(op_pad[0]), 
      .I1(op_pad[1]), 
      .I2(op_pad[2]), 
      .I3(op_pad[3]), 
      .I4(op_pad[4]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h7c1f07c02ab552aa) // Specify LUT Contents
  ) LUT6_2_inst_0_7 (
      .O6(lut2csa[0][14]), 
      .O5(lut2csa[0][15]), 
      .I0(op_pad[0]), 
      .I1(op_pad[1]), 
      .I2(op_pad[2]), 
      .I3(op_pad[3]), 
      .I4(op_pad[4]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h05b0b696551aa3d4) // Specify LUT Contents
  ) LUT6_2_inst_0_8 (
      .O6(lut2csa[0][16]), 
      .O5(lut2csa[0][17]), 
      .I0(op_pad[0]), 
      .I1(op_pad[1]), 
      .I2(op_pad[2]), 
      .I3(op_pad[3]), 
      .I4(op_pad[4]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h66233b182d69694a) // Specify LUT Contents
  ) LUT6_2_inst_0_9 (
      .O6(lut2csa[0][18]), 
      .O5(lut2csa[0][19]), 
      .I0(op_pad[0]), 
      .I1(op_pad[1]), 
      .I2(op_pad[2]), 
      .I3(op_pad[3]), 
      .I4(op_pad[4]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h1ce718c603e0f83e) // Specify LUT Contents
  ) LUT6_2_inst_0_10 (
      .O6(lut2csa[0][20]), 
      .O5(lut2csa[0][21]), 
      .I0(op_pad[0]), 
      .I1(op_pad[1]), 
      .I2(op_pad[2]), 
      .I3(op_pad[3]), 
      .I4(op_pad[4]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hffe007feaab55554) // Specify LUT Contents
  ) LUT6_2_inst_0_11 (
      .O6(lut2csa[0][22]), 
      .O5(lut2csa[0][23]), 
      .I0(op_pad[0]), 
      .I1(op_pad[1]), 
      .I2(op_pad[2]), 
      .I3(op_pad[3]), 
      .I4(op_pad[4]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h33399998c3c1e1e0) // Specify LUT Contents
  ) LUT6_2_inst_0_12 (
      .O6(lut2csa[0][24]), 
      .O5(lut2csa[0][25]), 
      .I0(op_pad[0]), 
      .I1(op_pad[1]), 
      .I2(op_pad[2]), 
      .I3(op_pad[3]), 
      .I4(op_pad[4]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h56ab54aa9b3266cc) // Specify LUT Contents
  ) LUT6_2_inst_0_13 (
      .O6(lut2csa[0][26]), 
      .O5(lut2csa[0][27]), 
      .I0(op_pad[0]), 
      .I1(op_pad[1]), 
      .I2(op_pad[2]), 
      .I3(op_pad[3]), 
      .I4(op_pad[4]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'haab55554998ccccc) // Specify LUT Contents
  ) LUT6_2_inst_1_0 (
      .O6(lut2csa[1][0]), 
      .O5(lut2csa[1][1]), 
      .I0(op_pad[5]), 
      .I1(op_pad[6]), 
      .I2(op_pad[7]), 
      .I3(op_pad[8]), 
      .I4(op_pad[9]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h787c3c3cad56a956) // Specify LUT Contents
  ) LUT6_2_inst_1_1 (
      .O6(lut2csa[1][2]), 
      .O5(lut2csa[1][3]), 
      .I0(op_pad[5]), 
      .I1(op_pad[6]), 
      .I2(op_pad[7]), 
      .I3(op_pad[8]), 
      .I4(op_pad[9]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h64cd9b3249692da4) // Specify LUT Contents
  ) LUT6_2_inst_1_2 (
      .O6(lut2csa[1][4]), 
      .O5(lut2csa[1][5]), 
      .I0(op_pad[5]), 
      .I1(op_pad[6]), 
      .I2(op_pad[7]), 
      .I3(op_pad[8]), 
      .I4(op_pad[9]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h8e71ce38f07e0fc0) // Specify LUT Contents
  ) LUT6_2_inst_1_3 (
      .O6(lut2csa[1][6]), 
      .O5(lut2csa[1][7]), 
      .I0(op_pad[5]), 
      .I1(op_pad[6]), 
      .I2(op_pad[7]), 
      .I3(op_pad[8]), 
      .I4(op_pad[9]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'haad55aaa33666ccc) // Specify LUT Contents
  ) LUT6_2_inst_1_4 (
      .O6(lut2csa[1][8]), 
      .O5(lut2csa[1][9]), 
      .I0(op_pad[5]), 
      .I1(op_pad[6]), 
      .I2(op_pad[7]), 
      .I3(op_pad[8]), 
      .I4(op_pad[9]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h3c7870f0952ad5aa) // Specify LUT Contents
  ) LUT6_2_inst_1_5 (
      .O6(lut2csa[1][10]), 
      .O5(lut2csa[1][11]), 
      .I0(op_pad[5]), 
      .I1(op_pad[6]), 
      .I2(op_pad[7]), 
      .I3(op_pad[8]), 
      .I4(op_pad[9]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h7319cc665a5296b4) // Specify LUT Contents
  ) LUT6_2_inst_1_6 (
      .O6(lut2csa[1][12]), 
      .O5(lut2csa[1][13]), 
      .I0(op_pad[5]), 
      .I1(op_pad[6]), 
      .I2(op_pad[7]), 
      .I3(op_pad[8]), 
      .I4(op_pad[9]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h639ce738d6b5ad6a) // Specify LUT Contents
  ) LUT6_2_inst_1_7 (
      .O6(lut2csa[1][14]), 
      .O5(lut2csa[1][15]), 
      .I0(op_pad[5]), 
      .I1(op_pad[6]), 
      .I2(op_pad[7]), 
      .I3(op_pad[8]), 
      .I4(op_pad[9]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h64c6c9b2d2525b68) // Specify LUT Contents
  ) LUT6_2_inst_1_8 (
      .O6(lut2csa[1][16]), 
      .O5(lut2csa[1][17]), 
      .I0(op_pad[5]), 
      .I1(op_pad[6]), 
      .I2(op_pad[7]), 
      .I3(op_pad[8]), 
      .I4(op_pad[9]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h9b64924c492db6da) // Specify LUT Contents
  ) LUT6_2_inst_1_9 (
      .O6(lut2csa[1][18]), 
      .O5(lut2csa[1][19]), 
      .I0(op_pad[5]), 
      .I1(op_pad[6]), 
      .I2(op_pad[7]), 
      .I3(op_pad[8]), 
      .I4(op_pad[9]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hc71c71c63f03f03e) // Specify LUT Contents
  ) LUT6_2_inst_1_10 (
      .O6(lut2csa[1][20]), 
      .O5(lut2csa[1][21]), 
      .I0(op_pad[5]), 
      .I1(op_pad[6]), 
      .I2(op_pad[7]), 
      .I3(op_pad[8]), 
      .I4(op_pad[9]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h55aaa55466333998) // Specify LUT Contents
  ) LUT6_2_inst_1_11 (
      .O6(lut2csa[1][22]), 
      .O5(lut2csa[1][23]), 
      .I0(op_pad[5]), 
      .I1(op_pad[6]), 
      .I2(op_pad[7]), 
      .I3(op_pad[8]), 
      .I4(op_pad[9]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h2d696b4a1ce718c6) // Specify LUT Contents
  ) LUT6_2_inst_1_12 (
      .O6(lut2csa[1][24]), 
      .O5(lut2csa[1][25]), 
      .I0(op_pad[5]), 
      .I1(op_pad[6]), 
      .I2(op_pad[7]), 
      .I3(op_pad[8]), 
      .I4(op_pad[9]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h03e0f83effe007fe) // Specify LUT Contents
  ) LUT6_2_inst_1_13 (
      .O6(lut2csa[1][26]), 
      .O5(lut2csa[1][27]), 
      .I0(op_pad[5]), 
      .I1(op_pad[6]), 
      .I2(op_pad[7]), 
      .I3(op_pad[8]), 
      .I4(op_pad[9]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h663339984b5a52d2) // Specify LUT Contents
  ) LUT6_2_inst_2_0 (
      .O6(lut2csa[2][0]), 
      .O5(lut2csa[2][1]), 
      .I0(op_pad[10]), 
      .I1(op_pad[11]), 
      .I2(op_pad[12]), 
      .I3(op_pad[13]), 
      .I4(op_pad[14]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h739c631c7c1f83e0) // Specify LUT Contents
  ) LUT6_2_inst_2_1 (
      .O6(lut2csa[2][2]), 
      .O5(lut2csa[2][3]), 
      .I0(op_pad[10]), 
      .I1(op_pad[11]), 
      .I2(op_pad[12]), 
      .I3(op_pad[13]), 
      .I4(op_pad[14]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h801ffc00554aaaaa) // Specify LUT Contents
  ) LUT6_2_inst_2_2 (
      .O6(lut2csa[2][4]), 
      .O5(lut2csa[2][5]), 
      .I0(op_pad[10]), 
      .I1(op_pad[11]), 
      .I2(op_pad[12]), 
      .I3(op_pad[13]), 
      .I4(op_pad[14]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hccc666663c3e1e1e) // Specify LUT Contents
  ) LUT6_2_inst_2_3 (
      .O6(lut2csa[2][6]), 
      .O5(lut2csa[2][7]), 
      .I0(op_pad[10]), 
      .I1(op_pad[11]), 
      .I2(op_pad[12]), 
      .I3(op_pad[13]), 
      .I4(op_pad[14]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'ha954ab5464cd9932) // Specify LUT Contents
  ) LUT6_2_inst_2_4 (
      .O6(lut2csa[2][8]), 
      .O5(lut2csa[2][9]), 
      .I0(op_pad[10]), 
      .I1(op_pad[11]), 
      .I2(op_pad[12]), 
      .I3(op_pad[13]), 
      .I4(op_pad[14]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h49692da48e71ce38) // Specify LUT Contents
  ) LUT6_2_inst_2_5 (
      .O6(lut2csa[2][10]), 
      .O5(lut2csa[2][11]), 
      .I0(op_pad[10]), 
      .I1(op_pad[11]), 
      .I2(op_pad[12]), 
      .I3(op_pad[13]), 
      .I4(op_pad[14]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hf07e0fc0aad55aaa) // Specify LUT Contents
  ) LUT6_2_inst_2_6 (
      .O6(lut2csa[2][12]), 
      .O5(lut2csa[2][13]), 
      .I0(op_pad[10]), 
      .I1(op_pad[11]), 
      .I2(op_pad[12]), 
      .I3(op_pad[13]), 
      .I4(op_pad[14]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h33666ccc3c7870f0) // Specify LUT Contents
  ) LUT6_2_inst_2_7 (
      .O6(lut2csa[2][14]), 
      .O5(lut2csa[2][15]), 
      .I0(op_pad[10]), 
      .I1(op_pad[11]), 
      .I2(op_pad[12]), 
      .I3(op_pad[13]), 
      .I4(op_pad[14]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hf319ec325a52b6a4) // Specify LUT Contents
  ) LUT6_2_inst_2_8 (
      .O6(lut2csa[2][16]), 
      .O5(lut2csa[2][17]), 
      .I0(op_pad[10]), 
      .I1(op_pad[11]), 
      .I2(op_pad[12]), 
      .I3(op_pad[13]), 
      .I4(op_pad[14]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h639cc7387c1f07c0) // Specify LUT Contents
  ) LUT6_2_inst_2_9 (
      .O6(lut2csa[2][18]), 
      .O5(lut2csa[2][19]), 
      .I0(op_pad[10]), 
      .I1(op_pad[11]), 
      .I2(op_pad[12]), 
      .I3(op_pad[13]), 
      .I4(op_pad[14]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h2ab552aab32664cc) // Specify LUT Contents
  ) LUT6_2_inst_2_10 (
      .O6(lut2csa[2][20]), 
      .O5(lut2csa[2][21]), 
      .I0(op_pad[10]), 
      .I1(op_pad[11]), 
      .I2(op_pad[12]), 
      .I3(op_pad[13]), 
      .I4(op_pad[14]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h9692d25adb249b6c) // Specify LUT Contents
  ) LUT6_2_inst_2_11 (
      .O6(lut2csa[2][22]), 
      .O5(lut2csa[2][23]), 
      .I0(op_pad[10]), 
      .I1(op_pad[11]), 
      .I2(op_pad[12]), 
      .I3(op_pad[13]), 
      .I4(op_pad[14]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h496db6dac71c71c6) // Specify LUT Contents
  ) LUT6_2_inst_2_12 (
      .O6(lut2csa[2][24]), 
      .O5(lut2csa[2][25]), 
      .I0(op_pad[10]), 
      .I1(op_pad[11]), 
      .I2(op_pad[12]), 
      .I3(op_pad[13]), 
      .I4(op_pad[14]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h3f03f03e55aaa554) // Specify LUT Contents
  ) LUT6_2_inst_2_13 (
      .O6(lut2csa[2][26]), 
      .O5(lut2csa[2][27]), 
      .I0(op_pad[10]), 
      .I1(op_pad[11]), 
      .I2(op_pad[12]), 
      .I3(op_pad[13]), 
      .I4(op_pad[14]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hdb249b6c92492db6) // Specify LUT Contents
  ) LUT6_2_inst_3_0 (
      .O6(lut2csa[3][0]), 
      .O5(lut2csa[3][1]), 
      .I0(op_pad[15]), 
      .I1(op_pad[16]), 
      .I2(op_pad[17]), 
      .I3(op_pad[18]), 
      .I4(op_pad[19]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h1c71ce38e07e0fc0) // Specify LUT Contents
  ) LUT6_2_inst_3_1 (
      .O6(lut2csa[3][2]), 
      .O5(lut2csa[3][3]), 
      .I0(op_pad[15]), 
      .I1(op_pad[16]), 
      .I2(op_pad[17]), 
      .I3(op_pad[18]), 
      .I4(op_pad[19]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'haad55aaa99ccc666) // Specify LUT Contents
  ) LUT6_2_inst_3_2 (
      .O6(lut2csa[3][4]), 
      .O5(lut2csa[3][5]), 
      .I0(op_pad[15]), 
      .I1(op_pad[16]), 
      .I2(op_pad[17]), 
      .I3(op_pad[18]), 
      .I4(op_pad[19]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hd29694b4e318e738) // Specify LUT Contents
  ) LUT6_2_inst_3_3 (
      .O6(lut2csa[3][6]), 
      .O5(lut2csa[3][7]), 
      .I0(op_pad[15]), 
      .I1(op_pad[16]), 
      .I2(op_pad[17]), 
      .I3(op_pad[18]), 
      .I4(op_pad[19]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hfc1f07c0001ff800) // Specify LUT Contents
  ) LUT6_2_inst_3_4 (
      .O6(lut2csa[3][8]), 
      .O5(lut2csa[3][9]), 
      .I0(op_pad[15]), 
      .I1(op_pad[16]), 
      .I2(op_pad[17]), 
      .I3(op_pad[18]), 
      .I4(op_pad[19]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h554aaaaaccc66666) // Specify LUT Contents
  ) LUT6_2_inst_3_5 (
      .O6(lut2csa[3][10]), 
      .O5(lut2csa[3][11]), 
      .I0(op_pad[15]), 
      .I1(op_pad[16]), 
      .I2(op_pad[17]), 
      .I3(op_pad[18]), 
      .I4(op_pad[19]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h3c3e1e1ea954ab54) // Specify LUT Contents
  ) LUT6_2_inst_3_6 (
      .O6(lut2csa[3][12]), 
      .O5(lut2csa[3][13]), 
      .I0(op_pad[15]), 
      .I1(op_pad[16]), 
      .I2(op_pad[17]), 
      .I3(op_pad[18]), 
      .I4(op_pad[19]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h64cd993249692da4) // Specify LUT Contents
  ) LUT6_2_inst_3_7 (
      .O6(lut2csa[3][14]), 
      .O5(lut2csa[3][15]), 
      .I0(op_pad[15]), 
      .I1(op_pad[16]), 
      .I2(op_pad[17]), 
      .I3(op_pad[18]), 
      .I4(op_pad[19]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h5555555433333332) // Specify LUT Contents
  ) LUT6_2_inst_3_8 (
      .O6(lut2csa[3][16]), 
      .O5(lut2csa[3][17]), 
      .I0(op_pad[15]), 
      .I1(op_pad[16]), 
      .I2(op_pad[17]), 
      .I3(op_pad[18]), 
      .I4(op_pad[19]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'ha5a5a5a4c639c638) // Specify LUT Contents
  ) LUT6_2_inst_3_9 (
      .O6(lut2csa[3][18]), 
      .O5(lut2csa[3][19]), 
      .I0(op_pad[15]), 
      .I1(op_pad[16]), 
      .I2(op_pad[17]), 
      .I3(op_pad[18]), 
      .I4(op_pad[19]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h5294ad6ace739ce6) // Specify LUT Contents
  ) LUT6_2_inst_3_10 (
      .O6(lut2csa[3][20]), 
      .O5(lut2csa[3][21]), 
      .I0(op_pad[15]), 
      .I1(op_pad[16]), 
      .I2(op_pad[17]), 
      .I3(op_pad[18]), 
      .I4(op_pad[19]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h6b5ad6b4739ce738) // Specify LUT Contents
  ) LUT6_2_inst_3_11 (
      .O6(lut2csa[3][22]), 
      .O5(lut2csa[3][23]), 
      .I0(op_pad[15]), 
      .I1(op_pad[16]), 
      .I2(op_pad[17]), 
      .I3(op_pad[18]), 
      .I4(op_pad[19]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h7c1f07c02ab552aa) // Specify LUT Contents
  ) LUT6_2_inst_3_12 (
      .O6(lut2csa[3][24]), 
      .O5(lut2csa[3][25]), 
      .I0(op_pad[15]), 
      .I1(op_pad[16]), 
      .I2(op_pad[17]), 
      .I3(op_pad[18]), 
      .I4(op_pad[19]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hb32664cc9692d25a) // Specify LUT Contents
  ) LUT6_2_inst_3_13 (
      .O6(lut2csa[3][26]), 
      .O5(lut2csa[3][27]), 
      .I0(op_pad[15]), 
      .I1(op_pad[16]), 
      .I2(op_pad[17]), 
      .I3(op_pad[18]), 
      .I4(op_pad[19]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h739ce7380f83e0f8) // Specify LUT Contents
  ) LUT6_2_inst_4_0 (
      .O6(lut2csa[4][0]), 
      .O5(lut2csa[4][1]), 
      .I0(op_pad[20]), 
      .I1(op_pad[21]), 
      .I2(op_pad[22]), 
      .I3(op_pad[23]), 
      .I4(op_pad[24]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h552ab552cc999336) // Specify LUT Contents
  ) LUT6_2_inst_4_1 (
      .O6(lut2csa[4][2]), 
      .O5(lut2csa[4][3]), 
      .I0(op_pad[20]), 
      .I1(op_pad[21]), 
      .I2(op_pad[22]), 
      .I3(op_pad[23]), 
      .I4(op_pad[24]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h692d25a4249b6c92) // Specify LUT Contents
  ) LUT6_2_inst_4_2 (
      .O6(lut2csa[4][4]), 
      .O5(lut2csa[4][5]), 
      .I0(op_pad[20]), 
      .I1(op_pad[21]), 
      .I2(op_pad[22]), 
      .I3(op_pad[23]), 
      .I4(op_pad[24]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hb6d2492438e38e38) // Specify LUT Contents
  ) LUT6_2_inst_4_3 (
      .O6(lut2csa[4][6]), 
      .O5(lut2csa[4][7]), 
      .I0(op_pad[20]), 
      .I1(op_pad[21]), 
      .I2(op_pad[22]), 
      .I3(op_pad[23]), 
      .I4(op_pad[24]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hc0fc0fc0aa555aaa) // Specify LUT Contents
  ) LUT6_2_inst_4_4 (
      .O6(lut2csa[4][8]), 
      .O5(lut2csa[4][9]), 
      .I0(op_pad[20]), 
      .I1(op_pad[21]), 
      .I2(op_pad[22]), 
      .I3(op_pad[23]), 
      .I4(op_pad[24]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h99ccc666d29694b4) // Specify LUT Contents
  ) LUT6_2_inst_4_5 (
      .O6(lut2csa[4][10]), 
      .O5(lut2csa[4][11]), 
      .I0(op_pad[20]), 
      .I1(op_pad[21]), 
      .I2(op_pad[22]), 
      .I3(op_pad[23]), 
      .I4(op_pad[24]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'he318e738fc1f07c0) // Specify LUT Contents
  ) LUT6_2_inst_4_6 (
      .O6(lut2csa[4][12]), 
      .O5(lut2csa[4][13]), 
      .I0(op_pad[20]), 
      .I1(op_pad[21]), 
      .I2(op_pad[22]), 
      .I3(op_pad[23]), 
      .I4(op_pad[24]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h001ff800554aaaaa) // Specify LUT Contents
  ) LUT6_2_inst_4_7 (
      .O6(lut2csa[4][14]), 
      .O5(lut2csa[4][15]), 
      .I0(op_pad[20]), 
      .I1(op_pad[21]), 
      .I2(op_pad[22]), 
      .I3(op_pad[23]), 
      .I4(op_pad[24]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hbf5a815e00a57ffe) // Specify LUT Contents
  ) LUT6_2_inst_4_8 (
      .O6(lut2csa[4][16]), 
      .O5(lut2csa[4][17]), 
      .I0(op_pad[20]), 
      .I1(op_pad[21]), 
      .I2(op_pad[22]), 
      .I3(op_pad[23]), 
      .I4(op_pad[24]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hfffffffefffffffe) // Specify LUT Contents
  ) LUT6_2_inst_4_9 (
      .O6(lut2csa[4][18]), 
      .O5(lut2csa[4][19]), 
      .I0(op_pad[20]), 
      .I1(op_pad[21]), 
      .I2(op_pad[22]), 
      .I3(op_pad[23]), 
      .I4(op_pad[24]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hfffffffe55555554) // Specify LUT Contents
  ) LUT6_2_inst_4_10 (
      .O6(lut2csa[4][20]), 
      .O5(lut2csa[4][21]), 
      .I0(op_pad[20]), 
      .I1(op_pad[21]), 
      .I2(op_pad[22]), 
      .I3(op_pad[23]), 
      .I4(op_pad[24]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h33333332a5a5a5a4) // Specify LUT Contents
  ) LUT6_2_inst_4_11 (
      .O6(lut2csa[4][22]), 
      .O5(lut2csa[4][23]), 
      .I0(op_pad[20]), 
      .I1(op_pad[21]), 
      .I2(op_pad[22]), 
      .I3(op_pad[23]), 
      .I4(op_pad[24]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hc639c6385294ad6a) // Specify LUT Contents
  ) LUT6_2_inst_4_12 (
      .O6(lut2csa[4][24]), 
      .O5(lut2csa[4][25]), 
      .I0(op_pad[20]), 
      .I1(op_pad[21]), 
      .I2(op_pad[22]), 
      .I3(op_pad[23]), 
      .I4(op_pad[24]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hce739ce66b5ad6b4) // Specify LUT Contents
  ) LUT6_2_inst_4_13 (
      .O6(lut2csa[4][26]), 
      .O5(lut2csa[4][27]), 
      .I0(op_pad[20]), 
      .I1(op_pad[21]), 
      .I2(op_pad[22]), 
      .I3(op_pad[23]), 
      .I4(op_pad[24]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'ha5a5a5a4639c639c) // Specify LUT Contents
  ) LUT6_2_inst_5_0 (
      .O6(lut2csa[5][0]), 
      .O5(lut2csa[5][1]), 
      .I0(op_pad[25]), 
      .I1(op_pad[26]), 
      .I2(op_pad[27]), 
      .I3(op_pad[28]), 
      .I4(op_pad[29]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hb5294ad639ce7318) // Specify LUT Contents
  ) LUT6_2_inst_5_1 (
      .O6(lut2csa[5][2]), 
      .O5(lut2csa[5][3]), 
      .I0(op_pad[25]), 
      .I1(op_pad[26]), 
      .I2(op_pad[27]), 
      .I3(op_pad[28]), 
      .I4(op_pad[29]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h94a5294a8c6318c6) // Specify LUT Contents
  ) LUT6_2_inst_5_2 (
      .O6(lut2csa[5][4]), 
      .O5(lut2csa[5][5]), 
      .I0(op_pad[25]), 
      .I1(op_pad[26]), 
      .I2(op_pad[27]), 
      .I3(op_pad[28]), 
      .I4(op_pad[29]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h83e0f83ed54aad54) // Specify LUT Contents
  ) LUT6_2_inst_5_3 (
      .O6(lut2csa[5][6]), 
      .O5(lut2csa[5][7]), 
      .I0(op_pad[25]), 
      .I1(op_pad[26]), 
      .I2(op_pad[27]), 
      .I3(op_pad[28]), 
      .I4(op_pad[29]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h4cd99b32696d2da4) // Specify LUT Contents
  ) LUT6_2_inst_5_4 (
      .O6(lut2csa[5][8]), 
      .O5(lut2csa[5][9]), 
      .I0(op_pad[25]), 
      .I1(op_pad[26]), 
      .I2(op_pad[27]), 
      .I3(op_pad[28]), 
      .I4(op_pad[29]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h24db6492b6924924) // Specify LUT Contents
  ) LUT6_2_inst_5_5 (
      .O6(lut2csa[5][10]), 
      .O5(lut2csa[5][11]), 
      .I0(op_pad[25]), 
      .I1(op_pad[26]), 
      .I2(op_pad[27]), 
      .I3(op_pad[28]), 
      .I4(op_pad[29]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h38e38e38c0fc0fc0) // Specify LUT Contents
  ) LUT6_2_inst_5_6 (
      .O6(lut2csa[5][12]), 
      .O5(lut2csa[5][13]), 
      .I0(op_pad[25]), 
      .I1(op_pad[26]), 
      .I2(op_pad[27]), 
      .I3(op_pad[28]), 
      .I4(op_pad[29]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'haa555aaa99ccc666) // Specify LUT Contents
  ) LUT6_2_inst_5_7 (
      .O6(lut2csa[5][14]), 
      .O5(lut2csa[5][15]), 
      .I0(op_pad[25]), 
      .I1(op_pad[26]), 
      .I2(op_pad[27]), 
      .I3(op_pad[28]), 
      .I4(op_pad[29]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h77333110a5a5a5a4) // Specify LUT Contents
  ) LUT6_2_inst_5_8 (
      .O6(lut2csa[5][16]), 
      .O5(lut2csa[5][17]), 
      .I0(op_pad[25]), 
      .I1(op_pad[26]), 
      .I2(op_pad[27]), 
      .I3(op_pad[28]), 
      .I4(op_pad[29]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h6c936c921c70e38e) // Specify LUT Contents
  ) LUT6_2_inst_5_9 (
      .O6(lut2csa[5][18]), 
      .O5(lut2csa[5][19]), 
      .I0(op_pad[25]), 
      .I1(op_pad[26]), 
      .I2(op_pad[27]), 
      .I3(op_pad[28]), 
      .I4(op_pad[29]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hfc0fe07efc001ffe) // Specify LUT Contents
  ) LUT6_2_inst_5_10 (
      .O6(lut2csa[5][20]), 
      .O5(lut2csa[5][21]), 
      .I0(op_pad[25]), 
      .I1(op_pad[26]), 
      .I2(op_pad[27]), 
      .I3(op_pad[28]), 
      .I4(op_pad[29]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h03fffffefffffffe) // Specify LUT Contents
  ) LUT6_2_inst_5_11 (
      .O6(lut2csa[5][22]), 
      .O5(lut2csa[5][23]), 
      .I0(op_pad[25]), 
      .I1(op_pad[26]), 
      .I2(op_pad[27]), 
      .I3(op_pad[28]), 
      .I4(op_pad[29]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hfffffffefffffffe) // Specify LUT Contents
  ) LUT6_2_inst_5_12 (
      .O6(lut2csa[5][24]), 
      .O5(lut2csa[5][25]), 
      .I0(op_pad[25]), 
      .I1(op_pad[26]), 
      .I2(op_pad[27]), 
      .I3(op_pad[28]), 
      .I4(op_pad[29]), 
      .I5(1'b1)  
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h5555555433333332) // Specify LUT Contents
  ) LUT6_2_inst_5_13 (
      .O6(lut2csa[5][26]), 
      .O5(lut2csa[5][27]), 
      .I0(op_pad[25]), 
      .I1(op_pad[26]), 
      .I2(op_pad[27]), 
      .I3(op_pad[28]), 
      .I4(op_pad[29]), 
      .I5(1'b1)  
  );


  localparam NOF_PARTIALPROD = 6;
  localparam NOF_CSASTAGES = NOF_PARTIALPROD-2;

  logic [28+NOF_CSASTAGES-1:0] carry [NOF_CSASTAGES-1:0];
  logic [28+NOF_CSASTAGES-1:0] sum [NOF_CSASTAGES-1:0];

  logic [28+NOF_CSASTAGES-1:0] mul2csa [NOF_PARTIALPROD-1:0];
  for (genvar i=0; i<NOF_PARTIALPROD; ++i) begin
    assign mul2csa[i] = {'0,lut2csa[i]};
  end
  
  logic [28+NOF_CSASTAGES-1:0] add_tree0;
  logic [28+NOF_CSASTAGES-1:0] add_tree1;
  logic [28+NOF_CSASTAGES-1:0] res_csa_d;
  logic [28+NOF_CSASTAGES-1:0] res_csa_q;


  localparam sim = 1'b1;
  always @(posedge clk_i) begin
    add_tree0 <= mul2csa[0]+mul2csa[1]+mul2csa[2];
    add_tree1 <= mul2csa[3]+mul2csa[4]+mul2csa[5];
    res_csa_q <= add_tree0 + add_tree1;
  end   

  sparse_reduction_268369921
  #(
    .DATA_WIDTH(DATA_WIDTH),
    .QINT(64'd268369921)
  ) u_red (
    .clk_i(clk_i),
    .op_i(res_csa_q),
    .res_o(res_o)   
  );
  
endmodule