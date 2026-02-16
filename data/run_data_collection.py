#!/usr/bin/env python3
"""
Run NTT synthesis & verification for multiple design points from an HJSON file
and collect .tex result files.

For each design point in the HJSON:
  1. Run RTL/config generation:

     python3 util/ntt_r4mdc.py N Q PSI W4 LOG_Q REDUCTION BFUS

  2. Overwrite constraints.xdc:

     hw/ip/ntt_r4mdc/synth/constraints.xdc
     with create_clock based on 'frequency' (MHz) in cfg, using 2 decimal places.

  3. Run synthesis:

     ./synth_target.sh -s "aisec:ip:ntt_r4mdc_Q_N_BFUS:0.1" TARGET
        TARGET = Q_N_type           (non-V7)
               = Q_N_v7_type        (V7)

  4. Run verification:

     ./verify_target.sh -s "aisec:dv:ntt_r4mdc_Q_N_BFUS:0.1" TARGET

  5. Collect result .tex files:
     - Simulation:

       build/aisec_dv_ntt_r4mdc_Q_N_BFUS_0.1/sim_results.tex
     - Synthesis:

       build/reports/aisec_ip_ntt_r4mdc_Q_N_BFUS_0.1/TARGET.tex
       (fallback: TARGET-vivado.tex)

     Copy them into:
       repo_root/data/<hjson_basename>_<timestamp>/
     with filenames:
       <design_name>_Q<N>_N<Q>_B<BFUS>_type-<type>_fpga-<fpga>_sim.tex
       <design_name>_Q<N>_N<Q>_B<BFUS>_type-<type>_fpga-<fpga>_synth.tex

Usage:
  python3 run_data_collection.py path/to/designs.hjson
  python3 run_data_collection.py path/to/designs.hjson --dry-run

"""

import argparse
import math
import subprocess
import sys
from pathlib import Path
from datetime import datetime
import shutil

try:
    import hjson
except ImportError:
    print("ERROR: This script requires the 'hjson' package. Install it with:\n"
          "  pip install hjson",
          file=sys.stderr)
    sys.exit(1)

# import the merge helper (merge_reports.py must be next to this script)

try:
    from util.report.merge_reports import merge_tex_files
except ImportError:
    merge_tex_files = None  # will handle this gracefully later


def parse_args():
    p = argparse.ArgumentParser(
        description="Automate NTT synthesis & verification from an HJSON config."
    )
    p.add_argument("hjson_file", help="Path to the HJSON configuration file")
    p.add_argument(
        "--dry-run",
        action="store_true",
        help="Print commands and copy operations but do not execute them"
    )
    # (optional) allow overriding merged output filename
    p.add_argument(
        "--merged-tex",
        help="Path for merged .tex output (default: <out_dir>/results.tex)",
        default=None,
    )
    return p.parse_args()


def iter_designs(data):
    """
    Iterate (name, cfg) pairs over the HJSON root.

    Supports:
      - dict: { "NAME": {...}, ... }
      - list of dicts: [ { "NAME": {...} }, { "OTHER": {...} }, ... ]

    """
    if isinstance(data, dict):
        for name, cfg in data.items():
            yield name, cfg
    elif isinstance(data, list):
        for elem in data:
            if isinstance(elem, dict):
                for name, cfg in elem.items():
                    yield name, cfg
            else:
                raise ValueError("List elements in HJSON root must be objects")
    else:
        raise ValueError("Unsupported HJSON root type (must be object or list)")


def compute_log_q(q: int) -> int:
    """Compute LOG(Q) as ceil(log2(Q))."""
    return math.ceil(math.log2(q))


def write_constraints_xdc(repo_root: Path, frequency_mhz) -> None:
    """
    Overwrite constraints.xdc with a single create_clock line using the
    given frequency in MHz. Uses exactly three decimal places.
    """
    freq = float(frequency_mhz)
    period_ns = 1000.0 / freq
    half_ns = period_ns / 2.0

    period_str = f"{period_ns:.3f}"
    half_str = f"{half_ns:.3f}"

    constraints_path = repo_root / "hw" / "ip" / "ntt_r4mdc" / "synth" / "constraints.xdc"
    constraints_path.parent.mkdir(parents=True, exist_ok=True)

    line = (
        f"create_clock -name CLK -period {period_str} "
        f"-waveform {{0 {half_str}}} [get_ports clk_i]\n"
    )
    constraints_path.write_text(line, encoding="utf-8")
    print(f"  Wrote constraints.xdc with period {period_str} ns (freq ~{freq} MHz)")


