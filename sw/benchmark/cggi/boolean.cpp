// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "binfhecontext.h"

using namespace lbcrypto;

#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>
#include <cstring>
#include <optional>
#include <filesystem>

// XRT includes
#include "xrt/xrt_bo.h"
#include <experimental/xrt_xclbin.h>
#include <experimental/xrt_ip.h>
#include "xrt/xrt_device.h"
#include "xrt/xrt_kernel.h"

namespace fs = std::filesystem;

void wait_for_enter(const std::string &msg) {
	std::cout << msg << std::endl;
	std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
}

static void print_usage() {
  std::cout
    << "Usage:\n"
    << "  ntt_app.exe -s <core-id> <target> <platform> [--device <index|bdf>] [--tv-root <path>]\n\n"
    << "Example:\n"
    << "  ./ntt_app.exe -s \"aisec:fpga:top_ntt_u55c_33550337_1024_16:0.1\" 33550337_1024_dit u55c\n\n"
    << "Arguments:\n"
    << "  -s, --core    FuseSoC core ID (e.g., aisec:fpga:top_ntt_u55c_33550337_1024_16:0.1)\n"
    << "  <target>      parameterset (e.g., 33550337_1024_dit)\n"
    << "  <platform>    u200 | u250 | u55c\n"
    << "Options:\n"
    << "  --device      XRT device index (0,1,...) or BDF (e.g., 0000:21:00.1). Default index 0.\n"
    << "  --tv-root     Testvector root directory. Default: hw/top_ntt/dv/tb/testcases/testvectors\n";
}

static std::string sanitize_core_id(const std::string& core_id) {
  std::string out = core_id;
  for (auto& ch : out) {
    if (ch == ':') ch = '_';
  }
  return out;
}

// Parse core-id like "aisec:fpga:top_ntt_u55c_33550337_1024_16:0.1"
// -> platform=u55c, q=33550337, n=1024, pes=16
static bool parse_core_id(const std::string& core_id, std::string& platform, std::string& q, std::string& n, std::string& pes) {
  auto last_colon = core_id.rfind(':');
  std::string core_nover = (last_colon == std::string::npos) ? core_id : core_id.substr(0, last_colon);

  auto pos = core_nover.find("top_ntt_");
  if (pos == std::string::npos) return false;
  std::string tail = core_nover.substr(pos + std::string("top_ntt_").size());
  // Expect tail: "<platform>_<q>_<n>_<pes>"
  std::istringstream iss(tail);
  std::string token;
  std::vector<std::string> parts;
  while (std::getline(iss, token, '_')) parts.push_back(token);
  if (parts.size() != 4) return false;
  platform = parts[0];
  q = parts[1];
  n = parts[2];
  pes = parts[3];
  return true;
}

// From parameterset "<q>_<n>_<mode>" extract q, n, mode
static bool parse_parameterset(const std::string& parameterset, std::string& q, std::string& n, std::string& mode) {
  std::istringstream iss(parameterset);
  std::string token;
  std::vector<std::string> parts;
  while (std::getline(iss, token, '_')) parts.push_back(token);
  if (parts.size() < 3) return false;
  q = parts[0];
  n = parts[1];
  // mode can contain '_' (e.g., uni_opt). Join remaining parts.
  mode = parts[2];
  for (size_t i = 3; i < parts.size(); ++i) {
    mode += "_" + parts[i];
  }
  return true;
}

// Build short and long kernel names
static std::string make_short_kernel_name(const std::string& n, const std::string& mode, const std::string& pes) {
  return "ntt_" + n + "_" + mode + "_" + pes; // matches package_xo kernel_name
}
static std::string make_long_kernel_name(const std::string& parameterset, const std::string& platform, const std::string& pes) {
  return "top_ntt_" + parameterset + "_" + platform + "_" + pes;
}
static std::string make_xclbin_basename(const std::string& parameterset, const std::string& platform, const std::string& pes) {
  return "top_ntt_" + parameterset + "_" + platform + "_" + pes + ".xclbin";
}

