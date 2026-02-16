// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`resetall
`timescale 1ns/10ps

module buf2axi #(
    // Set to the address width of the interface
    parameter int unsigned C_M_AXI_ADDR_WIDTH  = 64,

    // Set the data width of the interface
    // Range: 32, 64, 128, 256, 512, 1024
    parameter int unsigned C_M_AXI_DATA_WIDTH  = 32,

    // Width of the ctrl_xfer_size_in_bytes input
    // Range: 16:C_M_AXI_ADDR_WIDTH
    parameter int unsigned C_XFER_SIZE_WIDTH   = C_M_AXI_ADDR_WIDTH,

    // Specifies the maximum number of AXI4 transactions that may be outstanding.
    parameter int unsigned C_MAX_OUTSTANDING   = 32,

    // Includes a data fifo between the AXI4-Stream slave and the AXI4 write
    // channel master.  Depth is set to 32.
    parameter bit C_INCLUDE_DATA_FIFO = 1,

    // Include data permutation
    parameter bit INCLUDE_DATA_PERMUTATION = 0,

    // Set the number of chained FIFOs 
    parameter int unsigned NOF_FIFO = 1,

    // Length of Pipeline
    parameter int unsigned PIPELINE_LENGTH  = 16,
    
    // Set data width of output data
    parameter int unsigned DATA_WIDTH  = 32,

    // Depth of buffers
    parameter int unsigned FIFO_DEPTH  = 32
)
(
    // AXI Interface
    input  wire                           aclk,
    input  wire                           areset,

    // Control signals
    input  wire                           ctrl_start_i,              // Pulse high for one cycle to begin reading
    output wire                           ctrl_done_o,               // Pulses high for one cycle when transfer request is complete
    
    // The following ctrl signals are sampled when ctrl_start is asserted
    input  wire [C_M_AXI_ADDR_WIDTH-1:0]  ctrl_addr_offset_i,        // Starting Address offset
    input  wire [C_XFER_SIZE_WIDTH-1:0]   ctrl_xfer_size_in_bytes_i, // Length in number of bytes, limited by the address width.

    // AXI4 master interface (write only)
    output wire                            m_axi_awvalid,
    input  wire                            m_axi_awready,
    output wire [C_M_AXI_ADDR_WIDTH-1:0]   m_axi_awaddr,
    output wire [7:0]                      m_axi_awlen,

    output wire                            m_axi_wvalid,
    input  wire                            m_axi_wready,
    output wire [C_M_AXI_DATA_WIDTH-1:0]   m_axi_wdata,
    output wire [C_M_AXI_DATA_WIDTH/8-1:0] m_axi_wstrb,
    output wire                            m_axi_wlast,

    input  wire                            m_axi_bvalid,
    output wire                            m_axi_bready,    

    // FIFO Interface
    input       logic [NOF_FIFO-1:0]        data_valid_i,
    input       logic [DATA_WIDTH-1:0]      data_i[NOF_FIFO-1:0],
    input       logic                       rd_en_i,
    output      logic                       done_loading_o,
    output      logic                       done_reading_o,
    output      logic                       data_sent2axi_o
);
    localparam FIFO_READ_DEPTH = (FIFO_DEPTH * DATA_WIDTH)/C_M_AXI_DATA_WIDTH;
    localparam FIFO_WRITE_DEPTH = PIPELINE_LENGTH*FIFO_DEPTH;
    localparam FIFO_DEPTH_ACT = ((FIFO_DEPTH * DATA_WIDTH)/C_M_AXI_DATA_WIDTH < 16) ? 2*(16/((FIFO_DEPTH * DATA_WIDTH)/C_M_AXI_DATA_WIDTH)*FIFO_DEPTH) : 2*FIFO_DEPTH;
    
    // FIFO control signals
    logic [NOF_FIFO-1:0] fifo_empty;
    logic [NOF_FIFO-1:0] fifo_full;
    logic [NOF_FIFO-1:0] rd_en_fifo_d;
    logic [NOF_FIFO-1:0] rd_en_fifo_q;

    // FIFO 2 Mux signals
    logic [C_M_AXI_DATA_WIDTH-1:0] data_fifo2mux [NOF_FIFO-1:0];
    logic [NOF_FIFO-1:0] data_val_fifo2mux;

    // Mux 2 AXI write master signals
    logic [C_M_AXI_DATA_WIDTH-1:0] data_mux2axi;
    logic data_val_mux2axi;

    // Counter signals for FIFO selection
    logic [$clog2(NOF_FIFO):0] cnt_fifo_sel;
    logic [$clog2(FIFO_READ_DEPTH)-1:0] cnt_fifo_read;
    logic [$clog2(FIFO_WRITE_DEPTH)-1:0] cnt_fifo_write;

    // Demux for read enable
    logic m_axis_tready_axi2fifo;
    always_ff @(posedge  aclk) begin
        for (int i=0; i<NOF_FIFO; ++i) begin
            if (areset) begin
                rd_en_fifo_d[i] = '0;
                rd_en_fifo_q[i] = '0;
            end else if (cnt_fifo_sel == i) begin
                // Only read when ready and not empty
                rd_en_fifo_d[i] = rd_en_i & m_axis_tready_axi2fifo;
                if (FIFO_READ_DEPTH <= 2) begin
                    rd_en_fifo_q[i] = rd_en_fifo_d[i];
                end else begin
                    rd_en_fifo_q[i] = rd_en_fifo_d[i] & (cnt_fifo_read < FIFO_READ_DEPTH-2);
                end
            end else begin
                rd_en_fifo_d[i] = '0;
                rd_en_fifo_q[i] = '0;
            end
        end
    end

    // Feedback
    generate;
        if (NOF_FIFO == 1) begin
            assign data_sent2axi_o = rd_en_i & m_axis_tready_axi2fifo;
        end else begin
            assign data_sent2axi_o = data_val_mux2axi;
        end
    endgenerate

    // Counters to select FIFO one after another during writing over AXI
    always_ff @(posedge  aclk) begin
        if (areset) begin
            cnt_fifo_read <= '0;
        end else if (data_val_mux2axi) begin
            if (cnt_fifo_read == FIFO_READ_DEPTH-1) begin
                cnt_fifo_read <= '0;
            end else begin
                cnt_fifo_read <= cnt_fifo_read + 1;
            end
        end
    end
    
    always_ff @(posedge  aclk) begin
        done_reading_o <= 1'b0;
        if (areset) begin
            cnt_fifo_sel <= '0;
        end else if ((data_val_mux2axi) && (cnt_fifo_read == FIFO_READ_DEPTH-1)) begin
            if (cnt_fifo_sel == NOF_FIFO-1) begin
                cnt_fifo_sel <= '0;
                done_reading_o <= 1'b1;
            end else begin
                cnt_fifo_sel <= cnt_fifo_sel + 1;                
            end
        end 
    end

    // Counter to track words written into FIFOs
    always_ff @(posedge  aclk) begin
        done_loading_o <= 1'b0;
        if (areset) begin
            cnt_fifo_write <= '0;
            done_loading_o <= 1'b0;
        end else if (data_valid_i) begin
            if (cnt_fifo_write == FIFO_WRITE_DEPTH-1) begin
                cnt_fifo_write <= '0;
                done_loading_o <= 1'b1;
            end else begin
                cnt_fifo_write <= cnt_fifo_write + 1;
            end
        end
    end

    // Generate FIFO for every channel
    generate;
    for (genvar i=0; i<NOF_FIFO; ++i) begin

        // xpm_fifo_sync: Synchronous FIFO
        // Xilinx Parameterized Macro, version 2023.1
        // FIFO_MEMORY_TYPE should not be "auto" as READ_DATA_WIDTH and WRITE_DATA_WIDTH are not equal!
        xpm_fifo_sync #(
            .CASCADE_HEIGHT(0),                         // DECIMAL
            .DOUT_RESET_VALUE("0"),                     // String
            .ECC_MODE("no_ecc"),                        // String
            .FIFO_MEMORY_TYPE("auto"),                 // String
            .FIFO_READ_LATENCY(1),                      // DECIMAL
            .FIFO_WRITE_DEPTH(PIPELINE_LENGTH*FIFO_DEPTH_ACT),        // DECIMAL
            .FULL_RESET_VALUE(0),                       // DECIMAL
            .PROG_EMPTY_THRESH(10),                     // DECIMAL
            .PROG_FULL_THRESH(10),                      // DECIMAL
            .RD_DATA_COUNT_WIDTH($clog2(FIFO_READ_DEPTH)+1), // DECIMAL
            .READ_DATA_WIDTH(C_M_AXI_DATA_WIDTH),       // DECIMAL
            .READ_MODE("std"),                          // String
            .SIM_ASSERT_CHK(0),                         // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
            .USE_ADV_FEATURES("1707"),                  // String
            .WAKEUP_TIME(0),                            // DECIMAL
            .WRITE_DATA_WIDTH(DATA_WIDTH),              // DECIMAL
            .WR_DATA_COUNT_WIDTH($clog2(FIFO_WRITE_DEPTH)+1)  // DECIMAL
        ) U_FIFO (
            .almost_empty(),                        // 1-bit output: Almost Empty : When asserted, this signal indicates that
                                                    // only one more read can be performed before the FIFO goes to empty.

            .almost_full(),                         // 1-bit output: Almost Full: When asserted, this signal indicates that
                                                    // only one more write can be performed before the FIFO is full.

            .data_valid(data_val_fifo2mux[i]),      // 1-bit output: Read Data Valid: When asserted, this signal indicates
                                                    // that valid data is available on the output bus (dout).

            .dbiterr(),                             // 1-bit output: Double Bit Error: Indicates that the ECC decoder detected
                                                    // a double-bit error and data in the FIFO core is corrupted.

            .dout(data_fifo2mux[i]),                // READ_DATA_WIDTH-bit output: Read Data: The output data bus is driven
                                                    // when reading the FIFO.

            .empty(fifo_empty[i]),                  // 1-bit output: Empty Flag: When asserted, this signal indicates that the
                                                    // FIFO is empty. Read requests are ignored when the FIFO is empty,
                                                    // initiating a read while empty is not destructive to the FIFO.

            .full(fifo_full[i]),                      // 1-bit output: Full Flag: When asserted, this signal indicates that the
                                                    // FIFO is full. Write requests are ignored when the FIFO is full,
                                                    // initiating a write when the FIFO is full is not destructive to the
                                                    // contents of the FIFO.

            .overflow(),                            // 1-bit output: Overflow: This signal indicates that a write request
                                                    // (wren) during the prior clock cycle was rejected, because the FIFO is
                                                    // full. Overflowing the FIFO is not destructive to the contents of the
                                                    // FIFO.

            .prog_empty(),                          // 1-bit output: Programmable Empty: This signal is asserted when the
                                                    // number of words in the FIFO is less than or equal to the programmable
                                                    // empty threshold value. It is de-asserted when the number of words in
                                                    // the FIFO exceeds the programmable empty threshold value.

            .prog_full(),                           // 1-bit output: Programmable Full: This signal is asserted when the
                                                    // number of words in the FIFO is greater than or equal to the
                                                    // programmable full threshold value. It is de-asserted when the number of
                                                    // words in the FIFO is less than the programmable full threshold value.

            .rd_data_count(),                       // RD_DATA_COUNT_WIDTH-bit output: Read Data Count: This bus indicates the
                                                    // number of words read from the FIFO.

            .rd_rst_busy(),                         // 1-bit output: Read Reset Busy: Active-High indicator that the FIFO read
                                                    // domain is currently in a reset state.

            .sbiterr(),                             // 1-bit output: Single Bit Error: Indicates that the ECC decoder detected
                                                    // and fixed a single-bit error.

            .underflow(),                           // 1-bit output: Underflow: Indicates that the read request (rd_en) during
                                                    // the previous clock cycle was rejected because the FIFO is empty. Under
                                                    // flowing the FIFO is not destructive to the FIFO.

            .wr_ack(),                              // 1-bit output: Write Acknowledge: This signal indicates that a write
                                                    // request (wr_en) during the prior clock cycle is succeeded.

            .wr_data_count(),                       // WR_DATA_COUNT_WIDTH-bit output: Write Data Count: This bus indicates
                                                    // the number of words written into the FIFO.

            .wr_rst_busy(),                         // 1-bit output: Write Reset Busy: Active-High indicator that the FIFO
                                                    // write domain is currently in a reset state.

            .din(data_i[i]),                        // WRITE_DATA_WIDTH-bit input: Write Data: The input data bus used when
                                                    // writing the FIFO.

            .injectdbiterr('0),                     // 1-bit input: Double Bit Error Injection: Injects a double bit error if
                                                    // the ECC feature is used on block RAMs or UltraRAM macros.

            .injectsbiterr('0),                     // 1-bit input: Single Bit Error Injection: Injects a single bit error if
                                                    // the ECC feature is used on block RAMs or UltraRAM macros.

            .rd_en(rd_en_fifo_q[i]),                  // 1-bit input: Read Enable: If the FIFO is not empty, asserting this
                                                    // signal causes data (on dout) to be read from the FIFO. Must be held
                                                    // active-low when rd_rst_busy is active high.

            .rst(areset),                           // 1-bit input: Reset: Must be synchronous to wr_clk. The clock(s) can be
                                                    // unstable at the time of applying reset, but reset must be released only
                                                    // after the clock(s) is/are stable.

            .sleep('0),                             // 1-bit input: Dynamic power saving- If sleep is High, the memory/fifo
                                                    // block is in power saving mode.

            .wr_clk(aclk),                          // 1-bit input: Write clock: Used for write operation. wr_clk must be a
                                                    // free running clock.

            .wr_en(data_valid_i[i])                 // 1-bit input: Write Enable: If the FIFO is not full, asserting this
                                                    // signal causes data (on din) to be written to the FIFO Must be held
                                                    // active-low when rst or wr_rst_busy or rd_rst_busy is active high
        );
        // End of xpm_fifo_sync_inst instantiation
    end
    endgenerate

    // Mux to select correct FIFO to deliver data to memory via U_AXI_WRTIE0
    assign data_mux2axi = data_fifo2mux[cnt_fifo_sel];
    // ToDo: Add latency to optimize timing due to usage of URAM
    assign data_val_mux2axi = data_val_fifo2mux[cnt_fifo_sel];
    axi_write_master #(
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_XFER_SIZE_WIDTH(C_XFER_SIZE_WIDTH),
        .C_MAX_OUTSTANDING(C_MAX_OUTSTANDING),
        .C_INCLUDE_DATA_FIFO(C_INCLUDE_DATA_FIFO)
    ) U_AXI_WRITE0 (
        // AXI Interface
        .aclk(aclk),
        .areset(areset),
        .ctrl_start(ctrl_start_i),
        .ctrl_done(ctrl_done_o), 
        .ctrl_addr_offset(ctrl_addr_offset_i), 
        .ctrl_xfer_size_in_bytes(ctrl_xfer_size_in_bytes_i),
        // AXI4 master interface (write only)
        .m_axi_awvalid(m_axi_awvalid),
        .m_axi_awready(m_axi_awready),
        .m_axi_awaddr(m_axi_awaddr),
        .m_axi_awlen(m_axi_awlen),
        .m_axi_wvalid(m_axi_wvalid),
        .m_axi_wready(m_axi_wready),
        .m_axi_wdata(m_axi_wdata),
        .m_axi_wstrb(m_axi_wstrb),
        .m_axi_wlast(m_axi_wlast),
        .m_axi_bvalid(m_axi_bvalid),
        .m_axi_bready(m_axi_bready),
        // AXI4-Stream interface
        .s_axis_aclk(aclk),
        .s_axis_areset(areset),
        .s_axis_tvalid(data_val_mux2axi),
        .s_axis_tready(m_axis_tready_axi2fifo),
        .s_axis_tdata(data_mux2axi)
    );

endmodule


