#!/usr/bin/env python3

# Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

import numpy as np
from ntt_python.mod_arith import *
from ntt_python.ntt_base import *
import os
from pathlib import Path
import math

def bit_reverse_order(coeffs):
    n = len(coeffs)
    # Calculate the number of bits required to represent the length
    num_bits = n.bit_length() - 1
    
    # Create a new list for the bit-reversed order
    reversed_coeffs = [0] * n
    
    for i in range(n):
        # Reverse the bits of the index
        reversed_index = int(bin(i)[2:].zfill(num_bits)[::-1], 2)
        reversed_coeffs[reversed_index] = coeffs[i]
    
    return reversed_coeffs

def reshape_list(input_list, n1, n2):
    if len(input_list) != n1 * n2:
        raise ValueError("The total size of the new array must be unchanged.")
    return np.array(input_list).reshape(n1, n2)

def process_poly(stage, poly,bfus):
    # Initialize parameters
    group_of_twiddles = 2
    twiddle_per_group = 1
    stride_between_groups = 2
    stride_between_bfus_in_ntt = 1
    stride_between_ntts = 4
    # Adjust parameters based on the stage
    twiddle_per_group <<= (2 * stage)
    stride_between_groups <<= (2 * stage)
    stride_between_bfus_in_ntt <<= (2 * stage)
    stride_between_ntts <<= (2 * stage)
    
    # Initialize poly2 with the appropriate length
    poly2 = [0] * (int(bfus/2) * 2 * group_of_twiddles * twiddle_per_group)  # Adjust size accordingly
    i = 0

    for ntt in range(int(bfus/2)):
        for bf_group in range(2):
            for twiddle_group in range(group_of_twiddles):
                for current_twiddle in range(twiddle_per_group):
                    idx = (
                        current_twiddle
                        + twiddle_group * stride_between_groups
                        + bf_group * stride_between_bfus_in_ntt
                        + ntt * stride_between_ntts
                    )
                    poly2[i] = poly[idx]
                    i += 1
    return poly2

