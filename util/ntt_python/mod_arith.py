#!/usr/bin/env python3

# Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0


import numpy as np
import sys

class mod_arith:

    def __init__(self, q, r, q_dash, r_dash, omega, psi):
        self.q = q                  # run-time configurable
        self.r = r                  # fixed; compile-time configurable
        self.q_dash = q_dash        # run-time configurable
        self.r_dash = r_dash        # run-time configurable
        self.omega = omega          # allows calculation of twiddle factors on the fly together with twiddle
        self.psi = psi              # allows calculation of twiddle factors on the fly together with twiddle
        self.twiddle = 0            # allows to load twiddle factors or compute them on the fly
        self.omega_init = omega     # initial value of omega for precomputing values
        self.psi_init = psi         # initial value of psi for precomputing values

    def mul(self,a,b):
        q = self.q
        c = a*b
        z = c % q
        return z
    
    def mont_red(self, a):
        m = int(a * self.q_dash)
        s = int(a + (m % self.r) * self.q)
        t = int(s) >> int(np.log2(self.r))
        if np.uint64(self.q) <= t:
            t = t - self.q
        return t

    def mont_mul(self, a, b):
        tmp = int(a * self.r_dash)
        a_dash = self.mont_red(tmp)
        tmp = int(b * self.r_dash)
        b_dash = self.mont_red(tmp)
        t_dash = self.mont_red(int(a_dash * b_dash))
        c = self.mont_red(t_dash)
        return c

    def add(self, a, b):
        c = int(a + b)
        if c >= self.q:
            c = c - self.q
        return c

    def sub(self, a, b):
        adds = int(a + self.q - b)
        c = adds - self.q
        if adds < self.q:
            c = adds
        return c

    def ct_butterfly_mont(self, a, b, twiddle):
        tmp = int(twiddle * self.r_dash)
        omega_dash = self.mont_red(tmp)
        t = self.mont_red(int(b*omega_dash))
        x = self.add(a, t)
        y = self.sub(a, t)
        return x, y

    def ct_butterfly(self, a, b, twiddle):
        t = self.mul(b,twiddle)
        x = self.add(a, t)
        y = self.sub(a, t)
        return x, y

    def gs_butterfly_mont(self, a, b, twiddle):
        tmp = int(twiddle * self.r_dash)
        omega_dash = self.mont_red(tmp)
        x = self.add(a, b)
        t = self.sub(a, b)
        y = self.mont_red(int(t * omega_dash))
        return x, y

    def gs_butterfly(self, a, b, twiddle):
        x = self.add(a, b)
        t = self.sub(a, b)
        y = self.mul(t,twiddle)
        return x, y   
    
    def op21(self,a):
        q = self.q
        if a & 1 == 0:
            r = (a >> 1) % q
        else:
            r = ((a >> 1) + ((q + 1)>>1)) % q
        return r

    def update_twiddle_mont(self):
        self.twiddle = self.mont_mul(self.omega, self.twiddle)
        return 1
    
    def update_twiddle(self):
        self.twiddle = self.mul(self.omega, self.twiddle)
        return 1
    
    def update_omega_and_psi_mont(self):
        tmp = self.omega
        self.psi = tmp
        self.omega = self.mont_mul(tmp, tmp)
        return 1
    
    def update_omega_and_psi(self):
        tmp = self.omega
        self.psi = tmp
        self.omega = self.mul(tmp, tmp)
        return 1