def run_cmd(cmd, cwd: Path, dry_run: bool):
    print("  CMD:", " ".join(str(c) for c in cmd))
    if dry_run:
        return
    subprocess.run(cmd, cwd=str(cwd), check=True)


def collect_results(
    name: str,
    repo_root: Path,
    out_dir: Path,
    *,
    N: int,
    Q: int,
    BFUS: int,
    type_str: str,
    fpga: str,
    target_suffix: str,
    synth_setup: str,
    verify_setup: str,
    dry_run: bool,
):
    """
    Collect simulation and synthesis .tex results and copy them into out_dir
    with unique, descriptive filenames.
    """
    print("  Step 5: Collecting .tex result files...")

    base_label = f"{name}_Q{Q}_N{N}_B{BFUS}_type-{type_str}_fpga-{fpga}"

    # --- Simulation results ---
    verify_setup_dir = verify_setup.replace(":", "_")
    sim_src = repo_root / "build" / verify_setup_dir / "sim_results.tex"
    sim_dest = out_dir / f"{base_label}_sim.tex"

    if sim_src.is_file():
        if dry_run:
            print(f"  [DRY-RUN] Would copy simulation results: {sim_src} -> {sim_dest}")
        else:
            shutil.copy2(sim_src, sim_dest)
            print(f"  Copied simulation results to {sim_dest}")
    else:
        print(f"  WARNING: Simulation results file not found at {sim_src}")

    # --- Synthesis results ---
    synth_setup_dir = synth_setup.replace(":", "_")
    synth_reports_dir = repo_root / "build" / "reports" / synth_setup_dir

    # Prefer new naming (<TARGET>.tex), fall back to older (<TARGET>-vivado.tex)
    synth_candidates = [
        synth_reports_dir / f"{target_suffix}.tex",
        synth_reports_dir / f"{target_suffix}-vivado.tex",
    ]
    synth_src = next((p for p in synth_candidates if p.is_file()), None)
    synth_dest = out_dir / f"{base_label}_synth.tex"

    if synth_src is not None:
        if dry_run:
            print(f"  [DRY-RUN] Would copy synthesis results: {synth_src} -> {synth_dest}")
        else:
            shutil.copy2(synth_src, synth_dest)
            print(f"  Copied synthesis results to {synth_dest}")
    else:
        tried_paths = ", ".join(str(p) for p in synth_candidates)
        print(f"  WARNING: Synthesis results file not found. Tried: {tried_paths}")


