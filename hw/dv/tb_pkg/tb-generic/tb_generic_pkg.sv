// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0


package tb_generic_pkg;

  task automatic resetsim(
    ref int errors
  );
    begin 
      errors = 0;   
    end  
  endtask : resetsim

  task automatic reset_uut(
    ref logic clk,
    ref logic rst_uut_n
  );   
  begin 
    rst_uut_n = 0;
    for (int i = 0; i<2;i++)
      @(posedge clk);
    @(negedge clk) rst_uut_n = 1;
 
    end 
  endtask : reset_uut

  task automatic verify_output(
    input logic[63:0] simulated_value,
    input logic[63:0] expected_value,
    ref int errors
  );
  begin
      if((simulated_value != expected_value) || ($isunknown(simulated_value)))
      begin
        errors = errors+1;
	      $display("Error - Simulated Value = %h, Expected Value = %h, Errors %d, at time %d \n", simulated_value,expected_value,errors,$time);
      end
    end

  endtask : verify_output

  task automatic write_ram_dummy(
    ref logic clk,
    ref logic[63:0] wdata,
    ref logic[15:0] waddr,
    ref logic wen,
    input integer N
  );
    begin
      // init
      wen = '0;
      wdata = '0;
      waddr = '0;
      
      // write ram
      for (int i = 0; i < N; i++) begin
        @(negedge clk);
        waddr = i;
        wdata = i;
        wen = '1;      
      end
      @(negedge clk);
      wen = '0;
      wdata = '0;
      waddr = '0; 
    end
  endtask : write_ram_dummy

  task automatic read_ram(
    ref logic clk,
    input logic [15:0] addr_i,
    output logic [63:0] rdbk_o,
    ref logic[63:0] rdata,
    ref logic[15:0] raddr,
    ref logic ren
  );
    begin
      ren = '0;
     
      @(negedge clk);
      raddr = addr_i;
      ren = '1;      
      
      @(negedge clk);
      ren = '0;
      rdbk_o = rdata;
      raddr = '0; 

    end
  endtask : read_ram


  task automatic write_ram(
    ref logic clk,
    ref logic[63:0] wdata,
    ref logic[15:0] waddr,
    ref logic wen,
    input logic [15:0] addr_i,
    input logic [63:0] data_i
  );
    begin
      // init
      wen = '0;
      wdata = '0;
      waddr = '0;
      
      @(negedge clk);
      waddr = addr_i;
      wdata = data_i;
      wen = '1;  

      @(negedge clk);
      wen = '0;
      wdata = '0;
      waddr = '0; 
    end
  endtask : write_ram

endpackage
