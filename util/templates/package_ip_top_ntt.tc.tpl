<%!
import numpy as np

def low32(x):
    return int(np.int32(int(x) & np.uint64(0xFFFFFFFF)))

def high32(x):
    return int(np.int32((int(x) >> np.uint64(32)) & np.uint64(0xFFFFFFFF)))

def qdash(q, dw):
    # (-q)^(-1) mod 2^dw (Montgomery)
    return pow(-int(q), -1, 1 << int(dw))

def barrett_k(dw):
    return 2 * int(dw)

def barrett_mu(q, dw):
    # floor(2^(2*dw) / q)
    return (1 << barrett_k(dw)) // int(q)

def return_twiddle1_opt(n,pes):
    if n == 4096:
          return 0
    elif n == 16384:
        return 0
    else:
        return 0

def return_twiddle2_opt(n,pes):
    if n == 4096:
        if((pes == 1) or (pes == 2) or (pes == 4) or (pes == 8) or (pes == 16) or (pes == 32)):
          return 1
        else:
          return 0
    elif n == 16384:
        return 1
    else:
        return 0
%>

# Auto-generated IP packaging script for NTT core

# Requires variables from set_parameters.tcl:

#   parameterset = "<q>_<n>_<mode>"  (e.g., "33550337_1024_dit")

#   platform     = "u55c" | "u200" | "u250"

#   projectpath  = absolute project root

#   nbufs        = number of butterfly units (PEs)

# Sanity checks (Tcl variable names given as literal identifiers, not $)

if {![info exists parameterset]} { puts "Error: 'parameterset' not set."; exit 1 }
if {![info exists platform]}     { puts "Error: 'platform' not set.";     exit 1 }
if {![info exists projectpath]}  { puts "Error: 'projectpath' not set.";  exit 1 }
if {![info exists nbufs]}        { puts "Error: 'nbufs' not set.";        exit 1 }

# Platform-specific AXI widths

switch ${'$platform'} {
    u55c -
    u200 -
    u250 {
        set v_c_m_axi_addr_width 64
        set v_c_m_axi_data_width 512
        set v_c_s_axi_control_data_width 32
        set v_c_s_axi_control_addr_width 8
    }
    default {
        puts "Error: Invalid platform '${'$platform'}'. Use u55c, u200, or u250."
        exit 1
    }
}

# Base parameters derived from core template (static at generation time)

set v_q          ${low32(ntt.q)}
set v_q64        ${high32(ntt.q)}
set v_n          ${int(ntt.n)}
set v_data_width ${int(ntt.dw)}
set v_logr       ${int(ntt.dw)}
set v_q_dash     ${low32(qdash(ntt.q, ntt.dw))}
set v_q_dash64   ${high32(qdash(ntt.q, ntt.dw))}
set v_w4         ${low32(ntt.w4)}
set v_w464       ${high32(ntt.w4)}
set v_k          ${barrett_k(ntt.dw)}

# Optional QMU and QMU_64 (for future use)
set v_q_mu       0
set v_q_mu64     0

# Delays independent of mode (mode-dependent DELAY_BF set below)

set v_delay_mul        ${int(ntt.delay_mult + ntt.delay_red)}
set v_delay_const_mul  ${int(ntt.delay_const_mult + ntt.delay_red)}

# Resource/algorithm choices

set v_red "SPARSE"

# Effective number of PEs comes from CLI 'nbufs'

set v_nof_pes ${'$nbufs'}

# Twiddle memory path (override with runtime PEs)

set v_twiddle_path "${'$projectpath'}/${ntt.mem_output_path}/${ntt.q}_${ntt.n}_${'$v_nof_pes'}"

# Mode-specific settings via switch on parameterset

