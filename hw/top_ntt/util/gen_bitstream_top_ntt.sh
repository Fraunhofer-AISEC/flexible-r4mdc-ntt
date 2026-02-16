#!/usr/bin/env bash

# Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

DEFAULT_VIVADO_SETTINGS="${VIVADO_SETTINGS:-/tools/Xilinx/Vivado/2023.2/settings64.sh}"
DEFAULT_CORES_ROOT="${CORES_ROOT:-.}"
DEFAULT_PACKAGE_TCL_REL="${PACKAGE_TCL:-hw/top_ntt/util/package_ip_ntt.tcl}"
DEFAULT_FREQ="${FREQ:-250}"
DEFAULT_OPT="${OPT:-2}"

print_usage() {
  cat <<EOF
Usage: $0 -s <core-id> <target> <platform> [--freq F] [--opt O] [--cores-root PATH] [--vivado-settings PATH] [--package-tcl PATH] [-d|--debug]
Example:
  $0 -s "aisec:fpga:top_ntt_u55c_33550337_1024_16:0.1" 33550337_1024_dit u55c --debug
EOF
}

CORE_ID=""
TARGET=""
PLATFORM=""
FREQ="${DEFAULT_FREQ}"
OPT_OBJ="${DEFAULT_OPT}"
CORES_ROOT="${DEFAULT_CORES_ROOT}"
VIVADO_SETTINGS="${DEFAULT_VIVADO_SETTINGS}"
PACKAGE_TCL_REL="${DEFAULT_PACKAGE_TCL_REL}"
DEBUG_FLAG=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--core) CORE_ID="$2"; shift 2 ;;
    --freq) FREQ="$2"; shift 2 ;;
    --opt) OPT_OBJ="$2"; shift 2 ;;
    --cores-root) CORES_ROOT="$2"; shift 2 ;;
    --vivado-settings) VIVADO_SETTINGS="$2"; shift 2 ;;
    --package-tcl) PACKAGE_TCL_REL="$2"; shift 2 ;;
    -d|--debug) DEBUG_FLAG=1; shift ;;
    -h|--help) print_usage; exit 0 ;;
    *)
      if [[ -z "${TARGET}" ]]; then TARGET="$1"
      elif [[ -z "${PLATFORM}" ]]; then PLATFORM="$1"
      else echo "Unexpected arg: $1"; print_usage; exit 1; fi
      shift
    ;;
  esac
done

if [[ -z "${CORE_ID}" || -z "${TARGET}" || -z "${PLATFORM}" ]]; then
  echo "ERROR: Missing required arguments."
  print_usage
  exit 1
fi

case "${PLATFORM}" in
  u200|u250|u55c) ;;
  *) echo "ERROR: Invalid platform '${PLATFORM}'. Allowed: u200, u250, u55c"; exit 1 ;;
esac

sanitize_core_id() { echo "$1" | sed 's/:/_/g'; }

parse_core_fields() {
  local core_nover="${1%:*}"
  local after_top="${core_nover#*top_ntt_}"
  IFS="_" read -r core_platform q n pes <<< "${after_top}"
  echo "${core_platform}" "${q}" "${n}" "${pes}"
}

map_deployment_platform() {
  case "$1" in
    u200) echo "xilinx_u200_gen3x16_xdma_2_202110_1" ;;
    u250) echo "xilinx_u250_gen3x16_xdma_4_1_202210_1" ;;
    u55c) echo "xilinx_u55c_gen3x16_xdma_3_202210_1" ;;
    *) return 1 ;;
  esac
}

generate_tcl_script() {
  local parameterset="$1"  # e.g. "33550337_1024_dit"
  local platform="$2"
  local nbfus="$3"
  local projectpath="$4"
  cat > set_parameters.tcl <<EOT
set parameterset $parameterset
set platform $platform
set projectpath $projectpath
set nbufs $nbfus
EOT
  echo "Generated set_parameters.tcl (parameterset=$parameterset, platform=$platform, nbufs=$nbfus)"
}

resolve_package_tcl() {
  local project_root="$1"
  local package_tcl_rel="$2"
  local q="$3"
  local n="$4"
  local pes="$5"
  local default_abs="${project_root}/${package_tcl_rel}"
  local dir
  dir="$(dirname "$default_abs")"
  local autogen="${dir}/package_ip_top_ntt_${q}_${n}_${pes}.tcl"
  if [[ -f "$autogen" ]]; then
    echo "$autogen"
  else
    echo "$default_abs"
  fi
}

concat_tcl() {
  local core_tcl="$1"
  local package_tcl_abs="$2"
  cat "$core_tcl" set_parameters.tcl "$package_tcl_abs" > tmp.tcl
}

# UPDATED: use short kernel name for connectivity

