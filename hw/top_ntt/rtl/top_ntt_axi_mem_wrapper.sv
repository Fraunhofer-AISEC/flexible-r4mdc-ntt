`resetall
`timescale 1ns/10ps

module top_ntt_axi_mem_wrapper #(
    // Parameterset specific
    parameter N = 1024,

    // Set to the address width of the interface
    parameter integer C_M_AXI_ADDR_WIDTH  = 64,

    // Set the data width of the interface
    // Range: 32, 64, 128, 256, 512, 1024
    parameter integer C_M_AXI_DATA_WIDTH  = 256,

    // Width of the ctrl_xfer_size_in_bytes input
    // Range: 16:C_M_AXI_ADDR_WIDTH
    parameter integer C_XFER_SIZE_WIDTH   = C_M_AXI_ADDR_WIDTH,

    // Specifies the maximum number of AXI4 transactions that may be outstanding.
    parameter integer C_MAX_OUTSTANDING   = 32,

    // Includes a data ram between the AXI4-Stream slave and the AXI4 write
    // channel master.  Depth is set to 32.
    parameter integer C_INCLUDE_DATA_FIFO = 1,
   
    // Data width
    parameter DATA_WIDTH = 32,
    parameter NOF_BUTTERFLY_UNITS = 16,
    parameter NOF_POLYNOMIALS = 1,
    parameter PIPELINE_LENGTH = 16,
    parameter FIFO_DEPTH_AXI2BUF = 1024,
    parameter FIFO_DEPTH_BUF2AXI = 1024
)(  
    // System Signals
    input  wire                                      clk_i,
    input  wire                                      rst_i,

    // AXI4 master interface (read only) - coeff0
    output wire                                     coeff0_m_axi_arvalid,
    input  wire                                     coeff0_m_axi_arready,
    output wire [C_M_AXI_ADDR_WIDTH-1:0]            coeff0_m_axi_araddr,
    output wire [7:0]                               coeff0_m_axi_arlen,

    input  wire                                     coeff0_m_axi_rvalid,
    output wire                                     coeff0_m_axi_rready,
    input  wire [C_M_AXI_DATA_WIDTH-1:0]            coeff0_m_axi_rdata,
    input  wire                                     coeff0_m_axi_rlast,

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
    output wire                                     coeff1_m_axi_arvalid,
    input  wire                                     coeff1_m_axi_arready,
    output wire [C_M_AXI_ADDR_WIDTH-1:0]            coeff1_m_axi_araddr,
    output wire [7:0]                               coeff1_m_axi_arlen,

    input  wire                                     coeff1_m_axi_rvalid,
    output wire                                     coeff1_m_axi_rready,
    input  wire [C_M_AXI_DATA_WIDTH-1:0]            coeff1_m_axi_rdata,
    input  wire                                     coeff1_m_axi_rlast,

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
    output wire                                     coeff2_m_axi_arvalid,
    input  wire                                     coeff2_m_axi_arready,
    output wire [C_M_AXI_ADDR_WIDTH-1:0]            coeff2_m_axi_araddr,
    output wire [7:0]                               coeff2_m_axi_arlen,

    input  wire                                     coeff2_m_axi_rvalid,
    output wire                                     coeff2_m_axi_rready,
    input  wire [C_M_AXI_DATA_WIDTH-1:0]            coeff2_m_axi_rdata,
    input  wire                                     coeff2_m_axi_rlast,

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
    output wire                                     coeff3_m_axi_arvalid,
    input  wire                                     coeff3_m_axi_arready,
    output wire [C_M_AXI_ADDR_WIDTH-1:0]            coeff3_m_axi_araddr,
    output wire [7:0]                               coeff3_m_axi_arlen,

    input  wire                                     coeff3_m_axi_rvalid,
    output wire                                     coeff3_m_axi_rready,
    input  wire [C_M_AXI_DATA_WIDTH-1:0]            coeff3_m_axi_rdata,
    input  wire                                     coeff3_m_axi_rlast,

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

    // Address offsets
    input logic [C_M_AXI_ADDR_WIDTH-1:0]            coeff0_addr_offset_i,
    input logic [C_M_AXI_ADDR_WIDTH-1:0]            coeff1_addr_offset_i,
    input logic [C_M_AXI_ADDR_WIDTH-1:0]            coeff2_addr_offset_i,
    input logic [C_M_AXI_ADDR_WIDTH-1:0]            coeff3_addr_offset_i,

    // Control signals input buffer
    input logic                                     read_start_i,
    input logic                                     buf2acc_rd_en_i,
    output logic [DATA_WIDTH-1:0]                   coeff0_o [NOF_BUTTERFLY_UNITS-1:0],
    output logic [DATA_WIDTH-1:0]                   coeff1_o [NOF_BUTTERFLY_UNITS-1:0],
    output logic [DATA_WIDTH-1:0]                   coeff2_o [NOF_BUTTERFLY_UNITS-1:0],
    output logic [DATA_WIDTH-1:0]                   coeff3_o [NOF_BUTTERFLY_UNITS-1:0],
    output logic                                    coeff_valid_o,
    output logic                                    sync_buf2acc_ready_o,
    output logic                                    sync_buf2acc_done_o,

    // Control signals out buffer
    input logic                                     write_start_i,    // future use
    input logic                                     acc2buf_rd_en_i,  // future use
    input logic [DATA_WIDTH-1:0]                    coeff0_i [NOF_BUTTERFLY_UNITS-1:0],
    input logic [DATA_WIDTH-1:0]                    coeff1_i [NOF_BUTTERFLY_UNITS-1:0],
    input logic [DATA_WIDTH-1:0]                    coeff2_i [NOF_BUTTERFLY_UNITS-1:0],
    input logic [DATA_WIDTH-1:0]                    coeff3_i [NOF_BUTTERFLY_UNITS-1:0],
    input logic                                     coeff_valid_i,
    input logic                                     sync_acc2buf_done_ack_i,
    output logic                                    sync_acc2buf_ready_o,
    output logic                                    sync_acc2buf_done_o
);

    // As it is a pipeline execution model, the coeff addresses will be overwrittten
    logic [63:0] coeff0_addr_offset_d;
    logic [63:0] coeff1_addr_offset_d;
    logic [63:0] coeff2_addr_offset_d;
    logic [63:0] coeff3_addr_offset_d;
    logic [63:0] coeff0_addr_offset_q;
    logic [63:0] coeff1_addr_offset_q;
    logic [63:0] coeff2_addr_offset_q;
    logic [63:0] coeff3_addr_offset_q;

    always_ff @(posedge  clk_i) begin
      coeff0_addr_offset_d <= coeff0_addr_offset_i;
      coeff1_addr_offset_d <= coeff1_addr_offset_i;
      coeff2_addr_offset_d <= coeff2_addr_offset_i;
      coeff3_addr_offset_d <= coeff3_addr_offset_i;
      coeff0_addr_offset_q <= coeff0_addr_offset_d;
      coeff1_addr_offset_q <= coeff1_addr_offset_d;
      coeff2_addr_offset_q <= coeff2_addr_offset_d;
      coeff3_addr_offset_q <= coeff3_addr_offset_d;
    end
    localparam FIFO_NOF = 1;
    logic [C_M_AXI_DATA_WIDTH-1:0] coeff0_axi2acc[FIFO_NOF-1:0];
    logic [C_M_AXI_DATA_WIDTH-1:0] coeff1_axi2acc[FIFO_NOF-1:0];
    logic [C_M_AXI_DATA_WIDTH-1:0] coeff2_axi2acc[FIFO_NOF-1:0];
    logic [C_M_AXI_DATA_WIDTH-1:0] coeff3_axi2acc[FIFO_NOF-1:0];

    logic [C_M_AXI_DATA_WIDTH-1:0] coeff0_acc2axi[FIFO_NOF-1:0];
    logic [C_M_AXI_DATA_WIDTH-1:0] coeff1_acc2axi[FIFO_NOF-1:0];
    logic [C_M_AXI_DATA_WIDTH-1:0] coeff2_acc2axi[FIFO_NOF-1:0];
    logic [C_M_AXI_DATA_WIDTH-1:0] coeff3_acc2axi[FIFO_NOF-1:0];
    always_comb begin
      for (int i=0; i<NOF_BUTTERFLY_UNITS; ++i) begin
        coeff0_o[i] = coeff0_axi2acc[0][DATA_WIDTH*i +: DATA_WIDTH];
        coeff1_o[i] = coeff1_axi2acc[0][DATA_WIDTH*i +: DATA_WIDTH];
        coeff2_o[i] = coeff2_axi2acc[0][DATA_WIDTH*i +: DATA_WIDTH];
        coeff3_o[i] = coeff3_axi2acc[0][DATA_WIDTH*i +: DATA_WIDTH];
        coeff0_acc2axi[0][DATA_WIDTH*i +: DATA_WIDTH] = coeff0_i[i];
        coeff1_acc2axi[0][DATA_WIDTH*i +: DATA_WIDTH] = coeff1_i[i];
        coeff2_acc2axi[0][DATA_WIDTH*i +: DATA_WIDTH] = coeff2_i[i];
        coeff3_acc2axi[0][DATA_WIDTH*i +: DATA_WIDTH] = coeff3_i[i];
      end
      
    end
    /*****************************************
    * AXI Read Channel Logic 
    ******************************************/
    // Buffer and input sync
    logic ctrl_start_coeff0, ctrl_done_coeff0;
    logic [C_M_AXI_ADDR_WIDTH-1:0] ctrl_addr_offset_coeff0;
    logic [C_XFER_SIZE_WIDTH-1:0] ctrl_xfer_size_in_bytes_coeff0;
    logic coeff0_sync_done,coeff0_sync_ready;
    logic rd_en_coeff0;
    logic coeff0_fifo_write_done;

    logic ctrl_start_coeff1, ctrl_done_coeff1;
    logic [C_M_AXI_ADDR_WIDTH-1:0] ctrl_addr_offset_coeff1;
    logic [C_XFER_SIZE_WIDTH-1:0] ctrl_xfer_size_in_bytes_coeff1;
    logic coeff1_sync_done, coeff1_sync_ready;
    logic rd_en_coeff1;
    logic coeff1_fifo_write_done;

    logic ctrl_start_coeff2, ctrl_done_coeff2;
    logic [C_M_AXI_ADDR_WIDTH-1:0] ctrl_addr_offset_coeff2;
    logic [C_XFER_SIZE_WIDTH-1:0] ctrl_xfer_size_in_bytes_coeff2;
    logic coeff2_sync_done, coeff2_sync_ready;
    logic rd_en_coeff2;
    logic coeff2_fifo_write_done;

    logic ctrl_start_coeff3, ctrl_done_coeff3;
    logic [C_M_AXI_ADDR_WIDTH-1:0] ctrl_addr_offset_coeff3;
    logic [C_XFER_SIZE_WIDTH-1:0] ctrl_xfer_size_in_bytes_coeff3;
    logic coeff3_sync_done, coeff3_sync_ready;
    logic rd_en_coeff3;
    logic coeff3_fifo_write_done;

    // coeffumulator buffer 2 coeffelerator
    logic [DATA_WIDTH-1:0] coeff0_buf2coeff [NOF_BUTTERFLY_UNITS-1:0];
    logic coeff0_val_buf2coeff;
    logic [DATA_WIDTH-1:0] coeff1_buf2coeff [NOF_BUTTERFLY_UNITS-1:0];
    logic coeff1_val_buf2coeff;
    logic [DATA_WIDTH-1:0] coeff2_buf2coeff [NOF_BUTTERFLY_UNITS-1:0];
    logic coeff2_val_buf2coeff;
    logic [DATA_WIDTH-1:0] coeff3_buf2coeff [NOF_BUTTERFLY_UNITS-1:0];
    logic coeff3_val_buf2coeff;

    assign rd_en_coeff0 = buf2acc_rd_en_i;
    assign rd_en_coeff1 = buf2acc_rd_en_i;
    assign rd_en_coeff2 = buf2acc_rd_en_i;
    assign rd_en_coeff3 = buf2acc_rd_en_i;

	  axi2buf #(
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_XFER_SIZE_WIDTH(C_XFER_SIZE_WIDTH),
        .C_MAX_OUTSTANDING(C_MAX_OUTSTANDING),
        .C_INCLUDE_DATA_FIFO(C_INCLUDE_DATA_FIFO),
        .NOF_FIFO(1),
        .PIPELINE_LENGTH(PIPELINE_LENGTH),
        .DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH_AXI2BUF)
	  ) U_AXI2BUF_COEFF0 (    
        .aclk(clk_i),
        .areset(rst_i),
        .ctrl_start_i(ctrl_start_coeff0),
        .ctrl_done_o(ctrl_done_coeff0),
        .ctrl_addr_offset_i(ctrl_addr_offset_coeff0),
        .ctrl_xfer_size_in_bytes_i(ctrl_xfer_size_in_bytes_coeff0),
        .m_axi_arvalid(coeff0_m_axi_arvalid),
        .m_axi_arready(coeff0_m_axi_arready),
        .m_axi_araddr(coeff0_m_axi_araddr),
        .m_axi_arlen(coeff0_m_axi_arlen),
        .m_axi_rvalid(coeff0_m_axi_rvalid),
        .m_axi_rready(coeff0_m_axi_rready),
        .m_axi_rdata(coeff0_m_axi_rdata),
        .m_axi_rlast(coeff0_m_axi_rlast),
        .rd_en_i(rd_en_coeff0),
        .data_valid_o(coeff0_val_buf2coeff),
        .data_o(coeff0_axi2acc),
        .read_ready_o(read_ready_coeff0),
        .done_o(coeff0_fifo_write_done)
    );

	  axi2buf #(
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_XFER_SIZE_WIDTH(C_XFER_SIZE_WIDTH),
        .C_MAX_OUTSTANDING(C_MAX_OUTSTANDING),
        .C_INCLUDE_DATA_FIFO(C_INCLUDE_DATA_FIFO),
        .PIPELINE_LENGTH(PIPELINE_LENGTH),
        .NOF_FIFO(1),
        .DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH_AXI2BUF)
	  ) U_AXI2BUF_COEFF1 (    
        .aclk(clk_i),
        .areset(rst_i),
        .ctrl_start_i(ctrl_start_coeff1),
        .ctrl_done_o(ctrl_done_coeff1),
        .ctrl_addr_offset_i(ctrl_addr_offset_coeff1),
        .ctrl_xfer_size_in_bytes_i(ctrl_xfer_size_in_bytes_coeff1),
        .m_axi_arvalid(coeff1_m_axi_arvalid),
        .m_axi_arready(coeff1_m_axi_arready),
        .m_axi_araddr(coeff1_m_axi_araddr),
        .m_axi_arlen(coeff1_m_axi_arlen),
        .m_axi_rvalid(coeff1_m_axi_rvalid),
        .m_axi_rready(coeff1_m_axi_rready),
        .m_axi_rdata(coeff1_m_axi_rdata),
        .m_axi_rlast(coeff1_m_axi_rlast),
        .rd_en_i(rd_en_coeff1),
        .data_valid_o(coeff1_val_buf2coeff),
        .data_o(coeff1_axi2acc),
        .read_ready_o(read_ready_coeff1),
        .done_o(coeff1_fifo_write_done)
    );

	  axi2buf #(
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_XFER_SIZE_WIDTH(C_XFER_SIZE_WIDTH),
        .C_MAX_OUTSTANDING(C_MAX_OUTSTANDING),
        .C_INCLUDE_DATA_FIFO(C_INCLUDE_DATA_FIFO),
        .NOF_FIFO(1),
        .PIPELINE_LENGTH(PIPELINE_LENGTH),
        .DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH_AXI2BUF)
	  ) U_AXI2BUF_COEFF2 (    
        .aclk(clk_i),
        .areset(rst_i),
        .ctrl_start_i(ctrl_start_coeff2),
        .ctrl_done_o(ctrl_done_coeff2),
        .ctrl_addr_offset_i(ctrl_addr_offset_coeff2),
        .ctrl_xfer_size_in_bytes_i(ctrl_xfer_size_in_bytes_coeff2),
        .m_axi_arvalid(coeff2_m_axi_arvalid),
        .m_axi_arready(coeff2_m_axi_arready),
        .m_axi_araddr(coeff2_m_axi_araddr),
        .m_axi_arlen(coeff2_m_axi_arlen),
        .m_axi_rvalid(coeff2_m_axi_rvalid),
        .m_axi_rready(coeff2_m_axi_rready),
        .m_axi_rdata(coeff2_m_axi_rdata),
        .m_axi_rlast(coeff2_m_axi_rlast),
        .rd_en_i(rd_en_coeff2),
        .data_valid_o(coeff2_val_buf2coeff),
        .data_o(coeff2_axi2acc),
        .read_ready_o(read_ready_coeff2),
        .done_o(coeff2_fifo_write_done)
    );

	  axi2buf #(
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_XFER_SIZE_WIDTH(C_XFER_SIZE_WIDTH),
        .C_MAX_OUTSTANDING(C_MAX_OUTSTANDING),
        .C_INCLUDE_DATA_FIFO(C_INCLUDE_DATA_FIFO),
        .NOF_FIFO(1),
        .PIPELINE_LENGTH(PIPELINE_LENGTH),
        .DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH_AXI2BUF)
	  ) U_AXI2BUF_COEFF3 (    
        .aclk(clk_i),
        .areset(rst_i),
        .ctrl_start_i(ctrl_start_coeff3),
        .ctrl_done_o(ctrl_done_coeff3),
        .ctrl_addr_offset_i(ctrl_addr_offset_coeff3),
        .ctrl_xfer_size_in_bytes_i(ctrl_xfer_size_in_bytes_coeff3),
        .m_axi_arvalid(coeff3_m_axi_arvalid),
        .m_axi_arready(coeff3_m_axi_arready),
        .m_axi_araddr(coeff3_m_axi_araddr),
        .m_axi_arlen(coeff3_m_axi_arlen),
        .m_axi_rvalid(coeff3_m_axi_rvalid),
        .m_axi_rready(coeff3_m_axi_rready),
        .m_axi_rdata(coeff3_m_axi_rdata),
        .m_axi_rlast(coeff3_m_axi_rlast),
        .rd_en_i(rd_en_coeff3),
        .data_valid_o(coeff3_val_buf2coeff),
        .data_o(coeff3_axi2acc),
        .read_ready_o(read_ready_coeff3),
        .done_o(coeff3_fifo_write_done)
    );
    // Channel sync control fsms
    channel_sync_fsm #(
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_XFER_SIZE_WIDTH(C_XFER_SIZE_WIDTH),
        .NOF_POLYNOMIALS(1),
        .DATA_WIDTH(DATA_WIDTH),
        .N(PIPELINE_LENGTH*N)
    ) U_COEFF0_SYN (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .start_i(read_start_i),
        .addr_i(coeff0_addr_offset_q),
        .ready_o(coeff0_sync_ready),
        .done_o(coeff0_sync_done),
        .ctrl_start_o(ctrl_start_coeff0),
        .ctrl_done_i(ctrl_done_coeff0),
        .ctrl_addr_offset_o(ctrl_addr_offset_coeff0),
        .ctrl_xfer_size_in_bytes_o(ctrl_xfer_size_in_bytes_coeff0)
    );
    channel_sync_fsm #(
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_XFER_SIZE_WIDTH(C_XFER_SIZE_WIDTH),
        .NOF_POLYNOMIALS(1),
        .DATA_WIDTH(DATA_WIDTH),
        .N(PIPELINE_LENGTH*N)
    ) U_COEFF1_SYN (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .start_i(read_start_i),
        .addr_i(coeff1_addr_offset_q),
        .ready_o(coeff1_sync_ready),
        .done_o(coeff1_sync_done),
        .ctrl_start_o(ctrl_start_coeff1),
        .ctrl_done_i(ctrl_done_coeff1),
        .ctrl_addr_offset_o(ctrl_addr_offset_coeff1),
        .ctrl_xfer_size_in_bytes_o(ctrl_xfer_size_in_bytes_coeff1)
    );

    channel_sync_fsm #(
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_XFER_SIZE_WIDTH(C_XFER_SIZE_WIDTH),
        .NOF_POLYNOMIALS(1),
        .DATA_WIDTH(DATA_WIDTH),
        .N(PIPELINE_LENGTH*N)
    ) U_COEFF2_SYN (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .start_i(read_start_i),
        .addr_i(coeff2_addr_offset_q),
        .ready_o(coeff2_sync_ready),
        .done_o(coeff2_sync_done),
        .ctrl_start_o(ctrl_start_coeff2),
        .ctrl_done_i(ctrl_done_coeff2),
        .ctrl_addr_offset_o(ctrl_addr_offset_coeff2),
        .ctrl_xfer_size_in_bytes_o(ctrl_xfer_size_in_bytes_coeff2)
    );

    channel_sync_fsm #(
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_XFER_SIZE_WIDTH(C_XFER_SIZE_WIDTH),
        .NOF_POLYNOMIALS(1),
        .DATA_WIDTH(DATA_WIDTH),
        .N(PIPELINE_LENGTH*N)
    ) U_COEFF3_SYN (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .start_i(read_start_i),
        .addr_i(coeff3_addr_offset_q),
        .ready_o(coeff3_sync_ready),
        .done_o(coeff3_sync_done),
        .ctrl_start_o(ctrl_start_coeff3),
        .ctrl_done_i(ctrl_done_coeff3),
        .ctrl_addr_offset_o(ctrl_addr_offset_coeff3),
        .ctrl_xfer_size_in_bytes_o(ctrl_xfer_size_in_bytes_coeff3)
    );

    // Combination of both done pulses to one done strobe
    logic ctrl_done_coeff;
    logic ctrl_done_coeff0_seen;
    logic ctrl_done_coeff1_seen;
    logic ctrl_done_coeff2_seen;
    logic ctrl_done_coeff3_seen;

    always_ff @(posedge clk_i) begin
        ctrl_done_coeff <= 1'b0;
        if (rst_i) begin
            sync_buf2acc_ready_o <= 1'b0;
            ctrl_done_coeff <= 1'b0;
            ctrl_done_coeff0_seen <= 1'b0;
            ctrl_done_coeff1_seen <= 1'b0;
            ctrl_done_coeff2_seen <= 1'b0;
            ctrl_done_coeff3_seen <= 1'b0;
        end else begin
            sync_buf2acc_ready_o <= coeff0_sync_ready & 
                                    coeff1_sync_ready & 
                                    coeff2_sync_ready & 
                                    coeff3_sync_ready;
            // Capture the arrival of coeff0_out_sync_done and coeff1_out_sync_done
            if (coeff0_fifo_write_done)
                ctrl_done_coeff0_seen <= 1'b1;
            
            if (coeff1_fifo_write_done)
                ctrl_done_coeff1_seen <= 1'b1;

            if (coeff2_fifo_write_done)
                ctrl_done_coeff2_seen <= 1'b1;

            if (coeff3_fifo_write_done)
                ctrl_done_coeff3_seen <= 1'b1;

            // Generate the ctrl_done_coeff pulse
            if (ctrl_done_coeff0_seen && ctrl_done_coeff1_seen && ctrl_done_coeff2_seen && ctrl_done_coeff3_seen) begin
                ctrl_done_coeff <= 1'b1;
                // Reset the captured states after generating the pulse
                ctrl_done_coeff0_seen <= 1'b0;
                ctrl_done_coeff1_seen <= 1'b0;
                ctrl_done_coeff2_seen <= 1'b0;
                ctrl_done_coeff3_seen <= 1'b0;
            end
        end
    end

    assign coeff_valid_o = coeff0_val_buf2coeff;
    assign sync_buf2acc_done_o = ctrl_done_coeff;
    
    /*****************************************
    * AXI Write Channel Logic 
    ******************************************/

    // Buffer and input sync
    logic ctrl_start_write_coeff0, ctrl_start_write_coeff1, ctrl_start_write_coeff2, ctrl_start_write_coeff3;
    logic ctrl_done_write_coeff0, ctrl_done_write_coeff1, ctrl_done_write_coeff2, ctrl_done_write_coeff3, ctrl_done_write_coeff;
    logic [C_M_AXI_ADDR_WIDTH-1:0] ctrl_addr_offset_write_coeff0, ctrl_addr_offset_write_coeff1, ctrl_addr_offset_write_coeff2, ctrl_addr_offset_write_coeff3;
    logic [C_XFER_SIZE_WIDTH-1:0] ctrl_xfer_size_in_bytes_write_coeff0, ctrl_xfer_size_in_bytes_write_coeff1, ctrl_xfer_size_in_bytes_write_coeff2, ctrl_xfer_size_in_bytes_write_coeff3;
    logic done_loading_fifo_coeff0, done_loading_fifo_coeff1,done_loading_fifo_coeff2, done_loading_fifo_coeff3, done_loading_fifo_coeff;
    logic done_reading_fifo_coeff0, done_reading_fifo_coeff1,done_reading_fifo_coeff2, done_reading_fifo_coeff3, done_reading_fifo_coeff;
    // Read from FIFOs when done filling them
    localparam WORDS_IN_PIPELINE = N*PIPELINE_LENGTH;
    logic [$clog2(N)+PIPELINE_LENGTH:0] cnt_fifo_coeff_write_coeff0;
    logic cnt_fifo_coeff_wen_coeff0;
    logic [$clog2(N)+PIPELINE_LENGTH:0] cnt_fifo_coeff_write_coeff1;
    logic cnt_fifo_coeff_wen_coeff1;
    logic [$clog2(N)+PIPELINE_LENGTH:0] cnt_fifo_coeff_write_coeff2;
    logic cnt_fifo_coeff_wen_coeff2;
    logic [$clog2(N)+PIPELINE_LENGTH:0] cnt_fifo_coeff_write_coeff3;
    logic cnt_fifo_coeff_wen_coeff3;
    // Feedback from BUF2XI
    logic data_sent2axi_coeff0;
    logic data_sent2axi_coeff1;
    logic data_sent2axi_coeff2;
    logic data_sent2axi_coeff3;

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            cnt_fifo_coeff_write_coeff0 <= '0;
            cnt_fifo_coeff_wen_coeff0 <= '0;
        end else begin
            if (done_loading_fifo_coeff0) begin
                cnt_fifo_coeff_wen_coeff0 <= 1'b1;
                cnt_fifo_coeff_write_coeff0 <= (WORDS_IN_PIPELINE-1);
            end else if (cnt_fifo_coeff_write_coeff0 == 'd0) begin
                cnt_fifo_coeff_wen_coeff0 <= 1'b0;
                cnt_fifo_coeff_write_coeff0 <= '0;
            end else if (cnt_fifo_coeff_wen_coeff0 && data_sent2axi_coeff0) begin
                cnt_fifo_coeff_write_coeff0 <= cnt_fifo_coeff_write_coeff0 - 1;
            end

            
        end
    end
    
    logic rd_en_coeff_wr_fifo_coeff0;
    assign rd_en_coeff_wr_fifo_coeff0 = cnt_fifo_coeff_wen_coeff0;

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            cnt_fifo_coeff_write_coeff1 <= '0;
            cnt_fifo_coeff_wen_coeff1 <= '0;
        end else begin
            if (done_loading_fifo_coeff1) begin
                cnt_fifo_coeff_wen_coeff1 <= 1'b1;
                cnt_fifo_coeff_write_coeff1 <= (WORDS_IN_PIPELINE-1);              
            end else if (cnt_fifo_coeff_write_coeff1 == 'd0) begin
                cnt_fifo_coeff_wen_coeff1 <= 1'b0;
                cnt_fifo_coeff_write_coeff1 <= '0;
            end else if (cnt_fifo_coeff_wen_coeff1 && data_sent2axi_coeff1) begin
                cnt_fifo_coeff_write_coeff1 <= cnt_fifo_coeff_write_coeff1 - 1;
            end            
        end
    end

    logic rd_en_coeff_wr_fifo_coeff1;
    assign rd_en_coeff_wr_fifo_coeff1 = cnt_fifo_coeff_wen_coeff1;


    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            cnt_fifo_coeff_write_coeff2 <= '0;
            cnt_fifo_coeff_wen_coeff2 <= '0;
        end else begin
            if (done_loading_fifo_coeff2) begin
                cnt_fifo_coeff_wen_coeff2 <= 1'b1;
                cnt_fifo_coeff_write_coeff2 <= (WORDS_IN_PIPELINE-1);              
            end else if (cnt_fifo_coeff_write_coeff2 == 'd0) begin
                cnt_fifo_coeff_wen_coeff2 <= 1'b0;
                cnt_fifo_coeff_write_coeff2 <= '0;
            end else if (cnt_fifo_coeff_wen_coeff2 && data_sent2axi_coeff2) begin
                cnt_fifo_coeff_write_coeff2 <= cnt_fifo_coeff_write_coeff2 - 1;
            end            
        end
    end

    logic rd_en_coeff_wr_fifo_coeff2;
    assign rd_en_coeff_wr_fifo_coeff2 = cnt_fifo_coeff_wen_coeff2;

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            cnt_fifo_coeff_write_coeff3 <= '0;
            cnt_fifo_coeff_wen_coeff3 <= '0;
        end else begin
            if (done_loading_fifo_coeff3) begin
                cnt_fifo_coeff_wen_coeff3 <= 1'b1;
                cnt_fifo_coeff_write_coeff3 <= (WORDS_IN_PIPELINE-1);              
            end else if (cnt_fifo_coeff_write_coeff3 == 'd0) begin
                cnt_fifo_coeff_wen_coeff3 <= 1'b0;
                cnt_fifo_coeff_write_coeff3 <= '0;
            end else if (cnt_fifo_coeff_wen_coeff3 && data_sent2axi_coeff3) begin
                cnt_fifo_coeff_write_coeff3 <= cnt_fifo_coeff_write_coeff3 - 1;
            end            
        end
    end

    logic rd_en_coeff_wr_fifo_coeff3;
    assign rd_en_coeff_wr_fifo_coeff3 = cnt_fifo_coeff_wen_coeff3;


    // Buffer for coeffumulator input for a when coeff=(a,b)
    buf2axi #(
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_XFER_SIZE_WIDTH(C_XFER_SIZE_WIDTH),
        .C_MAX_OUTSTANDING(2048),
        .C_INCLUDE_DATA_FIFO(C_INCLUDE_DATA_FIFO),
        .INCLUDE_DATA_PERMUTATION(0),
        .NOF_FIFO(1),
        .PIPELINE_LENGTH(PIPELINE_LENGTH),
        .DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH_BUF2AXI)
    ) U_BUF2AXI_COEFF0 (
        .aclk(clk_i),
        .areset(rst_i),
        .ctrl_start_i(ctrl_start_write_coeff0),
        .ctrl_done_o(ctrl_done_write_coeff0),
        .ctrl_addr_offset_i(ctrl_addr_offset_write_coeff0),
        .ctrl_xfer_size_in_bytes_i(ctrl_xfer_size_in_bytes_write_coeff0),
        .m_axi_awvalid(coeff0_m_axi_awvalid),
        .m_axi_awready(coeff0_m_axi_awready),
        .m_axi_awaddr(coeff0_m_axi_awaddr),
        .m_axi_awlen(coeff0_m_axi_awlen),
        .m_axi_wvalid(coeff0_m_axi_wvalid),
        .m_axi_wready(coeff0_m_axi_wready),
        .m_axi_wdata(coeff0_m_axi_wdata),
        .m_axi_wstrb(coeff0_m_axi_wstrb),
        .m_axi_wlast(coeff0_m_axi_wlast),
        .m_axi_bvalid(coeff0_m_axi_bvalid),
        .m_axi_bready(coeff0_m_axi_bready),    
        .data_valid_i({NOF_BUTTERFLY_UNITS{coeff_valid_i}}),
        .data_i(coeff0_acc2axi),
        .rd_en_i(rd_en_coeff_wr_fifo_coeff0),
        .done_loading_o(done_loading_fifo_coeff0),
        .done_reading_o(done_reading_fifo_coeff0),
        .data_sent2axi_o(data_sent2axi_coeff0)
    );

    // Buffer for coeffumulator input for b when coeff=(a,b)
    buf2axi #(
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_XFER_SIZE_WIDTH(C_XFER_SIZE_WIDTH),
        .C_MAX_OUTSTANDING(2048),
        .C_INCLUDE_DATA_FIFO(C_INCLUDE_DATA_FIFO),
        .INCLUDE_DATA_PERMUTATION(0),
        .NOF_FIFO(1),
        .PIPELINE_LENGTH(PIPELINE_LENGTH),
        .DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH_BUF2AXI)
    ) U_BUF2AXI_COEFF1 (
        .aclk(clk_i),
        .areset(rst_i),
        .ctrl_start_i(ctrl_start_write_coeff1),
        .ctrl_done_o(ctrl_done_write_coeff1),
        .ctrl_addr_offset_i(ctrl_addr_offset_write_coeff1),
        .ctrl_xfer_size_in_bytes_i(ctrl_xfer_size_in_bytes_write_coeff1),
        .m_axi_awvalid(coeff1_m_axi_awvalid),
        .m_axi_awready(coeff1_m_axi_awready),
        .m_axi_awaddr(coeff1_m_axi_awaddr),
        .m_axi_awlen(coeff1_m_axi_awlen),
        .m_axi_wvalid(coeff1_m_axi_wvalid),
        .m_axi_wready(coeff1_m_axi_wready),
        .m_axi_wdata(coeff1_m_axi_wdata),
        .m_axi_wstrb(coeff1_m_axi_wstrb),
        .m_axi_wlast(coeff1_m_axi_wlast),
        .m_axi_bvalid(coeff1_m_axi_bvalid),
        .m_axi_bready(coeff1_m_axi_bready),    
        .data_valid_i({NOF_BUTTERFLY_UNITS{coeff_valid_i}}),
        .data_i(coeff1_acc2axi),
        .rd_en_i(rd_en_coeff_wr_fifo_coeff1),
        .done_loading_o(done_loading_fifo_coeff1),
        .done_reading_o(done_reading_fifo_coeff1),
        .data_sent2axi_o(data_sent2axi_coeff1)
    );

    // Buffer for coeffumulator input for b when coeff=(a,b)
    buf2axi #(
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_XFER_SIZE_WIDTH(C_XFER_SIZE_WIDTH),
        .C_MAX_OUTSTANDING(2048),
        .C_INCLUDE_DATA_FIFO(C_INCLUDE_DATA_FIFO),
        .INCLUDE_DATA_PERMUTATION(0),
        .NOF_FIFO(1),
        .PIPELINE_LENGTH(PIPELINE_LENGTH),
        .DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH_BUF2AXI)
    ) U_BUF2AXI_COEFF2 (
        .aclk(clk_i),
        .areset(rst_i),
        .ctrl_start_i(ctrl_start_write_coeff2),
        .ctrl_done_o(ctrl_done_write_coeff2),
        .ctrl_addr_offset_i(ctrl_addr_offset_write_coeff2),
        .ctrl_xfer_size_in_bytes_i(ctrl_xfer_size_in_bytes_write_coeff2),
        .m_axi_awvalid(coeff2_m_axi_awvalid),
        .m_axi_awready(coeff2_m_axi_awready),
        .m_axi_awaddr(coeff2_m_axi_awaddr),
        .m_axi_awlen(coeff2_m_axi_awlen),
        .m_axi_wvalid(coeff2_m_axi_wvalid),
        .m_axi_wready(coeff2_m_axi_wready),
        .m_axi_wdata(coeff2_m_axi_wdata),
        .m_axi_wstrb(coeff2_m_axi_wstrb),
        .m_axi_wlast(coeff2_m_axi_wlast),
        .m_axi_bvalid(coeff2_m_axi_bvalid),
        .m_axi_bready(coeff2_m_axi_bready),    
        .data_valid_i({NOF_BUTTERFLY_UNITS{coeff_valid_i}}),
        .data_i(coeff2_acc2axi),
        .rd_en_i(rd_en_coeff_wr_fifo_coeff2),
        .done_loading_o(done_loading_fifo_coeff2),
        .done_reading_o(done_reading_fifo_coeff2),
        .data_sent2axi_o(data_sent2axi_coeff2)
    );

    // Buffer for coeffumulator input for b when coeff=(a,b)
    buf2axi #(
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_XFER_SIZE_WIDTH(C_XFER_SIZE_WIDTH),
        .C_MAX_OUTSTANDING(2048),
        .C_INCLUDE_DATA_FIFO(C_INCLUDE_DATA_FIFO),
        .INCLUDE_DATA_PERMUTATION(0),
        .NOF_FIFO(1),
        .PIPELINE_LENGTH(PIPELINE_LENGTH),
        .DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH_BUF2AXI)
    ) U_BUF2AXI_COEFF3 (
        .aclk(clk_i),
        .areset(rst_i),
        .ctrl_start_i(ctrl_start_write_coeff3),
        .ctrl_done_o(ctrl_done_write_coeff3),
        .ctrl_addr_offset_i(ctrl_addr_offset_write_coeff3),
        .ctrl_xfer_size_in_bytes_i(ctrl_xfer_size_in_bytes_write_coeff3),
        .m_axi_awvalid(coeff3_m_axi_awvalid),
        .m_axi_awready(coeff3_m_axi_awready),
        .m_axi_awaddr(coeff3_m_axi_awaddr),
        .m_axi_awlen(coeff3_m_axi_awlen),
        .m_axi_wvalid(coeff3_m_axi_wvalid),
        .m_axi_wready(coeff3_m_axi_wready),
        .m_axi_wdata(coeff3_m_axi_wdata),
        .m_axi_wstrb(coeff3_m_axi_wstrb),
        .m_axi_wlast(coeff3_m_axi_wlast),
        .m_axi_bvalid(coeff3_m_axi_bvalid),
        .m_axi_bready(coeff3_m_axi_bready),    
        .data_valid_i({NOF_BUTTERFLY_UNITS{coeff_valid_i}}),
        .data_i(coeff3_acc2axi),
        .rd_en_i(rd_en_coeff_wr_fifo_coeff3),
        .done_loading_o(done_loading_fifo_coeff3),
        .done_reading_o(done_reading_fifo_coeff3),
        .data_sent2axi_o(data_sent2axi_coeff3)
    );

    // Combine ctrl_done signals from 
    assign ctrl_done_write_coeff =  ctrl_done_write_coeff0 & 
                                    ctrl_done_write_coeff1 & 
                                    ctrl_done_write_coeff2 & 
                                    ctrl_done_write_coeff3;

    // Done strobes for output sync handshake
    logic coeff0_out_sync_done;
    logic coeff1_out_sync_done;
    logic coeff2_out_sync_done;
    logic coeff3_out_sync_done;

    // Synchronization of output channel
    logic start_output_sync_coeff0;
    logic job_output_sync_coeff0;
    logic coeff0_out_sync_ready;

    logic start_output_sync_coeff1;
    logic job_output_sync_coeff1;
    logic coeff1_out_sync_ready;
    
    logic start_output_sync_coeff2;
    logic job_output_sync_coeff2;
    logic coeff2_out_sync_ready;    

    logic start_output_sync_coeff3;
    logic job_output_sync_coeff3;
    logic coeff3_out_sync_ready;

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            job_output_sync_coeff0 <= 1'b0;
            job_output_sync_coeff1 <= 1'b0;
            job_output_sync_coeff2 <= 1'b0;
            job_output_sync_coeff3 <= 1'b0;
        end else begin
            if (done_reading_fifo_coeff3) begin
                job_output_sync_coeff3 <= 1'b1;
            end else if (job_output_sync_coeff3 && coeff3_out_sync_ready) begin
                job_output_sync_coeff3 <= 1'b0;
            end
            if (done_reading_fifo_coeff2) begin
                job_output_sync_coeff2 <= 1'b1;
            end else if (job_output_sync_coeff2 && coeff2_out_sync_ready) begin
                job_output_sync_coeff2 <= 1'b0;
            end
            if (done_reading_fifo_coeff1) begin
                job_output_sync_coeff1 <= 1'b1;
            end else if (job_output_sync_coeff1 && coeff1_out_sync_ready) begin
                job_output_sync_coeff1 <= 1'b0;
            end
            if (done_reading_fifo_coeff0) begin
                job_output_sync_coeff0 <= 1'b1;
            end else if (job_output_sync_coeff0 && coeff0_out_sync_ready) begin
                job_output_sync_coeff0 <= 1'b0;
            end
        end
    end
    
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            start_output_sync_coeff0 <= 1'b0;
            start_output_sync_coeff1 <= 1'b0;
            start_output_sync_coeff2 <= 1'b0;
            start_output_sync_coeff3 <= 1'b0;
        end else begin
            start_output_sync_coeff0 <= job_output_sync_coeff0 & coeff0_out_sync_ready;
            start_output_sync_coeff1 <= job_output_sync_coeff1 & coeff1_out_sync_ready;
            start_output_sync_coeff2 <= job_output_sync_coeff2 & coeff2_out_sync_ready;
            start_output_sync_coeff3 <= job_output_sync_coeff3 & coeff3_out_sync_ready;
        end
    end 
     
    channel_sync_fsm #(
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_XFER_SIZE_WIDTH(C_XFER_SIZE_WIDTH),
        .NOF_POLYNOMIALS(1),
        .DATA_WIDTH(DATA_WIDTH),
        .N(PIPELINE_LENGTH*N)
    ) U_COEFF0_OUT_SYN (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .start_i(start_output_sync_coeff0),
        .addr_i(coeff0_addr_offset_q),
        .ready_o(coeff0_out_sync_ready),
        .done_o(coeff0_out_sync_done),
        .ctrl_start_o(ctrl_start_write_coeff0),
        .ctrl_done_i(ctrl_done_write_coeff0),
        .ctrl_addr_offset_o(ctrl_addr_offset_write_coeff0),
        .ctrl_xfer_size_in_bytes_o(ctrl_xfer_size_in_bytes_write_coeff0)
    );

    channel_sync_fsm #(
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_XFER_SIZE_WIDTH(C_XFER_SIZE_WIDTH),
        .NOF_POLYNOMIALS(1),
        .DATA_WIDTH(DATA_WIDTH),
        .N(PIPELINE_LENGTH*N)
    ) U_COEFF1_OUT_SYN (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .start_i(start_output_sync_coeff1),
        .addr_i(coeff1_addr_offset_q),
        .ready_o(coeff1_out_sync_ready),
        .done_o(coeff1_out_sync_done),
        .ctrl_start_o(ctrl_start_write_coeff1),
        .ctrl_done_i(ctrl_done_write_coeff1),
        .ctrl_addr_offset_o(ctrl_addr_offset_write_coeff1),
        .ctrl_xfer_size_in_bytes_o(ctrl_xfer_size_in_bytes_write_coeff1)
    );

    channel_sync_fsm #(
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_XFER_SIZE_WIDTH(C_XFER_SIZE_WIDTH),
        .NOF_POLYNOMIALS(1),
        .DATA_WIDTH(DATA_WIDTH),
        .N(PIPELINE_LENGTH*N)
    ) U_COEFF2_OUT_SYN (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .start_i(start_output_sync_coeff2),
        .addr_i(coeff2_addr_offset_q),
        .ready_o(coeff2_out_sync_ready),
        .done_o(coeff2_out_sync_done),
        .ctrl_start_o(ctrl_start_write_coeff2),
        .ctrl_done_i(ctrl_done_write_coeff2),
        .ctrl_addr_offset_o(ctrl_addr_offset_write_coeff2),
        .ctrl_xfer_size_in_bytes_o(ctrl_xfer_size_in_bytes_write_coeff2)
    );

    channel_sync_fsm #(
        .C_M_AXI_ADDR_WIDTH(C_M_AXI_ADDR_WIDTH),
        .C_M_AXI_DATA_WIDTH(C_M_AXI_DATA_WIDTH),
        .C_XFER_SIZE_WIDTH(C_XFER_SIZE_WIDTH),
        .NOF_POLYNOMIALS(1),
        .DATA_WIDTH(DATA_WIDTH),
        .N(PIPELINE_LENGTH*N)
    ) U_COEFF3_OUT_SYN (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .start_i(start_output_sync_coeff3),
        .addr_i(coeff3_addr_offset_q),
        .ready_o(coeff3_out_sync_ready),
        .done_o(coeff3_out_sync_done),
        .ctrl_start_o(ctrl_start_write_coeff3),
        .ctrl_done_i(ctrl_done_write_coeff3),
        .ctrl_addr_offset_o(ctrl_addr_offset_write_coeff3),
        .ctrl_xfer_size_in_bytes_o(ctrl_xfer_size_in_bytes_write_coeff3)
    );
    logic coeff0_seen, coeff1_seen, coeff2_seen, coeff3_seen;
    logic sync_acc2buf_done;
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            sync_acc2buf_ready_o <= 1'b0;
            sync_acc2buf_done <= 1'b0;
            coeff0_seen <= 1'b0;
            coeff1_seen <= 1'b0;
            coeff2_seen <= 1'b0;
            coeff3_seen <= 1'b0;
        end else begin
            
            sync_acc2buf_ready_o <= coeff0_out_sync_ready & coeff1_out_sync_ready & coeff2_out_sync_ready & coeff3_out_sync_ready;
            // Capture the arrival of coeff0_out_sync_done and coeff1_out_sync_done
            if (coeff0_out_sync_done)
                coeff0_seen <= 1'b1;
            
            if (coeff1_out_sync_done)
                coeff1_seen <= 1'b1;

            if (coeff2_out_sync_done)
                coeff2_seen <= 1'b1;

            if (coeff3_out_sync_done)
                coeff3_seen <= 1'b1;
            // Generate the ap_done pulse
            if (sync_acc2buf_done) begin
                sync_acc2buf_done <= 1'b0;
            end else if (coeff0_seen && coeff1_seen && coeff2_seen && coeff3_seen) begin
                sync_acc2buf_done <= 1'b1;
                // Reset the captured states after generating the pulse
                coeff0_seen <= 1'b0;
                coeff1_seen <= 1'b0;
                coeff2_seen <= 1'b0;
                coeff3_seen <= 1'b0;
            end
        end
    end
    assign sync_acc2buf_done_o = sync_acc2buf_done;
endmodule
