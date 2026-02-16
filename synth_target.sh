#!/bin/bash

# Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# synth_target.sh

# Setup and run FuseSoC targets and drive Vivado runs

# Defaults

SETUP="aisec:ip:ntt_r4mdc:0.1"
TOOL="vivado"

usage() {
  cat <<EOF
Usage: $0 [-s SETUP] TARGET1 [TARGET2 ...]
       $0 "targetA,targetB,..."   (single comma-separated arg accepted)
Default SETUP: ${SETUP}

Environment:
  VIVADO_SETTINGS   Optional path to Xilinx Vivado settings64.sh
                    (used when 'vivado' is not already in PATH).
                    Fallback: /tools/Xilinx/Vivado/2023.2/settings64.sh
EOF
  exit 1
}

# --- helpers ---------------------------------------------------------------

ensure_vivado() {
  if command -v vivado >/dev/null 2>&1; then
    return 0
  fi

  if [ -n "${VIVADO_SETTINGS:-}" ] && [ -f "$VIVADO_SETTINGS" ]; then
    # shellcheck source=/dev/null
    . "$VIVADO_SETTINGS"
  elif [ -f "/tools/Xilinx/Vivado/2023.2/settings64.sh" ]; then
    # shellcheck source=/dev/null
    . "/tools/Xilinx/Vivado/2023.2/settings64.sh"
  fi

  if command -v vivado >/dev/null 2>&1; then
    return 0
  fi

  echo "ERROR: 'vivado' not found. Set VIVADO_SETTINGS to your settings64.sh or add Vivado to PATH."
  return 1
}

make_tmp_tcl() {
  # $1 = base/core tcl file to prepend
  local base_tcl="$1"

  if [ ! -f "$base_tcl" ]; then
    echo "ERROR: Base TCL not found: $base_tcl"
    return 1
  fi

  cat > vivado_commands.tcl <<'EOT'

# Vivado will raise an error if impl_1 is launched when it is already done. So

# check the progress first and only launch if it's not complete.

if { [get_property PROGRESS [get_runs impl_1]] != "100%"} {
  # Vivado only outputs to stdout for jobs that are explicitly waited on with
  # 'wait_on_run'. So launch and wait on synth then launch and wait on impl to
  # get logging to stdout from both.
  set_property -name {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} -value {-mode out_of_context} -objects [get_runs synth_1]
  launch_runs synth_1 -quiet

  launch_runs impl_1
  wait_on_run impl_1
  puts "Implementation completed"
}

if { [get_property PROGRESS [get_runs impl_1]] != "100%"} {
   puts "ERROR: Implementation and bitstream generation step failed."
   exit 1
}
EOT

  cat "$base_tcl" vivado_commands.tcl > tmp.tcl
}

find_core_tcl() {
  # Prefer a TCL named like the core "SETUP_DIR.tcl", otherwise take the first *.tcl found
  # $1 = SETUP_DIR (colons -> underscores)
  local setup_dir="$1"
  local preferred="${setup_dir}.tcl"

  if [ -f "$preferred" ]; then
    echo "$preferred"
    return 0
  fi

  # Fallback: look for any tcl in the current dir (excluding the ones we create)
  local cand
  cand=$(ls -1 *.tcl 2>/dev/null | grep -v -E '(^tmp\.tcl$|^vivado_commands\.tcl$)' | head -n 1 || true)
  if [ -n "$cand" ]; then
    echo "$cand"
    return 0
  fi

  return 1
}

# --- options ---------------------------------------------------------------

# parse options

while getopts "s:h" opt; do
  case $opt in
    s) SETUP="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done
shift $((OPTIND-1))

