{ config, lib, ... }:

with lib;

let
  cfg = config.modules.amd-rx6600xt;
in
{
  options.modules.amd-rx6600xt = {
    enable = mkEnableOption "AMD RX 6600 XT support (for PyTorch, etc.)";
    #
  };

  config = mkIf cfg.enable {
    hardware.amdgpu.opencl.enable = true;
    environment.variables = {
      HSA_OVERRIDE_GFX_VERSION = "10.3.0";  # AMD RX 6600 XT (RDNA 2)
      HSA_ENABLE_SDMA = "0";
    };
  };
}
