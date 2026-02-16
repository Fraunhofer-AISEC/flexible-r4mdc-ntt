// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "openfhe.h"

#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
#include <cstring>
#include <optional>
#include <filesystem>
#include <chrono>
#include <limits>
#include <random>

// XRT includes
#include "xrt/xrt_bo.h"
#include <experimental/xrt_xclbin.h>
#include <experimental/xrt_ip.h>
#include "xrt/xrt_device.h"
#include "xrt/xrt_kernel.h"

namespace fs = std::filesystem;
using namespace lbcrypto;

// ----------------------------- Helpers ----------------------------------------

static void print_usage() {
    std::cout
        << "Usage:\n"
        << "  ntt_goldilocks_bench.exe -s <core-id> <target> <platform> [--device <index|bdf>]\n\n"
        << "Example:\n"
        << "  ./ntt_goldilocks_bench.exe -s \"aisec:fpga:top_ntt_u55c_18446744069414584321_4096_8:0.1\" "
           "18446744069414584321_4096_uni u55c\n\n"
        << "Arguments:\n"
        << "  -s, --core    FuseSoC core ID (e.g., aisec:fpga:top_ntt_u55c_18446744069414584321_4096_8:0.1)\n"
        << "  <target>      parameterset (e.g., 18446744069414584321_4096_uni)\n"
        << "  <platform>    u200 | u250 | u55c\n"
        << "Options:\n"
        << "  --device      XRT device index (0,1,...) or BDF (e.g., 0000:e2:00.1). "
           "Currently ignored; device is hard-coded.\n";
}

static std::string sanitize_core_id(const std::string& core_id) {
    std::string out = core_id;
    for (auto& ch : out) {
        if (ch == ':')
            ch = '_';
    }
    return out;
}

// Parse core-id like "aisec:fpga:top_ntt_u55c_18446744069414584321_4096_8:0.1"
// -> platform=u55c, q=18446744069414584321, n=4096, pes=8
static bool parse_core_id(const std::string& core_id,
                          std::string& platform,
                          std::string& q,
                          std::string& n,
                          std::string& pes) {
    auto last_colon = core_id.rfind(':');
    std::string core_nover = (last_colon == std::string::npos) ? core_id : core_id.substr(0, last_colon);

    auto pos = core_nover.find("top_ntt_");
    if (pos == std::string::npos)
        return false;
    std::string tail = core_nover.substr(pos + std::string("top_ntt_").size());
    // Expect tail: "<platform>_<q>_<n>_<pes>"
    std::istringstream iss(tail);
    std::string token;
    std::vector<std::string> parts;
    while (std::getline(iss, token, '_'))
        parts.push_back(token);
    if (parts.size() != 4)
        return false;
    platform = parts[0];
    q        = parts[1];
    n        = parts[2];
    pes      = parts[3];
    return true;
}

// From parameterset "<q>_<n>_<mode>" extract q, n, mode
// mode is only used for kernel/xclbin naming (e.g., "uni", "uni_opt")
static bool parse_parameterset(const std::string& parameterset,
                               std::string& q,
                               std::string& n,
                               std::string& mode) {
    std::istringstream iss(parameterset);
    std::string token;
    std::vector<std::string> parts;
    while (std::getline(iss, token, '_'))
        parts.push_back(token);
    if (parts.size() < 3)
        return false;
    q    = parts[0];
    n    = parts[1];
    mode = parts[2];
    for (size_t i = 3; i < parts.size(); ++i) {
        mode += "_" + parts[i];
    }
    return true;
}

// Build short and long kernel names
static std::string make_short_kernel_name(const std::string& n,
                                          const std::string& mode,
                                          const std::string& pes) {
    return "ntt_" + n + "_" + mode + "_" + pes; // matches package_xo kernel_name
}
static std::string make_long_kernel_name(const std::string& parameterset,
                                         const std::string& platform,
                                         const std::string& pes) {
    return "top_ntt_" + parameterset + "_" + platform + "_" + pes;
}
static std::string make_xclbin_basename(const std::string& parameterset,
                                        const std::string& platform,
                                        const std::string& pes) {
    return "top_ntt_" + parameterset + "_" + platform + "_" + pes + ".xclbin";
}