if [ $# -lt 1 ]; then
  usage
fi

# parse targets (accept either multiple args or one comma-separated arg)

if [ $# -eq 1 ] && [[ "$1" == *,* ]]; then
  IFS=',' read -r -a TARGETS <<< "$1"
else
  TARGETS=("$@")
fi

PROJECT_ROOT="$(pwd)"
LOGDIR="${PROJECT_ROOT}/logs"
mkdir -p "$LOGDIR"

# convert setup name used by fusesoc -> build dir name (example: "aisec:ip:ntt_r4mdc:0.1" -> "aisec_ip_ntt_r4mdc_0.1")

SETUP_DIR="${SETUP//:/_}"

# Extract PE count (PES) from SETUP_DIR; assumes ..._<PES>_<version>

PES=""
if [[ "$SETUP_DIR" == *_*_* ]]; then
  cand=$(awk -F'_' '{print $(NF-1)}' <<< "$SETUP_DIR")
  if [[ "$cand" =~ ^[0-9]+$ ]]; then
    PES="$cand"
  fi
fi

SUMMARY="${LOGDIR}/summary.txt"
: > "$SUMMARY"  # truncate/clear summary

EXIT_CODE=0

# --- main loop -------------------------------------------------------------

for TARGET in "${TARGETS[@]}"; do
  echo "== TARGET: ${TARGET} ==" | tee -a "$SUMMARY"

  FUSESOC_LOG="${LOGDIR}/${TARGET}.fusesoc.log"
  echo "Running fusesoc --cores-root . run --tool=${TOOL} --target=${TARGET} --no-export --setup \"${SETUP}\"" | tee -a "$SUMMARY"

  if fusesoc --cores-root . run --tool="${TOOL}" --target="${TARGET}" --no-export --setup "${SETUP}" >"$FUSESOC_LOG" 2>&1; then
    echo "fusesoc: setup OK" | tee -a "$SUMMARY"
  else
    echo "fusesoc: setup FAILED (see ${FUSESOC_LOG})" | tee -a "$SUMMARY"
    EXIT_CODE=2
    # continue to try to locate build dir/logs
  fi

  # expected build dir (fallback: try to find in fusesoc log)
  BUILD_DIR="${PROJECT_ROOT}/build/${SETUP_DIR}/${TARGET}-${TOOL}"
  if [ ! -d "$BUILD_DIR" ]; then
    FOUND=$(grep -m1 -oE 'build/[^[:space:]]+' "$FUSESOC_LOG" || true)
    if [ -n "$FOUND" ]; then
      BUILD_DIR="${PROJECT_ROOT}/${FOUND}"
    fi
  fi

  if [ ! -d "$BUILD_DIR" ]; then
    echo "Build directory not found for ${TARGET}. Expected ${BUILD_DIR}" | tee -a "$SUMMARY"
    EXIT_CODE=$(( EXIT_CODE == 0 ? 3 : EXIT_CODE ))
    continue
  fi

  echo "Entering build dir: ${BUILD_DIR}" | tee -a "$SUMMARY"
  pushd "$BUILD_DIR" > /dev/null

  # detect core TCL
  CORE_TCL=$(find_core_tcl "$SETUP_DIR" || true)
  if [ -z "$CORE_TCL" ]; then
    echo "ERROR: Could not find a core TCL file in ${BUILD_DIR}" | tee -a "$SUMMARY"
    popd > /dev/null
    EXIT_CODE=$(( EXIT_CODE == 0 ? 4 : EXIT_CODE ))
    continue
  fi
  echo "Using core TCL: ${CORE_TCL}" | tee -a "$SUMMARY"

  # assemble tmp TCL (core + run commands)
  if ! make_tmp_tcl "$CORE_TCL"; then
    echo "ERROR: Failed to create tmp.tcl" | tee -a "$SUMMARY"
    popd > /dev/null
    EXIT_CODE=$(( EXIT_CODE == 0 ? 4 : EXIT_CODE ))
    continue
  fi

  # ensure vivado available
  if ! ensure_vivado; then
    echo "ERROR: Vivado not available" | tee -a "$SUMMARY"
    popd > /dev/null
    EXIT_CODE=$(( EXIT_CODE == 0 ? 5 : EXIT_CODE ))
    continue
  fi

  # run vivado
  VIVADO_LOG="${LOGDIR}/${TARGET}.vivado.log"
  echo "Running Vivado (batch): tmp.tcl -> ${VIVADO_LOG}" | tee -a "$SUMMARY"
  if vivado -mode batch -source tmp.tcl > "$VIVADO_LOG" 2>&1; then
    echo "Vivado: OK" | tee -a "$SUMMARY"

  else
    echo "Vivado: FAILED (see ${VIVADO_LOG})" | tee -a "$SUMMARY"
    EXIT_CODE=$(( EXIT_CODE == 0 ? 6 : EXIT_CODE ))
  fi

  popd > /dev/null

  # parse report
  REPORT_NAME="${TARGET}"
  if [ -n "$PES" ]; then
    REPORT_NAME="${TARGET}_${PES}"
  fi

  python3 ${PROJECT_ROOT}/util/report/parse_fpga_report.py ${BUILD_DIR}/${SETUP_DIR}.runs/impl_1/ntt_r4mdc_synth_wrapper_utilization_placed.rpt -csv ${PROJECT_ROOT}/build/reports/${SETUP_DIR}/${TARGET}-vivado.csv -tex ${PROJECT_ROOT}/build/reports/${SETUP_DIR}/${TARGET}-vivado.tex -name "${REPORT_NAME}"

done


echo "Summary written to ${SUMMARY}"
exit "$EXIT_CODE"
