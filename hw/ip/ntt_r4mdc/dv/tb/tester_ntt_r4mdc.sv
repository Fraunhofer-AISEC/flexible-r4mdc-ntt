// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

`resetall
`timescale 1ns/10ps

module tester_ntt_r4mdc
    import tb_generic_pkg::*;
#(
    parameter int unsigned DATA_WIDTH = 27,
    parameter int unsigned N = 1024,
    parameter int unsigned NOF_BUTTERFLY_UNITS = 4,
    parameter BUTTERFLY_TYPE = "CT",
    parameter TESTCASE_PATH = "STD128",
    parameter TEST_NAME = "STD128",
    parameter LOG_FILE = "../sim_results.log",
    parameter TEX_FILE = "../sim_results.tex"

) (
    input   logic                       clk_i,
    input   logic                       rst_i,
    output  logic                       intt_o,
    input   logic   [DATA_WIDTH-1:0]    data0_i[NOF_BUTTERFLY_UNITS-1:0],
    input   logic   [DATA_WIDTH-1:0]    data1_i[NOF_BUTTERFLY_UNITS-1:0],
    input   logic   [DATA_WIDTH-1:0]    data2_i[NOF_BUTTERFLY_UNITS-1:0],
    input   logic   [DATA_WIDTH-1:0]    data3_i[NOF_BUTTERFLY_UNITS-1:0],
    input   logic                       data_valid_i,

    output  logic   [DATA_WIDTH-1:0]    data0_o[NOF_BUTTERFLY_UNITS-1:0],
    output  logic   [DATA_WIDTH-1:0]    data1_o[NOF_BUTTERFLY_UNITS-1:0],
    output  logic   [DATA_WIDTH-1:0]    data2_o[NOF_BUTTERFLY_UNITS-1:0],
    output  logic   [DATA_WIDTH-1:0]    data3_o[NOF_BUTTERFLY_UNITS-1:0],
    output  logic                       data_valid_o
);
    int errors_total;   
    localparam string uut_name = "NTT-R4MDC";
    localparam int nof_runs = 100;
    // Variables which hold testvector and expected output
    typedef struct {
        logic [DATA_WIDTH-1:0] coeff_i [N-1:0];
        logic [DATA_WIDTH-1:0] coeff_o [N-1:0];
    } ntt_t;


    function automatic ntt_t read_testvector (string TESTCASE_PATH, string TEST_NAME);
        ntt_t testvector;
        logic [DATA_WIDTH-1:0] coeff_tmp [N-1:0];
        logic [DATA_WIDTH-1:0] exp_tmp [N-1:0];
        $readmemh($sformatf("%s/testvector_coeff_%s.mem", TESTCASE_PATH, TEST_NAME),coeff_tmp); 
        $readmemh($sformatf("%s/testvector_coeff_exp_%s.mem", TESTCASE_PATH, TEST_NAME), exp_tmp);
        testvector.coeff_i = coeff_tmp;
        testvector.coeff_o = exp_tmp;
        return testvector;
    endfunction 

    localparam NTTS_PER_NTT = 2;

    localparam BFU_PER_GROUP =  (NOF_BUTTERFLY_UNITS == 32) ? 2 :
                                (NOF_BUTTERFLY_UNITS == 8) ? 2 : 1;
    localparam STRIDE_BETWEEN_BFUS_IN_GROUP =   (NOF_BUTTERFLY_UNITS == 32) ? N/64 : 
                                                (NOF_BUTTERFLY_UNITS == 8) ? N/16 : 0;
    localparam STRIDE_BETWEEN_BFUGROUP =    (NOF_BUTTERFLY_UNITS == 32) ? N/16 : 
                                            (NOF_BUTTERFLY_UNITS == 8) ? N/4 : N/2;
    localparam STRIDE_BETWEEN_NTT_IN_BFU =  (NOF_BUTTERFLY_UNITS == 32) ? N/32 :
                                            (NOF_BUTTERFLY_UNITS == 8) ? N/8 : N/4;

    task measure_latency_dit (ntt_t testcase [nof_runs-1:0]);

      // CC counter
      longint cc;
      // Latency of 100 Operations
      longint cc_start;
      longint cc_end;

      // Latency of 1 Operation
      longint cc_start_latency;
      longint cc_end_latency;

      // logfiles
      integer logfile;  
      integer texfile; 

      int errors;

      intt_o = 1'b0;

      fork

        begin : f_cc_cnt
          cc = 0;
          while(1) begin
              @(posedge clk_i) ;
              cc = cc + 1;
          end
        end
        fork
        begin : f_stimulate

          @(negedge clk_i);
          cc_start_latency = cc;
          cc_start = cc;
          for (int k=0; k<nof_runs; ++k) begin
            for (int j=0; j<(N/4)/NOF_BUTTERFLY_UNITS; ++j) begin
                for (int i=0; i<NOF_BUTTERFLY_UNITS; ++i) begin
                    data0_o[i] = testcase[k].coeff_i[j+(i*N/(4*NOF_BUTTERFLY_UNITS))];
                    data1_o[i] = testcase[k].coeff_i[N/4+j+(i*N/(4*NOF_BUTTERFLY_UNITS))];
                    data2_o[i] = testcase[k].coeff_i[N/2+j+(i*N/(4*NOF_BUTTERFLY_UNITS))];
                    data3_o[i] = testcase[k].coeff_i[N/2+N/4+j+(i*N/(4*NOF_BUTTERFLY_UNITS))];                    
                end
                data_valid_o = '1;
                @(negedge clk_i);
            end
          end
          data_valid_o = '0;
        end

        begin : f_measure_and_verify
          // Reset error count
          errors = 0;
          logfile = $fopen({LOG_FILE},"a");
          texfile = $fopen({TEX_FILE},"a");
          for (int k=0; k<nof_runs; ++k) begin
            if (NOF_BUTTERFLY_UNITS == 2 || NOF_BUTTERFLY_UNITS == 8 || NOF_BUTTERFLY_UNITS == 32 ) begin
              for (int n=0; n<NTTS_PER_NTT; ++n) begin
                  for (int j=0; j<((N/4)/NOF_BUTTERFLY_UNITS)/NTTS_PER_NTT; ++j) begin
                      wait ((data_valid_i == 1'b1) && (clk_i ==1'b0));
                      // Iterate through all Butterfly Units
                      for (int i=0; i<NOF_BUTTERFLY_UNITS/BFU_PER_GROUP; ++i) begin
                          for (int l=0; l<BFU_PER_GROUP; ++l) begin
                              verify_output(.simulated_value(data0_i[BFU_PER_GROUP*i+l]) ,.expected_value(testcase[k].coeff_o[4*j + i*STRIDE_BETWEEN_BFUGROUP + l*STRIDE_BETWEEN_BFUS_IN_GROUP + n*STRIDE_BETWEEN_NTT_IN_BFU]),.errors(errors));
                              verify_output(.simulated_value(data1_i[BFU_PER_GROUP*i+l]) ,.expected_value(testcase[k].coeff_o[4*j+1 + i*STRIDE_BETWEEN_BFUGROUP + l*STRIDE_BETWEEN_BFUS_IN_GROUP + n*STRIDE_BETWEEN_NTT_IN_BFU]),.errors(errors)); 
                              verify_output(.simulated_value(data2_i[BFU_PER_GROUP*i+l]) ,.expected_value(testcase[k].coeff_o[4*j+2 + i*STRIDE_BETWEEN_BFUGROUP + l*STRIDE_BETWEEN_BFUS_IN_GROUP + n*STRIDE_BETWEEN_NTT_IN_BFU]),.errors(errors));
                              verify_output(.simulated_value(data3_i[BFU_PER_GROUP*i+l]) ,.expected_value(testcase[k].coeff_o[4*j+3 + i*STRIDE_BETWEEN_BFUGROUP + l*STRIDE_BETWEEN_BFUS_IN_GROUP + n*STRIDE_BETWEEN_NTT_IN_BFU]),.errors(errors));   
                          end
                      end
                  @(negedge clk_i);
                  end 
              end
            end else begin  
              for (int j=0; j<(N/4)/NOF_BUTTERFLY_UNITS; ++j) begin
                  wait ((data_valid_i == 1'b1) && (clk_i ==1'b0));
                  for (int i=0; i<NOF_BUTTERFLY_UNITS; ++i) begin
                      verify_output(.simulated_value(data0_i[i]) ,.expected_value(testcase[k].coeff_o[4*j + i*(N/NOF_BUTTERFLY_UNITS)]),.errors(errors));
                      verify_output(.simulated_value(data1_i[i]) ,.expected_value(testcase[k].coeff_o[4*j+1 + i*(N/NOF_BUTTERFLY_UNITS)]),.errors(errors)); 
                      verify_output(.simulated_value(data2_i[i]) ,.expected_value(testcase[k].coeff_o[4*j+2 + i*(N/NOF_BUTTERFLY_UNITS)]),.errors(errors));
                      verify_output(.simulated_value(data3_i[i]) ,.expected_value(testcase[k].coeff_o[4*j+3 + i*(N/NOF_BUTTERFLY_UNITS)]),.errors(errors)); 
                  end 
                  @(negedge clk_i);
              end
            end
              if (k==0) begin
                  cc_end_latency = cc;
              end
          end
          errors_total = errors_total + errors;
          @(negedge clk_i);
          $fdisplay(logfile, "Simulation of %s completed with %d errors",uut_name,errors_total);
          //$display("Simulation of %s completed with %d errors",uut_name,errors_total);
          $display("Latency for 100 Operations: %d CCs",cc_end-cc_start);
          $fdisplay(logfile, "Latency for 1 Operation: %d CCs",cc_end_latency-cc_start_latency);
          $fdisplay(logfile, "Latency for 100 Operations: %d CCs",cc_end-cc_start);
          $fdisplay(logfile, "Average Latency for 100 Operations: %d CCs",(cc_end-cc_start)/100);
          $fclose(logfile);

          $fdisplay(texfile, "\\DefineVar{%s-dit-%0d-lat}{%0d}",TEST_NAME,NOF_BUTTERFLY_UNITS,cc_end_latency-cc_start_latency);
          $fdisplay(texfile, "\\DefineVar{%s-dit-%0d-lat100}{%0d}",TEST_NAME,NOF_BUTTERFLY_UNITS,(cc_end-cc_start));
          $fdisplay(texfile, "\\DefineVar{%s-dit-%0d-latavg100}{%0d}",TEST_NAME,NOF_BUTTERFLY_UNITS,(cc_end-cc_start)/100);

          $fclose(texfile);
        end

        begin : f_cc_end
          @(negedge clk_i);
          wait ((data_valid_i == 1'b1) && (clk_i ==1'b0));
          
          @(posedge clk_i);
          wait ((data_valid_i == 0'b0) && (clk_i ==1'b0));
          cc_end = cc;
        end
        join
      join_any
    endtask

    task measure_latency_dif (ntt_t testcase [nof_runs-1:0]);

      //intt_o = 1'b1;

      // CC counter
      longint cc;

      // Latency of 100 Operations
      longint cc_start;
      longint cc_end;

      // Latency of 1 Operation
      longint cc_start_latency;
      longint cc_end_latency;

      // logfiles
      integer logfile;  
      integer texfile; 

      int errors;

      intt_o = 1'b1;
      fork

        begin : f_cc_cnt
          cc = 0;
          while(1) begin
              @(posedge clk_i) ;
              cc = cc + 1;
          end
        end
        fork

        begin : f_stimulate

          @(negedge clk_i);
          cc_start_latency = cc;
          cc_start = cc;
          for (int k=0; k<nof_runs; ++k) begin
            if (NOF_BUTTERFLY_UNITS == 2 || NOF_BUTTERFLY_UNITS == 8 || NOF_BUTTERFLY_UNITS == 32 ) begin
              for (int n=0; n<NTTS_PER_NTT; ++n) begin
                  for (int j=0; j<((N/4)/NOF_BUTTERFLY_UNITS)/NTTS_PER_NTT; ++j) begin
                      // Iterate through all Butterfly Units
                      for (int i=0; i<NOF_BUTTERFLY_UNITS/BFU_PER_GROUP; ++i) begin
                          for (int l=0; l<BFU_PER_GROUP; ++l) begin
                              data0_o[BFU_PER_GROUP*i+l] = testcase[k].coeff_i[4*j + i*STRIDE_BETWEEN_BFUGROUP + l*STRIDE_BETWEEN_BFUS_IN_GROUP + n*STRIDE_BETWEEN_NTT_IN_BFU];
                              data1_o[BFU_PER_GROUP*i+l] = testcase[k].coeff_i[4*j+1 + i*STRIDE_BETWEEN_BFUGROUP + l*STRIDE_BETWEEN_BFUS_IN_GROUP + n*STRIDE_BETWEEN_NTT_IN_BFU];
                              data2_o[BFU_PER_GROUP*i+l] = testcase[k].coeff_i[4*j+2 + i*STRIDE_BETWEEN_BFUGROUP + l*STRIDE_BETWEEN_BFUS_IN_GROUP + n*STRIDE_BETWEEN_NTT_IN_BFU];
                              data3_o[BFU_PER_GROUP*i+l] = testcase[k].coeff_i[4*j+3 + i*STRIDE_BETWEEN_BFUGROUP + l*STRIDE_BETWEEN_BFUS_IN_GROUP + n*STRIDE_BETWEEN_NTT_IN_BFU];                    
                          
                          end
                      end
                      data_valid_o = '1;
                      @(negedge clk_i);
                  end
              end
            end else begin
            for (int j=0; j<(N/4)/NOF_BUTTERFLY_UNITS; ++j) begin
                for (int i=0; i<NOF_BUTTERFLY_UNITS; ++i) begin
                    data0_o[i] = testcase[k].coeff_i[4*j + i*(N/NOF_BUTTERFLY_UNITS)];
                    data1_o[i] = testcase[k].coeff_i[4*j+1 + i*(N/NOF_BUTTERFLY_UNITS)];
                    data2_o[i] = testcase[k].coeff_i[4*j+2 + i*(N/NOF_BUTTERFLY_UNITS)];
                    data3_o[i] = testcase[k].coeff_i[4*j+3 + i*(N/NOF_BUTTERFLY_UNITS)];                    
                end
                data_valid_o = '1;
                @(negedge clk_i);
            end
            end

          end
          data_valid_o = '0;
        end

        begin : f_measure_and_verify
          // Reset error count
          
          errors = 0;
          logfile = $fopen({LOG_FILE},"a");
          texfile = $fopen({TEX_FILE},"a");
          for (int k=0; k<nof_runs; ++k) begin
              for (int j=0; j<(N/4)/NOF_BUTTERFLY_UNITS; ++j) begin
                  wait ((data_valid_i == 1'b1) && (clk_i ==1'b0));
                  for (int i=0; i<NOF_BUTTERFLY_UNITS; ++i) begin
                      verify_output(.simulated_value(data0_i[i]) ,.expected_value(testcase[k].coeff_o[j+(i*N/(4*NOF_BUTTERFLY_UNITS))]),.errors(errors));
                      verify_output(.simulated_value(data1_i[i]) ,.expected_value(testcase[k].coeff_o[N/4+j+(i*N/(4*NOF_BUTTERFLY_UNITS))]),.errors(errors)); 
                      verify_output(.simulated_value(data2_i[i]) ,.expected_value(testcase[k].coeff_o[N/2+j+(i*N/(4*NOF_BUTTERFLY_UNITS))]),.errors(errors));
                      verify_output(.simulated_value(data3_i[i]) ,.expected_value(testcase[k].coeff_o[N/2+N/4+j+(i*N/(4*NOF_BUTTERFLY_UNITS))]),.errors(errors)); 
                  end 
                  @(negedge clk_i);
              end
              if (k==0) begin
                  cc_end_latency = cc;
              end
            end
          errors_total = errors_total + errors;
          @(negedge clk_i);
          $fdisplay(logfile, "Simulation of %s completed with %d errors",uut_name,errors_total);
          //$display("Simulation of %s completed with %d errors",uut_name,errors_total);
          $display("Latency for 100 Operations: %d CCs",cc_end-cc_start);
          $fdisplay(logfile, "Latency for 1 Operation: %d CCs",cc_end_latency-cc_start_latency);
          $fdisplay(logfile, "Latency for 100 Operations: %d CCs",cc_end-cc_start);
          $fdisplay(logfile, "Average Latency for 100 Operations: %d CCs",(cc_end-cc_start)/100);
          $fclose(logfile);

          $fdisplay(texfile, "\\DefineVar{%s-dif-%0d-lat}{%0d}",TEST_NAME,NOF_BUTTERFLY_UNITS,cc_end_latency-cc_start_latency);
          $fdisplay(texfile, "\\DefineVar{%s-dif-%0d-lat100}{%0d}",TEST_NAME,NOF_BUTTERFLY_UNITS,(cc_end-cc_start));
          $fdisplay(texfile, "\\DefineVar{%s-dif-%0d-latavg100}{%0d}",TEST_NAME,NOF_BUTTERFLY_UNITS,(cc_end-cc_start)/100);

          $fclose(texfile);
        end

        begin : f_cc_end
          @(negedge clk_i);
          wait ((data_valid_i == 1'b1) && (clk_i ==1'b0));
          
          @(posedge clk_i);
          wait ((data_valid_i == 0'b0) && (clk_i ==1'b0));
          cc_end = cc;
        end
        join
      join_any
    endtask

    ntt_t testcase_ntt [nof_runs-1:0];
    ntt_t testcase_intt [nof_runs-1:0];

    integer logfile;  
    integer texfile; 

    // Test Procedure
    initial begin
        // Reset chip inputs
        data_valid_o = 0;
        intt_o = 1'b0;
        errors_total = 0;

        // overwrite old tex and log file
        logfile = $fopen({LOG_FILE},"w+");
        texfile = $fopen({TEX_FILE},"w+");
        $fclose(logfile);
        $fclose(texfile);

        for (int i = 0; i<15;i++)
            @(posedge clk_i);

        for (int i = 0; i<nof_runs;i++) begin
            testcase_ntt[i] = read_testvector(TESTCASE_PATH, $sformatf("ntt_%s_%0d",TEST_NAME,i));
            testcase_intt[i] = read_testvector(TESTCASE_PATH, $sformatf("intt_%s_%0d",TEST_NAME,i));
        end
        if (BUTTERFLY_TYPE == "CT") begin
          measure_latency_dit(testcase_ntt);
        end else if (BUTTERFLY_TYPE == "GS") begin
          measure_latency_dif(testcase_intt);
        end else if (BUTTERFLY_TYPE == "UNI")begin
          measure_latency_dit(testcase_ntt);
          measure_latency_dif(testcase_intt);
        end
        $display("Simulation of %s completed with %d errors",uut_name,errors_total);

        $stop;
    end




endmodule