// Try to locate the xclbin file in common locations
static std::optional<fs::path> find_xclbin(const std::string& core_id,
                                           const std::string& target,
                                           const std::string& xclbin_base) {
    fs::path cwd      = fs::current_path();
    std::string sanit = sanitize_core_id(core_id);

    std::vector<fs::path> candidates;
    candidates.emplace_back(cwd / xclbin_base);
    candidates.emplace_back(cwd / "xclbin" / xclbin_base);
    candidates.emplace_back(cwd / "build" / sanit / (target + "-vivado") / xclbin_base);

    for (const auto& p : candidates) {
        if (fs::exists(p))
            return p;
    }
    return std::nullopt;
}

// ---------------------------- HW benchmark -------------------------------------

template <typename T>
bool run_hw_benchmark(const std::string& core_id,
                      const std::string& parameterset,
                      const std::string& platform,
                      const std::optional<std::string>& /*device_arg*/,
                      size_t num_iterations) {
    // Parse parameterset
    std::string q_ps, n_ps, mode;
    if (!parse_parameterset(parameterset, q_ps, n_ps, mode)) {
        std::cerr << "ERROR: Invalid parameterset '" << parameterset
                  << "'. Expected '<q>_<n>_<mode>'." << std::endl;
        return false;
    }

    // Parse core-id
    std::string plat_ci, q_ci, n_ci, pes;
    if (!parse_core_id(core_id, plat_ci, q_ci, n_ci, pes)) {
        std::cerr << "ERROR: Could not parse core ID '" << core_id << "'." << std::endl;
        return false;
    }
    if (plat_ci != platform) {
        std::cerr << "ERROR: Platform mismatch: core='" << plat_ci
                  << "' CLI='" << platform << "'." << std::endl;
        return false;
    }
    if (q_ci != q_ps || n_ci != n_ps) {
        std::cerr << "ERROR: parameterset (" << q_ps << "_" << n_ps
                  << ") does not match core-id (" << q_ci << "_" << n_ci << ")." << std::endl;
        return false;
    }

    // Build kernel/xclbin names
    const std::string kernel_short = make_short_kernel_name(n_ps, mode, pes);
    const std::string kernel_long  = make_long_kernel_name(parameterset, platform, pes);
    const std::string xclbin_base  = make_xclbin_basename(parameterset, platform, pes);

    // Locate xclbin
    auto xclbin_path_opt = find_xclbin(core_id, parameterset, xclbin_base);
    if (!xclbin_path_opt) {
        std::cerr << "ERROR: Could not find xclbin '" << xclbin_base << "'. Searched:\n"
                  << "  ./\n  ./xclbin/\n  ./build/<sanitized-core>/<target>-vivado/\n";
        return false;
    }
    fs::path xclbin_path = *xclbin_path_opt;
    std::cout << "Using xclbin: " << xclbin_path.string() << std::endl;

    // Open device (currently hard-coded BDF, adjust as needed)
    auto device = xrt::device("0000:e2:00.1");

    std::cout << "Loading xclbin..." << std::endl;
    auto uuid = device.load_xclbin(xclbin_path.string());

    // Create kernel: try short name, then long name
    xrt::kernel krnl;
    try {
        krnl = xrt::kernel(device, uuid, kernel_short, xrt::kernel::cu_access_mode::exclusive);
        std::cout << "Kernel opened: " << kernel_short << std::endl;
    } catch (const std::exception& e) {
        std::cerr << "Warning: kernel '" << kernel_short << "' not found (" << e.what()
                  << "). Trying '" << kernel_long << "'..." << std::endl;
        try {
            krnl = xrt::kernel(device, uuid, kernel_long, xrt::kernel::cu_access_mode::exclusive);
            std::cout << "Kernel opened: " << kernel_long << std::endl;
        } catch (const std::exception& e2) {
            std::cerr << "ERROR: Could not open kernel by short or long name.\n"
                      << "  short: " << kernel_short << "\n"
                      << "  long : " << kernel_long << "\n"
                      << "Reason: " << e2.what() << std::endl;
            return false;
        }
    }

    // Data size: n
    const size_t batch_size = 32;
    size_t data_size        = static_cast<size_t>(std::stoul(n_ps));
    size_t vector_size_bytes = sizeof(T) * data_size;

    // Allocate BOs (global memory, 4 ports)
    auto boCoeff0 = xrt::bo(device, batch_size * vector_size_bytes / 4, 0);
    auto boCoeff1 = xrt::bo(device, batch_size * vector_size_bytes / 4, 1);
    auto boCoeff2 = xrt::bo(device, batch_size * vector_size_bytes / 4, 2);
    auto boCoeff3 = xrt::bo(device, batch_size * vector_size_bytes / 4, 3);

    auto boCoeff0_map = boCoeff0.map<T*>();
    auto boCoeff1_map = boCoeff1.map<T*>();
    auto boCoeff2_map = boCoeff2.map<T*>();
    auto boCoeff3_map = boCoeff3.map<T*>();

    // Initialize with dummy data
    std::fill(boCoeff0_map, boCoeff0_map + batch_size * data_size / 4, static_cast<T>(0xFFFFFFFFFFFFFFFFULL));
    std::fill(boCoeff1_map, boCoeff1_map + batch_size * data_size / 4, static_cast<T>(0xFFFFFFFFFFFFFFFFULL));
    std::fill(boCoeff2_map, boCoeff2_map + batch_size * data_size / 4, static_cast<T>(0xFFFFFFFFFFFFFFFFULL));
    std::fill(boCoeff3_map, boCoeff3_map + batch_size * data_size / 4, static_cast<T>(0xFFFFFFFFFFFFFFFFULL));

    // Sync to device once; content is irrelevant for pure latency benchmark
    boCoeff0.sync(XCL_BO_SYNC_BO_TO_DEVICE);
    boCoeff1.sync(XCL_BO_SYNC_BO_TO_DEVICE);
    boCoeff2.sync(XCL_BO_SYNC_BO_TO_DEVICE);
    boCoeff3.sync(XCL_BO_SYNC_BO_TO_DEVICE);

    // Run both directions: config=0 (NTT), config=1 (INTT)
    for (uint32_t config = 0; config <= 1; ++config) {
        const char* label = (config == 0) ? "NTT" : "INTT";

        auto run = xrt::run(krnl);
        run.set_arg(0, 0x0);
        run.set_arg(1, config); // config bit selects forward/inverse inside the kernel
        run.set_arg(2, 0x0);
        run.set_arg(3, boCoeff0);
        run.set_arg(4, boCoeff1);
        run.set_arg(5, boCoeff2);
        run.set_arg(6, boCoeff3);

        long long sum_duration = 0;
        for (size_t j = 0; j < 1000; ++j){
          auto start = std::chrono::steady_clock::now();
          run.start();
          run.wait();
          auto end = std::chrono::steady_clock::now();
          sum_duration += std::chrono::duration_cast<std::chrono::microseconds>(end - start).count();
        }
        //auto avg_us_fwd_batch = static_cast<double>(sum_duration)/1000;
        double avg_us = static_cast<double>(sum_duration) / 1000;
        std::cout << "Average Batch " << label << " latency with HW: "
                  << std::dec << avg_us << " microseconds" << std::endl;
    }

    // Optionally read back results if needed
    boCoeff0.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
    boCoeff1.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
    boCoeff2.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
    boCoeff3.sync(XCL_BO_SYNC_BO_FROM_DEVICE);

    return true;
}

