// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`resetall
`timescale 1ns/10ps

module top_ntt #(

    // Enable/disable skid buffer usage
    // Skid buffer costs more logic but achieves 2x higher throughput
    parameter SKID_BUFFER = "True",

    // Parameterset specific 
   	parameter QINT = 134215681,
    parameter QINT_64 = 0,
    parameter QDASH = 130021375,
    parameter QDASH_64 = 0,
    parameter QMU = 134219775,
    parameter QMU_64 = 0,
    parameter W4 = 134219775,
    parameter W4_64 = 0,
    parameter K = 54,
    parameter N = 1024,
    parameter TWIDDLE_MEM_PATH = "/home/t_stelzer/projects/aisec/fhe-sv/rtl/ntt/cggi_std_128_mem_hp_28/8",

    // Width of S_AXI data bus
    parameter C_S_AXI_CONTROL_DATA_WIDTH = 32,

    // Width of S_AXI address bus
    parameter C_S_AXI_CONTROL_ADDR_WIDTH = 7,

    // Set to the address width of the interface
    parameter integer C_M_AXI_ADDR_WIDTH  = 64,

    // Set the data width of the interface
    // Range: 32, 64, 128, 256, 512, 1024
    parameter integer C_M_AXI_DATA_WIDTH  = 512,

    // Width of the ctrl_xfer_size_in_bytes input
    // Range: 16:C_M_AXI_ADDR_WIDTH
    parameter integer C_XFER_SIZE_WIDTH   = C_M_AXI_ADDR_WIDTH,

    // Specifies the maximum number of AXI4 transactions that may be outstanding.
    parameter integer C_MAX_OUTSTANDING   = 128,

    // Includes a data ram between the AXI4-Stream slave and the AXI4 write
    // channel master.  Depth is set to 32.
    parameter integer C_INCLUDE_DATA_FIFO = 1,

    // Number of parallel processing elements in accelerator
    parameter NOF_BUTTERFLY_UNITS = 8,	
    parameter BUTTERFLY_TYPE = "CT",

    // Data width of accelerator
    parameter DATA_WIDTH = 28,
    parameter LOG_R = 28,
    parameter DELAY_BF = 12,
    parameter DELAY_MULT = 12,
    parameter DELAY_CONST_MULT = 12,
    // Hardware Configuration - changes not supported right now
    parameter REDUCTION = "SPARSE", // Choose between "BARRETT", "MONTGOMERY", "SOLINA27" and "SOLINA64"
    parameter FIFO_TYPE = "XPM", // Choose between "SHREG", "XPM", "CUSTOM" ToDo: Future Work
    parameter bit TWIDDLE1_OPT = 1'b0,
    parameter bit TWIDDLE2_OPT = 1'b0
)
(
    // System Signals
    input  wire                                      ap_clk                ,
    input  wire                                      ap_rst_n              ,

    // Note: A minimum subset of AXI4 memory mapped signals are declared.  AXI
    // signals omitted from these interfaces are automatically inferred with the
    // optimal values for Xilinx accleration platforms.  This allows Xilinx AXI4 Interconnects
    // within the system to be optimized by removing logic for AXI4 protocol
    // features that are not necessary. When adapting AXI4 masters within the RTL
    // kernel that have signals not declared below, it is suitable to add the
    // signals to the declarations below to connect them to the AXI4 Master.
    // 
    // List of ommited signals - effect
    // -------------------------------
    // ID - Transaction ID are used for multithreading and out of order
    // transactions.  This increases complexity. This saves logic and increases Fmax
    // in the system when ommited.
    // SIZE - Default value is log2(data width in bytes). Needed for subsize bursts.
    // This saves logic and increases Fmax in the system when ommited.
    // BURST - Default value (0b01) is incremental.  Wrap and fixed bursts are not
    // recommended. This saves logic and increases Fmax in the system when ommited.
    // LOCK - Not supported in AXI4
    // CACHE - Default value (0b0011) allows modifiable transactions. No benefit to
    // changing this.
    // PROT - Has no effect in current acceleration platforms.
    // QOS - Has no effect in current acceleration platforms.
    // REGION - Has no effect in current acceleration platforms.
    // USER - Has no effect in current acceleration platforms.
    // RESP - Not useful in most acceleration platforms.


    // AXI4 master interface (read only) - coeff0
    output wire                                     coeff0_m_axi_arvalid  ,
    input  wire                                     coeff0_m_axi_arready  ,
    output wire [C_M_AXI_ADDR_WIDTH-1:0]            coeff0_m_axi_araddr   ,
    output wire [7:0]                               coeff0_m_axi_arlen    ,

    input  wire                                     coeff0_m_axi_rvalid   ,
    output wire                                     coeff0_m_axi_rready   ,
    input  wire [C_M_AXI_DATA_WIDTH-1:0]            coeff0_m_axi_rdata    ,
    input  wire                                     coeff0_m_axi_rlast    ,

    // AXI4 master interface (write only) - coeff0
    output wire                                     coeff0_m_axi_awvalid,
    input  wire                                     coeff0_m_axi_awready,
    output wire [C_M_AXI_ADDR_WIDTH-1:0]            coeff0_m_axi_awaddr,
    output wire [7:0]                               coeff0_m_axi_awlen,

    output wire                                     coeff0_m_axi_wvalid,
    input  wire                                     coeff0_m_axi_wready,
    output wire [C_M_AXI_DATA_WIDTH-1:0]            coeff0_m_axi_wdata,
    output wire [C_M_AXI_DATA_WIDTH/8-1:0]          coeff0_m_axi_wstrb,
    output wire                                     coeff0_m_axi_wlast,

    input  wire                                     coeff0_m_axi_bvalid,
    output wire                                     coeff0_m_axi_bready,  


    // AXI4 master interface (read only) - coeff1
    output wire                                     coeff1_m_axi_arvalid  ,
    input  wire                                     coeff1_m_axi_arready  ,
    output wire [C_M_AXI_ADDR_WIDTH-1:0]            coeff1_m_axi_araddr   ,
    output wire [7:0]                               coeff1_m_axi_arlen    ,

    input  wire                                     coeff1_m_axi_rvalid   ,
    output wire                                     coeff1_m_axi_rready   ,
    input  wire [C_M_AXI_DATA_WIDTH-1:0]            coeff1_m_axi_rdata    ,
    input  wire                                     coeff1_m_axi_rlast    ,

    // AXI4 master interface (write only) - coeff1
    output wire                                     coeff1_m_axi_awvalid,
    input  wire                                     coeff1_m_axi_awready,
    output wire [C_M_AXI_ADDR_WIDTH-1:0]            coeff1_m_axi_awaddr,
    output wire [7:0]                               coeff1_m_axi_awlen,

    output wire                                     coeff1_m_axi_wvalid,
    input  wire                                     coeff1_m_axi_wready,
    output wire [C_M_AXI_DATA_WIDTH-1:0]            coeff1_m_axi_wdata,
    output wire [C_M_AXI_DATA_WIDTH/8-1:0]          coeff1_m_axi_wstrb,
    output wire                                     coeff1_m_axi_wlast,

    input  wire                                     coeff1_m_axi_bvalid,
    output wire                                     coeff1_m_axi_bready,  

    // AXI4 master interface (read only) - coeff2
    output wire                                     coeff2_m_axi_arvalid  ,
    input  wire                                     coeff2_m_axi_arready  ,
    output wire [C_M_AXI_ADDR_WIDTH-1:0]            coeff2_m_axi_araddr   ,
    output wire [7:0]                               coeff2_m_axi_arlen    ,

    input  wire                                     coeff2_m_axi_rvalid   ,
    output wire                                     coeff2_m_axi_rready   ,
    input  wire [C_M_AXI_DATA_WIDTH-1:0]            coeff2_m_axi_rdata    ,
    input  wire                                     coeff2_m_axi_rlast    ,

    // AXI4 master interface (write only) - coeff2
    output wire                                     coeff2_m_axi_awvalid,
    input  wire                                     coeff2_m_axi_awready,
    output wire [C_M_AXI_ADDR_WIDTH-1:0]            coeff2_m_axi_awaddr,
    output wire [7:0]                               coeff2_m_axi_awlen,

    output wire                                     coeff2_m_axi_wvalid,
    input  wire                                     coeff2_m_axi_wready,
    output wire [C_M_AXI_DATA_WIDTH-1:0]            coeff2_m_axi_wdata,
    output wire [C_M_AXI_DATA_WIDTH/8-1:0]          coeff2_m_axi_wstrb,
    output wire                                     coeff2_m_axi_wlast,

    input  wire                                     coeff2_m_axi_bvalid,
    output wire                                     coeff2_m_axi_bready,  

    // AXI4 master interface (read only) - coeff3
    output wire                                     coeff3_m_axi_arvalid  ,
    input  wire                                     coeff3_m_axi_arready  ,
    output wire [C_M_AXI_ADDR_WIDTH-1:0]            coeff3_m_axi_araddr   ,
    output wire [7:0]                               coeff3_m_axi_arlen    ,

    input  wire                                     coeff3_m_axi_rvalid   ,
    output wire                                     coeff3_m_axi_rready   ,
    input  wire [C_M_AXI_DATA_WIDTH-1:0]            coeff3_m_axi_rdata    ,
    input  wire                                     coeff3_m_axi_rlast    ,

    // AXI4 master interface (write only) - coeff3
    output wire                                     coeff3_m_axi_awvalid,
    input  wire                                     coeff3_m_axi_awready,
    output wire [C_M_AXI_ADDR_WIDTH-1:0]            coeff3_m_axi_awaddr,
    output wire [7:0]                               coeff3_m_axi_awlen,

    output wire                                     coeff3_m_axi_wvalid,
    input  wire                                     coeff3_m_axi_wready,
    output wire [C_M_AXI_DATA_WIDTH-1:0]            coeff3_m_axi_wdata,
    output wire [C_M_AXI_DATA_WIDTH/8-1:0]          coeff3_m_axi_wstrb,
    output wire                                     coeff3_m_axi_wlast,

    input  wire                                     coeff3_m_axi_bvalid,
    output wire                                     coeff3_m_axi_bready,  

    // AXI4-Lite slave interface - control
    input  wire                                     s_axi_control_awvalid,
    output wire                                     s_axi_control_awready,
    input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]    s_axi_control_awaddr ,
    input  wire                                     s_axi_control_wvalid ,
    output wire                                     s_axi_control_wready ,
    input  wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]    s_axi_control_wdata  ,
    input  wire [C_S_AXI_CONTROL_DATA_WIDTH/8-1:0]  s_axi_control_wstrb  ,
    input  wire                                     s_axi_control_arvalid,
    output wire                                     s_axi_control_arready,
    input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]    s_axi_control_araddr ,
    output wire                                     s_axi_control_rvalid ,
    input  wire                                     s_axi_control_rready ,
    output wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]    s_axi_control_rdata  ,
    output wire [1:0]                               s_axi_control_rresp  ,
    output wire                                     s_axi_control_bvalid ,
    input  wire                                     s_axi_control_bready ,
    output wire [1:0]                               s_axi_control_bresp  ,
    output wire                                     interrupt     

);

    //////////////////////////////////////////
    // List of ToDo's:
    //
    // - 32-bit/64-bit slave interface
    // - CTRL and IR behavior
    //////////////////////////////////////////


    // Set the pipeline length of the accelerator ToDo: actual length
    localparam PIPELINE_LENGTH = 32;

    // Set data width of from AXI buffers
    // either 32-bit or 64-bit depending on actual data width of accelerator
    localparam DATA_WIDTH_FROM_BUFFER = (DATA_WIDTH > 32) ? 64 : 32;

    // Set the number of chained FIFOs input buffers
    localparam NOF_FIFO_INPUT  = 2*NOF_BUTTERFLY_UNITS;
    localparam NOF_FIFO_OUTPUT = NOF_BUTTERFLY_UNITS;

    localparam NOF_FIFO = NOF_BUTTERFLY_UNITS;

    // Set depth of buffers
    localparam FIFO_DEPTH_AXI2BUF  = ((N/4)*DATA_WIDTH_FROM_BUFFER)/C_M_AXI_DATA_WIDTH;
    
    // Set depth of buffers
    localparam FIFO_DEPTH_BUF2AXI  = ((N/4)*DATA_WIDTH_FROM_BUFFER)/C_M_AXI_DATA_WIDTH;

    // Set depth of RAMs in bits
    localparam RAM_DEPTH  = (DATA_WIDTH_FROM_BUFFER * N)/(NOF_BUTTERFLY_UNITS);

    logic rst; 
    assign rst = ~ap_rst_n;

    logic clk;
    assign clk = ap_clk;

    // XRT API for pipelined execution model
    logic ap_start, ap_done, ap_ready, ap_idle, ap_continue;

    // Input synchronization via ap_start and ap_ready
    // - ap_start enables reading from COEFF buffer
    // - ap_ready is asserted when reading is done and another request can be started
    // - ap_start is validated and deasserted by the ap_ready signal
    // - XRT scheduler detects the status of the ap_start signal and asserts ap_start when the signal is low, meaning the kernel can accept a new task. 
    // - The ap_ready signal is generated by the kernel, indicating its status.

    // Output synchronization via ap_done and ap_continue
    // - ap_done is asserted when COEFF buffer is written
    // - ap_continue keeps the kernel running
    // - ap_done is confirmed and de-asserted by the ap_continue
    // - XRT asserts ap_continue --> should be implemented as a self-clear signal, so that it only keeps one cycle


    //////////////////////////////////////////
    // Version control
    // ---------------------------------------
    // 0.1.0    Initial prototype version
    // ---------------------------------------
    //////////////////////////////////////////

    logic [7:0] v_major, v_minor, v_patch;
    assign v_major = 8'hff;
    assign v_minor = 8'hde;
    assign v_patch = 8'had;

    // Reg2HW - Address offsets
    logic [63:0] coeff0_addr_offset;
    logic [63:0] coeff1_addr_offset;
    logic [63:0] coeff2_addr_offset;
    logic [63:0] coeff3_addr_offset;

    logic [63:0] coeff0_addr_offset_q;
    logic [63:0] coeff1_addr_offset_q;
    logic [63:0] coeff2_addr_offset_q;
    logic [63:0] coeff3_addr_offset_q;

    logic [63:0] coeff0_addr_offset_d;
    logic [63:0] coeff1_addr_offset_d;
    logic [63:0] coeff2_addr_offset_d;
    logic [63:0] coeff3_addr_offset_d;

    //Reg2Hw - Settings
    logic [31:0] ntt_config;
    logic [31:0] ntt_batch_size;
    logic intt;
    logic debug;
    assign intt = ntt_config[0];
    assign debug = ntt_config[1];

    // Coefficient buffer 2 accelerator
    logic [DATA_WIDTH_FROM_BUFFER-1:0] coeff0_buf2acc [NOF_FIFO-1:0];
    logic [DATA_WIDTH_FROM_BUFFER-1:0] coeff1_buf2acc [NOF_FIFO-1:0];
    logic [DATA_WIDTH_FROM_BUFFER-1:0] coeff2_buf2acc [NOF_FIFO-1:0];
    logic [DATA_WIDTH_FROM_BUFFER-1:0] coeff3_buf2acc [NOF_FIFO-1:0];

    logic [DATA_WIDTH-1:0] coeff0_acc_in [NOF_FIFO-1:0];
    logic [DATA_WIDTH-1:0] coeff1_acc_in [NOF_FIFO-1:0];
    logic [DATA_WIDTH-1:0] coeff2_acc_in [NOF_FIFO-1:0];
    logic [DATA_WIDTH-1:0] coeff3_acc_in [NOF_FIFO-1:0];

    logic [DATA_WIDTH-1:0] coeff0_acc_in_q [NOF_FIFO-1:0];
    logic [DATA_WIDTH-1:0] coeff1_acc_in_q [NOF_FIFO-1:0];
    logic [DATA_WIDTH-1:0] coeff2_acc_in_q [NOF_FIFO-1:0];
    logic [DATA_WIDTH-1:0] coeff3_acc_in_q [NOF_FIFO-1:0];

    // Coefficient accelerator 2 buffer
    logic [DATA_WIDTH_FROM_BUFFER-1:0] coeff0_acc2buf [NOF_FIFO-1:0];
    logic [DATA_WIDTH_FROM_BUFFER-1:0] coeff1_acc2buf [NOF_FIFO-1:0];
    logic [DATA_WIDTH_FROM_BUFFER-1:0] coeff2_acc2buf [NOF_FIFO-1:0];
    logic [DATA_WIDTH_FROM_BUFFER-1:0] coeff3_acc2buf [NOF_FIFO-1:0];
    logic coeff_val_acc2buf;

    // Coefficient accelerator 2 buffer
    logic [DATA_WIDTH_FROM_BUFFER-1:0] coeff0_mux [NOF_FIFO-1:0];
    logic [DATA_WIDTH_FROM_BUFFER-1:0] coeff1_mux [NOF_FIFO-1:0];
    logic [DATA_WIDTH_FROM_BUFFER-1:0] coeff2_mux [NOF_FIFO-1:0];
    logic [DATA_WIDTH_FROM_BUFFER-1:0] coeff3_mux [NOF_FIFO-1:0];
    logic coeff_val_mux;

    logic [DATA_WIDTH-1:0] coeff0_acc_out [NOF_FIFO-1:0];
    logic [DATA_WIDTH-1:0] coeff1_acc_out [NOF_FIFO-1:0];
    logic [DATA_WIDTH-1:0] coeff2_acc_out [NOF_FIFO-1:0];
    logic [DATA_WIDTH-1:0] coeff3_acc_out [NOF_FIFO-1:0];

    logic [DATA_WIDTH-1:0] coeff0_acc_out_q [NOF_FIFO-1:0];
    logic [DATA_WIDTH-1:0] coeff1_acc_out_q [NOF_FIFO-1:0];
    logic [DATA_WIDTH-1:0] coeff2_acc_out_q [NOF_FIFO-1:0];
    logic [DATA_WIDTH-1:0] coeff3_acc_out_q [NOF_FIFO-1:0];

    logic coeff_val_buf2acc;
    logic coeff_val_acc_out, coeff_val_acc_out_q;
    logic coeff_val_acc_in, coeff_val_acc_in_q;

    // Control wrapper wires
    logic coeff_val_acc2mux;
    logic cnt_en_acc2mem;
    logic cnt_en_mem2acc;
    logic ctrl_done_coeff;
    logic ctrl_done_acc;
    logic cnt_fifo_en;
    logic read_coeff_done;
    logic start;

    always_comb begin
      cnt_en_acc2mem = coeff_val_acc2buf;
      cnt_en_mem2acc = coeff_val_acc_in_q;
      for (int i=0; i<NOF_FIFO; ++i) begin
          coeff0_acc_in[i] = coeff0_buf2acc[i][DATA_WIDTH-1:0];
          coeff1_acc_in[i] = coeff1_buf2acc[i][DATA_WIDTH-1:0];
          coeff2_acc_in[i] = coeff2_buf2acc[i][DATA_WIDTH-1:0];
          coeff3_acc_in[i] = coeff3_buf2acc[i][DATA_WIDTH-1:0];
      end
      coeff_val_acc_in = coeff_val_buf2acc;
      for (int i=0; i<NOF_FIFO; ++i) begin
          coeff0_acc2buf[i] = coeff0_acc_out_q[i];
          coeff1_acc2buf[i] = coeff1_acc_out_q[i];
          coeff2_acc2buf[i] = coeff2_acc_out_q[i];
          coeff3_acc2buf[i] = coeff3_acc_out_q[i];
      end
      coeff_val_acc2buf = coeff_val_acc_out_q;
    end


    always_ff @(posedge  clk) begin
      coeff0_addr_offset_d <= coeff0_addr_offset;
      coeff1_addr_offset_d <= coeff1_addr_offset;
      coeff2_addr_offset_d <= coeff2_addr_offset;
      coeff3_addr_offset_d <= coeff3_addr_offset;
      coeff0_addr_offset_q <= coeff0_addr_offset_d;
      coeff1_addr_offset_q <= coeff1_addr_offset_d;
      coeff2_addr_offset_q <= coeff2_addr_offset_d;
      coeff3_addr_offset_q <= coeff3_addr_offset_d;
    end

    top_ntt_ctrl_wrapper #(
      .N(N),
      .NOF_BUTTERFLY_UNITS(NOF_BUTTERFLY_UNITS),	
      .PIPELINE_LENGTH(PIPELINE_LENGTH)
    ) u_ctrl (
      .clk_i(clk),
      .rst_i(rst),
      .start_i(ap_start),
      .start_pulse_o(start),
      .ready_o(ap_ready),
      .done_o(ap_done),
      .idle_o(ap_idle),
      .cnt_en_acc2mem_i(cnt_en_acc2mem),
      .cnt_en_mem2acc_i(cnt_en_mem2acc),
      .sync_buf2acc_done_i(ctrl_done_coeff),
      .sync_acc2buf_done_i(ctrl_done_acc),
      .cnt_fifo_en_o(cnt_fifo_en),
      .read_coeff_done_o(read_coeff_done)
    );

    // AXI control slave interface
	  top_ntt_axi_slave #(
        .SKID_BUFFER(SKID_BUFFER),
        .C_S_AXI_DATA_WIDTH(C_S_AXI_CONTROL_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S_AXI_CONTROL_ADDR_WIDTH),
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH)
    ) U_AXI_SLAVE (
        .interrupt(interrupt),
        .ap_start(ap_start),
        .ap_done(ap_done),
        .ap_ready(ap_ready),
        .ap_idle(ap_idle),
        .ap_continue(ap_continue),

        .v_major(v_major),
        .v_minor(v_minor),
        .v_patch(v_patch),

        .coeff0_addr_offset(coeff0_addr_offset),
        .coeff1_addr_offset(coeff1_addr_offset),
        .coeff2_addr_offset(coeff2_addr_offset),
        .coeff3_addr_offset(coeff3_addr_offset),

        .ntt_config(ntt_config),
        .ntt_batch_size(ntt_batch_size),

        .S_AXI_ACLK(clk),
        .S_AXI_ARESET(rst),
        .S_AXI_AWADDR(s_axi_control_awaddr),
        .S_AXI_AWPROT('b0),
        .S_AXI_AWVALID(s_axi_control_awvalid),
        .S_AXI_AWREADY(s_axi_control_awready),
        .S_AXI_WDATA(s_axi_control_wdata),
        .S_AXI_WSTRB(s_axi_control_wstrb),
        .S_AXI_WVALID(s_axi_control_wvalid),
        .S_AXI_WREADY(s_axi_control_wready),
        .S_AXI_BRESP(s_axi_control_bresp),
        .S_AXI_BVALID(s_axi_control_bvalid),
        .S_AXI_BREADY(s_axi_control_bready),
        .S_AXI_ARADDR(s_axi_control_araddr),
        .S_AXI_ARPROT('b0),
        .S_AXI_ARVALID(s_axi_control_arvalid),
        .S_AXI_ARREADY(s_axi_control_arready),
        .S_AXI_RDATA(s_axi_control_rdata),
        .S_AXI_RRESP(s_axi_control_rresp),
        .S_AXI_RVALID(s_axi_control_rvalid),
        .S_AXI_RREADY(s_axi_control_rready)
    );
    top_ntt_axi_mem_wrapper #(
        .N(N/4),
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_XFER_SIZE_WIDTH(C_XFER_SIZE_WIDTH),
        .C_MAX_OUTSTANDING(C_MAX_OUTSTANDING),
        .C_INCLUDE_DATA_FIFO(C_INCLUDE_DATA_FIFO),
        .DATA_WIDTH(DATA_WIDTH_FROM_BUFFER),
        .NOF_BUTTERFLY_UNITS(NOF_BUTTERFLY_UNITS),
        .NOF_POLYNOMIALS(1),
        .PIPELINE_LENGTH(PIPELINE_LENGTH),
        .FIFO_DEPTH_AXI2BUF(FIFO_DEPTH_AXI2BUF),
        .FIFO_DEPTH_BUF2AXI(FIFO_DEPTH_BUF2AXI)
    ) u_axi_coeff_buffer (
        // System Signals
        .clk_i(clk),
        .rst_i(rst),

        // AXI4 master interface (read only) - coeff0
        .coeff0_m_axi_arvalid(coeff0_m_axi_arvalid),
        .coeff0_m_axi_arready(coeff0_m_axi_arready),
        .coeff0_m_axi_araddr(coeff0_m_axi_araddr),
        .coeff0_m_axi_arlen(coeff0_m_axi_arlen),

        .coeff0_m_axi_rvalid(coeff0_m_axi_rvalid),
        .coeff0_m_axi_rready(coeff0_m_axi_rready),
        .coeff0_m_axi_rdata(coeff0_m_axi_rdata),
        .coeff0_m_axi_rlast(coeff0_m_axi_rlast),

        // AXI4 master interface (write only) - coeff0
        .coeff0_m_axi_awvalid(coeff0_m_axi_awvalid),
        .coeff0_m_axi_awready(coeff0_m_axi_awready),
        .coeff0_m_axi_awaddr(coeff0_m_axi_awaddr),
        .coeff0_m_axi_awlen(coeff0_m_axi_awlen),

        .coeff0_m_axi_wvalid(coeff0_m_axi_wvalid),
        .coeff0_m_axi_wready(coeff0_m_axi_wready),
        .coeff0_m_axi_wdata(coeff0_m_axi_wdata),
        .coeff0_m_axi_wstrb(coeff0_m_axi_wstrb),
        .coeff0_m_axi_wlast(coeff0_m_axi_wlast),

        .coeff0_m_axi_bvalid(coeff0_m_axi_bvalid),
        .coeff0_m_axi_bready(coeff0_m_axi_bready),  

        // AXI4 master interface (read only) - coeff1
        .coeff1_m_axi_arvalid(coeff1_m_axi_arvalid),
        .coeff1_m_axi_arready(coeff1_m_axi_arready),
        .coeff1_m_axi_araddr(coeff1_m_axi_araddr),
        .coeff1_m_axi_arlen(coeff1_m_axi_arlen),

        .coeff1_m_axi_rvalid(coeff1_m_axi_rvalid),
        .coeff1_m_axi_rready(coeff1_m_axi_rready),
        .coeff1_m_axi_rdata(coeff1_m_axi_rdata),
        .coeff1_m_axi_rlast(coeff1_m_axi_rlast),

        // AXI4 master interface (write only) - coeff1
        .coeff1_m_axi_awvalid(coeff1_m_axi_awvalid),
        .coeff1_m_axi_awready(coeff1_m_axi_awready),
        .coeff1_m_axi_awaddr(coeff1_m_axi_awaddr),
        .coeff1_m_axi_awlen(coeff1_m_axi_awlen),

        .coeff1_m_axi_wvalid(coeff1_m_axi_wvalid),
        .coeff1_m_axi_wready(coeff1_m_axi_wready),
        .coeff1_m_axi_wdata(coeff1_m_axi_wdata),
        .coeff1_m_axi_wstrb(coeff1_m_axi_wstrb),
        .coeff1_m_axi_wlast(coeff1_m_axi_wlast),

        .coeff1_m_axi_bvalid(coeff1_m_axi_bvalid),
        .coeff1_m_axi_bready(coeff1_m_axi_bready),  

        // AXI4 master interface (read only) - coeff2
        .coeff2_m_axi_arvalid(coeff2_m_axi_arvalid),
        .coeff2_m_axi_arready(coeff2_m_axi_arready),
        .coeff2_m_axi_araddr(coeff2_m_axi_araddr),
        .coeff2_m_axi_arlen(coeff2_m_axi_arlen),

        .coeff2_m_axi_rvalid(coeff2_m_axi_rvalid),
        .coeff2_m_axi_rready(coeff2_m_axi_rready),
        .coeff2_m_axi_rdata(coeff2_m_axi_rdata),
        .coeff2_m_axi_rlast(coeff2_m_axi_rlast),

        // AXI4 master interface (write only) - coeff2
        .coeff2_m_axi_awvalid(coeff2_m_axi_awvalid),
        .coeff2_m_axi_awready(coeff2_m_axi_awready),
        .coeff2_m_axi_awaddr(coeff2_m_axi_awaddr),
        .coeff2_m_axi_awlen(coeff2_m_axi_awlen),

        .coeff2_m_axi_wvalid(coeff2_m_axi_wvalid),
        .coeff2_m_axi_wready(coeff2_m_axi_wready),
        .coeff2_m_axi_wdata(coeff2_m_axi_wdata),
        .coeff2_m_axi_wstrb(coeff2_m_axi_wstrb),
        .coeff2_m_axi_wlast(coeff2_m_axi_wlast),

        .coeff2_m_axi_bvalid(coeff2_m_axi_bvalid),
        .coeff2_m_axi_bready(coeff2_m_axi_bready),  

        // AXI4 master interface (read only) - coeff3
        .coeff3_m_axi_arvalid(coeff3_m_axi_arvalid),
        .coeff3_m_axi_arready(coeff3_m_axi_arready),
        .coeff3_m_axi_araddr(coeff3_m_axi_araddr),
        .coeff3_m_axi_arlen(coeff3_m_axi_arlen),

        .coeff3_m_axi_rvalid(coeff3_m_axi_rvalid),
        .coeff3_m_axi_rready(coeff3_m_axi_rready),
        .coeff3_m_axi_rdata(coeff3_m_axi_rdata),
        .coeff3_m_axi_rlast(coeff3_m_axi_rlast),

        // AXI4 master interface (write only) - coeff3
        .coeff3_m_axi_awvalid(coeff3_m_axi_awvalid),
        .coeff3_m_axi_awready(coeff3_m_axi_awready),
        .coeff3_m_axi_awaddr(coeff3_m_axi_awaddr),
        .coeff3_m_axi_awlen(coeff3_m_axi_awlen),

        .coeff3_m_axi_wvalid(coeff3_m_axi_wvalid),
        .coeff3_m_axi_wready(coeff3_m_axi_wready),
        .coeff3_m_axi_wdata(coeff3_m_axi_wdata),
        .coeff3_m_axi_wstrb(coeff3_m_axi_wstrb),
        .coeff3_m_axi_wlast(coeff3_m_axi_wlast),

        .coeff3_m_axi_bvalid(coeff3_m_axi_bvalid),
        .coeff3_m_axi_bready(coeff3_m_axi_bready),  

        // Address offsets
        .coeff0_addr_offset_i(coeff0_addr_offset),
        .coeff1_addr_offset_i(coeff1_addr_offset),
        .coeff2_addr_offset_i(coeff2_addr_offset),
        .coeff3_addr_offset_i(coeff3_addr_offset),

        // Control signals input buffer
        .read_start_i(start),
        .buf2acc_rd_en_i(cnt_fifo_en),
        .coeff0_o(coeff0_buf2acc),
        .coeff1_o(coeff1_buf2acc),
        .coeff2_o(coeff2_buf2acc),
        .coeff3_o(coeff3_buf2acc),
        .coeff_valid_o(coeff0_val_buf2acc),
        .sync_buf2acc_ready_o(coeff_sync_ready),
        .sync_buf2acc_done_o(ctrl_done_coeff),

        // Control signals out buffer
        .write_start_i(1'b0),
        .acc2buf_rd_en_i(1'b0),
        .coeff0_i(coeff0_mux),
        .coeff1_i(coeff1_mux),
        .coeff2_i(coeff2_mux),
        .coeff3_i(coeff3_mux),
        .coeff_valid_i(coeff_val_mux),
        .sync_acc2buf_done_ack_i(ap_continue),
        .sync_acc2buf_ready_o(),
        .sync_acc2buf_done_o(ctrl_done_acc)
    );

    // Pipeline to enable routing across SLRs
    generate;
      for (int i=0; i<NOF_FIFO; ++i) begin
          pipeline #(
              .DATA_WIDTH(DATA_WIDTH),
              .STAGES(7),
              .EN(1'b0),
              .RST(1'b0)
          ) u_mem2acc_pipe_0 (
              .clk_i(clk),
              .data_i(coeff0_acc_in[i]),
              .en_i(1'b0),
              .rst_i(1'b0),
              .data_o(coeff0_acc_in_q[i]) 
          );
          pipeline #(
              .DATA_WIDTH(DATA_WIDTH),
              .STAGES(7),
              .EN(1'b0),
              .RST(1'b0)
          ) u_mem2acc_pipe_1 (
              .clk_i(clk),
              .data_i(coeff1_acc_in[i]),
              .en_i(1'b0),
              .rst_i(1'b0),
              .data_o(coeff1_acc_in_q[i]) 
          );
          pipeline #(
              .DATA_WIDTH(DATA_WIDTH),
              .STAGES(7),
              .EN(1'b0),
              .RST(1'b0)
          ) u_mem2acc_pipe_2 (
              .clk_i(clk),
              .data_i(coeff2_acc_in[i]),
              .en_i(1'b0),
              .rst_i(1'b0),
              .data_o(coeff2_acc_in_q[i]) 
          );
          pipeline #(
              .DATA_WIDTH(DATA_WIDTH),
              .STAGES(7),
              .EN(1'b0),
              .RST(1'b0)
          ) u_mem2acc_pipe_3 (
              .clk_i(clk),
              .data_i(coeff3_acc_in[i]),
              .en_i(1'b0),
              .rst_i(1'b0),
              .data_o(coeff3_acc_in_q[i]) 
          );
          pipeline #(
              .DATA_WIDTH(1),
              .STAGES(7),
              .EN(1'b0),
              .RST(1'b0)
          ) u_mem2acc_pipe_valid (
              .clk_i(clk),
              .data_i(coeff_val_acc_in),
              .en_i(1'b0),
              .rst_i(1'b0),
              .data_o(coeff_val_acc_in_q) 
          );

          pipeline #(
              .DATA_WIDTH(DATA_WIDTH),
              .STAGES(7),
              .EN(1'b0),
              .RST(1'b0)
          ) u_acc2mem_pipe_0 (
              .clk_i(clk),
              .data_i(coeff0_acc_out[i]),
              .en_i(1'b0),
              .rst_i(1'b0),
              .data_o(coeff0_acc_out_q[i]) 
          );
          pipeline #(
              .DATA_WIDTH(DATA_WIDTH),
              .STAGES(7),
              .EN(1'b0),
              .RST(1'b0)
          ) u_acc2mem_pipe_1 (
              .clk_i(clk),
              .data_i(coeff1_acc_out[i]),
              .en_i(1'b0),
              .rst_i(1'b0),
              .data_o(coeff1_acc_out_q[i]) 
          );
          pipeline #(
              .DATA_WIDTH(DATA_WIDTH),
              .STAGES(7),
              .EN(1'b0),
              .RST(1'b0)
          ) u_acc2mem_pipe_2 (
              .clk_i(clk),
              .data_i(coeff2_acc_out[i]),
              .en_i(1'b0),
              .rst_i(1'b0),
              .data_o(coeff2_acc_out_q[i]) 
          );
          pipeline #(
              .DATA_WIDTH(DATA_WIDTH),
              .STAGES(7),
              .EN(1'b0),
              .RST(1'b0)
          ) u_acc2mem_pipe_3 (
              .clk_i(clk),
              .data_i(coeff3_acc_out[i]),
              .en_i(1'b0),
              .rst_i(1'b0),
              .data_o(coeff3_acc_out_q[i]) 
          );
          pipeline #(
              .DATA_WIDTH(1),
              .STAGES(7),
              .EN(1'b0),
              .RST(1'b0)
          ) u_acc2mem_pipe_valid (
              .clk_i(clk),
              .data_i(coeff_val_acc_out),
              .en_i(1'b0),
              .rst_i(1'b0),
              .data_o(coeff_val_acc_out_q) 
          );
      end
    endgenerate


    always_ff @(posedge clk) begin
      if (rst) begin
        coeff_val_mux <= 1'b0;
      end else begin
        coeff_val_mux <= debug ? coeff0_val_buf2acc : coeff_val_acc2buf;
      end
      coeff0_mux <= debug ? coeff0_buf2acc : coeff0_acc2buf;
      coeff1_mux <= debug ? coeff1_buf2acc : coeff1_acc2buf;
      coeff2_mux <= debug ? coeff2_buf2acc : coeff2_acc2buf;
      coeff3_mux <= debug ? coeff3_buf2acc : coeff3_acc2buf;
    end

    // Parameters for length > 32-bit
    localparam [DATA_WIDTH-1:0] ACT_QINT = (DATA_WIDTH > 32) ? {QINT_64, {32{1'b0}}} | QINT : QINT;
    localparam [DATA_WIDTH-1:0] ACT_QDASH = (DATA_WIDTH > 32) ? {QDASH_64, {32{1'b0}}} | QDASH : QDASH; 
    localparam [DATA_WIDTH-1:0] ACT_W4 = (DATA_WIDTH > 32) ? {W4_64, {32{1'b0}}} | W4 : W4;
    
    ntt_r4mdc #(
        .DATA_WIDTH(DATA_WIDTH),
        .LOG_R(LOG_R),
        .N(N),
        .QINT(ACT_QINT),
        .QDASH(ACT_QDASH),
        .REDUCTION(REDUCTION), // Choose between "BARRETT", "MONTGOMERY", "SOLINA32" and "SOLINA64" ToDo
        .FIFO_TYPE("XPM"),        // Choose between "SHREG", "XPM", "FIFOE18" and "FIFOE36" ToDo
        .BUTTERFLY_TYPE(BUTTERFLY_TYPE),    // Choose between "CT" and "GS" ToDo
        .NOF_BUTTERFLY_UNITS(NOF_BUTTERFLY_UNITS),
        .DELAY_MULT(DELAY_MULT),
        .DELAY_BF(DELAY_BF),
        .DELAY_CONST_MULT(DELAY_CONST_MULT),
        .W4(ACT_W4),
        .TWIDDLE_MEM_PATH(TWIDDLE_MEM_PATH),
        .TWIDDLE1_OPT(TWIDDLE1_OPT),
        .TWIDDLE2_OPT(TWIDDLE2_OPT)
    ) uut (
        .clk_i(clk),
        .rst_i(rst),
        .intt_i(intt),
        .data0_i(coeff0_acc_in_q),
        .data1_i(coeff1_acc_in_q),
        .data2_i(coeff2_acc_in_q),
        .data3_i(coeff3_acc_in_q),
        .data_valid_i(coeff_val_acc_in_q),

        .data0_o(coeff0_acc_out),
        .data1_o(coeff1_acc_out),
        .data2_o(coeff2_acc_out),
        .data3_o(coeff3_acc_out),
        .data_valid_o(coeff_val_acc_out)
    );

endmodule
