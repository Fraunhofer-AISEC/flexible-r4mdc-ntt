// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0   
   
`timescale 1ns/10ps

module fifo_wrapper
#(
    parameter int unsigned DATA_WIDTH = 27,
    parameter int unsigned FIFO_DEPTH = 512,
    parameter FIFO_TYPE = "XPM"        // Choose between "SHREG", "XPM"
)
(
    input   logic                       clk_i,
    input   logic                       rst_i,
    input   logic [DATA_WIDTH-1:0]      data_i,
    output  logic [DATA_WIDTH-1:0]      data_o,
    output  logic                       data_valid_o,    
    input   logic                       wr_en_fifo_i,
    input   logic                       rd_en_fifo_i

);
    function automatic bit is_power_of_two(int value);
        return (value > 0) && ((value & (value - 1)) == 0);
    endfunction

    function automatic int next_power_of_two(int value);
        if (value <= 1) begin
            return 1;
        end else begin
            int power = 1;
            while (power < value) begin
                power <<= 1; // Shift left to multiply by 2
            end
            return power;
        end
    endfunction

    generate
        if ((FIFO_DEPTH < 32) || (FIFO_TYPE) =="SHREG") begin

            // Pipeline register for FIFO_DEPTH 1
            if (FIFO_DEPTH == 1) begin
                always_ff @(posedge clk_i) begin
                    data_o <= data_i;
                end

            // Shift register for FIFO_DEPTH <16
            end else begin
                
                shreg #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .SHREG_SIZE(FIFO_DEPTH)
                ) U_STAGE_SHREG_0 (
                    .clk_i(clk_i),
                    .shreg_i(data_i),
                    .shreg_en_i(wr_en_fifo_i || rd_en_fifo_i),
                    .shreg_o(data_o)
                );
            end

        end else begin

            // xpm_fifo_sync: Synchronous FIFO
            // Xilinx Parameterized Macro, version 2023.1
            
            localparam int NEW_DEPTH = next_power_of_two(FIFO_DEPTH); 

            logic almost_empty_fifo0;
            logic almost_full_fifo0;
            logic data_valid_fifo0;        
            logic dbiterr_fifo0;
            logic empty_fifo0;
            logic full_fifo0;
            logic overflow_fifo0;
            logic prog_empty_fifo0;
            logic prog_full_fifo0;
            logic [$clog2(NEW_DEPTH)-1:0] rd_data_count_fifo0;
            logic rd_rst_busy_fifo0;
            logic sbiterr_fifo0;
            logic underflow_fifo0;
            logic wr_ack_fifo0;
            logic [$clog2(NEW_DEPTH)-1:0] wr_data_count_fifo0;
            logic wr_rst_busy_fifo0;

            xpm_fifo_sync #(
                .CASCADE_HEIGHT(0),        // DECIMAL
                .DOUT_RESET_VALUE("0"),    // String
                .ECC_MODE("no_ecc"),       // String
                .FIFO_MEMORY_TYPE("block"), // String
                .FIFO_READ_LATENCY(1),     // DECIMAL
                .FIFO_WRITE_DEPTH(NEW_DEPTH), // DECIMAL
                .FULL_RESET_VALUE(0),      // DECIMAL
                .PROG_EMPTY_THRESH(10),    // DECIMAL
                .PROG_FULL_THRESH(10),     // DECIMAL
                .RD_DATA_COUNT_WIDTH($clog2(NEW_DEPTH)), // DECIMAL
                .READ_DATA_WIDTH(DATA_WIDTH), // DECIMAL
                .READ_MODE("fwft"),        // String
                .SIM_ASSERT_CHK(0),        // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
                .USE_ADV_FEATURES("1707"), // String
                .WAKEUP_TIME(0),           // DECIMAL
                .WRITE_DATA_WIDTH(DATA_WIDTH), // DECIMAL
                .WR_DATA_COUNT_WIDTH($clog2(NEW_DEPTH)) // DECIMAL
            ) U_STAGE_FIFO_0 (
                .almost_empty(almost_empty_fifo0),      // 1-bit output: Almost Empty : When asserted, this signal indicates that
                                                        // only one more read can be performed before the FIFO goes to empty.

                .almost_full(almost_full_fifo0),        // 1-bit output: Almost Full: When asserted, this signal indicates that
                                                        // only one more write can be performed before the FIFO is full.

                .data_valid(data_valid_o),              // 1-bit output: Read Data Valid: When asserted, this signal indicates
                                                        // that valid data is available on the output bus (dout).

                .dbiterr(dbiterr_fifo0),                // 1-bit output: Double Bit Error: Indicates that the ECC decoder detected
                                                        // a double-bit error and data in the FIFO core is corrupted.

                .dout(data_o),                         // READ_DATA_WIDTH-bit output: Read Data: The output data bus is driven
                                                        // when reading the FIFO.

                .empty(empty_fifo0),                    // 1-bit output: Empty Flag: When asserted, this signal indicates that the
                                                        // FIFO is empty. Read requests are ignored when the FIFO is empty,
                                                        // initiating a read while empty is not destructive to the FIFO.

                .full(full_fifo0),                      // 1-bit output: Full Flag: When asserted, this signal indicates that the
                                                        // FIFO is full. Write requests are ignored when the FIFO is full,
                                                        // initiating a write when the FIFO is full is not destructive to the
                                                        // contents of the FIFO.

                .overflow(overflow_fifo0),              // 1-bit output: Overflow: This signal indicates that a write request
                                                        // (wren) during the prior clock cycle was rejected, because the FIFO is
                                                        // full. Overflowing the FIFO is not destructive to the contents of the
                                                        // FIFO.

                .prog_empty(prog_empty_fifo0),          // 1-bit output: Programmable Empty: This signal is asserted when the
                                                        // number of words in the FIFO is less than or equal to the programmable
                                                        // empty threshold value. It is de-asserted when the number of words in
                                                        // the FIFO exceeds the programmable empty threshold value.

                .prog_full(prog_full_fifo0),            // 1-bit output: Programmable Full: This signal is asserted when the
                                                        // number of words in the FIFO is greater than or equal to the
                                                        // programmable full threshold value. It is de-asserted when the number of
                                                        // words in the FIFO is less than the programmable full threshold value.

                .rd_data_count(rd_data_count_fifo0),    // RD_DATA_COUNT_WIDTH-bit output: Read Data Count: This bus indicates the
                                                        // number of words read from the FIFO.

                .rd_rst_busy(rd_rst_busy_fifo0),        // 1-bit output: Read Reset Busy: Active-High indicator that the FIFO read
                                                        // domain is currently in a reset state.

                .sbiterr(sbiterr_fifo0),                // 1-bit output: Single Bit Error: Indicates that the ECC decoder detected
                                                        // and fixed a single-bit error.

                .underflow(underflow_fifo0),            // 1-bit output: Underflow: Indicates that the read request (rd_en) during
                                                        // the previous clock cycle was rejected because the FIFO is empty. Under
                                                        // flowing the FIFO is not destructive to the FIFO.

                .wr_ack(wr_ack_fifo0),                  // 1-bit output: Write Acknowledge: This signal indicates that a write
                                                        // request (wr_en) during the prior clock cycle is succeeded.

                .wr_data_count(wr_data_count_fifo0),    // WR_DATA_COUNT_WIDTH-bit output: Write Data Count: This bus indicates
                                                        // the number of words written into the FIFO.

                .wr_rst_busy(wr_rst_busy_fifo0),        // 1-bit output: Write Reset Busy: Active-High indicator that the FIFO
                                                        // write domain is currently in a reset state.

                .din(data_i),                          // WRITE_DATA_WIDTH-bit input: Write Data: The input data bus used when
                                                        // writing the FIFO.

                .injectdbiterr('0),                     // 1-bit input: Double Bit Error Injection: Injects a double bit error if
                                                        // the ECC feature is used on block RAMs or UltraRAM macros.

                .injectsbiterr('0),                     // 1-bit input: Single Bit Error Injection: Injects a single bit error if
                                                        // the ECC feature is used on block RAMs or UltraRAM macros.

                .rd_en(rd_en_fifo_i),                    // 1-bit input: Read Enable: If the FIFO is not empty, asserting this
                                                        // signal causes data (on dout) to be read from the FIFO. Must be held
                                                        // active-low when rd_rst_busy is active high.

                .rst(rst_i),                            // 1-bit input: Reset: Must be synchronous to wr_clk. The clock(s) can be
                                                        // unstable at the time of applying reset, but reset must be released only
                                                        // after the clock(s) is/are stable.

                .sleep('0),                             // 1-bit input: Dynamic power saving- If sleep is High, the memory/fifo
                                                        // block is in power saving mode.

                .wr_clk(clk_i),                         // 1-bit input: Write clock: Used for write operation. wr_clk must be a
                                                        // free running clock.

                .wr_en(wr_en_fifo_i)                     // 1-bit input: Write Enable: If the FIFO is not full, asserting this
                                                        // signal causes data (on din) to be written to the FIFO Must be held
                                                        // active-low when rst or wr_rst_busy or rd_rst_busy is active high
            );
            // End of xpm_fifo_sync_inst instantiation
        end

    endgenerate

endmodule: fifo_wrapper