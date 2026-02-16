// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

package tb_axi_pkg;

    task automatic write_axi(

        ref logic clk,
        ref integer clk_cycles,

        input logic [31:0] data,
        input logic [7:0] address,

        // AXI Write Address Channel
        ref logic[7:0] s_axi_awaddr,
        ref logic[2:0] s_axi_awprot,
        ref logic s_axi_awvalid,
        ref logic s_axi_awready,
        // AXI Write Data Channel
        ref logic [31:0] s_axi_wdata,
        ref logic [3:0] s_axi_wstrb,
        ref logic s_axi_wvalid,
        ref logic s_axi_wready,
        // AXI Read Address Channel
        ref logic[7:0] s_axi_araddr,
        ref logic[2:0] s_axi_arprot,
        ref logic s_axi_arvalid,
        ref logic s_axi_arready,
        // AXI Read Data Channel
        ref logic [31:0] s_axi_rdata,
        ref logic[1:0] s_axi_rresp,
        ref logic s_axi_rvalid,
        ref logic s_axi_rready, 
        // AXi Write Response Channel
        ref logic [1:0] s_axi_bresp,
        ref logic s_axi_bvalid,
        ref logic s_axi_bready

        );   
        
        begin 

            @(negedge clk);

            // AXI Write Address Channel
            s_axi_awaddr = address;
            s_axi_awvalid = 1'b1;

            // AXI Write Data Channel
            s_axi_wdata = data;
            s_axi_wvalid = 1'b1;
            s_axi_wstrb = 'b1111;
        
            // AXI Write Response Channeö
            s_axi_bready = 1'b1;
  
            @(negedge clk);
            while (! (s_axi_awready & s_axi_wready)) begin  
                @(negedge clk);
                // ToDo: Separation
            end

            s_axi_awvalid = 1'b0;
            s_axi_wvalid = 1'b0;

            s_axi_awaddr = 'b0;

            s_axi_wstrb = 'b0000;
            s_axi_wdata = 'b0;
            while (! (s_axi_bvalid)) begin  
            @(negedge clk);
        // ToDo: Separation
            end

            if (s_axi_bresp == 2'b00) begin

            end

        end
        
        
    endtask : write_axi

    task automatic read_axi(

        output logic [31:0] data, 
        ref logic clk,
        ref integer clk_cycles,
        input logic [7:0] address,

        // AXI Write Address Channel
        ref logic[7:0] s_axi_awaddr,
        ref logic[2:0] s_axi_awprot,
        ref logic s_axi_awvalid,
        ref logic s_axi_awready,
        // AXI Write Data Channel
        ref logic [31:0] s_axi_wdata,
        ref logic [3:0] s_axi_wstrb,
        ref logic s_axi_wvalid,
        ref logic s_axi_wready,
        // AXI Read Address Channel
        ref logic[7:0] s_axi_araddr,
        ref logic[2:0] s_axi_arprot,
        ref logic s_axi_arvalid,
        ref logic s_axi_arready,
        // AXI Read Data Channel
        ref logic [31:0] s_axi_rdata,
        ref logic[1:0] s_axi_rresp,
        ref logic s_axi_rvalid,
        ref logic s_axi_rready, 
        // AXi Write Response Channel
        ref logic [1:0] s_axi_bresp,
        ref logic s_axi_bvalid,
        ref logic s_axi_bready
        );   
        
        
        begin 

            @(negedge clk);
            s_axi_araddr = address;
            s_axi_arvalid = 1'b1;
            s_axi_rready = 1'b1;
            @(negedge clk);

            while (! (s_axi_arready)) begin  
                @(negedge clk);
                // ToDo: Separation
            end
            s_axi_arvalid = 1'b0;

            while (! (s_axi_rvalid)) begin  
                @(negedge clk);
                // ToDo: Separation
            end

            data = s_axi_rdata;
            @(negedge clk);

            s_axi_rready = 1'b1;

        end
        
        
    endtask : read_axi

endpackage