switch ${'$parameterset'} {
    ${ntt.q}_${ntt.n}_dit {
        puts "Parameterset ${ntt.q}_${ntt.n}_dit selected"
        set v_bf_type "CT"
        set v_delay_bf [expr {${int(ntt.delay_bf)} - 1}]
        set v_twiddle1_opt 0
        set v_twiddle2_opt 0
        # Short kernel name
        set v_kernel_name "ntt_${ntt.n}_dit_${'$v_nof_pes'}"
    }
    ${ntt.q}_${ntt.n}_dif {
        puts "Parameterset ${ntt.q}_${ntt.n}_dif selected"
        set v_bf_type "GS"
        set v_delay_bf ${int(ntt.delay_bf)}
        set v_twiddle1_opt 0
        set v_twiddle2_opt 0
        set v_kernel_name "ntt_${ntt.n}_dif_${'$v_nof_pes'}"
    }
    ${ntt.q}_${ntt.n}_uni {
        puts "Parameterset ${ntt.q}_${ntt.n}_uni selected"
        set v_bf_type "UNI"
        set v_delay_bf ${int(ntt.delay_bf)}
        set v_twiddle1_opt 0
        set v_twiddle2_opt 0
        set v_kernel_name "ntt_${ntt.n}_uni_${'$v_nof_pes'}"
    }
    ${ntt.q}_${ntt.n}_uni_opt {
        puts "Parameterset ${ntt.q}_${ntt.n}_uni_opt selected"
        set v_bf_type "UNI"
        set v_delay_bf ${int(ntt.delay_bf)}
        set v_twiddle1_opt ${return_twiddle1_opt(ntt.n, ntt.pes)}
        set v_twiddle2_opt ${return_twiddle2_opt(ntt.n, ntt.pes)}
        set v_kernel_name "ntt_${ntt.n}_uni_opt_${'$v_nof_pes'}"
    }
    default {
        puts "Error: Invalid parameterset '${'$parameterset'}' for q=${ntt.q}, n=${ntt.n}."
        exit 1
    }
}

# Start IP-Packager

ipx::package_project -root_dir ${'$projectpath'}/synth/ip_repo -vendor user.org -library user -taxonomy /UserIP -import_files -force
set_property vendor_display_name {Fraunhofer AISEC} [ipx::current_core]
set_property company_url https://aisec.fraunhofer.de [ipx::current_core]
set_property version 0.1 [ipx::current_core]

# Compatibility

set_property sdx_kernel true [ipx::current_core]
set_property sdx_kernel_type rtl [ipx::current_core]
set_property ipi_drc {ignore_freq_hz true} [ipx::current_core]
set_property vitis_drc {ctrl_protocol ap_ctrl_chain} [ipx::current_core]

# Ports and Interfaces

ipx::associate_bus_interfaces -busif coeff0_m_axi -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif coeff1_m_axi -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif coeff2_m_axi -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif coeff3_m_axi -clock ap_clk [ipx::current_core]
ipx::associate_bus_interfaces -busif s_axi_control -clock ap_clk [ipx::current_core]

# Addressing and Memory

