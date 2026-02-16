// Copyright Fraunhofer Institute for Applied and Integrated Security (AISEC).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0   

package arith_pkg; 
  
    // The table below summarizes the width and height of DSP slices for different devices
    // Type         DSP_W x DSP_H                       Devices
    //-------------------------------------------------------------------------
    // DSP48A1:     18 x 18 signed (17 x 17 unsigned)   6-Series
    // DSP48E1:     25 x 18 signed (24 x 17 unsigned)   7-Series
    // DSP48E2:     27 x 18 signed (26 x 17 unsigned)   UltraScale, UltraScale+

    typedef enum integer {
      FPGA7Series         = 0,   // AMD FPGA 7-Series Devices
      FPGAUltraScale      = 1,   // AMD FPGA UltraScale Devices
      FPGAUltraScalePlus  = 2,   // AMD FPGA UltraScale+ Devices
      FPGA6Series         = 3    // AMD FPGA 6-Series Devices
    } device_e;

    typedef enum integer {
      Dsp48A1WidthSigned   = 18, // AMD FPGA 6-Series Devices
      Dsp48E1WidthSigned   = 25, // AMD FPGA 7-Series Devices
      Dsp48E2WidthSigned   = 27, // AMD FPGA UltraScale+ Devices
      Dsp48A1WidthUnsigned = 17, // AMD FPGA 6-Series Devices
      Dsp48E1WidthUnsigned = 24, // AMD FPGA 7-Series Devices
      Dsp48E2WidthUnsigned = 26  // AMD FPGA UltraScale+ Devices
    } dsp_w_e;

    typedef enum integer {
      DspHeightSigned   = 18, 
      DspHeightUnsigned = 17
    } dsp_h_e;

    typedef struct packed {
      dsp_w_e           DspWidth;
      dsp_h_e           DspHeight;
      device_e          DeviceType;
    } dsp_implementation_t;

    localparam dsp_implementation_t XILINX_6_SERIES_SIGNED = '{
        DspWidth:   Dsp48A1WidthSigned,
        DspHeight:  DspHeightSigned,
        DeviceType: FPGA6Series
    };

    localparam dsp_implementation_t XILINX_6_SERIES_UNSIGNED = '{
        DspWidth:   Dsp48A1WidthUnsigned,
        DspHeight:  DspHeightUnsigned,
        DeviceType: FPGA6Series
    };

    localparam dsp_implementation_t XILINX_7_SERIES_SIGNED = '{
        DspWidth:   Dsp48E1WidthSigned,
        DspHeight:  DspHeightSigned,
        DeviceType: FPGA7Series
    };

    localparam dsp_implementation_t XILINX_7_SERIES_UNSIGNED = '{
        DspWidth:   Dsp48E1WidthUnsigned,
        DspHeight:  DspHeightUnsigned,
        DeviceType: FPGA7Series
    };

    localparam dsp_implementation_t XILINX_ULTRASCALE_SIGNED = '{
        DspWidth:   Dsp48E2WidthSigned,
        DspHeight:  DspHeightSigned,
        DeviceType: FPGAUltraScale
    };

    localparam dsp_implementation_t XILINX_ULTRASCALE_UNSIGNED = '{
        DspWidth:   Dsp48E2WidthUnsigned,
        DspHeight:  DspHeightUnsigned,
        DeviceType: FPGAUltraScale
    };

    localparam dsp_implementation_t XILINX_ULTRASCALE_PLUS_SIGNED = '{
        DspWidth:   Dsp48E2WidthSigned,
        DspHeight:  DspHeightSigned,
        DeviceType: FPGAUltraScalePlus
    };

    localparam dsp_implementation_t XILINX_ULTRASCALE_PLUS_UNSIGNED = '{
        DspWidth:   Dsp48E2WidthUnsigned,
        DspHeight:  DspHeightUnsigned,
        DeviceType: FPGAUltraScalePlus
    };

    // Global default DSP implementation setting
  `ifdef TARGET_XILINX_7_SERIES_UNSIGNED
    localparam dsp_implementation_t GLOBAL_DSP_IMPL = XILINX_7_SERIES_UNSIGNED;
  `elsif TARGET_XILINX_7_SERIES_SIGNED
    localparam dsp_implementation_t GLOBAL_DSP_IMPL = XILINX_7_SERIES_SIGNED;
  `elsif TARGET_XILINX_ULTRASCLAE_UNSIGNED
    localparam dsp_implementation_t GLOBAL_DSP_IMPL = XILINX_ULTRASCALE_UNSIGNED;
  `elsif TARGET_XILINX_ULTRASCLAE_SIGNED
    localparam dsp_implementation_t GLOBAL_DSP_IMPL = XILINX_ULTRASCALE_SIGNED;
  `elsif TARGET_XILINX_ULTRASCLAE_PLUS_UNSIGNED
    localparam dsp_implementation_t GLOBAL_DSP_IMPL = XILINX_ULTRASCALE_PLUS_UNSIGNED;
  `elsif TARGET_XILINX_ULTRASCLAE_PLUS_SIGNED
    localparam dsp_implementation_t GLOBAL_DSP_IMPL = XILINX_ULTRASCALE_PLUS_SIGNED;
  `elsif TARGET_XILINX_6_SERIES_UNSIGNED
    localparam dsp_implementation_t GLOBAL_DSP_IMPL = XILINX_6_SERIES_UNSIGNED;
  `elsif TARGET_XILINX_6_SERIES_SIGNED
    localparam dsp_implementation_t GLOBAL_DSP_IMPL = XILINX_6_SERIES_SIGNED;
  `else
    localparam dsp_implementation_t GLOBAL_DSP_IMPL = XILINX_ULTRASCALE_PLUS_UNSIGNED;
  `endif

endpackage 