def generate_r4ntt_rom(n, l, mod_arith, nof_bfus, path):
    # Ensure the base output directory exists (create parents as needed)
    base = Path(path)
    base.mkdir(parents=True, exist_ok=True)

    twiddle_rom1 = []
    twiddle_rom2 = []
    twiddle_rom3 = []

    log_n = int(math.log(n, 4))
    m = int(np.uint64(n) >> np.uint64(2))
    q = mod_arith.q

    # Use a stable omega base (omega_init if available)
    omega_base = getattr(mod_arith, "omega_init", mod_arith.omega)

    while m >= 1:
        p = m
        omega_m = pow(omega_base, p, q)
        limit = int(n // (4 * p))
        for k in range(limit):
            rev = reverse_2bit_chunks(k, limit.bit_length() - 1)
            e = 2 * rev + 1
            twiddle_rom1.append(pow(omega_m, e, q))
            twiddle_rom2.append(pow(omega_m, 2 * e, q))
            twiddle_rom3.append(pow(omega_m, 3 * e, q))
        m = int(np.uint64(m) >> np.uint64(2))

    r = 0
    stage = 0
    for i in range(log_n - 1, -1, -1):
        J = int(pow(4, i))
        twiddle_stage_rom1 = []
        twiddle_stage_rom2 = []
        twiddle_stage_rom3 = []

        for k in range(int(n / (4 * J))):
            wa1 = twiddle_rom1[r]
            wa2 = twiddle_rom2[r]
            wa3 = twiddle_rom3[r]
            twiddle_stage_rom1.append(wa1)
            twiddle_stage_rom2.append(wa2)
            twiddle_stage_rom3.append(wa3)
            r += 1

        log_used = 4
        if nof_bfus == 2:
            log_used = 2

        if nof_bfus > 1:
            shift = int(math.ceil(math.log(nof_bfus, log_used)))
            if stage >= shift:
                # Optional MDC reordering (unchanged)
                if nof_bfus == 8:
                    
                    twiddle_stage_rom1 = process_poly(stage - 2, twiddle_stage_rom1, nof_bfus)
                    twiddle_stage_rom2 = process_poly(stage - 2, twiddle_stage_rom2, nof_bfus)
                    twiddle_stage_rom3 = process_poly(stage - 2, twiddle_stage_rom3, nof_bfus)
                if nof_bfus == 32:
                    
                    twiddle_stage_rom1 = process_poly(stage - 3, twiddle_stage_rom1, nof_bfus)
                    twiddle_stage_rom2 = process_poly(stage - 3, twiddle_stage_rom2, nof_bfus)
                    twiddle_stage_rom3 = process_poly(stage - 3, twiddle_stage_rom3, nof_bfus)

                
                
                for mdc in range(nof_bfus):
                    subdir = base / str(mdc)
                    subdir.mkdir(parents=True, exist_ok=True)

                    stage_idx = stage - shift

                    with open(subdir / f"twiddle_stage_rom1_{stage_idx}.mem", "w") as f:
                        for idx in range(mdc * (len(twiddle_stage_rom1) // nof_bfus),
                                         (mdc + 1) * (len(twiddle_stage_rom1) // nof_bfus)):
                            f.write(f"{format(twiddle_stage_rom1[idx], 'x')}\n")

                    with open(subdir / f"twiddle_stage_rom2_{stage_idx}.mem", "w") as f:
                        for idx in range(mdc * (len(twiddle_stage_rom2) // nof_bfus),
                                         (mdc + 1) * (len(twiddle_stage_rom2) // nof_bfus)):
                            f.write(f"{format(twiddle_stage_rom2[idx], 'x')}\n")

                    with open(subdir / f"twiddle_stage_rom3_{stage_idx}.mem", "w") as f:
                        for idx in range(mdc * (len(twiddle_stage_rom3) // nof_bfus),
                                         (mdc + 1) * (len(twiddle_stage_rom3) // nof_bfus)):
                            f.write(f"{format(twiddle_stage_rom3[idx], 'x')}\n")
            else:
                
                with open(base / f"twiddle_stage_rom1_{stage}.mem", "w") as f:
                    for idx in range(len(twiddle_stage_rom1)):
                        for _ in range(int(nof_bfus / len(twiddle_stage_rom1))):
                            f.write(f"{format(twiddle_stage_rom1[idx], 'x')}\n")

                with open(base / f"twiddle_stage_rom2_{stage}.mem", "w") as f:
                    for idx in range(len(twiddle_stage_rom2)):
                        for _ in range(int(nof_bfus / len(twiddle_stage_rom2))):
                            f.write(f"{format(twiddle_stage_rom2[idx], 'x')}\n")

                with open(base / f"twiddle_stage_rom3_{stage}.mem", "w") as f:
                    for idx in range(len(twiddle_stage_rom3)):
                        for _ in range(int(nof_bfus / len(twiddle_stage_rom3))):
                            f.write(f"{format(twiddle_stage_rom3[idx], 'x')}\n")
        else:
            with open(base / f"twiddle_stage_rom1_{stage}.mem", "w") as f:
                for idx in range(len(twiddle_stage_rom1)):
                    f.write(f"{format(twiddle_stage_rom1[idx], 'x')}\n")

            with open(base / f"twiddle_stage_rom2_{stage}.mem", "w") as f:
                for idx in range(len(twiddle_stage_rom2)):
                    f.write(f"{format(twiddle_stage_rom2[idx], 'x')}\n")

            with open(base / f"twiddle_stage_rom3_{stage}.mem", "w") as f:
                for idx in range(len(twiddle_stage_rom3)):
                    f.write(f"{format(twiddle_stage_rom3[idx], 'x')}\n")

        stage += 1

def generate_r4intt_rom(n, l, mod_arith, nof_bfus, path):
    base = Path(path)
    base.mkdir(parents=True, exist_ok=True)

    twiddle_rom1 = []
    twiddle_rom2 = []
    twiddle_rom3 = []

    log_n = int(math.log(n, 4))
    m = int(np.uint64(n) >> np.uint64(2))
    q = mod_arith.q

    # Use a stable base for omega (omega_init if available)
    omega_base = getattr(mod_arith, "omega_init", mod_arith.omega)

    # Precompute twiddles (inverse uses same twiddle tables, reversed consumption)
    while m >= 1:
        p = m
        omega_m = pow(omega_base, p, q)
        limit = int(n // (4 * p))
        for k in range(limit):
            rev = reverse_2bit_chunks(k, limit.bit_length() - 1)
            e = 2 * rev + 1
            twiddle_rom1.append(pow(omega_m, e, q))
            twiddle_rom2.append(pow(omega_m, 2 * e, q))
            twiddle_rom3.append(pow(omega_m, 3 * e, q))
        m = int(np.uint64(m) >> np.uint64(2))

    # Consume twiddles in reverse order for inverse
    r = len(twiddle_rom1) - 1
    stage = log_n - 1

    for i in range(log_n):
        J = int(pow(4, i))

        twiddle_stage_rom1 = []
        twiddle_stage_rom2 = []
        twiddle_stage_rom3 = []

        for k in range(int(n // (4 * J))):
            wa1 = twiddle_rom1[r]
            wa2 = twiddle_rom2[r]
            wa3 = twiddle_rom3[r]
            twiddle_stage_rom1.append(wa1)
            twiddle_stage_rom2.append(wa2)
            twiddle_stage_rom3.append(wa3)
            r -= 1

        log_used = 2 if nof_bfus == 2 else 4

        if nof_bfus > 1:
            shift = int(math.ceil(math.log(nof_bfus, log_used)))
            if stage >= shift:
                # Optional MDC reordering (unchanged)
                if nof_bfus == 8:
                    
                    twiddle_stage_rom1 = process_poly(stage - 2, twiddle_stage_rom1, nof_bfus)
                    twiddle_stage_rom2 = process_poly(stage - 2, twiddle_stage_rom2, nof_bfus)
                    twiddle_stage_rom3 = process_poly(stage - 2, twiddle_stage_rom3, nof_bfus)
                if nof_bfus == 32:
                    
                    twiddle_stage_rom1 = process_poly(stage - 3, twiddle_stage_rom1, nof_bfus)
                    twiddle_stage_rom2 = process_poly(stage - 3, twiddle_stage_rom2, nof_bfus)
                    twiddle_stage_rom3 = process_poly(stage - 3, twiddle_stage_rom3, nof_bfus)

                
                
                stage_idx = stage - shift

                for mdc in range(nof_bfus):
                    
                    subdir = base / str(mdc)
                    subdir.mkdir(parents=True, exist_ok=True)

                    # Slice per BFU
                    start = mdc * (len(twiddle_stage_rom1) // nof_bfus)
                    end = (mdc + 1) * (len(twiddle_stage_rom1) // nof_bfus)

                    with open(subdir / f"twiddle_inv_stage_rom1_{stage_idx}.mem", "w") as f:
                        for idx in range(start, end):
                            f.write(f"{format(twiddle_stage_rom1[idx], 'x')}\n")

                    with open(subdir / f"twiddle_inv_stage_rom2_{stage_idx}.mem", "w") as f:
                        for idx in range(start, end):
                            f.write(f"{format(twiddle_stage_rom2[idx], 'x')}\n")

                    with open(subdir / f"twiddle_inv_stage_rom3_{stage_idx}.mem", "w") as f:
                        for idx in range(start, end):
                            f.write(f"{format(twiddle_stage_rom3[idx], 'x')}\n")

            else:
                
                with open(base / f"twiddle_inv_stage_rom1_{stage}.mem", "w") as f:
                    for idx in range(len(twiddle_stage_rom1)):
                        for _ in range(int(nof_bfus / len(twiddle_stage_rom1))):
                            f.write(f"{format(twiddle_stage_rom1[idx], 'x')}\n")

                with open(base / f"twiddle_inv_stage_rom2_{stage}.mem", "w") as f:
                    for idx in range(len(twiddle_stage_rom2)):
                        for _ in range(int(nof_bfus / len(twiddle_stage_rom2))):
                            f.write(f"{format(twiddle_stage_rom2[idx], 'x')}\n")

                with open(base / f"twiddle_inv_stage_rom3_{stage}.mem", "w") as f:
                    for idx in range(len(twiddle_stage_rom3)):
                        for _ in range(int(nof_bfus / len(twiddle_stage_rom3))):
                            f.write(f"{format(twiddle_stage_rom3[idx], 'x')}\n")
        else:
            with open(base / f"twiddle_inv_stage_rom1_{stage}.mem", "w") as f:
                for idx in range(len(twiddle_stage_rom1)):
                    f.write(f"{format(twiddle_stage_rom1[idx], 'x')}\n")

            with open(base / f"twiddle_inv_stage_rom2_{stage}.mem", "w") as f:
                for idx in range(len(twiddle_stage_rom2)):
                    f.write(f"{format(twiddle_stage_rom2[idx], 'x')}\n")

            with open(base / f"twiddle_inv_stage_rom3_{stage}.mem", "w") as f:
                for idx in range(len(twiddle_stage_rom3)):
                    f.write(f"{format(twiddle_stage_rom3[idx], 'x')}\n")

        stage -= 1