// Try to locate the xclbin file in common locations
static std::optional<fs::path> find_xclbin(const std::string& core_id,
                                           const std::string& target,
                                           const std::string& xclbin_base) {
  fs::path cwd = fs::current_path();
  std::string sanitized = sanitize_core_id(core_id);

  std::vector<fs::path> candidates;
  candidates.emplace_back(cwd / xclbin_base);
  candidates.emplace_back(cwd / "xclbin" / xclbin_base);
  candidates.emplace_back(cwd / "build" / sanitized / (target + "-vivado") / xclbin_base);

  for (const auto& p : candidates) {
    if (fs::exists(p)) return p;
  }
  return std::nullopt;
}

template <typename T>
bool run_test(const std::string& core_id,
              const std::string& parameterset,
              const std::string& platform,
              const std::optional<std::string>& device_arg,
              const fs::path& tv_root)
{
  // Parse parameters
  std::string q_ps, n_ps, mode;
  if (!parse_parameterset(parameterset, q_ps, n_ps, mode)) {
    std::cerr << "ERROR: Invalid parameterset '" << parameterset << "'. Expected '<q>_<n>_<mode>'." << std::endl;
    return false;
  }
  // Parse core id for platform/q/n/pes
  std::string plat_ci, q_ci, n_ci, pes;
  if (!parse_core_id(core_id, plat_ci, q_ci, n_ci, pes)) {
    std::cerr << "ERROR: Could not parse core ID '" << core_id << "'." << std::endl;
    return false;
  }
  if (plat_ci != platform) {
    std::cerr << "ERROR: Platform mismatch: core='" << plat_ci << "' CLI='" << platform << "'." << std::endl;
    return false;
  }
  if (q_ci != q_ps || n_ci != n_ps) {
    std::cerr << "ERROR: parameterset (" << q_ps << "_" << n_ps << ") does not match core-id (" << q_ci << "_" << n_ci << ")." << std::endl;
    return false;
  }

  // Build names
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

  // Open device
  auto device = xrt::device("0000:e2:00.1");
  
  std::cout << "PATH: " << xclbin_path.string() << std::endl;
  // Load xclbin
  std::cout << "Loading xclbin..." << std::endl;
  auto uuid = device.load_xclbin(xclbin_path.string());

  // Create kernel: try short name first, fall back to long name
  xrt::kernel krnl;
  try {
    krnl = xrt::kernel(device, uuid, kernel_short,xrt::kernel::cu_access_mode::exclusive);
    std::cout << "Kernel opened: " << kernel_short << std::endl;
  } catch (const std::exception& e) {
    std::cerr << "Warning: kernel '" << kernel_short << "' not found (" << e.what() << "). Trying '" << kernel_long << "'..." << std::endl;
    try {
      krnl = xrt::kernel(device, uuid, kernel_long,xrt::kernel::cu_access_mode::exclusive);
      std::cout << "Kernel opened: " << kernel_long << std::endl;
    } catch (const std::exception& e2) {
      std::cerr << "ERROR: Could not open kernel by short or long name.\n"
                << "  short: " << kernel_short << "\n"
                << "  long : " << kernel_long  << "\n"
                << "Reason: " << e2.what() << std::endl;
      return false;
    }
  }

  // Data size: n
  size_t batch_size = 32;
  size_t data_size = static_cast<size_t>(std::stoul(n_ps));
  size_t vector_size_bytes = sizeof(T) * data_size;
  uint32_t config;
  config = (mode == "dit") ? 0x0 : 0x1;
  std::cout << "\nCONFIG: " << config << std::endl;
  // Allocate BO (global memory)
  auto boCoeff0 = xrt::bo(device, batch_size*vector_size_bytes/4, 0); // bank 0 unless overridden
  auto boCoeff1 = xrt::bo(device, batch_size*vector_size_bytes/4, 1); // bank 1 unless overridden
  auto boCoeff2 = xrt::bo(device, batch_size*vector_size_bytes/4, 2); // bank 2 unless overridden
  auto boCoeff3 = xrt::bo(device, batch_size*vector_size_bytes/4, 3); // bank 3 unless overridden

  std::vector<T> ref0(batch_size*data_size/4);
  std::vector<T> ref1(batch_size*data_size/4);
  std::vector<T> ref2(batch_size*data_size/4);
  std::vector<T> ref3(batch_size*data_size/4);

  // Map buffer
  auto boCoeff0_map = boCoeff0.map<T*>();
  std::fill(boCoeff0_map, boCoeff0_map + batch_size*data_size/4, 0xff);

  auto boCoeff1_map = boCoeff1.map<T*>();
  std::fill(boCoeff1_map, boCoeff1_map + batch_size*data_size/4, 0xff);

  auto boCoeff2_map = boCoeff2.map<T*>();
  std::fill(boCoeff2_map, boCoeff2_map + batch_size*data_size/4, 0xff);

  auto boCoeff3_map = boCoeff3.map<T*>();
  std::fill(boCoeff3_map, boCoeff3_map + batch_size*data_size/4, 0xff);

  std::vector<T> data_in;
  std::vector<T> data_exp;

  std::unique_ptr<T[]> buf(new T[data_size]);
  std::unique_ptr<T[]> buf_exp(new T[data_size]);

  // Testvectors

  // Sync to device
  boCoeff0.sync(XCL_BO_SYNC_BO_TO_DEVICE);
  boCoeff1.sync(XCL_BO_SYNC_BO_TO_DEVICE);
  boCoeff2.sync(XCL_BO_SYNC_BO_TO_DEVICE);
  boCoeff3.sync(XCL_BO_SYNC_BO_TO_DEVICE);

  std::cout << "Running kernel..." << std::endl;

  // Setup kernel
  auto run = xrt::run(krnl);
  run.set_arg(0,0x0);
  run.set_arg(1,config); 
  run.set_arg(2,0x0); 
  run.set_arg(3,boCoeff0); 
  run.set_arg(4,boCoeff1); 
  run.set_arg(5,boCoeff2); 
  run.set_arg(6,boCoeff3); 

  long long sum_duration = 0;
  for (size_t j = 0; j < 1000; ++j){
    auto start = std::chrono::steady_clock::now();
    run.start();
    run.wait();
    auto end = std::chrono::steady_clock::now();
    sum_duration += std::chrono::duration_cast<std::chrono::microseconds>(end - start).count();
  }
  auto avg_us_fwd_batch = static_cast<double>(sum_duration)/1000;
  if (mode == "dit"){
    std::cout << "Average Batch NTT latency with HW: " << std::dec << avg_us_fwd_batch << " microseconds" << std::endl;
  } else {
    std::cout << "Average Batch INTT latency with HW: " << std::dec << avg_us_fwd_batch << " microseconds" << std::endl;
  }
  
  // Read back
  boCoeff0.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
  boCoeff1.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
  boCoeff2.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
  boCoeff3.sync(XCL_BO_SYNC_BO_FROM_DEVICE);

  return true;
}

