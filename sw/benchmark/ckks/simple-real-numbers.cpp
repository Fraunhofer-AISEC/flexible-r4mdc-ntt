///==================================================================================
// BSD 2-Clause License
//
// Copyright (c) 2025, Duality Technologies Inc. and other contributors
//
// All rights reserved.
//
// Author TPOC: contact@openfhe.org
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//==================================================================================

/*
  Simple examples for CKKS
 */

#define PROFILE

#include "openfhe.h"
#include <vector>
#include <iostream>

using namespace lbcrypto;

int main(int argc, char* argv[]) {
    // Step 1: Setup CryptoContext

    // A. Specify main parameters
    /* A1) Multiplicative depth:
   * The CKKS scheme we setup here will work for any computation
   * that has a multiplicative depth equal to 'multDepth'.
   * This is the maximum possible depth of a given multiplication,
   * but not the total number of multiplications supported by the
   * scheme.
   *
   * For example, computation f(x, y) = x^2 + x*y + y^2 + x + y has
   * a multiplicative depth of 1, but requires a total of 3 multiplications.
   * On the other hand, computation g(x_i) = x1*x2*x3*x4 can be implemented
   * either as a computation of multiplicative depth 3 as
   * g(x_i) = ((x1*x2)*x3)*x4, or as a computation of multiplicative depth 2
   * as g(x_i) = (x1*x2)*(x3*x4).
   *
   * For performance reasons, it's generally preferable to perform operations
   * in the shorted multiplicative depth possible.
   */
    uint32_t multDepth = 3;

    /* A2) Bit-length of scaling factor.
   * CKKS works for real numbers, but these numbers are encoded as integers.
   * For instance, real number m=0.01 is encoded as m'=round(m*D), where D is
   * a scheme parameter called scaling factor. Suppose D=1000, then m' is 10 (an
   * integer). Say the result of a computation based on m' is 130, then at
   * decryption, the scaling factor is removed so the user is presented with
   * the real number result of 0.13.
   *
   * Parameter 'scaleModSize' determines the bit-length of the scaling
   * factor D, but not the scaling factor itself. The latter is implementation
   * specific, and it may also vary between ciphertexts in certain versions of
   * CKKS (e.g., in FLEXIBLEAUTO).
   *
   * Choosing 'scaleModSize' depends on the desired accuracy of the
   * computation, as well as the remaining parameters like multDepth or security
   * standard. This is because the remaining parameters determine how much noise
   * will be incurred during the computation (remember CKKS is an approximate
   * scheme that incurs small amounts of noise with every operation). The
   * scaling factor should be large enough to both accommodate this noise and
   * support results that match the desired accuracy.
   */
    uint32_t firstModSize = 90;
    uint32_t scaleModSize = 73;

    /* A3) Number of plaintext slots used in the ciphertext.
   * CKKS packs multiple plaintext values in each ciphertext.
   * The maximum number of slots depends on a security parameter called ring
   * dimension. In this instance, we don't specify the ring dimension directly,
   * but let the library choose it for us, based on the security level we
   * choose, the multiplicative depth we want to support, and the scaling factor
   * size.
   *
   * Please use method GetRingDimension() to find out the exact ring dimension
   * being used for these parameters. Give ring dimension N, the maximum batch
   * size is N/2, because of the way CKKS works.
   */
    uint32_t batchSize = 8;

    /*
    * The word size in bits of the target hardware architecture.
    */
    uint32_t registerWordSize = 26;

    int argcCount = 1;
    if (argc > 1) {
        while (argcCount < argc) {
            uint32_t paramValue = atoi(argv[argcCount]);
            switch (argcCount) {
                case 1:
                    firstModSize = paramValue;
                    std::cout << "Setting First Mod Size: " << firstModSize << std::endl;
                    break;
                case 2:
                    scaleModSize = paramValue;
                    std::cout << "Setting Scaling Mod Size: " << scaleModSize << std::endl;
                    break;
                case 3:
                    registerWordSize = paramValue;
                    std::cout << "Setting Register Word Size: " << registerWordSize << std::endl;
                    break;
                case 4:
                    multDepth = paramValue;
                    std::cout << "Setting Multiplicative Depth: " << multDepth << std::endl;
                    break;
                default:
                    std::cout << "Invalid option" << std::endl;
                    break;
            }
            argcCount += 1;
            std::cout << "argcCount: " << argcCount << std::endl;
        }
        std::cout << "Complete !" << std::endl;
    }
    else {
        std::cout << "Using default parameters" << std::endl;
        std::cout << "First Mod Size: " << firstModSize << std::endl;
        std::cout << "Scaling Mod Size: " << scaleModSize << std::endl;
        std::cout << "Register Word Size: " << registerWordSize << std::endl;
        std::cout << "Multiplicative Depth: " << multDepth << std::endl;
        std::cout << "Usage: " << argv[0] << " [firstModSize] [scalingModSize] [registerWordSize] [multDepth]"
                  << std::endl;
    }

    /* A4) Desired security level based on FHE standards.
   * This parameter can take four values. Three of the possible values
   * correspond to 128-bit, 192-bit, and 256-bit security, and the fourth value
   * corresponds to "NotSet", which means that the user is responsible for
   * choosing security parameters. Naturally, "NotSet" should be used only in
   * non-production environments, or by experts who understand the security
   * implications of their choices.
   *
   * If a given security level is selected, the library will consult the current
   * security parameter tables defined by the FHE standards consortium
   * (https://homomorphicencryption.org/introduction/) to automatically
   * select the security parameters. Please see "TABLES of RECOMMENDED
   * PARAMETERS" in  the following reference for more details:
   * http://homomorphicencryption.org/wp-content/uploads/2018/11/HomomorphicEncryptionStandardv1.1.pdf
   */
    CCParams<CryptoContextCKKSRNS> parameters;
    parameters.SetMultiplicativeDepth(multDepth);
    parameters.SetFirstModSize(firstModSize);
    parameters.SetScalingModSize(scaleModSize);
    parameters.SetBatchSize(batchSize);
    parameters.SetSecurityLevel(HEStd_NotSet);
    parameters.SetRingDim(1 << 12);
    parameters.SetScalingTechnique(COMPOSITESCALINGAUTO);
    parameters.SetRegisterWordSize(registerWordSize);

    CryptoContext<DCRTPoly> cc     = GenCryptoContext(parameters);
    const auto cryptoParamsCKKSRNS = std::dynamic_pointer_cast<CryptoParametersCKKSRNS>(cc->GetCryptoParameters());
    std::cout << "Composite Degree: " << cryptoParamsCKKSRNS->GetCompositeDegree() << "\nPrime Modulus Size: "
              << static_cast<float>(scaleModSize) / cryptoParamsCKKSRNS->GetCompositeDegree()
              << "\nRegister Word Size: " << registerWordSize << std::endl;

    // Enable the features that you wish to use
    cc->Enable(PKE);
    cc->Enable(KEYSWITCH);
    cc->Enable(LEVELEDSHE);
    std::cout << "CKKS scheme is using ring dimension " << cc->GetRingDimension() << std::endl << std::endl;
    // RNS moduli (q_i) for the CRT towers
    auto elemParams = cc->GetElementParams();                 // DCRTPoly::Params
    const auto& towers = elemParams->GetParams();             // vector of sub-params

    std::cout << "CKKS us using RNS moduli q_i:\n";
    for (size_t i = 0; i < towers.size(); ++i) {
        std::cout << "  q[" << i << "] = " << towers[i]->GetModulus()  << std::endl;
        // Root of unity for this modulus
        // std::cout << "    rootOfUnity = " << towers[i]->GetRootOfUnity() << "\n";
    }

    // Number of polys in the batch
    const size_t batchCount = 32;

    using DugType = typename DCRTPoly::DugType; // uniform mod q
    DugType dug;
    long long sum_duration = 0;
    if(true){
    // Create batch of random RNS polynomials in coefficient domain
    for (size_t j = 0; j < 1000; ++j){
        std::vector<DCRTPoly> batch;
        batch.reserve(batchCount);
        for (size_t i = 0; i < batchCount; ++i) {
            batch.emplace_back(dug, elemParams, Format::COEFFICIENT);
        }
        // Time forward NTT (COEFFICIENT -> EVALUATION) for the entire batch
        auto t0 = std::chrono::high_resolution_clock::now();
        for (auto& a : batch) {
            a.SetFormat(EVALUATION);
        }
        auto t1 = std::chrono::high_resolution_clock::now();
        sum_duration += std::chrono::duration_cast<std::chrono::microseconds>(t1 - t0).count();
      }
      auto avg_us_fwd_batch = static_cast<double>(sum_duration)/1000;

    // Time inverse NTT (EVALUATION -> COEFFICIENT) for the entire batch
    sum_duration = 0;
    for (size_t j = 0; j < 1000; ++j){
        std::vector<DCRTPoly> batch;
        batch.reserve(batchCount);
        for (size_t i = 0; i < batchCount; ++i) {
            batch.emplace_back(dug, elemParams, Format::EVALUATION);
        }
        auto t2 = std::chrono::high_resolution_clock::now();
        for (auto& a : batch) {
            a.SetFormat(COEFFICIENT);
        }
        auto t3 = std::chrono::high_resolution_clock::now();
        sum_duration += std::chrono::duration_cast<std::chrono::microseconds>(t3 - t2).count();
    }
    auto avg_us_inv_batch = static_cast<double>(sum_duration)/1000;

    std::cout << "Average RNS Batch NTT latency with SW: " << std::dec << avg_us_fwd_batch << " microseconds" << std::endl;
    std::cout << "Average RNS Batch INTT latency with SW: " << std::dec << avg_us_inv_batch << " microseconds" << std::endl;
    }else{

    // Benchmarking NTT and INTT for Goldilocks Prime
    constexpr uint64_t Q64 = 18446744069414584321ULL; 
    const uint32_t N = 4096;
    const uint32_t m = 2 * N;

    NativeInteger q(Q64);
    NativeInteger ru = RootOfUnity<NativeInteger>(m, q);

    using Params = NativePoly::Params; // alias keeps code version-agnostic
    auto polyParams = std::make_shared<Params>(m, q, ru);

    sum_duration = 0;
    for (size_t j = 0; j < 1000; ++j){
      std::vector<NativePoly> res(32,NativePoly(polyParams, Format::COEFFICIENT, true));
      for (size_t j = 0; j < 32; ++j){
        for (size_t i = 0; i < N; ++i) {
            res[j][i] = i;
        }
      }

      // Benchmark Program Step 3: Calculate NTT in Software
      auto t4 = std::chrono::steady_clock::now();
      for (size_t j = 0; j < 32; ++j){
        for (size_t i = 0; i < N; ++i) {
            res[j].SetFormat(Format::EVALUATION);
        }
      }
      auto t5 = std::chrono::steady_clock::now();
      sum_duration += std::chrono::duration_cast<std::chrono::microseconds>(t5 - t4).count();
    }
    auto avg_us_fwd_batch_goldilock = static_cast<double>(sum_duration)/1000;
  
    std::cout << "Average Batch NTT latency with SW: " << std::dec << avg_us_fwd_batch_goldilock << " microseconds" << std::endl;

    sum_duration = 0;
    for (size_t j = 0; j < 1000; ++j){
      std::vector<NativePoly> res(32,NativePoly(polyParams, Format::EVALUATION, true));
      for (size_t j = 0; j < 32; ++j){
        for (size_t i = 0; i < N; ++i) {
            res[j][i] = i;
        }
      }
      // Benchmark Program Step 3: Calculate INTT in Software
      auto t6 = std::chrono::steady_clock::now();
      for (size_t j = 0; j < 32; ++j){
        for (size_t i = 0; i < N; ++i) {
            res[j].SetFormat(Format::COEFFICIENT);
        }
      }
      auto t7 = std::chrono::steady_clock::now();
      sum_duration += std::chrono::duration_cast<std::chrono::microseconds>(t7 - t6).count();
    }
    auto avg_us_inv_batch_goldilock = static_cast<double>(sum_duration)/1000;
  
    std::cout << "Average Batch INTT latency with SW: " << std::dec << avg_us_inv_batch_goldilock << " microseconds" << std::endl;
    }
    return 0;
}