// ---------------------------- SW benchmark -------------------------------------

// Benchmarks forward and inverse NTT with OpenFHE NativePoly for Goldilocks prime
static void run_sw_benchmark_goldilocks(std::size_t N,
                                        std::size_t batch_size,
                                        std::size_t num_iterations) {

    // Benchmarking NTT and INTT for Goldilocks Prime
    constexpr uint64_t Q64 = 18446744069414584321ULL; 
    const uint32_t m = 2 * N;

    // Initialize a random number generator
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> distrib(0, 1024);

    using DugType = typename DCRTPoly::DugType; // uniform mod q
    DugType dug;

    long long sum_duration = 0;

    NativeInteger q(Q64);
    NativeInteger ru = RootOfUnity<NativeInteger>(m, q);

    using Params = NativePoly::Params; // alias keeps code version-agnostic
    auto polyParams = std::make_shared<Params>(m, q, ru);

    sum_duration = 0;

    for (size_t j = 0; j < 1000; ++j){
      std::vector<NativePoly> res(32,NativePoly(polyParams, Format::COEFFICIENT, true));
      for (size_t j = 0; j < 32; ++j){
        for (size_t i = 0; i < N; ++i) {
            res[j][i] = distrib(gen);
        }
      }

      // Benchmark Program Step 3: Calculate NTT in Software
      auto t4 = std::chrono::steady_clock::now();
      for (size_t j = 0; j < 32; ++j){
        res[j].SetFormat(Format::EVALUATION);
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
        res[j].SetFormat(Format::COEFFICIENT);
      }
      auto t7 = std::chrono::steady_clock::now();
      sum_duration += std::chrono::duration_cast<std::chrono::microseconds>(t7 - t6).count();
    }
    auto avg_us_inv_batch_goldilock = static_cast<double>(sum_duration)/1000;
  
    std::cout << "Average Batch INTT latency with SW: " << std::dec << avg_us_inv_batch_goldilock << " microseconds" << std::endl;

}

