{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.modules.packages.jetbrains;

  anyDisabled =
    !cfg.enablePyCharm
    || !cfg.enableWebStorm
    || !cfg.enableIdea
    || !cfg.enableClion
    || !cfg.enableGoLand
    || !cfg.enableRustRover;
in
{
  options.modules.packages.jetbrains = {
    enableAll = mkOption {
      type = types.bool;
      default = false;
      description = "Enable all JetBrains IDEs";
    };
    enablePyCharm = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable PyCharm IDE";
    };
    enableWebStorm = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable WebStorm IDE";
    };
    enableIdea = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable IntelliJ IDEA IDE";
    };
    enableClion = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable CLion IDE";
    };
    enableGoLand = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable GoLand IDE";
    };
    enableRustRover = mkOption {
      type = types.bool;
      default = cfg.enableAll;
      description = "Enable RustRover IDE";
    };
  };

  config = {
    assertions = [
      {
        assertion = !(cfg.enableAll && anyDisabled);
        message = "modules.packages.jetbrains: enableAll=true cannot be combined with any per-IDE option set to false";
      }
    ];

    home.packages = mkMerge [
      (mkIf cfg.enablePyCharm [ pkgs.jetbrains.pycharm ])
      (mkIf cfg.enableWebStorm [ pkgs.jetbrains.webstorm ])
      (mkIf cfg.enableIdea [ pkgs.jetbrains.idea ])
      (mkIf cfg.enableClion [ pkgs.jetbrains.clion ])
      (mkIf cfg.enableGoLand [ pkgs.jetbrains.goland ])
      (mkIf cfg.enableRustRover [ pkgs.jetbrains.rust-rover ])
    ];
  };
}
