#!/usr/bin/env python3

# Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

"""
Generates an R4MDC (MDC) NTTs
for both DIT (CT) and DIF (GS) variants via Mako templates.
"""

import argparse
import math
import numpy as np
from mako.lookup import TemplateLookup

from ntt_python.mod_arith import *
from ntt_python.ntt_gen_testvector import *
from ntt_python.ntt_gen_rom import *

class NttGen:
    def __init__(self, n, q, psi, w4, dw, red, pes):
        # NTT parameters
        self.n = n
        self.q = q
        self.psi = psi
        self.w4 = w4
        self.dw = dw
        self.red = red
        self.pes = pes  # number of butterfly units (parallelism)
        self.delay_mult = 0 
        self.delay_add_sub = 3 
        self.delay_const_mult = 2
        self.delay_red = 0
        self.delay_bf = 0
        self.twiddles = []

        # Paths and templates
        self.core_output_path = "hw/ip/ntt_r4mdc"
        self.top_core_output_path = "hw/top_ntt/"
        self.dv_core_output_path = "hw/ip/ntt_r4mdc/dv"
        self.mem_output_path = "hw/mem"
        self.templates_dir = "./util/templates"

    def reset_twiddles(self):
        self.twiddles = []

    def compute_delays(self):
        # Future Work: read from hjson
        self.delay_mul = 0 
        self.delay_red = 0
        self.delay_bf = 0
        self.delay_const_mult = 0

        if self.q == 268369921:
            self.delay_red = 6
            self.delay_const_mult = 3
        elif self.q == 18446744069414584321:
            self.delay_red = 3
            self.delay_const_mult = 1
        elif self.q == 33550337:
            self.delay_red = 3
            self.delay_const_mult = 1
        else: 
           self.delay_red = 3
           self.delay_const_mult = 1

        if self.dw == 28:
            self.delay_mult = 4
        elif self.dw == 64:
            self.delay_mult = 5
        elif self.dw == 25:
            self.delay_mult = 3
        else: 
           self.delay_mult = 3

        self.delay_bf = ((self.delay_mult + self.delay_red) + self.delay_add_sub + 1) + ((self.delay_const_mult + self.delay_red)+ self.delay_add_sub + 1)

    # Twiddles for DIT (forward NTT), reduced for pes
    def prepare_twiddles_dit(self):
        r = int(2 ** self.dw)
        q_dash = pow((-self.q), -1, r)
        r_dash = (pow((r), 2, self.q))
        mod_arith1 = mod_arith(self.q, r, q_dash, r_dash, self.psi, self.w4)
        generate_r4ntt_rom(self.n, self.n, mod_arith1, self.pes,self.mem_output_path + "/" + str(self.q) + "_" + str(self.n) + "_" + str(self.pes))

    # Twiddles for DIF (inverse-like ordering), reduced for pes
    def prepare_twiddles_dif(self):
        r = int(2 ** self.dw)
        q_dash = pow((-self.q), -1, r)
        r_dash = (pow((r), 2, self.q))
        mod_arith1 = mod_arith(self.q, r, q_dash, r_dash, self.psi, self.w4)
        generate_r4intt_rom(self.n, 1, mod_arith1, self.pes,self.mem_output_path + "/" + str(self.q) + "_" + str(self.n) + "_" + str(self.pes))

    # Render helper
    def _render_to_file(self, tpl_name, out_path, context):
        lookup = TemplateLookup(directories=[self.templates_dir], filesystem_checks=True)
        tpl = lookup.get_template(tpl_name)
        with open(out_path, 'w') as f:
            f.write(tpl.render(**context))

    # Core files (FuseSoC)
    def generate_ip_core(self):
        # mode: "dit" or "dif"
        out = f"{self.core_output_path}/ntt_r4mdc_{self.q}_{self.n}_{self.pes}.core"
        self._render_to_file(
            "ntt_r4mdc_ip.core.tpl",
            out,
            dict(ntt=self)
        )

    def generate_dv_core(self):
        out = f"{self.dv_core_output_path}/ntt_r4mdc_{self.q}_{self.n}_{self.pes}_dv.core"
        self._render_to_file(
            "ntt_r4mdc_dv.core.tpl",
            out,
            dict(ntt=self)
        )
    def generate_top_core(self):
        # mode: "dit" or "dif"
        out = f"{self.top_core_output_path}/top_ntt_{self.q}_{self.n}_{self.pes}.core"
        self._render_to_file(
            "top_ntt_ip.core.tpl",
            out,
            dict(ntt=self)
        )
    def generate_package_script(self):
        # mode: "dit" or "dif"
        out = f"{self.top_core_output_path}/util/package_ip_top_ntt_{self.q}_{self.n}_{self.pes}.tcl"
        self._render_to_file(
            "package_ip_top_ntt.tc.tpl",
            out,
            dict(ntt=self)
        )
    # Testvectors
    def generate_ntt_testvectors(self):
        # DIT -> NTT
        for i in range(100):
          tv = NttTest(f"ntt_{self.q}_{self.n}_{i}", self.n, self.q, self.psi, self.w4,
                      f"hw/dv/testvectors/ntt_{self.q}_{self.n}/")
          tv.run_ntt_test(True,100*i)
          tv.generate_ntt_test()

    def generate_intt_testvectors(self):
        # DIF -> INTT
        for i in range(100):
          tv = NttTest(f"intt_{self.q}_{self.n}_{i}", self.n, self.q, self.psi, self.w4,
                      f"hw/dv/testvectors/ntt_{self.q}_{self.n}/")
          tv.run_intt_test(True,100*i)
          tv.generate_intt_test()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate R4MDC NTT (DIT/DIF) core files via Mako templates.')
    parser.add_argument('n', type=int, help='polynomial degree n')
    parser.add_argument('q', type=int, help='prime modulus q')
    parser.add_argument('psi', type=int, help='psi primitive root')
    parser.add_argument('w4', type=int, help='4th root of unity')
    parser.add_argument('dw', type=int, help='data width')
    parser.add_argument('red', type=str, help='reduction method (e.g., LAZY/SPARSE)')
    parser.add_argument('pes', type=int, help='number of butterfly units (parallelism)')

    args = parser.parse_args()

    gen = NttGen(args.n, args.q, args.psi, args.w4, args.dw, args.red, args.pes)
    gen.compute_delays()
    gen.prepare_twiddles_dit()
    gen.generate_ntt_testvectors()
    gen.prepare_twiddles_dif()
    gen.generate_intt_testvectors()
    gen.generate_ip_core()
    gen.generate_dv_core()
    gen.generate_top_core()
    gen.generate_package_script()