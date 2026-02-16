// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`timescale 1ns/10ps

// Designed according to https://zipcpu.com/blog/2020/03/08/easyaxil.html and https://github.com/Xilinx/Vitis-Tutorials/tree/2024.2/Hardware_Acceleration
module top_ntt_axi_slave #
	(

    // Enable/disable skid buffer usage
    // Skid buffer costs more logic but achieves 2x higher throughput
    parameter SKID_BUFFER = "False",

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter C_S_AXI_DATA_WIDTH = 32,

		// Width of S_AXI address bus
		parameter C_S_AXI_ADDR_WIDTH = 7,

    // Width of M_AXI address bus
    parameter C_M_AXI_ADDR_WIDTH = 64
	)
	(
		// Users to add ports here
    
    output logic                          interrupt,
    output logic                          ap_start,
    output logic                          ap_continue,
    input  logic                          ap_done,
    input  logic                          ap_ready,
    input  logic                          ap_idle,

    // Version
    input  logic [7:0]                    v_major,
    input  logic [7:0]                    v_minor,
    input  logic [7:0]                    v_patch,

    // Hardware acceleration
    output logic [C_M_AXI_ADDR_WIDTH-1:0] coeff0_addr_offset,
    output logic [C_M_AXI_ADDR_WIDTH-1:0] coeff1_addr_offset,
    output logic [C_M_AXI_ADDR_WIDTH-1:0] coeff2_addr_offset,
    output logic [C_M_AXI_ADDR_WIDTH-1:0] coeff3_addr_offset,

    output logic [C_S_AXI_DATA_WIDTH-1:0] ntt_config,
    output logic [C_S_AXI_DATA_WIDTH-1:0] ntt_batch_size,

		// User ports ends

		// Global Clock Signal
		input logic  S_AXI_ACLK,

		// Global Reset Signal. This Signal is Active LOW
		input logic  S_AXI_ARESET,

		// Write address (issued by master, acceped by Slave)
		input logic [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,

		// Write channel Protection type. This signal indicates the
    // privilege and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		input logic [2 : 0] S_AXI_AWPROT,

		// Write address valid. This signal indicates that the master signaling
    // valid write address and control information.
		input logic  S_AXI_AWVALID,

		// Write address ready. This signal indicates that the slave is ready
    // to accept an address and associated control signals.
		output logic  S_AXI_AWREADY,

		// Write data (issued by master, acceped by Slave)
		input logic [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,

		// Write strobes. This signal indicates which byte lanes hold
    // valid data. There is one write strobe bit for each eight
    // bits of the write data bus.
		input logic [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,

		// Write valid. This signal indicates that valid write
    // data and strobes are available.
		input logic  S_AXI_WVALID,

		// Write ready. This signal indicates that the slave
    // can accept the write data.
		output logic  S_AXI_WREADY,

		// Write response. This signal indicates the status
    // of the write transaction.
		output logic [1 : 0] S_AXI_BRESP,

		// Write response valid. This signal indicates that the channel
    // is signaling a valid write response.
		output logic  S_AXI_BVALID,

		// Response ready. This signal indicates that the master
    // can accept a write response.
		input logic  S_AXI_BREADY,

		// Read address (issued by master, acceped by Slave)
		input logic [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,

		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether the
    // transaction is a data access or an instruction access.
		input logic [2 : 0] S_AXI_ARPROT,

		// Read address valid. This signal indicates that the channel
    // is signaling valid read address and control information.
		input logic  S_AXI_ARVALID,

		// Read address ready. This signal indicates that the slave is
    // ready to accept an address and associated control signals.
		output logic  S_AXI_ARREADY,

		// Read data (issued by slave)
		output logic [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,

		// Read response. This signal indicates the status of the
    // read transfer.
		output logic [1 : 0] S_AXI_RRESP,

		// Read valid. This signal indicates that the channel is
    // signaling the required read data.
		output logic  S_AXI_RVALID,

		// Read ready. This signal indicates that the master can
    // accept the read data and response information.
		input logic  S_AXI_RREADY
);
    // Local functions
    function [C_S_AXI_DATA_WIDTH-1:0]	apply_wstrb;
        input	[C_S_AXI_DATA_WIDTH-1:0]	prior_data;
        input	[C_S_AXI_DATA_WIDTH-1:0]	new_data;
        input	[C_S_AXI_DATA_WIDTH/8-1:0]	wstrb;

        integer	k;
        for(k=0; k<C_S_AXI_DATA_WIDTH/8; k=k+1)
        begin
            apply_wstrb[k*8 +: 8] = wstrb[k] ? new_data[k*8 +: 8] : prior_data[k*8 +: 8];
        end
    endfunction

    // Local parameters
    localparam ADDRLSB = $clog2(C_S_AXI_DATA_WIDTH)-3;

    // Internal signals
    logic [C_S_AXI_ADDR_WIDTH-1-ADDRLSB:0] awskd_addr;
    logic [C_S_AXI_ADDR_WIDTH-1-ADDRLSB:0] arskd_addr;
    logic [C_S_AXI_DATA_WIDTH-1:0] wskd_data;
    logic [(C_S_AXI_DATA_WIDTH/8)-1 : 0] wskd_strb;

    logic axil_write_ready;
    logic axil_read_ready;
    logic axil_bvalid;
    logic axil_awready;
    logic axil_read_valid;
    logic axil_arready;

    logic [C_S_AXI_DATA_WIDTH-1:0] axil_read_data;

    //////////////////////////////////////////////////////////////////////////
    // Registers
    //////////////////////////////////////////////////////////////////////////

    //------------------------Address Info-------------------
    // 0x00 : Control signals
    //        bit 0  - ap_start (Read/Write/COH)
    //        bit 1  - ap_done (Read/COR)
    //        bit 2  - ap_idle (Read)
    //        bit 3  - ap_ready (Read)
    //        bit 4  - ap_continue (Read/Write)
    //        bit 7  - auto_restart (Read/Write)
    //        others - reserved
    // 0x04 : Global Interrupt Enable Register
    //        bit 0  - Global Interrupt Enable (Read/Write)
    //        others - reserved
    // 0x08 : IP Interrupt Enable Register (Read/Write)
    //        bit 0  - Channel 0 (ap_done)
    //        bit 1  - Channel 1 (ap_ready)
    //        others - reserved
    // 0x0c : IP Interrupt Status Register (Read/TOW)
    //        bit 0  - Channel 0 (ap_done)
    //        bit 1  - Channel 1 (ap_ready)
    //        others - reserved
    // 0x10 : Version
    //        bit 7:0   - Patch
    //        bit 15:8  - Minor Revision
    //        bit 23:16 - Major Revision
    // 0x14 : NTT Config Register (Read/Write)
    // 0x18 : NTT Batch Size Register (Read/Write)
    // 0x20 : Base Address for Coefficients 0 (Read/Write) 31:0
    // 0x24 : Base Address for Coefficients 0 (Read/Write) 63:32
    // 0x28 : Base Address for Coefficients 1 (Read/Write) 31:0
    // 0x2C : Base Address for Coefficients 1 (Read/Write) 63:32
    // 0x30 : Base Address for Coefficients 2 (Read/Write) 31:0
    // 0x34 : Base Address for Coefficients 2 (Read/Write) 63:32
    // 0x38 : Base Address for Coefficients 3 (Read/Write) 31:0
    // 0x3C : Base Address for Coefficients 3 (Read/Write) 63:32
    // (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

    // Register declaration
    logic [C_S_AXI_DATA_WIDTH-1:0]  r_ctrl, 
                                    r_gier, 
                                    r_ip_ier, 
                                    r_ip_isr, 
                                    r_version, 
                                    r_addr_coeff0_0,
                                    r_addr_coeff0_1,
                                    r_addr_coeff1_0, 
                                    r_addr_coeff1_1, 
                                    r_addr_coeff2_0, 
                                    r_addr_coeff2_1, 
                                    r_addr_coeff3_0, 
                                    r_addr_coeff3_1, 
                                    r_ntt_config, 
                                    r_ntt_batch_size;

    // Internal write strobe signals
    logic [C_S_AXI_DATA_WIDTH-1:0]  wskd_r_ctrl,
                                    wskd_r_gier, 
                                    wskd_r_ip_ier, 
                                    wskd_r_ip_isr, 
                                    wskd_r_addr_coeff0_0, 
                                    wskd_r_addr_coeff0_1, 
                                    wskd_r_addr_coeff1_0,
                                    wskd_r_addr_coeff1_1,
                                    wskd_r_addr_coeff2_0, 
                                    wskd_r_addr_coeff2_1, 
                                    wskd_r_addr_coeff3_0, 
                                    wskd_r_addr_coeff3_1, 
                                    wskd_r_ntt_config, 
                                    wskd_r_ntt_batch_size;

    // Inital register values
    initial	r_gier = 0;
    initial	r_ip_ier = 0;
    initial	r_ip_isr = 0;

    // Apply write strobe: apply_wstrb(old_data, new_data, write_strobes)
    assign	wskd_r_ctrl = apply_wstrb(r_ctrl, wskd_data, wskd_strb);
    assign	wskd_r_gier = apply_wstrb(r_gier, wskd_data, wskd_strb);
    assign	wskd_r_ip_ier = apply_wstrb(r_ip_ier, wskd_data, wskd_strb);
    assign	wskd_r_ip_isr = apply_wstrb(r_ip_isr, wskd_data, wskd_strb);
    assign	wskd_r_addr_coeff0_0 = apply_wstrb(r_addr_coeff0_0, wskd_data, wskd_strb);
    assign	wskd_r_addr_coeff0_1 = apply_wstrb(r_addr_coeff0_1, wskd_data, wskd_strb);
    assign	wskd_r_addr_coeff1_0 = apply_wstrb(r_addr_coeff1_0, wskd_data, wskd_strb);
    assign	wskd_r_addr_coeff1_1 = apply_wstrb(r_addr_coeff1_1, wskd_data, wskd_strb);
    assign	wskd_r_addr_coeff2_0 = apply_wstrb(r_addr_coeff2_0, wskd_data, wskd_strb);
    assign	wskd_r_addr_coeff2_1 = apply_wstrb(r_addr_coeff2_1, wskd_data, wskd_strb);
    assign	wskd_r_addr_coeff3_0 = apply_wstrb(r_addr_coeff3_0, wskd_data, wskd_strb);
    assign	wskd_r_addr_coeff3_1 = apply_wstrb(r_addr_coeff3_1, wskd_data, wskd_strb);
	  assign	wskd_r_ntt_config = apply_wstrb(r_ntt_config, wskd_data, wskd_strb);
    assign	wskd_r_ntt_batch_size = apply_wstrb(r_ntt_batch_size, wskd_data, wskd_strb);

    // Trigger interrupt
    assign interrupt = r_gier[0] & (|r_ip_isr);

    // Reserved
    assign r_ctrl[31:8] = '0;
    assign r_ctrl[6:5] = '0;

    // R_CTRL_AP_START
    always @(posedge S_AXI_ACLK) begin : r_ctrl_ap_start
        if (S_AXI_ARESET) begin
            r_ctrl[0] <= 1'b0;
        end else if (axil_write_ready && awskd_addr == 6'b000000) begin
            r_ctrl[0] <= wskd_r_ctrl[0];
        // Auto restart
        end else if (ap_ready) begin
            r_ctrl[0] <= r_ctrl[7]; // Clear on handshake (ap_ready)/auto restart
        end
    end
    assign ap_start = r_ctrl[0];

    // R_CTRL_AP_DONE
    always @(posedge S_AXI_ACLK) begin : r_ctrl_ap_done
        if (S_AXI_ARESET) begin
            r_ctrl[1] <= 1'b0;
        end else if (ap_done) begin
            r_ctrl[1] <= 1'b1;
        end else if (axil_read_ready && arskd_addr == 6'b000000) begin
            r_ctrl[1] <= 1'b0; // Clear on read
        end
    end   

    // R_CTRL_AP_IDLE
    always @(posedge S_AXI_ACLK) begin : r_ctrl_ap_idle
        if (S_AXI_ARESET) begin
            r_ctrl[2] <= 1'b0;
        end else begin
            r_ctrl[2] <= ap_idle;
        end
    end  

    // R_CTRL_AP_READY
    always @(posedge S_AXI_ACLK) begin : r_ctrl_ap_ready
        if (S_AXI_ARESET) begin
            r_ctrl[3] <= 1'b0;
        end else begin
            r_ctrl[3] <= ap_ready;
        end
    end  

    // R_CTRL_AP_CONTINUE
    always @(posedge S_AXI_ACLK) begin : r_ctrl_ap_continue
        r_ctrl[4] <= 1'b0; // SC
        if (S_AXI_ARESET) begin
            r_ctrl[4] <= 1'b0;
        end else if (axil_write_ready && awskd_addr == 6'b000000) begin
            r_ctrl[4] <= wskd_r_ctrl[4];
        end
    end
    assign ap_continue = r_ctrl[4];

    // R_CTRL_AUTO_RESTART
    always @(posedge S_AXI_ACLK) begin : r_ctrl_auto_restart
        if (S_AXI_ARESET) begin
            r_ctrl[7] <= 1'b0;
        end else if (axil_write_ready && awskd_addr == 6'b000000) begin
            r_ctrl[7] <= wskd_r_ctrl[7];
        end
    end

    // R_GIER
    always @(posedge S_AXI_ACLK) begin : r_gier_0
        if (S_AXI_ARESET) begin
            r_gier[0] <= 1'b0;
        end else if (axil_write_ready && awskd_addr == 6'b000001) begin
            r_gier[0] <= wskd_r_gier[0];
        end
    end

    // R_IER_0
    always @(posedge S_AXI_ACLK) begin : r_ier_0
        if (S_AXI_ARESET) begin
            r_ip_ier[0] <= 1'b0;
        end else if (axil_write_ready && awskd_addr == 6'b000010) begin
            r_ip_ier[0] <= wskd_r_ip_ier[0];
        end
    end

    // R_IER_1
    always @(posedge S_AXI_ACLK) begin : r_ier_1
        if (S_AXI_ARESET) begin
            r_ip_ier[1] <= 1'b0;
        end else if (axil_write_ready && awskd_addr == 6'b000010) begin
            r_ip_ier[1] <= wskd_r_ip_ier[1];
        end
    end

    // R_ISR_0
    always @(posedge S_AXI_ACLK) begin : r_isr_0
        if (S_AXI_ARESET) begin
            r_ip_isr[0] <= 1'b0;
        end if (r_ip_ier[0] & ap_done)
            r_ip_isr[0] <= 1'b1;
        else if (axil_write_ready && awskd_addr == 6'b000011) begin
            // Toggle on write
            r_ip_isr[0] <= r_ip_isr[0] ^ wskd_r_ip_isr[0]; 
        end
    end

    // R_ISR_1
    always @(posedge S_AXI_ACLK) begin : r_isr_1
        if (S_AXI_ARESET) begin
            r_ip_isr[1] <= 1'b0;
        end if (r_ip_ier[1] & ap_ready)
            r_ip_isr[1] <= 1'b1;
        else if (axil_write_ready && awskd_addr == 6'b000011) begin
            // Toggle on write
            r_ip_isr[1] <= r_ip_isr[1] ^ wskd_r_ip_isr[1];
        end
    end

    // R_VERSION
    assign r_version = {8'b00000000,v_major,v_minor,v_patch};


    // R_NTT_CONFIG
    always @(posedge S_AXI_ACLK) begin : reg_ntt_config
        if (S_AXI_ARESET) begin
            r_ntt_config <= 'b0;
        end else if (axil_write_ready && awskd_addr == 4'b0101) begin
            r_ntt_config <= wskd_r_ntt_config;
        end
    end
    assign ntt_config = r_ntt_config;

    // R_NTT_BATCH_SIZE
    always @(posedge S_AXI_ACLK) begin : reg_ntt_batch_size
        if (S_AXI_ARESET) begin
            r_ntt_batch_size <= 'b0;
        end else if (axil_write_ready && awskd_addr == 4'b0110) begin
            r_ntt_batch_size <= wskd_r_ntt_batch_size;
        end
    end
    assign ntt_batch_size = r_ntt_batch_size;


    // R_ADDR_COEFF0_0
    always @(posedge S_AXI_ACLK) begin : reg_addr_coeff0_0
        if (S_AXI_ARESET) begin
            r_addr_coeff0_0 <= 'b0;
        end else if (axil_write_ready && awskd_addr == 4'b1000) begin
            r_addr_coeff0_0 <= wskd_r_addr_coeff0_0;
        end
    end
    assign coeff0_addr_offset[31:0] = r_addr_coeff0_0;

    // R_ADDR_COEFF0_1
    always @(posedge S_AXI_ACLK) begin : reg_addr_coeff0_1
        if (S_AXI_ARESET) begin
            r_addr_coeff0_1 <= 'b0;
        end else if (axil_write_ready && awskd_addr == 4'b1001) begin
            r_addr_coeff0_1 <= wskd_r_addr_coeff0_1;
        end
    end
    assign coeff0_addr_offset[63:32] = r_addr_coeff0_1;

    // R_ADDR_COEFF1_0
    always @(posedge S_AXI_ACLK) begin : reg_addr_coeff1_0
        if (S_AXI_ARESET) begin
            r_addr_coeff1_0 <= 'b0;
        end else if (axil_write_ready && awskd_addr == 4'b1010) begin
            r_addr_coeff1_0 <= wskd_r_addr_coeff1_0;
        end
    end
    assign coeff1_addr_offset[31:0] = r_addr_coeff1_0;

    // R_ADDR_COEFF1_1
    always @(posedge S_AXI_ACLK) begin : reg_addr_coeff1_1
        if (S_AXI_ARESET) begin
            r_addr_coeff1_1 <= 'b0;
        end else if (axil_write_ready && awskd_addr == 4'b1011) begin
            r_addr_coeff1_1 <= wskd_r_addr_coeff0_1;
        end
    end
    assign coeff1_addr_offset[63:32] = r_addr_coeff1_1;

    // R_ADDR_COEFF2_0
    always @(posedge S_AXI_ACLK) begin : reg_addr_coeff2_0
        if (S_AXI_ARESET) begin
            r_addr_coeff2_0 <= 'b0;
        end else if (axil_write_ready && awskd_addr == 4'b1100) begin
            r_addr_coeff2_0 <= wskd_r_addr_coeff0_0;
        end
    end
    assign coeff2_addr_offset[31:0] = r_addr_coeff2_0;

    // R_ADDR_COEFF2_1
    always @(posedge S_AXI_ACLK) begin : reg_addr_coeff2_1
        if (S_AXI_ARESET) begin
            r_addr_coeff2_1 <= 'b0;
        end else if (axil_write_ready && awskd_addr == 4'b1101) begin
            r_addr_coeff2_1 <= wskd_r_addr_coeff2_1;
        end
    end
    assign coeff2_addr_offset[63:32] = r_addr_coeff2_1;

    // R_ADDR_COEFF3_0
    always @(posedge S_AXI_ACLK) begin : reg_addr_coeff3_0
        if (S_AXI_ARESET) begin
            r_addr_coeff3_0 <= 'b0;
        end else if (axil_write_ready && awskd_addr == 4'b1110) begin
            r_addr_coeff3_0 <= wskd_r_addr_coeff3_0;
        end
    end
    assign coeff3_addr_offset[31:0] = r_addr_coeff3_0;

    // R_ADDR_COEFF3_1
    always @(posedge S_AXI_ACLK) begin : reg_addr_coeff3_1
        if (S_AXI_ARESET) begin
            r_addr_coeff3_1 <= 'b0;
        end else if (axil_write_ready && awskd_addr == 4'b1111) begin
            r_addr_coeff3_1 <= wskd_r_addr_coeff3_1;
        end
    end
    assign coeff3_addr_offset[63:32] = r_addr_coeff3_1;


    initial	axil_read_data = 0;
    always @(posedge S_AXI_ACLK) begin : read_mechanism
        if (S_AXI_ARESET) 
            axil_read_data <= 0;
        else if (!S_AXI_RVALID || S_AXI_RREADY)
        begin
            case(arskd_addr)
                4'b0000:	axil_read_data	<= r_ctrl;
                4'b0001:	axil_read_data	<= r_gier;
                4'b0010:	axil_read_data	<= r_ip_ier;
                4'b0011:	axil_read_data	<= r_ip_isr;

                4'b0100:  axil_read_data	<= r_version;
                4'b0101:	axil_read_data	<= r_ntt_config;
                4'b0110:	axil_read_data	<= r_ntt_batch_size;

                4'b1000:	axil_read_data	<= r_addr_coeff0_0;
                4'b1001:	axil_read_data	<= r_addr_coeff0_1;
                4'b1010:	axil_read_data	<= r_addr_coeff1_0;
                4'b1011:	axil_read_data	<= r_addr_coeff1_1;
                4'b1100:	axil_read_data	<= r_addr_coeff2_0;
                4'b1101:	axil_read_data	<= r_addr_coeff2_1;
                4'b1110:	axil_read_data	<= r_addr_coeff3_0;
                4'b1111:	axil_read_data	<= r_addr_coeff3_1;
            endcase
        end
        if (!axil_read_ready)
            axil_read_data <= 0;
    end : read_mechanism


    //////////////////////////////////////////////////////////////////////////
    // Handshake
    //////////////////////////////////////////////////////////////////////////

    // Response signals (not implemented yet)
    assign	S_AXI_BRESP = 2'b00;
    assign	S_AXI_RRESP = 2'b00;

    // Write handhsake - indicate successful write
    initial	axil_bvalid = 0;
    always @(posedge S_AXI_ACLK) begin : whandshake_mechanism
          if (S_AXI_ARESET)
              axil_bvalid <= 0;
          else if (axil_write_ready)
              axil_bvalid <= 1;
          else if (S_AXI_BREADY)
              axil_bvalid <= 0;
      end : whandshake_mechanism

    assign	S_AXI_BVALID = axil_bvalid;

    // Read handhsake - indicate successful read
    initial	axil_read_valid = 1'b0;
    always @(posedge S_AXI_ACLK) begin : rhandshake_mechanism
          if (S_AXI_ARESET)
              axil_read_valid <= 1'b0;
          else if (axil_read_ready)
              axil_read_valid <= 1'b1;
          else if (S_AXI_RREADY)
              axil_read_valid <= 1'b0;
      end : rhandshake_mechanism

    assign	S_AXI_RVALID = axil_read_valid;

	// We accomplished all of our S_AXI_RDATA logic above, so we just
	// set the bus return signal, S_AXI_RDATA, to it here.
	assign	S_AXI_RDATA  = axil_read_data;

    generate;
        if (SKID_BUFFER == "False") begin : g_handshake_wo_skid_buffer

            assign 	awskd_addr = S_AXI_AWADDR[C_S_AXI_ADDR_WIDTH-1:ADDRLSB];
            //assign 	arskd_addr = S_AXI_ARADDR[C_S_AXI_ADDR_WIDTH-1:ADDRLSB];
            assign	wskd_data  = S_AXI_WDATA;
            assign	wskd_strb  = S_AXI_WSTRB;

            initial	axil_awready = 1'b0;
            always @(posedge S_AXI_ACLK) begin
            if (S_AXI_ARESET) begin
                axil_awready <= 1'b0;
            end else begin
                axil_awready <= !axil_awready
                    && (S_AXI_AWVALID && S_AXI_WVALID)
                    && (!S_AXI_BVALID || S_AXI_BREADY);
            end
            end

            assign	S_AXI_AWREADY = axil_awready;
            assign	S_AXI_WREADY  = axil_awready;
            assign	axil_write_ready = axil_awready;     
            assign	axil_read_ready = (S_AXI_ARVALID && S_AXI_ARREADY);

            always_comb begin
                axil_arready = !S_AXI_RVALID;
            end

            assign	arskd_addr = S_AXI_ARADDR[C_S_AXI_ADDR_WIDTH-1:ADDRLSB];     
            assign	S_AXI_ARREADY = axil_arready;

        end : g_handshake_wo_skid_buffer 
        
        else if (SKID_BUFFER == "True") begin
            logic	awskd_valid, wskd_valid;

            skidbuffer #(.OPT_OUTREG(0),
                    .DW(C_S_AXI_ADDR_WIDTH-ADDRLSB))
            axilawskid(//
                .i_clk(S_AXI_ACLK), .i_reset(S_AXI_ARESET),
                .i_valid(S_AXI_AWVALID), .o_ready(S_AXI_AWREADY),
                .i_data(S_AXI_AWADDR[C_S_AXI_ADDR_WIDTH-1:ADDRLSB]),
                .o_valid(awskd_valid), .i_ready(axil_write_ready),
                .o_data(awskd_addr));

            skidbuffer #(.OPT_OUTREG(0),
                    .DW(C_S_AXI_DATA_WIDTH+C_S_AXI_DATA_WIDTH/8))
            axilwskid(//
                .i_clk(S_AXI_ACLK), .i_reset(S_AXI_ARESET),
                .i_valid(S_AXI_WVALID), .o_ready(S_AXI_WREADY),
                .i_data({ S_AXI_WDATA, S_AXI_WSTRB }),
                .o_valid(wskd_valid), .i_ready(axil_write_ready),
                .o_data({ wskd_data, wskd_strb }));

            assign	axil_write_ready = awskd_valid && wskd_valid
                    && (!S_AXI_BVALID || S_AXI_BREADY);

	        logic	arskd_valid;

            skidbuffer #(.OPT_OUTREG(0), .DW(C_S_AXI_ADDR_WIDTH-ADDRLSB))
            axilarskid(//
                .i_clk(S_AXI_ACLK), .i_reset(S_AXI_ARESET),
                .i_valid(S_AXI_ARVALID), .o_ready(S_AXI_ARREADY),
                .i_data(S_AXI_ARADDR[C_S_AXI_ADDR_WIDTH-1:ADDRLSB]),
                .o_valid(arskd_valid), .i_ready(axil_read_ready),
                .o_data(arskd_addr));

            assign	axil_read_ready = arskd_valid
                    && (!axil_read_valid || S_AXI_RREADY);

            end
    endgenerate

endmodule