ipx::add_register CTRL    [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]
set_property address_offset 0x00 [ipx::get_registers CTRL -of_objects    [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property size           32    [ipx::get_registers CTRL -of_objects    [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]

ipx::add_register VERSION [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]
set_property address_offset 0x10 [ipx::get_registers VERSION -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property size           32   [ipx::get_registers VERSION -of_objects [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]

ipx::add_register CFG     [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]
set_property address_offset 0x14 [ipx::get_registers CFG -of_objects     [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property size           32   [ipx::get_registers CFG -of_objects     [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]

ipx::add_register BATCH   [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]
set_property address_offset 0x18 [ipx::get_registers BATCH -of_objects   [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]
set_property size           32   [ipx::get_registers BATCH -of_objects   [ipx::get_address_blocks reg0 -of_objects [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]]]

set mm [ipx::get_memory_maps s_axi_control -of_objects [ipx::current_core]]
set ab [ipx::get_address_blocks reg0 -of_objects $mm]

set base_offset 0x20
set step_bytes 8  ;# 64-bit increments

set idx 0
foreach {regname busif} {COEFF0 coeff0_m_axi COEFF1 coeff1_m_axi COEFF2 coeff2_m_axi COEFF3 coeff3_m_axi} {
  ipx::add_register $regname $ab

  set offset_val [expr {$base_offset + $idx * $step_bytes}]
  set offset_hex [format 0x%X $offset_val]
  set_property address_offset $offset_hex [ipx::get_registers $regname -of_objects $ab]
  set_property size           64        [ipx::get_registers $regname -of_objects $ab]  ;# 64 bits

  ipx::add_register_parameter ASSOCIATED_BUSIF [ipx::get_registers $regname -of_objects $ab]
  set_property value $busif [ipx::get_register_parameters ASSOCIATED_BUSIF -of_objects [ipx::get_registers $regname -of_objects $ab]]

  incr idx
}

# Parameterize

set_property widget {textEdit} [ipgui::get_guiparamspec -name "DATA_WIDTH" -component [ipx::current_core]]
set_property value $v_data_width [ipx::get_user_parameters DATA_WIDTH -of_objects [ipx::current_core]]
set_property value $v_data_width [ipx::get_hdl_parameters  DATA_WIDTH -of_objects [ipx::current_core]]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "N" -component [ipx::current_core]]
set_property value $v_n [ipx::get_user_parameters N -of_objects [ipx::current_core]]
set_property value $v_n [ipx::get_hdl_parameters  N -of_objects [ipx::current_core]]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "C_S_AXI_CONTROL_DATA_WIDTH" -component [ipx::current_core]]
set_property value $v_c_s_axi_control_data_width [ipx::get_user_parameters C_S_AXI_CONTROL_DATA_WIDTH -of_objects [ipx::current_core]]
set_property value $v_c_s_axi_control_data_width [ipx::get_hdl_parameters  C_S_AXI_CONTROL_DATA_WIDTH -of_objects [ipx::current_core]]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "C_S_AXI_CONTROL_ADDR_WIDTH" -component [ipx::current_core]]
set_property value $v_c_s_axi_control_addr_width [ipx::get_user_parameters C_S_AXI_CONTROL_ADDR_WIDTH -of_objects [ipx::current_core]]
set_property value $v_c_s_axi_control_addr_width [ipx::get_hdl_parameters  C_S_AXI_CONTROL_ADDR_WIDTH -of_objects [ipx::current_core]]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "C_M_AXI_DATA_WIDTH" -component [ipx::current_core]]
set_property value $v_c_m_axi_data_width [ipx::get_user_parameters C_M_AXI_DATA_WIDTH -of_objects [ipx::current_core]]
set_property value $v_c_m_axi_data_width [ipx::get_hdl_parameters  C_M_AXI_DATA_WIDTH -of_objects [ipx::current_core]]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "C_M_AXI_ADDR_WIDTH" -component [ipx::current_core]]
set_property value $v_c_m_axi_addr_width [ipx::get_user_parameters C_M_AXI_ADDR_WIDTH -of_objects [ipx::current_core]]
set_property value $v_c_m_axi_addr_width [ipx::get_hdl_parameters  C_M_AXI_ADDR_WIDTH -of_objects [ipx::current_core]]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "LOG_R" -component [ipx::current_core]]
set_property value $v_logr [ipx::get_user_parameters LOG_R -of_objects [ipx::current_core]]
set_property value $v_logr [ipx::get_hdl_parameters  LOG_R -of_objects [ipx::current_core]]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "REDUCTION" -component [ipx::current_core]]
set_property value $v_red [ipx::get_user_parameters REDUCTION -of_objects [ipx::current_core]]
set_property value $v_red [ipx::get_hdl_parameters  REDUCTION -of_objects [ipx::current_core]]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "TWIDDLE_MEM_PATH" -component [ipx::current_core]]
set_property value $v_twiddle_path [ipx::get_user_parameters TWIDDLE_MEM_PATH -of_objects [ipx::current_core]]
set_property value $v_twiddle_path [ipx::get_hdl_parameters  TWIDDLE_MEM_PATH -of_objects [ipx::current_core]]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "NOF_BUTTERFLY_UNITS" -component [ipx::current_core]]
set_property value $v_nof_pes [ipx::get_user_parameters NOF_BUTTERFLY_UNITS -of_objects [ipx::current_core]]
set_property value $v_nof_pes [ipx::get_hdl_parameters  NOF_BUTTERFLY_UNITS -of_objects [ipx::current_core]]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "QINT" -component [ipx::current_core]]
set_property value $v_q [ipx::get_user_parameters QINT -of_objects [ipx::current_core]]
set_property value $v_q [ipx::get_hdl_parameters  QINT -of_objects [ipx::current_core]]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "QINT_64" -component [ipx::current_core]]
set_property value $v_q64 [ipx::get_user_parameters QINT_64 -of_objects [ipx::current_core]]
set_property value $v_q64 [ipx::get_hdl_parameters  QINT_64 -of_objects [ipx::current_core]]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "QMU" -component [ipx::current_core]]
set_property value $v_q_mu [ipx::get_user_parameters QMU -of_objects [ipx::current_core]]
set_property value $v_q_mu [ipx::get_hdl_parameters  QMU -of_objects [ipx::current_core]]

# Optional QMU_64 (only if parameter exists)

catch {
  set_property widget {textEdit} [ipgui::get_guiparamspec -name "QMU_64" -component [ipx::current_core]]
  set_property value $v_q_mu64 [ipx::get_user_parameters QMU_64 -of_objects [ipx::current_core]]
  set_property value $v_q_mu64 [ipx::get_hdl_parameters  QMU_64 -of_objects [ipx::current_core]]
}

