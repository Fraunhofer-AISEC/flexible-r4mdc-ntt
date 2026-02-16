// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`resetall
`timescale 1ns/10ps

module channel_sync_fsm #(
    // Set to the address width of the interface
    parameter int unsigned C_M_AXI_ADDR_WIDTH  = 64,

    // Set the data width of the interface
    // Range: 32, 64, 128, 256, 512, 1024
    parameter int unsigned C_M_AXI_DATA_WIDTH  = 32,

    // Width of the ctrl_xfer_size_in_bytes input
    // Range: 16:C_M_AXI_ADDR_WIDTH
    parameter int unsigned C_XFER_SIZE_WIDTH   = C_M_AXI_ADDR_WIDTH,

    // Set data width of AXI2BUF/BUF2AXI
    parameter int unsigned DATA_WIDTH = 32,

    // Set the degree of a polynomial
    parameter int unsigned N = 1024,

    // Set how many polynomials should be read in one row
    parameter int unsigned NOF_POLYNOMIALS = 1
)
(
    input   logic                               clk_i,
    input   logic                               rst_i,

    input   logic                               start_i,
    input   logic   [C_M_AXI_ADDR_WIDTH-1:0]    addr_i,
    output  logic                               ready_o,
    output  logic                               done_o,

    output  logic                               ctrl_start_o,
    input   logic                               ctrl_done_i,

    output  logic   [C_M_AXI_ADDR_WIDTH-1:0]    ctrl_addr_offset_o,
    output  logic   [C_XFER_SIZE_WIDTH-1:0]     ctrl_xfer_size_in_bytes_o
);

    typedef enum { 
        S_IDLE,
        S_FETCH_ADDR,
        S_LOAD_DATA
    } t_state;

    t_state current_state, next_state;

    // Counter
    logic [$clog2(NOF_POLYNOMIALS)-1:0] cnt_poly;

    // State register
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            current_state <= S_IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // Next-state logic
    always_comb begin
        case (current_state)

            S_IDLE: begin
                if (start_i) begin
                    next_state = S_FETCH_ADDR;
                end else begin
                    next_state = S_IDLE;
                end
            end

            S_FETCH_ADDR: begin
                next_state = S_LOAD_DATA;
            end

            S_LOAD_DATA: begin
                if (ctrl_done_i) begin
                    if (cnt_poly == NOF_POLYNOMIALS-1) begin
                        next_state = S_IDLE;
                    end else begin
                        next_state = S_FETCH_ADDR;
                    end
                end else begin
                    next_state = S_LOAD_DATA;
                end
            end

            default: begin
                next_state = S_IDLE;
            end
        endcase
    end

    logic [C_M_AXI_ADDR_WIDTH-1:0] addr;

    // Output logic and register
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            ready_o <= 1'b0;
            cnt_poly <= '0;
            ctrl_start_o <= 1'b0; 
            done_o <= 1'b0;
        end else begin
            ctrl_start_o <= 1'b0;    
            done_o <= 1'b0;
            case (current_state)

                S_IDLE: begin
                    ready_o <= 1'b1;
                    if (start_i) begin
                        addr <= addr_i;
                        ready_o <= 1'b0;
                        cnt_poly <= '0;
                    end
                end

                S_FETCH_ADDR: begin
                    ctrl_start_o <= 1'b1;
                    ctrl_addr_offset_o <= addr;
                    ctrl_xfer_size_in_bytes_o <= (N)*(DATA_WIDTH/8);

                end

                S_LOAD_DATA: begin
                    if (ctrl_done_i) begin
                        if (cnt_poly == NOF_POLYNOMIALS-1) begin
                            ready_o <= 1'b1;
                            done_o <= 1'b1;
                        end else begin
                            addr <= addr + (N)*(DATA_WIDTH/8);
                            cnt_poly <= cnt_poly + 1; 
                        end
                    end
                end

                default: begin
                    ctrl_start_o <= 1'b0;
                    ready_o <= 1'b0;
                end

            endcase       
        end
    end
endmodule