int main(int argc, char** argv) {
  if (argc < 4) {
    print_usage();
    return 1;
  }

  std::string core_id;
  std::string parameterset;
  std::string platform;
  std::optional<std::string> device_opt;
  fs::path tv_root = fs::current_path() / "hw" / "dv" / "testvectors";

  // Simple CLI parse
  int i = 1;
  while (i < argc) {
    std::string arg = argv[i];
    if (arg == "-s" || arg == "--core") {
      if (i + 1 >= argc) { print_usage(); return 1; }
      core_id = argv[++i];
    } else if (arg == "--device") {
      if (i + 1 >= argc) { print_usage(); return 1; }
      device_opt = argv[++i];
    } else if (arg == "--tv-root") {
      if (i + 1 >= argc) { print_usage(); return 1; }
      tv_root = fs::path(argv[++i]);
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

  // Parse parameters
  std::string q_ps, n_ps, mode;
  if (!parse_parameterset(parameterset, q_ps, n_ps, mode)) {
    std::cerr << "ERROR: Invalid parameterset '" << parameterset << "'. Expected '<q>_<n>_<mode>'." << std::endl;
    return 1;
  }

  // Validate platform
  xrt::kernel krnl;
  if (platform != "u200" && platform != "u250" && platform != "u55c") {
    std::cerr << "ERROR: Invalid platform '" << platform << "'. Allowed: u200, u250, u55c." << std::endl;
    return 1;
  }
  bool ok;
  try {
    // Data type: adjust if your kernel expects wider words. For now, 32-bit signed.
    ok = run_test<int>(core_id, parameterset, platform, device_opt, tv_root);
    //return ok ? 0 : 2;
  } catch (const std::exception& e) {
    std::cerr << "Unhandled exception: " << e.what() << std::endl;
    return 3;
  }

    // Benchmark Program: Step 1: Set CryptoContext
    auto cc = BinFHEContext();

    // STD128 is the security level of 128 bits of security based on LWE Estimator
    // and HE standard. Other common options are TOY, MEDIUM, STD192, and STD256.
    // MEDIUM corresponds to the level of more than 100 bits for both quantum and
    // classical computer attacks.
    cc.GenerateBinFHEContext(STD128Q);

    auto polyParams  = cc.GetParams()->GetRingGSWParams()->GetPolyParams();
    auto N = cc.GetParams()->GetRingGSWParams()->GetN();
    auto Q = cc.GetParams()->GetRingGSWParams()->GetQ();

    // Benchmark Program Step 2: Initalize Polynomials  
    NativeVector m(N, Q);
    

    if (mode == "dit"){
        long long sum_duration = 0;
        for (size_t j = 0; j < 1000; ++j){
          std::vector<NativePoly> res(32,NativePoly(polyParams, Format::COEFFICIENT, true));
          for (size_t j = 0; j < 32; ++j){
            for (size_t i = 0; i < N; ++i) {
                res[j][i] = i;
            }
          }

          // Benchmark Program Step 3: Calculate NTT in Software
          auto start = std::chrono::steady_clock::now();
          for (size_t j = 0; j < 32; ++j){
              res[j].SetFormat(Format::EVALUATION);
          }
          auto end = std::chrono::steady_clock::now();
          sum_duration += std::chrono::duration_cast<std::chrono::microseconds>(end - start).count();
        }
        auto avg_us_fwd_batch = static_cast<double>(sum_duration)/1000;
      
        std::cout << "Average Batch NTT latency with SW: " << std::dec << avg_us_fwd_batch << " microseconds" << std::endl;
    }
    if (mode == "dif"){
        long long sum_duration = 0;
        for (size_t j = 0; j < 1000; ++j){
          std::vector<NativePoly> res(32,NativePoly(polyParams, Format::EVALUATION, true));
          for (size_t j = 0; j < 32; ++j){
            for (size_t i = 0; i < N; ++i) {
                res[j][i] = i;
            }
          }

          // Benchmark Program Step 3: Calculate INTT in Software
          auto start = std::chrono::steady_clock::now();
          for (size_t j = 0; j < 32; ++j){
              res[j].SetFormat(Format::COEFFICIENT);
          }
          auto end = std::chrono::steady_clock::now();
          sum_duration += std::chrono::duration_cast<std::chrono::microseconds>(end - start).count();
        }
        auto avg_us_fwd_batch = static_cast<double>(sum_duration)/1000;
      
        std::cout << "Average Batch INTT latency with SW: " << std::dec << avg_us_fwd_batch << " microseconds" << std::endl;
    }
    return ok ? 0 : 2;
}
