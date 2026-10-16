{ config, lib, ... }:

let
  cfg = config.modules.nixpkgs-config;

  # Filter out functions (e.g. packageOverrides, allowUnfreePredicate)
  # leaving only pure serializable settings
  serializableConfig =
    if config.nixpkgs.config != null then
      lib.filterAttrs (_: v: !builtins.isFunction v) config.nixpkgs.config
    else
      { };
in
{
  options.modules.nixpkgs-config = {
    enable = lib.mkEnableOption "Enable exporting nixpkgs.config to ~/.config/nixpkgs/config.nix";
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."nixpkgs/config.nix".text = ''
      # Generated automatically by modules.nixpkgs-config
      ${lib.generators.toPretty { } serializableConfig}
    '';
  };
}
