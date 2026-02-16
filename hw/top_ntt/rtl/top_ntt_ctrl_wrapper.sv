`resetall
`timescale 1ns/10ps

/**************************************************************************************************/
// Toplevel for Alveo U55C FPGA
/**************************************************************************************************/

module top_ntt_ctrl_wrapper #(

    // Parameterset specific
    parameter int unsigned N = 1024,
    // Number of parallel processing elements in accelerator
    parameter int NOF_BUTTERFLY_UNITS = 8,
    parameter int unsigned PIPELINE_LENGTH = 16
)
(
    // System Signals
    input   logic                                   clk_i,
    input   logic                                   rst_i,

    input   logic                                   start_i,
    output  logic                                   ready_o,
    output  logic                                   done_o,
    output  logic                                   idle_o,
    output  logic                                   start_pulse_o,
    input   logic                                   ntt_batch_size_i,
    input   logic                                   cnt_en_acc2mem_i,
    input   logic                                   cnt_en_mem2acc_i,
    input   logic                                   sync_buf2acc_done_i,
    input   logic                                   sync_acc2buf_done_i,
    output  logic                                   cnt_fifo_en_o,
    output  logic                                   read_coeff_done_o
);

    /**************************************************************************************************/
    // Counters to track which polynomial within the current batch has been finished
    /**************************************************************************************************/
    logic [$clog2(PIPELINE_LENGTH)-1:0] cnt_batch_idx;
    logic [$clog2(N/(4*NOF_BUTTERFLY_UNITS))-1:0] cnt_coeff_idx;

    logic [$clog2(PIPELINE_LENGTH)-1:0] cnt_batch_idx_started;
    logic [$clog2(N/(4*NOF_BUTTERFLY_UNITS))-1:0] cnt_coeff_idx_started;

    logic [$clog2(N)-1:0] cnt_coeff_read;
    logic [$clog2(N)+PIPELINE_LENGTH:0] cnt_fifo_acc_read;
    logic read_coeff_done;
    logic cnt_fifo_en;   
    logic ap_start_r, ap_idle_r, ap_start_pulse, ap_done_i, ap_done_r;
    logic user_idle, user_done, user_ready, user_start;
    logic start_pulse_d, start_pulse_q;
    assign idle_o = user_idle;
    assign done_o = user_done;
    assign ready_o =  user_ready;
    assign user_start = start_i;

    // create pulse when user_start transitions to 1
    always @(posedge clk_i) begin
        if (rst_i) begin
            ap_start_r <= 1'b0;
            start_pulse_q <= 1'b0;
        end else begin
            ap_start_r <= start_i;
            start_pulse_q <= start_pulse_d;
        end
    end
    assign ap_start_pulse = start_i & ~ap_start_r;
    assign start_pulse_d = ap_start_pulse;
    assign start_pulse_o = start_pulse_q;

    // user_idle is asserted when done is asserted, it is de-asserted when ap_start_pulse
    // is asserted
    always @(posedge clk_i) begin
        if (rst_i) begin
            ap_idle_r <= 1'b1;
        end
        else begin
            ap_idle_r <= user_done ? 1'b1 :
                ap_start_pulse ? 1'b0 : user_idle;
        end
    end

    assign user_idle = ap_idle_r;

    // Done logic
    always @(posedge clk_i) begin
        if (rst_i) begin
            ap_done_r <= '0;
        end
        else begin
            ap_done_r <= (ap_start_pulse | user_done) ? '0 : ap_done_r | sync_acc2buf_done_i;
        end
    end

    assign user_done = &ap_done_r;
    assign user_ready = user_done;

    // Counter to track coefficients in current ciphertext
    always_ff @(posedge  clk_i) begin
        if (rst_i) begin
            cnt_coeff_idx <= '0;
        end else if (cnt_en_acc2mem_i) begin
            if (cnt_coeff_idx == (N/(4*NOF_BUTTERFLY_UNITS)-1)) begin
                cnt_coeff_idx <= '0;
            end else begin
                cnt_coeff_idx <= cnt_coeff_idx + 1;
            end
        end else if (start_pulse_q) begin
            cnt_coeff_idx <= '0;
        end
    end

    // Counter to track ciphertext in current batch
    always_ff @(posedge  clk_i) begin
        if (rst_i) begin
            cnt_batch_idx <= '0;
        end else if (cnt_coeff_idx == (N/(4*NOF_BUTTERFLY_UNITS)-1)) begin
            if (cnt_batch_idx == (PIPELINE_LENGTH-1)) begin
                cnt_batch_idx <= '0;
            end else begin
                cnt_batch_idx <= cnt_batch_idx + 1;
            end
        end else if (start_pulse_q) begin
            cnt_batch_idx <= '0;
        end
    end

    // Counter to track coefficients in current ciphertext
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            cnt_coeff_idx_started <= '0;
        end else if (cnt_en_mem2acc_i) begin
            if (cnt_coeff_idx_started == (N/(4*NOF_BUTTERFLY_UNITS)-1)) begin
                cnt_coeff_idx_started <= '0;
            end else begin
                cnt_coeff_idx_started <= cnt_coeff_idx_started + 1;
            end
        end else if (start_pulse_q) begin
            cnt_coeff_idx_started <= '0;
        end
    end

    // Counters to track ciphertext in current batch and count idle iterations for BSKs 
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            cnt_batch_idx_started <= '0;
        end else if (cnt_coeff_idx_started == N/(4*NOF_BUTTERFLY_UNITS)-1) begin
            if (cnt_batch_idx_started == PIPELINE_LENGTH-1) begin
                cnt_batch_idx_started <= '0;
            end else begin
                cnt_batch_idx_started <= cnt_batch_idx_started + 1;
            end
        end else if (start_pulse_q) begin
            cnt_batch_idx_started <= '0;
        end
    end


    // Delay chain assignment
    // When ctrl_done is high, a FIFO needs to read the loaded samples first, before they are transfered to the accelerator.
    // This leads to the case that ctrl_done is set because read was successful, but FIFO is still reading samples from the previous run.

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            read_coeff_done <= 1'b0;
            cnt_coeff_read <= '0;
        end else begin
          if (start_pulse_q) begin
            read_coeff_done <= 1'b0;
          end else if (cnt_fifo_en) begin 
            if ((cnt_batch_idx_started == PIPELINE_LENGTH-1) && (cnt_coeff_idx_started == (N/(4*NOF_BUTTERFLY_UNITS))-1)) begin
              read_coeff_done <= 1'b1;
              cnt_coeff_read <= 1'b0;
            end else if (!read_coeff_done) begin
                if (cnt_coeff_read == (N/(4*NOF_BUTTERFLY_UNITS))-1) begin
                    cnt_coeff_read <= '0;
                end else if (cnt_coeff_read == 0) begin
                    cnt_coeff_read <= cnt_coeff_read + 1;
                end else begin
                    cnt_coeff_read <= cnt_coeff_read + 1;
                end
            end
          end
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            cnt_fifo_acc_read <= '0;
            cnt_fifo_en <= '0;
        end else begin
            if (sync_buf2acc_done_i) begin
                cnt_fifo_en <= 1'b1;
                cnt_fifo_acc_read <= (PIPELINE_LENGTH*N/(4*NOF_BUTTERFLY_UNITS))-1;
            end else if (cnt_fifo_acc_read == 0) begin
                cnt_fifo_en <= 1'b0;
                cnt_fifo_acc_read <= '0;
            end else if (cnt_fifo_en) begin
                cnt_fifo_acc_read <= cnt_fifo_acc_read -1;
            end
        end
    end

    assign cnt_fifo_en_o = cnt_fifo_en;
    assign read_coeff_done_o = read_coeff_done;

endmodule