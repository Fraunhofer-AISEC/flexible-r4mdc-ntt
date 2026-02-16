CAPI=2:
name: "aisec:fpga:top_ntt_u55c_${ntt.q}_${ntt.n}_${ntt.pes}:0.1"
description: "R4MDC NTT FPGA Design"

<%! import numpy as np 

def low32(x):
    return int(np.int32(int(x) & np.uint64(0xFFFFFFFF)))

def high32(x):
    return int(np.int32((x >> np.uint64(32)) & np.uint64(0xFFFFFFFF)))

def inv_mod_2dw(q, dw):
    return pow(-int(q), -1, 1 << int(dw))  # modular inverse of -q mod 2^dw

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

filesets:
  files_rtl:
    depend:
      - aisec:fpga:top_ntt_u55c:0.1

parameters:

  TWIDDLE_MEM_PATH:
    datatype: str
    description: Twiddle ROM initialization file in vmem hex format
    default: "../../../${ntt.mem_output_path}/${ntt.q}_${ntt.n}_${ntt.pes}"
    paramtype: vlogparam

  NOF_BUTTERFLY_UNITS:
    datatype: int
    description: Number of parallel processing elements
    default: 1
    paramtype: vlogparam

  DATA_WIDTH:
    datatype: int
    description: Width of data path
    default: 27
    paramtype: vlogparam

  N:
    datatype: int
    description: Polynomial degree
    default: 1024
    paramtype: vlogparam

  QINT:
    datatype: int
    description: Lower 32 bits of Modulus
    default: 134215681
    paramtype: vlogparam

  QINT_64:
    datatype: int
    description: Upper 32 bits of Modulus
    default: 0
    paramtype: vlogparam

  QDASH:
    datatype: int
    description: Lower 32 bits of constant for montgomery multiplication
    default: 130021375
    paramtype: vlogparam

  QDASH_64:
    datatype: int
    description: Upper 32 bits of constant for montgomery multiplication
    default: 0
    paramtype: vlogparam

  W4:
    datatype: int
    description: Lower 32 bits of 4th root of unity
    default: 37361560
    paramtype: vlogparam

  W4_64:
    datatype: int
    description: Upper 32 bits of 4th root of unity
    default: 0
    paramtype: vlogparam

  LOG_R:
    datatype: int
    description: Constant for montgomery multiplication
    default: 27
    paramtype: vlogparam

  QMU:
    datatype: int
    description: Constant for barrett multiplication
    default: 134219775
    paramtype: vlogparam

  K:
    datatype: int
    description: Constant for barrett multiplication
    default: 54
    paramtype: vlogparam

  TWIDDLE1_OPT:
    datatype: int
    description: Enable optimization for goldilock prime
    default: 0
    paramtype: vlogparam

  TWIDDLE2_OPT:
    datatype: int
    description: Enable optimization for goldilock prime
    default: 0
    paramtype: vlogparam

  REDUCTION:
    datatype: str
    description: Reduction method for multply operations
    default: "SPARSE"
    paramtype: vlogparam

  DELAY_BF:
    datatype: int
    description: Latency of butterfly unit implementation
    default: 11
    paramtype: vlogparam

  DELAY_MULT:
    datatype: int
    description: Latency of multiplier implementation
    default: 5
    paramtype: vlogparam

  DELAY_CONST_MULT:
    datatype: int
    description: Latency of multiplier implementation
    default: 5
    paramtype: vlogparam

  BUTTERFLY_TYPE:
    datatype: str
    description: File location for log file
    default: "CT"
    paramtype: vlogparam

  BUTTERFLY_TYPE:
    datatype: str
    description: Butterfly type
% if mode == "dit":
    default: "CT"
% else:
    default: "GS"
% endif
    paramtype: vlogparam

