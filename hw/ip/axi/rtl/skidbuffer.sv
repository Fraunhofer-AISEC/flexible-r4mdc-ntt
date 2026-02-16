// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// Designed according to https://zipcpu.com/blog/2019/05/22/skidbuffer.html
module skidbuffer #(
    // Set data width of data
    parameter int unsigned DATA_WIDTH  = 32,
    parameter	bit	OPT_OUTREG = 1
) (
    input   logic                   clk_i,
    input   logic                   rst_i,  
	  input	  logic			              valid_i,
    output  logic			              ready_o,
    input	  logic [DATA_WIDTH-1:0]  data_i,
    output	logic 			            valid_o,
    input	  logic 			            ready_i,
    output	logic	[DATA_WIDTH-1:0]	data_o
);

    // high if valid data but outgoing path stalled
    logic                   r_valid;
    logic [DATA_WIDTH-1:0]  r_data;

    logic                   ready2out;
    logic                   valid2out;
    logic [DATA_WIDTH-1:0]  data2out;
    always_comb begin
        // output stall signal is given by valid signal of internal buffer
        ready2out = !r_valid;
    end

    generate;
        if (!OPT_OUTREG) begin
            always_comb begin
                valid2out = (valid_i || r_valid);
                if (r_valid) begin
                    data2out = r_data;
                end else begin
                    data2out = data_i;
                end
            end
        end else begin
            always_ff @(posedge clk_i) begin
                if (rst_i) begin
                    valid2out <= 1'b0;
                end else if (!valid2out || ready_i) begin
                    valid2out <= (valid_i || r_valid);
                end
            end

            always_ff @(posedge clk_i) begin
                if (!valid2out || ready_i) begin
                  if (r_valid) begin
                    data2out <= r_data;
                  end else if (valid_i) begin
                    data2out <= data_i;
                  end
                end
            end
        end
    endgenerate

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            r_valid <= 1'b0;
        end else if ((valid_i && ready2out) && (valid2out && ready_i)) begin
            // valid incoming data, but stalled output
            r_valid <= 1'b1;
        end else if (ready_i) begin
            // return to normal operation and act as pass through
            r_valid <= 1'b0;
        end
    end

    always_ff @(posedge clk_i) begin
        if (ready2out) begin

            r_data <= data_i;
        end
    end

    // output signal aissgnment
    assign ready_o = ready2out;
    assign valid_o = valid2out;
    assign data_o = data2out;

endmodule