set_property widget {textEdit} [ipgui::get_guiparamspec -name "QDASH" -component [ipx::current_core]]
set_property value $v_q_dash [ipx::get_user_parameters QDASH -of_objects [ipx::current_core]]
set_property value $v_q_dash [ipx::get_hdl_parameters  QDASH -of_objects [ipx::current_core]]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "QDASH_64" -component [ipx::current_core]]
set_property value $v_q_dash64 [ipx::get_user_parameters QDASH_64 -of_objects [ipx::current_core]]
set_property value $v_q_dash64 [ipx::get_hdl_parameters  QDASH_64 -of_objects [ipx::current_core]]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "W4" -component [ipx::current_core]]
set_property value $v_w4 [ipx::get_user_parameters W4 -of_objects [ipx::current_core]]
set_property value $v_w4 [ipx::get_hdl_parameters  W4 -of_objects [ipx::current_core]]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "W4_64" -component [ipx::current_core]]
set_property value $v_w464 [ipx::get_user_parameters W4_64 -of_objects [ipx::current_core]]
set_property value $v_w464 [ipx::get_hdl_parameters  W4_64 -of_objects [ipx::current_core]]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "K" -component [ipx::current_core]]
set_property value $v_k [ipx::get_user_parameters K -of_objects [ipx::current_core]]
set_property value $v_k [ipx::get_hdl_parameters  K -of_objects [ipx::current_core]]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "DELAY_BF" -component [ipx::current_core]]
set_property value $v_delay_bf [ipx::get_user_parameters DELAY_BF -of_objects [ipx::current_core]]
set_property value $v_delay_bf [ipx::get_hdl_parameters  DELAY_BF -of_objects [ipx::current_core]]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "DELAY_MULT" -component [ipx::current_core]]
set_property value $v_delay_mul [ipx::get_user_parameters DELAY_MULT -of_objects [ipx::current_core]]
set_property value $v_delay_mul [ipx::get_hdl_parameters  DELAY_MULT -of_objects [ipx::current_core]]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "DELAY_CONST_MULT" -component [ipx::current_core]]
set_property value $v_delay_const_mul [ipx::get_user_parameters DELAY_CONST_MULT -of_objects [ipx::current_core]]
set_property value $v_delay_const_mul [ipx::get_hdl_parameters  DELAY_CONST_MULT -of_objects [ipx::current_core]]

set_property widget {textEdit} [ipgui::get_guiparamspec -name "BUTTERFLY_TYPE" -component [ipx::current_core]]
set_property value $v_bf_type [ipx::get_user_parameters BUTTERFLY_TYPE -of_objects [ipx::current_core]]
set_property value $v_bf_type [ipx::get_hdl_parameters  BUTTERFLY_TYPE -of_objects [ipx::current_core]]

# Optional twiddle opts (present only in UNI_OPT cores)

catch {
  set_property widget {textEdit} [ipgui::get_guiparamspec -name "TWIDDLE1_OPT" -component [ipx::current_core]]
  set_property value $v_twiddle1_opt [ipx::get_user_parameters TWIDDLE1_OPT -of_objects [ipx::current_core]]
  set_property value $v_twiddle1_opt [ipx::get_hdl_parameters  TWIDDLE1_OPT -of_objects [ipx::current_core]]
}
catch {
  set_property widget {textEdit} [ipgui::get_guiparamspec -name "TWIDDLE2_OPT" -component [ipx::current_core]]
  set_property value $v_twiddle2_opt [ipx::get_user_parameters TWIDDLE2_OPT -of_objects [ipx::current_core]]
  set_property value $v_twiddle2_opt [ipx::get_hdl_parameters  TWIDDLE2_OPT -of_objects [ipx::current_core]]
}

# Package

ipx::add_bus_parameter FREQ_TOLERANCE_HZ [ipx::get_bus_interfaces ap_clk -of_objects [ipx::current_core]]
set_property value -1 [ipx::get_bus_parameters FREQ_TOLERANCE_HZ -of_objects [ipx::get_bus_interfaces ap_clk -of_objects [ipx::current_core]]]

set_property core_revision 2 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::check_integrity -kernel -xrt [ipx::current_core]
ipx::save_core [ipx::current_core]

# Package XO (ensure Tcl variables are emitted via ${'$...'} to avoid Mako expansion)

package_xo -xo_path ${'$projectpath'}/synth/xo/top_ntt_${'${parameterset}'}_${'${platform}'}_${'$v_nof_pes'}.xo \
           -kernel_name ${'$v_kernel_name'} \
           -ip_directory ${'$projectpath'}/synth/ip_repo \
           -ctrl_protocol ap_ctrl_chain

set_property ip_repo_paths ${'$projectpath'}/synth/ip_repo [current_project]
ipx::check_integrity -quiet -kernel -xrt [ipx::current_core]