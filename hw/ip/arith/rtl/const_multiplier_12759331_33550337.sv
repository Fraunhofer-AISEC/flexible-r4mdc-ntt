// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module const_multiplier_12759331_33550337
#(
    parameter int unsigned DATA_WIDTH = 25
)
(
    input   logic                       clk_i,
    input   logic   [DATA_WIDTH-1:0]    op_i,
    output  logic   [DATA_WIDTH-1:0]    res_o   
);

  logic [24:0] op_pad;
  logic [24:0] lut2csa [4:0];

  assign op_pad = {op_i};

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h4d926d92db4924b6) // Specify LUT Contents
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
      .INIT(64'h6d92492471e38e38) // Specify LUT Contents
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
      .INIT(64'h81fc0fc0ab555aaa) // Specify LUT Contents
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
      .INIT(64'h32666ccc3c7870f0) // Specify LUT Contents
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
      .INIT(64'h952ad5aad9b366cc) // Specify LUT Contents
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
      .INIT(64'h1e3c78f01fc07f00) // Specify LUT Contents
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
      .INIT(64'h526ded92d1e3e38e) // Specify LUT Contents
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
      .INIT(64'h7ab54ad4366cd9b2) // Specify LUT Contents
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
      .INIT(64'h5b496d2436db2492) // Specify LUT Contents
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
      .INIT(64'ha492492438e38e38) // Specify LUT Contents
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
      .INIT(64'hc0fc0fc000fff000) // Specify LUT Contents
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
      .INIT(64'h55aaaaaacc666666) // Specify LUT Contents
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
      .INIT(64'h96b4b4b400000000) // Specify LUT Contents
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
      .INIT(64'hc0fc0fc0c003ffc0) // Specify LUT Contents
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
      .INIT(64'h9555556a1999998c) // Specify LUT Contents
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
      .INIT(64'h4b4b4b5a926d926c) // Specify LUT Contents
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
      .INIT(64'h4924b6da6db6db6c) // Specify LUT Contents
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
      .INIT(64'h71c71c7081f81f80) // Specify LUT Contents
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
      .INIT(64'hab554aaa32666ccc) // Specify LUT Contents
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
      .INIT(64'hfc847f3095ad256a) // Specify LUT Contents
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
      .INIT(64'h8c631ce683e0fc1e) // Specify LUT Contents
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
      .INIT(64'hd54aa9544cd99b32) // Specify LUT Contents
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
      .INIT(64'hc3c7870e6a952a54) // Specify LUT Contents
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
      .INIT(64'h264c99324b692da4) // Specify LUT Contents
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
      .INIT(64'h26db6492b4924924) // Specify LUT Contents
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
      .INIT(64'h38e38e3800000000) // Specify LUT Contents
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
      .INIT(64'h264c99326d25b496) // Specify LUT Contents
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
      .INIT(64'h49b6d924db6db492) // Specify LUT Contents
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
      .INIT(64'hc71c738e3f03f07e) // Specify LUT Contents
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
      .INIT(64'hff000ffeaa555554) // Specify LUT Contents
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
      .INIT(64'h33999998694b4b4a) // Specify LUT Contents
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
      .INIT(64'hb26d926c6924b6da) // Specify LUT Contents
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
      .INIT(64'h6bfa425e3eaaa8f4) // Specify LUT Contents
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
      .INIT(64'he66666321e1e1e0e) // Specify LUT Contents
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
      .INIT(64'hab54ab54cc673398) // Specify LUT Contents
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
      .INIT(64'ha52d694a9ce318c6) // Specify LUT Contents
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
      .INIT(64'h83e0f83ed54aad54) // Specify LUT Contents
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
      .INIT(64'h4cd99b32c3c7870e) // Specify LUT Contents
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
      .INIT(64'h6a952a5400000000) // Specify LUT Contents
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
      .INIT(64'h83e0f83e56aa556a) // Specify LUT Contents
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
      .INIT(64'h9b33664c1c3c7870) // Specify LUT Contents
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
      .INIT(64'hb56ad52ad9b3664c) // Specify LUT Contents
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
      .INIT(64'hb496d2dad9249b6c) // Specify LUT Contents
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
      .INIT(64'h4b6db6dac71c71c6) // Specify LUT Contents
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
      .INIT(64'h3f03f03eff000ffe) // Specify LUT Contents
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
      .INIT(64'h29b5ad6a649364d8) // Specify LUT Contents
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
      .INIT(64'hb6da496c38e38e70) // Specify LUT Contents
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
      .INIT(64'hc0fc0f8000fff000) // Specify LUT Contents
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
      .INIT(64'h55aaaaaacc666666) // Specify LUT Contents
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
      .INIT(64'h3c1e1e1ea954ab54) // Specify LUT Contents
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
      .INIT(64'hce673398a52d694a) // Specify LUT Contents
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
      .INIT(64'h9ce318c600000000) // Specify LUT Contents
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
      .INIT(64'h3c1e1e1e954ab54a) // Specify LUT Contents
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
      .INIT(64'h73398cc65a52d694) // Specify LUT Contents
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
      .INIT(64'h639ce7187c1f07e0) // Specify LUT Contents
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
      .INIT(64'h2ab552aab32664cc) // Specify LUT Contents
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
      .INIT(64'h3c3878f0956ad5aa) // Specify LUT Contents
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
      .INIT(64'hd9b366ccb496d25a) // Specify LUT Contents
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
      .INIT(64'he53a8572fa3d0782) // Specify LUT Contents
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
      .INIT(64'h003ff802556aaaa8) // Specify LUT Contents
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
      .INIT(64'hcce6666696b4b4b4) // Specify LUT Contents
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
      .INIT(64'h4d926d9296db4924) // Specify LUT Contents
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
      .INIT(64'h18e38e38e0fc0fc0) // Specify LUT Contents
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
      .INIT(64'h00fff00055aaaaaa) // Specify LUT Contents
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
      .INIT(64'hcc66666600000000) // Specify LUT Contents
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


  localparam NOF_PARTIALPROD = 5;
  localparam NOF_CSASTAGES = NOF_PARTIALPROD-2;

  logic [25+NOF_CSASTAGES-1:0] carry [NOF_CSASTAGES-1:0];
  logic [25+NOF_CSASTAGES-1:0] sum [NOF_CSASTAGES-1:0];

  logic [25+NOF_CSASTAGES-1:0] mul2csa [NOF_PARTIALPROD-1:0];
  for (genvar i=0; i<NOF_PARTIALPROD; ++i) begin
    assign mul2csa[i] = {'0,lut2csa[i]};
  end
  
  logic [25+NOF_CSASTAGES-1:0] res_csa_d;
  logic [25+NOF_CSASTAGES-1:0] res_csa_q;

  always @(posedge clk_i) begin
    res_csa_q <= res_csa_d;
  end   

  assign res_csa_d = mul2csa[0]+mul2csa[1]+mul2csa[2]+mul2csa[3]+mul2csa[4];

  sparse_reduction_33550337
  #(
    .DATA_WIDTH(DATA_WIDTH),
    .QINT(33550337)
  ) u_red (
    .clk_i(clk_i),
    .op_i(res_csa_q),
    .res_o(res_o)   
  );


endmodule