targets:
  default: &default_target
    filesets:
      - files_rtl
    toplevel: top_ntt

  ${ntt.q}_${ntt.n}_dit:
    <<: *default_target
    filesets:
      - files_rtl
    parameters:
      - N=${ntt.n}
      - DATA_WIDTH=${ntt.dw}
      - QINT=${low32(ntt.q)}
      - QINT_64=${high32(ntt.q)}
      - QDASH=${low32(pow((-ntt.q), -1, int(2 ** ntt.dw)))}
      - QDASH_64=${high32(pow((-ntt.q), -1, int(2 ** ntt.dw)))}
      - W4=${low32(ntt.w4)}
      - W4_64=${high32(ntt.w4)}
      - LOG_R=${ntt.dw}
      - NOF_BUTTERFLY_UNITS=${ntt.pes}
      - REDUCTION=SPARSE
      - DELAY_BF=${ntt.delay_bf-1}
      - DELAY_MULT=${ntt.delay_mult + ntt.delay_red}
      - DELAY_CONST_MULT=${ntt.delay_const_mult + ntt.delay_red}
      - BUTTERFLY_TYPE=CT
      - TWIDDLE_MEM_PATH=../../../${ntt.mem_output_path}/${ntt.q}_${ntt.n}_${ntt.pes}
    tools:
      vivado:
        board_part: "xilinx.com:au55c:part0:1.0"

  ${ntt.q}_${ntt.n}_dif:
    <<: *default_target
    filesets:
      - files_rtl
    parameters:
      - N=${ntt.n}
      - DATA_WIDTH=${ntt.dw}
      - QINT=${low32(ntt.q)}
      - QINT_64=${high32(ntt.q)}
      - QDASH=${low32(pow((-ntt.q), -1, int(2 ** ntt.dw)))}
      - QDASH_64=${high32(pow((-ntt.q), -1, int(2 ** ntt.dw)))}
      - W4=${low32(ntt.w4)}
      - W4_64=${high32(ntt.w4)}
      - LOG_R=${ntt.dw}
      - NOF_BUTTERFLY_UNITS=${ntt.pes}
      - REDUCTION=SPARSE
      - DELAY_BF=${ntt.delay_bf}
      - DELAY_MULT=${ntt.delay_mult + ntt.delay_red}
      - DELAY_CONST_MULT=${ntt.delay_const_mult + ntt.delay_red}
      - BUTTERFLY_TYPE=GS
      - TWIDDLE_MEM_PATH=../../../${ntt.mem_output_path}/${ntt.q}_${ntt.n}_${ntt.pes}
    tools:
      vivado:
        board_part: "xilinx.com:au55c:part0:1.0"

  ${ntt.q}_${ntt.n}_uni:
    <<: *default_target
    filesets:
      - files_rtl
    parameters:
      - N=${ntt.n}
      - DATA_WIDTH=${ntt.dw}
      - QINT=${low32(ntt.q)}
      - QINT_64=${high32(ntt.q)}
      - QDASH=${low32(pow((-ntt.q), -1, int(2 ** ntt.dw)))}
      - QDASH_64=${high32(pow((-ntt.q), -1, int(2 ** ntt.dw)))}
      - W4=${low32(ntt.w4)}
      - W4_64=${high32(ntt.w4)}
      - LOG_R=${ntt.dw}
      - NOF_BUTTERFLY_UNITS=${ntt.pes}
      - REDUCTION=SPARSE
      - DELAY_BF=${ntt.delay_bf}
      - DELAY_MULT=${ntt.delay_mult + ntt.delay_red}
      - DELAY_CONST_MULT=${ntt.delay_const_mult + ntt.delay_red}
      - BUTTERFLY_TYPE=UNI
      - TWIDDLE_MEM_PATH=../../../${ntt.mem_output_path}/${ntt.q}_${ntt.n}_${ntt.pes}
    tools:
      vivado:
        board_part: "xilinx.com:au55c:part0:1.0"

  ${ntt.q}_${ntt.n}_uni_opt:
    <<: *default_target
    filesets:
      - files_rtl
    parameters:
      - N=${ntt.n}
      - DATA_WIDTH=${ntt.dw}
      - QINT=${low32(ntt.q)}
      - QINT_64=${high32(ntt.q)}
      - QDASH=${low32(pow((-ntt.q), -1, int(2 ** ntt.dw)))}
      - QDASH_64=${high32(pow((-ntt.q), -1, int(2 ** ntt.dw)))}
      - W4=${low32(ntt.w4)}
      - W4_64=${high32(ntt.w4)}
      - LOG_R=${ntt.dw}
      - NOF_BUTTERFLY_UNITS=${ntt.pes}
      - REDUCTION=SPARSE
      - TWIDDLE1_OPT=${return_twiddle1_opt(ntt.n,ntt.pes)}
      - TWIDDLE2_OPT=${return_twiddle2_opt(ntt.n,ntt.pes)}
      - DELAY_BF=${ntt.delay_bf}
      - DELAY_MULT=${ntt.delay_mult + ntt.delay_red}
      - DELAY_CONST_MULT=${ntt.delay_const_mult + ntt.delay_red}
      - BUTTERFLY_TYPE=UNI
      - TWIDDLE_MEM_PATH=../../../${ntt.mem_output_path}/${ntt.q}_${ntt.n}_${ntt.pes}
    tools:
      vivado:
        board_part: "xilinx.com:au55c:part0:1.0"