def process_design(name: str, design_cfg: dict, repo_root: Path, out_dir: Path, dry_run: bool):
    print(f"=== Design: {name} ===")

    try:
        params = design_cfg["param"]
        cfg = design_cfg["cfg"]
        platform = design_cfg["platform"]
    except KeyError as e:
        raise ValueError(f"Missing expected key {e} in design '{name}'") from e

    # Extract parameters
    N = int(params["N"])
    Q = int(params["Q"])
    PSI = int(params["PSI"])
    W4 = int(params["W4"])

    architecture = str(cfg["architecture"])
    radix = int(cfg["radix"])
    type_str = str(cfg["type"]).lower()           # e.g. "dit", "dif", "uni_opt"
    BFUS = int(cfg["parallelism"])                # BFUS
    reduction = str(cfg["reduction"])             # e.g. "sparse"
    frequency = float(cfg["frequency"])           # MHz

    fpga = str(platform["fpga"])                  # e.g. "u55c" or "V7"

    # LOG(Q)
    log_q = compute_log_q(Q)

    print(f"  N={N}, Q={Q}, PSI={PSI}, W4={W4}, LOG(Q)={log_q}")
    print(f"  type={type_str}, parallelism={BFUS}, reduction={reduction}, "
          f"frequency={frequency} MHz, fpga={fpga}, arch={architecture}, radix={radix}")

    # 1) Run util/ntt_r4mdc.py
    ntt_script = repo_root / "util" / "ntt_r4mdc.py"
    ntt_cmd = [
        "python3", str(ntt_script),
        str(N),
        str(Q),
        str(PSI),
        str(W4),
        str(log_q),
        reduction,
        str(BFUS),
    ]
    print("  Step 1: Generating NTT RTL & config files...")
    run_cmd(ntt_cmd, cwd=repo_root, dry_run=dry_run)

    # 2) Overwrite constraints.xdc from frequency
    print("  Step 2: Writing constraints.xdc...")
    write_constraints_xdc(repo_root, frequency)

    # Prepare target name
    # Non-V7:   Q_N_type
    # V7:       Q_N_v7_type
    if fpga.lower() == "v7":
        target_suffix = f"{Q}_{N}_v7_{type_str}"
    else:
        target_suffix = f"{Q}_{N}_{type_str}"

    # 3) Run synthesis
    synth_setup = f"aisec:ip:ntt_r4mdc_{Q}_{N}_{BFUS}:0.1"
    synth_script = repo_root / "synth_target.sh"
    synth_cmd = [
        str(synth_script),
        "-s", synth_setup,
        target_suffix,
    ]
    print("  Step 3: Running synthesis...")
    run_cmd(synth_cmd, cwd=repo_root, dry_run=dry_run)

    # 4) Run verification
    verify_setup = f"aisec:dv:ntt_r4mdc_{Q}_{N}_{BFUS}:0.1"
    verify_script = repo_root / "verify_target.sh"
    verify_cmd = [
        str(verify_script),
        "-s", verify_setup,
        target_suffix,
    ]
    print("  Step 4: Running verification...")
    run_cmd(verify_cmd, cwd=repo_root, dry_run=dry_run)

    # 5) Collect result .tex files
    collect_results(
        name=name,
        repo_root=repo_root,
        out_dir=out_dir,
        N=N,
        Q=Q,
        BFUS=BFUS,
        type_str=type_str,
        fpga=fpga,
        target_suffix=target_suffix,
        synth_setup=synth_setup,
        verify_setup=verify_setup,
        dry_run=dry_run,
    )

    print(f"=== Done: {name} ===\n")


def main():
    args = parse_args()
    # Repository root is one level above this script
    repo_root = Path(__file__).resolve().parent.parent
    hjson_path = Path(args.hjson_file)

    if not hjson_path.is_file():
        print(f"ERROR: HJSON file not found: {hjson_path}", file=sys.stderr)
        sys.exit(1)

    with hjson_path.open("r", encoding="utf-8") as f:
        data = hjson.load(f)

    # Prepare output directory under repo_root/data/<basename>_<timestamp>
    cfg_name = hjson_path.stem
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    out_dir = repo_root / "data" / f"{cfg_name}_{timestamp}"

    if args.dry_run:
        print(f"[DRY-RUN] Would create output directory: {out_dir}")
    else:
        out_dir.mkdir(parents=True, exist_ok=True)
        print(f"Output directory: {out_dir}")

    try:
        for name, design_cfg in iter_designs(data):
            process_design(name, design_cfg, repo_root, out_dir, args.dry_run)
    except subprocess.CalledProcessError as e:
        print(f"\nERROR: Command failed with exit code {e.returncode}", file=sys.stderr)
        sys.exit(e.returncode)
    except Exception as e:
        print(f"\nERROR: {e}", file=sys.stderr)
        sys.exit(1)

    # merge all collected .tex files into a single file
    if args.dry_run:
        merged_tex_path = args.merged_tex or (out_dir / "results.tex")
        print(f"[DRY-RUN] Would merge .tex files in {out_dir} into {merged_tex_path}")
    else:
        if merge_tex_files is None:
            print("WARNING: merge_reports.merge_tex_files not available; "
                  "skipping merged .tex generation.")
        else:
            merged_tex_path = Path(args.merged_tex) if args.merged_tex else (out_dir / "results.tex")
            print(f"Merging all .tex files in {out_dir} into {merged_tex_path}")
            merge_tex_files(str(out_dir), str(merged_tex_path))


if __name__ == "__main__":
    main()