#!/usr/bin/env python3

# Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

import numpy as np
from ntt_python.mod_arith import *
from ntt_python.ntt_base import *
import os
import sys

import random

class NttTest:
    def __init__(self, name, n, q, psi, w4, path):
        self.n = n            
        self.q = q
        self.psi = psi
        self.w4 = w4
        self.name = name
        self.path = path
        self.stimulus = list(range(0, self.n))
        self.expected = list(range(0, self.n))
        self.arith_impl = mod_arith(self.q, 0, 0, 0, self.psi,  self.w4)

    def run_ntt_test(self,random_test,seed):
        poly = list(range(0, self.n))
        if (random_test == True):
            for i in range(0, len(poly)):
              random.seed(seed+i)
              self.stimulus[i] = random.randint(0,self.q-1)
              poly[i] = self.stimulus[i]
        else:
            for i in range(0, len(poly)):
              self.stimulus[i] = i
              poly[i] = self.stimulus[i]
        self.expected = ntt_r4(self.n, self.n, self.arith_impl, poly, True, 0)

    def generate_ntt_test(self):
      # Create the directory if it does not exist
      os.makedirs(os.path.dirname(self.path), exist_ok=True)
      f = open(str(self.path) + "/testvector_coeff_" + str(self.name) + ".mem", "w")
      for j in range(0,self.n):
        f.write(str(format(self.stimulus[j], 'x'))+"\n") #.zfill(8)
      f.close()

      f = open(str(self.path) + "/testvector_coeff_exp_" + str(self.name) + ".mem", "w")
      for j in range(0,self.n):
        f.write(str(format(self.expected[j], 'x'))+"\n") #.zfill(8)
      f.close()

    def run_intt_test(self,random_test,seed):
        poly = list(range(0, self.n))
        if (random_test == True):
            for i in range(0, len(poly)):
              random.seed(seed+i)
              self.stimulus[i] = random.randint(0,self.q-1)
              poly[i] = self.stimulus[i]
        else:
            for i in range(0, len(poly)):
              poly[i] = i
            poly = ntt_r4(self.n, self.n, self.arith_impl, poly)
            for i in range(0, len(poly)):
              self.stimulus[i] = poly[i]

        self.expected = intt_r4(self.n, 1, self.arith_impl, poly, True, 0)


    def generate_intt_test(self):
      # Create the directory if it does not exist
      os.makedirs(os.path.dirname(self.path), exist_ok=True)
      f = open(str(self.path) + "/testvector_coeff_" + str(self.name) + ".mem", "w")
      for j in range(0,self.n):
        f.write(str(format(self.stimulus[j], 'x'))+"\n") #.zfill(8)
      f.close()

      f = open(str(self.path) + "/testvector_coeff_exp_" + str(self.name) + ".mem", "w")
      for j in range(0,self.n):
        f.write(str(format(self.expected[j], 'x'))+"\n") #.zfill(8)
      f.close()