link_xclbin() {
  local platform="$1"
  local deployment_platform="$2"
  local kernel_name="$3"   # short kernel name used inside XO
  local xo_base="$4"       # basename of XO/xclbin files (long name ok)
  local frq="$5"
  local opt_obj="$6"
  local projectpath="$7"
  local debug_flag="$8"

  local xo="${projectpath}/synth/xo/${xo_base}.xo"
  if [[ ! -f "$xo" ]]; then
    echo "ERROR: XO not found: $xo"
    exit 1
  fi

  if [[ "$platform" == "u55c" ]]; then
    # Optional debug args (chipscope) only when --debug is passed
    local debug_args=()
    if [[ "$debug_flag" -eq 1 ]]; then
      debug_args+=(--debug.protocol all)
      debug_args+=(--debug.chipscope "${kernel_name}_1:coeff0_m_axi")
      debug_args+=(--debug.chipscope "${kernel_name}_1:coeff1_m_axi")
      debug_args+=(--debug.chipscope "${kernel_name}_1:coeff2_m_axi")
      debug_args+=(--debug.chipscope "${kernel_name}_1:coeff3_m_axi")
    fi

    v++ -t hw --platform "$deployment_platform" --link "$xo" \
      --connectivity.sp ${kernel_name}_1.coeff0_m_axi:HBM[0] \
      --connectivity.sp ${kernel_name}_1.coeff1_m_axi:HBM[1] \
      --connectivity.sp ${kernel_name}_1.coeff2_m_axi:HBM[2] \
      --connectivity.sp ${kernel_name}_1.coeff3_m_axi:HBM[3] \
      --kernel_frequency "$frq" \
      --optimize "$opt_obj" \
      "${debug_args[@]}" \
      -o "${xo_base}.xclbin"
  else
    v++ -t hw --platform "$deployment_platform" --link "$xo" \
      --connectivity.sp ${kernel_name}_1.coeff0_m_axi:DDR[0] \
      --connectivity.sp ${kernel_name}_1.coeff1_m_axi:DDR[3] \
      --connectivity.sp ${kernel_name}_1.coeff2_m_axi:DDR[1] \
      --connectivity.sp ${kernel_name}_1.coeff3_m_axi:DDR[2] \
      --kernel_frequency "$frq" \
      --optimize "$opt_obj" \
      -o "${xo_base}.xclbin"
  fi
}

# Parse CORE_ID

read -r core_platform q n pes <<< "$(parse_core_fields "${CORE_ID}")"
if [[ -z "${core_platform:-}" || -z "${q:-}" || -z "${n:-}" || -z "${pes:-}" ]]; then
  echo "ERROR: Could not parse core ID '${CORE_ID}'."
  exit 1
fi
if [[ "${core_platform}" != "${PLATFORM}" ]]; then
  echo "ERROR: Platform mismatch: core uses '${core_platform}', arg '${PLATFORM}'."
  exit 1
fi

# parameterset must include mode suffix (e.g., 33550337_1024_dit)

parameterset="${TARGET}"

# Extract mode from parameterset safely (supports 'uni_opt')

tmp="${parameterset#*_}"; mode="${tmp#*_}"     # drop <q>_ then <n>_

# Short kernel name (keeps total length << 64)

kernel_name="ntt_${n}_${mode}_${pes}"

# XO/xclbin file base (long name ok)

xo_base="top_ntt_${parameterset}_${PLATFORM}_${pes}"

# Setup with FuseSoC

fusesoc --cores-root "${CORES_ROOT}" run --target="${TARGET}" --no-export --tool=vivado --setup "${CORE_ID}"

# Paths

sanitized_core="$(sanitize_core_id "${CORE_ID}")"
build_dir="build/${sanitized_core}/${TARGET}-vivado"
project_root="$(pwd)"
package_tcl_abs="$(resolve_package_tcl "${project_root}" "${PACKAGE_TCL_REL}" "${q}" "${n}" "${pes}")"
echo "Using packaging script: ${package_tcl_abs}"

# Clean old XO

rm -f "${project_root}/synth/xo/"*.xo || true

# Vivado batch

cd "${build_dir}"
if [[ -f "${VIVADO_SETTINGS}" ]]; then . "${VIVADO_SETTINGS}"; else echo "WARNING: Vivado settings not found at ${VIVADO_SETTINGS}"; fi

# Find the main FuseSoC-generated TCL

core_tcl=""
if [[ -f "edalize.tcl" ]]; then core_tcl="edalize.tcl"
elif [[ -f "${sanitized_core}.tcl" ]]; then core_tcl="${sanitized_core}.tcl"
else core_tcl="$(ls -1 *.tcl | head -n 1 || true)"
fi
if [[ -z "${core_tcl}" || ! -f "${core_tcl}" ]]; then
  echo "ERROR: Could not locate a TCL script in ${build_dir}"
  exit 1
fi

# Generate params and run

generate_tcl_script "${parameterset}" "${PLATFORM}" "${pes}" "${project_root}"
concat_tcl "${core_tcl}" "${package_tcl_abs}"
vivado -mode batch -source tmp.tcl

# Vitis link step (uses short kernel name)

deployment_platform="$(map_deployment_platform "${PLATFORM}")"
link_xclbin "${PLATFORM}" "${deployment_platform}" "${kernel_name}" "${xo_base}" "${FREQ}" "${OPT_OBJ}" "${project_root}" "${DEBUG_FLAG}"

cd "${project_root}"
echo "Done. Output: synth/xo/${xo_base}.xo and ${xo_base}.xclbin"