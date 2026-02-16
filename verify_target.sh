#!/usr/bin/env bash
set -uo pipefail

# Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Simple runner for multiple fusesoc targets (ModelSim)
# Usage:
#   ./run_fusesoc_targets.sh -s "aisec:dv:ntt_r2mdc:0.1" std128_dit_2 std128_dif_2
#   ./run_fusesoc_targets.sh "std128_dit_2,std128_dif_2"
#
# Outputs:
#   logs/<target>.fusesoc.log  - fusesoc stdout/stderr
#   logs/<target>.sim.log     - make run stdout/stderr
#   logs/<target>.errors      - extracted error-like lines (if any)
#   logs/summary.txt          - per-target summary

# Defaults
SETUP="aisec:dv:ntt_r4mdc:0.1"
TOOL="modelsim"

usage() {
  cat <<EOF
Usage: $0 [-s SETUP] TARGET1 [TARGET2 ...]
       $0 "targetA,targetB,..."   (single comma-separated arg accepted)
Default SETUP: ${SETUP}
EOF
  exit 1
}

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

# convert setup name used by fusesoc -> build dir name (example: "aisec:dv:ntt_r2mdc:0.1" -> "aisec_dv_ntt_r2mdc_0.1")
SETUP_DIR="${SETUP//:/_}"
SUMMARY="${LOGDIR}/summary.txt"
: > "$SUMMARY"  # truncate/clear summary

EXIT_CODE=0

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
    EXIT_CODE=3
    continue
  fi

  echo "Entering build dir: ${BUILD_DIR}" | tee -a "$SUMMARY"
  pushd "$BUILD_DIR" > /dev/null

  SIM_LOG="${LOGDIR}/${TARGET}.sim.log"
  echo "Running 'make run' (logging to ${SIM_LOG})" | tee -a "$SUMMARY"
  if make run >"$SIM_LOG" 2>&1; then
    echo "make run finished (rc=0)" | tee -a "$SUMMARY"
  else
    RC=$?
    echo "make run returned ${RC} (see ${SIM_LOG})" | tee -a "$SUMMARY"
    EXIT_CODE=4
  fi

  # parse the common summary line: "Simulation of ... completed with <N> errors"
  SIM_SUMMARY_LINE=$(grep -E 'Simulation of .* completed with *[0-9]+ errors' "$SIM_LOG" || true)
  if [ -n "$SIM_SUMMARY_LINE" ]; then
    N_ERRORS=$(echo "$SIM_SUMMARY_LINE" | sed -E 's/.*completed with *([0-9]+) errors.*/\1/')
    echo "Parsed simulation summary: ${N_ERRORS} errors" | tee -a "$SUMMARY"
    if [ "$N_ERRORS" -ne 0 ]; then EXIT_CODE=5; fi
  else
    echo "No 'Simulation of ... completed' summary line found" | tee -a "$SUMMARY"
  fi

  # pickup $stop notes (testbench stop points)
  STOP_LINES=$(grep -n '\$stop' "$SIM_LOG" || true)
  if [ -n "$STOP_LINES" ]; then
    echo "Found \$stop notes (first 10 lines):" | tee -a "$SUMMARY"
    echo "$STOP_LINES" | sed -n '1,10p' | tee -a "$SUMMARY"
  fi

  # extract error-like messages (ModelSim '** Error', UVM errors, generic Error:, Assertion, ...)
  # NOTE: we intentionally do NOT match plain 'Error' (too generic), only patterns typical for real errors.
  ERR_LINES=$(grep -n -E '\*\* Error:|\*\* Errors|UVM_ERROR|UVM_FATAL|^\*\*\s+Error:|ERROR:|Error:|assertion|Assertion failed' "$SIM_LOG" || true)

  # exclude the "Simulation of ... completed with ..." summary line if matched by a generic ERROR pattern
  ERR_LINES=$(echo "$ERR_LINES" | grep -v -E 'Simulation of .* completed with' || true)

  # exclude lines that explicitly state zero errors, e.g. "Errors=0" or "Errors: 0"
  ERR_LINES=$(echo "$ERR_LINES" | grep -v -E 'Errors[=:]\s*0\b' || true)

  if [ -n "$ERR_LINES" ]; then
    ERR_FILE="${LOGDIR}/${TARGET}.errors"
    echo "$ERR_LINES" > "$ERR_FILE"
    echo "Errors extracted (saved to ${ERR_FILE}; first 20 lines shown):" | tee -a "$SUMMARY"
    echo "$ERR_LINES" | sed -n '1,20p' | tee -a "$SUMMARY"
    EXIT_CODE=6
  else
    echo "No explicit error-like lines found by grep" | tee -a "$SUMMARY"
  fi

  popd > /dev/null
  echo "" | tee -a "$SUMMARY"
done

echo "Run finished. Summary: ${SUMMARY}"
exit $EXIT_CODE
