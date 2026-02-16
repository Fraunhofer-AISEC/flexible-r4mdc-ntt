// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

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
    << "  test_top_ntt_rns.exe -s <core-id> <target> <platform> [--device <index|bdf>] [--tv-root <path>]\n\n"
    << "Example:\n"
    << "  ./test_top_ntt_rns.exe -s \"aisec:fpga:top_ntt_u55c_33550337_1024_16:0.1\" 33550337_1024_dit u55c\n\n"
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

// Read hex testvector lines into buffer and data vector
template <typename T>
bool read_testvector(const std::string& filename, std::vector<T>& data, T buf[], size_t data_size) {
  std::ifstream infile(filename);
  if (!infile) {
    std::cerr << "Unable to open file " << filename << std::endl;
    return false;
  }
  size_t index = 0;
  std::string line;
  while (std::getline(infile, line) && index < data_size) {
    std::stringstream ss;
    ss << std::hex << line;
    T value{};
    ss >> value;
    buf[index] = value;
    data.push_back(value);
    ++index;
  }
  infile.close();
  if (index != data_size) {
    std::cerr << "Warning: read " << index << " elements, expected " << data_size << std::endl;
  }
  return true;
}

// Build testvector paths: tv_root/ntt_<q>_<n>/testvector_coeff_<q>_<n>_0.mem etc.
static void make_testvector_paths(const fs::path& tv_root,
                                  const std::string& q,
                                  const std::string& n,
                                  const std::string& mode,
                                  const std::string& testcase,
                                  fs::path& coeff_in,
                                  fs::path& coeff_exp) {
  std::string base = q + "_" + n;
  fs::path dir = tv_root / ("ntt_" + base);
  if (mode == "dit") {
    coeff_in  = dir / ("testvector_coeff_ntt_"      + base + "_" + testcase + ".mem");
    coeff_exp = dir / ("testvector_coeff_exp_ntt_"  + base + "_" + testcase + ".mem");
  } else {
    coeff_in  = dir / ("testvector_coeff_intt_"      + base + "_" + testcase + ".mem");
    coeff_exp = dir / ("testvector_coeff_exp_intt_"  + base + "_" + testcase + ".mem");
  }
}

