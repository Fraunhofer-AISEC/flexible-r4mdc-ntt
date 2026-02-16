#!/usr/bin/env python3

# Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

import numpy as np
import sys
import math

from ntt_python.mod_arith import *

def reverse_2bit_chunks(num, bitwidth):
    # Convert the number to binary and remove the '0b' prefix
    binary_str = bin(num)[2:]

    # Pad the binary string to the specified bitwidth
    binary_str = binary_str.zfill(bitwidth)

    # Ensure the length is a multiple of 2
    if len(binary_str) % 2 != 0:
        binary_str = '0' + binary_str  # Add a leading zero if needed

    # Create groups of 2 bits and reverse them
    chunks = [binary_str[i:i+2] for i in range(0, len(binary_str), 2)]
    reversed_chunks = chunks[::-1]

    # Join the reversed chunks
    reversed_binary = ''.join(reversed_chunks)

    return int(reversed_binary, 2)

def reverse_bits(num, bitwidth):
    # Convert the number to binary and remove the '0b' prefix
    binary_str = bin(num)[2:]

    # Pad the binary string to the specified bitwidth
    binary_str = binary_str.zfill(bitwidth)

    # Reverse the binary string
    reversed_binary = binary_str[::-1]

    return int(reversed_binary, 2)

def ntt_r4(n, l, mod_arith, poly, dbg = False, dbg_idx = 0):
    # Radix-4 NTT according to https://tches.iacr.org/index.php/TCHES/article/view/9291/8857

    # For Radix-4 implementation:
    # Psi corresponds to primitive 4-th root of unity
    # Omega corresponds to primitive 2N-th root of unity

    # Initial values
    omega = mod_arith.omega_init
    w4 = mod_arith.psi_init

    unused = l

    twiddle_rom1 = []
    twiddle_rom2 = []
    twiddle_rom3 = []
    log_n = int(math.log(n,4))
    m = int(np.uint64(n) >> np.uint64(2))
    while (m >= 1):
        omega_m = pow(mod_arith.omega,m,mod_arith.q)
        p = m
        for k in range (0,int(n/int((4*p)))):
            limit = int(n/int((4*p)))
            twiddle_rom1.append(pow(omega_m,2*reverse_2bit_chunks(k,limit.bit_length()-1)+1,  mod_arith.q))
            twiddle_rom2.append(pow(omega_m,2*(2*reverse_2bit_chunks(k,limit.bit_length()-1)+1),  mod_arith.q))
            twiddle_rom3.append(pow(omega_m,3*(2*reverse_2bit_chunks(k,limit.bit_length()-1)+1),  mod_arith.q))
        m = int(np.uint64(m) >> np.uint64(2))
    r = 0
    for i in range(log_n-1,-1,-1):
        j = int(pow(4,i))
        for k in range(int(n/(4*j))):
            omega_1 = twiddle_rom1[r]
            omega_2 = twiddle_rom2[r]
            omega_3 = twiddle_rom3[r]
            r = r + 1
            for j2 in range (j):
                idx0 = 4*k*j+j2
                idx1 = 4*k*j+j2+j
                idx2 = 4*k*j+j2+2*j
                idx3 = 4*k*j+j2+3*j
                t0 = mod_arith.add(poly[idx0],mod_arith.mul(poly[idx2],omega_2))
                t1 = mod_arith.sub(poly[idx0],mod_arith.mul(poly[idx2],omega_2))
                t2 = mod_arith.add(mod_arith.mul(poly[idx1],omega_1),mod_arith.mul(poly[idx3],omega_3))
                t3 = mod_arith.sub(mod_arith.mul(poly[idx1],omega_1),mod_arith.mul(poly[idx3],omega_3))
                poly[idx0] = mod_arith.add(t0,t2)
                poly[idx1] = mod_arith.add(t1,mod_arith.mul(t3,w4))
                poly[idx2] = mod_arith.sub(t0,t2)
                poly[idx3] = mod_arith.sub(t1,mod_arith.mul(t3,w4))
    return poly
    
        
def intt_r4(n, l, mod_arith, poly, dbg = False, dbg_idx = 0):
    # Radix-4 NTT according to https://tches.iacr.org/index.php/TCHES/article/view/9291/8857

    # For Radix-4 implementation:
    # Psi corresponds to primitive 4-th root of unity
    # Omega corresponds to primitive 2N-th root of unity

    # Initial values
    omega = mod_arith.omega_init
    w4 = mod_arith.psi_init

    r = 0

    twiddle_rom1 = []
    twiddle_rom2 = []
    twiddle_rom3 = []
    log_n = int(math.log(n,4))
    m = int(np.uint64(n) >> np.uint64(2))
    while (m >= 1):
        omega_m = pow(omega,m,mod_arith.q)
        p = m

        for k in range (0,int(n/int((4*p)))):
            limit = int(n/int((4*p)))
            twiddle_rom1.append(pow(omega_m,2*reverse_2bit_chunks(k,limit.bit_length()-1)+1,  mod_arith.q))
            twiddle_rom2.append(pow(omega_m,2*(2*reverse_2bit_chunks(k,limit.bit_length()-1)+1),  mod_arith.q))
            twiddle_rom3.append(pow(omega_m,3*(2*reverse_2bit_chunks(k,limit.bit_length()-1)+1),  mod_arith.q))
        m = int(np.uint64(m) >> np.uint64(2))

    r = int(int(n-1)/3)-1
    for i in range(log_n):
        j = int(pow(4,i))
        for k in range(int(n/(4*j))):
            wa1 = twiddle_rom1[r]
            wa2 = twiddle_rom2[r]
            wa3 = twiddle_rom3[r]
            r = r - 1
            for j2 in range(j):
                idx0 = 4*k*j+j2
                idx1 = 4*k*j+j2+j
                idx2 = 4*k*j+j2+2*j
                idx3 = 4*k*j+j2+3*j
                t0 = mod_arith.op21(mod_arith.add(poly[idx0],poly[idx2]))
                t1 = (mod_arith.op21(-poly[idx0] + poly[idx2])*w4) % mod_arith.q
                t2 = mod_arith.op21(mod_arith.add(poly[idx1],poly[idx3]))
                t3 = (mod_arith.op21(-poly[idx1] + poly[idx3])) % mod_arith.q
                poly[idx0] = mod_arith.op21(mod_arith.add(t0,t2))
                poly[idx1] = mod_arith.op21(mod_arith.mul(mod_arith.add(t1,t3),wa1))
                poly[idx2] = (mod_arith.op21(t2 - t0) * wa2) % mod_arith.q
                poly[idx3] = (mod_arith.op21(t3 - t1) * wa3) % mod_arith.q
    return poly
