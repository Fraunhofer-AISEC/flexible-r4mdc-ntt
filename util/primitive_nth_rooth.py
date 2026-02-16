#!/usr/bin/env sage -python

# Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

from sage.all import GF, is_prime, Mod
import sys, math

def primitive_nth_root(q, n):
    q = int(q)
    n = int(n)
    if n <= 0:
        raise ValueError("n must be a positive integer")
    if not is_prime(q):
        raise ValueError("q must be a prime")
    if n == 1:
        K = GF(q)
        return K(1), K, 1
    if math.gcd(n, q) != 1:
        raise ValueError(f"No primitive {n}-th root of unity exists in characteristic q={q} because gcd(n, q) != 1")

    # Minimal extension degree k with n | (q^k - 1)
    if (q - 1) % n == 0:
        k = 1
    else:
        k = Mod(q, n).multiplicative_order()

    K = GF(q**k, name='a')  # Field GF(q^k)
    g = K.multiplicative_generator()  # generator of K^*
    zeta = g**((K.order() - 1) // n)  # element of exact order n
    return zeta, K, k

def main(argv):
    if len(argv) != 3:
        print("Usage: sage -python primitive_nth_root.py <prime q> <n>")
        return 2
    q = int(argv[1])
    n = int(argv[2])
    zeta, K, k = primitive_nth_root(q, n)
    field_str = f"GF({q})" if k == 1 else f"GF({q}^{k})"
    print(f"Field: {field_str}")
    print(f"Primitive {n}-th root of unity: {zeta}")
    # Simple verification
    print(f"Verification: zeta^n == 1? {zeta**n == K(1)}; order(zeta) = {zeta.multiplicative_order()}")

if __name__ == "__main__":
    sys.exit(main(sys.argv))