template <typename T>
bool run_test(const std::string& core_id,
              const std::string& parameterset,
              const std::string& platform,
              const std::optional<std::string>& device_arg,
              const std::string& configuration,
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
  
  const size_t nof_bfu = static_cast<size_t>(std::stoul(pes));

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
  config = (configuration == "dit") ? 0x0 : 0x1;

  // Allocate BO (global memory)
  auto boCoeff0 = xrt::bo(device, batch_size*vector_size_bytes/4, 0); // bank 0 unless overridden
  auto boCoeff1 = xrt::bo(device, batch_size*vector_size_bytes/4, 1); // bank 1 unless overridden
  auto boCoeff2 = xrt::bo(device, batch_size*vector_size_bytes/4, 2); // bank 2 unless overridden
  auto boCoeff3 = xrt::bo(device, batch_size*vector_size_bytes/4, 3); // bank 3 unless overridden

  std::vector<T> ref0(batch_size*data_size/4);
  std::vector<T> ref1(batch_size*data_size/4);
  std::vector<T> ref2(batch_size*data_size/4);
  std::vector<T> ref3(batch_size*data_size/4);

  std::vector<T> dbg0(batch_size*data_size/4);
  std::vector<T> dbg1(batch_size*data_size/4);
  std::vector<T> dbg2(batch_size*data_size/4);
  std::vector<T> dbg3(batch_size*data_size/4);

  // Map buffer
  auto boCoeff0_map = boCoeff0.map<T*>();
  std::fill(boCoeff0_map, boCoeff0_map + batch_size*data_size/4, 0);

  auto boCoeff1_map = boCoeff1.map<T*>();
  std::fill(boCoeff1_map, boCoeff1_map + batch_size*data_size/4, 0);

  auto boCoeff2_map = boCoeff2.map<T*>();
  std::fill(boCoeff2_map, boCoeff2_map + batch_size*data_size/4, 0);

  auto boCoeff3_map = boCoeff3.map<T*>();
  std::fill(boCoeff3_map, boCoeff3_map + batch_size*data_size/4, 0);

  std::vector<T> data_in;
  std::vector<T> data_exp;

  std::unique_ptr<T[]> buf(new T[data_size]);
  std::unique_ptr<T[]> buf_exp(new T[data_size]);
  

  // Testvectors
  for (size_t k = 0; k < batch_size; ++k) { 
    fs::path coeff_in, coeff_exp;
    make_testvector_paths(tv_root, q_ps, n_ps, configuration, std::to_string(k), coeff_in, coeff_exp);

    if (!read_testvector<T>(coeff_in.string(),  data_in,  buf.get(),     data_size)) return false;
    if (!read_testvector<T>(coeff_exp.string(), data_exp, buf_exp.get(), data_size)) return false;

    if (configuration == "dit") { 

      if (nof_bfu == 8) {
        const size_t N = data_size;
        const size_t NTTS_PER_NTT = 2;
        const size_t BFU_PER_GROUP = 2;
        const size_t STRIDE_BETWEEN_BFUS_IN_GROUP = N / 16;
        const size_t STRIDE_BETWEEN_BFUGROUP      = N / 4;
        const size_t STRIDE_BETWEEN_NTT_IN_BFU    = N / 8;

        // j iterates (N/4)/NOF_BUTTERFLY_UNITS/NTTS_PER_NTT = N/64
        const size_t jmax = (N / 4) / nof_bfu / NTTS_PER_NTT;

        for (size_t n = 0; n < NTTS_PER_NTT; ++n) {
          for (size_t j = 0; j < jmax; ++j) {
            for (size_t i = 0; i < nof_bfu / BFU_PER_GROUP; ++i) {   // 0..3
              for (size_t l = 0; l < BFU_PER_GROUP; ++l) {           // 0..1
                const size_t lane = BFU_PER_GROUP * i + l;           // 0..7
                // Linear index in the port buffer for this batch k
                const size_t dst = k * (N / 4) + (n * jmax + j) * nof_bfu + lane;

                const size_t base = i * STRIDE_BETWEEN_BFUGROUP
                                  + l * STRIDE_BETWEEN_BFUS_IN_GROUP
                                  + n * STRIDE_BETWEEN_NTT_IN_BFU;

                ref0[dst] = buf_exp[4 * j + 0 + base];
                ref1[dst] = buf_exp[4 * j + 1 + base];
                ref2[dst] = buf_exp[4 * j + 2 + base];
                ref3[dst] = buf_exp[4 * j + 3 + base];
              }
            }
          }
        }
      } else {
        // fallback to your existing mapping for other BFU counts
        for (size_t j = 0; j < (data_size / 4) / 8; ++j) {
          for (size_t i = 0; i < 8; ++i) {
            ref0[k*data_size/4+i+j*8] = buf_exp[4*j +     i*data_size/8];
            ref1[k*data_size/4+i+j*8] = buf_exp[4*j + 1 + i*data_size/8];
            ref2[k*data_size/4+i+j*8] = buf_exp[4*j + 2 + i*data_size/8];
            ref3[k*data_size/4+i+j*8] = buf_exp[4*j + 3 + i*data_size/8];
          }
        }
      }
      for (size_t j = 0; j < (data_size/4)/8; ++j) {
        for (size_t i = 0; i < 8; ++i) {
          boCoeff0_map[k*data_size/4+i+j*8] = buf[j+i*data_size/(4*8)];
          boCoeff1_map[k*data_size/4+i+j*8] = buf[data_size/4+j+i*data_size/(4*8)];
          boCoeff2_map[k*data_size/4+i+j*8] = buf[data_size/2+j+i*data_size/(4*8)];
          boCoeff3_map[k*data_size/4+i+j*8] = buf[data_size/2+data_size/4+j+i*data_size/(4*8)];
          dbg0[k*data_size/4+i+j*8] = buf[j+i*data_size/(4*8)];
          dbg1[k*data_size/4+i+j*8] = buf[data_size/4+j+i*data_size/(4*8)];
          dbg2[k*data_size/4+i+j*8] = buf[data_size/2+j+i*data_size/(4*8)];
          dbg3[k*data_size/4+i+j*8] = buf[data_size/2+data_size/4+j+i*data_size/(4*8)];
        }
      }
    } else {

      if (nof_bfu == 8) {
        const size_t N = data_size;
        const size_t NTTS_PER_NTT = 2;
        const size_t BFU_PER_GROUP = 2;
        const size_t STRIDE_BETWEEN_BFUS_IN_GROUP = N / 16;
        const size_t STRIDE_BETWEEN_BFUGROUP      = N / 4;
        const size_t STRIDE_BETWEEN_NTT_IN_BFU    = N / 8;

        // jmax = (N/4)/NOF_BUTTERFLY_UNITS/NTTS_PER_NTT = N/64
        const size_t jmax = (N / 4) / nof_bfu / NTTS_PER_NTT;

        for (size_t n = 0; n < NTTS_PER_NTT; ++n) {
          for (size_t j = 0; j < jmax; ++j) {
            for (size_t i = 0; i < nof_bfu / BFU_PER_GROUP; ++i) { // 0..3
              for (size_t l = 0; l < BFU_PER_GROUP; ++l) {         // 0..1
                const size_t lane = BFU_PER_GROUP * i + l;         // 0..7
                const size_t dst  = k * (N / 4) + (n * jmax + j) * nof_bfu + lane;

                const size_t base = i * STRIDE_BETWEEN_BFUGROUP
                                  + l * STRIDE_BETWEEN_BFUS_IN_GROUP
                                  + n * STRIDE_BETWEEN_NTT_IN_BFU;

                // Inputs to the 4 AXI ports
                boCoeff0_map[dst] = buf[4 * j + 0 + base];
                boCoeff1_map[dst] = buf[4 * j + 1 + base];
                boCoeff2_map[dst] = buf[4 * j + 2 + base];
                boCoeff3_map[dst] = buf[4 * j + 3 + base];
              }
            }
          }
        }
      } else {
        // Fallback (original non-uni mapping)
        for (size_t j = 0; j < (data_size / 4) / 8; ++j) {
          for (size_t i = 0; i < 8; ++i) {
            boCoeff0_map[k * data_size / 4 + i + j * 8] = buf[4 * j +     i * data_size / 8];
            boCoeff1_map[k * data_size / 4 + i + j * 8] = buf[4 * j + 1 + i * data_size / 8];
            boCoeff2_map[k * data_size / 4 + i + j * 8] = buf[4 * j + 2 + i * data_size / 8];
            boCoeff3_map[k * data_size / 4 + i + j * 8] = buf[4 * j + 3 + i * data_size / 8];
          }
        }
      }

      for (size_t j = 0; j < (data_size/4)/8; ++j) {
        for (size_t i = 0; i < 8; ++i) {
          // Please make changes here:
          ref0[k*data_size/4+i+j*8] = buf_exp[j+i*data_size/(4*8)];
          ref1[k*data_size/4+i+j*8] = buf_exp[data_size/4+j+i*data_size/(4*8)];
          ref2[k*data_size/4+i+j*8] = buf_exp[data_size/2+j+i*data_size/(4*8)];
          ref3[k*data_size/4+i+j*8] = buf_exp[data_size/2+data_size/4+j+i*data_size/(4*8)];
        }
      }
    }
  }
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

  // Uncomment the line below for debugging with ILAs
  wait_for_enter("\nPress ENTER to continue after setting up ILA trigger...");

  auto start = std::chrono::steady_clock::now();
  run.start();
  run.wait();
  auto end = std::chrono::steady_clock::now();
  auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start).count();
  if (configuration == "dit") { 
    std::cout << "Batch NTT latency with HW: " << std::dec << duration << " microseconds" << std::endl;
  } else {
    std::cout << "Batch INTT latency with HW: " << std::dec << duration << " microseconds" << std::endl;
  }
  // Read back
  boCoeff0.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
  boCoeff1.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
  boCoeff2.sync(XCL_BO_SYNC_BO_FROM_DEVICE);
  boCoeff3.sync(XCL_BO_SYNC_BO_FROM_DEVICE);

  // Validate (compare bytes)
  if (std::memcmp(boCoeff0_map, ref0.data(), batch_size*data_size/4 * sizeof(T)) != 0) {
    std::cerr << "Validation FAILED: output does not match reference for Port 0" << std::endl;
    return false;
  }
  if (std::memcmp(boCoeff1_map, ref1.data(), batch_size*data_size/4 * sizeof(T)) != 0) {
    std::cerr << "Validation FAILED: output does not match reference for Port 1" << std::endl;
    return false;
  }
  if (std::memcmp(boCoeff2_map, ref2.data(), batch_size*data_size/4 * sizeof(T)) != 0) {
    std::cerr << "Validation FAILED: output does not match reference for Port 2" << std::endl;
    return false;
  }
  if (std::memcmp(boCoeff3_map, ref3.data(), batch_size*data_size/4 * sizeof(T)) != 0) {
    std::cerr << "Validation FAILED: output does not match reference for Port 3" << std::endl;
    return false;
  }
  std::cout << "TEST PASSED" << std::endl;
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

  // Validate platform
  if (platform != "u200" && platform != "u250" && platform != "u55c") {
    std::cerr << "ERROR: Invalid platform '" << platform << "'. Allowed: u200, u250, u55c." << std::endl;
    return 1;
  }

  try {
    bool ok = run_test<unsigned long long>(core_id, parameterset, platform, device_opt, "dit", tv_root);
    ok = run_test<unsigned long long>(core_id, parameterset, platform, device_opt, "dif", tv_root);
    return ok ? 0 : 2;
  } catch (const std::exception& e) {
    std::cerr << "Unhandled exception: " << e.what() << std::endl;
    return 3;
  }
}