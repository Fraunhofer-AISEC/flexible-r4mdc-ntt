// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module const_multiplier_37361560_134215681
#(
    parameter int unsigned DATA_WIDTH = 27
)
(
    input   logic                       clk_i,
    input   logic   [DATA_WIDTH-1:0]    op_i,
    output  logic   [DATA_WIDTH-1:0]    res_o   
);

  logic [29:0] op_pad;
  assign op_pad = {3'b0, op_i};
  logic [27:0] lut2csa [5:0];

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h1c3c78f003fc07f0) // Specify LUT Contents
  ) LUT6_2_inst_0_0 (
      .O6(lut2csa[0][0]), // 1-bit LUT6 output
      .O5(lut2csa[0][1]), // 1-bit lower LUT5 output
      .I0(op_pad[0]), // 1-bit LUT input
      .I1(op_pad[1]), // 1-bit LUT input
      .I2(op_pad[2]), // 1-bit LUT input
      .I3(op_pad[3]), // 1-bit LUT input
      .I4(op_pad[4]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h0003fff05555555a) // Specify LUT Contents
  ) LUT6_2_inst_0_1 (
      .O6(lut2csa[0][2]), // 1-bit LUT6 output
      .O5(lut2csa[0][3]), // 1-bit lower LUT5 output
      .I0(op_pad[0]), // 1-bit LUT input
      .I1(op_pad[1]), // 1-bit LUT input
      .I2(op_pad[2]), // 1-bit LUT input
      .I3(op_pad[3]), // 1-bit LUT input
      .I4(op_pad[4]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h33333336a5a5a5a4) // Specify LUT Contents
  ) LUT6_2_inst_0_2 (
      .O6(lut2csa[0][4]), // 1-bit LUT6 output
      .O5(lut2csa[0][5]), // 1-bit lower LUT5 output
      .I0(op_pad[0]), // 1-bit LUT input
      .I1(op_pad[1]), // 1-bit LUT input
      .I2(op_pad[2]), // 1-bit LUT input
      .I3(op_pad[3]), // 1-bit LUT input
      .I4(op_pad[4]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hc639c6385294ad6a) // Specify LUT Contents
  ) LUT6_2_inst_0_3 (
      .O6(lut2csa[0][6]), // 1-bit LUT6 output
      .O5(lut2csa[0][7]), // 1-bit lower LUT5 output
      .I0(op_pad[0]), // 1-bit LUT input
      .I1(op_pad[1]), // 1-bit LUT input
      .I2(op_pad[2]), // 1-bit LUT input
      .I3(op_pad[3]), // 1-bit LUT input
      .I4(op_pad[4]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hce739ce6c1f07c1e) // Specify LUT Contents
  ) LUT6_2_inst_0_4 (
      .O6(lut2csa[0][8]), // 1-bit LUT6 output
      .O5(lut2csa[0][9]), // 1-bit lower LUT5 output
      .I0(op_pad[0]), // 1-bit LUT input
      .I1(op_pad[1]), // 1-bit LUT input
      .I2(op_pad[2]), // 1-bit LUT input
      .I3(op_pad[3]), // 1-bit LUT input
      .I4(op_pad[4]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h3ff003feb6992da4) // Specify LUT Contents
  ) LUT6_2_inst_0_5 (
      .O6(lut2csa[0][10]), // 1-bit LUT6 output
      .O5(lut2csa[0][11]), // 1-bit lower LUT5 output
      .I0(op_pad[0]), // 1-bit LUT input
      .I1(op_pad[1]), // 1-bit LUT input
      .I2(op_pad[2]), // 1-bit LUT input
      .I3(op_pad[3]), // 1-bit LUT input
      .I4(op_pad[4]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h8e771c622b5a56b4) // Specify LUT Contents
  ) LUT6_2_inst_0_6 (
      .O6(lut2csa[0][12]), // 1-bit LUT6 output
      .O5(lut2csa[0][13]), // 1-bit lower LUT5 output
      .I0(op_pad[0]), // 1-bit LUT input
      .I1(op_pad[1]), // 1-bit LUT input
      .I2(op_pad[2]), // 1-bit LUT input
      .I3(op_pad[3]), // 1-bit LUT input
      .I4(op_pad[4]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h339c67383c1f87c0) // Specify LUT Contents
  ) LUT6_2_inst_0_7 (
      .O6(lut2csa[0][14]), // 1-bit LUT6 output
      .O5(lut2csa[0][15]), // 1-bit lower LUT5 output
      .I0(op_pad[0]), // 1-bit LUT input
      .I1(op_pad[1]), // 1-bit LUT input
      .I2(op_pad[2]), // 1-bit LUT input
      .I3(op_pad[3]), // 1-bit LUT input
      .I4(op_pad[4]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hc01ff800554aaaaa) // Specify LUT Contents
  ) LUT6_2_inst_0_8 (
      .O6(lut2csa[0][16]), // 1-bit LUT6 output
      .O5(lut2csa[0][17]), // 1-bit lower LUT5 output
      .I0(op_pad[0]), // 1-bit LUT input
      .I1(op_pad[1]), // 1-bit LUT input
      .I2(op_pad[2]), // 1-bit LUT input
      .I3(op_pad[3]), // 1-bit LUT input
      .I4(op_pad[4]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h666cccccd2da5a5a) // Specify LUT Contents
  ) LUT6_2_inst_0_9 (
      .O6(lut2csa[0][18]), // 1-bit LUT6 output
      .O5(lut2csa[0][19]), // 1-bit lower LUT5 output
      .I0(op_pad[0]), // 1-bit LUT input
      .I1(op_pad[1]), // 1-bit LUT input
      .I2(op_pad[2]), // 1-bit LUT input
      .I3(op_pad[3]), // 1-bit LUT input
      .I4(op_pad[4]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h31c639c60fc1f83e) // Specify LUT Contents
  ) LUT6_2_inst_0_10 (
      .O6(lut2csa[0][20]), // 1-bit LUT6 output
      .O5(lut2csa[0][21]), // 1-bit lower LUT5 output
      .I0(op_pad[0]), // 1-bit LUT input
      .I1(op_pad[1]), // 1-bit LUT input
      .I2(op_pad[2]), // 1-bit LUT input
      .I3(op_pad[3]), // 1-bit LUT input
      .I4(op_pad[4]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h556aad5466733198) // Specify LUT Contents
  ) LUT6_2_inst_0_11 (
      .O6(lut2csa[0][22]), // 1-bit LUT6 output
      .O5(lut2csa[0][23]), // 1-bit lower LUT5 output
      .I0(op_pad[0]), // 1-bit LUT input
      .I1(op_pad[1]), // 1-bit LUT input
      .I2(op_pad[2]), // 1-bit LUT input
      .I3(op_pad[3]), // 1-bit LUT input
      .I4(op_pad[4]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h8783c1e052a954aa) // Specify LUT Contents
  ) LUT6_2_inst_0_12 (
      .O6(lut2csa[0][24]), // 1-bit LUT6 output
      .O5(lut2csa[0][25]), // 1-bit lower LUT5 output
      .I0(op_pad[0]), // 1-bit LUT input
      .I1(op_pad[1]), // 1-bit LUT input
      .I2(op_pad[2]), // 1-bit LUT input
      .I3(op_pad[3]), // 1-bit LUT input
      .I4(op_pad[4]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h9b3266cc00000000) // Specify LUT Contents
  ) LUT6_2_inst_0_13 (
      .O6(lut2csa[0][26]), // 1-bit LUT6 output
      .O5(lut2csa[0][27]), // 1-bit lower LUT5 output
      .I0(op_pad[0]), // 1-bit LUT input
      .I1(op_pad[1]), // 1-bit LUT input
      .I2(op_pad[2]), // 1-bit LUT input
      .I3(op_pad[3]), // 1-bit LUT input
      .I4(op_pad[4]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h556aad5433199ccc) // Specify LUT Contents
  ) LUT6_2_inst_1_0 (
      .O6(lut2csa[1][0]), // 1-bit LUT6 output
      .O5(lut2csa[1][1]), // 1-bit lower LUT5 output
      .I0(op_pad[5]), // 1-bit LUT input
      .I1(op_pad[6]), // 1-bit LUT input
      .I2(op_pad[7]), // 1-bit LUT input
      .I3(op_pad[8]), // 1-bit LUT input
      .I4(op_pad[9]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hf0f87c3ca552a956) // Specify LUT Contents
  ) LUT6_2_inst_1_1 (
      .O6(lut2csa[1][2]), // 1-bit LUT6 output
      .O5(lut2csa[1][3]), // 1-bit lower LUT5 output
      .I0(op_pad[5]), // 1-bit LUT input
      .I1(op_pad[6]), // 1-bit LUT input
      .I2(op_pad[7]), // 1-bit LUT input
      .I3(op_pad[8]), // 1-bit LUT input
      .I4(op_pad[9]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h6cc99b32e3c7870e) // Specify LUT Contents
  ) LUT6_2_inst_1_2 (
      .O6(lut2csa[1][4]), // 1-bit LUT6 output
      .O5(lut2csa[1][5]), // 1-bit lower LUT5 output
      .I0(op_pad[5]), // 1-bit LUT input
      .I1(op_pad[6]), // 1-bit LUT input
      .I2(op_pad[7]), // 1-bit LUT input
      .I3(op_pad[8]), // 1-bit LUT input
      .I4(op_pad[9]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'he03f80fee0007ffe) // Specify LUT Contents
  ) LUT6_2_inst_1_3 (
      .O6(lut2csa[1][6]), // 1-bit LUT6 output
      .O5(lut2csa[1][7]), // 1-bit lower LUT5 output
      .I0(op_pad[5]), // 1-bit LUT input
      .I1(op_pad[6]), // 1-bit LUT input
      .I2(op_pad[7]), // 1-bit LUT input
      .I3(op_pad[8]), // 1-bit LUT input
      .I4(op_pad[9]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hb555555493333332) // Specify LUT Contents
  ) LUT6_2_inst_1_4 (
      .O6(lut2csa[1][8]), // 1-bit LUT6 output
      .O5(lut2csa[1][9]), // 1-bit lower LUT5 output
      .I0(op_pad[5]), // 1-bit LUT input
      .I1(op_pad[6]), // 1-bit LUT input
      .I2(op_pad[7]), // 1-bit LUT input
      .I3(op_pad[8]), // 1-bit LUT input
      .I4(op_pad[9]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h25a5a5a493536b6c) // Specify LUT Contents
  ) LUT6_2_inst_1_5 (
      .O6(lut2csa[1][10]), // 1-bit LUT6 output
      .O5(lut2csa[1][11]), // 1-bit lower LUT5 output
      .I0(op_pad[5]), // 1-bit LUT input
      .I1(op_pad[6]), // 1-bit LUT input
      .I2(op_pad[7]), // 1-bit LUT input
      .I3(op_pad[8]), // 1-bit LUT input
      .I4(op_pad[9]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h70cf18e20fc0f81e) // Specify LUT Contents
  ) LUT6_2_inst_1_6 (
      .O6(lut2csa[1][12]), // 1-bit LUT6 output
      .O5(lut2csa[1][13]), // 1-bit lower LUT5 output
      .I0(op_pad[5]), // 1-bit LUT input
      .I1(op_pad[6]), // 1-bit LUT input
      .I2(op_pad[7]), // 1-bit LUT input
      .I3(op_pad[8]), // 1-bit LUT input
      .I4(op_pad[9]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h556aad5466733198) // Specify LUT Contents
  ) LUT6_2_inst_1_7 (
      .O6(lut2csa[1][14]), // 1-bit LUT6 output
      .O5(lut2csa[1][15]), // 1-bit lower LUT5 output
      .I0(op_pad[5]), // 1-bit LUT input
      .I1(op_pad[6]), // 1-bit LUT input
      .I2(op_pad[7]), // 1-bit LUT input
      .I3(op_pad[8]), // 1-bit LUT input
      .I4(op_pad[9]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h2d296b4a1ce718c6) // Specify LUT Contents
  ) LUT6_2_inst_1_8 (
      .O6(lut2csa[1][16]), // 1-bit LUT6 output
      .O5(lut2csa[1][17]), // 1-bit lower LUT5 output
      .I0(op_pad[5]), // 1-bit LUT input
      .I1(op_pad[6]), // 1-bit LUT input
      .I2(op_pad[7]), // 1-bit LUT input
      .I3(op_pad[8]), // 1-bit LUT input
      .I4(op_pad[9]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'ha94a5294318c6318) // Specify LUT Contents
  ) LUT6_2_inst_1_9 (
      .O6(lut2csa[1][18]), // 1-bit LUT6 output
      .O5(lut2csa[1][19]), // 1-bit lower LUT5 output
      .I0(op_pad[5]), // 1-bit LUT input
      .I1(op_pad[6]), // 1-bit LUT input
      .I2(op_pad[7]), // 1-bit LUT input
      .I3(op_pad[8]), // 1-bit LUT input
      .I4(op_pad[9]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h3e0f83e0c00ffc00) // Specify LUT Contents
  ) LUT6_2_inst_1_10 (
      .O6(lut2csa[1][20]), // 1-bit LUT6 output
      .O5(lut2csa[1][21]), // 1-bit lower LUT5 output
      .I0(op_pad[5]), // 1-bit LUT input
      .I1(op_pad[6]), // 1-bit LUT input
      .I2(op_pad[7]), // 1-bit LUT input
      .I3(op_pad[8]), // 1-bit LUT input
      .I4(op_pad[9]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h555aaaaa666ccccc) // Specify LUT Contents
  ) LUT6_2_inst_1_11 (
      .O6(lut2csa[1][22]), // 1-bit LUT6 output
      .O5(lut2csa[1][23]), // 1-bit lower LUT5 output
      .I0(op_pad[5]), // 1-bit LUT input
      .I1(op_pad[6]), // 1-bit LUT input
      .I2(op_pad[7]), // 1-bit LUT input
      .I3(op_pad[8]), // 1-bit LUT input
      .I4(op_pad[9]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hd2da5a5a31c639c6) // Specify LUT Contents
  ) LUT6_2_inst_1_12 (
      .O6(lut2csa[1][24]), // 1-bit LUT6 output
      .O5(lut2csa[1][25]), // 1-bit lower LUT5 output
      .I0(op_pad[5]), // 1-bit LUT input
      .I1(op_pad[6]), // 1-bit LUT input
      .I2(op_pad[7]), // 1-bit LUT input
      .I3(op_pad[8]), // 1-bit LUT input
      .I4(op_pad[9]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h0fc1f83e00000000) // Specify LUT Contents
  ) LUT6_2_inst_1_13 (
      .O6(lut2csa[1][26]), // 1-bit LUT6 output
      .O5(lut2csa[1][27]), // 1-bit lower LUT5 output
      .I0(op_pad[5]), // 1-bit LUT input
      .I1(op_pad[6]), // 1-bit LUT input
      .I2(op_pad[7]), // 1-bit LUT input
      .I3(op_pad[8]), // 1-bit LUT input
      .I4(op_pad[9]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h555aaaaa33366666) // Specify LUT Contents
  ) LUT6_2_inst_2_0 (
      .O6(lut2csa[2][0]), // 1-bit LUT6 output
      .O5(lut2csa[2][1]), // 1-bit lower LUT5 output
      .I0(op_pad[10]), // 1-bit LUT input
      .I1(op_pad[11]), // 1-bit LUT input
      .I2(op_pad[12]), // 1-bit LUT input
      .I3(op_pad[13]), // 1-bit LUT input
      .I4(op_pad[14]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'ha5a4b4b4c638c738) // Specify LUT Contents
  ) LUT6_2_inst_2_1 (
      .O6(lut2csa[2][2]), // 1-bit LUT6 output
      .O5(lut2csa[2][3]), // 1-bit lower LUT5 output
      .I0(op_pad[10]), // 1-bit LUT input
      .I1(op_pad[11]), // 1-bit LUT input
      .I2(op_pad[12]), // 1-bit LUT input
      .I3(op_pad[13]), // 1-bit LUT input
      .I4(op_pad[14]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hf83f07c0aa9552aa) // Specify LUT Contents
  ) LUT6_2_inst_2_2 (
      .O6(lut2csa[2][4]), // 1-bit LUT6 output
      .O5(lut2csa[2][5]), // 1-bit lower LUT5 output
      .I0(op_pad[10]), // 1-bit LUT input
      .I1(op_pad[11]), // 1-bit LUT input
      .I2(op_pad[12]), // 1-bit LUT input
      .I3(op_pad[13]), // 1-bit LUT input
      .I4(op_pad[14]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h998cce66787c3e1e) // Specify LUT Contents
  ) LUT6_2_inst_2_3 (
      .O6(lut2csa[2][6]), // 1-bit LUT6 output
      .O5(lut2csa[2][7]), // 1-bit lower LUT5 output
      .I0(op_pad[10]), // 1-bit LUT input
      .I1(op_pad[11]), // 1-bit LUT input
      .I2(op_pad[12]), // 1-bit LUT input
      .I3(op_pad[13]), // 1-bit LUT input
      .I4(op_pad[14]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'had56ab5464cd9932) // Specify LUT Contents
  ) LUT6_2_inst_2_4 (
      .O6(lut2csa[2][8]), // 1-bit LUT6 output
      .O5(lut2csa[2][9]), // 1-bit lower LUT5 output
      .I0(op_pad[10]), // 1-bit LUT input
      .I1(op_pad[11]), // 1-bit LUT input
      .I2(op_pad[12]), // 1-bit LUT input
      .I3(op_pad[13]), // 1-bit LUT input
      .I4(op_pad[14]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'he3c3870eb5652a54) // Specify LUT Contents
  ) LUT6_2_inst_2_5 (
      .O6(lut2csa[2][10]), // 1-bit LUT6 output
      .O5(lut2csa[2][11]), // 1-bit lower LUT5 output
      .I0(op_pad[10]), // 1-bit LUT input
      .I1(op_pad[11]), // 1-bit LUT input
      .I2(op_pad[12]), // 1-bit LUT input
      .I3(op_pad[13]), // 1-bit LUT input
      .I4(op_pad[14]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hc67633980787c3e0) // Specify LUT Contents
  ) LUT6_2_inst_2_6 (
      .O6(lut2csa[2][12]), // 1-bit LUT6 output
      .O5(lut2csa[2][13]), // 1-bit lower LUT5 output
      .I0(op_pad[10]), // 1-bit LUT input
      .I1(op_pad[11]), // 1-bit LUT input
      .I2(op_pad[12]), // 1-bit LUT input
      .I3(op_pad[13]), // 1-bit LUT input
      .I4(op_pad[14]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h52ad56aa9b3664cc) // Specify LUT Contents
  ) LUT6_2_inst_2_7 (
      .O6(lut2csa[2][14]), // 1-bit LUT6 output
      .O5(lut2csa[2][15]), // 1-bit lower LUT5 output
      .I0(op_pad[10]), // 1-bit LUT input
      .I1(op_pad[11]), // 1-bit LUT input
      .I2(op_pad[12]), // 1-bit LUT input
      .I3(op_pad[13]), // 1-bit LUT input
      .I4(op_pad[14]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hb692d25a718e31c6) // Specify LUT Contents
  ) LUT6_2_inst_2_8 (
      .O6(lut2csa[2][16]), // 1-bit LUT6 output
      .O5(lut2csa[2][17]), // 1-bit lower LUT5 output
      .I0(op_pad[10]), // 1-bit LUT input
      .I1(op_pad[11]), // 1-bit LUT input
      .I2(op_pad[12]), // 1-bit LUT input
      .I3(op_pad[13]), // 1-bit LUT input
      .I4(op_pad[14]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h0f81f03e552aa554) // Specify LUT Contents
  ) LUT6_2_inst_2_9 (
      .O6(lut2csa[2][18]), // 1-bit LUT6 output
      .O5(lut2csa[2][19]), // 1-bit lower LUT5 output
      .I0(op_pad[10]), // 1-bit LUT input
      .I1(op_pad[11]), // 1-bit LUT input
      .I2(op_pad[12]), // 1-bit LUT input
      .I3(op_pad[13]), // 1-bit LUT input
      .I4(op_pad[14]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h663339982d696b4a) // Specify LUT Contents
  ) LUT6_2_inst_2_10 (
      .O6(lut2csa[2][20]), // 1-bit LUT6 output
      .O5(lut2csa[2][21]), // 1-bit lower LUT5 output
      .I0(op_pad[10]), // 1-bit LUT input
      .I1(op_pad[11]), // 1-bit LUT input
      .I2(op_pad[12]), // 1-bit LUT input
      .I3(op_pad[13]), // 1-bit LUT input
      .I4(op_pad[14]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h1ce718c6a94a5294) // Specify LUT Contents
  ) LUT6_2_inst_2_11 (
      .O6(lut2csa[2][22]), // 1-bit LUT6 output
      .O5(lut2csa[2][23]), // 1-bit lower LUT5 output
      .I0(op_pad[10]), // 1-bit LUT input
      .I1(op_pad[11]), // 1-bit LUT input
      .I2(op_pad[12]), // 1-bit LUT input
      .I3(op_pad[13]), // 1-bit LUT input
      .I4(op_pad[14]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h318c63183e0f83e0) // Specify LUT Contents
  ) LUT6_2_inst_2_12 (
      .O6(lut2csa[2][24]), // 1-bit LUT6 output
      .O5(lut2csa[2][25]), // 1-bit lower LUT5 output
      .I0(op_pad[10]), // 1-bit LUT input
      .I1(op_pad[11]), // 1-bit LUT input
      .I2(op_pad[12]), // 1-bit LUT input
      .I3(op_pad[13]), // 1-bit LUT input
      .I4(op_pad[14]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hc00ffc0000000000) // Specify LUT Contents
  ) LUT6_2_inst_2_13 (
      .O6(lut2csa[2][26]), // 1-bit LUT6 output
      .O5(lut2csa[2][27]), // 1-bit lower LUT5 output
      .I0(op_pad[10]), // 1-bit LUT input
      .I1(op_pad[11]), // 1-bit LUT input
      .I2(op_pad[12]), // 1-bit LUT input
      .I3(op_pad[13]), // 1-bit LUT input
      .I4(op_pad[14]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h1ce718c6b5ad4a52) // Specify LUT Contents
  ) LUT6_2_inst_3_0 (
      .O6(lut2csa[3][0]), // 1-bit LUT6 output
      .O5(lut2csa[3][1]), // 1-bit lower LUT5 output
      .I0(op_pad[15]), // 1-bit LUT input
      .I1(op_pad[16]), // 1-bit LUT input
      .I2(op_pad[17]), // 1-bit LUT input
      .I3(op_pad[18]), // 1-bit LUT input
      .I4(op_pad[19]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h8c6339ce83e0f83e) // Specify LUT Contents
  ) LUT6_2_inst_3_1 (
      .O6(lut2csa[3][2]), // 1-bit LUT6 output
      .O5(lut2csa[3][3]), // 1-bit lower LUT5 output
      .I0(op_pad[15]), // 1-bit LUT input
      .I1(op_pad[16]), // 1-bit LUT input
      .I2(op_pad[17]), // 1-bit LUT input
      .I3(op_pad[18]), // 1-bit LUT input
      .I4(op_pad[19]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h7fe007feaab55554) // Specify LUT Contents
  ) LUT6_2_inst_3_2 (
      .O6(lut2csa[3][4]), // 1-bit LUT6 output
      .O5(lut2csa[3][5]), // 1-bit lower LUT5 output
      .I0(op_pad[15]), // 1-bit LUT input
      .I1(op_pad[16]), // 1-bit LUT input
      .I2(op_pad[17]), // 1-bit LUT input
      .I3(op_pad[18]), // 1-bit LUT input
      .I4(op_pad[19]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h999333322d25a5a4) // Specify LUT Contents
  ) LUT6_2_inst_3_3 (
      .O6(lut2csa[3][6]), // 1-bit LUT6 output
      .O5(lut2csa[3][7]), // 1-bit lower LUT5 output
      .I0(op_pad[15]), // 1-bit LUT input
      .I1(op_pad[16]), // 1-bit LUT input
      .I2(op_pad[17]), // 1-bit LUT input
      .I3(op_pad[18]), // 1-bit LUT input
      .I4(op_pad[19]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hce39c638f03e07c0) // Specify LUT Contents
  ) LUT6_2_inst_3_4 (
      .O6(lut2csa[3][8]), // 1-bit LUT6 output
      .O5(lut2csa[3][9]), // 1-bit lower LUT5 output
      .I0(op_pad[15]), // 1-bit LUT input
      .I1(op_pad[16]), // 1-bit LUT input
      .I2(op_pad[17]), // 1-bit LUT input
      .I3(op_pad[18]), // 1-bit LUT input
      .I4(op_pad[19]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'haa9552aa856bd6a0) // Specify LUT Contents
  ) LUT6_2_inst_3_5 (
      .O6(lut2csa[3][10]), // 1-bit LUT6 output
      .O5(lut2csa[3][11]), // 1-bit lower LUT5 output
      .I0(op_pad[15]), // 1-bit LUT input
      .I1(op_pad[16]), // 1-bit LUT input
      .I2(op_pad[17]), // 1-bit LUT input
      .I3(op_pad[18]), // 1-bit LUT input
      .I4(op_pad[19]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hc9b264cca496d25a) // Specify LUT Contents
  ) LUT6_2_inst_3_6 (
      .O6(lut2csa[3][12]), // 1-bit LUT6 output
      .O5(lut2csa[3][13]), // 1-bit lower LUT5 output
      .I0(op_pad[15]), // 1-bit LUT input
      .I1(op_pad[16]), // 1-bit LUT input
      .I2(op_pad[17]), // 1-bit LUT input
      .I3(op_pad[18]), // 1-bit LUT input
      .I4(op_pad[19]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h638e31c61f81f03e) // Specify LUT Contents
  ) LUT6_2_inst_3_7 (
      .O6(lut2csa[3][14]), // 1-bit LUT6 output
      .O5(lut2csa[3][15]), // 1-bit lower LUT5 output
      .I0(op_pad[15]), // 1-bit LUT input
      .I1(op_pad[16]), // 1-bit LUT input
      .I2(op_pad[17]), // 1-bit LUT input
      .I3(op_pad[18]), // 1-bit LUT input
      .I4(op_pad[19]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h552aa55466333998) // Specify LUT Contents
  ) LUT6_2_inst_3_8 (
      .O6(lut2csa[3][16]), // 1-bit LUT6 output
      .O5(lut2csa[3][17]), // 1-bit lower LUT5 output
      .I0(op_pad[15]), // 1-bit LUT input
      .I1(op_pad[16]), // 1-bit LUT input
      .I2(op_pad[17]), // 1-bit LUT input
      .I3(op_pad[18]), // 1-bit LUT input
      .I4(op_pad[19]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h87c3c1e052a954aa) // Specify LUT Contents
  ) LUT6_2_inst_3_9 (
      .O6(lut2csa[3][18]), // 1-bit LUT6 output
      .O5(lut2csa[3][19]), // 1-bit lower LUT5 output
      .I0(op_pad[15]), // 1-bit LUT input
      .I1(op_pad[16]), // 1-bit LUT input
      .I2(op_pad[17]), // 1-bit LUT input
      .I3(op_pad[18]), // 1-bit LUT input
      .I4(op_pad[19]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h9b3266ccb696d25a) // Specify LUT Contents
  ) LUT6_2_inst_3_10 (
      .O6(lut2csa[3][20]), // 1-bit LUT6 output
      .O5(lut2csa[3][21]), // 1-bit lower LUT5 output
      .I0(op_pad[15]), // 1-bit LUT input
      .I1(op_pad[16]), // 1-bit LUT input
      .I2(op_pad[17]), // 1-bit LUT input
      .I3(op_pad[18]), // 1-bit LUT input
      .I4(op_pad[19]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h718e31c60f81f03e) // Specify LUT Contents
  ) LUT6_2_inst_3_11 (
      .O6(lut2csa[3][22]), // 1-bit LUT6 output
      .O5(lut2csa[3][23]), // 1-bit lower LUT5 output
      .I0(op_pad[15]), // 1-bit LUT input
      .I1(op_pad[16]), // 1-bit LUT input
      .I2(op_pad[17]), // 1-bit LUT input
      .I3(op_pad[18]), // 1-bit LUT input
      .I4(op_pad[19]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h552aa55466333998) // Specify LUT Contents
  ) LUT6_2_inst_3_12 (
      .O6(lut2csa[3][24]), // 1-bit LUT6 output
      .O5(lut2csa[3][25]), // 1-bit lower LUT5 output
      .I0(op_pad[15]), // 1-bit LUT input
      .I1(op_pad[16]), // 1-bit LUT input
      .I2(op_pad[17]), // 1-bit LUT input
      .I3(op_pad[18]), // 1-bit LUT input
      .I4(op_pad[19]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h2d696b4a00000000) // Specify LUT Contents
  ) LUT6_2_inst_3_13 (
      .O6(lut2csa[3][26]), // 1-bit LUT6 output
      .O5(lut2csa[3][27]), // 1-bit lower LUT5 output
      .I0(op_pad[15]), // 1-bit LUT input
      .I1(op_pad[16]), // 1-bit LUT input
      .I2(op_pad[17]), // 1-bit LUT input
      .I3(op_pad[18]), // 1-bit LUT input
      .I4(op_pad[19]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h718e31c67e0fc1f8) // Specify LUT Contents
  ) LUT6_2_inst_4_0 (
      .O6(lut2csa[4][0]), // 1-bit LUT6 output
      .O5(lut2csa[4][1]), // 1-bit lower LUT5 output
      .I0(op_pad[20]), // 1-bit LUT input
      .I1(op_pad[21]), // 1-bit LUT input
      .I2(op_pad[22]), // 1-bit LUT input
      .I3(op_pad[23]), // 1-bit LUT input
      .I4(op_pad[24]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h2aa554aa199ccc66) // Specify LUT Contents
  ) LUT6_2_inst_4_1 (
      .O6(lut2csa[4][2]), // 1-bit LUT6 output
      .O5(lut2csa[4][3]), // 1-bit lower LUT5 output
      .I0(op_pad[20]), // 1-bit LUT input
      .I1(op_pad[21]), // 1-bit LUT input
      .I2(op_pad[22]), // 1-bit LUT input
      .I3(op_pad[23]), // 1-bit LUT input
      .I4(op_pad[24]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h52d696b46318e738) // Specify LUT Contents
  ) LUT6_2_inst_4_2 (
      .O6(lut2csa[4][4]), // 1-bit LUT6 output
      .O5(lut2csa[4][5]), // 1-bit lower LUT5 output
      .I0(op_pad[20]), // 1-bit LUT input
      .I1(op_pad[21]), // 1-bit LUT input
      .I2(op_pad[22]), // 1-bit LUT input
      .I3(op_pad[23]), // 1-bit LUT input
      .I4(op_pad[24]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hd6b5ad6ace739ce6) // Specify LUT Contents
  ) LUT6_2_inst_4_3 (
      .O6(lut2csa[4][6]), // 1-bit LUT6 output
      .O5(lut2csa[4][7]), // 1-bit lower LUT5 output
      .I0(op_pad[20]), // 1-bit LUT input
      .I1(op_pad[21]), // 1-bit LUT input
      .I2(op_pad[22]), // 1-bit LUT input
      .I3(op_pad[23]), // 1-bit LUT input
      .I4(op_pad[24]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hc1f07c1e3ff003fe) // Specify LUT Contents
  ) LUT6_2_inst_4_4 (
      .O6(lut2csa[4][8]), // 1-bit LUT6 output
      .O5(lut2csa[4][9]), // 1-bit lower LUT5 output
      .I0(op_pad[20]), // 1-bit LUT input
      .I1(op_pad[21]), // 1-bit LUT input
      .I2(op_pad[22]), // 1-bit LUT input
      .I3(op_pad[23]), // 1-bit LUT input
      .I4(op_pad[24]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'haaa55554e81d02f4) // Specify LUT Contents
  ) LUT6_2_inst_4_5 (
      .O6(lut2csa[4][10]), // 1-bit LUT6 output
      .O5(lut2csa[4][11]), // 1-bit lower LUT5 output
      .I0(op_pad[20]), // 1-bit LUT input
      .I1(op_pad[21]), // 1-bit LUT input
      .I2(op_pad[22]), // 1-bit LUT input
      .I3(op_pad[23]), // 1-bit LUT input
      .I4(op_pad[24]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h332664989692d24a) // Specify LUT Contents
  ) LUT6_2_inst_4_6 (
      .O6(lut2csa[4][12]), // 1-bit LUT6 output
      .O5(lut2csa[4][13]), // 1-bit lower LUT5 output
      .I0(op_pad[20]), // 1-bit LUT input
      .I1(op_pad[21]), // 1-bit LUT input
      .I2(op_pad[22]), // 1-bit LUT input
      .I3(op_pad[23]), // 1-bit LUT input
      .I4(op_pad[24]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hdb249b6ce3c71c70) // Specify LUT Contents
  ) LUT6_2_inst_4_7 (
      .O6(lut2csa[4][14]), // 1-bit LUT6 output
      .O5(lut2csa[4][15]), // 1-bit lower LUT5 output
      .I0(op_pad[20]), // 1-bit LUT input
      .I1(op_pad[21]), // 1-bit LUT input
      .I2(op_pad[22]), // 1-bit LUT input
      .I3(op_pad[23]), // 1-bit LUT input
      .I4(op_pad[24]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'ha952b52acd9b264c) // Specify LUT Contents
  ) LUT6_2_inst_4_8 (
      .O6(lut2csa[4][16]), // 1-bit LUT6 output
      .O5(lut2csa[4][17]), // 1-bit lower LUT5 output
      .I0(op_pad[20]), // 1-bit LUT input
      .I1(op_pad[21]), // 1-bit LUT input
      .I2(op_pad[22]), // 1-bit LUT input
      .I3(op_pad[23]), // 1-bit LUT input
      .I4(op_pad[24]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'ha4b692da638e71c6) // Specify LUT Contents
  ) LUT6_2_inst_4_9 (
      .O6(lut2csa[4][18]), // 1-bit LUT6 output
      .O5(lut2csa[4][19]), // 1-bit lower LUT5 output
      .I0(op_pad[20]), // 1-bit LUT input
      .I1(op_pad[21]), // 1-bit LUT input
      .I2(op_pad[22]), // 1-bit LUT input
      .I3(op_pad[23]), // 1-bit LUT input
      .I4(op_pad[24]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h1f81f03e552aa554) // Specify LUT Contents
  ) LUT6_2_inst_4_10 (
      .O6(lut2csa[4][20]), // 1-bit LUT6 output
      .O5(lut2csa[4][21]), // 1-bit lower LUT5 output
      .I0(op_pad[20]), // 1-bit LUT input
      .I1(op_pad[21]), // 1-bit LUT input
      .I2(op_pad[22]), // 1-bit LUT input
      .I3(op_pad[23]), // 1-bit LUT input
      .I4(op_pad[24]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h6633399887c3c1e0) // Specify LUT Contents
  ) LUT6_2_inst_4_11 (
      .O6(lut2csa[4][22]), // 1-bit LUT6 output
      .O5(lut2csa[4][23]), // 1-bit lower LUT5 output
      .I0(op_pad[20]), // 1-bit LUT input
      .I1(op_pad[21]), // 1-bit LUT input
      .I2(op_pad[22]), // 1-bit LUT input
      .I3(op_pad[23]), // 1-bit LUT input
      .I4(op_pad[24]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h52a954aa9b3266cc) // Specify LUT Contents
  ) LUT6_2_inst_4_12 (
      .O6(lut2csa[4][24]), // 1-bit LUT6 output
      .O5(lut2csa[4][25]), // 1-bit lower LUT5 output
      .I0(op_pad[20]), // 1-bit LUT input
      .I1(op_pad[21]), // 1-bit LUT input
      .I2(op_pad[22]), // 1-bit LUT input
      .I3(op_pad[23]), // 1-bit LUT input
      .I4(op_pad[24]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hb696d25a00000000) // Specify LUT Contents
  ) LUT6_2_inst_4_13 (
      .O6(lut2csa[4][26]), // 1-bit LUT6 output
      .O5(lut2csa[4][27]), // 1-bit lower LUT5 output
      .I0(op_pad[20]), // 1-bit LUT input
      .I1(op_pad[21]), // 1-bit LUT input
      .I2(op_pad[22]), // 1-bit LUT input
      .I3(op_pad[23]), // 1-bit LUT input
      .I4(op_pad[24]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h66333998e1f0f878) // Specify LUT Contents
  ) LUT6_2_inst_5_0 (
      .O6(lut2csa[5][0]), // 1-bit LUT6 output
      .O5(lut2csa[5][1]), // 1-bit lower LUT5 output
      .I0(op_pad[25]), // 1-bit LUT input
      .I1(op_pad[26]), // 1-bit LUT input
      .I2(op_pad[27]), // 1-bit LUT input
      .I3(op_pad[28]), // 1-bit LUT input
      .I4(op_pad[29]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hb55aad526cc99b36) // Specify LUT Contents
  ) LUT6_2_inst_5_1 (
      .O6(lut2csa[5][2]), // 1-bit LUT6 output
      .O5(lut2csa[5][3]), // 1-bit lower LUT5 output
      .I0(op_pad[25]), // 1-bit LUT input
      .I1(op_pad[26]), // 1-bit LUT input
      .I2(op_pad[27]), // 1-bit LUT input
      .I3(op_pad[28]), // 1-bit LUT input
      .I4(op_pad[29]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h496d2da48e71ce38) // Specify LUT Contents
  ) LUT6_2_inst_5_2 (
      .O6(lut2csa[5][4]), // 1-bit LUT6 output
      .O5(lut2csa[5][5]), // 1-bit lower LUT5 output
      .I0(op_pad[25]), // 1-bit LUT input
      .I1(op_pad[26]), // 1-bit LUT input
      .I2(op_pad[27]), // 1-bit LUT input
      .I3(op_pad[28]), // 1-bit LUT input
      .I4(op_pad[29]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hf07e0fc0aad55aaa) // Specify LUT Contents
  ) LUT6_2_inst_5_3 (
      .O6(lut2csa[5][6]), // 1-bit LUT6 output
      .O5(lut2csa[5][7]), // 1-bit lower LUT5 output
      .I0(op_pad[25]), // 1-bit LUT input
      .I1(op_pad[26]), // 1-bit LUT input
      .I2(op_pad[27]), // 1-bit LUT input
      .I3(op_pad[28]), // 1-bit LUT input
      .I4(op_pad[29]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h99ccc666d29694b4) // Specify LUT Contents
  ) LUT6_2_inst_5_4 (
      .O6(lut2csa[5][8]), // 1-bit LUT6 output
      .O5(lut2csa[5][9]), // 1-bit lower LUT5 output
      .I0(op_pad[25]), // 1-bit LUT input
      .I1(op_pad[26]), // 1-bit LUT input
      .I2(op_pad[27]), // 1-bit LUT input
      .I3(op_pad[28]), // 1-bit LUT input
      .I4(op_pad[29]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'he318e738308694f2) // Specify LUT Contents
  ) LUT6_2_inst_5_5 (
      .O6(lut2csa[5][10]), // 1-bit LUT6 output
      .O5(lut2csa[5][11]), // 1-bit lower LUT5 output
      .I0(op_pad[25]), // 1-bit LUT input
      .I1(op_pad[26]), // 1-bit LUT input
      .I2(op_pad[27]), // 1-bit LUT input
      .I3(op_pad[28]), // 1-bit LUT input
      .I4(op_pad[29]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h0f81740e552aa154) // Specify LUT Contents
  ) LUT6_2_inst_5_6 (
      .O6(lut2csa[5][12]), // 1-bit LUT6 output
      .O5(lut2csa[5][13]), // 1-bit lower LUT5 output
      .I0(op_pad[25]), // 1-bit LUT input
      .I1(op_pad[26]), // 1-bit LUT input
      .I2(op_pad[27]), // 1-bit LUT input
      .I3(op_pad[28]), // 1-bit LUT input
      .I4(op_pad[29]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h6633399887c3c1e0) // Specify LUT Contents
  ) LUT6_2_inst_5_7 (
      .O6(lut2csa[5][14]), // 1-bit LUT6 output
      .O5(lut2csa[5][15]), // 1-bit lower LUT5 output
      .I0(op_pad[25]), // 1-bit LUT input
      .I1(op_pad[26]), // 1-bit LUT input
      .I2(op_pad[27]), // 1-bit LUT input
      .I3(op_pad[28]), // 1-bit LUT input
      .I4(op_pad[29]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h52a954aa9b3266cc) // Specify LUT Contents
  ) LUT6_2_inst_5_8 (
      .O6(lut2csa[5][16]), // 1-bit LUT6 output
      .O5(lut2csa[5][17]), // 1-bit lower LUT5 output
      .I0(op_pad[25]), // 1-bit LUT input
      .I1(op_pad[26]), // 1-bit LUT input
      .I2(op_pad[27]), // 1-bit LUT input
      .I3(op_pad[28]), // 1-bit LUT input
      .I4(op_pad[29]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hb696d25adb249b6c) // Specify LUT Contents
  ) LUT6_2_inst_5_9 (
      .O6(lut2csa[5][18]), // 1-bit LUT6 output
      .O5(lut2csa[5][19]), // 1-bit lower LUT5 output
      .I0(op_pad[25]), // 1-bit LUT input
      .I1(op_pad[26]), // 1-bit LUT input
      .I2(op_pad[27]), // 1-bit LUT input
      .I3(op_pad[28]), // 1-bit LUT input
      .I4(op_pad[29]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'he3c71c70a952b52a) // Specify LUT Contents
  ) LUT6_2_inst_5_10 (
      .O6(lut2csa[5][20]), // 1-bit LUT6 output
      .O5(lut2csa[5][21]), // 1-bit lower LUT5 output
      .I0(op_pad[25]), // 1-bit LUT input
      .I1(op_pad[26]), // 1-bit LUT input
      .I2(op_pad[27]), // 1-bit LUT input
      .I3(op_pad[28]), // 1-bit LUT input
      .I4(op_pad[29]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'hcd9b264ca4b692da) // Specify LUT Contents
  ) LUT6_2_inst_5_11 (
      .O6(lut2csa[5][22]), // 1-bit LUT6 output
      .O5(lut2csa[5][23]), // 1-bit lower LUT5 output
      .I0(op_pad[25]), // 1-bit LUT input
      .I1(op_pad[26]), // 1-bit LUT input
      .I2(op_pad[27]), // 1-bit LUT input
      .I3(op_pad[28]), // 1-bit LUT input
      .I4(op_pad[29]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h638e71c61f81f03e) // Specify LUT Contents
  ) LUT6_2_inst_5_12 (
      .O6(lut2csa[5][24]), // 1-bit LUT6 output
      .O5(lut2csa[5][25]), // 1-bit lower LUT5 output
      .I0(op_pad[25]), // 1-bit LUT input
      .I1(op_pad[26]), // 1-bit LUT input
      .I2(op_pad[27]), // 1-bit LUT input
      .I3(op_pad[28]), // 1-bit LUT input
      .I4(op_pad[29]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );

  // LUT6_2: 6-input, 2 output Look-Up Table
  //         Virtex UltraScale+
  // Xilinx HDL Language Template, version 2024.2

  LUT6_2 #(
      .INIT(64'h552aa55400000000) // Specify LUT Contents
  ) LUT6_2_inst_5_13 (
      .O6(lut2csa[5][26]), // 1-bit LUT6 output
      .O5(lut2csa[5][27]), // 1-bit lower LUT5 output
      .I0(op_pad[25]), // 1-bit LUT input
      .I1(op_pad[26]), // 1-bit LUT input
      .I2(op_pad[27]), // 1-bit LUT input
      .I3(op_pad[28]), // 1-bit LUT input
      .I4(op_pad[29]), // 1-bit LUT input
      .I5(1'b1)  // 1-bit LUT input (fast MUX select only available to O6 output)
  );


  localparam NOF_PARTIALPROD = 6;
  localparam NOF_CSASTAGES = NOF_PARTIALPROD-2;

  logic [DATA_WIDTH+NOF_CSASTAGES-1:0] carry [NOF_CSASTAGES-1:0];
  logic [DATA_WIDTH+NOF_CSASTAGES-1:0] sum [NOF_CSASTAGES-1:0];

  logic [DATA_WIDTH+NOF_CSASTAGES-1:0] mul2csa [NOF_PARTIALPROD-1:0];
  // Build CSA tree for addition of 6 operands
  for (genvar i=0; i<NOF_PARTIALPROD; ++i) begin
    assign mul2csa[i] = {'0,lut2csa[i]};
  end
  // Build CSA tree for addition of 6 operands
  generate;
    for (genvar i=0; i<NOF_CSASTAGES; ++i) begin
      if (i == 0) begin : g_inital_stage
        csa #(
          .DATA_WIDTH(DATA_WIDTH+NOF_CSASTAGES)
        ) U_CSA_INIT (
          .op0_i(mul2csa[0]),
          .op1_i(mul2csa[1]),
          .op2_i(mul2csa[2]),
          .sum_o(sum[i]),
          .carry_o(carry[i])
        );
      end : g_inital_stage else begin : g_intermediate_stage
        csa #(
          .DATA_WIDTH(DATA_WIDTH+NOF_CSASTAGES)
        ) U_CSA_STAGE (
          .op0_i(sum[i-1]),
          .op1_i(carry[i-1]),
          .op2_i(mul2csa[2+i]),
          .sum_o(sum[i]),
          .carry_o(carry[i])
        );        
      end : g_intermediate_stage
    end
  endgenerate

  // Compute final result
  logic [2*DATA_WIDTH-1:0] res_csa_d;
  logic [2*DATA_WIDTH-1:0] res_csa_q;
  generate;
    if (NOF_CSASTAGES == 0) begin
      assign res_csa_d = mul2csa[0] + mul2csa[1];
    end else begin
      assign res_csa_d = sum[$left(sum)] + carry[$left(carry)];
    end
  endgenerate

  // Register stage after CSA tree
  always @(posedge clk_i) begin
    res_csa_q <= res_csa_d;
  end   


  sparse_reduction_134215681
  #(
    .DATA_WIDTH(DATA_WIDTH),
    .QINT(134215681)
  ) u_red (
    .clk_i(clk_i),
    .op_i(res_csa_q),
    .res_o(res_o)   
  );
  
endmodule