// ------------------------------- main -----------------------------------------

int main(int argc, char** argv) {
    if (argc < 4) {
        print_usage();
        return 1;
    }

    std::string core_id;
    std::string parameterset;
    std::string platform;
    std::optional<std::string> device_opt;

    // Simple CLI parse
    int i = 1;
    while (i < argc) {
        std::string arg = argv[i];
        if (arg == "-s" || arg == "--core") {
            if (i + 1 >= argc) {
                print_usage();
                return 1;
            }
            core_id = argv[++i];
        } else if (arg == "--device") {
            if (i + 1 >= argc) {
                print_usage();
                return 1;
            }
            device_opt = argv[++i];
        } else if (parameterset.empty()) {
            parameterset = arg;
        } else if (platform.empty()) {
            platform = arg;
        } else {
            std::cerr << "Unexpected argument: " << arg << std::endl;
            print_usage();
            return 1;
        }
        ++i;
    }

    if (core_id.empty() || parameterset.empty() || platform.empty()) {
        print_usage();
        return 1;
    }

    if (platform != "u200" && platform != "u250" && platform != "u55c") {
        std::cerr << "ERROR: Invalid platform '" << platform
                  << "'. Allowed: u200, u250, u55c." << std::endl;
        return 1;
    }

    // Extract q and n from parameterset to configure SW benchmark
    std::string q_ps, n_ps, mode_ps;
    if (!parse_parameterset(parameterset, q_ps, n_ps, mode_ps)) {
        std::cerr << "ERROR: Invalid parameterset '" << parameterset
                  << "'. Expected '<q>_<n>_<mode>'." << std::endl;
        return 1;
    }

    constexpr uint64_t GOLDILOCKS_Q = 18446744069414584321ULL;
    const std::string goldilocks_q_str = std::to_string(GOLDILOCKS_Q);
    if (q_ps != goldilocks_q_str) {
        std::cerr << "WARNING: q in parameterset (" << q_ps
                  << ") does not match Goldilocks q="
                  << goldilocks_q_str << ". Make sure this matches your bitstream."
                  << std::endl;
    }

    size_t N = static_cast<size_t>(std::stoul(n_ps));
    const size_t batch_size    = 32;
    const size_t num_iterations_hw = 1000;  // adjust as desired
    const size_t num_iterations_sw = 1000;  // adjust as desired

    bool hw_ok = false;
    try {
        hw_ok = run_hw_benchmark<unsigned long long>(
            core_id, parameterset, platform, device_opt, num_iterations_hw);
    } catch (const std::exception& e) {
        std::cerr << "Unhandled exception during HW benchmark: " << e.what() << std::endl;
        return 3;
    }

    // SW reference benchmark (Goldilocks, same N and batch size)
    try {
        run_sw_benchmark_goldilocks(N, batch_size, num_iterations_sw);
    } catch (const std::exception& e) {
        std::cerr << "Unhandled exception during SW benchmark: " << e.what() << std::endl;
        // Do not change HW result based on SW failure
    }

    return hw_ok ? 0 : 2;
}

